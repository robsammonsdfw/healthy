//
//  MyLogViewController.m
//  DietMasterGo
//
//  Created by Andrew Moffitt on 11/23/10.
//  Copyright 2010 AE Studios. All rights reserved.
//

#import "MyLogViewController.h"

@import SafariServices;
#import <HealthKit/HealthKit.h>

#import "MyMovesViewController.h"
#import "DetailViewController.h"
#import "ExercisesDetailViewController.h"
#import "Log_Add.h"
#import "ExercisesViewController.h"
#import "FoodsHome.h"
#import "MyLogTableViewCell.h"
#import "FoodsSearch.h"
#import "StepData.h"
#import "MyMovesDataProvider.h"
#import "TTTAttributedLabel.h"
#import "DietMasterGoViewController.h"
#import "MyGoalViewController.h"
#import "MealPlanViewController.h"

#define DETAIL_VIEW_TAG 883344
#define CALORIE_BAR_HEIGHT 185
#define CALORIE_BAR_CLOSED_HEIGHT 68

#import "StepData.h"

@interface MyLogViewController ()<SFSafariViewControllerDelegate, UIGestureRecognizerDelegate, TTTAttributedLabelDelegate>
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) LogDaySummary *logDaySummary;
/// Array of titles for the sections of the log.
@property (nonatomic, strong) NSArray *sectionTitleArray;
/// Dictionary of foods per meal. Key = Section title, eg. "Breakfast"
/// Value = Dictionary of foods, where "Calories" = total calorie count, and "Foods" = array of foods.
@property (nonatomic, strong) NSMutableDictionary *sectionFoodsDict;
/// Exercises logged for the day.
@property (nonatomic, strong) NSMutableArray *exerciseResults;

/// Date that's currently being displayed.
@property (nonatomic, strong) NSDate *date_currentDate;

/// For collecting Apple Calories / Steps.
@property (nonatomic,retain) HKHealthStore *healthStore;
@property (nonatomic, strong) StepData *stepData;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIToolbar *dateToolBar;
@property (nonatomic, strong) IBOutlet UILabel *lbl_dateHdr;

/// Totals for calculating Remaining values.
@property (nonatomic) CGFloat actualCarbCalories;
@property (nonatomic) CGFloat actualFatCalories;
@property (nonatomic) CGFloat actualProteinCalories;

@end

static NSString *CellIdentifier = @"MyLogTableViewCell";

@implementation MyLogViewController

#pragma mark VIEW LIFECYCLE

- (instancetype)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _exerciseResults = [NSMutableArray array];
        _sectionFoodsDict = [NSMutableDictionary dictionary];
        _sectionTitleArray = @[@"Breakfast", @"Snack 1", @"Lunch", @"Snack 2", @"Dinner", @"Snack 3", @"Exercise"];
        _healthStore = [[HKHealthStore alloc] init];
        _stepData = [[StepData alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"ReloadData" object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"My Log";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
        
    self.lbl_dateHdr.textColor = AccentFontColor
    self.lbl_dateHdr.backgroundColor = [UIColor clearColor];
    
    self.dateToolBar.backgroundColor = AccentColor;
    self.dateToolBar.barTintColor = AccentColor;
    
    self.tableView.backgroundColor = UIColorFromHex(0xF3F3F3);
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    UINib *nib = [UINib nibWithNibName:@"MyLogTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];

    self.view.backgroundColor = [UIColor whiteColor];
    
    if (!self.date_currentDate) {
        NSDate *sourceDate = [NSDate date];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
        [self.dateFormatter setTimeZone:systemTimeZone];
        NSString *date_string = [self.dateFormatter stringFromDate:sourceDate];
        NSDate *destinationDate = [self.dateFormatter dateFromString:date_string];
        self.date_currentDate = destinationDate;
    }
    
    NSDate* sourceDate = [NSDate date];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
    [self.dateFormatter setTimeZone:systemTimeZone];
    NSString *date_string = [self.dateFormatter stringFromDate:sourceDate];
    NSDate *currDate = [self.dateFormatter dateFromString:date_string];
    
    self.date_currentDate = currDate;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationItem.rightBarButtonItem=nil;
        
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:PLIST_NAME];
    NSDictionary *appDefaults = [[NSDictionary alloc] initWithContentsOfFile:finalPath];
    UIImageView *backgroundImage = (UIImageView *)[self.view viewWithTag:501];
    if ([[appDefaults valueForKey:@"account_code"] isEqualToString:@"ezdietplanner"]) {
        backgroundImage.image = [UIImage imageNamed:@"Log_Screen"];
    }
    
    [self.navigationController.navigationBar setTranslucent:NO];
    self.tableView.separatorColor = [UIColor lightGrayColor];
    
    UISwipeGestureRecognizer *swipe_Recognizer_Next = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe_Action:)];
    [swipe_Recognizer_Next setDelegate:self];
    [swipe_Recognizer_Next setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.tableView addGestureRecognizer:swipe_Recognizer_Next];
    
    UISwipeGestureRecognizer *swipe_Recognizer_Previous = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe_Action:)];
    [swipe_Recognizer_Previous setDelegate:self];
    [swipe_Recognizer_Previous setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.tableView addGestureRecognizer:swipe_Recognizer_Previous];
    
    UILayoutGuide *layoutGuide = self.view.safeAreaLayoutGuide;

    self.logDaySummary = [[LogDaySummary alloc] initWithFrame:CGRectZero];
    self.logDaySummary.translatesAutoresizingMaskIntoConstraints = NO;
    __weak typeof(self) weakSelf = self;
    self.logDaySummary.didSelectInfoButtonCallback = ^{
        [weakSelf goToSafetyGuidelines:nil];
    };
    [self.view addSubview:self.logDaySummary];
    
    [self.logDaySummary.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:0].active = YES;
    [self.logDaySummary.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:0].active = YES;
    [self.logDaySummary.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:0].active = YES;
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:0].active = YES;
    [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:0].active = YES;
    [self.tableView.topAnchor constraintEqualToAnchor:self.dateToolBar.bottomAnchor constant:0].active = YES;
    [self.tableView.bottomAnchor constraintEqualToAnchor:self.logDaySummary.topAnchor constant:0].active = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"My Log";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    [self updateCalorieTotal];
    [self updateAppleWatchData];
    [self updateData:self.date_currentDate];
}

