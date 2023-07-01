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
#import "FMDatabaseAdditions.h"
#import "DetailViewController.h"
#import "Log_Add.h"
#import "MealPlanDetailsTableViewCell.h"
#import "TTTAttributedLabel.h"
#import "DMMealPlanDataProvider.h"

@interface MealPlanDetailViewController() <UITableViewDelegate, UITableViewDataSource, TTTAttributedLabelDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic) int addToPlanButtonIndex;
@property (nonatomic, strong) IBOutlet UIImageView *imgbar;
@property (nonatomic, strong) IBOutlet UIImageView *imgbarline;
@property (nonatomic, strong) IBOutlet UILabel *staticCalPlannedLbl;
@property (nonatomic, strong) IBOutlet UILabel *staticRecomCalLbl;
@end

static NSString *CellIdentifier = @"MealPlanDetailsTableViewCell";

@implementation MealPlanDetailViewController

- (instancetype)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        _selectedIndex = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    titleLabel.textColor=PrimaryDarkFontColor
    _staticRecomCalLbl.textColor = PrimaryFontColor
    _staticCalPlannedLbl.textColor = PrimaryFontColor

    _imgbar.backgroundColor= PrimaryColor
    _imgbarline.backgroundColor=RGB(255, 255, 255, 0.5);
  
    self.tableView.estimatedRowHeight = 60;
    [self.tableView registerNib:[UINib nibWithNibName:CellIdentifier bundle:nil] forCellReuseIdentifier:CellIdentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
          switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
              case 2436:
              case 2688:
              case 1792:
                  //iphone x+
                  infoBtn.frame = CGRectMake(10, _imgbar.frame.origin.y + _staticRecomCalLbl.bounds.size.height, 18, 21);

                  break;
              default:
              //for iphone 8
              infoBtn.frame = CGRectMake(10, _imgbar.frame.origin.y - 8, 18, 21);

                  break;
          }

    }

    [infoBtn addTarget:self action:@selector(goToSafetyGuidelines:) forControlEvents:UIControlEventTouchUpInside];
    [infoBtn setUserInteractionEnabled:YES];
    
    self.title = @"My Meals";
    [self.navigationItem setTitle:@"My Meals"];

    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar setTranslucent:NO];

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStylePlain
                                   target: nil action: nil];
    backButton.tintColor=[UIColor whiteColor];
    [self.navigationItem setBackBarButtonItem: backButton];
    
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    NSDictionary *tempDict = [[NSDictionary alloc] initWithDictionary:[dietmasterEngine.mealPlanArray objectAtIndex:self.selectedIndex]];
    titleLabel.text = [tempDict valueForKey:@"MealName"];
    
    titleLabel.backgroundColor=PrimaryDarkColor
   
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                 target:self
                                                                                 action:@selector(showActionSheet:)];
    rightButton.style = UIBarButtonItemStylePlain;
    rightButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    if (!dietmasterEngine.dateSelected) {
        NSDate* sourceDate = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
        [dateFormat setTimeZone:systemTimeZone];
        NSString *date_string = [dateFormat stringFromDate:sourceDate];
        NSDate *date = [dateFormat dateFromString:date_string];
        
        dietmasterEngine.dateSelected = date;
        NSDateFormatter *dateFormat_display = [[NSDateFormatter alloc] init];
        [dateFormat_display setDateStyle:NSDateFormatterLongStyle];
        [dateFormat_display setTimeZone:systemTimeZone];
        NSString *date_Display		= [dateFormat_display stringFromDate:date];
        dietmasterEngine.dateSelectedFormatted = date_Display;
    }
    
    [self updateCalorieLabels];
    
    mealCodeToAdd = -1;
    self.addToPlanButtonIndex = -1;
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:PLIST_NAME];
    NSDictionary *appDefaults = [[NSDictionary alloc] initWithContentsOfFile:finalPath];
    
    UIImageView *backgroundImage = (UIImageView *)[self.view viewWithTag:501];
    if ([[appDefaults valueForKey:@"account_code"] isEqualToString:@"ezdietplanner"]) {
        backgroundImage.image = [UIImage imageNamed:@"My_Plan_Background"];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self checkForMissingFoods];
    [self loadData];
    [self.tableView reloadData];
}

