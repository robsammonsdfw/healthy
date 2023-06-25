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

@interface ExercisesDetailViewController() <UITextFieldDelegate>
@property (nonatomic) double stepCount;
@property (nonatomic, strong) UIBarButtonItem *rightButton;
@property (nonatomic) double calories;

//HHT apple watch
@property (nonatomic, strong) HKHealthStore *healthStore;
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) NSSet *readDataTypes;
@property (nonatomic, strong) StepData * sd;

@property (nonatomic, strong) IBOutlet UIPickerView *pickerView;
@property (nonatomic, strong) NSMutableArray *pickerComponentOneArray;
@property (nonatomic, strong) NSMutableArray *pickerComponentTwoArray;
@property (nonatomic, strong) IBOutlet UILabel *lblCaloriesBurnedTitle;
@property (nonatomic, strong) IBOutlet UILabel *caloriesBurnedLabel;
@property (nonatomic, strong) IBOutlet UILabel *exerciseNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UITextField *tfCalories;//09-02-2016

//HHT apple watch
@property (nonatomic, strong) IBOutlet UIButton *btnAllowHealthAccess;
@property (nonatomic, strong) IBOutlet UIView *viewAllowHealthAccess;
@property (nonatomic, strong) IBOutlet UILabel *permissionTagLbl;
@property (nonatomic, strong) IBOutlet UIButton *permissionBtn;

@property (nonatomic, strong) IBOutlet UIImageView *imgbar;

/// Constraint that attaches the imgBar to the bottom.
@property (nonatomic, strong) NSLayoutConstraint *imgBarBottomConstraint;

@end

@implementation ExercisesDetailViewController

- (instancetype)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    return self;
}

#pragma mark DATA METHODS
-(void)loadData {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:PLIST_NAME];
    NSDictionary *appDefaults = [[NSDictionary alloc] initWithContentsOfFile:finalPath];
    
    NSString *appName = [appDefaults valueForKey:@"app_name_long"];
    [self.permissionBtn setTitle:[NSString stringWithFormat:@"Allow %@ to access Apple Heath data.", appName] forState:UIControlStateNormal];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    self.exerciseNameLabel.text = [dietmasterEngine.exerciseSelectedDict valueForKey:@"ActivityName"];
    
    [DMActivityIndicator hideActivityIndicator];

    int exerciseIDTemp = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"ExerciseID"] intValue];
    
    if (exerciseIDTemp == 257 || exerciseIDTemp == 267 || exerciseIDTemp == 268 || exerciseIDTemp == 269 || exerciseIDTemp == 275){
        int caloriesOverride = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"Exercise_Time_Minutes"] intValue];
        if (caloriesOverride != 0)
            self.tfCalories.text = [NSString stringWithFormat:@"%d", caloriesOverride];
        [self.pickerView selectRow:caloriesOverride inComponent:0 animated:YES];
    }
    else if (exerciseIDTemp == 259 || exerciseIDTemp == 276) {
        self.lblCaloriesBurnedTitle.text = @"Step Count";
        int stepsTaken = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"Exercise_Time_Minutes"] intValue];
        if (stepsTaken != 0)
            self.tfCalories.text = [NSString stringWithFormat:@"%d", stepsTaken];
        [self.pickerView selectRow:stepsTaken inComponent:0 animated:YES];
    }
    else if (exerciseIDTemp == 272 || exerciseIDTemp == 274 ){
        
    }
    else {
        int totalTime = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"Exercise_Time_Minutes"] intValue];
        int hours = totalTime / 60;
        int minutes = (totalTime % 60);
        
        [self.pickerView selectRow:hours inComponent:0 animated:YES];
        [self.pickerView selectRow:minutes inComponent:1 animated:YES];
    }
    
    [self.pickerView reloadAllComponents];
    
    [self performSelector:@selector(updateCalorieLabel) withObject:nil afterDelay:0.50];
        
    UIImageView *backgroundImage = (UIImageView *)[self.view viewWithTag:501];
    if ([[appDefaults valueForKey:@"account_code"] isEqualToString:@"ezdietplanner"]) {
        backgroundImage.image = [UIImage imageNamed:@"Food_Detail_Screen"];
        self.pickerView.backgroundColor = [UIColor whiteColor];
    }
}

