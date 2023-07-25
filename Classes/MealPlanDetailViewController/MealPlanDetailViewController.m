//
//  MealPlanDetailViewController.m
//  DietMasterGo
//
//  Created by Henry Kirk on 6/11/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//
@import SafariServices;
#import "MealPlanDetailViewController.h"
#import "DietmasterEngine.h"
#import "FMDatabase.h"
#import "DetailViewController.h"
#import "Log_Add.h"
#import "MealPlanDetailsTableViewCell.h"
#import "TTTAttributedLabel.h"
#import "DMMealPlanDataProvider.h"
#import "DMMealPlan.h"
#import "DMMealPlanItem.h"

@interface MealPlanDetailViewController() <UITableViewDelegate, UITableViewDataSource, TTTAttributedLabelDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIImageView *imgbar;
@property (nonatomic, strong) IBOutlet UIImageView *imgbarline;
@property (nonatomic, strong) IBOutlet UILabel *staticCalPlannedLbl;
@property (nonatomic, strong) IBOutlet UILabel *staticRecomCalLbl;
@property (nonatomic, strong)  UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *recommendedCaloriesLabel;
@property (nonatomic, strong) IBOutlet UILabel *caloriesPlannedLabel;
@property (nonatomic, strong) IBOutlet UIButton *infoBtn;

/// The meal plan to display.
@property (nonatomic, strong) DMMealPlan *mealPlan;
@end

static NSString *CellIdentifier = @"MealPlanDetailsTableViewCell";

@implementation MealPlanDetailViewController

- (instancetype)initWithMealPlan:(DMMealPlan *)mealPlan {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        _mealPlan = mealPlan;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:DMReloadDataNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.staticRecomCalLbl.textColor = AppConfiguration.footerTextColor;
    self.staticCalPlannedLbl.textColor = AppConfiguration.footerTextColor;

    self.imgbar.backgroundColor = AppConfiguration.footerColor;
    self.imgbar.layer.cornerRadius = 25;
    self.imgbar.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    self.imgbar.clipsToBounds = YES;

    self.imgbarline.backgroundColor = AppConfiguration.footerTextColor;
  
    self.tableView.estimatedRowHeight = 70;
    self.tableView.estimatedSectionHeaderHeight = 44;
    [self.tableView registerNib:[UINib nibWithNibName:CellIdentifier bundle:nil] forCellReuseIdentifier:CellIdentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
          switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
              case 2436:
              case 2688:
              case 1792:
                  //iphone x+
                  self.infoBtn.frame = CGRectMake(10, _imgbar.frame.origin.y + _staticRecomCalLbl.bounds.size.height, 18, 21);

                  break;
              default:
              //for iphone 8
                  self.infoBtn.frame = CGRectMake(10, _imgbar.frame.origin.y - 8, 18, 21);

                  break;
          }

    }

    [self.infoBtn addTarget:self action:@selector(goToSafetyGuidelines:) forControlEvents:UIControlEventTouchUpInside];
    [self.infoBtn setUserInteractionEnabled:YES];
    self.infoBtn.tintColor = AppConfiguration.footerTextColor;
    
    self.title = @"Meal Details";
    [self.navigationItem setTitle:@"Meal Details"];

    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setTranslucent:NO];

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStylePlain
                                   target: nil action: nil];
    backButton.tintColor = AppConfiguration.footerTextColor;
    [self.navigationItem setBackBarButtonItem: backButton];
    
    self.titleLabel.text = self.mealPlan.mealName;
    self.titleLabel.backgroundColor = AppConfiguration.headerColor;
    self.titleLabel.textColor = AppConfiguration.headerTextColor;
   
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                 target:self
                                                                                 action:@selector(showActionSheet:)];
    rightButton.style = UIBarButtonItemStylePlain;
    rightButton.tintColor = AppConfiguration.headerTextColor;
    self.navigationItem.rightBarButtonItem = rightButton;
    
    self.caloriesPlannedLabel.textColor = AppConfiguration.footerTextColor;
    self.recommendedCaloriesLabel.textColor = AppConfiguration.footerTextColor;
    
    [self updateCalorieLabels];
    
    UIImageView *backgroundImage = (UIImageView *)[self.view viewWithTag:501];
    if ([AppConfiguration.accountCode isEqualToString:@"ezdietplanner"]) {
        backgroundImage.image = [UIImage imageNamed:@"My_Plan_Background"];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self updateCalorieLabels];
    [self.tableView reloadData];
}

