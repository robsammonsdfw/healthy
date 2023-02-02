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

@implementation DetailViewController

@synthesize pickerColumn1Array, pickerColumn3Array;
@synthesize pickerRow1, pickerRow2, pickerRow3;
@synthesize pickerDecimalArray, pickerFractionArray;

#pragma mark DATA METHODS
-(void)loadData {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
        
    }
    
    double gramWeight = [[dietmasterEngine.foodSelectedDict valueForKey:@"GramWeight"] floatValue];
    double foodProtein = [[dietmasterEngine.foodSelectedDict valueForKey:@"Protein"] floatValue];
    double foodFat = [[dietmasterEngine.foodSelectedDict valueForKey:@"Fat"] floatValue];
    double foodCarbs = [[dietmasterEngine.foodSelectedDict valueForKey:@"Carbohydrates"] floatValue];
    double servingSize = [[dietmasterEngine.foodSelectedDict valueForKey:@"ServingSize"] floatValue];
    double foodCalories = [[dietmasterEngine.foodSelectedDict valueForKey:@"Calories"] floatValue];
    double selectedServing = [[dietmasterEngine.foodSelectedDict valueForKey:@"Servings"] floatValue];
    
    int foodID = [[dietmasterEngine.foodSelectedDict valueForKey:@"FoodKey"] intValue];
