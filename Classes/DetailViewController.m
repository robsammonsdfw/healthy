//
//  DetailViewController.m
//  DietMasterGo
//
//  Created by Andrew Moffitt on 1/5/11.
//  Copyright 2011 AE Studios. All rights reserved.
//
@import SafariServices;
#import "DetailViewController.h"
#import "ExchangeFoodViewController.h"
#import "DMMealPlanDataProvider.h"
#import "DMMyLogDataProvider.h"
#import "DMDataFetcher.h"

@interface DetailViewController()
@property (nonatomic, strong) NSMutableArray *pickerColumn1Array;
@property (nonatomic, strong) NSMutableArray *pickerColumn3Array;
@property (nonatomic, strong) NSMutableArray *pickerFractionArray;
@property (nonatomic, strong) NSMutableArray *pickerDecimalArray;
@property (nonatomic, strong) NSNumber *pickerRow1;
@property (nonatomic, strong) NSNumber *pickerRow2;
@property (nonatomic, strong) NSNumber *pickerRow3;
@property (nonatomic, strong) IBOutlet UIImageView *imgbar;
@property (nonatomic, strong) IBOutlet UILabel *staticCalLbl;
@property (nonatomic, strong) IBOutlet UILabel *staticProtFatCarbLbl;
@property (nonatomic, strong) IBOutlet UILabel *foodIdLbl;

/// The food that is being displayed to the user.
@property (nonatomic, strong) DMFood *food;
@property (nonatomic, strong) NSDate *selectedDate;
/// If the food is a favorite of the user or not.
@property (nonatomic) NSInteger countIsFavorite;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) DMMealPlanItem *mealPlanItem;
@property (nonatomic, strong) DMMealPlan *mealPlan;
@property (nonatomic) DMLogMealCode mealCode;
/// The number of servings the user has or had selected.
@property (nonatomic, strong) NSNumber *selectedServings;
@end

@implementation DetailViewController

@synthesize pickerColumn1Array, pickerColumn3Array;
@synthesize pickerRow1, pickerRow2, pickerRow3;
@synthesize pickerDecimalArray, pickerFractionArray;

- (instancetype)initWithFood:(DMFood *)food
                    mealCode:(DMLogMealCode)mealCode
            selectedServings:(NSNumber *)servings
                mealPlanItem:(DMMealPlanItem *)mealPlanItem
                    mealPlan:(DMMealPlan *)mealPlan
                selectedDate:(NSDate *)selectedDate {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _food = food;
        _mealCode = mealCode;
        _selectedServings = servings;
        _mealPlanItem = mealPlanItem;
        _mealPlan = mealPlan;
        _selectedDate = selectedDate ?: [NSDate date];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cleanUpView) name:@"CleanUpView" object:nil];

    }
    return self;
}

- (instancetype)initWithFood:(DMFood *)food
                    mealCode:(DMLogMealCode)mealCode
            selectedServings:(NSNumber *)servings
                selectedDate:(NSDate *)selectedDate {
    return [self initWithFood:food mealCode:mealCode selectedServings:servings mealPlanItem:nil mealPlan:nil selectedDate:selectedDate];
}

#pragma mark DATA METHODS