- (IBAction)goToSafetyGuidelines:(id)sender {
    SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://advancedwebservicegroup.com/AWSGDocuments/GuidelinesAndSafety.html"]];
    [self presentViewController:sfvc animated:YES completion:nil];
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [self dismissViewControllerAnimated:true completion:nil];
}

/// This reloads the meal plan that's being displayed.
- (void)reloadData {
    if ([NSThread isMainThread]) {
        DMMealPlanDataProvider *provider = [[DMMealPlanDataProvider alloc] init];
        [DMActivityIndicator showActivityIndicator];
        [provider fetchUserPlannedMealsWithCompletionBlock:^(NSObject *object, NSError *error) {
            [DMActivityIndicator hideActivityIndicator];
            if (error) {
                [DMGUtilities showAlertWithTitle:@"Error" message:error.localizedDescription inViewController:nil];
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *results = (NSArray *)object;
                for (DMMealPlan *mealPlan in results) {
                    if ([mealPlan.mealId isEqual:self.mealPlan.mealId]) {
                        self.mealPlan = mealPlan;
                        break;
                    }
                }
                [self.tableView reloadData];
                [self updateCalorieLabels];
            });
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData];
        });
    }
}

/// Adds the entire plan to the date selected.
- (void)addEntirePlanToLogOnDate:(NSDate *)date {
    DMMealPlanDataProvider *provider = [[DMMealPlanDataProvider alloc] init];
    for (DMMealPlanItem *item in [[self.mealPlan getAllMealItems] copy]) {
        [provider insertMealPlanItemIntoLog:item toDate:date];
    }
    [DMActivityIndicator showCompletedIndicator];
    [self.navigationController popViewControllerAnimated:YES];
}

/// Adds the meal to log with the code provided.
- (void)addMealToLogWithCode:(DMLogMealCode)mealCode onDate:(NSDate *)date {
    DMMealPlanDataProvider *provider = [[DMMealPlanDataProvider alloc] init];
    NSArray *mealItems = [self.mealPlan getMealItemsForMealCode:mealCode];
    for (DMMealPlanItem *item in mealItems) {
        [provider insertMealPlanItemIntoLog:item toDate:date];
    }
    [DMActivityIndicator showCompletedIndicator];
}

- (void)addItemToMealPlan:(id)sender {
    Log_Add *dvController = [[Log_Add alloc] initWithMealPlan:self.mealPlan selectedDate:[NSDate date]];
    dvController.taskMode = DMTaskModeAddToPlan;
    [self.navigationController pushViewController:dvController animated:YES];
}

#pragma mark SELECT DATE METHODS