//    _foodIdLbl.text = _foodIdValue;
    
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
        [dict release];
    }

    
    FMResultSet *rs = [db executeQuery:query];
    while ([rs next]) {
        num_isFavorite		= [rs intForColumn:@"favCount"];
        
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithInt:[rs intForColumn:@"MeasureID"]], @"MeasureID",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"GramWeight"]], @"GramWeight",
                              [rs stringForColumn:@"Description"], @"Description", nil];
        [pickerColumn3Array addObject:dict];
        
        rowListArr = [[NSMutableArray alloc]initWithArray:[self filterObjectsByKeys:@"MeasureID" array:pickerColumn3Array]];
        pickerColumn3Array = rowListArr;

        
        [dict release];
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
    
    NSString *servingList		= [NSString stringWithFormat:@"%.2f", [[dietmasterEngine.foodSelectedDict valueForKey:@"Servings"] floatValue]];
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
                self.pickerRow2 = [NSNumber numberWithInt:i];
                break;
            }
        }
        
        for(NSInteger i = 0; i < [pickerFractionArray count]; i++){
            double pickerValue = [[pickerFractionArray objectAtIndex:i] floatValue];
            
            if(pickerValue == pickerCompare){
                fractionPicker = YES;
                [pickerView reloadAllComponents];
                decimalButton.style = UIBarButtonItemStylePlain;
                fractionButton.style = UIBarButtonItemStyleDone;
                self.pickerRow2 = [NSNumber numberWithInt:i];
                break;
            }
        }
        
        [pickerView selectRow:[pickerRow2 intValue] inComponent:1 animated:YES];
    }
    
    int measureID = [[dietmasterEngine.foodSelectedDict valueForKey:@"MeasureID"] intValue];
    for(NSInteger i = 0; i < [pickerColumn3Array count]; i++){
        int pickerID = [[[pickerColumn3Array objectAtIndex:i] valueForKey:@"MeasureID"] intValue];
        if(pickerID == measureID){
            self.pickerRow3 = [NSNumber numberWithInt:i];
            break;
        }
    }
    
    [pickerView selectRow:[pickerRow3 intValue] inComponent:2 animated:YES];
    
    [self performSelector:@selector(updateCalorieCount) withObject:nil afterDelay:0.50];
    
    [self hideLoading];
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
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    lblText.text		= [dietmasterEngine.foodSelectedDict valueForKey:@"Name"];
    
    UIImage* image3 = [UIImage imageNamed:@"menuscan.png"];
    UIButton *urButton = [UIButton buttonWithType:UIButtonTypeCustom];
    urButton.frame = CGRectMake(0, 0, 30, 30);
    [urButton setBackgroundImage:image3 forState:UIControlStateNormal];
    [urButton addTarget:self action:@selector(showActionSheet:)
       forControlEvents:UIControlEventTouchUpInside];
    urButton.clipsToBounds = YES;
    urButton.layer.cornerRadius =3;
    urButton.layer.borderColor=[UIColor blackColor].CGColor;
    urButton.layer.borderWidth=0.8f;
    UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithCustomView:urButton];
    self.navigationItem.rightBarButtonItem=doneButton;
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:PLIST_NAME];
    NSDictionary *appDefaults = [[[NSDictionary alloc] initWithContentsOfFile:finalPath] autorelease];
    
    UIImageView *backgroundImage = (UIImageView *)[self.view viewWithTag:501];
    if ([[appDefaults valueForKey:@"account_code"] isEqualToString:@"ezdietplanner"]) {
        backgroundImage.image = [UIImage imageNamed:@"Food_Detail_Screen"];
        pickerView.backgroundColor = [UIColor whiteColor];
    }
    
    [self.navigationController.navigationBar setTranslucent:NO];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self showLoading];
    [self performSelector:@selector(loadData) withObject:nil afterDelay:0.25];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cleanUpView) name:@"CleanUpView" object:nil];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    if ([dietmasterEngine.taskMode isEqualToString:@"AddMealPlanItem"]) {
        lblMealName.text	= @"Add item to Plan";
    }
    else {
        if (![[[NSUserDefaults standardUserDefaults]objectForKey:@"isddmm"] boolValue]) {
            lblMealName.text	= [NSString stringWithFormat: @"Log Date: %@", dietmasterEngine.dateSelectedFormatted];
        }
        else{
            NSString *strDate = dietmasterEngine.dateSelectedFormatted;
            NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
            NSDateFormatter *dateFormat_display = [[NSDateFormatter alloc] init];
            [dateFormat_display setDateFormat:@"MMMM d, yyyy"];
            [dateFormat_display setTimeZone:systemTimeZone];
            NSDate *date = [dateFormat_display dateFromString:strDate];
            
            if (date) {
                [dateFormat_display setDateFormat:@"d MMMM, yyyy"];
                NSString *strFinal = [dateFormat_display stringFromDate:date];
                lblMealName.text	= [NSString stringWithFormat: @"Log Date: %@", strFinal];
            }
            else{
                lblMealName.text	= [NSString stringWithFormat: @"Log Date: %@", dietmasterEngine.dateSelectedFormatted];
            }
        }
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CleanUpView" object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    if([dietmasterEngine.taskMode isEqualToString:@"Save"]) {
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

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark ACTION SHEET METHODS
-(void)showActionSheet:(id)sender {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    
    UIActionSheet *popupQuery = nil;
    NSString *favoriteOrNot = nil;
    if (num_isFavorite == 0) {
        favoriteOrNot = @"Save as Favorite";
    } else {
        favoriteOrNot = @"Remove from Favorites";
    }
    
    if ([dietmasterEngine.taskMode isEqualToString:@"Save"]) {
        if (dietmasterEngine.isMealPlanItem) {
            popupQuery = [[UIActionSheet alloc] initWithTitle:@"Select Action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add to Log", favoriteOrNot, @"Exchange Food", @"Save Changes",  @"Remove from Plan", nil];
        }
        else {
            popupQuery = [[UIActionSheet alloc] initWithTitle:@"Select Action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add to Log", favoriteOrNot, nil];
        }
    }
    
    if ([dietmasterEngine.taskMode isEqualToString:@"Edit"]) {
        popupQuery = [[UIActionSheet alloc] initWithTitle:@"Select Action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save Changes", favoriteOrNot, @"Remove from Log", nil];
    }
    
    if ([dietmasterEngine.taskMode isEqualToString:@"AddMealPlanItem"]) {
        popupQuery = [[UIActionSheet alloc] initWithTitle:@"Select Action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add to Plan", favoriteOrNot, nil];
    }
    
    popupQuery.tag = 10;
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:[UIApplication sharedApplication].keyWindow];
    [popupQuery release];
}

-(void)confirmDeleteFromLog {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Remove from Log?" delegate:self cancelButtonTitle:@"Don't Remove" destructiveButtonTitle:@"Yes, Remove" otherButtonTitles:nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    actionSheet.tag = 5;
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    [actionSheet release];
}

