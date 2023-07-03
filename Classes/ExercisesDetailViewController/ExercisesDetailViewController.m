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
#import "DietmasterEngine.h"

@interface ExercisesDetailViewController() <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic) double stepCount;
@property (nonatomic, strong) UIBarButtonItem *rightButton;
@property (nonatomic) double calories;

//HHT apple watch
@property (nonatomic, strong) HKHealthStore *healthStore;
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) NSSet *readDataTypes;
@property (nonatomic, strong) StepData *stepData;

@property (nonatomic, strong) IBOutlet UIPickerView *pickerView;
@property (nonatomic, strong) NSMutableArray *pickerComponentOneArray;
@property (nonatomic, strong) NSMutableArray *pickerComponentTwoArray;
@property (nonatomic, strong) IBOutlet UILabel *lblCaloriesBurnedTitle;
@property (nonatomic, strong) IBOutlet UILabel *caloriesBurnedLabel;
@property (nonatomic, strong) IBOutlet UILabel *exerciseNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UITextField *tfCalories;//09-02-2016

@property (nonatomic, strong) IBOutlet UIImageView *imgbar;

/// Constraint that attaches the imgBar to the bottom.
@property (nonatomic, strong) NSLayoutConstraint *imgBarBottomConstraint;

/// The exercise currently being presented.
@property (nonatomic, strong) NSDictionary *exerciseDict;
@property (nonatomic, strong) NSDate *selectedDate;
@end

@implementation ExercisesDetailViewController

- (instancetype)initWithExerciseDict:(NSDictionary *)exerciseDict
                        selectedDate:(NSDate *)selectedDate {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        _exerciseDict = exerciseDict;
        _selectedDate = selectedDate ?: [NSDate date];
    }
    return self;
}