/// Action called when user selects to add the meal to a date selected.
/// E.g. Breakfast to 6/26/2023.
- (void)selectMealDate:(UIButton *)sender {
    DMDatePickerViewController *dateController = [[DMDatePickerViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    dateController.didSelectDateCallback = ^(NSDate *date) {
        // The sender.tag is the value of the meal code.
        DMLogMealCode code = (DMLogMealCode)sender.tag;
        [weakSelf confirmAddMealToLogWithMealCode:code onDate:date];
    };
    [dateController presentPickerIn:self];
}

/// Lets the user add a meal plan to the entire day.
- (void)selectAllMealDate:(id)sender {
    DMDatePickerViewController *dateController = [[DMDatePickerViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    dateController.didSelectDateCallback = ^(NSDate *date) {
        [weakSelf confirmAddEntirePlanToLogToDate:date];
    };
    [dateController presentPickerIn:self];
}

#pragma mark WEBSERVICE CALLS

- (void)deleteMealPlanItem:(NSDictionary *)dict {
    if (!dict) {
        return;
    }
    DMMealPlanDataProvider *provider = [[DMMealPlanDataProvider alloc] init];
    __weak typeof(self) weakSelf = self;
    [provider deleteUserPlannedMealItems:@[dict] withCompletionBlock:^(BOOL completed, NSError *error) {
        [weakSelf updateCalorieLabels];
    }];
}

#pragma mark TABLE VIEW METHODS

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (NSInteger)DMLogMealCodeSnackThree;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    view.backgroundColor = UIColorFromHexString(@"#F3F3F3");

    DMMealPlanDataProvider *dataProvider = [[DMMealPlanDataProvider alloc] init];
    NSArray *mealItems = [self.mealPlan getMealItemsForMealCode:section];
    NSString *mealNote = [self.mealPlan getMealNoteForMealCode:section];
    if (mealItems.count) {
        NSNumber *totalCalories = [dataProvider getTotalCaloriesForMealPlanItems:mealItems];
        
        NSString *sectionTitle;
        if(section == 0) {
            sectionTitle = @"Breakfast";
        }
        else if(section == 1) {
            sectionTitle = @"Snack 1";
        }
        else if(section == 2) {
            sectionTitle = @"Lunch";
        }
        else if(section == 3) {
            sectionTitle = @"Snack 2";
        }
        else if(section == 4) {
            sectionTitle = @"Dinner";
        }
        else if(section == 5) {
            sectionTitle = @"Snack 3";
        }
        else {
            sectionTitle = @"NONE";
        }
        
        UILabel *mealLabel = [[UILabel alloc] init];
        mealLabel.translatesAutoresizingMaskIntoConstraints = NO;
        mealLabel.textColor = [UIColor blackColor];
        mealLabel.font = [UIFont boldSystemFontOfSize:17.0];
        mealLabel.text = sectionTitle;
        mealLabel.backgroundColor = [UIColor clearColor];
        
        UILabel *calorieLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        calorieLabel.translatesAutoresizingMaskIntoConstraints = NO;
        calorieLabel.text = [NSString stringWithFormat:@"%.0f Calories", [totalCalories doubleValue]];
        calorieLabel.textColor = [UIColor blackColor];
        calorieLabel.font = [UIFont boldSystemFontOfSize:13.0];
        calorieLabel.backgroundColor = [UIColor clearColor];
        calorieLabel.textAlignment = NSTextAlignmentRight;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button addTarget:self
                   action:@selector(selectMealDate:)
         forControlEvents:UIControlEventTouchUpInside];
        UIImage *myLogImage = [UIImage imageNamed:@"mylog"];
        myLogImage = [myLogImage imageWithTintColor:[UIColor blackColor] renderingMode:UIImageRenderingModeAlwaysTemplate];
        [button setImage:myLogImage forState:UIControlStateNormal];
        button.tag = section;
        button.tintColor = [UIColor blackColor];
        
        UILabel *mealNoteLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        mealNoteLabel.translatesAutoresizingMaskIntoConstraints = NO;
        mealNoteLabel.text = mealNote;
        mealNoteLabel.textColor = [UIColor blackColor];
        mealNoteLabel.font = [UIFont boldSystemFontOfSize:15.0];
        mealNoteLabel.backgroundColor = [UIColor clearColor];
        mealNoteLabel.textAlignment = NSTextAlignmentLeft;
        mealNoteLabel.numberOfLines = 0;

        [view addSubview:mealLabel];
        [view addSubview:calorieLabel];
        [view addSubview:button];
        [view addSubview:mealNoteLabel];
        
        [mealLabel.leadingAnchor constraintEqualToAnchor:view.leadingAnchor constant:12].active = YES;
        [mealLabel.topAnchor constraintEqualToAnchor:view.topAnchor constant:8].active = YES;

        [calorieLabel.leadingAnchor constraintEqualToAnchor:mealLabel.trailingAnchor constant:0].active = YES;
        [calorieLabel.topAnchor constraintEqualToAnchor:mealLabel.topAnchor constant:0].active = YES;
        [calorieLabel.bottomAnchor constraintEqualToAnchor:mealLabel.bottomAnchor constant:0].active = YES;
        [calorieLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        
        [button.leadingAnchor constraintEqualToAnchor:calorieLabel.trailingAnchor constant:12].active = YES;
        [button.widthAnchor constraintEqualToConstant:26].active = YES;
        [button.centerYAnchor constraintEqualToAnchor:mealLabel.centerYAnchor constant:0].active = YES;
        [button.trailingAnchor constraintEqualToAnchor:view.trailingAnchor constant:-12].active = YES;

        [mealNoteLabel.topAnchor constraintEqualToAnchor:mealLabel.bottomAnchor constant:10].active = YES;
        [mealNoteLabel.leadingAnchor constraintEqualToAnchor:view.leadingAnchor constant:12].active = YES;
        [mealNoteLabel.trailingAnchor constraintEqualToAnchor:view.trailingAnchor constant:0].active = YES;
        [mealNoteLabel.bottomAnchor constraintEqualToAnchor:view.bottomAnchor constant:-10].active = YES;
        [mealNoteLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *mealItems = [self.mealPlan getMealItemsForMealCode:section];
    return mealItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MealPlanDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.lblMealName.numberOfLines = 0;
    cell.lblMealName.lineBreakMode = NSLineBreakByWordWrapping;
    
    cell.userInteractionEnabled = NO;
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSArray *mealItems = [self.mealPlan getMealItemsForMealCode:indexPath.section];
    DMMealPlanItem *mealItem = mealItems[indexPath.row];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.lblMealName.font = [UIFont systemFontOfSize:15.0];
    cell.lblServingSize.font = [UIFont systemFontOfSize:13.0];
    cell.lblServingSize.textColor = [UIColor darkGrayColor];
    cell.lblMealName.textColor = [UIColor blackColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.userInteractionEnabled = YES;

    DMMyLogDataProvider *provider = [[DMMyLogDataProvider alloc] init];
    DMFood *food = [provider getFoodForFoodKey:mealItem.foodId];
    NSString *measureDesc = [provider getMeasureDescriptionForMeasureId:mealItem.measureId
                                                             forFoodKey:food.foodKey];
    cell.lblServingSize.text = [NSString stringWithFormat:@"Serving: %.2f - %@",
                                [mealItem.numberOfServings doubleValue], measureDesc];
    NSString *foodName = food.name ?: @"Missing Food: Contact your provider.";
    NSNumber *foodCategory = food.categoryId;
    NSURL *foodNameURL = nil;
    
    if ([foodCategory intValue] == 66) {
        DMUser *currentUser = [[DMAuthManager sharedInstance] loggedInUser];
        NSString *hostname = currentUser.hostName;
        NSNumber *recipeID = food.recipeId;
        if (hostname != nil && ![hostname isEqualToString:@""] && recipeID != nil && [recipeID intValue] > 0) {
            cell.userInteractionEnabled = YES;
            cell.lblMealName.delegate = self;
            NSString *url = [NSString stringWithFormat:@"%@/PDFviewer.aspx?ReportName=CustomRecipe&ID=%@", hostname, recipeID];
            foodNameURL = [NSURL URLWithString:url];
        }
        
    } else {
        NSString *foodURLString = food.foodURL;
        if (foodURLString.length) {
            cell.userInteractionEnabled = YES;
            foodNameURL = [NSURL URLWithString:foodURLString];
        }
    }
    
    cell.lblMealName.text = foodName;

    if (foodNameURL) {
        NSRange range = NSMakeRange(0, foodName.length);
        [cell.lblMealName addLinkToURL:foodNameURL withRange:range];
        cell.lblMealName.delegate = self;
    } else {
        cell.lblMealName.delegate = nil;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *mealItems = [self.mealPlan getMealItemsForMealCode:indexPath.section];
    DMMealPlanItem *mealItem = mealItems[indexPath.row];
            
    DMMyLogDataProvider *provider = [[DMMyLogDataProvider alloc] init];
    DMFood *food = [provider getFoodForFoodKey:mealItem.foodId];

    DetailViewController *dvController = [[DetailViewController alloc] initWithFood:food
                                                                           mealCode:indexPath.section
                                                                   selectedServings:mealItem.numberOfServings
                                                                       mealPlanItem:mealItem
                                                                           mealPlan:self.mealPlan
                                                                       selectedDate:nil];
    dvController.taskMode = DMTaskModeAdd;
    [self.navigationController pushViewController:dvController animated:YES];

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        
        NSArray *mealItems = [self.mealPlan getMealItemsForMealCode:indexPath.section];
        DMMealPlanItem *mealItem = mealItems[indexPath.row];
        
        NSDictionary *params = @{@"MealID" : self.mealPlan.mealId,
                                 @"MealCode" : @(mealItem.mealCode),
                                 @"FoodID" : mealItem.foodId };
        [self deleteMealPlanItem:params];
        
        [self.mealPlan removeMealPlanItem:mealItem inMealCode:indexPath.section];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [tableView endUpdates];
        [tableView reloadData];
    }
}

#pragma mark ACTION SHEET METHODS

- (void)showActionSheet:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Action" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    [alert addAction:[UIAlertAction actionWithTitle:@"Add Plan to Log"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self selectAllMealDate:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Add New Food"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self addItemToMealPlan:nil];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark CONFIRM DIALOG

/// Confirms to the user they wish to add the meal to the date for given meal code.
- (void)confirmAddMealToLogWithMealCode:(DMLogMealCode)mealCode onDate:(NSDate *)date {
    NSDateFormatter *dateFormat_display = [[NSDateFormatter alloc] init];
    [dateFormat_display setDateFormat:@"MMMM d, yyyy"];
    NSString *date_Display = [dateFormat_display stringFromDate:date];
    NSString *message = [NSString stringWithFormat:@"You are about to add this meal to:\n %@\nIs this correct?", date_Display];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirm Log Date"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self addMealToLogWithCode:mealCode onDate:date];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"No"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)confirmAddEntirePlanToLogToDate:(NSDate *)date {
    NSDateFormatter *dateFormat_display = [[NSDateFormatter alloc] init];
    [dateFormat_display setDateStyle:NSDateFormatterLongStyle];
    NSString *date_Display = [dateFormat_display stringFromDate:date];
    
    NSString *message = [NSString stringWithFormat:@"You are about to add this plan to:\n %@\nIs this correct?", date_Display];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirm Log Date"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self addEntirePlanToLogOnDate:date];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"No"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - TTTAttributedLabel Delegate

- (void)attributedLabel:(__unused TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

- (void)updateCalorieLabels {
    DMUser *currentUser = [[DMAuthManager sharedInstance] loggedInUser];
    self.recommendedCaloriesLabel.text = [NSString stringWithFormat:@"%i", [currentUser.userBMR intValue]];
    
    DMMealPlanDataProvider *dataProvider = [[DMMealPlanDataProvider alloc] init];
    NSArray *mealItems = [self.mealPlan getAllMealItems];
    NSNumber *totalCalories = [dataProvider getTotalCaloriesForMealPlanItems:mealItems];

    self.caloriesPlannedLabel.text = [NSString stringWithFormat:@"%.0f", totalCalories.doubleValue];
}

@end
