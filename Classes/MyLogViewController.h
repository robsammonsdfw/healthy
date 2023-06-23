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

@interface MyLogViewController : UIViewController <UIGestureRecognizerDelegate, TTTAttributedLabelDelegate> {
	
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

@property (nonatomic, strong) IBOutlet UIImageView *imgbottom;
@property (nonatomic, strong) NSDate *date_currentDate1;
@property (nonatomic, strong) NSNumber *int_mealID;
@property (nonatomic, strong) IBOutlet UITableView *tbl;
@property (nonatomic, strong) IBOutlet UIImageView *imgbottomline;
@property (assign, nonatomic, readonly) NSInteger primaryKey;
@property (nonatomic, strong) NSDate *date_currentDate;
@property (nonatomic, strong) UITableView *tblSimpleTable;
@property (nonatomic) int num_BMR;

@property (nonatomic, strong) IBOutlet UILabel *staticRecommendedLbl;
@property (nonatomic, strong) IBOutlet UILabel *staticRemainingLbl;
@property (nonatomic, strong) IBOutlet UILabel *staticRecCarbLbl;
@property (nonatomic, strong) IBOutlet UILabel *staticActualCarbLbl;
@property (nonatomic, strong) IBOutlet UILabel *staticRecProtLbl;
@property (nonatomic, strong) IBOutlet UILabel *staticActualProtLbl;
@property (nonatomic, strong) IBOutlet UILabel *staticRecFatLbl;
@property (nonatomic, strong) IBOutlet UILabel *staticActualFatLbl;
@property (nonatomic, strong) IBOutlet UILabel *staticCarbsLbl;
@property (nonatomic, strong) IBOutlet UILabel *staticProteinLbl;
@property (nonatomic, strong) IBOutlet UILabel *staticFatLbl;

//HHT apple watch
@property (nonatomic,retain) HKHealthStore *healthStore;
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) NSSet *readDataTypes;
@property (nonatomic, strong) StepData * sd;

-(void)getBMR;

-(IBAction)shownextDate:(id) sender;
-(IBAction)showprevDate:(id)sender;
-(IBAction)goToSafetyGuidelines:(id) sender;

-(void)updateData:(NSDate *)date;
-(void)loadExerciseData:(NSDate *)date;
-(void)updateCalorieTotal;
-(IBAction)saveFavoriteMeal:(id)sender;
-(void)saveFavoriteMealToDatabase:(id)sender;
-(void)reloadData;

@end
