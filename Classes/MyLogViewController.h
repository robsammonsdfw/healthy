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
#import "MyMovesDataProvider.h"
#import "TTTAttributedLabel.h"
#import "DietMasterGoViewController.h"
#import "MyLogViewController.h"
#import "MyGoalViewController.h"
#import "MealPlanViewController.h"

@interface MyLogViewController : UIViewController <UIGestureRecognizerDelegate, TTTAttributedLabelDelegate> {
	
	IBOutlet UILabel *lbl_dateHdr;
	IBOutlet UILabel *lbl_CaloriesLogged;
	IBOutlet UILabel *lbl_CaloriesRecommended;
    IBOutlet UIButton *infoBtn;

	int int_foodID;
	
	NSDate *date_currentDate;
	NSNumber *int_mealID;
	
	NSString *selectedFood;
    
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
        
    IBOutlet UIToolbar *dateToolBar;
		
	NSDate *date_currentDate1;
    
    int exerciseLogID;
    MyMovesDataProvider *soapWebService;
}

@property (nonatomic, strong) IBOutlet UIImageView *imgbottom;
@property (nonatomic, strong) NSDate *date_currentDate1;
@property (nonatomic, strong) NSNumber *int_mealID;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIImageView *imgbottomline;
@property (assign, nonatomic, readonly) NSInteger primaryKey;
@property (nonatomic, strong) NSDate *date_currentDate;

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

@property (nonatomic,retain) HKHealthStore *healthStore;
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) NSSet *readDataTypes;
@property (nonatomic, strong) StepData * sd;

@end