- (void)loadData {
    self.exerciseNameLabel.text = [self.exerciseDict valueForKey:@"ActivityName"];
    
    int exerciseIDTemp = [[self.exerciseDict valueForKey:@"ExerciseID"] intValue];
    
    if (exerciseIDTemp == 257 || exerciseIDTemp == 267 || exerciseIDTemp == 268 || exerciseIDTemp == 269 || exerciseIDTemp == 275){
        int caloriesOverride = [[self.exerciseDict valueForKey:@"Exercise_Time_Minutes"] intValue];
        if (caloriesOverride != 0)
            self.tfCalories.text = [NSString stringWithFormat:@"%d", caloriesOverride];
        [self.pickerView selectRow:caloriesOverride inComponent:0 animated:YES];
    }
    else if (exerciseIDTemp == 259 || exerciseIDTemp == 276) {
        self.lblCaloriesBurnedTitle.text = @"Step Count";
        int stepsTaken = [[self.exerciseDict valueForKey:@"Exercise_Time_Minutes"] intValue];
        if (stepsTaken != 0)
            self.tfCalories.text = [NSString stringWithFormat:@"%d", stepsTaken];
        [self.pickerView selectRow:stepsTaken inComponent:0 animated:YES];
    }
    else if (exerciseIDTemp == 272 || exerciseIDTemp == 274 ){
        
    }
    else {
        int totalTime = [[self.exerciseDict valueForKey:@"Exercise_Time_Minutes"] intValue];
        int hours = totalTime / 60;
        int minutes = (totalTime % 60);
        
        [self.pickerView selectRow:hours inComponent:0 animated:YES];
        [self.pickerView selectRow:minutes inComponent:1 animated:YES];
    }
    
    [self.pickerView reloadAllComponents];
    
    [self updateCalorieLabel];
        
    NSString *accountCode = [DMGUtilities configValueForKey:@"account_code"];
    UIImageView *backgroundImage = (UIImageView *)[self.view viewWithTag:501];
    if ([accountCode isEqualToString:@"ezdietplanner"]) {
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
    self.tfCalories.textColor = [UIColor blackColor];
    self.exerciseNameLabel.textAlignment = NSTextAlignmentCenter;
    
    self.tfCalories.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.tfCalories.layer.borderWidth = 1.0f;
    self.tfCalories.layer.cornerRadius = 8;
    
    int exerciseIDTemp = [[self.exerciseDict valueForKey:@"ExerciseID"] intValue];
    if (exerciseIDTemp == 272 || exerciseIDTemp == 274) {
        self.arrData = [NSMutableArray new];
        self.healthStore = [[HKHealthStore alloc] init];
        self.stepData = [[StepData alloc]init];
        [self checkForPermission];
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    int exerciseIDTemp = [[self.exerciseDict valueForKey:@"ExerciseID"] intValue];
    if (exerciseIDTemp == 272 || exerciseIDTemp == 274 || exerciseIDTemp == 275){
        self.arrData = [NSMutableArray new];
        self.healthStore = [[HKHealthStore alloc] init];
        self.stepData = [[StepData alloc]init];
        [self checkForPermission];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cleanUpView) name:@"CleanUpView" object:nil];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UITextField appearance] setTintColor:[UIColor whiteColor]];
    if (self.taskMode == DMTaskModeAdd) {
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
    
    int exerciseID = [[self.exerciseDict valueForKey:@"ExerciseID"] intValue];
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
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    self.dateLabel.text = [NSString stringWithFormat: @"Log Date: %@", [dateFormatter stringFromDate:self.selectedDate]];
    
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
- (void)checkForPermission {
    [self.stepData checkHealthKitAuthorizationWithCompletionBlock:^(BOOL authorized, NSError *error) {
        if (authorized) {
            [self readAppleHealthData];
            return;
        }
        
        NSString *appName = [DMGUtilities configValueForKey:@"app_name_long"];
        NSString *message = [NSString stringWithFormat:@"Apple HealthKit permission is needed. Please open the Apple Health app and grant access for %@.", appName];
        [DMGUtilities showAlertWithTitle:@"Permission Needed" message:message inViewController:nil];
    }];
}

- (void)readAppleHealthData {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    interval.day = 1;
    
    NSDateComponents *anchorComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                                     fromDate:[NSDate date]];
    anchorComponents.hour = 0;
    NSDate *anchorDate = [calendar dateFromComponents:anchorComponents];
    HKQuantityType *quantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    // Create the query
    HKStatisticsCollectionQuery *query =
            [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType
                                              quantitySamplePredicate:nil
                                                              options:HKStatisticsOptionCumulativeSum
                                                           anchorDate:anchorDate
                                                   intervalComponents:interval];
    
    query.initialResultsHandler = ^(HKStatisticsCollectionQuery* query, HKStatisticsCollection* results, NSError *error) {
        if (error) {
            return;
        }
        
        NSDate *startDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:0 toDate:self.selectedDate options:0];
        [results enumerateStatisticsFromDate:startDate toDate:self.selectedDate withBlock:^(HKStatistics * _Nonnull result, BOOL * _Nonnull stop) {
            dispatch_async(dispatch_get_main_queue(), ^{
                HKQuantity *quantity = result.sumQuantity;
                if (quantity) {
                    self.stepCount = [quantity doubleValueForUnit:[HKUnit countUnit]];
                    [self showStepData];
                }
                else {
                    self.lblCaloriesBurnedTitle.text = @"Data not available.";
                    self.pickerView.hidden = YES;
                    self.caloriesBurnedLabel.hidden = NO;
                    self.tfCalories.hidden = YES;
                    self.lblCaloriesBurnedTitle.hidden = NO;
                }
            });
        }];
    };
    
    [self.healthStore executeQuery:query];
}

- (void)showStepData {
    [self.rightButton setEnabled:YES];
    self.pickerView.hidden = YES;
    self.caloriesBurnedLabel.hidden = NO;
    self.tfCalories.hidden = YES;
    self.lblCaloriesBurnedTitle.hidden = NO;

    int exerciseIDTemp = [[self.exerciseDict valueForKey:@"ExerciseID"] intValue];
    if (exerciseIDTemp == 272 || exerciseIDTemp == 275){
        self.lblCaloriesBurnedTitle.text = @"Calories Burned";
        double caloriesBurned = [self.stepData stepsToCaloriesForSteps:self.stepCount];
        self.calories = caloriesBurned;
        self.caloriesBurnedLabel.text = [NSString stringWithFormat:@"%.0f",caloriesBurned];
    }
    else if (exerciseIDTemp == 274 || exerciseIDTemp == 276) {
        self.lblCaloriesBurnedTitle.text = @"Step Count";
        self.caloriesBurnedLabel.text = [NSString stringWithFormat:@"%.0f",self.stepCount];
    }
}