- (void)loadData {
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }
    
    double gramWeight = [self.food.gramWeight floatValue];
    double foodProtein = [self.food.protein floatValue];
    double foodFat = [self.food.fat floatValue];
    double foodCarbs = [self.food.carbohydrates floatValue];
    double servingSize = [self.food.servingSize floatValue];
    double foodCalories = [self.food.calories floatValue];
    double selectedServing = [self.selectedServings floatValue];
        
    lblFat.text = [NSString stringWithFormat:@"%.2f", foodFat * (gramWeight / 100)];
    lblCarbs.text = [NSString stringWithFormat:@"%.2f", foodCarbs * (gramWeight / 100)];
    lblProtein.text = [NSString stringWithFormat:@"%.2f", foodProtein * (gramWeight / 100)];
    self.foodIdLbl.text = self.food.foodKey.stringValue;
    
    DMMyLogDataProvider *provider = [[DMMyLogDataProvider alloc] init];
    self.countIsFavorite = [provider isFoodFavoritedForFoodKey:self.food.foodKey];

    NSArray *measureDetails = [provider getMeasureDetailsForFoodKey:self.food.foodKey];
    [pickerColumn3Array addObjectsFromArray:measureDetails];
    rowListArr = [[self filterObjectsByKeys:@"MeasureID" array:pickerColumn3Array] mutableCopy];
    pickerColumn3Array = rowListArr;

    double totalCalories;
    if (servingSize == 0){
        servingSize = 1;
    }
    if (selectedServing > 0) {
        totalCalories = foodCalories * (selectedServing * gramWeight  / 100 / servingSize);
    } else {
        selectedServing = 1.0;
        totalCalories = foodCalories * (selectedServing * gramWeight  / 100 / servingSize);
    }
    
    lblCalories.text = [NSString stringWithFormat:@"%.2f", totalCalories];
    
    NSString *servingList = [NSString stringWithFormat:@"%.2f", selectedServing];
    NSArray *servingItems = [servingList componentsSeparatedByString:@"."];
    
    [pickerView reloadAllComponents];
    
    for (NSInteger i = 0; i < [pickerColumn1Array count]; i++){
        NSString *string = [[pickerColumn1Array objectAtIndex:i] stringValue];
        if([string isEqualToString:[servingItems objectAtIndex:0]]){
            self.pickerRow1 = [NSNumber numberWithInt:(int)i];
            break;
        }
    }
    [pickerView selectRow:[pickerRow1 intValue] inComponent:0 animated:YES];
    
    if ([servingItems count] > 1) {
        
        double pickerCompare = [[servingItems objectAtIndex:1] floatValue] / 100;
        for(NSInteger i = 0; i < [pickerDecimalArray count]; i++){
            if([[NSString stringWithFormat:@"%@", [pickerDecimalArray objectAtIndex:i]] isEqualToString:[NSString stringWithFormat:@"%.1f", pickerCompare]]) {
                fractionPicker = NO;
                [pickerView reloadAllComponents];
                fractionButton.style = UIBarButtonItemStylePlain;
                decimalButton.style = UIBarButtonItemStyleDone;
                self.pickerRow2 = [NSNumber numberWithInteger:i];
                break;
            }
        }
        
        for (NSInteger i = 0; i < [pickerFractionArray count]; i++){
            double pickerValue = [[pickerFractionArray objectAtIndex:i] floatValue];
            
            if (pickerValue == pickerCompare){
                fractionPicker = YES;
                [pickerView reloadAllComponents];
                decimalButton.style = UIBarButtonItemStylePlain;
                fractionButton.style = UIBarButtonItemStyleDone;
                self.pickerRow2 = [NSNumber numberWithInteger:i];
                break;
            }
        }
        
        [pickerView selectRow:[pickerRow2 intValue] inComponent:1 animated:YES];
    }
    
    int measureID = [self.food.measureId intValue];
    if (self.mealPlanItem) {
        measureID = self.mealPlanItem.measureId.intValue;
    }
    for (NSInteger i = 0; i < [pickerColumn3Array count]; i++){
        int pickerID = [[[pickerColumn3Array objectAtIndex:i] valueForKey:@"MeasureID"] intValue];
        if (pickerID == measureID) {
            self.pickerRow3 = @(i);
            break;
        }
    }
    
    [pickerView selectRow:[pickerRow3 intValue] inComponent:2 animated:YES];
    
    [self updateCalorieCount];
}

#pragma mark VIEW LIFECYCLE

