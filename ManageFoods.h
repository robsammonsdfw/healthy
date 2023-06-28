//
//  ManageFoods.h
//  DietMasterGo
//
//  Created by Andrew Moffitt on 8/19/11.
//  Copyright 2011 AE Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoodCategoryPicker.h"
#import "MeasurePicker.h"

@interface ManageFoods : UIViewController <UITextFieldDelegate, MeasurePickerDelegate, FoodCategoryDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate> {
		
	IBOutlet UIScrollView *scrollView;
	NSDate *date_currentDate;
	NSString *date_Today;
	NSString *date_Display;
	NSString *date_DB;
		
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
    
    IBOutlet UIButton *selectCategoryButton;
    IBOutlet UIButton *selectMeasureButton;
	IBOutlet UIToolbar *keyboardToolBar;
    IBOutlet UIBarButtonItem *closeDoneButton;
        
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
@property (nonatomic) NSInteger savedFoodID;
@property (nonatomic) BOOL saveToLog;
@property (nonatomic) BOOL hideAddToLog;
@property (nonatomic) int intTabId;

/// Main inititalizer.
- (instancetype)initWithFood:(NSDictionary *)foodDict NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@end