#pragma mark VIEW LIFECYCLE
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tfCalories.delegate = self;
    self.tfCalories.placeholder = @"0";
    self.lblCaloriesBurnedTitle.textColor = PrimaryFontColor;
    self.caloriesBurnedLabel.textColor = PrimaryFontColor;
    self.tfCalories.textColor = PrimaryFontColor;
    self.exerciseNameLabel.textAlignment = NSTextAlignmentCenter;
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    int exerciseIDTemp = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"ExerciseID"] intValue];
    
    if (exerciseIDTemp == 272 || exerciseIDTemp == 274){
        self.arrData = [NSMutableArray new];
        self.healthStore = [[HKHealthStore alloc] init];
        self.sd = [[StepData alloc]init];
        
        [self checkForPremission];
    }
    
    self.imgbar.backgroundColor = PrimaryColor;
    
    self.rightButton = [[UIBarButtonItem alloc]
                           initWithBarButtonSystemItem: UIBarButtonSystemItemAction target:self action:@selector(showActionSheet:)];
    self.rightButton.style = UIBarButtonItemStylePlain;
    self.rightButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = self.rightButton;
    
    if (exerciseIDTemp == 272 || exerciseIDTemp == 274){
        [self.rightButton setEnabled:NO];
    }
    else {
       [self.rightButton setEnabled:YES];
    }
    [self.navigationController.navigationBar setTranslucent:NO];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //HHT apple watch start (to solve issue when user comes from background)
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    int exerciseIDTemp = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"ExerciseID"] intValue];
    
    if (exerciseIDTemp == 272 || exerciseIDTemp == 274 || exerciseIDTemp == 275){
        self.arrData = [NSMutableArray new];
        self.healthStore = [[HKHealthStore alloc] init];
        self.sd = [[StepData alloc]init];
        [self checkForPremission];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cleanUpView) name:@"CleanUpView" object:nil];
    
    self.exerciseLogID = 0;
    [DMActivityIndicator showActivityIndicator];
    [self performSelector:@selector(loadData) withObject:nil afterDelay:0.15];
}

- (void)deleteExerciseAPICALL {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
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
        
    });
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //HHT apple watch
    self.btnAllowHealthAccess.hidden = YES;
    self.permissionBtn.hidden = YES;
    self.viewAllowHealthAccess.hidden = YES;
    
    [[UITextField appearance] setTintColor:[UIColor whiteColor]];
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    if([dietmasterEngine.taskMode isEqualToString:@"Save"]) {
        self.navigationItem.title = @"Add to Log";
    }
    else {
        self.navigationItem.title = @"Edit Log";
    }
    
    if (!self.pickerComponentOneArray) {
        self.pickerComponentOneArray = [[NSMutableArray alloc] init];
    }
    
    if (!self.pickerComponentTwoArray) {
        self.pickerComponentTwoArray = [[NSMutableArray alloc] init];
    }
    
    [self.pickerComponentOneArray removeAllObjects];
    [self.pickerComponentTwoArray removeAllObjects];
    
    int exerciseID = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"ExerciseID"] intValue];
    BOOL showTextField = NO;
    
    if (exerciseID == 259) {
        self.pickerView.hidden = YES;
        self.caloriesBurnedLabel.hidden = YES;
        self.tfCalories.hidden = NO;
        [self.tfCalories becomeFirstResponder];
        showTextField = YES;
        for (int i=0; i < 10001; i++) {
            NSString *hourString = [[NSString alloc] initWithFormat:@"%i", i];
            [self.pickerComponentOneArray addObject:hourString];
        }
    }
    else if (exerciseID == 257 || exerciseID == 267 || exerciseID == 268 || exerciseID == 269 || exerciseID == 275 || exerciseID == 276) {
        self.pickerView.hidden = YES;
        self.caloriesBurnedLabel.hidden = YES;
        self.tfCalories.hidden = NO;
        [self.tfCalories becomeFirstResponder];
        showTextField = YES;
        
        for (int i=0; i < 2501; i++) {
            NSString *hourString = [[NSString alloc] initWithFormat:@"%i", i];
            [self.pickerComponentOneArray addObject:hourString];
        }
    } else if (exerciseID == 272 || exerciseID == 274 || exerciseID == 275  || exerciseID == 276){
        self.btnAllowHealthAccess.hidden = NO;
        self.permissionBtn.hidden = NO;
        self.viewAllowHealthAccess.hidden = NO;
        self.pickerView.hidden = YES;
        self.caloriesBurnedLabel.hidden = YES;
        self.tfCalories.hidden = YES;
        self.lblCaloriesBurnedTitle.hidden = YES;
    }
    else {
        showTextField = NO;
        self.tfCalories.hidden = YES;
        self.pickerView.hidden = NO;

        for (int i=0; i < 24; i++) {
            NSString *hourString = [[NSString alloc] initWithFormat:@"%i", i];
            [self.pickerComponentOneArray addObject:hourString];
        }
        for (int i=0; i < 60; i++) {
            NSString *minuteString = [[NSString alloc] initWithFormat:@"%i", i];
            [self.pickerComponentTwoArray addObject:minuteString];
        }
    }
    self.dateLabel.text = [NSString stringWithFormat: @"Log Date: %@", dietmasterEngine.dateSelectedFormatted];
    
    // Set the constraint based on if TextField is in view or not.
    if (!showTextField) {
        // Attach to picker.
        self.imgBarBottomConstraint = [self.imgbar.bottomAnchor constraintEqualToAnchor:self.pickerView.topAnchor constant:0];
        self.imgBarBottomConstraint.active = YES;
    } else {
        UIKeyboardLayoutGuide *layoutGuide = [self.view keyboardLayoutGuide];
        self.imgBarBottomConstraint = [self.imgbar.bottomAnchor constraintEqualToAnchor:layoutGuide.topAnchor constant:0];
        self.imgBarBottomConstraint.active = YES;
    }
}

