//
//  ExercisesDetailViewController.m
//  DietMasterGo
//
//  Created by Henry Kirk on 2/4/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import "ExercisesDetailViewController.h"
#import <HealthKit/HealthKit.h>
#import "StepData.h"

@interface ExercisesDetailViewController ()
{
    //HHT apple watch
    double stepCount;
    double calories;
    UIBarButtonItem* rightButton;
}

//HHT apple watch
@property(nonatomic,retain) HKHealthStore *healthStore;
@property(nonatomic, strong) NSMutableArray *arrData;
@property(nonatomic, strong) NSSet *readDataTypes;
@property(nonatomic, strong) StepData * sd;

@end

@implementation ExercisesDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(id)init {
    self = [super initWithNibName:@"ExercisesDetailViewController" bundle:nil];
    return self;
}

#pragma mark DATA METHODS
-(void)loadData {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:PLIST_NAME];
    NSDictionary *appDefaults = [[[NSDictionary alloc] initWithContentsOfFile:finalPath] autorelease];
    
    NSString *appName = [appDefaults valueForKey:@"app_name_long"];
    [permissionBtn setTitle:[NSString stringWithFormat:@"Allow %@ to access Apple Heath data.", appName] forState:UIControlStateNormal];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    exerciseNameLabel.text = [dietmasterEngine.exerciseSelectedDict valueForKey:@"ActivityName"];
    
    [self hideLoading];
    
    int exerciseIDTemp = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"ExerciseID"] intValue];
    
    if (exerciseIDTemp == 257 || exerciseIDTemp == 267 || exerciseIDTemp == 268 || exerciseIDTemp == 269 || exerciseIDTemp == 275){
        int caloriesOverride = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"Exercise_Time_Minutes"] intValue];
        if (caloriesOverride != 0)
            tfCalories.text = [NSString stringWithFormat:@"%d", caloriesOverride];
        [pickerView selectRow:caloriesOverride inComponent:0 animated:YES];
    }
    else if (exerciseIDTemp == 259 || exerciseIDTemp == 276) {
        lblCaloriesBurnedTitle.text = @"Step Count";
        int stepsTaken = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"Exercise_Time_Minutes"] intValue];
        if (stepsTaken != 0)
            tfCalories.text = [NSString stringWithFormat:@"%d", stepsTaken];
        [pickerView selectRow:stepsTaken inComponent:0 animated:YES];
    }
    else if (exerciseIDTemp == 272 || exerciseIDTemp == 274 ){
        
    }
    else {
        int totalTime = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"Exercise_Time_Minutes"] intValue];
        int hours = totalTime / 60;
        int minutes = (totalTime % 60);
        
        [pickerView selectRow:hours inComponent:0 animated:YES];
        [pickerView selectRow:minutes inComponent:1 animated:YES];
    }
    
    [pickerView reloadAllComponents];
    
    [self performSelector:@selector(updateCalorieLabel) withObject:nil afterDelay:0.50];
        
    UIImageView *backgroundImage = (UIImageView *)[self.view viewWithTag:501];
    if ([[appDefaults valueForKey:@"account_code"] isEqualToString:@"ezdietplanner"]) {
        backgroundImage.image = [UIImage imageNamed:@"Food_Detail_Screen"];
        pickerView.backgroundColor = [UIColor whiteColor];
    }
}

