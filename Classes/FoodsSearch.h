//
//  FoodsSearch.h
//  DietMasterGo
//
//  Created by Andrew Moffitt on 3/1/11.
//  Copyright 2011 AE Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMMealPlan.h"

/// The type of search the user is performing.
/// Note: This enum aligns with the order of the SegmentedControl.
typedef NS_ENUM(NSUInteger, DMFoodSearchType) {
    DMFoodSearchTypeAllFoods = 0,
    DMFoodSearchTypeMyFoods,
    DMFoodSearchTypeFavoriteFoods,
    DMFoodSearchTypeProgramFoods,
    DMFoodSearchTypeFavoriteMeals
};

@interface FoodsSearch : UIViewController {
	int uniqueID;
	int int_foodID;
	NSString *date_foodLogtime;
}

/// Type of search user if performing.
@property (nonatomic) DMFoodSearchType searchType;
/// The task mode the user is taking.
@property (nonatomic) DMTaskMode taskMode;

- (instancetype)initWithMealCode:(DMLogMealCode)mealCode
                    selectedDate:(NSDate *)selectedDate;

- (instancetype)initWithMealCode:(DMLogMealCode)mealCode
                        mealPlan:(DMMealPlan *)mealPlan
                    mealPlanItem:(DMMealPlanItem *)mealPlanItem
                    selectedDate:(NSDate *)selectedDate NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
@end