//HHT apple watch
#pragma mark IBAction
-(void)checkForPremission {
    HKAuthorizationStatus permissionStatus = [self.healthStore authorizationStatusForType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]];
    
    if (permissionStatus == HKAuthorizationStatusSharingAuthorized) {
        self.btnAllowHealthAccess.hidden = YES;
        self.permissionBtn.hidden = YES;
        self.viewAllowHealthAccess.hidden = YES;
        
        [self readData];
    }
    else if (permissionStatus == HKAuthorizationStatusSharingDenied) {
        DMLog(@"** HKHealthStore HKAuthorizationStatusSharingDenied **");
    }
}

- (IBAction)btnAllowAccessClick:(id)sender {
    //check HKHealthStore available or not
    if ([HKHealthStore isHealthDataAvailable] == NO) {
        DMLog(@"** HKHealthStore NotAvailable **");
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
                DMLog(@"Error");
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
            DMLog(@"** An error occurred while calculating the statistics: %@ **",error.localizedDescription);
        }
        
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        
        NSDate *endDate = dietmasterEngine.dateSelected;
        NSDate *startDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:0 toDate:endDate options:0];
        
        [results enumerateStatisticsFromDate:startDate toDate:endDate withBlock:^(HKStatistics * _Nonnull result, BOOL * _Nonnull stop) {
            HKQuantity *quantity = result.sumQuantity;
            if (quantity) {
                NSDate *date = result.endDate;
                
                self.stepCount = [quantity doubleValueForUnit:[HKUnit countUnit]];
                //DMLog(@"%@: %.0f", date, self.stepCount);
                [self showStepData];
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.lblCaloriesBurnedTitle.text = @"Data not available";
                    
                    self.btnAllowHealthAccess.hidden = YES;
                    self.permissionBtn.hidden = YES;
                    self.viewAllowHealthAccess.hidden = YES;
                    self.pickerView.hidden = YES;
                    self.caloriesBurnedLabel.hidden = NO;
                    self.tfCalories.hidden = YES;
                    self.lblCaloriesBurnedTitle.hidden = NO;
                });
            }
        }];
    };
    
    [self.healthStore executeQuery:query];
}


//HHT apple watch
-(void)showStepData {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.rightButton setEnabled:YES];
        self.btnAllowHealthAccess.hidden = YES;
        self.permissionBtn.hidden = YES;
        self.viewAllowHealthAccess.hidden = YES;
        
        self.pickerView.hidden = YES;
        self.caloriesBurnedLabel.hidden = NO;
        self.tfCalories.hidden = YES;
        self.lblCaloriesBurnedTitle.hidden = NO;
    
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        
        int exerciseIDTemp = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"ExerciseID"] intValue];
        
        if (exerciseIDTemp == 272 || exerciseIDTemp == 275){
            self.lblCaloriesBurnedTitle.text = @"Calories Burned";
            double caloriesBurned = [self.sd stepsToCalories:self.stepCount];
            self.calories = caloriesBurned;
            self.caloriesBurnedLabel.text = [NSString stringWithFormat:@"%.0f",caloriesBurned];
        }
        else if (exerciseIDTemp == 274 || exerciseIDTemp == 276) {
            self.lblCaloriesBurnedTitle.text = @"Step Count";
            self.caloriesBurnedLabel.text = [NSString stringWithFormat:@"%.0f",self.stepCount];
        }
    });
}