#pragma mark VIEW LIFECYCLE
- (void)viewDidLoad {
    [super viewDidLoad];
    
    lblCaloriesBurnedTitle.textColor = PrimaryFontColor;
    caloriesBurnedLabel.textColor = PrimaryFontColor;
    tfCalories.textColor = PrimaryFontColor;

    //HHT apple watch start
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    int exerciseIDTemp = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"ExerciseID"] intValue];
    
    if (exerciseIDTemp == 272 || exerciseIDTemp == 274){
        self.arrData = [NSMutableArray new];
        self.healthStore = [[HKHealthStore alloc] init];
        self.sd = [[StepData alloc]init];
        
        [self checkForPremission];
    }
    //HHT apple watch end
    
    _imgbar.backgroundColor= PrimaryColor
    
    if (IS_IPHONE_4)
        tfCalories.frame = CGRectMake(tfCalories.frame.origin.x, 109, tfCalories.frame.size.width, tfCalories.frame.size.height);
    else
        tfCalories.frame = CGRectMake(tfCalories.frame.origin.x, 199, tfCalories.frame.size.width, tfCalories.frame.size.height);
    
    rightButton = [[UIBarButtonItem alloc]
                           initWithBarButtonSystemItem: UIBarButtonSystemItemAction target:self action:@selector(showActionSheet:)];
    rightButton.style = UIBarButtonItemStylePlain;
    self.navigationItem.rightBarButtonItem = rightButton;
    
    if (exerciseIDTemp == 272 || exerciseIDTemp == 274){
        [rightButton setEnabled:NO];
    }
    else {
       [rightButton setEnabled:YES];
    }
    
    //[bi release];
    [self.navigationController.navigationBar setTranslucent:NO];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //HHT apple watch start (to solve issue when user comes from background)
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    int exerciseIDTemp = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"ExerciseID"] intValue];
    
    if (exerciseIDTemp == 272 || exerciseIDTemp == 274 || exerciseIDTemp == 275){
        self.arrData = [NSMutableArray new];
        self.healthStore = [[HKHealthStore alloc] init];
        self.sd = [[StepData alloc]init];
        
        [self checkForPremission];
    }
    //HHT apple watch end
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cleanUpView) name:@"CleanUpView" object:nil];
    
    exerciseLogID = 0;
    [self showLoading];
    [self performSelector:@selector(loadData) withObject:nil afterDelay:0.15];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CleanUpView" object:nil];
}

-(void)deleteExerciseAPICALL {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    
    if([dietmasterEngine.taskMode isEqualToString:@"Save"]) {
        self.navigationItem.title = @"Add to Log";
    }
    else {
        self.navigationItem.title = @"Edit Log";
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *strLogDate =[NSString stringWithFormat: @"Log Date: %@", dietmasterEngine.dateSelectedFormatted];
    int ExerciseID= [[dietmasterEngine.exerciseSelectedDict valueForKey:@"ExerciseID"] intValue];
    
    NSString *stridex =[NSString stringWithFormat:@"%d",ExerciseID];
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"DeleteExerciseLog", @"RequestType",
                              @{@"UserID" : [prefs valueForKey:@"userid_dietmastergo"],
                                @"ExerciseID" :stridex,
                                @"LogDate" :strLogDate,
                                @"AuthKey" : [prefs valueForKey:@"authkey_dietmastergo"]
                                }, @"parameters",
                              nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        GetDataWebService *webService = [[GetDataWebService alloc] init];
        webService.getDataWSDelegate = self;
        [webService callWebservice:infoDict];
        [webService release];
    });
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //HHT apple watch
    btnAllowHealthAccess.hidden = YES;
    permissionBtn.hidden = YES;
    viewAllowHealthAccess.hidden = YES;
    
    [[UITextField appearance] setTintColor:[UIColor whiteColor]];
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    if([dietmasterEngine.taskMode isEqualToString:@"Save"]) {
        self.navigationItem.title = @"Add to Log";
    }
    else {
        self.navigationItem.title = @"Edit Log";
    }
    
    if (!pickerComponentOneArray) {
        pickerComponentOneArray = [[NSMutableArray alloc] init];
    }
    
    if (!pickerComponentTwoArray) {
        pickerComponentTwoArray = [[NSMutableArray alloc] init];
    }
    
    [pickerComponentOneArray removeAllObjects];
    [pickerComponentTwoArray removeAllObjects];
    
    int exerciseID = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"ExerciseID"] intValue];
    
    if (exerciseID == 259) {
        pickerView.hidden = YES;
        caloriesBurnedLabel.hidden = YES;
        [tfCalories becomeFirstResponder];
        
        for (int i=0; i < 10001; i++) {
            NSString *hourString = [[NSString alloc] initWithFormat:@"%i", i];
            [pickerComponentOneArray addObject:hourString];
            [hourString release];
        }
    }
    else if (exerciseID == 257 || exerciseID == 267 || exerciseID == 268 || exerciseID == 269 || exerciseID == 275 || exerciseID == 276) {
        pickerView.hidden = YES;
        caloriesBurnedLabel.hidden = YES;
        [tfCalories becomeFirstResponder];
        
        for (int i=0; i < 2501; i++) {
            NSString *hourString = [[NSString alloc] initWithFormat:@"%i", i];
            [pickerComponentOneArray addObject:hourString];
            [hourString release];
        }
    }
    
    //HHT apple watch
    else if (exerciseID == 272 || exerciseID == 274 || exerciseID == 275  || exerciseID == 276){
        btnAllowHealthAccess.hidden = NO;
        permissionBtn.hidden = NO;
        viewAllowHealthAccess.hidden = NO;
        
        pickerView.hidden = YES;
        caloriesBurnedLabel.hidden = YES;
        tfCalories.hidden = YES;
        _imgbar.hidden = YES;
        lblCaloriesBurnedTitle.hidden = YES;
    }
    else {
        for (int i=0; i < 24; i++) {
            NSString *hourString = [[NSString alloc] initWithFormat:@"%i", i];
            [pickerComponentOneArray addObject:hourString];
            [hourString release];
        }
        for (int i=0; i < 60; i++) {
            NSString *minuteString = [[NSString alloc] initWithFormat:@"%i", i];
            [pickerComponentTwoArray addObject:minuteString];
            [minuteString release];
        }
    }
    dateLabel.text = [NSString stringWithFormat: @"Log Date: %@", dietmasterEngine.dateSelectedFormatted];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//- (void)viewDidUnload {