- (void)viewDidLoad {
    [super viewDidLoad];
    
    lblMealName.text = @"";
    if (self.taskMode == DMTaskModeView && self.mealPlan) {
        self.navigationItem.title = @"Plan Item Detail";
        self.title = @"Plan Item Detail";

    } else if (self.taskMode == DMTaskModeEdit) {
        self.navigationItem.title = @"Edit Log";
        self.title = @"Edit Log";

    } else if (self.taskMode == DMTaskModeAdd) {
        self.navigationItem.title = @"Add to Log";
        self.title = @"Add to Log";
        lblMealName.text = @"Please confirm measure.";

    } else if (self.taskMode == DMTaskModeAddToPlan) {
        self.navigationItem.title = @"Add to Plan";
        self.title = @"Add to Plan";
        lblMealName.text = @"Please confirm measure.";
    }
    
    if (!self.mealPlan) {
        NSTimeZone *systemTimeZone = [NSTimeZone systemTimeZone];
        NSDateFormatter *dateFormat_display = [[NSDateFormatter alloc] init];
        [dateFormat_display setDateStyle:NSDateFormatterLongStyle];
        [dateFormat_display setTimeZone:systemTimeZone];
        NSString *dateString = [dateFormat_display stringFromDate:self.selectedDate];
        lblMealName.text = [NSString stringWithFormat: @"Log Date: %@", dateString];
    }
    lblMealName.font = [UIFont boldSystemFontOfSize:17];
    
    rowListArr = [[NSMutableArray alloc] init];

    _imgbar.backgroundColor= PrimaryColor;
    _staticCalLbl.textColor = PrimaryFontColor;
    _staticProtFatCarbLbl.textColor = PrimaryFontColor;
    lblCalories.textColor = PrimaryFontColor
    lblProtein.textColor = PrimaryFontColor
    lblFat.textColor = PrimaryFontColor
    lblCarbs.textColor = PrimaryFontColor
    
    if (!pickerColumn1Array) {
        pickerColumn1Array = [[NSMutableArray alloc] init];
        for (int i = 0; i<501; i++) {
            [pickerColumn1Array addObject:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i",i]]];
        }
    }
    
    fractionPicker = YES;
    decimalButton.style = UIBarButtonItemStylePlain;
    fractionButton.style = UIBarButtonItemStyleDone;
    
    if (!pickerDecimalArray) {
        pickerDecimalArray = [[NSMutableArray alloc] initWithObjects:
                              [NSDecimalNumber decimalNumberWithString:@"0"],
                              [NSDecimalNumber decimalNumberWithString:@".1"],
                              [NSDecimalNumber decimalNumberWithString:@".2"],
                              [NSDecimalNumber decimalNumberWithString:@".3"],
                              [NSDecimalNumber decimalNumberWithString:@".4"],
                              [NSDecimalNumber decimalNumberWithString:@".5"],
                              [NSDecimalNumber decimalNumberWithString:@".6"],
                              [NSDecimalNumber decimalNumberWithString:@".7"],
                              [NSDecimalNumber decimalNumberWithString:@".8"],
                              [NSDecimalNumber decimalNumberWithString:@".9"],
                              nil];
    }
    
    if (!pickerFractionArray) {
        pickerFractionArray = [[NSMutableArray alloc] initWithObjects:
                               [NSDecimalNumber decimalNumberWithString:@"0"],
                               [NSDecimalNumber decimalNumberWithString:@".125"],
                               [NSDecimalNumber decimalNumberWithString:@".25"],
                               [NSDecimalNumber decimalNumberWithString:@".333"],
                               [NSDecimalNumber decimalNumberWithString:@".375"],
                               [NSDecimalNumber decimalNumberWithString:@".5"],
                               [NSDecimalNumber decimalNumberWithString:@".625"],
                               [NSDecimalNumber decimalNumberWithString:@".667"],
                               [NSDecimalNumber decimalNumberWithString:@".75"],
                               [NSDecimalNumber decimalNumberWithString:@".875"],
                               nil];
    }
    
    pickerColumn3Array = [[NSMutableArray alloc] init];

    lblText.text = self.food.name;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSheet:)];
    rightButton.style = UIBarButtonItemStylePlain;
    rightButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    NSString *accountCode = [DMGUtilities configValueForKey:@"account_code"];
    if ([accountCode isEqualToString:@"ezdietplanner"]) {
        UIImageView *backgroundImage = (UIImageView *)[self.view viewWithTag:501];
        backgroundImage.image = [UIImage imageNamed:@"Food_Detail_Screen"];
        pickerView.backgroundColor = [UIColor whiteColor];
    }
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Due to how pickers load, need to load data after a moment.
    [self performSelector:@selector(loadData) withObject:nil afterDelay:0.2];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    infoBtn.frame = CGRectMake(SCREEN_WIDTH - 25, lblProtein.frame.origin.y, infoBtn.frame.size.width, infoBtn.frame.size.height);
}