- (void)showActionSheet:(id)sender {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Action" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (self.taskMode == DMTaskModeAdd) {
        [alert addAction:[UIAlertAction actionWithTitle:@"Add to Log"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            [self saveToLog:nil];
        }]];
    }
    
    if (self.taskMode == DMTaskModeEdit) {
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
    int exerciseID = [[self.exerciseDict valueForKey:@"ExerciseID"] intValue];
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
    int exerciseID = [[self.exerciseDict valueForKey:@"ExerciseID"] intValue];
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
    int exerciseID = [[self.exerciseDict valueForKey:@"ExerciseID"] intValue];
    
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

- (void)saveToLog:(id)sender {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }
    
    int hoursExercised = 0;
    int minutesExercised = 0;
    
    int exerciseIDTemp = [[self.exerciseDict valueForKey:@"ExerciseID"] intValue];
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
    
    if (self.taskMode == DMTaskModeAdd) {
        [db beginTransaction];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDateFormatter *keydateformatter = [[NSDateFormatter alloc] init];
        [keydateformatter setDateFormat:@"yyyyMMdd"];
        
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        [keydateformatter setTimeZone:[NSTimeZone systemTimeZone]];
        
        NSString *logTimeString = [dateFormatter stringFromDate:self.selectedDate];
        NSString *keyDate = [keydateformatter stringFromDate:self.selectedDate];
        
        int exerciseID = [[self.exerciseDict valueForKey:@"ExerciseID"] intValue];
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
        
        NSString *date_string = [dateFormatter stringFromDate:self.selectedDate];
        
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
        
    } else if (self.taskMode == DMTaskModeEdit) {
        int exerciseLogID = [[self.exerciseDict valueForKey:@"Exercise_Log_ID"] intValue];
        
        [db beginTransaction];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *date_string = [dateFormatter stringFromDate:[NSDate date]];
        
        NSString *updateQuery = [[NSString alloc] initWithFormat:@"UPDATE Exercise_Log SET Exercise_Time_Minutes = %i, Date_Modified = '%@' WHERE Exercise_Log_ID = %i", minutesExercised, date_string, exerciseLogID];
        
        [db executeUpdate:updateQuery];
        
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
        
    }

    DMMyLogDataProvider *provider = [[DMMyLogDataProvider alloc] init];
    [provider saveExerciseLogsWithCompletionBlock:nil];
    [DMActivityIndicator showCompletedIndicator];
    [[NSNotificationCenter defaultCenter] postNotificationName:DMReloadDataNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:DMTriggerUpSyncNotification object:nil];
    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
}

- (IBAction)delLog:(id) sender {
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }
    
    [db beginTransaction];
    
    int exerciseLogID = [[self.exerciseDict valueForKey:@"Exercise_Log_ID"] intValue];
    
    NSString *deleteQuery = [[NSString alloc] initWithFormat:@"DELETE FROM Exercise_Log WHERE Exercise_Log_ID = %i", exerciseLogID];
    
    [db executeUpdate:deleteQuery];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
    
    [DMActivityIndicator showCompletedIndicator];
    [[NSNotificationCenter defaultCenter] postNotificationName:DMReloadDataNotification object:nil];
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
    DayDataProvider *dayProvider = [DayDataProvider sharedInstance];
    
    int exerciseID = [[self.exerciseDict valueForKey:@"ExerciseID"] intValue];
    
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
        double caloriesPerHour = [[self.exerciseDict valueForKey:@"CaloriesPerHour"] floatValue];
        
        int hoursExercised = 0;
        double minutesExercised = 0;
        hoursExercised = [[self.pickerComponentOneArray objectAtIndex:[self.pickerView selectedRowInComponent:0]] intValue];
        minutesExercised = [[self.pickerComponentTwoArray objectAtIndex:[self.pickerView selectedRowInComponent:1]] intValue];
        minutesExercised = minutesExercised + (hoursExercised * 60);
        
        double totalCaloriesBurned = (caloriesPerHour / 60) * [dayProvider getCurrentWeight].floatValue * minutesExercised;
        
        self.caloriesBurnedLabel.text = [NSString stringWithFormat:@"%.f", totalCaloriesBurned];
    }
}

@end