-(void)confirmDeleteFromFavorite {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Remove from Favorites?" delegate:self cancelButtonTitle:@"Don't Remove" destructiveButtonTitle:@"Yes, Remove" otherButtonTitles:nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    actionSheet.tag = 1;
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    [actionSheet release];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];

    if (actionSheet.tag == 10) {
        if (buttonIndex == 0) {
            if([dietmasterEngine.taskMode isEqualToString:@"Edit"] || [dietmasterEngine.taskMode isEqualToString:@"Save"]) {
                [self saveToLog:nil];
            }
            
            if([dietmasterEngine.taskMode isEqualToString:@"AddMealPlanItem"]) {
                [self insertNewFood];
            }
        }
        else if (buttonIndex == 1) {
            if (num_isFavorite == 0) {
                [self saveToFavorites];
            }
            else {
                [self confirmDeleteFromFavorite];
            }
        }
        else if (buttonIndex == 2) {
            if([dietmasterEngine.taskMode isEqualToString:@"Edit"]) {
                [self confirmDeleteFromLog];
                
            }
            else {
                if(![dietmasterEngine.taskMode isEqualToString:@"AddMealPlanItem"]) {
                    if (dietmasterEngine.isMealPlanItem) {
                        [self exchangeFood];
                    }
                }
            }
        }
        else if (buttonIndex == 3) {
            if (dietmasterEngine.isMealPlanItem) {
                [self updateFoodServings];
            }
        }
        else if (buttonIndex == 4) {
            if (dietmasterEngine.isMealPlanItem) {
                [self deleteFromPlan];
            }
        }
    }
    else if (actionSheet.tag == 5) {
        if (buttonIndex == 0) {
            [self delLog:nil];
        }
        else if (buttonIndex == 1) {
        }
    }
    else if (actionSheet.tag == 1) {
        if (buttonIndex == 0) {
            [self deleteFromFavorites];
        }
        else if (buttonIndex == 1) {
        }
    }
}

#pragma mark CLEAN UP METHODS
-(void)cleanUpView {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark MEAL PLAN METHODS

-(void)exchangeFood {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]  initWithTitle: @"Back" style: UIBarButtonItemStylePlain target: nil action: nil];
    [self.navigationItem setBackBarButtonItem: backButton];
    [backButton release];
    
    DietmasterEngine *dietmasterEngine = [DietmasterEngine instance];
    NSMutableDictionary *exchangeDict = dietmasterEngine.foodSelectedDict;
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    ExchangeFoodViewController *exchangeVC = [[ExchangeFoodViewController alloc] init];
    exchangeVC.hidesBottomBarWhenPushed = YES;
    exchangeVC.foodID = [exchangeDict valueForKey:@"FoodID"];
    exchangeVC.mealTypeID = [exchangeDict valueForKey:@"MealTypeID"];
    exchangeVC.CaloriesToMaintain = [lblCalories.text doubleValue];
    exchangeVC.ExchangeOldDataDict = exchangeDict;
    [self.navigationController pushViewController:exchangeVC animated:YES];
    [exchangeVC release];
}

