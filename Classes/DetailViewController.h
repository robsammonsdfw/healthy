//
//  DetailViewController.h
//  DietMasterGo
//
//  Created by Andrew Moffitt on 1/5/11.
//  Copyright 2011 AE Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"
#import "DMMealPlanItem.h"
#import "DMMealPlan.h"

#define cSection1 0
#define cSection2 1
#define cSection3 2

@interface DetailViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {

	IBOutlet UILabel *lblText;
	IBOutlet UILabel *lblMealName;
	IBOutlet UIPickerView *pickerView;
	IBOutlet UILabel *lblCalories;
    IBOutlet UILabel *lblProtein;
	IBOutlet UILabel *lblCarbs;
	IBOutlet UILabel *lblFat;
    IBOutlet UIButton *infoBtn;
    
	NSNumber *pickerRow1;
	NSNumber *pickerRow2;
	NSNumber *pickerRow3;
	
	NSMutableArray *pickerColumn1Array;
	NSMutableArray *pickerColumn3Array;
    
    NSMutableArray *pickerFractionArray;
    NSMutableArray *pickerDecimalArray;
    BOOL fractionPicker;
        
    IBOutlet UIBarButtonItem *decimalButton;
    IBOutlet UIBarButtonItem *fractionButton;
    NSMutableArray *rowListArr;
}

/// The task mode that the controller is going to perform.
@property (nonatomic) DMTaskMode taskMode;

/// Main inititalizer.
- (instancetype)initWithFood:(DMFood *)food
                    mealCode:(DMLogMealCode)mealCode
            selectedServings:(NSNumber *)servings
                selectedDate:(NSDate *)selectedDate;

/// For dealing with meal plans.
- (instancetype)initWithFood:(DMFood *)food
                    mealCode:(DMLogMealCode)mealCode
            selectedServings:(NSNumber *)servings
                mealPlanItem:(DMMealPlanItem *)mealPlanItem
                    mealPlan:(DMMealPlan *)mealPlan
                selectedDate:(NSDate *)selectedDate NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@end