- (void)showActionSheet:(id)sender {
    [self.view endEditing:YES];
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Action" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if ([dietmasterEngine.taskMode isEqualToString:@"Save"]) {
        [alert addAction:[UIAlertAction actionWithTitle:@"Add to Log"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            [self saveToLog:nil];
        }]];
    }
    
    if ([dietmasterEngine.taskMode isEqualToString:@"Edit"]) {
        [alert addAction:[UIAlertAction actionWithTitle:@"Save Changes"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            [self saveToLog:nil];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Remove from Log"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            [self confirmDeleteFromLog];
        }]];
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

/// Confirms with the user they want to delete this exercise from the log.
-(void)confirmDeleteFromLog {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Remove from Log?"
                                                                   message:@"Are you sure you wish to remove this from the log?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes, Delete"
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self delLog:nil];
        //[DataProvider sharedInstance].minutesExercisedToday = 0;
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
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
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
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
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    int exerciseID = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"ExerciseID"] intValue];
    
    if (exerciseID == 257 || exerciseID == 259 || exerciseID == 267 || exerciseID == 268 || exerciseID == 269 || exerciseID == 275 || exerciseID == 276) {
        return [self.pickerComponentOneArray count];
    }
    else if (exerciseID == 272 || exerciseID == 274){
        return 0;
    }
    else {
        switch (component){
            case 0:
                return [self.pickerComponentOneArray count];
                break;
            case 1:
                return [self.pickerComponentTwoArray count];
                break;
        }
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    int exerciseID = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"ExerciseID"] intValue];
    
    if (exerciseID == 257 || exerciseID == 267 || exerciseID == 275) {
        return [NSString stringWithFormat:@"%@ Calories", [self.pickerComponentOneArray objectAtIndex:row]];
    }
    else if (exerciseID == 268 ) {
        return [NSString stringWithFormat:@"%@ Moves", [self.pickerComponentOneArray objectAtIndex:row]];
    }
    else if ( exerciseID == 269 || exerciseID == 276) {
        return [NSString stringWithFormat:@"%@ Steps", [self.pickerComponentOneArray objectAtIndex:row]];
    }
    else if (exerciseID == 259) {
        return [NSString stringWithFormat:@"%@ Steps", [self.pickerComponentOneArray objectAtIndex:row]];
    }
    else if (exerciseID == 272 || exerciseID == 274){
        return @"";
    }
    else {
        switch (component){
            case 0:
                if (row == 1)
                    return [NSString stringWithFormat:@"%@ Hour", [self.pickerComponentOneArray objectAtIndex:row]];
                else
                    return [NSString stringWithFormat:@"%@ Hours", [self.pickerComponentOneArray objectAtIndex:row]];
                break;
            case 1:
                if (row == 1)
                    return [NSString stringWithFormat:@"%@ Minute", [self.pickerComponentTwoArray objectAtIndex:row]];
                else
                    return [NSString stringWithFormat:@"%@ Minutes", [self.pickerComponentTwoArray objectAtIndex:row]];
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
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
        
    }
    
    int hoursExercised = 0;
    int minutesExercised = 0;
    
    int exerciseIDTemp = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"ExerciseID"] intValue];
    if (exerciseIDTemp == 257 || exerciseIDTemp == 267 || exerciseIDTemp == 268 || exerciseIDTemp == 269 || exerciseIDTemp == 275 || exerciseIDTemp == 276) {
        minutesExercised = [self.tfCalories.text intValue];
    }
    else if (exerciseIDTemp == 259) {
        minutesExercised = [self.tfCalories.text intValue];
    }
    //HHT apple watch
    else if (exerciseIDTemp == 272) {
        minutesExercised = self.calories;
    }
    //HHT apple watch
    else if (exerciseIDTemp == 274){
        minutesExercised = self.stepCount;
    }
    else {
        hoursExercised = [[self.pickerComponentOneArray objectAtIndex:[self.pickerView selectedRowInComponent:0]] intValue];
        minutesExercised = [[self.pickerComponentTwoArray objectAtIndex:[self.pickerView selectedRowInComponent:1]] intValue];
        minutesExercised = minutesExercised + (hoursExercised * 60);
    }
    
    if([dietmasterEngine.taskMode isEqualToString:@"Save"]) {
        [db beginTransaction];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
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
        
        
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
        
        self.exerciseLogID = [db lastInsertRowId];
        
        [DMActivityIndicator showCompletedIndicator];
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }
    else if ([dietmasterEngine.taskMode isEqualToString:@"Edit"]) {
        self.exerciseLogID = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"Exercise_Log_ID"] intValue];
        
        [db beginTransaction];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *date_string = [dateFormatter stringFromDate:[NSDate date]];
        
        NSString *updateQuery = [[NSString alloc] initWithFormat:@"UPDATE Exercise_Log SET Exercise_Time_Minutes = %i, Date_Modified = '%@' WHERE Exercise_Log_ID = %i", minutesExercised, date_string, self.exerciseLogID];
        
        [db executeUpdate:updateQuery];
        
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
        
        [DMActivityIndicator showCompletedIndicator];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(IBAction) delLog:(id) sender {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
        
    }
    
    [db beginTransaction];
    
    self.exerciseLogID = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"Exercise_Log_ID"] intValue];
    
    NSString *deleteQuery = [[NSString alloc] initWithFormat:@"DELETE FROM Exercise_Log WHERE Exercise_Log_ID = %i", self.exerciseLogID];
    
    [db executeUpdate:deleteQuery];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
    
    [DMActivityIndicator showCompletedIndicator];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) deleteFromFavorites {
    [self.navigationController popViewControllerAnimated:YES];
    [DMActivityIndicator showCompletedIndicator];
}