#pragma mark ACTION SHEET METHODS
- (void)showActionSheet:(id)sender {
    NSString *favoriteOrNot = nil;
    if (self.countIsFavorite == 0) {
        favoriteOrNot = @"Save as Favorite";
    } else {
        favoriteOrNot = @"Remove from Favorites";
    }

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Action" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (self.taskMode == DMTaskModeAdd) {
        if (self.mealPlanItem) {
            [alert addAction:[UIAlertAction actionWithTitle:@"Add to Log"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                [self selectMealDateWithCompletionBlock:^(BOOL completed) {
                    [self saveToLog:nil];
                }];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:favoriteOrNot
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                if (self.countIsFavorite == 0) {
                    [self saveToFavorites];
                } else {
                    [self confirmDeleteFromFavorite];
                }
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"Exchange Food"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                [self exchangeFood];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"Save Changes"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                [self updateFoodServings];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"Remove from Plan"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                [self deleteFromPlan];
            }]];
        }
        else {
            [alert addAction:[UIAlertAction actionWithTitle:@"Add to Log"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                [self saveToLog:nil];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:favoriteOrNot
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                if (self.countIsFavorite == 0) {
                    [self saveToFavorites];
                } else {
                    [self confirmDeleteFromFavorite];
                }
            }]];

        }
    }
    
    if (self.taskMode == DMTaskModeEdit) {
        [alert addAction:[UIAlertAction actionWithTitle:@"Save Changes"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            [self saveToLog:nil];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:favoriteOrNot
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            if (self.countIsFavorite == 0) {
                [self saveToFavorites];
            } else {
                [self confirmDeleteFromFavorite];
            }
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Remove from log"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            [self confirmDeleteFromLog];
        }]];
    }
    
    if (self.taskMode == DMTaskModeAddToPlan) {
        [alert addAction:[UIAlertAction actionWithTitle:@"Add to Plan"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            [self insertNewFood];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:favoriteOrNot
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            if (self.countIsFavorite == 0) {
                [self saveToFavorites];
            } else {
                [self confirmDeleteFromFavorite];
            }
        }]];
    }

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)confirmDeleteFromLog {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Remove from Log?"
                                                                   message:@"Are you sure you wish to remove this from the log?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes, Remove"
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self deleteFromRemoteServer];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Don't Remove" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)confirmDeleteFromFavorite {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Remove from Favorites?"
                                                                   message:@"Are you sure you wish to remove this?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes, Remove"
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self deleteFromFavorites];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Don't Remove" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

-(void)cleanUpView {
    [self.navigationController popViewControllerAnimated:YES];
}

/// Lets the user choose a date prior to completion block action.
- (void)selectMealDateWithCompletionBlock:(completionBlock)completionBlock {
    DMDatePickerViewController *dateController = [[DMDatePickerViewController alloc] init];
    dateController.didSelectDateCallback = ^(NSDate *date) {
        self.selectedDate = date;
        if (completionBlock) {
            completionBlock(YES);
        }
    };
    [dateController presentPickerIn:self];
}

#pragma mark MEAL PLAN METHODS

- (void)exchangeFood {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]  initWithTitle: @"Back" style: UIBarButtonItemStylePlain target: nil action: nil];
    [self.navigationItem setBackBarButtonItem: backButton];
    
    ExchangeFoodViewController *exchangeVC =
            [[ExchangeFoodViewController alloc] initWithFoodToExchange:self.food
                                                       forMealPlanItem:self.mealPlanItem
                                                            inMealPlan:self.mealPlan];
    [self.navigationController pushViewController:exchangeVC animated:YES];
}

- (void)updateFoodServings {
    [DMActivityIndicator showActivityIndicator];
    
    int num_measureID = [[[pickerColumn3Array objectAtIndex:[pickerView selectedRowInComponent:cSection3]] valueForKey:@"MeasureID"] intValue];
    NSDecimalNumber *servingSize1 = [pickerColumn1Array objectAtIndex:[pickerView selectedRowInComponent:cSection1]];
    NSDecimalNumber *servingSize2;
    if (fractionPicker) {
        servingSize2 = [pickerFractionArray objectAtIndex:[pickerView selectedRowInComponent:cSection2]];
    } else {
        servingSize2 = [pickerDecimalArray objectAtIndex:[pickerView selectedRowInComponent:cSection2]];
    }
    NSDecimalNumber *servingAmount = [servingSize1 decimalNumberByAdding:servingSize2];
    
    NSDictionary *updateDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    self.mealPlan.mealId, @"MealID",
                                    @(self.mealCode), @"MealCode",
                                    self.food.foodKey, @"FoodID",
                                    servingAmount, @"ServingSize",
                                    @(num_measureID), @"MeasureID",
                                nil];
        
    DMMealPlanDataProvider *provider = [[DMMealPlanDataProvider alloc] init];
    [provider updateUserPlannedMealItems:@[updateDict] withCompletionBlock:^(BOOL completed, NSError *error) {
        [DMActivityIndicator hideActivityIndicator];
        if (error) {
            [DMGUtilities showAlertWithTitle:@"Error" message:error.localizedDescription inViewController:nil];
            return;
        }
        
        [DMActivityIndicator showCompletedIndicator];
    }];
}

