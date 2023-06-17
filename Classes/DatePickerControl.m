//
//  DatePickerControl.m
//  DietMasterGo
//
//  Created by Andrew Moffitt on 3/11/11.
//  Copyright 2011 AE Studios. All rights reserved.
//

#import "DatePickerControl.h"

@implementation DatePickerControl

@synthesize date_currentDate, myDatePicker, apassedData, sourceName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"Date Picker";
    }
    return self;
}

-(id)initWithText:(NSString *)passedText passedData:(viewData *)dataParameter
{
	if (self = [self initWithNibName:@"DatePickerControl" bundle:nil]) {
		self.apassedData = dataParameter;
		self.sourceName= [apassedData fromView];
	}
	return self;
}

- (void)viewDidLoad {
	if(self.date_currentDate == NULL) {
        NSDate* sourceDate = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
        [dateFormat setTimeZone:systemTimeZone];
        NSString *date_string = [dateFormat stringFromDate:sourceDate];
        NSDate *date_today = [dateFormat dateFromString:date_string];
        
		self.date_currentDate = date_today;
	}
	
	if ([self.sourceName isEqualToString:@"DW_01New"]) {
		UILabel *lblBirthDate = [[UILabel alloc] initWithFrame:CGRectMake(85, 10, 175, 35)];
		[lblBirthDate setText:@"Enter Your Birthdate"];
		[lblBirthDate setTextColor:[UIColor whiteColor]];
		[lblBirthDate setBackgroundColor:[UIColor clearColor]];
		[self.view addSubview:lblBirthDate];
	}
	
	[myDatePicker setDate:date_currentDate animated:YES];	
    myDatePicker.maximumDate = [NSDate date];
	[super viewDidLoad];
}

-(IBAction)sendNewDate:(id) sender {
	
    if ([self.delegate respondsToSelector:@selector(dpControl:didChooseDate:)]) {
        [self.delegate dpControl:self didChooseDate:[myDatePicker date]];
    }
}

-(IBAction)cancelSaveDate:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
