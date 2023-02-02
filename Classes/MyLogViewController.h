//
//  MyLogViewController.h
//  DietMasterGo
//
//  Created by Andrew Moffitt on 11/23/10.
//  Copyright 2010 AE Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
// FMDB
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "DietmasterEngine.h"

#import "FoodsSearch.h"

#import <HealthKit/HealthKit.h>
#import "StepData.h"
#import "MyMovesWebServices.h"
#import "TTTAttributedLabel.h"
#import "DietMasterGoViewController.h"
#import "MyLogViewController.h"
#import "MyGoalViewController.h"
#import "MealPlanViewController.h"
#import "AppSettings.h"
#import "PopUpView.h"


@interface MyLogViewController : UIViewController <MBProgressHUDDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate, TTTAttributedLabelDelegate> {
	
	IBOutlet UITableView *tblSimpleTable;
	IBOutlet UILabel *lbl_dateHdr;
	IBOutlet UILabel *lbl_CaloriesLogged;
	IBOutlet UILabel *lbl_CaloriesRecommended;
    IBOutlet UIButton *infoBtn;

	int int_foodID;
	double num_totalCalories;
    double num_totalCaloriesBurned;
	int num_BMR;
	
	NSDate *date_currentDate;
	NSNumber *int_mealID;
	
    IBOutlet UIActivityIndicatorView *cellSpinner;
    
    MBProgressHUD *HUD;
    NSMutableArray *exerciseResults;
    NSMutableArray *foodResults;
	
	double Remanig;
	double Recommendded;
	double calorieslodded;
	double exerciseloged;
	
	double actualCarb;
	double recCarb;
	double ansactualCarb;
	
	double recprofitn;
	double actual;
	double ansis; 

	double recFat;
	double actualfat;
	double actans;
    
    // Favorite Meals
    NSString *favoriteMealName;
    int favoriteMealSectionID;
	
	NSString *selectedFood;
    
    int breakfastCalories;
    int snack1Calories;
    int lunchCalories;
    int snack2Calories;
    int dinnerCalories;
    int snack3Calories;
    
    // day detail view
    IBOutlet UIView *dayDetailView;
    BOOL detailViewInView;
    CGRect closedDetailRect;
    CGRect openedDetailRect;
    IBOutlet UIButton *openCloseDetailButton;
    // labels
    IBOutlet UILabel *recCarbLabel;
    IBOutlet UILabel *recProtLabel;
    IBOutlet UILabel *recFatLabel;
    IBOutlet UILabel *actualCarbLabel;
    IBOutlet UILabel *actualProtLabel;
    IBOutlet UILabel *actualFatLabel;
    // values
    CGFloat actualCarbCalories;
    CGFloat actualFatCalories;
    CGFloat actualProteinCalories;
    
    UIImageView *imgSwipeHint;
    
    IBOutlet UIToolbar *dateToolBar;
	
	NSMutableArray *Arrcatgory;
	
	NSDate *date_currentDate1;

	NSMutableArray *selectSectionArray;
	BOOL isExerciseData;
    
    //HHT apple watch
    int exerciseLogID;
    MyMovesWebServices *soapWebService;
}

@property (retain, nonatomic) IBOutlet UIImageView *imgbottom;
@property (nonatomic, retain) NSDate *date_currentDate1;
@property (nonatomic, retain) NSNumber *int_mealID;
@property (retain, nonatomic) IBOutlet UITableView *tbl;
@property (retain, nonatomic) IBOutlet UIImageView *imgbottomline;
@property (assign, nonatomic, readonly) NSInteger primaryKey;
@property (nonatomic, retain) NSDate *date_currentDate;
@property (nonatomic, retain) UITableView *tblSimpleTable;
@property (nonatomic) int num_BMR;
@property (nonatomic, retain) IBOutlet UIView *dayDetailView;

@property (retain, nonatomic) IBOutlet UILabel *staticRecommendedLbl;
@property (retain, nonatomic) IBOutlet UILabel *staticRemainingLbl;
@property (retain, nonatomic) IBOutlet UILabel *staticRecCarbLbl;
@property (retain, nonatomic) IBOutlet UILabel *staticActualCarbLbl;
@property (retain, nonatomic) IBOutlet UILabel *staticRecProtLbl;
@property (retain, nonatomic) IBOutlet UILabel *staticActualProtLbl;
@property (retain, nonatomic) IBOutlet UILabel *staticRecFatLbl;
@property (retain, nonatomic) IBOutlet UILabel *staticActualFatLbl;
@property (retain, nonatomic) IBOutlet UILabel *staticCarbsLbl;
@property (retain, nonatomic) IBOutlet UILabel *staticProteinLbl;
@property (retain, nonatomic) IBOutlet UILabel *staticFatLbl;

@property (retain, nonatomic) IBOutlet UIView *showPopUpVw;
@property (retain, nonatomic) IBOutlet UIView *overallView;

@property (retain, nonatomic) IBOutlet UIView *vw;

//HHT apple watch
@property(nonatomic,retain) HKHealthStore *healthStore;
@property(nonatomic, strong) NSMutableArray *arrData;
@property(nonatomic, strong) NSSet *readDataTypes;
@property(nonatomic, strong) StepData * sd;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *whiteViewHeightConst;

-(void) getBMR;

-(IBAction) showLogAdd:(id) sender;
-(IBAction) shownextDate:(id) sender;
-(IBAction)showprevDate:(id)sender;
-(IBAction) goToSafetyGuidelines:(id) sender;

-(void)updateData:(NSDate *)date;
-(void)showLoading;
-(void)hideLoading;
-(void)showCompleted;
-(void)loadExerciseData:(NSDate *)date;
-(void)updateCalorieTotal;
-(IBAction)saveFavoriteMeal:(id)sender;
-(void)saveFavoriteMealToDatabase:(id)sender;
-(void)reloadData;
-(IBAction)showHideDetailView:(id)sender;
-(void)movedDetailView:(id)sender;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *popUpVwBottonContrain;

@end
