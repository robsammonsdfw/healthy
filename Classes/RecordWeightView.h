//
//  RecordWeightView.h
//  DietMasterGo
//
//  Created by Andrew Moffitt on 1/7/11.
//  Copyright 2011 AE Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "DatePickerControl.h"
#import "MBProgressHUD.h"

@class AppDelegate;

@interface RecordWeightView : UIViewController <UITextFieldDelegate> {
	IBOutlet UITextField *txtfieldWeight;
	IBOutlet UILabel *recordDate;
	
	AppDelegate *mainDelegate;
	NSDate *date_currentDate;
	NSString *date_Today;
	NSString *date_Display;
	NSString *date_DB;
	sqlite3 *database;
	NSString *dbPath;
    
    IBOutlet UILabel *lblUnit;
}

@property (nonatomic, strong) IBOutlet UIButton *btnrecordweight;
@property (nonatomic, strong) AppDelegate *mainDelegate;
@property (nonatomic, strong) UILabel *recordDate;
@property (nonatomic, strong) NSDate *date_currentDate;
@property (nonatomic, strong) NSString *date_Today;
@property (nonatomic, strong) NSString *date_Display;
@property (nonatomic, strong) NSString *date_DB;

- (IBAction) recordWeight:(id) sender;
- (IBAction) changeDate:(id) sender;

@end