//    [lblCaloriesBurnedTitle release];
//    lblCaloriesBurnedTitle = nil;
//    [super viewDidUnload];
//    
//    pickerView = nil;
//    pickerComponentOneArray = nil;
//    pickerComponentTwoArray = nil;
//    caloriesBurnedLabel = nil;
//    exerciseNameLabel = nil;
//}

- (void)dealloc {
    [lblCaloriesBurnedTitle release];
    lblCaloriesBurnedTitle = nil;
    [_imgbar release];
    [permissionBtn release];
    [permissionBtn release];
    pickerView = nil;
    pickerComponentOneArray = nil;
    pickerComponentTwoArray = nil;
    caloriesBurnedLabel = nil;
    exerciseNameLabel = nil;
    [super dealloc];
}

//HHT apple watch
#pragma mark IBAction
-(void)checkForPremission {
    HKAuthorizationStatus permissionStatus = [self.healthStore authorizationStatusForType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]];
    
    if (permissionStatus == HKAuthorizationStatusSharingAuthorized) {
        btnAllowHealthAccess.hidden = YES;
        permissionBtn.hidden = YES;
        viewAllowHealthAccess.hidden = YES;
        
        [self readData];
    }
    else if (permissionStatus == HKAuthorizationStatusSharingDenied) {
        NSLog(@"** HKHealthStore HKAuthorizationStatusSharingDenied **");
    }
}

- (IBAction)btnAllowAccessClick:(id)sender {
    //check HKHealthStore available or not
    if ([HKHealthStore isHealthDataAvailable] == NO) {
        NSLog(@"** HKHealthStore NotAvailable **");
        return;
    }
    
    //self.healthStore = [[HKHealthStore alloc] init];
    
    NSArray *shareTypes = @[[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]];
    NSArray *readTypes = @[[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]];

    HKAuthorizationStatus permissionStatus = [self.healthStore authorizationStatusForType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]];
    
    if (permissionStatus == HKAuthorizationStatusSharingAuthorized) {
        [self readData];
    }
    else {
        [self.healthStore requestAuthorizationToShareTypes:[NSSet setWithArray:shareTypes] readTypes:[NSSet setWithArray:readTypes] completion:^(BOOL success, NSError * _Nullable error) {
            if (success){
                [self readData];
            }
            else {
                NSLog(@"Error");
            }
        }];
    }
}

//HHT apple watch
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
            NSLog(@"** An error occurred while calculating the statistics: %@ **",error.localizedDescription);
        }
        
        DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
        
        NSDate *endDate = dietmasterEngine.dateSelected;
        NSDate *startDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:0 toDate:endDate options:0];
        
        [results enumerateStatisticsFromDate:startDate toDate:endDate withBlock:^(HKStatistics * _Nonnull result, BOOL * _Nonnull stop) {
            HKQuantity *quantity = result.sumQuantity;
            if (quantity) {
                NSDate *date = result.endDate;
                
                stepCount = [quantity doubleValueForUnit:[HKUnit countUnit]];
                //double cals = [self.sd stepsToCalories:value];
                NSLog(@"%@: %.0f", date,stepCount);
                
                [self showStepData];
                
                //NSString *strStatics = [NSString stringWithFormat:@"%@,%.0f,%.0f",date,value,cals];
                //NSString *strStatics = [NSString stringWithFormat:@"%@,%.0f",date,stepCount];
                //[self.arrData addObject:strStatics];
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    lblCaloriesBurnedTitle.text = @"Data not available";
                    
                    btnAllowHealthAccess.hidden = YES;
                    permissionBtn.hidden = YES;
                    viewAllowHealthAccess.hidden = YES;
                    pickerView.hidden = YES;
                    caloriesBurnedLabel.hidden = NO;
                    tfCalories.hidden = YES;
                    _imgbar.hidden = NO;
                    lblCaloriesBurnedTitle.hidden = NO;
                });
            }
            
            if(stop)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //double temp = [self getMostRecentActiveCalories];
                    //NSLog(@"%f",temp);
                });
            }
        }];
    };
    
    [self.healthStore executeQuery:query];
}


