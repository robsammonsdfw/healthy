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
@property (nonatomic, strong) NSDictionary *foodDict;
@property (nonatomic, strong) DMFood *food;
@end

@implementation DetailViewController

@synthesize pickerColumn1Array, pickerColumn3Array;
@synthesize pickerRow1, pickerRow2, pickerRow3;
@synthesize pickerDecimalArray, pickerFractionArray;

- (instancetype)initWithFood:(NSDictionary *)foodDict {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        _foodDict = foodDict;
        [self loadFood];
    }
    return self;
}

#pragma mark DATA METHODS

- (void)loadFood {
    DMMyLogDataProvider *provider = [[DMMyLogDataProvider alloc] init];
    self.food = [provider getFoodForFoodKey:self.foodDict[@"FoodKey"]];
}

- (void)loadData {
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }
    
    double gramWeight = [self.food.gramWeight floatValue];
    double foodProtein = [[self.foodDict valueForKey:@"Protein"] floatValue];
    double foodFat = [[self.foodDict valueForKey:@"Fat"] floatValue];
    double foodCarbs = [[self.foodDict valueForKey:@"Carbohydrates"] floatValue];
    double servingSize = [[self.foodDict valueForKey:@"ServingSize"] floatValue];
    double foodCalories = [[self.foodDict valueForKey:@"Calories"] floatValue];
    double selectedServing = [[self.foodDict valueForKey:@"Servings"] floatValue];
    
    int foodID = [[self.foodDict valueForKey:@"FoodKey"] intValue];
    
    lblFat.text			= [NSString stringWithFormat:@"%.2f",foodFat * (gramWeight / 100)];
    lblCarbs.text		= [NSString stringWithFormat:@"%.2f",foodCarbs * (gramWeight / 100)];
    lblProtein.text		= [NSString stringWithFormat:@"%.2f",foodProtein * (gramWeight / 100)];
    
    NSString *query = [NSString stringWithFormat: @"SELECT m.MeasureID, m.Description, fm.GramWeight, (SELECT count(*) FROM Favorite_Food WHERE FoodID = %i) as favCount FROM Measure m INNER JOIN FoodMeasure fm ON fm.MeasureID = m.MeasureID WHERE fm.FoodID = %i ORDER BY m.Description", foodID,foodID];
    
    NSString *addSql = [NSString stringWithFormat:@"SELECT * FROM Food WHERE FoodKey  = %i", foodID];
    FMResultSet *rss = [db executeQuery:addSql];
    while ([rss next]) {
        
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithInt:[rss intForColumn:@"FoodID"]], @"FoodID", nil];
        _foodIdLbl.text = [NSString stringWithFormat:@"%@",dict[@"FoodID"]];
        
    }
    
    FMResultSet *rs = [db executeQuery:query];
    while ([rs next]) {
        num_isFavorite		= [rs intForColumn:@"favCount"];
        
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithInt:[rs intForColumn:@"MeasureID"]], @"MeasureID",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"GramWeight"]], @"GramWeight",
                              [rs stringForColumn:@"Description"], @"Description", nil];
        [pickerColumn3Array addObject:dict];
        
        rowListArr = [[self filterObjectsByKeys:@"MeasureID" array:pickerColumn3Array] mutableCopy];
        pickerColumn3Array = rowListArr;
        
    }
    
    double totalCalories;
    if (servingSize == 0){
        servingSize=1;
    }
    
    if (selectedServing > 0) {
        totalCalories = foodCalories * (selectedServing * gramWeight  / 100 / servingSize);
    }
    else {
        selectedServing = 1.0;
        totalCalories = foodCalories * (selectedServing * gramWeight  / 100 / servingSize);
    }
    
    lblCalories.text = [NSString stringWithFormat:@"%.2f", totalCalories];
    
    NSString *servingList		= [NSString stringWithFormat:@"%.2f", [[self.foodDict valueForKey:@"Servings"] floatValue]];
    NSArray *servingItems	= [servingList componentsSeparatedByString:@"."];
    
    [pickerView reloadAllComponents];
    
    for(NSInteger i = 0; i < [pickerColumn1Array count]; i++){
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
            
            if(pickerValue == pickerCompare){
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
    
    int measureID = [[self.foodDict valueForKey:@"MeasureID"] intValue];
    for(NSInteger i = 0; i < [pickerColumn3Array count]; i++){
        int pickerID = [[[pickerColumn3Array objectAtIndex:i] valueForKey:@"MeasureID"] intValue];
        if(pickerID == measureID){
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
                              [NSDecimalNumber decimalNumberWithString:@".5"],                               [NSDecimalNumber decimalNumberWithString:@".6"],
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
    
    if (!pickerColumn3Array) {
        pickerColumn3Array = [[NSMutableArray alloc] init];
    }
    
    [pickerColumn3Array removeAllObjects];
    
    lblText.text = [self.foodDict valueForKey:@"Name"];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                 target:self
                                                                                 action:@selector(showActionSheet:)];
    rightButton.style = UIBarButtonItemStylePlain;
    rightButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:PLIST_NAME];
    NSDictionary *appDefaults = [[NSDictionary alloc] initWithContentsOfFile:finalPath];
    
    UIImageView *backgroundImage = (UIImageView *)[self.view viewWithTag:501];
    if ([[appDefaults valueForKey:@"account_code"] isEqualToString:@"ezdietplanner"]) {
        backgroundImage.image = [UIImage imageNamed:@"Food_Detail_Screen"];
        pickerView.backgroundColor = [UIColor whiteColor];
    }
    
    [self.navigationController.navigationBar setTranslucent:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Due to how pickers load, need to load data after a moment.
    [self performSelector:@selector(loadData) withObject:nil afterDelay:0.25];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cleanUpView) name:@"CleanUpView" object:nil];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    if ([dietmasterEngine.taskMode isEqualToString:@"AddMealPlanItem"]) {
        lblMealName.text = @"Add item to Plan";
    } else {
        NSString *strDate = dietmasterEngine.dateSelectedFormatted;
        NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
        NSDateFormatter *dateFormat_display = [[NSDateFormatter alloc] init];
        [dateFormat_display setDateStyle:NSDateFormatterLongStyle];
        [dateFormat_display setTimeZone:systemTimeZone];
        NSDate *date = [dateFormat_display dateFromString:strDate];
        if (date) {
            NSString *strFinal = [dateFormat_display stringFromDate:date];
            lblMealName.text    = [NSString stringWithFormat: @"Log Date: %@", strFinal];
        }
        else{
            lblMealName.text    = [NSString stringWithFormat: @"Log Date: %@", dietmasterEngine.dateSelectedFormatted];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    if ([dietmasterEngine.taskMode isEqualToString:@"Save"]) {
        if (dietmasterEngine.isMealPlanItem) {
            self.navigationItem.title = @"Plan Item Detail";
        }
        else {
            self.navigationItem.title = @"Add to Log";
        }
    }
    else if ([dietmasterEngine.taskMode isEqualToString:@"Edit"]) {
        self.navigationItem.title = @"Edit Log";
    }
    else if ([dietmasterEngine.taskMode isEqualToString:@"AddMealPlanItem"]) {
        self.navigationItem.title = @"Add to Plan";
    }
    
    infoBtn.frame = CGRectMake(SCREEN_WIDTH - 25, lblProtein.frame.origin.y, infoBtn.frame.size.width, infoBtn.frame.size.height);
}

#pragma mark ACTION SHEET METHODS
- (void)showActionSheet:(id)sender {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    NSString *favoriteOrNot = nil;
    if (num_isFavorite == 0) {
        favoriteOrNot = @"Save as Favorite";
    } else {
        favoriteOrNot = @"Remove from Favorites";
    }

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Action" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if ([dietmasterEngine.taskMode isEqualToString:@"Save"]) {
        if (dietmasterEngine.isMealPlanItem) {
            [alert addAction:[UIAlertAction actionWithTitle:@"Add to Log"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                [self saveToLog:nil];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:favoriteOrNot
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                if (num_isFavorite == 0) {
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
                if (num_isFavorite == 0) {
                    [self saveToFavorites];
                } else {
                    [self confirmDeleteFromFavorite];
                }
            }]];

        }
    }
    
    if ([dietmasterEngine.taskMode isEqualToString:@"Edit"]) {
        [alert addAction:[UIAlertAction actionWithTitle:@"Save Changes"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            [self saveToLog:nil];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:favoriteOrNot
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            if (num_isFavorite == 0) {
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
    
    if ([dietmasterEngine.taskMode isEqualToString:@"AddMealPlanItem"]) {
        [alert addAction:[UIAlertAction actionWithTitle:@"Add to Plan"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            [self insertNewFood];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:favoriteOrNot
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            if (num_isFavorite == 0) {
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

-(void)confirmDeleteFromLog {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Remove from Log?"
                                                                   message:@"Are you sure you wish to remove this from the log?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes, Remove"
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self delLog:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Don't Remove" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

-(void)confirmDeleteFromFavorite {
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

#pragma mark MEAL PLAN METHODS

- (void)exchangeFood {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]  initWithTitle: @"Back" style: UIBarButtonItemStylePlain target: nil action: nil];
    [self.navigationItem setBackBarButtonItem: backButton];
    
    ExchangeFoodViewController *exchangeVC = [[ExchangeFoodViewController alloc] initWithExchangedFood:[self.foodDict copy]];
    [self.navigationController pushViewController:exchangeVC animated:YES];
}

- (void)updateFoodServings {
    [DMActivityIndicator showActivityIndicator];
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    int num_measureID = [[[pickerColumn3Array objectAtIndex:[pickerView selectedRowInComponent:cSection3]] valueForKey:@"MeasureID"] intValue];
    int foodID = [[self.foodDict valueForKey:@"FoodKey"] intValue];
    NSDecimalNumber *servingSize1 = [pickerColumn1Array objectAtIndex:[pickerView selectedRowInComponent:cSection1]];
    NSDecimalNumber *servingSize2;
    if (fractionPicker) {
        servingSize2 = [pickerFractionArray objectAtIndex:[pickerView selectedRowInComponent:cSection2]];
    } else {
        servingSize2 = [pickerDecimalArray objectAtIndex:[pickerView selectedRowInComponent:cSection2]];
    }
    NSDecimalNumber *servingAmount = [servingSize1 decimalNumberByAdding:servingSize2];
    
    NSDictionary *updateDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    @(dietmasterEngine.selectedMealPlanID), @"MealID",
                                    dietmasterEngine.selectedMealID, @"MealCode",
                                    @(foodID), @"FoodID",
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
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        dietmasterEngine.didInsertNewFood = YES;
    }];
}

-(void)insertNewFood {
    [DMActivityIndicator showActivityIndicator];
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    int num_measureID	= [[[pickerColumn3Array objectAtIndex:[pickerView selectedRowInComponent:cSection3]] valueForKey:@"MeasureID"] intValue];
    
    NSDecimalNumber *servingSize1	= [pickerColumn1Array objectAtIndex:[pickerView selectedRowInComponent:cSection1]];
    NSDecimalNumber *servingSize2;
    if (fractionPicker) {
        servingSize2	= [pickerFractionArray objectAtIndex:[pickerView selectedRowInComponent:cSection2]];
    }
    else {
        servingSize2	= [pickerDecimalArray objectAtIndex:[pickerView selectedRowInComponent:cSection2]];
    }
    NSDecimalNumber *servingAmount		= [servingSize1 decimalNumberByAdding:servingSize2];
    
    int foodID = [[self.foodDict valueForKey:@"FoodKey"] intValue];
    int mealCode = [dietmasterEngine.selectedMealID intValue];
    
    NSDictionary *insertDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSNumber numberWithInt:dietmasterEngine.selectedMealPlanID], @"MealID",
                                [NSNumber numberWithInt:mealCode], @"MealCode",
                                [NSNumber numberWithInt:foodID], @"FoodID",
                                [NSNumber numberWithInt:num_measureID], @"MeasureID",
                                servingAmount, @"ServingSize",
                                nil];
    
    DMMealPlanDataProvider *provider = [[DMMealPlanDataProvider alloc] init];
    __weak typeof(self) weakSelf = self;
    [provider saveUserPlannedMealItems:@[insertDict] withCompletionBlock:^(BOOL completed, NSError *error) {
        [DMActivityIndicator hideActivityIndicator];
        if (error) {
            [DMGUtilities showAlertWithTitle:@"Error" message:error.localizedDescription inViewController:nil];
            return;
        }
        
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        dietmasterEngine.didInsertNewFood = YES;
        [DMActivityIndicator showCompletedIndicator];
        [weakSelf.navigationController popToViewController:[[weakSelf.navigationController viewControllers] objectAtIndex:2] animated:YES];
    }];
}

- (void)deleteFromPlan {
    [DMActivityIndicator showActivityIndicator];

    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    int foodID = [[self.foodDict valueForKey:@"FoodKey"] intValue];
    int mealCode = [dietmasterEngine.selectedMealID intValue];
    
    NSDictionary *mealItems = [[NSDictionary alloc] initWithObjectsAndKeys:
                             @(dietmasterEngine.selectedMealPlanID), @"MealID",
                             @(mealCode), @"MealCode",
                             @(foodID), @"FoodID",
                             nil];
    
    DMMealPlanDataProvider *provider = [[DMMealPlanDataProvider alloc] init];
    __weak typeof(self) weakSelf = self;
    [provider deleteUserPlannedMealItems:@[mealItems] withCompletionBlock:^(BOOL completed, NSError *error) {
        [DMActivityIndicator hideActivityIndicator];
        if (error) {
            [DMGUtilities showAlertWithTitle:@"Error" message:error.localizedDescription inViewController:nil];
            return;
        }
        
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        dietmasterEngine.didInsertNewFood = YES;
        [DMActivityIndicator showCompletedIndicator];
        [weakSelf.navigationController popToViewController:[[weakSelf.navigationController viewControllers] objectAtIndex:2] animated:YES];
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
    double servingSize = [[self.foodDict valueForKey:@"ServingSize"] floatValue];
    double foodCalories = [[self.foodDict valueForKey:@"Calories"] floatValue];
    
    NSDecimalNumber *servingSize1	= [pickerColumn1Array objectAtIndex:[pickerView selectedRowInComponent:cSection1]];
    NSDecimalNumber *servingSize2;
    if (fractionPicker) {
        servingSize2	= [pickerFractionArray objectAtIndex:[pickerView selectedRowInComponent:cSection2]];
    }
    else {
        servingSize2	= [pickerDecimalArray objectAtIndex:[pickerView selectedRowInComponent:cSection2]];
    }
    NSDecimalNumber *servingAmount		= [servingSize1 decimalNumberByAdding:servingSize2];
    
    if (servingSize == 0){
        servingSize=1;
    }
    double flt_totalCalories	= foodCalories * ([servingAmount floatValue] * gramWeight  / 100 / servingSize);
    
    lblCalories.text = [NSString stringWithFormat:@"%.2f", flt_totalCalories];
    
    double foodProtein = [[self.foodDict valueForKey:@"Protein"] floatValue];
    double foodFat = [[self.foodDict valueForKey:@"Fat"] floatValue];
    double foodCarbs = [[self.foodDict valueForKey:@"Carbohydrates"] floatValue];
    
    lblFat.text			= [NSString stringWithFormat:@"%.2f",(foodFat * (gramWeight / 100)) / servingSize * [servingAmount floatValue]];
    lblCarbs.text		= [NSString stringWithFormat:@"%.2f",(foodCarbs * (gramWeight / 100))  / servingSize * [servingAmount floatValue]];
    lblProtein.text		= [NSString stringWithFormat:@"%.2f",(foodProtein * (gramWeight / 100))  / servingSize *[servingAmount floatValue]];
}

#pragma mark LOG METHODS
 
- (void)saveToLog:(id) sender {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
        return;
    }
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];

    int num_measureID = [[[pickerColumn3Array objectAtIndex:[pickerView selectedRowInComponent:cSection3]] valueForKey:@"MeasureID"] intValue];
    NSDecimalNumber *servingSize1 = [pickerColumn1Array objectAtIndex:[pickerView selectedRowInComponent:cSection1]];
    NSDecimalNumber *servingSize2;
    if (fractionPicker) {
        servingSize2 = [pickerFractionArray objectAtIndex:[pickerView selectedRowInComponent:cSection2]];
    } else {
        servingSize2 = [pickerDecimalArray objectAtIndex:[pickerView selectedRowInComponent:cSection2]];
    }
    NSDecimalNumber *servingAmount = [servingSize1 decimalNumberByAdding:servingSize2];
    
    if ([dietmasterEngine.taskMode isEqualToString:@"Save"]) {
        
        int mealIDValue = 0;
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
        [dateFormat setTimeZone:systemTimeZone];
        NSString *date_Today = [dateFormat stringFromDate:dietmasterEngine.dateSelected];
        
        NSString *mealIDQuery = [NSString stringWithFormat:@"SELECT MealID FROM Food_Log WHERE (MealDate BETWEEN DATETIME('%@ 00:00:00') AND DATETIME('%@ 23:59:59'))", date_Today, date_Today];
        FMResultSet *rsMealID = [db executeQuery:mealIDQuery];
        while ([rsMealID next]) {
            mealIDValue = [rsMealID intForColumn:@"MealID"];
        }
        [rsMealID close];
        int minIDvalue = 0;
        if (mealIDValue == 0) {
            NSString *idQuery = @"SELECT MIN(MealID) as MealID FROM Food_Log";
            FMResultSet *rsID = [db executeQuery:idQuery];
            while ([rsID next]) {
                minIDvalue = [rsID intForColumn:@"MealID"];
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
        }
        
        if (mealIDValue > 0 || mealIDValue < 0) {
            minIDvalue = mealIDValue;
        }
        
        int foodID = [[self.foodDict valueForKey:@"FoodKey"] intValue];
        int mealCode = [dietmasterEngine.selectedMealID intValue];
        
        [db beginTransaction];
        
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        systemTimeZone = [NSTimeZone systemTimeZone];
        [dateFormat setTimeZone:systemTimeZone];
        NSString *date_string = [dateFormat stringFromDate:dietmasterEngine.dateSelected];

        NSString *insertSQL = [NSString stringWithFormat: @"REPLACE INTO Food_Log (MealID, MealDate) VALUES (%i, DATETIME('%@'))", minIDvalue, date_string];
        [db executeUpdate:insertSQL];
        
        int mealID = minIDvalue;
        
        NSString *strChkRecord = [NSString stringWithFormat:@"SELECT count(*) FROM Food_Log_Items where FoodID = '%d' AND MealCode = '%d'AND MealID = '%d'",foodID,mealCode,mealID];
        FMResultSet *objChk = [db executeQuery:strChkRecord];
        while ([objChk next]) {
            if ([objChk intForColumn:@"count(*)"] > 0) {
            } else {
                NSDate* sourceDate = [NSDate date];
                [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *date_string1 = [dateFormat stringFromDate:sourceDate];
                
                insertSQL = [NSString stringWithFormat: @"REPLACE INTO Food_Log_Items "
                             "(MealID, FoodID, MealCode, MeasureID, NumberOfServings, LastModified) "
                             " VALUES (%i, %i, %i, %i, %f, DATETIME('%@'))",
                             mealID, foodID, mealCode, num_measureID, [servingAmount floatValue], date_string1];
                [db executeUpdate:insertSQL];
            }
        }
        
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
        [DMActivityIndicator showCompletedIndicator];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:nil];
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];

    } else if ([dietmasterEngine.taskMode isEqualToString:@"Edit"]) {
        
        [db beginTransaction];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        NSString *date_string = [dateFormat stringFromDate:[NSDate date]];
        
        int foodMealID = [[self.foodDict valueForKey:@"FoodLogMealID"] intValue];
        int foodID = [[self.foodDict valueForKey:@"FoodKey"] intValue];
        int MealCode  = [dietmasterEngine.selectedMealID intValue];
        
        NSString *updateSQL = [NSString stringWithFormat: @"UPDATE Food_Log_Items SET MeasureID = %i, NumberOfServings = %f, LastModified = '%@' WHERE FoodID = %i AND MealID = %i AND MealCode = %i", num_measureID,[servingAmount floatValue], date_string, foodID,foodMealID ,MealCode];
        [db executeUpdate:updateSQL];
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
        
        [DMActivityIndicator showCompletedIndicator];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:nil];
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
    }
}

- (IBAction)delLog:(id)sender {
    [self deleteFromWSLog];
}

- (void)deleteFromLog {
    DietmasterEngine *dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }
    
    [db beginTransaction];
    int foodMealID = [[self.foodDict valueForKey:@"FoodLogMealID"] intValue];
    int foodID = [[self.foodDict valueForKey:@"FoodKey"] intValue];
    NSString *updateSQL = [NSString stringWithFormat: @"DELETE FROM Food_Log_Items WHERE FoodID = %i AND MealID = %i AND MealCode = %i", foodID, foodMealID, [dietmasterEngine.selectedMealID intValue]];
    [db executeUpdate:updateSQL];
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
    
    [DMActivityIndicator hideActivityIndicator];
    [DMActivityIndicator showCompletedIndicator];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteFromFavorites {
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
        return;
    }
    
    int foodID = [[self.foodDict valueForKey:@"FoodKey"] intValue];
    [db beginTransaction];
    NSString *updateSQL = [NSString stringWithFormat: @"DELETE FROM Favorite_Food WHERE FoodID = %i", foodID];
    [db executeUpdate:updateSQL];
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
    
    num_isFavorite = 0;
    
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
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:nil];
    }];
}

- (void)saveToFavorites {
    DietmasterEngine *dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
        return;
    }
    
    int foodID = [[self.foodDict valueForKey:@"FoodKey"] intValue];
    int num_measureID = [[self.foodDict valueForKey:@"MeasureID"] intValue];
    
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
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone *systemTimeZone = [NSTimeZone systemTimeZone];
    [dateFormatter setTimeZone:systemTimeZone];
    NSString *date_string = [dateFormatter stringFromDate:dietmasterEngine.dateSelected];

    NSString *insertSQL = [NSString stringWithFormat: @"REPLACE INTO Favorite_Food (Favorite_FoodID, FoodID,modified,MeasureID) VALUES (%i, %i,DATETIME('%@'),%i)", minIDvalue, foodID, date_string, num_measureID];
    [db executeUpdate:insertSQL];
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
    
    num_isFavorite = 1;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:nil];
    [DMActivityIndicator showCompletedIndicator];
}

- (void)deleteFromWSLog {
    [DMActivityIndicator showActivityIndicator];
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    int foodLogID = [[self.foodDict valueForKey:@"FoodLogMealID"] intValue];
    int foodID = [[self.foodDict valueForKey:@"FoodKey"] intValue];
    
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"DeleteMealItem", @"RequestType",
                                [NSNumber numberWithInt:foodLogID], @"MealID",
                                dietmasterEngine.selectedMealID, @"MealCode",
                                [NSNumber numberWithInt:foodID], @"FoodID",
                                nil];
    
    [DMDataFetcher fetchDataWithRequestParams:infoDict completion:^(NSObject *object, NSError *error) {
        if (error) {
            [DMActivityIndicator hideActivityIndicator];
            [DMGUtilities showAlertWithTitle:@"Error" message:error.localizedDescription inViewController:nil];
            return;
        }
        [self deleteFromLog];
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
