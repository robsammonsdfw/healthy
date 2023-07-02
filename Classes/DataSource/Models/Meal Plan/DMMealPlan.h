//
//  DMMealPlan.h
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 7/1/23.
//

#import <Foundation/Foundation.h>
@class DMMealPlanItem;

/// The code for each meal.
typedef NS_ENUM(NSUInteger, DMLogMealCode) {
    DMLogMealCodeBreakfast = 0,
    DMLogMealCodeSnackOne,
    DMLogMealCodeLunch,
    DMLogMealCodeSnackTwo,
    DMLogMealCodeDinner,
    DMLogMealCodeSnackThree,
    // Exercise, not technically a meal, but it's valued.
    DMLogMealCodeExercise
};

NS_ASSUME_NONNULL_BEGIN

/// Object that represents a Meal plan.
/// Here's the structure that this object will represent.
/**
 - MealID = 5212035;  /// This is the ID of the day's meal.
 - MealTypeID = 2097; /// This is the ID of the overall plan.
 - MealName = "1200 Calories {Lean and Tone Physique} - Day 01"; /// Name of the meal.
 - MealItems
           ({
           FoodID = 658;
           FoodURL = "";
           MealCode = 0;
           MeasureID = 4;
           NumberOfServings = "0.5";
           RecipeID = "";
         }) // Items for the meal.
 - MealNotes =     (
             {
         MealCode = 0;
         MealNote = "Prepare oats w/milk, top w/nuts & fruit.";
     },
             {
         MealCode = 1;
         MealNote = "Spread almond butter on muffin, sprinkle w seeds. ";
     },
             {
         MealCode = 2;
         MealNote = "Salad served with toast.";
     },
             {
         MealCode = 3;
         MealNote = "Bean, cheese burrito wrap. ";
     },
             {
         MealCode = 4;
         MealNote = "Roast tilapia, beans/quinoa, brocc/spinach salad.";
     },
             {
         MealCode = 5;
         MealNote = "Top cottage cheese w peaches. ";
     }
 ); // Notes for each meal.
 */
@interface DMMealPlan : NSObject

@property (nonatomic, strong, readonly) NSNumber *mealId;
@property (nonatomic, strong, readonly) NSNumber *mealTypeId;
@property (nonatomic, strong, readonly) NSString *mealName;

/// The required initialzier.
- (instancetype)initWithDictionary:(NSDictionary *)dictonary NS_DESIGNATED_INITIALIZER;

/// Returns the meal items for the code provided.
- (NSArray<DMMealPlanItem *> *)getMealItemsForMealCode:(DMLogMealCode)mealCode;

/// Returns all meal plan items.
- (NSArray<DMMealPlanItem *> *)getAllMealItems;

/// Returns the notes for the code.
- (NSString *)getMealNoteForMealCode:(DMLogMealCode)mealCode;

/// Removes a value from this object, but doesn't remove it from the database or
/// server. It's just for keeping the object tidy. Don't use it often.
- (void)removeMealPlanItem:(DMMealPlanItem *)mealPlanItem inMealCode:(DMLogMealCode)mealCode;

@end

NS_ASSUME_NONNULL_END