-(void)saveToFavorites {
    [self.navigationController popViewControllerAnimated:YES];
    [DMActivityIndicator showCompletedIndicator];
}

-(void)updateCalorieLabel {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    int exerciseID = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"ExerciseID"] intValue];
    
    if (exerciseID == 257 || exerciseID == 267 || exerciseID == 275) {
        
        int overrideCalories = [[self.pickerComponentOneArray objectAtIndex:[self.pickerView selectedRowInComponent:0]] intValue];
        self.caloriesBurnedLabel.text = [NSString stringWithFormat:@"%i", overrideCalories];
    }
    else if (exerciseID == 268) {
        int overrideCalories = [[self.pickerComponentOneArray objectAtIndex:[self.pickerView selectedRowInComponent:0]] intValue];
        self.caloriesBurnedLabel.text = [NSString stringWithFormat:@"%i Moves Taken", overrideCalories];
    }
    else if (exerciseID == 269  || exerciseID == 276) {
        int overrideCalories = [[self.pickerComponentOneArray objectAtIndex:[self.pickerView selectedRowInComponent:0]] intValue];
        self.caloriesBurnedLabel.text = [NSString stringWithFormat:@"%i Steps Taken", overrideCalories];
    }
    else if (exerciseID == 259) {
        int stepsTaken = [[self.pickerComponentOneArray objectAtIndex:[self.pickerView selectedRowInComponent:0]] intValue];
        self.caloriesBurnedLabel.text = [NSString stringWithFormat:@"%i Steps Taken", stepsTaken];
    }
    else if (exerciseID == 272 || exerciseID == 274){
        
    }
    else {
        double caloriesPerHour = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"CaloriesPerHour"] floatValue];
        
        int hoursExercised = 0;
        double minutesExercised = 0;
        hoursExercised = [[self.pickerComponentOneArray objectAtIndex:[self.pickerView selectedRowInComponent:0]] intValue];
        minutesExercised = [[self.pickerComponentTwoArray objectAtIndex:[self.pickerView selectedRowInComponent:1]] intValue];
        minutesExercised = minutesExercised + (hoursExercised * 60);
        
        double totalCaloriesBurned = (caloriesPerHour / 60) * [dietmasterEngine.currentWeight floatValue] * minutesExercised;
        
        self.caloriesBurnedLabel.text = [NSString stringWithFormat:@"%.2f", totalCaloriesBurned];
    }
}

@end