- (void)updateAppleWatchData {
    HKAuthorizationStatus permissionStatus = [self.healthStore authorizationStatusForType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]];
    
    DMUser *currentUser = [[DMAuthManager sharedInstance] loggedInUser];
    if (permissionStatus == HKAuthorizationStatusSharingAuthorized) {
        if (currentUser.enableAppleHealthSync) {
            [self readData];
        }
        else {
            DMLog(@"** Auto update apple watch sync is off **");
        }
    }
    else if (permissionStatus == HKAuthorizationStatusSharingDenied) {
        DMLog(@"** HKHealthStore HKAuthorizationStatusSharingDenied **");
    }
}

#pragma mark TABLE VIEW METHODS

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionTitleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = self.sectionTitleArray[section];

    DayDataProvider* dayProvider = [DayDataProvider sharedInstance];
    double exerciseCalories = [dayProvider getCaloriesBurnedViaExerciseWithDate:self.date_currentDate];

    NSString *calorieCount = @"";
    if ([sectionTitle isEqualToString:@"Exercise"]) {
        calorieCount = [NSString stringWithFormat:@"-%.0f Calories", exerciseCalories];
    } else {
        NSDictionary *foodsDict = self.sectionFoodsDict[sectionTitle];
        calorieCount = [NSString stringWithFormat:@"%i Calories", [foodsDict[@"Calories"] intValue]];
    }
            
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectZero];
    headerView.backgroundColor = UIColorFromHex(0xF3F3F3);

    UIButton *plusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    plusButton.translatesAutoresizingMaskIntoConstraints = NO;
    [plusButton addTarget:self
                  action:@selector(logFoodOrExercise:)
        forControlEvents:UIControlEventTouchUpInside];
    [plusButton setBackgroundImage:[UIImage imageNamed:@"plusfinal"] forState:UIControlStateNormal];
    plusButton.tag = section;
    [headerView addSubview:plusButton];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = sectionTitle;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel setFont:[UIFont systemFontOfSize:16]];
    [headerView addSubview:titleLabel];

    UILabel *calorieLabel = [[UILabel alloc] init];
    calorieLabel.translatesAutoresizingMaskIntoConstraints = NO;
    calorieLabel.text = calorieCount;
    calorieLabel.textColor = [UIColor darkGrayColor];
    calorieLabel.font = [UIFont boldSystemFontOfSize:13.0];
    calorieLabel.backgroundColor = [UIColor clearColor];
    calorieLabel.textAlignment = NSTextAlignmentRight;
    [headerView addSubview:calorieLabel];

    UIButton *favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    favoriteButton.translatesAutoresizingMaskIntoConstraints = NO;
    [favoriteButton addTarget:self action:@selector(saveFavoriteMeal:) forControlEvents:UIControlEventTouchUpInside];
    UIImage *image = [[UIImage imageNamed:@"03-heart.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [favoriteButton setImage:image forState:UIControlStateNormal];
    favoriteButton.tintColor = PrimaryColor
    favoriteButton.tag = section;
    favoriteButton.hidden = [sectionTitle isEqualToString:@"Exercise"];
    [headerView addSubview:favoriteButton];
    
    [plusButton.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor constant:12].active = YES;
    [plusButton.centerYAnchor constraintEqualToAnchor:headerView.centerYAnchor constant:0].active = YES;
    [plusButton.widthAnchor constraintEqualToConstant:25].active = YES;
    [plusButton.heightAnchor constraintEqualToConstant:25].active = YES;

    [titleLabel.leadingAnchor constraintEqualToAnchor:plusButton.trailingAnchor constant:14].active = YES;
    [titleLabel.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor constant:0].active = YES;
    [titleLabel.topAnchor constraintEqualToAnchor:headerView.topAnchor constant:0].active = YES;
    [titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];

    [calorieLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:titleLabel.trailingAnchor constant:10].active = YES;
    [calorieLabel.topAnchor constraintEqualToAnchor:headerView.topAnchor constant:0].active = YES;
    [calorieLabel.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor constant:0].active = YES;
    [calorieLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [calorieLabel.trailingAnchor constraintEqualToAnchor:favoriteButton.leadingAnchor constant:-12].active = YES;
    
    [favoriteButton.trailingAnchor constraintLessThanOrEqualToAnchor:headerView.trailingAnchor constant:-12].active = YES;
    [favoriteButton.widthAnchor constraintEqualToConstant:33].active = YES;
    [favoriteButton.heightAnchor constraintEqualToConstant:33].active = YES;
    [favoriteButton.centerYAnchor constraintEqualToAnchor:headerView.centerYAnchor constant:0].active = YES;

    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *sectionTitle = self.sectionTitleArray[section];
    if ([sectionTitle isEqualToString:@"Exercise"]) {
        return self.exerciseResults.count;
    } else {
        return [self.sectionFoodsDict[sectionTitle][@"Foods"] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DayDataProvider *dayProvider = [DayDataProvider sharedInstance];
    double currentUserWeight = [dayProvider getCurrentWeight].doubleValue;
    NSString *sectionTitle = self.sectionTitleArray[indexPath.section];

    MyLogTableViewCell *cell = (MyLogTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *foodNameText = nil;
    NSString *calorieText = nil;
    
    if ([sectionTitle isEqualToString:@"Exercise"]) {
        NSArray *exerciseResultsArray = [self.exerciseResults copy];
        NSDictionary *dict = exerciseResultsArray[indexPath.row];
        int exerciseID = [[dict valueForKey:@"ExerciseID"] intValue];
        NSNumber *caloriesPerHour = [dict valueForKey:@"CaloriesPerHour"];
        int minutesExercised = [[dict valueForKey:@"Exercise_Time_Minutes"] intValue];
                    
        double totalCaloriesBurned;
        if (exerciseID == 257 || exerciseID == 267) {
            totalCaloriesBurned = minutesExercised;
            calorieText = [NSString stringWithFormat:@"-%.0f Calories",totalCaloriesBurned];
        }
        else if (exerciseID == 268) {
            totalCaloriesBurned = minutesExercised;
            calorieText = [NSString stringWithFormat:@"-%.0f Moves",totalCaloriesBurned];
        }
        else if (exerciseID == 269 || exerciseID == 276) {
            totalCaloriesBurned = minutesExercised;
            calorieText = [NSString stringWithFormat:@"%.0f Steps",totalCaloriesBurned];
        }
        else if (exerciseID == 259) {
            totalCaloriesBurned = 0.0;
            calorieText = [NSString stringWithFormat:@"%i Steps", minutesExercised];
        }
        else if (exerciseID == 272 || exerciseID == 275) {
            totalCaloriesBurned = minutesExercised;
            calorieText = [NSString stringWithFormat:@"-%.0f Calories",totalCaloriesBurned];
        }
        else if (exerciseID == 274) {
            totalCaloriesBurned = 0.0;
            calorieText = [NSString stringWithFormat:@"%i Steps",minutesExercised];
        }
        else {
            totalCaloriesBurned = ([caloriesPerHour floatValue]/ 60) * currentUserWeight * minutesExercised;
            calorieText = [NSString stringWithFormat:@"-%.0f Calories",totalCaloriesBurned];
        }
        foodNameText = [dict valueForKey:@"ActivityName"];
    } else {
        NSDictionary *dict = self.sectionFoodsDict[sectionTitle][@"Foods"][indexPath.row];
        NSString *nameString = [dict valueForKey:@"Name"];
        NSRange r = [nameString rangeOfString:nameString];
        foodNameText = nameString;
        
        NSNumber *foodCategory = [dict valueForKey:@"CategoryID"];
        if ([foodCategory intValue] == 66) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *hostname = [prefs stringForKey:@"HostName"];
            NSNumber *recipeID = [dict valueForKey:@"RecipeID"];
            if (hostname != nil && ![hostname isEqualToString:@""] && recipeID != nil && [recipeID intValue] > 0) {
                cell.lblFoodName.delegate = self;
                NSString *url = [NSString stringWithFormat:@"%@/PDFviewer.aspx?ReportName=CustomRecipe&ID=%@", hostname, recipeID];
                [cell.lblFoodName addLinkToURL:[NSURL URLWithString:url] withRange:r];
            }
            
        } else {
            NSString *foodURL = [dict valueForKey:@"FoodURL"];
            if (foodURL != nil && ![foodURL isEqualToString:@""]) {
                cell.lblFoodName.delegate = self;
                [cell.lblFoodName addLinkToURL:[NSURL URLWithString:foodURL] withRange:r];
            } else {
                cell.lblFoodName.delegate = nil;
            }
        }
        calorieText = [NSString stringWithFormat:@"%i Calories",[[dict valueForKey:@"TotalCalories"] intValue]];
    }
        
    cell.lblFoodName.numberOfLines = 1;
    cell.lblFoodName.lineBreakMode = NSLineBreakByTruncatingTail;
    cell.lblFoodName.textColor = [UIColor blackColor];
    cell.lblCalories.textColor = [UIColor darkGrayColor];
    cell.lblFoodName.font = [UIFont boldSystemFontOfSize:14];
    cell.lblCalories.font = [UIFont systemFontOfSize:12];
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.separatorInset = UIEdgeInsetsZero;

    // We set the text last, because the TTAttributedLabel ignores properties set
    // after text is set.
    cell.lblCalories.text = calorieText;
    cell.lblFoodName.text = foodNameText;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionTitle = self.sectionTitleArray[indexPath.section];
    [self.dateFormatter setDateFormat:@"MMMM d, yyyy"];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if ([sectionTitle isEqualToString:@"Exercise"]) {
        NSDictionary *dict = self.exerciseResults[indexPath.row];
        ExercisesDetailViewController *controller =
            [[ExercisesDetailViewController alloc] initWithExerciseDict:dict
                                                           selectedDate:self.date_currentDate];
        controller.taskMode = DMTaskModeEdit;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else {
        DMMyLogDataProvider *provider = [[DMMyLogDataProvider alloc] init];
        NSDictionary *foodDict = self.sectionFoodsDict[sectionTitle][@"Foods"][indexPath.row];
        DMFood *food = [provider getFoodForFoodKey:foodDict[@"FoodID"]];
        DetailViewController *controller = [[DetailViewController alloc] initWithFood:food
                                                                             mealCode:indexPath.section
                                                                     selectedServings:foodDict[@"Servings"]
                                                                         selectedDate:self.date_currentDate];
        controller.taskMode = DMTaskModeEdit;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - TTTAttributedLabel Delegate

- (void)attributedLabel:(__unused TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

#pragma mark - Date

- (IBAction)shownextDate:(id)sender {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    NSCalendar *cal = [NSCalendar currentCalendar];
    [components setDay:+1];
    NSDate *date_Tomorrow = [cal dateByAddingComponents:components toDate:self.date_currentDate options:0];
    
    self.date_currentDate = date_Tomorrow;
    
    HKAuthorizationStatus permissionStatus = [self.healthStore authorizationStatusForType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]];
    
    DMUser *currentUser = [[DMAuthManager sharedInstance] loggedInUser];

    if (permissionStatus == HKAuthorizationStatusSharingAuthorized) {
        if (currentUser.enableAppleHealthSync){
            [self readData];
        }
        else {
            DMLog(@"** Auto update apple watch sync is off **");
        }
    }
    else if (permissionStatus == HKAuthorizationStatusSharingDenied) {
        DMLog(@"** HKHealthStore HKAuthorizationStatusSharingDenied **");
    }
    
    [self updateData:date_Tomorrow];
}

- (IBAction)showprevDate:(id)sender {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    NSCalendar *cal = [NSCalendar currentCalendar];
    [components setDay:-1];
    NSDate *date_Yesterday = [cal dateByAddingComponents:components toDate:self.date_currentDate options:0];
    self.date_currentDate = date_Yesterday;
    
    HKAuthorizationStatus permissionStatus = [self.healthStore authorizationStatusForType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]];
    if (permissionStatus == HKAuthorizationStatusSharingAuthorized) {
        DMUser *currentUser = [[DMAuthManager sharedInstance] loggedInUser];
        if (currentUser.enableAppleHealthSync){
            [self readData];
        }
    }
    
    [self updateData:date_Yesterday];
}

- (IBAction)swipe_Action:(UISwipeGestureRecognizer *)sender {
    switch (sender.direction) {
        case UISwipeGestureRecognizerDirectionLeft:
            [self shownextDate:nil];
            break;
        case UISwipeGestureRecognizerDirectionRight:
            [self showprevDate:nil];
            break;
        default:
            break;
    }
}

#pragma mark Saving and Logging

/// Shows the food list or exercise list to user, so they can select
/// a food or exercise for that time of day selected.
- (IBAction)logFoodOrExercise:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSInteger section = button.tag;
    if (section > self.sectionTitleArray.count-1) {
        return;
    }
    
    NSString *mealName = self.sectionTitleArray[section];
    DMLogMealCode mealCode = (DMLogMealCode)section;
    
    if (mealCode <= DMLogMealCodeSnackThree) {
        FoodsSearch *fhController1 = [[FoodsSearch alloc] initWithMealCode:mealCode selectedDate:self.date_currentDate];
        fhController1.title = mealName;
        fhController1.taskMode = DMTaskModeAdd;
        [self.navigationController pushViewController:fhController1 animated:YES];
        
    } else if (mealCode == DMLogMealCodeExercise) {
        ExercisesViewController *exercisesViewController = [[ExercisesViewController alloc] initWithSelectedDate:self.date_currentDate];
        exercisesViewController.taskMode = DMTaskModeAdd;
        [self.navigationController pushViewController:exercisesViewController animated:YES];
    }
}

- (IBAction)saveFavoriteMeal:(id)sender {
    NSInteger section = [sender tag];
    NSString *sectionTitle = self.sectionTitleArray[section];
    NSDictionary *mealDict = self.sectionFoodsDict[sectionTitle];
    if (!mealDict) {
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Save as Favorite Meal"
                                                                   message:@"Enter short name or description."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        // Configure.
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"Save"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        NSString *mealName = [alert.textFields.firstObject.text capitalizedString];
        if ([mealName length] == 0) {
            [DMGUtilities showAlertWithTitle:@"Error" message:@"Favorite Meal Name is required. Please try again." inViewController:nil];
        } else {
            [self saveFavoriteMeal:mealDict withName:mealName];
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)saveFavoriteMeal:(NSDictionary *)mealDict withName:(NSString *)mealName {
    [DMActivityIndicator showActivityIndicator];

    DMMyLogDataProvider *provider = [[DMMyLogDataProvider alloc] init];
    [provider saveFavoriteMeal:mealDict withName:mealName];
    
    [DMActivityIndicator hideActivityIndicator];
    [DMActivityIndicator showCompletedIndicator];
}

#pragma mark DATA METHODS

- (void)updateCalorieTotal {
    DayDataProvider* dayProvider = [DayDataProvider sharedInstance];

    // What's recommended.
    DMUser *currentUser = [[DMAuthManager sharedInstance] loggedInUser];
    CGFloat bmrValue = [dayProvider getCurrentBMR].floatValue;
    CGFloat carbGramsRecommended = (currentUser.carbRatio.floatValue / 100) * bmrValue / 4;
    CGFloat proteinGramsRecommended = (currentUser.proteinRatio.floatValue / 100) * bmrValue / 4;
    CGFloat fatGramsRecommended = (currentUser.fatRatio.floatValue / 100) * bmrValue / 9;
    
    NSString *carbGramsRecString = [NSString stringWithFormat:@"%.1fg", carbGramsRecommended];
    NSString *proteinGramsRecString = [NSString stringWithFormat:@"%.1fg", proteinGramsRecommended];
    NSString *fatGramsRecString = [NSString stringWithFormat:@"%.1fg", fatGramsRecommended];
    NSString *caloriesRecommended = [NSString stringWithFormat:@"%.0f", bmrValue];
    [self.logDaySummary setRecommendedLabelsWithCalorie:caloriesRecommended
                                                  carbs:carbGramsRecString
                                                protein:proteinGramsRecString
                                                    fat:fatGramsRecString];
    
    double caloriesRemaining = [dayProvider getTotalCaloriesRemainingWithDate:self.date_currentDate].doubleValue;

    /// What we've consumed.
    NSString *remainingCalories = [NSString stringWithFormat:@"%.0f", caloriesRemaining];
    NSString *carbGramsActual = [NSString stringWithFormat:@"%.1fg", round(carbGramsRecommended - (self.actualCarbCalories / 4))];
    NSString *fatGramsActual = [NSString stringWithFormat:@"%.1fg", round(fatGramsRecommended - (self.actualFatCalories / 9))];
    NSString *proteinGramsActual = [NSString stringWithFormat:@"%.1fg", round(proteinGramsRecommended - (self.actualProteinCalories / 4))];

    [self.logDaySummary setRemainingLabelsWithCalorie:remainingCalories
                                                carbs:carbGramsActual
                                              protein:proteinGramsActual
                                                  fat:fatGramsActual];
}

- (void)loadExerciseData:(NSDate *)date {
    [self.exerciseResults removeAllObjects];
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDateFormatter *dateFormat_display = [[NSDateFormatter alloc] init];
    [dateFormat_display setDateFormat:@"MMMM d, yyyy"];
    NSString *date_Today = [dateFormat stringFromDate:date];
    
    NSString *query = [NSString stringWithFormat:@"SELECT Exercise_Log.Exercise_Log_ID, Exercise_Log.ExerciseID, Exercise_Log.Exercise_Time_Minutes, Exercise_Log.Log_Date, Exercises.ActivityName, Exercises.CaloriesPerHour FROM Exercise_Log INNER JOIN Exercises ON Exercise_Log.ExerciseID = Exercises.ExerciseID WHERE (Exercise_Log.Log_Date BETWEEN DATETIME('%@ 00:00:00') AND DATETIME('%@ 23:59:59')) ORDER BY Log_Date", date_Today, date_Today];
        
    FMResultSet *rs = [db executeQuery:query];
    while ([rs next]) {
        NSNumber *exerciseLogID = [NSNumber numberWithInt:[rs intForColumn:@"Exercise_Log_ID"]];
        
        NSNumber *exerciseID = [NSNumber numberWithInt:[rs intForColumn:@"ExerciseID"]];
        NSNumber *exerciseTimeMinutes = [NSNumber numberWithInt:[rs intForColumn:@"Exercise_Time_Minutes"]];
        NSString *activityName = [[NSString alloc] initWithString:[rs stringForColumn:@"ActivityName"]];
        NSNumber *caloriesPerHour = [NSNumber numberWithDouble:[rs doubleForColumn:@"CaloriesPerHour"]];
        
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              exerciseLogID, @"Exercise_Log_ID",
                              exerciseID, @"ExerciseID",
                              exerciseTimeMinutes, @"Exercise_Time_Minutes",
                              activityName, @"ActivityName",
                              caloriesPerHour, @"CaloriesPerHour",
                              nil];
        [self.exerciseResults addObject:dict];
    }
    
    [rs close];
    [self.tableView reloadData];
    [self updateCalorieTotal];
}

- (void)reloadData {
    if ([NSThread isMainThread]) {
        [self updateData:self.date_currentDate];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData];
        });
    }
}

- (void)updateData:(NSDate *)date {
    [self.sectionFoodsDict removeAllObjects];
    
    NSMutableArray *breakfastArray = [NSMutableArray array];
    NSMutableArray *snack1Array = [NSMutableArray array];
    NSMutableArray *lunchArray = [NSMutableArray array];
    NSMutableArray *snack2Array = [NSMutableArray array];
    NSMutableArray *dinnerArray = [NSMutableArray array];
    NSMutableArray *snack3Array = [NSMutableArray array];
    
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }
    
    NSTimeZone *systemTimeZone = [NSTimeZone systemTimeZone];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [self.dateFormatter setTimeZone:systemTimeZone];
    NSString *date_Today = [self.dateFormatter stringFromDate:date];
    [self.dateFormatter setDateStyle:NSDateFormatterLongStyle];
    NSString *date_Display = [self.dateFormatter stringFromDate:date];
    
    self.lbl_dateHdr.text = date_Display;
    self.date_currentDate = date;
    
    NSString *query = [NSString stringWithFormat: @"SELECT Food_Log.MealID, Food_Log.MealDate, Food_Log_Items.MealCode, Food_Log_Items.FoodID, Food_Log_Items.MeasureID, Food_Log_Items.NumberOfServings, Food.FoodKey, Food.Name, Food.Calories, Food.Fat, Food.Carbohydrates, Food.Protein, FoodMeasure.GramWeight, Food.ServingSize, Food.CategoryID, Food.RecipeID, Food.FoodURL, count(1) FROM Food_Log INNER JOIN Food_Log_Items ON Food_Log.MealID = Food_Log_Items.MealID INNER JOIN Food ON Food.FoodKey = Food_Log_Items.FoodID INNER JOIN FoodMeasure ON FoodMeasure.FoodID = Food.FoodKey WHERE (Food_Log.MealDate BETWEEN DATETIME('%@ 00:00:00') AND DATETIME('%@ 23:59:59')) AND Food_Log_Items.MeasureID = FoodMeasure.MeasureID group by Food_Log.MealID, Food_Log.MealDate, Food_Log_Items.MealCode, Food_Log_Items.FoodID, Food_Log_Items.MeasureID, Food.FoodKey ORDER BY Food_Log_Items.MealCode ASC", date_Today, date_Today];
    
    NSInteger breakfastCalories = 0;
    NSInteger snack1Calories = 0;
    NSInteger lunchCalories = 0;
    NSInteger snack2Calories = 0;
    NSInteger dinnerCalories = 0;
    NSInteger snack3Calories = 0;
    
    self.actualCarbCalories = 0.0;
    self.actualFatCalories = 0.0;
    self.actualProteinCalories = 0.0;

    FMResultSet *rs = [db executeQuery:query];
    while ([rs next]) {
        NSInteger mealID = [rs intForColumn:@"MealCode"];
        double calories = [rs doubleForColumn:@"NumberOfServings"] * (([rs doubleForColumn:@"Calories"] * ([rs doubleForColumn:@"GramWeight"] / 100)) / [rs doubleForColumn:@"ServingSize"]);
        
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithInt:[rs intForColumn:@"FoodID"]], @"FoodID",
                              [NSNumber numberWithInt:[rs intForColumn:@"FoodKey"]], @"FoodKey",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"NumberOfServings"]], @"Servings",
                              [rs dateForColumn:@"MealDate"], @"MealDate",
                              [NSNumber numberWithInt:[rs intForColumn:@"MealCode"]], @"MealCode",
                              [rs stringForColumn:@"Name"], @"Name",
                              [NSNumber numberWithInt:[rs intForColumn:@"Calories"]], @"Calories",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Fat"]], @"Fat",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Carbohydrates"]], @"Carbohydrates",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Protein"]], @"Protein",
                              [NSNumber numberWithInt:[rs intForColumn:@"MeasureID"]], @"MeasureID",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"GramWeight"]], @"GramWeight",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"ServingSize"]], @"ServingSize",
                              
                              [NSNumber numberWithInt:[rs intForColumn:@"MealID"]], @"FoodLogMealID",
                              [NSNumber numberWithInt:calories], @"TotalCalories",
                              [NSNumber numberWithInt:[rs intForColumn:@"RecipeID"]], @"RecipeID",
                              [rs stringForColumn:@"FoodURL"], @"FoodURL",
                              [NSNumber numberWithInt:[rs intForColumn:@"CategoryID"]], @"CategoryID",
                              nil];
        
        double fatGrams = [rs doubleForColumn:@"Fat"];
        self.actualFatCalories += ([rs doubleForColumn:@"NumberOfServings"] * ((fatGrams * 9.0) * ([rs doubleForColumn:@"GramWeight"] / 100) / [rs doubleForColumn:@"ServingSize"]));
        
        double carbGrams = [rs doubleForColumn:@"Carbohydrates"];
        self.actualCarbCalories += ([rs doubleForColumn:@"NumberOfServings"] * ((carbGrams * 4.0) * ([rs doubleForColumn:@"GramWeight"] / 100) / [rs doubleForColumn:@"ServingSize"]));
        
        double proteinGrams = [rs doubleForColumn:@"Protein"];
        self.actualProteinCalories += ([rs doubleForColumn:@"NumberOfServings"] * ((proteinGrams * 4.0) * ([rs doubleForColumn:@"GramWeight"] / 100) / [rs doubleForColumn:@"ServingSize"]));
        
        switch (mealID) {
            case 0:
                [breakfastArray addObject:dict];
                breakfastCalories += calories;
                break;
            case 1:
                [snack1Array addObject:dict];
                snack1Calories += calories;
                break;
            case 2:
                [lunchArray addObject:dict];
                lunchCalories += calories;
                break;
            case 3:
                [snack2Array addObject:dict];
                snack2Calories += calories;
                break;
            case 4:
                [dinnerArray addObject:dict];
                dinnerCalories += calories;
                break;
            case 5:
                [snack3Array addObject:dict];
                snack3Calories += calories;
                break;
        }
    }
    [rs close];
    
    // Add the values to the food dictionary.
    NSDictionary *breakfastDict = @{ @"Calories" : @(breakfastCalories), @"Foods" : breakfastArray };
    NSDictionary *snack1Dict = @{ @"Calories" : @(snack1Calories), @"Foods" : snack1Array };
    NSDictionary *lunchDict = @{ @"Calories" : @(lunchCalories), @"Foods" : lunchArray };
    NSDictionary *snack2Dict = @{ @"Calories" : @(snack2Calories), @"Foods" : snack2Array };
    NSDictionary *dinnerDict = @{ @"Calories" : @(dinnerCalories), @"Foods" : dinnerArray };
    NSDictionary *snack3Dict = @{ @"Calories" : @(snack3Calories), @"Foods" : snack3Array };

    self.sectionFoodsDict[@"Breakfast"] = breakfastDict;
    self.sectionFoodsDict[@"Snack 1"] = snack1Dict;
    self.sectionFoodsDict[@"Lunch"] = lunchDict;
    self.sectionFoodsDict[@"Snack 2"] = snack2Dict;
    self.sectionFoodsDict[@"Dinner"] = dinnerDict;
    self.sectionFoodsDict[@"Snack 3"] = snack3Dict;

    [self.tableView reloadData];
    [self updateCalorieTotal];
    [self loadExerciseData:date];
}