//HHT apple watch
-(void)showStepData {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [rightButton setEnabled:YES];
        btnAllowHealthAccess.hidden = YES;
        permissionBtn.hidden = YES;
        viewAllowHealthAccess.hidden = YES;
        
        pickerView.hidden = YES;
        caloriesBurnedLabel.hidden = NO;
        tfCalories.hidden = YES;
        _imgbar.hidden = NO;
        lblCaloriesBurnedTitle.hidden = NO;
    
        DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
        
        int exerciseIDTemp = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"ExerciseID"] intValue];
        
        if (exerciseIDTemp == 272 || exerciseIDTemp == 275){
            lblCaloriesBurnedTitle.text = @"Calories Burned";
            double caloriesBurned = [self.sd stepsToCalories:stepCount];
            calories = caloriesBurned;
            caloriesBurnedLabel.text = [NSString stringWithFormat:@"%.0f",caloriesBurned];
        }
        else if (exerciseIDTemp == 274 || exerciseIDTemp == 276) {
            lblCaloriesBurnedTitle.text = @"Step Count";
            caloriesBurnedLabel.text = [NSString stringWithFormat:@"%.0f",stepCount];
        }
    });
}

#pragma mark ACTION SHEET METHODS
-(void)showActionSheet:(id)sender {
    [self.view endEditing:YES];
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    
    UIActionSheet *popupQuery;
    
    if([dietmasterEngine.taskMode isEqualToString:@"Save"]) {
        popupQuery = [[UIActionSheet alloc] initWithTitle:@"Select Action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add to Log", nil];
    }
    
    if([dietmasterEngine.taskMode isEqualToString:@"Edit"]) {
        popupQuery = [[UIActionSheet alloc] initWithTitle:@"Select Action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save Changes", @"Remove from Log", nil];
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

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    
    if (actionSheet.tag == 10) {
        if (buttonIndex == 0) {
            [self saveToLog:nil];
        }
        else if (buttonIndex == 1) {
            if([dietmasterEngine.taskMode isEqualToString:@"Edit"]) {
                [self confirmDeleteFromLog];
            }
            else {
            }
        }
    }
    else if (actionSheet.tag == 5) {
        if (buttonIndex == 0) {
            [self delLog:nil];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"minutesExercised"];

           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
               [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"minutesExercised"];
               [[NSUserDefaults standardUserDefaults] synchronize];
           });
        }
        else if (buttonIndex == 1) {
        }
    }
    else if (actionSheet.tag == 1) {
        if (buttonIndex == 0) {
            [self deleteFromFavorites];
        }
        else if (buttonIndex == 1) {
            // Don't Remove
        }
    }
}

