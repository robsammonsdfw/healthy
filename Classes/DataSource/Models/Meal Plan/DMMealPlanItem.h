//
//  DMMealPlanItem.h
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 7/1/23.
//

#import <Foundation/Foundation.h>
#import "DMMealPlan.h"

NS_ASSUME_NONNULL_BEGIN

/// Represents a Meal Plan item.
/**
     {
    FoodID = 658;
    FoodURL = "";
    MealCode = 0;
    MeasureID = 4;
    NumberOfServings = "0.5";
    RecipeID = "";
 */
@interface DMMealPlanItem : NSObject

@property (nonatomic, strong, readonly) NSNumber *foodId;
@property (nonatomic, strong, readonly) NSNumber *foodURL;
@property (nonatomic, readonly) DMLogMealCode mealCode;
@property (nonatomic, strong, readonly) NSNumber *measureId;
@property (nonatomic, strong, readonly) NSNumber *numberOfServings;
@property (nonatomic, strong, readonly) NSNumber *recipeId;

/// The required initialzier.
- (instancetype)initWithDictionary:(NSDictionary *)dictonary NS_DESIGNATED_INITIALIZER;

- (NSDictionary *)dictionaryRepresentation;

@end

NS_ASSUME_NONNULL_END