- (void)readData {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    interval.day = 1;
    
    NSDateComponents *anchorComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                                     fromDate:[NSDate date]];
    anchorComponents.hour = 0;
    NSDate *anchorDate = [calendar dateFromComponents:anchorComponents];
    HKQuantityType *quantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    // Create the query
    HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType
                                                                           quantitySamplePredicate:nil
                                                                                           options:HKStatisticsOptionCumulativeSum
                                                                                        anchorDate:anchorDate
                                                                                intervalComponents:interval];
    
    query.initialResultsHandler = ^(HKStatisticsCollectionQuery* query, HKStatisticsCollection* results, NSError *error) {
        if (error) {
            // Perform proper error handling here
            DMLog(@"** An error occurred while calculating the statistics: %@ **",error.localizedDescription);
        }
        
        NSDate *startDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:0 toDate:self.date_currentDate options:0];
        [results enumerateStatisticsFromDate:startDate toDate:self.date_currentDate withBlock:^(HKStatistics * _Nonnull result, BOOL * _Nonnull stop) {
            HKQuantity *quantity = result.sumQuantity;
            if (quantity) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    int stepCount = [quantity doubleValueForUnit:[HKUnit countUnit]];
                    [self saveStepCount:stepCount];
                    
                    double caloriesBurned = [self.stepData stepsToCaloriesForSteps:stepCount];
                    [self addCaloriesForHealthKit:caloriesBurned];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self loadExerciseData:self.date_currentDate];
                });
            }
        }];
    };
    
    [self.healthStore executeQuery:query];
}