#pragma mark CLEAN UP METHODS
-(void)cleanUpView {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark PICKER VIEW METHODS
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    
    switch (component){
        case 0:
            return 155.0f;
            break;
        case 1:
            return 155.0f;
            break;
    }
    return 0;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    int exerciseID = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"ExerciseID"] intValue];
    
    if (exerciseID == 257 || exerciseID == 259 || exerciseID == 267 || exerciseID == 268 || exerciseID == 269 || exerciseID == 275 || exerciseID == 276) {
        return 1;
    }
    else if (exerciseID == 272 || exerciseID == 274){
        return 1;
    }
    else {
        return 2;
    }
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    int exerciseID = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"ExerciseID"] intValue];
    
    if (exerciseID == 257 || exerciseID == 259 || exerciseID == 267 || exerciseID == 268 || exerciseID == 269 || exerciseID == 275 || exerciseID == 276) {
        return [pickerComponentOneArray count];
    }
    else if (exerciseID == 272 || exerciseID == 274){
        return 0;
    }
    else {
        switch (component){
            case 0:
                return [pickerComponentOneArray count];
                break;
            case 1:
                return [pickerComponentTwoArray count];
                break;
        }
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    int exerciseID = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"ExerciseID"] intValue];
    
    if (exerciseID == 257 || exerciseID == 267 || exerciseID == 275) {
        return [NSString stringWithFormat:@"%@ Calories", [pickerComponentOneArray objectAtIndex:row]];
    }
    else if (exerciseID == 268 ) {
        return [NSString stringWithFormat:@"%@ Moves", [pickerComponentOneArray objectAtIndex:row]];
    }
    else if ( exerciseID == 269 || exerciseID == 276) {
        return [NSString stringWithFormat:@"%@ Steps", [pickerComponentOneArray objectAtIndex:row]];
    }
    else if (exerciseID == 259) {
        return [NSString stringWithFormat:@"%@ Steps", [pickerComponentOneArray objectAtIndex:row]];
    }
    else if (exerciseID == 272 || exerciseID == 274){
        return @"";
    }
    else {
        switch (component){
            case 0:
                if (row == 1)
                    return [NSString stringWithFormat:@"%@ Hour", [pickerComponentOneArray objectAtIndex:row]];
                else
                    return [NSString stringWithFormat:@"%@ Hours", [pickerComponentOneArray objectAtIndex:row]];
                break;
            case 1:
                if (row == 1)
                    return [NSString stringWithFormat:@"%@ Minute", [pickerComponentTwoArray objectAtIndex:row]];
                else
                    return [NSString stringWithFormat:@"%@ Minutes", [pickerComponentTwoArray objectAtIndex:row]];
                break;
        }
    }
    return @"0";
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self updateCalorieLabel];
}

#pragma mark SAVE EDIT DB METHODS
-(void)saveToLog:(id)sender {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
        
    }
    
    int hoursExercised = 0;
    int minutesExercised = 0;
    
    int exerciseIDTemp = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"ExerciseID"] intValue];
    if (exerciseIDTemp == 257 || exerciseIDTemp == 267 || exerciseIDTemp == 268 || exerciseIDTemp == 269 || exerciseIDTemp == 275 || exerciseIDTemp == 276) {
        minutesExercised = [tfCalories.text intValue];
    }
    else if (exerciseIDTemp == 259) {
        minutesExercised = [tfCalories.text intValue];
    }
    //HHT apple watch
    else if (exerciseIDTemp == 272) {
        minutesExercised = calories;
    }
    //HHT apple watch
    else if (exerciseIDTemp == 274){
        minutesExercised = stepCount;
    }
    else {
        hoursExercised = [[pickerComponentOneArray objectAtIndex:[pickerView selectedRowInComponent:0]] intValue];
        minutesExercised = [[pickerComponentTwoArray objectAtIndex:[pickerView selectedRowInComponent:1]] intValue];
        minutesExercised = minutesExercised + (hoursExercised * 60);
    }
    
    if([dietmasterEngine.taskMode isEqualToString:@"Save"]) {
        [db beginTransaction];
        
//        NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
//        NSDateFormatter *outdateformatter = [[NSDateFormatter alloc] init];
//        [outdateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//        [outdateformatter setTimeZone:systemTimeZone];
//        NSString *logTimeString = [outdateformatter stringFromDate:dietmasterEngine.dateSelected];
//        [outdateformatter release];
//
//        NSDateFormatter *keydateformatter = [[NSDateFormatter alloc] init];
//        [keydateformatter setDateFormat:@"yyyyMMdd"];
//        [keydateformatter setTimeZone:systemTimeZone];
//        NSString *keyDate = [keydateformatter stringFromDate:dietmasterEngine.dateSelected];
//        [keydateformatter release];
        
        
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDateFormatter *keydateformatter = [[NSDateFormatter alloc] init];
        [keydateformatter setDateFormat:@"yyyyMMdd"];

        
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        [keydateformatter setTimeZone:[NSTimeZone systemTimeZone]];

        NSString *logTimeString = [dateFormatter stringFromDate:dietmasterEngine.dateSelected];
        NSString *keyDate = [keydateformatter stringFromDate:dietmasterEngine.dateSelected];
        
        
        
        
        int exerciseID = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"ExerciseID"] intValue];
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
        
        NSString *date_string = [dateFormatter stringFromDate:dietmasterEngine.dateSelected];
        
        
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
        [insertQuery release];
        
        if ([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
        
        exerciseLogID = [db lastInsertRowId];
        
        [self performSelector:@selector(showCompleted) withObject:nil afterDelay:0.25];
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }
    else if ([dietmasterEngine.taskMode isEqualToString:@"Edit"]) {
        exerciseLogID = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"Exercise_Log_ID"] intValue];
        
        [db beginTransaction];
        