-(void)updateFoodServings {
    [self showLoading];
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    
    int num_measureID	= [[[pickerColumn3Array objectAtIndex:[pickerView selectedRowInComponent:cSection3]] valueForKey:@"MeasureID"] intValue];
    int foodID = [[dietmasterEngine.foodSelectedDict valueForKey:@"FoodKey"] intValue];
    NSDecimalNumber *servingSize1	= [pickerColumn1Array objectAtIndex:[pickerView selectedRowInComponent:cSection1]];
    NSDecimalNumber *servingSize2;
    if (fractionPicker) {
        servingSize2	= [pickerFractionArray objectAtIndex:[pickerView selectedRowInComponent:cSection2]];
    }
    else {
        servingSize2	= [pickerDecimalArray objectAtIndex:[pickerView selectedRowInComponent:cSection2]];
    }
    NSDecimalNumber *servingAmount		= [servingSize1 decimalNumberByAdding:servingSize2];
    
    NSDictionary *updateDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSNumber numberWithInt:dietmasterEngine.selectedMealPlanID], @"MealID",
                                dietmasterEngine.selectedMealID, @"MealCode",
                                [NSNumber numberWithInt:foodID], @"FoodID",
                                servingAmount, @"ServingSize",
                                [NSNumber numberWithInt:num_measureID], @"MeasureID",
                                nil];
    
    for (id key in updateDict) {
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *wsInfoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"UpdateUserPlannedMealItems", @"RequestType",
                                [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                                [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                                updateDict, @"MealItems",
                                nil];
    
    MealPlanWebService *soapWebService = [[MealPlanWebService alloc] init];
    soapWebService.wsUpdateUserPlannedMealItems = self;
    [soapWebService callWebservice:wsInfoDict];
    [soapWebService release];
    
    [wsInfoDict release];
    [updateDict release];
}

-(void)insertNewFood {
    [self showLoading];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    
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
    
    int foodID = [[dietmasterEngine.foodSelectedDict valueForKey:@"FoodKey"] intValue];
    int mealCode = [dietmasterEngine.selectedMealID intValue];
    
    NSDictionary *insertDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSNumber numberWithInt:dietmasterEngine.selectedMealPlanID], @"MealID",
                                [NSNumber numberWithInt:mealCode], @"MealCode",
                                [NSNumber numberWithInt:foodID], @"FoodID",
                                [NSNumber numberWithInt:num_measureID], @"MeasureID",
                                servingAmount, @"ServingSize",
                                nil];
    
    for (id key in insertDict) {
    }
    
    NSDictionary *wsInfoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"InsertUserPlannedMealItems", @"RequestType",
                                [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                                [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                                insertDict, @"MealItems",
                                nil];
    
    MealPlanWebService *soapWebService2 = [[MealPlanWebService alloc] init];
    soapWebService2.wsInsertUserPlannedMealItems = self;
    [soapWebService2 callWebservice:wsInfoDict];
    [soapWebService2 release];
    
    [insertDict release];
    [wsInfoDict release];
}

-(void)deleteFromPlan {
    [self showLoading];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    
    int foodID = [[dietmasterEngine.foodSelectedDict valueForKey:@"FoodKey"] intValue];
    int mealCode = [dietmasterEngine.selectedMealID intValue];
    
    
    NSDictionary *newDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                             [NSNumber numberWithInt:dietmasterEngine.selectedMealPlanID], @"MealID",
                             [NSNumber numberWithInt:mealCode], @"MealCode",
                             [NSNumber numberWithInt:foodID], @"FoodID",
                             nil];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"DeleteUserPlannedMealItems", @"RequestType",
                              [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                              [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                              newDict, @"MealItems",
                              nil];
    
    MealPlanWebService *soapWebService = [[MealPlanWebService alloc] init];
    soapWebService.wsDeleteUserPlannedMealItems = self;
    [soapWebService callWebservice:infoDict];
    [soapWebService release];
    
    [infoDict release];
    [newDict release];
}

#pragma mark MEAL PLAN WEBSERVICE DELEGATES

- (void)updateUserPlannedMealItemsFinished:(NSMutableArray *)responseArray {
    [self hideLoading];
    [self showCompleted];
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    dietmasterEngine.didInsertNewFood = YES;
}

