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
#import "MealPlanWebService.h"
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
@property (nonatomic, strong) IBOutlet UIImageView *imgbar;

- (IBAction)delLog:(id) sender;
- (void) saveToLog:(id) sender;

@property (nonatomic, strong) NSMutableArray *pickerColumn1Array;
@property (nonatomic, strong) NSMutableArray *pickerColumn3Array;
@property (nonatomic, strong) NSMutableArray *pickerFractionArray;
@property (nonatomic, strong) NSMutableArray *pickerDecimalArray;
@property (nonatomic, strong) NSNumber *pickerRow1;
@property (nonatomic, strong) NSNumber *pickerRow2;
@property (nonatomic, strong) NSNumber *pickerRow3;

-(void)loadData;
-(void)cleanUpView;
-(void)showActionSheet:(id)sender;
-(void) deleteFromFavorites;
-(void)saveToFavorites;

-(void)updateCalorieCount;
-(NSString *)superScriptOf:(NSString *)inputNumber;
-(NSString *)subScriptOf:(NSString *)inputNumber;

-(IBAction)changePickerView:(id)sender;

-(void)exchangeFood;
-(void)updateFoodServings;
-(void)insertNewFood;
-(void)deleteFromPlan;

-(void)deleteFromWSLog;
-(void)deleteFromLog;
-(IBAction) goToSafetyGuidelines:(id) sender;

@property (nonatomic, strong) IBOutlet UILabel *staticCalLbl;
@property (nonatomic, strong) IBOutlet UILabel *staticProtFatCarbLbl;
@property (nonatomic, strong) IBOutlet UILabel *foodIdLbl;

@property (nonatomic, weak) NSString *foodIdValue;

@end