- (void)insertNewFood {
    [DMActivityIndicator showActivityIndicator];
    
    int num_measureID	= [[[pickerColumn3Array objectAtIndex:[pickerView selectedRowInComponent:cSection3]] valueForKey:@"MeasureID"] intValue];
    
    NSDecimalNumber *servingSize1 = [pickerColumn1Array objectAtIndex:[pickerView selectedRowInComponent:cSection1]];
    NSDecimalNumber *servingSize2;
    if (fractionPicker) {
        servingSize2 = [pickerFractionArray objectAtIndex:[pickerView selectedRowInComponent:cSection2]];
    }
    else {
        servingSize2 = [pickerDecimalArray objectAtIndex:[pickerView selectedRowInComponent:cSection2]];
    }
    NSDecimalNumber *servingAmount = [servingSize1 decimalNumberByAdding:servingSize2];
    
    NSDictionary *insertDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                self.mealPlan.mealId, @"MealID",
                                @(self.mealCode), @"MealCode",
                                self.food.foodKey, @"FoodID",
                                [NSNumber numberWithInt:num_measureID], @"MeasureID",
                                servingAmount, @"ServingSize",
                                nil];
    
    DMMealPlanDataProvider *provider = [[DMMealPlanDataProvider alloc] init];
    [provider saveUserPlannedMealItems:@[insertDict] withCompletionBlock:^(BOOL completed, NSError *error) {
        [DMActivityIndicator hideActivityIndicator];
        if (error) {
            [DMGUtilities showAlertWithTitle:@"Error" message:error.localizedDescription inViewController:nil];
            return;
        }
        [DMActivityIndicator showCompletedIndicator];
        [[NSNotificationCenter defaultCenter] postNotificationName:DMReloadDataNotification object:nil];
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:2] animated:YES];
    }];
}

- (void)deleteFromPlan {
    [DMActivityIndicator showActivityIndicator];
    
    NSDictionary *mealItems = [[NSDictionary alloc] initWithObjectsAndKeys:
                             self.mealPlan.mealId, @"MealID",
                             @(self.mealCode), @"MealCode",
                             self.food.foodKey, @"FoodID",
                             nil];
    
    DMMealPlanDataProvider *provider = [[DMMealPlanDataProvider alloc] init];
    [provider deleteUserPlannedMealItems:@[mealItems] withCompletionBlock:^(BOOL completed, NSError *error) {
        [DMActivityIndicator hideActivityIndicator];
        if (error) {
            [DMGUtilities showAlertWithTitle:@"Error" message:error.localizedDescription inViewController:nil];
            return;
        }
        
        [DMActivityIndicator showCompletedIndicator];
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:2] animated:YES];
    }];
}

#pragma mark BUTTON ACTIONS
-(IBAction)changePickerView:(id)sender {
    if ([sender tag] == 1) {
        fractionPicker = NO;
        fractionButton.style = UIBarButtonItemStylePlain;
        decimalButton.style = UIBarButtonItemStyleDone;
    }
    else {
        fractionPicker = YES;
        decimalButton.style = UIBarButtonItemStylePlain;
        fractionButton.style = UIBarButtonItemStyleDone;
    }
    
    [pickerView reloadAllComponents];
    [self updateCalorieCount];
}

#pragma mark PICKER VIEW METHODS
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    switch (component){
        case 0:
            return 55.0f;
        case 1:
            return 55.0f;
        case 2:
            return 210.0f;
            
    }
    return 0;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == cSection1) {
        return [pickerColumn1Array count];
    }
    else if(component == cSection2) {
        if (fractionPicker) {
            return [pickerFractionArray count];
        }
        else {
            return [pickerDecimalArray count];
        }
    }
    else {
        return [pickerColumn3Array count];
    }
    
}
- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == cSection1) {
        return [[pickerColumn1Array  objectAtIndex:row] stringValue];
    }
    else if(component == cSection2) {
        if (fractionPicker) {
            
            if (row == 0) {
                return @"0";
            }
            else if (row == 1) {
                return [NSString stringWithFormat:@"%@\u2044%@",[self superScriptOf:@"1"],[self subScriptOf:@"8"]];
            }
            else if (row == 2) {
                return [NSString stringWithFormat:@"%@\u2044%@",[self superScriptOf:@"1"],[self subScriptOf:@"4"]];
            }
            else if (row == 3) {
                return [NSString stringWithFormat:@"%@\u2044%@",[self superScriptOf:@"1"],[self subScriptOf:@"3"]];
            }
            else if (row == 4) {
                return [NSString stringWithFormat:@"%@\u2044%@",[self superScriptOf:@"3"],[self subScriptOf:@"8"]];
            }
            else if (row == 5) {
                return [NSString stringWithFormat:@"%@\u2044%@",[self superScriptOf:@"1"],[self subScriptOf:@"2"]];
            }
            else if (row == 6) {
                return [NSString stringWithFormat:@"%@\u2044%@",[self superScriptOf:@"5"],[self subScriptOf:@"8"]];
            }
            else if (row == 7) {
                return [NSString stringWithFormat:@"%@\u2044%@",[self superScriptOf:@"2"],[self subScriptOf:@"3"]];
            }
            else if (row == 8) {
                return [NSString stringWithFormat:@"%@\u2044%@",[self superScriptOf:@"3"],[self subScriptOf:@"4"]];
            }
            else if (row == 9) {
                return [NSString stringWithFormat:@"%@\u2044%@",[self superScriptOf:@"7"],[self subScriptOf:@"8"]];
            }
        }
        else {
            return [[pickerDecimalArray objectAtIndex:row] stringValue];
        }
    }
    else {
        return [[pickerColumn3Array  objectAtIndex:row] valueForKey:@"Description"];
    }
    
    return nil;
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self updateCalorieCount];
}

