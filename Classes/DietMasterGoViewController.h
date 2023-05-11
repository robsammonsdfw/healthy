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
#import "MCPieChartView.h"
#import "MCSliceLayer.h"

//below added by Reema on date 15-11-2017 for circular progress bar 
#import "MBCircularProgressBar/MBCircularProgressBarView.h"

@class AppDelegate;

@interface DietMasterGoViewController : UIViewController <MBProgressHUDDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate,UINavigationControllerDelegate,WSWorkoutList,MCPieChartViewDataSource, MCPieChartViewDelegate> {
    
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
    
    IBOutlet UILabel *lblConsumed;
    IBOutlet UILabel *lblBurned;
    IBOutlet UILabel *lblSugar;
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
    IBOutlet UILabel *lblToGo_lbs;
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
    double num_totalCaloriesBurnedTracked;
    double num_totalCaloriesRemaining;

    double actualCarb;
    double recCarb;
    double ansactualCarb;
    
    double recprofitn;
    double actual;
    double ansis;
    
    double recFat;
    double actualfat;
    double actans;

    double totalSugar;
    double totalSugarValue;
    double totalFat;
    double totalProtein;
    double totalCarbs;
    double currentWeight;
    double startWeight;
    double currentHeight;
    
    CGFloat actualCarbCalories;
    CGFloat actualFatCalories;
    CGFloat actualProteinCalories;

    
    int num_BMR;
    
    MBProgressHUD *HUD;
    
    // Grams
    IBOutlet UILabel *actualFatGramsLabel;
    IBOutlet UILabel *actualCarbGramsLabel;
    IBOutlet UILabel *actualProteinGramsLabel;
    
    IBOutlet UILabel *recCarbLabel;
    IBOutlet UILabel *recProtLabel;
    IBOutlet UILabel *recFatLabel;
    IBOutlet UILabel *actualCarbLabel;
    IBOutlet UILabel *actualProtLabel;
    IBOutlet UILabel *actualFatLabel;

    
    IBOutlet UILabel *percentBodyFatLabel;
    
    
    //22nd May...
    IBOutlet UILabel *lblCurrentBMI;
    IBOutlet UILabel *lblBodyFat;
    
    IBOutlet UILabel *lblCaloriesRemainingValue;
    
    NSString *strWeightStatus;
    NSString *status;
    NSString *leftStatus;
    NSString *weightStatus;

    IBOutlet UIView *vwPadding;
    
    //HHT version 3.0 dynamic color changes
    IBOutlet UILabel *lblStaticRecomCalories;
    IBOutlet UIView *viewGoal;
    IBOutlet UIView *viewFood;
    IBOutlet UIView *viewExercise;
    IBOutlet UIView *viewNet;
    
    IBOutlet UILabel *lblStaticDailyTotals;
    IBOutlet UILabel *lblStaticGoalsSummary;
    
    IBOutlet UILabel *lblStepsCount;
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
@property (nonatomic, retain) NSArray *items;
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
@property (retain, nonatomic) IBOutlet UIView *circleHomeView;
@property (retain, nonatomic) IBOutlet UIView *entireView;
@property (retain, nonatomic) IBOutlet MCPieChartView *remaining_Pie;
@property (retain, nonatomic) IBOutlet MCPieChartView *cpf_Pie;
@property (retain, nonatomic) IBOutlet UILabel *cpfLbl;
@property (retain, nonatomic) IBOutlet UIStackView *hideShowStack;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *hideShowConstant;
@property (retain, nonatomic) IBOutlet UIView *firstExpandVw;
@property (retain, nonatomic) IBOutlet UIView *consumedView;
@property (retain, nonatomic) IBOutlet UIView *sugarView;
@property (retain, nonatomic) IBOutlet UIView *plannedView;
@property (retain, nonatomic) IBOutlet UIView *weightView;
@property (retain, nonatomic) IBOutlet UIView *stepsView;
@property (retain, nonatomic) IBOutlet UIView *burnedView;
@property (retain, nonatomic) IBOutlet UIView *workoutView;
@property (retain, nonatomic) IBOutlet UIView *scheduledView;

@property (retain, nonatomic) IBOutlet UIImageView *suagrGraphImageVw;
@property (retain, nonatomic) IBOutlet UILabel *seperateLineVw;
@property (retain, nonatomic) IBOutlet UILabel *cpf_PercentageLbl;
@property (retain, nonatomic) IBOutlet UILabel *c_PercentageLbl;
@property (retain, nonatomic) IBOutlet UILabel *p_PercentageLbl;
@property (retain, nonatomic) IBOutlet UILabel *f_PercentageLbl;
@property (retain, nonatomic) IBOutlet UIView *headerBlueVw;
@property (retain, nonatomic) IBOutlet UIImageView *cornerRadiImgVw;

@property (retain, nonatomic) IBOutlet NSLayoutConstraint *expandViewHeightConst;
@property (retain, nonatomic) IBOutlet UIButton *rightExpBtnAction;
@property (retain, nonatomic) IBOutlet UILabel *seperateLineLbl;
@property (retain, nonatomic) IBOutlet UIStackView *headerStackVw;
@property (retain, nonatomic) IBOutlet UIStackView *leftStackVw;
@property (retain, nonatomic) IBOutlet UIStackView *rightStackVw;
@property (retain, nonatomic) IBOutlet UIView *midLineVw;
@property (retain, nonatomic) IBOutlet UIView *secondExpandVw;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *secondExpandViewHeightConst;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *secondHideShowConstant;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *thirdExpVwHeightConst;
@property (retain, nonatomic) IBOutlet UIStackView *secondHideShowStackVw;
@property (retain, nonatomic) IBOutlet UIButton *consumedPlusBtn;
@property (retain, nonatomic) IBOutlet UIButton *plannedArroewBtn;
@property (retain, nonatomic) IBOutlet UIButton *weightPlusBtn;
@property (retain, nonatomic) IBOutlet UIButton *burnedPlusBtn;
@property (retain, nonatomic) IBOutlet UIButton *calPullDwnBtn;
@property (retain, nonatomic) IBOutlet UIButton *macrosPullDwnBtn;
@property (retain, nonatomic) IBOutlet UIButton *sendMsgBtnOutlet;
@property (retain, nonatomic) IBOutlet UILabel *nameLbl;
@property (retain, nonatomic) IBOutlet UIButton *popUpBtn;
@property (retain, nonatomic) IBOutlet UIView *showPopUpVw;
@property (retain, nonatomic) IBOutlet UIButton *weightPullDwnBtn;
@property (retain, nonatomic) IBOutlet UIStackView *weightHideShowStack;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *weightHideShowHeightConst;
@property (retain, nonatomic) IBOutlet UILabel *weightSeperatorLbl;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *stepsBottonConstrain;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *burnedBottonConstrain;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *thirtyConst;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *eightyConst;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIImageView *homeImage;
@property (retain, nonatomic) IBOutlet UIImageView *consumedImage;
@property (retain, nonatomic) IBOutlet UIImageView *plannedImage;
@property (retain, nonatomic) IBOutlet UIImageView *weightImage;
@property (retain, nonatomic) IBOutlet UIImageView *stepsImage;
@property (retain, nonatomic) IBOutlet UIImageView *burnedImage;
@property (retain, nonatomic) IBOutlet UIImageView *workoutImage;
@property (retain, nonatomic) IBOutlet UIImageView *scheduledImage;
@property (retain, nonatomic) IBOutlet UIButton *gotoWorkout;
@property (retain, nonatomic) IBOutlet UIButton *gotoScheduled;

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

