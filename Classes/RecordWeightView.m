//
//  RecordWeightView.m
//  DietMasterGo
//
//  Created by Andrew Moffitt on 1/7/11.
//  Copyright 2011 AE Studios. All rights reserved.
//

#import "RecordWeightView.h"
#import "MyGoalViewController.h"
#import "DietmasterEngine.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

@interface RecordWeightView() <UITextFieldDelegate>

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) IBOutlet UIButton *btnrecordweight;
@property (nonatomic, strong) IBOutlet UITextField *txtfieldWeight;
@property (nonatomic, strong) IBOutlet UILabel *recordDate;
@property (nonatomic, strong) NSDate *date_currentDate;
@property (nonatomic, strong) NSString *date_Today;
@property (nonatomic, strong) NSString *date_Display;
@property (nonatomic, strong) NSString *date_DB;
@property (nonatomic, strong) IBOutlet UILabel *lblUnit;

@end

@implementation RecordWeightView

- (void)viewDidLoad {
    [super viewDidLoad];

    self.dateFormatter = [[NSDateFormatter alloc] init];
    
    self.btnrecordweight.backgroundColor = AppConfiguration.buttonColor;
    [self.btnrecordweight setTitleColor:AppConfiguration.buttonTextColor forState:UIControlStateNormal];
    self.btnrecordweight.layer.cornerRadius = 5;

	[self.txtfieldWeight becomeFirstResponder];

	[self setTitle:@"Log Weight"];
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Date"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(changeDate:)];
    editButton.tintColor = AppConfiguration.headerTextColor;
    self.navigationItem.rightBarButtonItem = editButton;
        
    if ([AppConfiguration.accountCode isEqualToString:@"ezdietplanner"]) {
        UIImageView *backgroundImage = (UIImageView *)[self.view viewWithTag:501];
        backgroundImage.image = [UIImage imageNamed:@"Log_Weight_Screen"];
    }
    
    [self updateDate];
    
    if (NSLocale.currentLocale.usesMetricSystem) {
        self.lblUnit.text = @"Kgs";
    } else {
        self.lblUnit.text = @"lbs";
    }
    self.lblUnit.textColor = [UIColor blackColor];
}

- (IBAction)changeDate:(id) sender {
    DMDatePickerViewController *dateController = [[DMDatePickerViewController alloc] init];
    [dateController setDate:self.date_currentDate];
    __weak typeof(self) weakSelf = self;
    dateController.didSelectDateCallback = ^(NSDate *date) {
        weakSelf.date_currentDate = date;
        [weakSelf updateDate];
    };
    [dateController presentPickerIn:self];
}

/// Changes the date that's displayed to the user.
- (void)updateDate {
    NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
    if (self.date_currentDate == NULL) {
        NSDate* sourceDate = [NSDate date];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
        [self.dateFormatter setTimeZone:systemTimeZone];
        NSString *date_string = [self.dateFormatter stringFromDate:sourceDate];
        NSDate *date_Now = [self.dateFormatter dateFromString:date_string];

        self.date_currentDate = date_Now;
    }
    
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [self.dateFormatter setTimeZone:systemTimeZone];
    self.date_Today = [self.dateFormatter stringFromDate:self.date_currentDate];
    
    [self.dateFormatter setDateFormat:@"MMMM d, yyyy"];
    [self.dateFormatter setTimeZone:systemTimeZone];
    self.date_Display    = [self.dateFormatter stringFromDate:self.date_currentDate];
    
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [self.dateFormatter setTimeZone:systemTimeZone];
    self.date_DB        = [self.dateFormatter stringFromDate:self.date_currentDate];
    
    self.recordDate.text = [NSString stringWithFormat: @"%@", self.date_Display];
}

- (IBAction)recordWeight:(id)sender {
	NSNumber *newWeight = [NSNumber numberWithDouble:[self.txtfieldWeight.text doubleValue]];
	if (newWeight.intValue <= 0) {
        [DMGUtilities showAlertWithTitle:@"Input Error" message:@"Please enter a valid weight." inViewController:nil];
        return;
	}
    
    NSString *strBodyfat = @"0";
    NSString *strEntryType = [NSString stringWithFormat:@"%li", DMWeightLogEntryTypeWeight];
    
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
        DMLog(@"Could not open db.");
    }

    [db beginTransaction];
    NSString *insertSQL = [NSString stringWithFormat: @"REPLACE INTO weightlog "
                           "(weight, logtime, deleted, entry_type, bodyfat) VALUES "
                           "(%@,'%@', 1, %@, %@)",
                           newWeight, self.date_Today, strEntryType, strBodyfat];
    [db executeUpdate:insertSQL];
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
    
    DMMyLogDataProvider *provider = [[DMMyLogDataProvider alloc] init];
    [provider saveWeightLogWithCompletionBlock:^(BOOL completed, NSError *error) {
        [DMActivityIndicator hideActivityIndicator];
        if (error) {
            [DMGUtilities showAlertWithTitle:@"Error" message:error.localizedDescription inViewController:nil];
            return;
        }
        [DMActivityIndicator showCompletedIndicator];
        [[NSNotificationCenter defaultCenter] postNotificationName:DMReloadDataNotification object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }];

}

@end