- (void)updateCalorieCount {
    double gramWeight = 0.0;
    if (pickerColumn3Array.count) {
        gramWeight = [[[pickerColumn3Array objectAtIndex:[pickerView selectedRowInComponent:cSection3]] valueForKey:@"GramWeight"] floatValue];
    }
    double servingSize = [self.food.servingSize floatValue];
    double foodCalories = [self.food.calories floatValue];
    
    NSDecimalNumber *servingSize1 = [pickerColumn1Array objectAtIndex:[pickerView selectedRowInComponent:cSection1]];
    NSDecimalNumber *servingSize2;
    if (fractionPicker) {
        servingSize2 = [pickerFractionArray objectAtIndex:[pickerView selectedRowInComponent:cSection2]];
    }
    else {
        servingSize2 = [pickerDecimalArray objectAtIndex:[pickerView selectedRowInComponent:cSection2]];
    }
    NSDecimalNumber *servingAmount = [servingSize1 decimalNumberByAdding:servingSize2];
    
    if (servingSize == 0){
        servingSize=1;
    }
    double flt_totalCalories = foodCalories * ([servingAmount floatValue] * gramWeight  / 100 / servingSize);
    
    lblCalories.text = [NSString stringWithFormat:@"%.2f", flt_totalCalories];
    
    double foodProtein = [self.food.protein floatValue];
    double foodFat = [self.food.fat floatValue];
    double foodCarbs = [self.food.carbohydrates floatValue];
    
    lblFat.text = [NSString stringWithFormat:@"%.2f",(foodFat * (gramWeight / 100)) / servingSize * [servingAmount floatValue]];
    lblCarbs.text = [NSString stringWithFormat:@"%.2f",(foodCarbs * (gramWeight / 100))  / servingSize * [servingAmount floatValue]];
    lblProtein.text = [NSString stringWithFormat:@"%.2f",(foodProtein * (gramWeight / 100))  / servingSize *[servingAmount floatValue]];
}

#pragma mark LOG METHODS
 
