//
//  ManageFoods.h
//  DietMasterGo
//
//  Created by Andrew Moffitt on 8/19/11.
//  Copyright 2011 AE Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "FoodCategoryPicker.h"
#import "MeasurePicker.h"
#import "MBProgressHUD.h"
#import "SaveUPCDataWebService.h"
#import "FactualQuery.h"

@class AppDelegate;

@interface ManageFoods : UIViewController <UITextFieldDelegate, MeasurePickerDelegate, FoodCategoryDelegate, UIImagePickerControllerDelegate, SaveUPCDataWSDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate> {
	
	AppDelegate *mainDelegate;
	
	IBOutlet UIScrollView *scrollView;
	NSDate *date_currentDate;
	NSString *date_Today;
	NSString *date_Display;
	NSString *date_DB;
	
	sqlite3 *database;
	NSString *dbPath;
	
	BOOL keyboardIsShown;
	BOOL ScannedFoodis;
	int intFoodID;
	NSNumber *intCategoryID;
	NSNumber *intMeasureID;
	NSString *strCategoryName;
	NSString *strMeasureName;
	UITextField *currentTextField;
			
	IBOutlet UITextField *txtfieldFoodName;
	IBOutlet UITextField *txtfieldCalories;
	IBOutlet UITextField *txtfieldTotalFat;
	IBOutlet UITextField *txtfieldSatFat;
	IBOutlet UITextField *txtfieldTransFat;
	IBOutlet UITextField *txtfieldCholesterol;
	IBOutlet UITextField *txtfieldSodium;
	IBOutlet UITextField *txtfieldPot;
	IBOutlet UITextField *txtfieldCarbs;
	IBOutlet UITextField *txtfieldFiber;
	IBOutlet UITextField *txtfieldSugars;
	IBOutlet UITextField *txtfieldProtein;
	IBOutlet UITextField *txtfieldCalcium;
	IBOutlet UITextField *txtfieldVitA;
	IBOutlet UITextField *txtfieldIron;
	IBOutlet UITextField *txtfieldVitD;
	IBOutlet UITextField *txtfieldThiamin;
	IBOutlet UITextField *txtfieldRib;
	IBOutlet UITextField *txtfieldNiacin;
	IBOutlet UITextField *txtfieldVitB6;
	IBOutlet UITextField *txtfieldFolicAcid;
	IBOutlet UITextField *txtfieldVitB12;
	IBOutlet UITextField *txtfieldAlcohol;
	IBOutlet UITextField *txtfieldMag;
	IBOutlet UITextField *txtfieldZinc;
	IBOutlet UITextField *txtfieldFolate;
	IBOutlet UITextField *txtfieldVitC;
	IBOutlet UITextField *txtfieldVitE;
	IBOutlet UITextField *txtfieldServingSize;
    
    // Henry mods
    IBOutlet UIButton *selectCategoryButton;
    IBOutlet UIButton *selectMeasureButton;
	IBOutlet UIToolbar *keyboardToolBar;
    IBOutlet UIBarButtonItem *closeDoneButton;
    
    
    NSMutableDictionary *selectedFoodDict;
    
    BOOL reloadData;
    
    NSMutableDictionary *scannerDict;
    NSString *scanned_UPCA;
    NSString *scanned_factualID;
    IBOutlet UIButton *scannerButton;
    
    BOOL isSaved;
    
    NSDictionary *upcDict;
}

@property (nonatomic, strong) AppDelegate *mainDelegate;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic) int intFoodID;
@property (nonatomic,retain) NSNumber *intCategoryID;
@property (nonatomic,retain) NSString *strCategoryName;
@property (nonatomic,retain) NSNumber *intMeasureID;
@property (nonatomic,retain) NSString *strMeasureName;
@property (nonatomic,retain) NSMutableDictionary *scannerDict;
@property (nonatomic,retain) NSString *scanned_UPCA;
@property (nonatomic,retain) NSString *scanned_factualID;
@property (nonatomic,retain) IBOutlet UIButton *scannerButton;

@property (nonatomic,retain) NSMutableDictionary *selectedFoodDict;

@property (nonatomic) NSInteger savedFoodID;
@property (nonatomic) BOOL saveToLog;
@property (nonatomic) BOOL hideAddToLog;

//HHT
@property (nonatomic) int intTabId;

- (IBAction) getCategory:(id) sender;
- (IBAction) getMeasure:(id) sender;

-(void)loadData;
-(void)updateFood:(id)sender;
-(void) recordFood:(id) sender;

-(void)clearEnteredData;
-(IBAction)nextTextField:(id)sender;
-(IBAction)previousTextField:(id)sender;
-(IBAction)dismissKeyboard:(id)sender;

-(IBAction)loadBarcodeScanner:(id)sender;
-(void)barcodeWasScanned:(NSNotification *)notification;

-(void)factualAPISuccess:(NSNotification *)notification;
-(void)factualAPIDidFail:(NSNotification *)notification;
-(void)tappedScrollView:(id)sender;

-(void)customBackAction:(id)sender;

-(void)foodWasSavedToCloud:(NSNotification *)notification;

@end



