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
#import "SoapWebServiceEngine.h"

#define cSection1 0
#define cSection2 1
#define cSection3 2

@interface DetailViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate, MBProgressHUDDelegate, WSUpdateUserPlannedMealItems, WSDeleteMealItemDelegate, WSInsertUserPlannedMealItems, WSDeleteUserPlannedMealItems, WSDeleteFavoriteFoodDelegate> {

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
    MBProgressHUD *HUD;
    
    IBOutlet UIBarButtonItem *decimalButton;
    IBOutlet UIBarButtonItem *fractionButton;
    NSMutableArray *rowListArr;

}
@property (retain, nonatomic) IBOutlet UIImageView *imgbar;

- (IBAction)delLog:(id) sender;
- (void) saveToLog:(id) sender;

@property (nonatomic, retain) NSMutableArray *pickerColumn1Array;
@property (nonatomic, retain) NSMutableArray *pickerColumn3Array;
@property (nonatomic, retain) NSMutableArray *pickerFractionArray;
@property (nonatomic, retain) NSMutableArray *pickerDecimalArray;
@property (nonatomic, retain) NSNumber *pickerRow1;
@property (nonatomic, retain) NSNumber *pickerRow2;
@property (nonatomic, retain) NSNumber *pickerRow3;

-(void)loadData;
-(void)cleanUpView;
-(void)showActionSheet:(id)sender;
-(void) deleteFromFavorites;
-(void)saveToFavorites;

-(void)showLoading;
-(void)hideLoading;
-(void)showCompleted;
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
-(NSMutableArray *) filterObjectsByKeys:(NSString *) key array:(NSMutableArray *)array;
-(IBAction) goToSafetyGuidelines:(id) sender;

@property (retain, nonatomic) IBOutlet UILabel *staticCalLbl;
@property (retain, nonatomic) IBOutlet UILabel *staticProtFatCarbLbl;
@property (retain, nonatomic) IBOutlet UILabel *foodIdLbl;

@property (nonatomic, weak) NSString *foodIdValue;

@end
