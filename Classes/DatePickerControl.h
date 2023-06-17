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
}

- (IBAction)sendNewDate:(id) sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (id)initWithText:(NSString *)text passedData:(viewData *)somePassedData;
- (IBAction)cancelSaveDate:(id)sender;

@property (nonatomic, strong) NSDate *date_currentDate;
@property (nonatomic, strong) IBOutlet UIDatePicker *myDatePicker;
@property (nonatomic, strong) NSString *sourceName;
@property (nonatomic, strong) viewData *apassedData;
@property (nonatomic, weak) id<DatePickerViewControllerDelegate> delegate;

@end

@protocol DatePickerViewControllerDelegate <NSObject>
@optional
- (void)dpControl:(DatePickerControl *)controller didChooseDate:(NSDate *)chosenDate;
@end