- (void)saveStepCount:(int)stepCount {
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }
    
    int minutesExercised = 0;
    
    int exerciseIDTemp = 274;
    minutesExercised = stepCount;
    
    [db beginTransaction];
    
    NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
    NSDateFormatter *outdateformatter = [[NSDateFormatter alloc] init];
    [outdateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [outdateformatter setTimeZone:systemTimeZone];
    NSString *logTimeString = [outdateformatter stringFromDate:self.date_currentDate];
    
    NSDateFormatter *keydateformatter = [[NSDateFormatter alloc] init];
    [keydateformatter setDateFormat:@"yyyyMMdd"];
    [keydateformatter setTimeZone:systemTimeZone];
    NSString *keyDate = [keydateformatter stringFromDate:self.date_currentDate];
    
    int exerciseID = exerciseIDTemp;
    NSString *exerciseLogStrID = [NSString stringWithFormat:@"%@-%i", keyDate, exerciseID];
    
    int minIDvalue = 0;
    NSString *idQuery = @"SELECT MIN(Exercise_Log_ID) as Exercise_Log_ID FROM Exercise_Log";
    FMResultSet *rsID = [db executeQuery:idQuery];
    while ([rsID next]) {
        minIDvalue = [rsID intForColumn:@"Exercise_Log_ID"];
    }
    [rsID close];
    minIDvalue = minIDvalue - 1;
    if (minIDvalue >=0) {
        int maxValue = minIDvalue;
        for (int i=0; i<=maxValue; i++) {
            if (minIDvalue < 0){
                break;
            }
            minIDvalue--;
        }
    }
    
    NSDate* sourceDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:systemTimeZone];
    NSString *date_string = [dateFormatter stringFromDate:sourceDate];
    
    NSString *insertQuery = [[NSString alloc] initWithFormat:@"REPLACE INTO Exercise_Log "
                             "(Exercise_Log_ID, Exercise_Log_StrID, ExerciseID, Exercise_Time_Minutes, Date_Modified, Log_Date)"
                             "VALUES (%i, '%@', %i, %i, '%@', '%@')",
                             minIDvalue,
                             exerciseLogStrID,
                             exerciseID,
                             minutesExercised,
                             date_string,
                             logTimeString];
    
    [db executeUpdate:insertQuery];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
}