//        NSDate* sourceDate = [NSDate date];
//        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
//        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//        NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
//        [dateFormatter setTimeZone:systemTimeZone];
//        NSString *date_string = [dateFormatter stringFromDate:sourceDate];
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *date_string = [dateFormatter stringFromDate:[NSDate date]];

        
        NSString *updateQuery = [[NSString alloc] initWithFormat:@"UPDATE Exercise_Log SET Exercise_Time_Minutes = %i, Date_Modified = '%@' WHERE Exercise_Log_ID = %i", minutesExercised, date_string, exerciseLogID];
        
        [db executeUpdate:updateQuery];
        
        if ([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
        
        [self performSelector:@selector(showCompleted) withObject:nil afterDelay:0.25];
        [self.navigationController popViewControllerAnimated:YES];
        
        [updateQuery release];
    }
}

-(IBAction) delLog:(id) sender {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
        
    }
    
    [db beginTransaction];
    
    exerciseLogID = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"Exercise_Log_ID"] intValue];
    
    NSString *deleteQuery = [[NSString alloc] initWithFormat:@"DELETE FROM Exercise_Log WHERE Exercise_Log_ID = %i", exerciseLogID];
    
    [db executeUpdate:deleteQuery];
    
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
    
    [deleteQuery release];
    
    [self performSelector:@selector(showCompleted) withObject:nil afterDelay:0.25];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) deleteFromFavorites {
    [self.navigationController popViewControllerAnimated:YES];
    [self performSelector:@selector(showCompleted) withObject:nil afterDelay:0.25];
}

-(void)saveToFavorites {
    [self.navigationController popViewControllerAnimated:YES];
    [self performSelector:@selector(showCompleted) withObject:nil afterDelay:0.25];
}

-(void)updateCalorieLabel {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    int exerciseID = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"ExerciseID"] intValue];
    
    if (exerciseID == 257 || exerciseID == 267 || exerciseID == 275) {
        
        int overrideCalories = [[pickerComponentOneArray objectAtIndex:[pickerView selectedRowInComponent:0]] intValue];
        caloriesBurnedLabel.text = [NSString stringWithFormat:@"%i", overrideCalories];
    }
    else if (exerciseID == 268) {
        int overrideCalories = [[pickerComponentOneArray objectAtIndex:[pickerView selectedRowInComponent:0]] intValue];
        caloriesBurnedLabel.text = [NSString stringWithFormat:@"%i Moves Taken", overrideCalories];
    }
    else if (exerciseID == 269  || exerciseID == 276) {
        int overrideCalories = [[pickerComponentOneArray objectAtIndex:[pickerView selectedRowInComponent:0]] intValue];
        caloriesBurnedLabel.text = [NSString stringWithFormat:@"%i Steps Taken", overrideCalories];
    }
    else if (exerciseID == 259) {
        int stepsTaken = [[pickerComponentOneArray objectAtIndex:[pickerView selectedRowInComponent:0]] intValue];
        caloriesBurnedLabel.text = [NSString stringWithFormat:@"%i Steps Taken", stepsTaken];
    }
    else if (exerciseID == 272 || exerciseID == 274){
        
    }
    else {
        double caloriesPerHour = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"CaloriesPerHour"] floatValue];
        
        int hoursExercised = 0;
        double minutesExercised = 0;
        hoursExercised = [[pickerComponentOneArray objectAtIndex:[pickerView selectedRowInComponent:0]] intValue];
        minutesExercised = [[pickerComponentTwoArray objectAtIndex:[pickerView selectedRowInComponent:1]] intValue];
        minutesExercised = minutesExercised + (hoursExercised * 60);
        
        double totalCaloriesBurned = (caloriesPerHour / 60) * [dietmasterEngine.currentWeight floatValue] * minutesExercised;
        
        caloriesBurnedLabel.text = [NSString stringWithFormat:@"%.2f", totalCaloriesBurned];
    }
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
@end
