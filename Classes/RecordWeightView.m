//
//  RecordWeightView.m
//  DietMasterGo
//
//  Created by Andrew Moffitt on 1/7/11.
//  Copyright 2011 AE Studios. All rights reserved.
//

#import "RecordWeightView.h"
#import "MyGoalViewController.h"
#import "DietMasterGoAppDelegate.h"
#import "DietmasterEngine.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

@implementation RecordWeightView

@synthesize mainDelegate, recordDate, date_currentDate, date_Today, date_Display, date_DB;

- (void)viewDidLoad {
    self.btnrecordweight.backgroundColor=PrimaryColor
	_btnrecordweight.layer.cornerRadius=5;

	[txtfieldWeight becomeFirstResponder];
	
    DietmasterEngine *dietEngine = [DietmasterEngine sharedInstance];
	dbPath	= [dietEngine databasePath];

	[self setTitle:@"Log Weight"];
    
    NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];

	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd"];
    [dateFormat setTimeZone:systemTimeZone];

	NSDateFormatter *dateFormat_display = [[NSDateFormatter alloc] init];
	[dateFormat_display setDateFormat:@"MMMM d, yyyy"];
    [dateFormat_display setTimeZone:systemTimeZone];

	NSDateFormatter *dateFormat_db = [[NSDateFormatter alloc] init];
	[dateFormat_db setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormat_db setTimeZone:systemTimeZone];

	if(self.date_currentDate == NULL) {
        NSDate* sourceDate = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
        [dateFormat setTimeZone:systemTimeZone];
        NSString *date_string = [dateFormat stringFromDate:sourceDate];
        NSDate *date_Now = [dateFormat dateFromString:date_string];

		self.date_currentDate = date_Now;
	}
	
	self.date_Today		= [dateFormat stringFromDate:date_currentDate];
	self.date_Display	= [dateFormat_display stringFromDate:date_currentDate];
	self.date_DB		= [dateFormat_db stringFromDate:date_currentDate];
	
	recordDate.text = [NSString stringWithFormat: @"%@", date_Display];
	
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Date"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(changeDate:)];
    self.navigationItem.rightBarButtonItem = editButton;
    
	[super viewDidLoad];
    
	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSString *finalPath = [path stringByAppendingPathComponent:PLIST_NAME];
	NSDictionary *appDefaults = [[NSDictionary alloc] initWithContentsOfFile:finalPath];
    UIImageView *backgroundImage = (UIImageView *)[self.view viewWithTag:501];
    if ([[appDefaults valueForKey:@"account_code"] isEqualToString:@"ezdietplanner"]) {
        backgroundImage.image = [UIImage imageNamed:@"Log_Weight_Screen"];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"isKgs"] boolValue]) {
        lblUnit.text = @"lbs";
    }
    else {
        lblUnit.text = @"Kgs";
    }
}

- (IBAction) changeDate:(id) sender {
	DatePickerControl *dpControl = [[DatePickerControl alloc] initWithNibName:@"DatePickerControl" bundle:nil];
	dpControl.delegate = self;
	dpControl.date_currentDate	= date_currentDate;
    [self presentViewController:dpControl animated:YES completion:nil];
	dpControl = nil;
}

-(void)dpControl:(DatePickerControl *)controller didChooseDate:(NSDate *)chosenDate {
	[self dismissViewControllerAnimated:YES completion:nil];
	self.date_currentDate = chosenDate;
	[self viewDidLoad];
}

-(IBAction) recordWeight:(id) sender {
	UIAlertView *view;
	NSNumber *newWeight = [NSNumber numberWithDouble:[txtfieldWeight.text doubleValue]];
    
	if (newWeight.intValue == 0) {
		
		view = [[UIAlertView alloc]
				initWithTitle: @"Input Error"
				message: @"Please Enter a Weight!"
				delegate: self
				cancelButtonTitle: @"OK"
				otherButtonTitles: nil];
		[view show];
	}
    else {
        NSString *strBodyfat = @"0";
        NSString *strEntryType = [NSString stringWithFormat:@"%d", WEIGHT_ENTRY];
        DietmasterEngine* dietmasterEnginePath = [DietmasterEngine sharedInstance];
        FMDatabase* tempdb = [FMDatabase databaseWithPath:[dietmasterEnginePath databasePath]];
        
        if (![tempdb open]) {
             DMLog(@"Could not open db.");
        }

        NSString *strQuery = [NSString stringWithFormat:@"SELECT entry_type, bodyfat FROM weightlog where logtime =\"%@\"", date_Today];
        
        FMResultSet *rs = [tempdb executeQuery:strQuery];
        while ([rs next]) {
            strBodyfat = [NSString stringWithFormat:@"%f", [rs doubleForColumn:@"bodyfat"]];
            strEntryType = [NSString stringWithFormat:@"%d", [rs intForColumn:@"entry_type"]];
        }

        NSString *insertSQL = [NSString stringWithFormat: @"REPLACE INTO weightlog (weight,logtime, deleted, entry_type, bodyfat) VALUES (%f,'%@', 1, %@, %@)", [newWeight doubleValue], date_Today, strEntryType, strBodyfat];

        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
        if (![db open]) {
            DMLog(@"Could not open db.");
        }
        
        [db beginTransaction];
        [db executeUpdate:insertSQL];
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
        
        [self performSelector:@selector(showCompleted) withObject:nil afterDelay:0.25];
        [self.navigationController popViewControllerAnimated:YES];
	}	
}

@end
