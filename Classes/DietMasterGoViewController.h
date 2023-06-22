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

/// The "tile layout" home screen for a user to move around the app.
@interface DietMasterGoViewController : UIViewController <MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, MCPieChartViewDataSource, MCPieChartViewDelegate> {
    
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

@property (nonatomic, strong) IBOutlet UIImageView *imglinetop;

-(void) getBMR;
@property (nonatomic, strong) IBOutlet UIImageView *imghomescreenbg;
@property (nonatomic, strong) IBOutlet UIImageView *imgtop1;
@property (nonatomic, strong) IBOutlet UIImageView *imgtop2;
@property (nonatomic, strong) IBOutlet UIImageView *imgtop3;
@property (nonatomic, strong) IBOutlet UIImageView *imgtop4;

@property (nonatomic, strong) NSDate *date_currentDate;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic) int num_BMR;

@property (nonatomic, strong) IBOutlet MBCircularProgressBarView *remainingCalories_Circular_Progress;
@property (nonatomic, strong) IBOutlet MBCircularProgressBarView *fat_circular;
@property (nonatomic, strong) IBOutlet MBCircularProgressBarView *protein_Circular;
@property (nonatomic, strong) IBOutlet MBCircularProgressBarView *carbs_circular;
@property (nonatomic, strong) IBOutlet YLProgressBar *progressbar;

@property (nonatomic, strong) IBOutlet UIView *fatBMIview;
@property (nonatomic, strong) IBOutlet UIView *startGoalView;
@property (nonatomic, strong) IBOutlet UIView *smallCriclesContainingView;
@property (nonatomic, strong) IBOutlet UIImageView *fatSmallCircleImg;
@property (nonatomic, strong) IBOutlet UIImageView *proteinSmallCircleImg;
@property (nonatomic, strong) IBOutlet UIImageView *carbSmallCircleImg;
@property (nonatomic, strong) IBOutlet UIImageView *bigCircleImg;
@property (nonatomic, strong) IBOutlet UIImageView *progressBarImg;
-(IBAction) showGroceryList:(id) sender;
-(IBAction) showManageFoods:(id) sender;
@property (nonatomic, strong) IBOutlet UIView *circleHomeView;
@property (nonatomic, strong) IBOutlet UIView *entireView;
@property (nonatomic, strong) IBOutlet MCPieChartView *remaining_Pie;
@property (nonatomic, strong) IBOutlet MCPieChartView *cpf_Pie;
@property (nonatomic, strong) IBOutlet UILabel *cpfLbl;
@property (nonatomic, strong) IBOutlet UIStackView *hideShowStack;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *hideShowConstant;
@property (nonatomic, strong) IBOutlet UIView *firstExpandVw;
@property (nonatomic, strong) IBOutlet UIView *consumedView;
@property (nonatomic, strong) IBOutlet UIView *sugarView;
@property (nonatomic, strong) IBOutlet UIView *plannedView;
@property (nonatomic, strong) IBOutlet UIView *weightView;
@property (nonatomic, strong) IBOutlet UIView *stepsView;
@property (nonatomic, strong) IBOutlet UIView *burnedView;
@property (nonatomic, strong) IBOutlet UIView *workoutView;
@property (nonatomic, strong) IBOutlet UIView *scheduledView;

@property (nonatomic, strong) IBOutlet UIImageView *suagrGraphImageVw;
@property (nonatomic, strong) IBOutlet UILabel *seperateLineVw;
@property (nonatomic, strong) IBOutlet UILabel *cpf_PercentageLbl;
@property (nonatomic, strong) IBOutlet UILabel *c_PercentageLbl;
@property (nonatomic, strong) IBOutlet UILabel *p_PercentageLbl;
@property (nonatomic, strong) IBOutlet UILabel *f_PercentageLbl;
@property (nonatomic, strong) IBOutlet UIView *headerBlueVw;
@property (nonatomic, strong) IBOutlet UIImageView *cornerRadiImgVw;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *expandViewHeightConst;
@property (nonatomic, strong) IBOutlet UIButton *rightExpBtnAction;
@property (nonatomic, strong) IBOutlet UILabel *seperateLineLbl;
@property (nonatomic, strong) IBOutlet UIStackView *headerStackVw;
@property (nonatomic, strong) IBOutlet UIStackView *leftStackVw;
@property (nonatomic, strong) IBOutlet UIStackView *rightStackVw;
@property (nonatomic, strong) IBOutlet UIView *midLineVw;
@property (nonatomic, strong) IBOutlet UIView *secondExpandVw;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *secondExpandViewHeightConst;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *secondHideShowConstant;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *thirdExpVwHeightConst;
@property (nonatomic, strong) IBOutlet UIStackView *secondHideShowStackVw;
@property (nonatomic, strong) IBOutlet UIButton *consumedPlusBtn;
@property (nonatomic, strong) IBOutlet UIButton *plannedArroewBtn;
@property (nonatomic, strong) IBOutlet UIButton *weightPlusBtn;
@property (nonatomic, strong) IBOutlet UIButton *burnedPlusBtn;
@property (nonatomic, strong) IBOutlet UIButton *calPullDwnBtn;
@property (nonatomic, strong) IBOutlet UIButton *macrosPullDwnBtn;
@property (nonatomic, strong) IBOutlet UIButton *sendMsgBtnOutlet;
@property (nonatomic, strong) IBOutlet UILabel *nameLbl;
@property (nonatomic, strong) IBOutlet UIButton *popUpBtn;
@property (nonatomic, strong) IBOutlet UIButton *weightPullDwnBtn;
@property (nonatomic, strong) IBOutlet UIStackView *weightHideShowStack;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *weightHideShowHeightConst;
@property (nonatomic, strong) IBOutlet UILabel *weightSeperatorLbl;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *stepsBottonConstrain;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *burnedBottonConstrain;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *thirtyConst;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *eightyConst;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIImageView *homeImage;
@property (nonatomic, strong) IBOutlet UIImageView *consumedImage;
@property (nonatomic, strong) IBOutlet UIImageView *plannedImage;
@property (nonatomic, strong) IBOutlet UIImageView *weightImage;
@property (nonatomic, strong) IBOutlet UIImageView *stepsImage;
@property (nonatomic, strong) IBOutlet UIImageView *burnedImage;
@property (nonatomic, strong) IBOutlet UIImageView *workoutImage;
@property (nonatomic, strong) IBOutlet UIImageView *scheduledImage;
@property (nonatomic, strong) IBOutlet UIButton *gotoWorkout;
@property (nonatomic, strong) IBOutlet UIButton *gotoScheduled;

// New methods by henry
-(void)loadData;
-(void)loadExerciseData;
-(void)updateCalorieTotal;
-(void)calculateBMI;
-(void)reloadData;

@end