- (void)updateUserPlannedMealItemsFailed:(NSString *)failedMessage {
    [self hideLoading];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"An error occurred. Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert setTag:200];
    [alert show];
    [alert release];
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

-(void)updateCalorieCount {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    double gramWeight = [[[pickerColumn3Array objectAtIndex:[pickerView selectedRowInComponent:cSection3]] valueForKey:@"GramWeight"] floatValue];
    double servingSize = [[dietmasterEngine.foodSelectedDict valueForKey:@"ServingSize"] floatValue];
    double foodCalories = [[dietmasterEngine.foodSelectedDict valueForKey:@"Calories"] floatValue];
    
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
    
    double foodProtein = [[dietmasterEngine.foodSelectedDict valueForKey:@"Protein"] floatValue];
    double foodFat = [[dietmasterEngine.foodSelectedDict valueForKey:@"Fat"] floatValue];
    double foodCarbs = [[dietmasterEngine.foodSelectedDict valueForKey:@"Carbohydrates"] floatValue];
    
    lblFat.text			= [NSString stringWithFormat:@"%.2f",(foodFat * (gramWeight / 100)) / servingSize * [servingAmount floatValue]];
    lblCarbs.text		= [NSString stringWithFormat:@"%.2f",(foodCarbs * (gramWeight / 100))  / servingSize * [servingAmount floatValue]];
    lblProtein.text		= [NSString stringWithFormat:@"%.2f",(foodProtein * (gramWeight / 100))  / servingSize *[servingAmount floatValue]];
}

#pragma mark LOG METHODS
-(void) saveToLog:(id) sender {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    
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
    
    if([dietmasterEngine.taskMode isEqualToString:@"Save"]) {
        
        int mealIDValue = 0;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        
        NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
        [dateFormat setTimeZone:systemTimeZone];
        NSString *date_Today = [dateFormat stringFromDate:dietmasterEngine.dateSelected];
//        [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]]; // Prevent adjustment to user's local time zone.
//
//        NSString *date_Today = [dateFormat stringFromDate:[NSDate date]];

        
        
        [dateFormat release];
        
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
        
        int foodID = [[dietmasterEngine.foodSelectedDict valueForKey:@"FoodKey"] intValue];
        int mealCode = [dietmasterEngine.selectedMealID intValue];
        
        [db beginTransaction];
        
        NSDate* sourceDate = [NSDate date];

        
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        systemTimeZone = [NSTimeZone systemTimeZone];
        [dateFormatter setTimeZone:systemTimeZone];
//        NSString *date_string = [dateFormatter stringFromDate:dietmasterEngine.dateSelected];
//        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]]; // Prevent adjustment to user's local time zone.
        
        NSString *date_string = [dateFormatter stringFromDate:dietmasterEngine.dateSelected];


        NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO Food_Log (MealID, MealDate) VALUES (%i, DATETIME('%@'))", minIDvalue, date_string];
        [db executeUpdate:insertSQL];
        
        int mealID = minIDvalue;
        
        NSString *strChkRecord = [NSString stringWithFormat:@"select count(*) from Food_Log_Items where FoodID = '%d' AND MealCode = '%d'AND MealID = '%d'",foodID,mealCode,mealID];
        FMResultSet *objChk = [db executeQuery:strChkRecord];
        while ([objChk next]) {
            if ([objChk intForColumn:@"count(*)"]>0) {
                NSLog(@"%d",[objChk intForColumn:@"count(*)"]);
                NSLog(@"Skip...");
            }
            else{
                
                NSDate* sourceDate = [NSDate date];
                NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//                [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]]; // Prevent adjustment to user's local time zone.
                NSString *date_string1 = [dateFormatter stringFromDate:sourceDate];
                
                insertSQL = [NSString stringWithFormat: @"INSERT INTO Food_Log_Items "
                             "(MealID, FoodID, MealCode, MeasureID, NumberOfServings, LastModified) "
                             " VALUES (%i, %i, %i, %i, %f, DATETIME('%@'))",
                             mealID, foodID, mealCode, num_measureID, [servingAmount floatValue], date_string1];
                [db executeUpdate:insertSQL];
            }
        }
        
        if ([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
        [self performSelector:@selector(showCompleted) withObject:nil afterDelay:0.25];
        
//        if (dietmasterEngine.isMealPlanItem) {
//            [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
//        }
//        else {
//            [self.navigationController popToRootViewControllerAnimated:YES];
//        }
        
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:2] animated:YES];

    }
    else if ([dietmasterEngine.taskMode isEqualToString:@"Edit"]) {
        
        [db beginTransaction];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

        [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        
        NSString *date_string = [dateFormat stringFromDate:[NSDate date]];

        
        int foodMealID = [[dietmasterEngine.foodSelectedDict valueForKey:@"FoodLogMealID"] intValue];
        int foodID = [[dietmasterEngine.foodSelectedDict valueForKey:@"FoodKey"] intValue];
        int MealCode  = [dietmasterEngine.selectedMealID intValue];
        
        NSString *updateSQL = [NSString stringWithFormat: @"UPDATE Food_Log_Items SET MeasureID = %i, NumberOfServings = %f, LastModified = '%@' WHERE FoodID = %i AND MealID = %i AND MealCode = %i", num_measureID,[servingAmount floatValue], date_string, foodID,foodMealID ,MealCode];
        
        
        [db executeUpdate:updateSQL];
        
        if ([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
        
        [self performSelector:@selector(showCompleted) withObject:nil afterDelay:0.25];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:nil];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(IBAction) delLog:(id) sender {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    [self deleteFromWSLog];
    [self deleteFromLog];
}

-(void)deleteFromLog {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    
    [db beginTransaction];
    
    int foodMealID = [[dietmasterEngine.foodSelectedDict valueForKey:@"FoodLogMealID"] intValue];
    int foodID = [[dietmasterEngine.foodSelectedDict valueForKey:@"FoodKey"] intValue];
    NSString *updateSQL = [NSString stringWithFormat: @"DELETE FROM Food_Log_Items WHERE FoodID = %i AND MealID = %i AND MealCode = %i", foodID,foodMealID,[dietmasterEngine.selectedMealID intValue]];
    [db executeUpdate:updateSQL];
    
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
    
    [self hideLoading];
    [self performSelector:@selector(showCompleted) withObject:nil afterDelay:0.25];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) deleteFromFavorites {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    
    int foodID = [[dietmasterEngine.foodSelectedDict valueForKey:@"FoodKey"] intValue];
    
    [db beginTransaction];
    
    NSString *updateSQL = [NSString stringWithFormat: @"DELETE FROM Favorite_Food WHERE FoodID = %i", foodID];
    
    
    [db executeUpdate:updateSQL];
    
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
    
    num_isFavorite = 0;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *wsInfoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"DeleteFavoriteFood", @"RequestType",
                                [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                                [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                                [NSNumber numberWithInt:foodID], @"FoodID",
                                nil];
    SoapWebServiceEngine *soapWebService = [[SoapWebServiceEngine alloc] init];
    [soapWebService callWebservice:wsInfoDict];
    [soapWebService release];
    [wsInfoDict release];
    
    [self performSelector:@selector(showCompleted) withObject:nil afterDelay:0.25];
    
}

-(void)saveToFavorites {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    
    int foodID = [[dietmasterEngine.foodSelectedDict valueForKey:@"FoodKey"] intValue];
    int num_measureID = [[dietmasterEngine.foodSelectedDict valueForKey:@"MeasureID"] intValue];
    
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
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSTimeZone *systemTimeZone = [NSTimeZone systemTimeZone];
    [dateFormatter setTimeZone:systemTimeZone];
    NSString *date_string = [dateFormatter stringFromDate:dietmasterEngine.dateSelected];
    
//    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]]; // Prevent adjustment to user's local time zone.
    
//    NSString *date_string = [dateFormatter stringFromDate:[NSDate date]];

    NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO Favorite_Food (Favorite_FoodID, FoodID,modified,MeasureID) VALUES (%i, %i,DATETIME('%@'),%i)", minIDvalue, foodID, date_string, num_measureID];
    
    NSLog(@"Save insertSQL for DetailView is %@", insertSQL);
    
    [db executeUpdate:insertSQL];
    
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
    
    num_isFavorite = 1;
    [self performSelector:@selector(showCompleted) withObject:nil afterDelay:0.25];
}

-(void)deleteFromWSLog {
    [self showLoading];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    
    int foodLogID = [[dietmasterEngine.foodSelectedDict valueForKey:@"FoodLogMealID"] intValue];
    int foodID = [[dietmasterEngine.foodSelectedDict valueForKey:@"FoodKey"] intValue];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *wsInfoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"DeleteMealItem", @"RequestType",
                                [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                                [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                                [NSNumber numberWithInt:foodLogID], @"MealID",
                                dietmasterEngine.selectedMealID, @"MealCode",
                                [NSNumber numberWithInt:foodID], @"FoodID",
                                nil];
    
    for (id key in wsInfoDict) {
    }
    
    SoapWebServiceEngine *soapWebService = [[SoapWebServiceEngine alloc] init];
    soapWebService.wsDeleteMealItemDelegate = self;
    [soapWebService callWebservice:wsInfoDict];
    [soapWebService release];
    [wsInfoDict release];
}

#pragma mark MEMORY METHODS
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//- (void)viewDidUnload {
//    [super viewDidUnload];
//    
//    lblText  = nil;
//    lblMealName  = nil;
//    pickerView  = nil;
//    lblCalories  = nil;
//    lblProtein  = nil;
//    lblCarbs  = nil;
//    lblFat  = nil;
//    pickerView = nil;
//    
//    pickerColumn1Array = nil;
//    pickerColumn3Array = nil;
//    pickerDecimalArray = nil;
//    pickerFractionArray = nil;
//}

- (void)dealloc {
    [_imgbar release];
    [_staticCalLbl release];
    [_staticProtFatCarbLbl release];
    [_foodIdLbl release];
    
    lblText  = nil;
    lblMealName  = nil;
    pickerView  = nil;
    lblCalories  = nil;
    lblProtein  = nil;
    lblCarbs  = nil;
    lblFat  = nil;
    pickerView = nil;
    
    pickerColumn1Array = nil;
    pickerColumn3Array = nil;
    pickerDecimalArray = nil;
    pickerFractionArray = nil;

    [super dealloc];
}

#pragma mark WEBSERVICE INSERT MEAL ITEM DELEGATE
- (void)insertUserPlannedMealItemsFinished:(NSMutableArray *)responseArray {
    [self hideLoading];
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    dietmasterEngine.didInsertNewFood = YES;
    [self performSelector:@selector(showCompleted) withObject:nil afterDelay:0.25];
    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:2] animated:YES];
}

- (void)insertUserPlannedMealItemsFailed:(NSString *)failedMessage {
    [self hideLoading];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"An error occurred. Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert setTag:200];
    [alert show];
    [alert release];
}

#pragma mark DELETE MEAL PLAN ITEMS DELEGATE
- (void)deleteUserPlannedMealItemsFinished:(NSMutableArray *)responseArray {
    [self hideLoading];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    dietmasterEngine.didInsertNewFood = YES;
    [self performSelector:@selector(showCompleted) withObject:nil afterDelay:0.25];
    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:2] animated:YES];
}

- (void)deleteUserPlannedMealItemsFailed:(NSString *)failedMessage {
    [self hideLoading];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"An error occurred. Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert setTag:200];
    [alert show];
    [alert release];
}

#pragma mark WEBSERVICE DELETE MEAL ITEM DELEGATE
- (void)deleteMealItemFinished:(NSMutableArray *)responseArray {
    [self hideLoading];
    [self deleteFromLog];
}

- (void)deleteMealItemFailed:(NSString *)failedMessage {
    [self hideLoading];
}

#pragma mark WEBSERVICE DELETE FAVORITE FOOD DELEGATE
- (void)deleteFavoriteFoodFinished:(NSMutableArray *)responseArray {
    
}
- (void)deleteFavoriteFoodFailed:(NSString *)failedMessage {
    NSLog(@"deleteFavoriteFoodFailed");
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods
-(void)showLoading {
    HUD = [[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES] retain];
}

-(void)hideLoading {
    [HUD hide:YES afterDelay:0.5];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    [HUD removeFromSuperview];
    [HUD release];
    HUD = nil;
}

- (void)showCompleted {
    HUD = [[MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES] retain];
    HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
    HUD.mode = MBProgressHUDModeCustomView;
    
    HUD.delegate = nil;
    HUD.labelText = @"Completed";
    
    [HUD show:YES];
    [HUD hide:YES afterDelay:1.0];
}

#pragma mark CUSTOM SUPERSCRIPT NSSTRING METHOD
-(NSString *)superScriptOf:(NSString *)inputNumber {
    
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

-(NSString *)subScriptOf:(NSString *)inputNumber {
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
    [tempValues release];
    return ret;
}

-(IBAction)goToSafetyGuidelines:(id)sender {
    SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://advancedwebservicegroup.com/AWSGDocuments/GuidelinesAndSafety.html"]];
    [self presentViewController:sfvc animated:YES completion:nil];
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
