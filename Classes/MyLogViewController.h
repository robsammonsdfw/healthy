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
	
	int int_foodID;
	
	NSDate *date_currentDate;
	NSNumber *int_mealID;
	
	NSString *selectedFood;
    
    // values
    CGFloat actualCarbCalories;
    CGFloat actualFatCalories;
    CGFloat actualProteinCalories;
		
	NSDate *date_currentDate1;
    
    int exerciseLogID;
}

@end
