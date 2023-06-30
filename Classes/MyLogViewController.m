//
//  MyLogViewController.m
//  DietMasterGo
//
//  Created by Andrew Moffitt on 11/23/10.
//  Copyright 2010 AE Studios. All rights reserved.
//

@import SafariServices;
#import "MyLogViewController.h"
#import "MyMovesViewController.h"
#import "DetailViewController.h"
#import "ExercisesDetailViewController.h"
#import "Log_Add.h"
#import "ExercisesViewController.h"
#import "FoodsHome.h"
#import "MyLogTableViewCell.h"

#define DETAIL_VIEW_TAG 883344
#define CALORIE_BAR_HEIGHT 185
#define CALORIE_BAR_CLOSED_HEIGHT 68

#import <HealthKit/HealthKit.h>
#import "StepData.h"

@interface MyLogViewController ()<SFSafariViewControllerDelegate>
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) LogDaySummary *logDaySummary;
@property (nonatomic) double stepCount;
@property (nonatomic) double calories;
@end

static NSString *CellIdentifier = @"MyLogTableViewCell";

@implementation MyLogViewController

@synthesize primaryKey, date_currentDate, int_mealID, date_currentDate1;

#pragma mark VIEW LIFECYCLE

- (instancetype)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
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
        
    lbl_dateHdr.textColor = AccentFontColor
    
    lbl_CaloriesRecommended.textColor = PrimaryFontColor;
    lbl_CaloriesLogged.textColor = PrimaryFontColor;
    recCarbLabel.textColor = PrimaryFontColor
    actualCarbLabel.textColor = PrimaryFontColor
    actualFatLabel.textColor = PrimaryFontColor
    recFatLabel.textColor = PrimaryFontColor
    actualProtLabel.textColor = PrimaryFontColor
    recProtLabel.textColor = PrimaryFontColor
    
    _staticRecommendedLbl.textColor = PrimaryFontColor;
    _staticRemainingLbl.textColor = PrimaryFontColor;
    _staticRecCarbLbl.textColor = PrimaryFontColor
    _staticActualCarbLbl.textColor = PrimaryFontColor
    _staticActualProtLbl.textColor = PrimaryFontColor
    _staticRecFatLbl.textColor = PrimaryFontColor
    _staticActualFatLbl.textColor = PrimaryFontColor
    _staticRecProtLbl.textColor = PrimaryFontColor
    
    _imgbottom.backgroundColor=PrimaryColor
    _imgbottomline.backgroundColor=RGB(255, 255, 255, 0.5);
    self.tableView.backgroundColor = UIColorFromHex(0xF3F3F3);
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    UINib *nib = [UINib nibWithNibName:@"MyLogTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];

    dateToolBar.backgroundColor=AccentColor;
    dateToolBar.barTintColor = AccentColor;
    
    self.view.backgroundColor = PrimaryColor;

    selectSectionArray = [[NSMutableArray alloc]init];
    
    //HHT apple watch
    _arrData = [NSMutableArray new];
    _healthStore = [[HKHealthStore alloc] init];
    _sd = [[StepData alloc]init];
    
    if (!self.date_currentDate) {
        NSDate *sourceDate = [NSDate date];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
        [self.dateFormatter setTimeZone:systemTimeZone];
        NSString *date_string = [self.dateFormatter stringFromDate:sourceDate];
        NSDate *destinationDate = [self.dateFormatter dateFromString:date_string];
        self.date_currentDate = destinationDate;
    }
    
    if(self.int_mealID == NULL) {
        self.int_mealID = 0;
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
    
    exerciseResults = [[NSMutableArray alloc] init];
    foodResults = [[NSMutableArray alloc] init];
    
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
    
    UISwipeGestureRecognizer *swipe_Recognizer_Next2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe_Action:)];
    [swipe_Recognizer_Next2 setDelegate:self];
    [swipe_Recognizer_Next2 setDirection:UISwipeGestureRecognizerDirectionRight];
    [dateToolBar addGestureRecognizer:swipe_Recognizer_Next2];
    
    UISwipeGestureRecognizer *swipe_Recognizer_Previous2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe_Action:)];
    [swipe_Recognizer_Previous2 setDelegate:self];
    [swipe_Recognizer_Previous2 setDirection:UISwipeGestureRecognizerDirectionLeft];
    [dateToolBar addGestureRecognizer:swipe_Recognizer_Previous2];
    
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
    [self.logDaySummary.bottomAnchor constraintEqualToAnchor:layoutGuide.bottomAnchor constant:0].active = YES;
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:0].active = YES;
    [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:0].active = YES;
    [self.tableView.topAnchor constraintEqualToAnchor:dateToolBar.bottomAnchor constant:0].active = YES;
    [self.tableView.bottomAnchor constraintEqualToAnchor:self.logDaySummary.topAnchor constant:0].active = YES;
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"My Log";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController) {
        [[self navigationController] setNavigationBarHidden:YES animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self updateCalorieTotal];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    dietmasterEngine.dateSelected = self.date_currentDate;
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
    if ([exerciseResults count] > 0) {
        return [foodResults count] + 1;
    }
    else {
        return [foodResults count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle;
    NSString *calorieCount;

    DayDataProvider* dayProvider = [DayDataProvider sharedInstance];
    double exerciseCalories = [dayProvider getCaloriesBurnedViaExerciseWithDate:self.date_currentDate];

    BOOL okForFavorite = NO;
    int selectedMealID = 0;
        
    if ([exerciseResults count] > 0 && ((section > [foodResults count]-1) || ([foodResults count] == 0 && [exerciseResults count] > 0))) {
        if (!isExerciseData) {
            sectionTitle = @"Exercise";
            calorieCount = [NSString stringWithFormat:@"-0 Calories"];
        } else {
            sectionTitle = @"Exercise";
            calorieCount = [NSString stringWithFormat:@"-%.0f Calories", exerciseCalories];
        }
    } else {
        okForFavorite = YES;
        
        NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[[foodResults objectAtIndex:section] objectAtIndex:0]];
        
        if ([dict objectForKey:@"MealCode"]) {
            
            selectedMealID = [[dict valueForKey:@"MealCode"] intValue];
            
            if(selectedMealID == 0) {
                sectionTitle = @"Breakfast";
                calorieCount = [NSString stringWithFormat:@"%i Calories", breakfastCalories];
            }
            else if(selectedMealID == 1) {
                sectionTitle = @"Snack 1";
                calorieCount = [NSString stringWithFormat:@"%i Calories", snack1Calories];
            }
            else if(selectedMealID == 2) {
                sectionTitle = @"Lunch";
                calorieCount = [NSString stringWithFormat:@"%i Calories", lunchCalories];
            }
            else if(selectedMealID == 3) {
                sectionTitle = @"Snack 2";
                calorieCount = [NSString stringWithFormat:@"%i Calories", snack2Calories];
            }
            else if(selectedMealID == 4) {
                sectionTitle = @"Dinner";
                calorieCount = [NSString stringWithFormat:@"%i Calories", dinnerCalories];
            }
            else if(selectedMealID == 5) {
                sectionTitle = @"Snack 3";
                calorieCount = [NSString stringWithFormat:@"%i Calories", snack3Calories];
            }
            else {
                sectionTitle = @"NONE";
                calorieCount = @" ";
            }
        } else {
            sectionTitle = [NSString stringWithFormat:@"%@",[[[foodResults objectAtIndex:section] objectAtIndex:0] valueForKey:@"Testing1"]];
            calorieCount = @"0.0";
        }
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
    favoriteButton.hidden = YES;
    [headerView addSubview:favoriteButton];
    if (okForFavorite) {
        favoriteButton.hidden = NO;
    }
    
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
    NSArray *exerciseResultsArray = [exerciseResults copy];
    NSArray *foodResultsArray = [foodResults copy];

    if ([exerciseResultsArray count] > 0 && ((section > [foodResultsArray count]-1) || ([foodResultsArray count] == 0 && [exerciseResultsArray count] > 0))) {
        if ([[exerciseResultsArray objectAtIndex:0] isKindOfClass:[NSDictionary class]]) {
            if ([exerciseResultsArray objectAtIndex:0][@"Testing1"]) {
                NSDictionary *tmpDICT = [[NSDictionary alloc] initWithDictionary:[[exerciseResultsArray objectAtIndex:0] objectAtIndex:0]];
                if ([tmpDICT objectForKey:@"Testing1"])
                {
                    return 0;
                }
            }
        }
        else if ([[exerciseResultsArray objectAtIndex:0] isKindOfClass:[NSArray class]]) {
            return 0;
        }
        return [exerciseResultsArray count];
    } else {
        NSDictionary *tmpDICT = [[NSDictionary alloc] initWithDictionary:[[foodResultsArray objectAtIndex:section] objectAtIndex:0]];
        
        if ([tmpDICT objectForKey:@"Testing1"]) {
            return 0;
        }
        
        return [[foodResultsArray objectAtIndex:section] count];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *exerciseResultsArray = [exerciseResults copy];
    NSArray *foodResultsArray = [foodResults copy];
    if ((indexPath.section > [foodResultsArray count]-1) || ([foodResultsArray count] == 0 && [exerciseResultsArray count] > 0)) {
        return indexPath;
    }
    else {
        return indexPath;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DayDataProvider *dayProvider = [DayDataProvider sharedInstance];
    double currentUserWeight = [dayProvider getCurrentWeight].doubleValue;
    NSArray *exerciseResultsArray = [exerciseResults copy];
    NSArray *foodResultsArray = [foodResults copy];

    MyLogTableViewCell *cell = (MyLogTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *foodNameText = nil;
    NSString *calorieText = nil;
    
    if ((indexPath.section > [foodResultsArray count]-1) || ([foodResultsArray count] == 0 && [exerciseResultsArray count] > 0)) {
        if (isExerciseData) {
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
        }
        else {
            foodNameText = nil;
            calorieText = nil;
        }
    } else {
        NSDictionary *dict = foodResultsArray[indexPath.section][indexPath.row];
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
    NSArray *exerciseResultsArray = [exerciseResults copy];
    NSArray *foodResultsArray = [foodResults copy];
    
    [self.dateFormatter setDateFormat:@"MMMM d, yyyy"];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if ((indexPath.section > [foodResultsArray count]-1) || ([foodResultsArray count] == 0 && [exerciseResultsArray count] > 0)) {
        
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[exerciseResultsArray objectAtIndex:indexPath.row]];
        [dietmasterEngine.exerciseSelectedDict setDictionary:dict];
        dietmasterEngine.taskMode = @"Edit";
        dietmasterEngine.isMealPlanItem = NO;
        
        int mealCode = [[dict valueForKey:@"MealCode"] intValue];
        dietmasterEngine.selectedMealID = [NSNumber numberWithInt:mealCode];
        ExercisesDetailViewController *eDVController = [[ExercisesDetailViewController alloc] init];
        [self.navigationController pushViewController:eDVController animated:YES];
    }
    else {
        NSDictionary *foodDict = [[foodResults objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        DetailViewController *dvController = [[DetailViewController alloc] initWithFood:foodDict];
        
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        dietmasterEngine.taskMode = @"Edit";
        dietmasterEngine.isMealPlanItem = NO;
        dietmasterEngine.dateSelected = date_currentDate;
        int mealCode = [[foodDict valueForKey:@"MealCode"] intValue];
        
        dietmasterEngine.selectedMealID = [NSNumber numberWithInt:mealCode];
        dvController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:dvController animated:YES];
    }
}

#pragma mark - TTTAttributedLabel Delegate

- (void)attributedLabel:(__unused TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

-(IBAction)shownextDate:(id)sender {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    NSCalendar *cal = [NSCalendar currentCalendar];
    [components setDay:+1];
    NSDate *date_Tomorrow = [cal dateByAddingComponents:components toDate:self.date_currentDate options:0];
    
    self.date_currentDate = date_Tomorrow;
    
    //HHT temp (IMP line)
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    dietmasterEngine.dateSelected = date_Tomorrow;
    
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

/// Shows the food list or exercise list to user, so they can select
/// a food or exercise for that time of day selected.
- (IBAction)logFoodOrExercise:(id)sender {
    NSArray *foodResultsArray = [foodResults copy];
    NSArray *sectionArray = [selectSectionArray copy];
    
    UIButton *button = (UIButton *)sender;
    NSInteger section = button.tag;
    
    if (foodResultsArray.count <= section && sectionArray.count <= section) {
        return; // Array not updated yet, return or we'll crash w/ index out of bounds.
    }

    NSString *MealsName;
    if (foodResultsArray.count == 0) {
        MealsName = [foodResultsArray objectAtIndex:section];
    } else {
        MealsName = [sectionArray objectAtIndex:section];
    }
    
    if ([MealsName isEqualToString:@"Breakfast"]) {
        int_mealID = [NSNumber numberWithInt:0];
    }
    else if ([MealsName isEqualToString:@"Snack 1"]) {
        int_mealID = [NSNumber numberWithInt:1];
    }
    else if ([MealsName isEqualToString:@"Lunch"]) {
        int_mealID = [NSNumber numberWithInt:2];
    }
    else if ([MealsName isEqualToString:@"Snack 2"]) {
        int_mealID = [NSNumber numberWithInt:3];
    }
    else if ([MealsName isEqualToString:@"Dinner"]) {
        int_mealID = [NSNumber numberWithInt:4];
    }
    else if ([MealsName isEqualToString:@"Snack 3"]) {
        int_mealID = [NSNumber numberWithInt:5];
    }
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    dietmasterEngine.isMealPlanItem = NO;
    
    if (section == 0) {
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        dietmasterEngine.selectedMealID = int_mealID;
        
        dietmasterEngine.taskMode = @"Save";

        FoodsSearch *fhController1 = [[FoodsSearch alloc] init];
        fhController1.date_currentDate    = date_currentDate;
        fhController1.title = MealsName;
        [self.navigationController pushViewController:fhController1 animated:YES];
        
    }
    else if (section == 1) {
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        dietmasterEngine.selectedMealID = int_mealID;
        dietmasterEngine.taskMode = @"Save";
        FoodsSearch *fhController1 = [[FoodsSearch alloc] init];
        fhController1.date_currentDate = date_currentDate;
        fhController1.title = MealsName;
        [self.navigationController pushViewController:fhController1 animated:YES];
        
    }
    else if (section == 2) {
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        dietmasterEngine.selectedMealID = int_mealID;
        dietmasterEngine.taskMode = @"Save";

        
        FoodsSearch *fhController1 = [[FoodsSearch alloc] init];
        fhController1.date_currentDate    = date_currentDate;
        fhController1.title = MealsName;
        [self.navigationController pushViewController:fhController1 animated:YES];
        
    }
    else if (section == 3) {
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        dietmasterEngine.selectedMealID = int_mealID;
        dietmasterEngine.taskMode = @"Save";

        FoodsSearch *fhController1 = [[FoodsSearch alloc] init];
        fhController1.date_currentDate    = date_currentDate;
        fhController1.title = MealsName;
        [self.navigationController pushViewController:fhController1 animated:YES];
        
    }
    else if (section == 4) {
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        dietmasterEngine.selectedMealID = int_mealID;
        dietmasterEngine.taskMode = @"Save";

        FoodsSearch *fhController1 = [[FoodsSearch alloc] init];
        fhController1.date_currentDate    = date_currentDate;
        fhController1.title = MealsName;
        [self.navigationController pushViewController:fhController1 animated:YES];
        
    }
    else if (section == 5) {
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        dietmasterEngine.selectedMealID = int_mealID;
        dietmasterEngine.taskMode = @"Save";

        FoodsSearch *fhController1 = [[FoodsSearch alloc] init];
        fhController1.date_currentDate    = date_currentDate;
        fhController1.title = MealsName;
        [self.navigationController pushViewController:fhController1 animated:YES];
        
    }
    else if (section == 6) {
        ExercisesViewController *exercisesViewController = [[ExercisesViewController alloc] init];
        [self.navigationController pushViewController:exercisesViewController animated:YES];
    }
    else {
        Log_Add *dvController = [[Log_Add alloc] init];
        dvController.date_currentDate = date_currentDate;
        [self.navigationController pushViewController:dvController animated:YES];
    }
}

-(IBAction)showprevDate:(id)sender {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    NSCalendar *cal = [NSCalendar currentCalendar];
    [components setDay:-1];
    NSDate *date_Yesterday = [cal dateByAddingComponents:components toDate:self.date_currentDate options:0];
    
    self.date_currentDate = date_Yesterday;
    
    //HHT temp (IMP line)
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    dietmasterEngine.dateSelected = date_Yesterday;
    
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
    
    [self updateData:date_Yesterday];
}

#pragma mark SAVE FAVORITE MEAL METHODS
-(IBAction)saveFavoriteMeal:(id)sender {
    favoriteMealName = @"";
    favoriteMealSectionID = [sender tag];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Save as Favorite Meal"
                                                                   message:@"Enter short name or description."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        // Configure.
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"Save"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        favoriteMealName = alert.textFields.firstObject.text;
        if ([favoriteMealName length] == 0) {
            [DMGUtilities showAlertWithTitle:@"Error" message:@"Favorite Meal Name is required. Please try again." inViewController:nil];
        } else {
            [self saveFavoriteMealToDatabase:nil];
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
        favoriteMealName = @"";
        favoriteMealSectionID = 0;
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

// Save Fav Meal
- (void)saveFavoriteMealToDatabase:(id)sender {
    
    [DMActivityIndicator showActivityIndicator];

    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
        
    }
    
    int minIDvalue = 0;
    NSString *idQuery = @"SELECT min(Favorite_MealID) as Favorite_MealID FROM Favorite_Meal";
    FMResultSet *rsID = [db executeQuery:idQuery];
    while ([rsID next]) {
        minIDvalue = [rsID intForColumn:@"Favorite_MealID"];
    }
    [rsID close];
    minIDvalue = minIDvalue - 1;
    if (minIDvalue >=0) {
        int maxValue = minIDvalue;
        for (int i=0; i<maxValue; i++) {
            if (minIDvalue < 0){
                break;
            }
            minIDvalue--;
        }
    }
    
    [db beginTransaction];
    
    NSDate* sourceDate = [NSDate date];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
    [self.dateFormatter setTimeZone:systemTimeZone];
    NSString *date_string = [self.dateFormatter stringFromDate:sourceDate];
    
    NSString *insertSQL = [NSString stringWithFormat: @"REPLACE INTO Favorite_Meal (Favorite_MealID, Favorite_Meal_Name, modified) VALUES (%i, '%@',DATETIME('%@'))", minIDvalue, favoriteMealName, date_string];
    
    
    [db executeUpdate:insertSQL];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
    
    int favoriteMealID = (int)[db lastInsertRowId];
    
    for (NSDictionary *dict in [foodResults objectAtIndex:favoriteMealSectionID]) {
        
        
        [db beginTransaction];
        
        NSDate* sourceDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
        [dateFormatter setTimeZone:systemTimeZone];
        NSString *date_string = [dateFormatter stringFromDate:sourceDate];
        
        NSString *insertSQLItems = [NSString stringWithFormat: @"REPLACE INTO Favorite_Meal_Items (FoodKey, Favorite_Meal_ID, FoodID, MeasureID, Servings, Last_Modified) VALUES (%i, %i, %i, %i, %f, DATETIME('%@'))", [[dict valueForKey:@"FoodKey"] intValue], favoriteMealID, [[dict valueForKey:@"FoodID"] intValue], [[dict valueForKey:@"MeasureID"] intValue], [[dict valueForKey:@"Servings"] floatValue], date_string];
        
        
        [db executeUpdate:insertSQLItems];
        
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        
        [db commit];
    }
    
    [DMActivityIndicator hideActivityIndicator];
    [DMActivityIndicator showCompletedIndicator];

    favoriteMealID = 0;
}

#pragma mark DATA METHODS

- (void)updateCalorieTotal {
    DayDataProvider* dayProvider = [DayDataProvider sharedInstance];
    double caloriesRemaining = [dayProvider getTotalCaloriesRemainingWithDate:self.date_currentDate].doubleValue;

    lbl_CaloriesLogged.text = [NSString stringWithFormat:@"%.0f",caloriesRemaining];

    CGFloat carbRatioActual = actualCarbCalories / 4;
    CGFloat proteinRatioActual = actualProteinCalories / 4;
    CGFloat fatRatioActual = actualFatCalories / 9;
    
    actualCarbLabel.text = [NSString stringWithFormat:@"%.1fg",carbRatioActual];
    actualProtLabel.text = [NSString stringWithFormat:@"%.1fg",proteinRatioActual];
    actualFatLabel.text = [NSString stringWithFormat:@"%.1fg",fatRatioActual];
    
    CGFloat carbRatioRecommended = [dayProvider getRecommendedCarbRatio].floatValue;
    CGFloat proteinRatioRecommended = [dayProvider getRecommendedProteinRatio].floatValue;
    CGFloat fatRatioRecommended = [dayProvider getRecommendedFatRatio].floatValue;
    
    recCarbLabel.text = [NSString stringWithFormat:@"%.1fg",carbRatioRecommended];
    recProtLabel.text = [NSString stringWithFormat:@"%.1fg",proteinRatioRecommended];
    recFatLabel.text = [NSString stringWithFormat:@"%.1fg",fatRatioRecommended];
    
    NSString *caloriesRecommended = [NSString stringWithFormat:@"%li", [dayProvider getCurrentBMR].integerValue];
    NSString *remainingCalories = [NSString stringWithFormat:@"%.0f", caloriesRemaining];
    [self.logDaySummary setRemainingLabelsWithCalorie:remainingCalories carbs:actualCarbLabel.text protein:actualProtLabel.text fat:actualFatLabel.text];
    [self.logDaySummary setRecommendedLabelsWithCalorie:caloriesRecommended carbs:recCarbLabel.text protein:recProtLabel.text fat:recFatLabel.text];
}

- (void)updateBMRLabel {
    DayDataProvider *dayProvider = [DayDataProvider sharedInstance];
    int bmrCalories = [dayProvider getCurrentBMR].intValue;
    int remainingCalories = [dayProvider getTotalCaloriesRemainingWithDate:self.date_currentDate].intValue;
    
    lbl_CaloriesRecommended.text = [NSString stringWithFormat:@"%i", (int)bmrCalories];
    lbl_CaloriesLogged.text = [NSString stringWithFormat:@"%i", remainingCalories];
}

- (void)loadExerciseData:(NSDate *)date {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    [exerciseResults removeAllObjects];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
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
        [exerciseResults addObject:dict];
        
        if (exerciseResults.count > 0) {
            isExerciseData = YES;
            if (![selectSectionArray containsObject:@"Exercise"]) {
                [selectSectionArray addObject:@"Exercise"];
            }
        } else {
            isExerciseData = NO;
            [selectSectionArray addObject:@"Exercise"];
            NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
            [tmpDict setObject:@"Exercise" forKey:@"Testing1"];
            [exerciseResults addObject:[NSMutableArray arrayWithObject:tmpDict]];
        }
    }
    
    [rs close];
    [self.tableView reloadData];
    [self updateCalorieTotal];
}

- (void)reloadData {
    NSDate* sourceDate = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
    [dateFormat setTimeZone:systemTimeZone];
    NSString *date_string = [dateFormat stringFromDate:sourceDate];
    NSDate *date_Now = [dateFormat dateFromString:date_string];
    
    [self updateData:date_Now];
}

- (void)updateData:(NSDate *)date {
    if (foodResults) {
        [foodResults removeAllObjects];
        [selectSectionArray removeAllObjects];
    }
    
    NSMutableArray *breakfastArray1 = [[NSMutableArray alloc] init];
    NSMutableArray *snack1Array2 = [[NSMutableArray alloc] init];
    NSMutableArray *lunchArray3 = [[NSMutableArray alloc] init];
    NSMutableArray *snack2Array4 = [[NSMutableArray alloc] init];
    NSMutableArray *dinnerArray5 = [[NSMutableArray alloc] init];
    NSMutableArray *snack3Array6 = [[NSMutableArray alloc] init];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    
    NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [self.dateFormatter setTimeZone:systemTimeZone];
    NSString *date_Today = [self.dateFormatter stringFromDate:date];

    [self.dateFormatter setDateStyle:NSDateFormatterLongStyle];
    NSString *date_Display = [self.dateFormatter stringFromDate:date];
    
    lbl_dateHdr.text = date_Display;
    self.date_currentDate = date;
    
    dietmasterEngine.dateSelected = date;
    dietmasterEngine.dateSelectedFormatted = date_Display;
        
    NSString *query = [NSString stringWithFormat: @"SELECT Food_Log.MealID, Food_Log.MealDate, Food_Log_Items.MealCode, Food_Log_Items.FoodID, Food_Log_Items.MeasureID, Food_Log_Items.NumberOfServings, Food.FoodKey, Food.Name, Food.Calories, Food.Fat, Food.Carbohydrates, Food.Protein, FoodMeasure.GramWeight, Food.ServingSize, Food.CategoryID, Food.RecipeID, Food.FoodURL, count(1) FROM Food_Log INNER JOIN Food_Log_Items ON Food_Log.MealID = Food_Log_Items.MealID INNER JOIN Food ON Food.FoodKey = Food_Log_Items.FoodID INNER JOIN FoodMeasure ON FoodMeasure.FoodID = Food.FoodKey WHERE (Food_Log.MealDate BETWEEN DATETIME('%@ 00:00:00') AND DATETIME('%@ 23:59:59')) AND Food_Log_Items.MeasureID = FoodMeasure.MeasureID group by Food_Log.MealID, Food_Log.MealDate, Food_Log_Items.MealCode, Food_Log_Items.FoodID, Food_Log_Items.MeasureID, Food.FoodKey ORDER BY Food_Log_Items.MealCode ASC", date_Today, date_Today];
        
    breakfastCalories = 0;
    snack1Calories = 0;
    lunchCalories = 0;
    snack2Calories = 0;
    dinnerCalories = 0;
    snack3Calories = 0;
    
    actualCarbCalories = 0.0;
    actualFatCalories = 0.0;
    actualProteinCalories = 0.0;
    
    FMResultSet *rs = [db executeQuery:query];
    while ([rs next]) {
        
        NSInteger mealID = [rs intForColumn:@"MealCode"];
        
        double totalCalories = [rs doubleForColumn:@"NumberOfServings"] * (([rs doubleForColumn:@"Calories"] * ([rs doubleForColumn:@"GramWeight"] / 100)) / [rs doubleForColumn:@"ServingSize"]);
        
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
                              [NSNumber numberWithInt:totalCalories], @"TotalCalories",
                              [NSNumber numberWithInt:[rs intForColumn:@"RecipeID"]], @"RecipeID",
                              [rs stringForColumn:@"FoodURL"], @"FoodURL",
                              [NSNumber numberWithInt:[rs intForColumn:@"CategoryID"]], @"CategoryID",
                              nil];
        
        double fatGrams = [rs doubleForColumn:@"Fat"];
        actualFatCalories = actualFatCalories + ([rs doubleForColumn:@"NumberOfServings"] * ((fatGrams * 9.0) * ([rs doubleForColumn:@"GramWeight"] / 100) / [rs doubleForColumn:@"ServingSize"]));
        
        double carbGrams = [rs doubleForColumn:@"Carbohydrates"];
        actualCarbCalories = actualCarbCalories + ([rs doubleForColumn:@"NumberOfServings"] * ((carbGrams * 4.0) * ([rs doubleForColumn:@"GramWeight"] / 100) / [rs doubleForColumn:@"ServingSize"]));
        
        double proteinGrams = [rs doubleForColumn:@"Protein"];
        actualProteinCalories = actualProteinCalories + ([rs doubleForColumn:@"NumberOfServings"] * ((proteinGrams * 4.0) * ([rs doubleForColumn:@"GramWeight"] / 100) / [rs doubleForColumn:@"ServingSize"]));
        
        switch (mealID) {
            case 0:
                [breakfastArray1 addObject:dict];
                breakfastCalories = breakfastCalories + totalCalories;
                break;
            case 1:
                [snack1Array2 addObject:dict];
                snack1Calories = snack1Calories + totalCalories;
                break;
            case 2:
                [lunchArray3 addObject:dict];
                lunchCalories = lunchCalories + totalCalories;
                break;
            case 3:
                [snack2Array4 addObject:dict];
                snack2Calories = snack2Calories + totalCalories;
                break;
            case 4:
                [dinnerArray5 addObject:dict];
                dinnerCalories = dinnerCalories + totalCalories;
                break;
            case 5:
                [snack3Array6 addObject:dict];
                snack3Calories = snack3Calories + totalCalories;
                break;
        }
    }
    
    if ([breakfastArray1 count] > 0) {
        [foodResults addObject:breakfastArray1];
        
        if (![selectSectionArray containsObject:@"Breakfast"]) {
            [selectSectionArray addObject:@"Breakfast"];
        }
    }
    
    if (![selectSectionArray containsObject:@"Breakfast"]) {
        [selectSectionArray addObject:@"Breakfast"];
        
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc]init];
        [tmpDict setObject:@"Breakfast" forKey:@"Testing1"];
        [foodResults addObject:[NSMutableArray arrayWithObject:tmpDict]];
    }
    
    if ([snack1Array2 count] > 0) {
        [foodResults addObject:snack1Array2];
        if (![selectSectionArray containsObject:@"Snack 1"]) {
            [selectSectionArray addObject:@"Snack 1"];
        }
    }
    
    if (![selectSectionArray containsObject:@"Snack 1"]) {
        [selectSectionArray addObject:@"Snack 1"];
        
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc]init];
        
        [tmpDict setObject:@"Snack 1" forKey:@"Testing1"];
        
        [foodResults addObject:[NSMutableArray arrayWithObject:tmpDict]];
    }
    
    if ([lunchArray3 count] > 0) {
        [foodResults addObject:lunchArray3];
        
        if (![selectSectionArray containsObject:@"Lunch"]) {
            [selectSectionArray addObject:@"Lunch"];
        }
    }
    
    if (![selectSectionArray containsObject:@"Lunch"]) {
        [selectSectionArray addObject:@"Lunch"];
        
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc]init];
        
        [tmpDict setObject:@"Lunch" forKey:@"Testing1"];
        
        [foodResults addObject:[NSMutableArray arrayWithObject:tmpDict]];
    }
    
    if ([snack2Array4 count] > 0) {
        [foodResults addObject:snack2Array4];
        if (![selectSectionArray containsObject:@"Snack 2"]) {
            [selectSectionArray addObject:@"Snack 2"];
        }
    }
    
    if (![selectSectionArray containsObject:@"Snack 2"]) {
        [selectSectionArray addObject:@"Snack 2"];
        
        
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc]init];
        
        [tmpDict setObject:@"Snack 2" forKey:@"Testing1"];
        
        [foodResults addObject:[NSMutableArray arrayWithObject:tmpDict]];
    }
    
    if ([dinnerArray5 count] > 0) {
        [foodResults addObject:dinnerArray5];
        
        if (![selectSectionArray containsObject:@"Dinner"])
        {
            [selectSectionArray addObject:@"Dinner"];
        }
        
    }
    
    if (![selectSectionArray containsObject:@"Dinner"]) {
        [selectSectionArray addObject:@"Dinner"];
        
        
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc]init];
        
        [tmpDict setObject:@"Dinner" forKey:@"Testing1"];
        
        [foodResults addObject:[NSMutableArray arrayWithObject:tmpDict]];
    }
    
    if ([snack3Array6 count] > 0) {
        [foodResults addObject:snack3Array6];
        
        if (![selectSectionArray containsObject:@"Snack 3"]) {
            [selectSectionArray addObject:@"Snack 3"];
        }
    }
    
    if (![selectSectionArray containsObject:@"Snack 3"]) {
        [selectSectionArray addObject:@"Snack 3"];
        
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc]init];
        
        [tmpDict setObject:@"Snack 3" forKey:@"Testing1"];
        
        [foodResults addObject:[NSMutableArray arrayWithObject:tmpDict]];
    }
       
    [rs close];
            
    [self loadExerciseData:date];
    [self updateBMRLabel];
    
    [self.tableView reloadData];
    [self.tableView reloadSectionIndexTitles];
    
    [self updateCalorieTotal];
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
        
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        NSDate *endDate = dietmasterEngine.dateSelected;
        NSDate *startDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:0 toDate:endDate options:0];
        
        [results enumerateStatisticsFromDate:startDate toDate:endDate withBlock:^(HKStatistics * _Nonnull result, BOOL * _Nonnull stop) {
            HKQuantity *quantity = result.sumQuantity;
            if (quantity) {
                //NSDate *date = result.endDate;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.stepCount = [quantity doubleValueForUnit:[HKUnit countUnit]];
                    [self stepCountSave];
                    
                    double caloriesBurned = [self.sd stepsToCalories:self.stepCount];
                    self.calories = caloriesBurned;
                    [self caloriesCount];
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

- (void)stepCountSave {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
        
    }
    
    int minutesExercised = 0;
    
    int exerciseIDTemp = 274;
    minutesExercised = self.stepCount;
    
    [db beginTransaction];
    
    NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
    NSDateFormatter *outdateformatter = [[NSDateFormatter alloc] init];
    [outdateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [outdateformatter setTimeZone:systemTimeZone];
    NSString *logTimeString = [outdateformatter stringFromDate:dietmasterEngine.dateSelected];
    
    
    NSDateFormatter *keydateformatter = [[NSDateFormatter alloc] init];
    [keydateformatter setDateFormat:@"yyyyMMdd"];
    [keydateformatter setTimeZone:systemTimeZone];
    NSString *keyDate = [keydateformatter stringFromDate:dietmasterEngine.dateSelected];
    
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
    
    exerciseLogID = [db lastInsertRowId];
}

//HHT apple watch
- (void)caloriesCount {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
        
    }
    
    int minutesExercised = 0;
    
    int exerciseIDTemp = 272;
    minutesExercised = self.calories;
    
    [db beginTransaction];
    
    NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
    NSDateFormatter *outdateformatter = [[NSDateFormatter alloc] init];
    [outdateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [outdateformatter setTimeZone:systemTimeZone];
    NSString *logTimeString = [outdateformatter stringFromDate:dietmasterEngine.dateSelected];
    
    NSDateFormatter *keydateformatter = [[NSDateFormatter alloc] init];
    [keydateformatter setDateFormat:@"yyyyMMdd"];
    [keydateformatter setTimeZone:systemTimeZone];
    NSString *keyDate = [keydateformatter stringFromDate:dietmasterEngine.dateSelected];
    
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
                             "(Exercise_Log_ID, Exercise_Log_StrID, ExerciseID, Exercise_Time_Minutes, Date_Modified, Log_Date) "
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
    
    [self loadExerciseData:self.date_currentDate];
    exerciseLogID = [db lastInsertRowId];
}

- (IBAction)goToSafetyGuidelines:(id)sender {
    SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://advancedwebservicegroup.com/AWSGDocuments/GuidelinesAndSafety.html"]];
    [self presentViewController:sfvc animated:YES completion:nil];
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [self dismissViewControllerAnimated:true completion:nil];
}
    
@end