-(IBAction)goToSafetyGuidelines:(id)sender {
    SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://advancedwebservicegroup.com/AWSGDocuments/GuidelinesAndSafety.html"]];
    [self presentViewController:sfvc animated:YES completion:nil];
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark LOAD DATA METHODS

- (void)loadData {
    DMMealPlanDataProvider *provider = [[DMMealPlanDataProvider alloc] init];
    __weak typeof(self) weakSelf = self;
    [provider fetchUserPlannedMealsWithCompletionBlock:^(NSObject *object, NSError *error) {
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        [dietmasterEngine.mealPlanArray removeAllObjects];
        if (error) {
            [[weakSelf tableView] reloadData];
            return;
        }
        NSArray *results = (NSArray *)object;
        [dietmasterEngine.mealPlanArray addObjectsFromArray:results];
        [weakSelf checkForMissingFoods];
        [[weakSelf tableView] reloadData];
        [weakSelf updateCalorieLabels];
    }];
}

- (void)addPlanToLog {
    DietmasterEngine *dietmasterEngine = [DietmasterEngine sharedInstance];
    NSArray *tempArray = [[dietmasterEngine.mealPlanArray objectAtIndex:self.selectedIndex] valueForKey:@"MealItems"];

    DMMealPlanDataProvider *provider = [[DMMealPlanDataProvider alloc] init];
    for (NSDictionary *dict in [tempArray copy]) {
        [provider insertMealPlanToLog:dict toDate:dietmasterEngine.dateSelected];
    }
    [DMActivityIndicator showCompletedIndicator];
}

/// Adds the meal to log with the code provided.
- (void)addMealToLogWithCode:(NSNumber *)mealCode {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    NSArray *mealItems = [[[dietmasterEngine.mealPlanArray objectAtIndex:self.selectedIndex] valueForKey:@"MealItems"] copy];
    
    DMMealPlanDataProvider *provider = [[DMMealPlanDataProvider alloc] init];
    for (NSDictionary *mealItemDict in [mealItems objectAtIndex:mealCode.integerValue]) {
        BOOL success = [provider insertMealPlanToLog:mealItemDict toDate:dietmasterEngine.dateSelected];
        if (!success) {
            DMLog(@"Food was not added successfully!");
        }
    }
    
    [DMActivityIndicator showCompletedIndicator];
}

- (void)addItemToMealPlan:(id)sender {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    int planMealID = [[[dietmasterEngine.mealPlanArray objectAtIndex:self.selectedIndex] valueForKey:@"MealID"] intValue];
    dietmasterEngine.selectedMealPlanID = planMealID;
    dietmasterEngine.isMealPlanItem = YES;
    dietmasterEngine.taskMode = @"AddMealPlanItem";
    Log_Add *dvController = [[Log_Add alloc] initWithNibName:@"Log_Add" bundle:nil];
    dvController.date_currentDate = dietmasterEngine.dateSelected;
    [self.navigationController pushViewController:dvController animated:YES];
}

#pragma mark SELECT DATE METHODS
- (void)selectMealDate:(UIButton *)sender {
    self.addToPlanButtonIndex = 1;

    DMDatePickerViewController *dateController = [[DMDatePickerViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    dateController.didSelectDateCallback = ^(NSDate *date) {
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        dietmasterEngine.dateSelected = date;
        // The sender.tag is the value of the meal code.
        [weakSelf confirmAddMealToLogWithMealCode:@(sender.tag)];
        weakSelf.addToPlanButtonIndex = -1;
    };
    [dateController presentPickerIn:self];
}

- (void)selectAllMealDate:(id)sender {
    self.addToPlanButtonIndex = 0;
    mealCodeToAdd = -1;
    
    DMDatePickerViewController *dateController = [[DMDatePickerViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    dateController.didSelectDateCallback = ^(NSDate *date) {
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        dietmasterEngine.dateSelected = date;
        [weakSelf confirmAddToLog];
        weakSelf.addToPlanButtonIndex = -1;
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
- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    NSArray *mealPlanArray = [dietmasterEngine.mealPlanArray copy];
    if ([mealPlanArray count] > 0) {
        return [[[mealPlanArray objectAtIndex:self.selectedIndex] valueForKey:@"MealItems"] count];
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    NSArray *mealPlanArray = [dietmasterEngine.mealPlanArray copy];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    view.backgroundColor = UIColorFromHex(0xF3F3F3);

    DMMealPlanDataProvider *dataProvider = [[DMMealPlanDataProvider alloc] init];
    if (mealPlanArray.count != 0 ) {
        NSNumber *totalCalories = [dataProvider getCaloriesForMealCodes: [[[mealPlanArray objectAtIndex:self.selectedIndex] valueForKey:@"MealItems"] objectAtIndex:section]];
        
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
        
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(10, 10, 150, 18);
        label.textColor = [UIColor blackColor];
        label.font = [UIFont boldSystemFontOfSize:17.0];
        label.text = sectionTitle;
        label.backgroundColor = [UIColor clearColor];
        
        CGRect calorieLabelFrame = CGRectMake(SCREEN_WIDTH - 160, 10, 100, 18);
        UILabel *calorieLabel			= [[UILabel alloc] initWithFrame:calorieLabelFrame];
        calorieLabel.text				= [NSString stringWithFormat:@"%.0f Calories", [totalCalories doubleValue]];
        calorieLabel.textColor			= [UIColor blackColor];
        calorieLabel.font				= [UIFont boldSystemFontOfSize:13.0];
        calorieLabel.backgroundColor	= [UIColor clearColor];
        calorieLabel.textAlignment = NSTextAlignmentRight;
        
        [view addSubview:label];
        [view addSubview:calorieLabel];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self
                   action:@selector(selectMealDate:)
         forControlEvents:UIControlEventTouchUpInside];
        UIImage *myLogImage = [UIImage imageNamed:@"mylog"];
        myLogImage = [myLogImage imageWithTintColor:[UIColor blackColor] renderingMode:UIImageRenderingModeAlwaysTemplate];
        [button setImage:myLogImage forState:UIControlStateNormal];
        button.frame = CGRectMake(SCREEN_WIDTH - 50, 0, 38, 38);
        button.tag = section;
        button.tintColor = [UIColor blackColor];
        [view addSubview:button];
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    NSArray *mealPlanArray = [dietmasterEngine.mealPlanArray copy];

    if ([[[mealPlanArray objectAtIndex:self.selectedIndex] allKeys] containsObject:@"MealNotes"]) {
        if ([[[[mealPlanArray objectAtIndex:self.selectedIndex] valueForKey:@"MealNotes"]valueForKey:@"MealCode"] containsObject:[NSString stringWithFormat:@"%ld", (long)section]]) {
            
            NSUInteger indexOfSection = [[[[mealPlanArray objectAtIndex:self.selectedIndex] valueForKey:@"MealNotes"]valueForKey:@"MealCode"] indexOfObject:[NSString stringWithFormat:@"%ld", (long)section]];
            
            NSDictionary *tempDict = [[NSDictionary alloc] initWithDictionary:[[[mealPlanArray objectAtIndex:self.selectedIndex] valueForKey:@"MealNotes"] objectAtIndex:indexOfSection]];
            if( [[tempDict valueForKey:@"MealNote"] isEqualToString:@""]) {
                return [[[[mealPlanArray objectAtIndex:self.selectedIndex] valueForKey:@"MealItems"] objectAtIndex:section] count];
            }
            else {
                return [[[[mealPlanArray objectAtIndex:self.selectedIndex] valueForKey:@"MealItems"] objectAtIndex:section] count] + 1;
            }
        }
        else {
            return [[[[mealPlanArray objectAtIndex:self.selectedIndex] valueForKey:@"MealItems"] objectAtIndex:section] count];
        }
    }
    else {
        return [[[[mealPlanArray objectAtIndex:self.selectedIndex] valueForKey:@"MealItems"] objectAtIndex:section] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MealPlanDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.lblMealName.numberOfLines = 0;
    cell.lblMealName.lineBreakMode = NSLineBreakByWordWrapping;
    
    cell.userInteractionEnabled = NO;
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    NSInteger indexpathRow = indexPath.row;
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    NSArray *mealPlanArray = [dietmasterEngine.mealPlanArray copy];
    if (mealPlanArray.count != 0) {
        if ([[[mealPlanArray objectAtIndex:self.selectedIndex] allKeys] containsObject:@"MealNotes"]) {
            if ([[[[mealPlanArray objectAtIndex:self.selectedIndex] valueForKey:@"MealNotes"]valueForKey:@"MealCode"] containsObject:[NSString stringWithFormat:@"%ld", (long)indexPath.section]]) {
                
                NSUInteger indexOfSection = [[[[mealPlanArray objectAtIndex:self.selectedIndex] valueForKey:@"MealNotes"]valueForKey:@"MealCode"] indexOfObject:[NSString stringWithFormat:@"%ld", (long)indexPath.section]];
                
                NSDictionary *tempDict = [[NSDictionary alloc] initWithDictionary:[[[mealPlanArray objectAtIndex:self.selectedIndex] valueForKey:@"MealNotes"] objectAtIndex:indexOfSection]];
                
                if(![[tempDict valueForKey:@"MealNote"] isEqualToString:@""]) {
                    if (indexPath.row == 0) {
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        cell.backgroundColor = UIColorFromHex(0xF3F3F3);
                        cell.lblMealNote.font = [UIFont boldSystemFontOfSize:15.0];
                        cell.accessoryType = UITableViewCellAccessoryNone;
                        cell.lblMealNote.numberOfLines = 0;
                        cell.userInteractionEnabled = NO;
                    
                        cell.lblMealNote.text = [tempDict valueForKey:@"MealNote"];
                        cell.lblMealName.text = nil;
                        cell.lblServingSize.text = nil;
                        return cell;
                    } else {
                        cell.lblMealNote.text = nil;
                        indexpathRow -= 1;
                    }
                } else {
                  cell.lblMealNote.text = nil;
                }
            } else {
               cell.lblMealNote.text = nil;
            }
        } else {
           cell.lblMealNote.text = nil;
        }
    } else {
        cell.lblMealNote.text = nil;
    }
    
    cell.backgroundColor = [UIColor clearColor];
    [cell lblMealName].adjustsFontSizeToFitWidth = YES;
    cell.lblMealName.font = [UIFont systemFontOfSize:15.0];
    cell.lblMealName.minimumScaleFactor = 10.0f;
    cell.lblServingSize.font = [UIFont systemFontOfSize:13.0];
    cell.lblServingSize.textColor = [UIColor darkGrayColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.lblMealName.textColor = [UIColor blackColor];
    
    cell.userInteractionEnabled = YES;

    if (mealPlanArray.count != 0) {
        NSDictionary *tempDict = [[NSDictionary alloc] initWithDictionary: [[[[mealPlanArray objectAtIndex:self.selectedIndex] valueForKey:@"MealItems"] objectAtIndex:[indexPath section]] objectAtIndex:indexpathRow]];
                
        DMMyLogDataProvider *provider = [[DMMyLogDataProvider alloc] init];
        DMFood *food = [provider getFoodForFoodKey:[tempDict valueForKey:@"FoodID"]];
        
        cell.lblServingSize.text = [NSString stringWithFormat:@"Serving: %.2f - %@", [[tempDict valueForKey:@"NumberOfServings"] doubleValue], food.description];

        NSString *foodName = food.name;
        cell.lblMealName.text = foodName;
        
        NSNumber *foodCategory = food.categoryId;
        NSRange r = [foodName rangeOfString:foodName];
        
        if ([foodCategory intValue] == 66) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *hostname = [prefs stringForKey:@"HostName"];
            NSNumber *recipeID = food.recipeId;
            
            if (hostname != nil && ![hostname isEqualToString:@""] && recipeID != nil && [recipeID intValue] > 0) {
                cell.userInteractionEnabled = YES;
                cell.lblMealName.delegate = self;
                NSString *url = [NSString stringWithFormat:@"%@/PDFviewer.aspx?ReportName=CustomRecipe&ID=%@", hostname, recipeID];
                [cell.lblMealName addLinkToURL:[NSURL URLWithString:url] withRange:r];
            }
            
        } else {
            NSString *foodURL = food.foodURL;
            if (foodURL != nil && ![foodURL isEqualToString:@""]) {
                cell.userInteractionEnabled = YES;
                cell.lblMealName.delegate = self;
                [cell.lblMealName addLinkToURL:[NSURL URLWithString:foodURL] withRange:r];
            } else {
                cell.lblMealName.delegate = nil;
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger indexpathRow = indexPath.row;
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    NSArray *mealPlanArray = [dietmasterEngine.mealPlanArray copy];

    if ([[[mealPlanArray objectAtIndex:self.selectedIndex] allKeys] containsObject:@"MealNotes"]) {
        NSArray *mealnotesdict = [[mealPlanArray objectAtIndex:self.selectedIndex] valueForKey:@"MealNotes"];
        
        for (int i = 0; i < [mealnotesdict count]; i++) {
            NSDictionary *mealNote = mealnotesdict[i];
            NSNumber *mealCode = [mealNote valueForKey:@"MealCode"];
            NSString *noteString = [mealNote valueForKey:@"MealNote"];
            
            if ([mealCode intValue] == (long)indexPath.section && ![noteString isEqualToString:@""]) {
                indexpathRow = MAX(indexPath.row - 1, 0);
                break;
            };
        }
    }
        
    if (mealPlanArray.count > 0){
        
        NSDictionary *tempDict = [[NSDictionary alloc] initWithDictionary:[[[[mealPlanArray objectAtIndex:self.selectedIndex] valueForKey:@"MealItems"] objectAtIndex:[indexPath section]] objectAtIndex:indexpathRow]];
                
        DMMyLogDataProvider *provider = [[DMMyLogDataProvider alloc] init];
        DMFood *food = [provider getFoodForFoodKey:[tempDict valueForKey:@"FoodID"]];
        
        dietmasterEngine.taskMode = @"Save";
        dietmasterEngine.isMealPlanItem = YES;
        [dietmasterEngine.mealPlanItemToExchangeDict setDictionary:[food dictionaryRepresentation]]; // For Exchanging!
        int mealCode = (int)[indexPath section];
        dietmasterEngine.selectedMealID = [NSNumber numberWithInt:mealCode]; // Meal to exchange with!
        dietmasterEngine.indexOfItemToExchange = (int)[indexPath row]; // index to exchange, making it easier.
        int planMealID = [[[mealPlanArray objectAtIndex:self.selectedIndex] valueForKey:@"MealID"] intValue];
        dietmasterEngine.selectedMealPlanID = planMealID;
        
        DetailViewController *dvController = [[DetailViewController alloc] initWithFood:[food dictionaryRepresentation]];
        [self.navigationController pushViewController:dvController animated:YES];

        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        NSArray *mealPlanArray = [dietmasterEngine.mealPlanArray copy];

        if (mealPlanArray.count != 0) {
            long index = [indexPath row];
            
            NSMutableDictionary *selectedDictionary = [mealPlanArray objectAtIndex:self.selectedIndex];
                        
            if ([[selectedDictionary allKeys] containsObject:@"MealNotes"]) {
                //cannot delete the meal note.
                if (index == 0) {
                    [tableView endUpdates];
                    return;
                }
                //if not 0, subtract 1 to get the index of the mealItem
                index--;
            }
            
            NSDictionary *tempDict = [[NSDictionary alloc] initWithDictionary:
                                      [[[[mealPlanArray objectAtIndex:self.selectedIndex]
                                         valueForKey:@"MealItems"]
                                        objectAtIndex:[indexPath section]]
                                       objectAtIndex:index]
                                      ];

            NSString *planMealID = [[mealPlanArray objectAtIndex:self.selectedIndex] valueForKey:@"MealID"];

            NSDictionary *newDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     planMealID, @"MealID",
                                     [tempDict valueForKey:@"MealCode"], @"MealCode",
                                     [tempDict valueForKey:@"FoodID"], @"FoodID",
                                     nil];
            [self deleteMealPlanItem:newDict];
            
            [[[[dietmasterEngine.mealPlanArray objectAtIndex:self.selectedIndex] valueForKey:@"MealItems"] objectAtIndex:[indexPath section]] removeObjectAtIndex:index];
            
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            [tableView endUpdates];
            [tableView reloadData];
        }
    }
}

#pragma mark MISSING FOOD
-(void)checkForMissingFoods {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    NSArray *mealPlanArray = [dietmasterEngine.mealPlanArray copy];

    if (mealPlanArray.count != 0) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:
                                     [[mealPlanArray objectAtIndex:self.selectedIndex]
                                      valueForKey:@"MealItems"]
                                                                copyItems:YES];
        
        NSMutableArray *arrMOnlyValid = (NSMutableArray *)[[NSMutableArray alloc] initWithArray:tempArray];
        
        for (NSArray *mealArray in tempArray) {
            int sectionIndex = (int)[tempArray indexOfObject:mealArray];
            
            NSMutableArray *indexPathArray = [[NSMutableArray alloc] init];
            
            for (NSDictionary *mealItems in mealArray) {
                                
                DMMyLogDataProvider *provider = [[DMMyLogDataProvider alloc] init];
                DMFood *food = [provider getFoodForFoodKey:[mealItems valueForKey:@"FoodID"]];

                NSRange range = [food.name rangeOfString:@"Invalid"];
                
                if ([food.name isEqualToString:@"Invalid Food, Contact Support"] || range.location != NSNotFound) {
                    [indexPathArray addObject:mealItems];
                    
                    NSMutableArray *arrMInvalidFoodRemoveOperation = [[NSMutableArray alloc] init];
                    
                    for (int i=0; i<[[tempArray objectAtIndex:sectionIndex] count]; i++) {
                        if ([[[tempArray objectAtIndex:sectionIndex] objectAtIndex:i] valueForKey:@"FoodID"] != [mealItems valueForKey:@"FoodID"]) {
                            [arrMInvalidFoodRemoveOperation addObject:[[tempArray objectAtIndex:sectionIndex] objectAtIndex:i]];
                        }
                        
                        if ([[[tempArray objectAtIndex:sectionIndex] objectAtIndex:i] valueForKey:@"FoodID"] == [mealItems valueForKey:@"FoodID"]) {
                            [arrMOnlyValid removeObject:mealItems];
                        }
                    }
                    
                    [arrMOnlyValid replaceObjectAtIndex:sectionIndex withObject:arrMInvalidFoodRemoveOperation];
                    
                    
                    tempArray = [arrMOnlyValid mutableCopy];
                    
                    [self.tableView endUpdates];
                    [self.tableView reloadData];
                }
            }
        }
    }
}

- (void)removeMissingFood:(NSIndexPath *)indexPath {
    
    [self.tableView beginUpdates];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    [[[[dietmasterEngine.mealPlanArray objectAtIndex:self.selectedIndex] valueForKey:@"MealItems"]
      objectAtIndex:[indexPath section]] removeObjectAtIndex:[indexPath row]];
    
    [self.tableView endUpdates];
    [self.tableView reloadData];
}

#pragma mark ACTION SHEET METHODS
-(void)showActionSheet:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Action" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    [alert addAction:[UIAlertAction actionWithTitle:@"Add Plan to Log"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        self.addToPlanButtonIndex = 0;
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
- (void)confirmAddMealToLogWithMealCode:(NSNumber *)mealCode {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    NSDateFormatter *dateFormat_display = [[NSDateFormatter alloc] init];
    [dateFormat_display setDateFormat:@"MMMM d, yyyy"];
    NSString *date_Display = [dateFormat_display stringFromDate:dietmasterEngine.dateSelected];
    NSString *message = [NSString stringWithFormat:@"You are about to add this meal to:\n %@\nIs this correct?", date_Display];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirm Log Date"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self addMealToLogWithCode:mealCode];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"No"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)confirmAddToLog {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    NSDateFormatter *dateFormat_display = [[NSDateFormatter alloc] init];
    [dateFormat_display setDateFormat:@"MMMM d, yyyy"];
    
    NSString *date_Display		= [dateFormat_display stringFromDate:dietmasterEngine.dateSelected];
    NSString *message = [NSString stringWithFormat:@"You are about to add this plan to:\n %@\nIs this correct?", date_Display];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirm Log Date"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self addPlanToLog];
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

#pragma mark LABEL UPDATE METHODS

-(void)updateCalorieLabels {
    DMUser *currentUser = [[DMAuthManager sharedInstance] loggedInUser];
    recommendedCaloriesLabel.text = [NSString stringWithFormat:@"%i", [currentUser.userBMR intValue]];

    double planCalories = 0;
    
    DMMealPlanDataProvider *dataProvider = [[DMMealPlanDataProvider alloc] init];
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    for (int i = 0; i <=5; i++) {
        NSDictionary *mealPlan = [dietmasterEngine.mealPlanArray objectAtIndex:self.selectedIndex];
        NSNumber *totalCalories = [dataProvider getCaloriesForMealCodes:[[mealPlan valueForKey:@"MealItems"] objectAtIndex:i]];
        planCalories = planCalories + [totalCalories doubleValue];
    }
    caloriesPlannedLabel.text = [NSString stringWithFormat:@"%.0f", planCalories];
}

@end
