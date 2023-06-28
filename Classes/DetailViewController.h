//
//  DetailViewController.h
//  DietMasterGo
//
//  Created by Andrew Moffitt on 1/5/11.
//  Copyright 2011 AE Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "DietmasterEngine.h"
#import "DMDataFetcher.h"

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
    
    int num_isFavorite;
    
    IBOutlet UIBarButtonItem *decimalButton;
    IBOutlet UIBarButtonItem *fractionButton;
    NSMutableArray *rowListArr;
}

@property (nonatomic, weak) NSString *foodIdValue;

/// Main inititalizer.
- (instancetype)initWithFood:(NSDictionary *)foodDict NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@end