- (void)addCaloriesForHealthKit:(double)caloriesBurned {
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }
        
    [db beginTransaction];
    
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
    [self.dateFormatter setTimeZone:systemTimeZone];
    NSString *logTimeString = [self.dateFormatter stringFromDate:self.date_currentDate];
    
    [self.dateFormatter setDateFormat:@"yyyyMMdd"];
    [self.dateFormatter setTimeZone:systemTimeZone];
    NSString *keyDate = [self.dateFormatter stringFromDate:self.date_currentDate];
    
    int exerciseID = 272;
    NSString *exerciseLogStrID = [NSString stringWithFormat:@"%@-%i", keyDate, exerciseID];
    
    int minIDvalue = 0;
    NSString *idQuery = @"SELECT MIN(Exercise_Log_ID) as Exercise_Log_ID FROM Exercise_Log";
    FMResultSet *rsID = [db executeQuery:idQuery];
    while ([rsID next]) {
        minIDvalue = [rsID intForColumn:@"Exercise_Log_ID"];
    }
    [rsID close];
    minIDvalue = minIDvalue - 1;
    if (minIDvalue >=0) {
        int maxValue = minIDvalue;
        for (int i=0; i<=maxValue; i++) {
            if (minIDvalue < 0){
                break;
            }
            minIDvalue--;
        }
    }
    
    NSDate* sourceDate = [NSDate date];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [self.dateFormatter setTimeZone:systemTimeZone];
    NSString *date_string = [self.dateFormatter stringFromDate:sourceDate];
    
    NSString *insertQuery = [[NSString alloc] initWithFormat:@"REPLACE INTO Exercise_Log "
                             "(Exercise_Log_ID, Exercise_Log_StrID, ExerciseID, Exercise_Time_Minutes, Date_Modified, Log_Date) "
                             "VALUES (%i, '%@', %i, %i, '%@', '%@')",
                             minIDvalue,
                             exerciseLogStrID,
                             exerciseID,
                             (int)caloriesBurned,
                             date_string,
                             logTimeString];
    [db executeUpdate:insertQuery];
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
    
    [self loadExerciseData:self.date_currentDate];
}

- (IBAction)goToSafetyGuidelines:(id)sender {
    SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://advancedwebservicegroup.com/AWSGDocuments/GuidelinesAndSafety.html"]];
    [self presentViewController:sfvc animated:YES completion:nil];
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [self dismissViewControllerAnimated:true completion:nil];
}
    
@end

