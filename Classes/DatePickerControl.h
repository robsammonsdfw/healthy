//
//  DatePickerControl.h
//  DietMasterGo
//
//  Created by Andrew Moffitt on 3/11/11.
//  Copyright 2011 AE Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "viewData.h"

@protocol DatePickerViewControllerDelegate;

@interface DatePickerControl : UIViewController {

	IBOutlet UIDatePicker *myDatePicker;
	NSDate *date_currentDate;
	viewData *apassedData;
	NSString *sourceName;
	id delegate;
}

- (IBAction) sendNewDate:(id) sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (id)initWithText:(NSString *)text passedData:(viewData *)somePassedData;
- (IBAction)cancelSaveDate:(id)sender;

@property (nonatomic, retain) NSDate *date_currentDate;
@property (nonatomic, retain) IBOutlet UIDatePicker *myDatePicker;
@property (nonatomic,retain) NSString *sourceName;
@property (nonatomic,retain) viewData *apassedData;
@property (assign) id delegate;

@end

@protocol DatePickerViewControllerDelegate
@optional
-(void)dpControl:(DatePickerControl *)controller didChooseDate:(NSDate *)chosenDate;

@end
