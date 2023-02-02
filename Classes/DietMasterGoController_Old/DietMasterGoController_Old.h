//
//  DietMasterGoViewController.h
//  DietMasterGo
//
//  Created by Andrew Moffitt on 11/23/10.
//  Copyright 2010 AE Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "DietmasterEngine.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "DietMasterGoAppDelegate.h"
#import "YLProgressBar.h"
#import "MyMovesWebServices.h"

//below added by Reema on date 15-11-2017 for circular progress bar
//#import "MBCircularProgressBar/MBCircularProgressBarView.h"
#import "MBCircularProgressBarView.h"

@class AppDelegate;

@interface DietMasterGoController_Old : UIViewController <MBProgressHUDDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate,UINavigationControllerDelegate,WSWorkoutList> {
    
    AppDelegate *appddd;
    
    IBOutlet UILabel *lbl_CaloriesLogged;
    IBOutlet UILabel *lbl_CaloriesRecommended;
    IBOutlet UILabel *lbl_GoalWeight;
    IBOutlet UILabel *lbl_CurrentWeight;
    IBOutlet UILabel *lbl_CalorieDifference;
    
    IBOutlet UILabel *goalCalorieLabel;
    IBOutlet UILabel *caloriesLoggedLabel;
    IBOutlet UILabel *exerciseCaloriesLoggedLabel;
    IBOutlet UILabel *netCalorieLabel;
    
    IBOutlet UILabel *totalFatLabel;
    IBOutlet UILabel *totalProteinLabel;
    IBOutlet UILabel *totalCarbsLabel;
    
    IBOutlet UILabel *currentBMILabel;
    
    //New change according to new DesingOutlet (Reema)-
    IBOutlet UILabel *lblGoal;
    IBOutlet UILabel *lblfoodCalories;
    IBOutlet UILabel *lblExerciseCalories;
    IBOutlet UILabel *lblNetCalories;
    
    IBOutlet UILabel *lblFatPercent;
    IBOutlet UILabel *lblProtinPercent;
    IBOutlet UILabel *lblCarbsPercent;
    
    IBOutlet UILabel *lblStart_lbs;
    IBOutlet UILabel *lblGoal_lbs;
    
    IBOutlet UILabel *lblWeightStatus;
    IBOutlet UILabel *lblWeight;
    IBOutlet UILabel *lblBody_Fat;
    IBOutlet UILabel *lblCurrent_BMI;
    IBOutlet UILabel *lblActualFat;
    IBOutlet UILabel *lblActualProtein;
    IBOutlet UILabel *lblActualCarbs;
    
    IBOutlet UILabel *staticGoalLbl;
    IBOutlet UILabel *staticFoodLbl;
    IBOutlet UILabel *staticExerciseLbl;
    IBOutlet UILabel *staticNetLbl;
    
    
    double num_Calories;
    double num_totalCalories;
    double num_totalCaloriesBurned;
    
    double totalFat;
    double totalProtein;
    double totalCarbs;
    double currentWeight;
    double startWeight;
    double currentHeight;
    
    int num_BMR;
    
    MBProgressHUD *HUD;
    
    // Grams
    IBOutlet UILabel *actualFatGramsLabel;
    IBOutlet UILabel *actualCarbGramsLabel;
    IBOutlet UILabel *actualProteinGramsLabel;
    
    IBOutlet UILabel *percentBodyFatLabel;
    
    
    //22nd May...
    IBOutlet UILabel *lblCurrentBMI;
    IBOutlet UILabel *lblBodyFat;
    
    IBOutlet UILabel *lblCaloriesRemainingValue;
    
    NSString *strWeightStatus;
    
    IBOutlet UIView *vwPadding;
    
    //HHT version 3.0 dynamic color changes
    IBOutlet UILabel *lblStaticRecomCalories;
//    IBOutlet UIView *viewGoal;
//    IBOutlet UIView *viewFood;
//    IBOutlet UIView *viewExercise;
//    IBOutlet UIView *viewNet;
    
    IBOutlet UIView *viewGoal;
    IBOutlet UIView *viewFood;
    IBOutlet UIView *viewExercise;
    IBOutlet UIView *viewNet;
    
    IBOutlet UILabel *lblStaticDailyTotals;
    IBOutlet UILabel *lblStaticGoalsSummary;
    
    //HHT change 2018
    IBOutlet UILabel *lblProgressBarCurrentWeight;
    
    //new design v3.0 (HHT change 2018) circular lable value
    IBOutlet UILabel *lblactualFatGramsLabel;
    IBOutlet UILabel *lblactualCarbGramsLabel;
    IBOutlet UILabel *lblactualProteinGramsLabel;
    
    //HHT change 2018 (Scroll view added)
    IBOutlet UIScrollView *scrollViewMain;
}

@property (retain, nonatomic) IBOutlet UIImageView *imglinetop;

-(void) getBMR;
@property (retain, nonatomic) IBOutlet UIImageView *imghomescreenbg;
@property (retain, nonatomic) IBOutlet UIImageView *imgtop1;
@property (retain, nonatomic) IBOutlet UIImageView *imgtop2;
@property (retain, nonatomic) IBOutlet UIImageView *imgtop3;
@property (retain, nonatomic) IBOutlet UIImageView *imgtop4;

@property (nonatomic, retain) NSDate *date_currentDate;
@property (nonatomic) int num_BMR;

@property (retain, nonatomic) IBOutlet MBCircularProgressBarView *remainingCalories_Circular_Progress;
@property (retain, nonatomic) IBOutlet MBCircularProgressBarView *fat_circular;
@property (retain, nonatomic) IBOutlet MBCircularProgressBarView *protein_Circular;
@property (retain, nonatomic) IBOutlet MBCircularProgressBarView *carbs_circular;
@property (retain, nonatomic) IBOutlet YLProgressBar *progressbar;

@property (retain, nonatomic) IBOutlet UIView *fatBMIview;
@property (retain, nonatomic) IBOutlet UIView *startGoalView;
@property (retain, nonatomic) IBOutlet UIView *smallCriclesContainingView;
@property (retain, nonatomic) IBOutlet UIImageView *fatSmallCircleImg;
@property (retain, nonatomic) IBOutlet UIImageView *proteinSmallCircleImg;
@property (retain, nonatomic) IBOutlet UIImageView *carbSmallCircleImg;
@property (retain, nonatomic) IBOutlet UIImageView *bigCircleImg;
@property (retain, nonatomic) IBOutlet UIImageView *progressBarImg;
-(IBAction) showGroceryList:(id) sender;
-(IBAction) showManageFoods:(id) sender;

// New methods by henry
-(void)showLoading;
-(void)hideLoading;
- (void)showCompleted;
-(void)loadData;
-(void)loadExerciseData;
-(void)updateCalorieTotal;
-(void)calculateBMI;
-(void)reloadData;

// for help and support
-(IBAction)showActionSheet:(id)sender;
-(void)emailUs:(id)sender;

@end