- (void)saveToLog:(id) sender {
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
        return;
    }
    int num_measureID = [[[pickerColumn3Array objectAtIndex:[pickerView selectedRowInComponent:cSection3]] valueForKey:@"MeasureID"] intValue];
    NSDecimalNumber *servingSize1 = [pickerColumn1Array objectAtIndex:[pickerView selectedRowInComponent:cSection1]];
    NSDecimalNumber *servingSize2;
    if (fractionPicker) {
        servingSize2 = [pickerFractionArray objectAtIndex:[pickerView selectedRowInComponent:cSection2]];
    } else {
        servingSize2 = [pickerDecimalArray objectAtIndex:[pickerView selectedRowInComponent:cSection2]];
    }
    NSDecimalNumber *servingAmount = [servingSize1 decimalNumberByAdding:servingSize2];
    
    DMMyLogDataProvider *provider = [[DMMyLogDataProvider alloc] init];
    NSNumber *logMealID = [provider getLogMealIDForDate:self.selectedDate];
    
    if (self.taskMode == DMTaskModeAdd) {
        
        int foodID = [self.food.foodKey intValue];
        
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [self.dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        NSString *date_string = [self.dateFormatter stringFromDate:self.selectedDate];
        
        [db beginTransaction];
        NSString *insertSQL = [NSString stringWithFormat: @"REPLACE INTO Food_Log (MealID, MealDate) VALUES (%@, DATETIME('%@'))", logMealID, date_string];
        [db executeUpdate:insertSQL];
        
        NSString *strChkRecord = [NSString stringWithFormat:@"SELECT count(*) FROM Food_Log_Items where FoodID = '%d' AND MealCode = '%d'AND MealID = '%@'",foodID, (int)self.mealCode, logMealID];
        FMResultSet *objChk = [db executeQuery:strChkRecord];
        while ([objChk next]) {
            if ([objChk intForColumn:@"count(*)"] > 0) {
            } else {
                NSDate* sourceDate = [NSDate date];
                [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *date_string1 = [self.dateFormatter stringFromDate:sourceDate];
                
                insertSQL = [NSString stringWithFormat: @"REPLACE INTO Food_Log_Items "
                             "(MealID, FoodID, MealCode, MeasureID, NumberOfServings, LastModified) "
                             " VALUES (%@, %i, %i, %i, %f, DATETIME('%@'))",
                             logMealID, foodID, (int)self.mealCode, num_measureID, [servingAmount floatValue], date_string1];
                [db executeUpdate:insertSQL];
            }
        }
        
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
        
        [DMActivityIndicator showCompletedIndicator];
        // Wait a second before pushing view back because otherwise the completed indicator won't work.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:DMReloadDataNotification object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:DMTriggerUpSyncNotification object:nil];
            NSInteger index = self.mealPlan ? 2 : 1;
            [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:index] animated:YES];
        });

    } else if (self.taskMode == DMTaskModeEdit) {
        
        [db beginTransaction];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [self.dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        NSString *date_string = [self.dateFormatter stringFromDate:[NSDate date]];
        
        int foodID = [self.food.foodKey intValue];
        
        NSString *updateSQL = [NSString stringWithFormat: @"UPDATE Food_Log_Items SET MeasureID = %i, NumberOfServings = %f, LastModified = '%@' WHERE FoodID = %i AND MealID = %@ AND MealCode = %i", num_measureID,[servingAmount floatValue], date_string, foodID, logMealID, (int)self.mealCode];
        [db executeUpdate:updateSQL];
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
        
        [DMActivityIndicator showCompletedIndicator];
        // Wait a second before pushing view back because otherwise the completed indicator won't work.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:DMReloadDataNotification object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:DMTriggerUpSyncNotification object:nil];
            [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
        });
    }
}

- (void)deleteFromFavorites {
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
        return;
    }
    
    int foodID = [self.food.foodKey intValue];
    [db beginTransaction];
    NSString *updateSQL = [NSString stringWithFormat: @"DELETE FROM Favorite_Food WHERE FoodID = %i", foodID];
    [db executeUpdate:updateSQL];
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
    self.countIsFavorite = 0;
    
    [DMActivityIndicator showActivityIndicator];
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"DeleteFavoriteFood", @"RequestType",
                                [NSNumber numberWithInt:foodID], @"FoodID",
                                nil];
    [DMDataFetcher fetchDataWithRequestParams:infoDict completion:^(NSObject *object, NSError *error) {
        [DMActivityIndicator hideActivityIndicator];
        if (error) {
            DMLog(@"Error DeleteFavoriteFood: %@", error.localizedDescription);
            [DMGUtilities showAlertWithTitle:@"Error" message:error.localizedDescription inViewController:nil];
            return;
        }
        [DMActivityIndicator showCompletedIndicator];
        [[NSNotificationCenter defaultCenter] postNotificationName:DMReloadDataNotification object:nil];
    }];
}

- (void)saveToFavorites {
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
        return;
    }
    
    int foodID = [self.food.foodKey intValue];
    int num_measureID = [self.food.measureId intValue];
    
    int minIDvalue = 0;
    NSString *idQuery = @"SELECT min(Favorite_FoodID) as Favorite_FoodID FROM Favorite_Food";
    FMResultSet *rsID = [db executeQuery:idQuery];
    while ([rsID next]) {
        minIDvalue = [rsID intForColumn:@"Favorite_FoodID"];
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
    [db beginTransaction];
    
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone *systemTimeZone = [NSTimeZone systemTimeZone];
    [self.dateFormatter setTimeZone:systemTimeZone];
    NSString *date_string = [self.dateFormatter stringFromDate:self.selectedDate];

    NSString *insertSQL = [NSString stringWithFormat: @"REPLACE INTO Favorite_Food (Favorite_FoodID, FoodID,modified,MeasureID) VALUES (%i, %i,DATETIME('%@'),%i)", minIDvalue, foodID, date_string, num_measureID];
    [db executeUpdate:insertSQL];
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
    
    self.countIsFavorite = 1;
    [[NSNotificationCenter defaultCenter] postNotificationName:DMReloadDataNotification object:nil];
    [DMActivityIndicator showCompletedIndicator];
}

