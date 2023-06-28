//
//  DMMealPlanDataProvider.h
//  DietMasterGo
//
//  Created by Henry Kirk on 6/26/23.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Handles interaction with MealPlan items.
@interface DMMealPlanDataProvider : NSObject

#pragma mark - Meal Plan

/// Updates the user meal items with provided dictionry.
- (void)updateUserPlannedMealItems:(nonnull NSArray *)mealItems withCompletionBlock:(nonnull completionBlockWithError)completionBlock;

/// Saves new user planned meal items with the provided data.
- (void)saveUserPlannedMealItems:(nonnull NSArray *)mealItems withCompletionBlock:(nonnull completionBlockWithError)completionBlock;

/// Deletes meal items provided.
- (void)deleteUserPlannedMealItems:(nonnull NSArray *)mealItems withCompletionBlock:(nonnull completionBlockWithError)completionBlock;

/// Exchanges one meal item for another.
- (void)exchangeUserPlannedMealItem:(nonnull NSDictionary *)mealItem
                           withItem:(nonnull NSDictionary *)newMealItem
                withCompletionBlock:(nonnull completionBlockWithError)completionBlock;

/// Fetches the user's planned meals and provides them in the completion block.
- (void)fetchUserPlannedMealsWithCompletionBlock:(nonnull completionBlockWithObject)completionBlock;

/// Gets the total calories for the array of meal codes provided.
- (NSNumber *)getCaloriesForMealCodes:(NSArray *)array;

#pragma mark - Grocery

/// Fetches the grocery list for meal items provided.
- (void)fetchGroceryListForMealItems:(nonnull NSArray *)mealItems withCompletionBlock:(nonnull completionBlockWithObject)completionBlock;

/// Gets grocery food details for the foods provided.
- (NSArray *)getGroceryFoodDetailsForFoods:(nullable NSArray *)foods;

/// Gets a saved grocery list from NSUserDefaults.
- (NSArray<NSDictionary *> *)getSavedGroceryList;
/// Saves a grocery list to NSUserDefaults.
- (void)saveGroceryList:(NSArray<NSDictionary *> *)groceryList;

@end

NS_ASSUME_NONNULL_END
