//
//  FoodsSearch.h
//  DietMasterGo
//
//  Created by Andrew Moffitt on 3/1/11.
//  Copyright 2011 AE Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

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
	NSDate *date_currentDate;
	NSNumber *int_mealID;
}

/// Type of search user if performing.
@property (nonatomic) DMFoodSearchType searchType;
@property (nonatomic, strong) NSDate *date_currentDate;
@property (nonatomic, strong) NSNumber *int_mealID;

@end