- (void)deleteFromLocalDatabase {
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }
    
    DMMyLogDataProvider *provider = [[DMMyLogDataProvider alloc] init];
    NSNumber *logMealID = [provider getLogMealIDForDate:self.selectedDate];

    [db beginTransaction];
    int foodID = [self.food.foodKey intValue];
    NSString *updateSQL = [NSString stringWithFormat: @"DELETE FROM Food_Log_Items WHERE FoodID = %i AND MealID = %@ AND MealCode = %i", foodID, logMealID, (int)self.mealCode];
    [db executeUpdate:updateSQL];
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
    
    [DMActivityIndicator hideActivityIndicator];
    [DMActivityIndicator showCompletedIndicator];
    [[NSNotificationCenter defaultCenter] postNotificationName:DMReloadDataNotification object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteFromRemoteServer {
    [DMActivityIndicator showActivityIndicator];
    
    DMMyLogDataProvider *provider = [[DMMyLogDataProvider alloc] init];
    NSNumber *logMealID = [provider getLogMealIDForDate:self.selectedDate];
    [provider deleteFoodFromLogWithID:self.food.foodKey logMealId:logMealID mealCode:self.mealCode completionBlock:^(BOOL completed, NSError *error) {
        if (error) {
            [DMActivityIndicator hideActivityIndicator];
            [DMGUtilities showAlertWithTitle:@"Error" message:error.localizedDescription inViewController:nil];
            return;
        }
        [self deleteFromLocalDatabase];
    }];
}

#pragma mark CUSTOM SUPERSCRIPT NSSTRING METHOD

- (NSString *)superScriptOf:(NSString *)inputNumber {
    NSString *outp=@"";
    for (int i =0; i<[inputNumber length]; i++) {
        unichar chara=[inputNumber characterAtIndex:i] ;
        switch (chara) {
            case '1':
                outp=[outp stringByAppendingFormat:@"\u00B9"];
                break;
            case '2':
                outp=[outp stringByAppendingFormat:@"\u00B2"];
                break;
            case '3':
                outp=[outp stringByAppendingFormat:@"\u00B3"];
                break;
            case '4':
                outp=[outp stringByAppendingFormat:@"\u2074"];
                break;
            case '5':
                outp=[outp stringByAppendingFormat:@"\u2075"];
                break;
            case '6':
                outp=[outp stringByAppendingFormat:@"\u2076"];
                break;
            case '7':
                outp=[outp stringByAppendingFormat:@"\u2077"];
                break;
            case '8':
                outp=[outp stringByAppendingFormat:@"\u2078"];
                break;
            case '9':
                outp=[outp stringByAppendingFormat:@"\u2079"];
                break;
            case '0':
                outp=[outp stringByAppendingFormat:@"\u2070"];
                break;
            default:
                break;
        }
    }
    return outp;
}

- (NSString *)subScriptOf:(NSString *)inputNumber {
    NSString *outp=@"";
    for (int i =0; i<[inputNumber length]; i++) {
        unichar chara=[inputNumber characterAtIndex:i] ;
        switch (chara) {
            case '1':
                outp=[outp stringByAppendingFormat:@"\u2081"];
                break;
            case '2':
                outp=[outp stringByAppendingFormat:@"\u2082"];
                break;
            case '3':
                outp=[outp stringByAppendingFormat:@"\u2083"];
                break;
            case '4':
                outp=[outp stringByAppendingFormat:@"\u2084"];
                break;
            case '5':
                outp=[outp stringByAppendingFormat:@"\u2085"];
                break;
            case '6':
                outp=[outp stringByAppendingFormat:@"\u2086"];
                break;
            case '7':
                outp=[outp stringByAppendingFormat:@"\u2087"];
                break;
            case '8':
                outp=[outp stringByAppendingFormat:@"\u2088"];
                break;
            case '9':
                outp=[outp stringByAppendingFormat:@"\u2089"];
                break;
            case '0':
                outp=[outp stringByAppendingFormat:@"\u2080"];
                break;
            default:
                break;
        }
    }
    return outp;   
}

-(NSMutableArray *) filterObjectsByKeys:(NSString *) key array:(NSMutableArray *)array {
    NSMutableSet *tempValues = [[NSMutableSet alloc] init];
    NSMutableArray *ret = [NSMutableArray array];
    for(id obj in array) {
        if(! [tempValues containsObject:[obj valueForKey:key]]) {
            [tempValues addObject:[obj valueForKey:key]];
            [ret addObject:obj];
        }
    }
    return ret;
}

#pragma mark Safari

- (IBAction)goToSafetyGuidelines:(id)sender {
    SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://advancedwebservicegroup.com/AWSGDocuments/GuidelinesAndSafety.html"]];
    [self presentViewController:sfvc animated:YES completion:nil];
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
