//
//  DMMyLogDataProvider.h
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/25/23.
//

#import <Foundation/Foundation.h>

#import "DMConstants.h"
@class DMMealPlanItem;
@class DMFood;

NS_ASSUME_NONNULL_BEGIN

/// Manages fetching, saving of items related to the user's Log.
@interface DMMyLogDataProvider : NSObject

#pragma mark - Sync Everything

/// Performs a complete upload of all user data.
+ (void)uploadDatabaseWithCompletionBlock:(completionBlockWithError)completionBlock;

/// Performs a complete sync of the database with completion block since the
/// last time a sync was performend.
/// Fetches all sorts of data from the server. Foods, Meals, Exercies, etc.
+ (void)syncDatabaseWithCompletionBlock:(completionBlockWithError)completionBlock;

#pragma mark - Meals

- (void)syncFavoriteMealsWithCompletionBlock:(completionBlockWithError)completionBlock;
- (void)syncFavoriteMealItemsWithCompletionBlock:(completionBlockWithError)completionBlock;

- (void)saveFavoriteMealItem:(int)mealID withCompletionBlock:(nullable completionBlockWithError)completionBlock;

/// Gets the measure ID for a food against a meal plan item.
- (NSNumber *)getMeasureIDForFoodKey:(NSNumber *)foodKey
                    fromMealPlanItem:(DMMealPlanItem *)mealPlanItem;

#pragma mark - Exercise

- (void)saveExerciseLogsWithCompletionBlock:(nullable completionBlockWithError)completionBlock;

/// Performs a sync of the exercise log, with date of last sync, current page number,
/// and fetched items if multiple pages. Pass 1 for page number and an empty array if
/// the first time.
- (void)syncExerciseLog:(NSString *)dateString
             pageNumber:(NSInteger)pageNumber
           fetchedItems:(NSArray *)fetchedItems
    withCompletionBlock:(completionBlockWithError)completionBlock;

#pragma mark - Foods

/// Saves the food with the key provided to the server.
- (void)saveFoodForKey:(NSNumber *)foodKey withCompletionBlock:(completionBlockWithObject)completionBlock;

/// Fetches favorite foods.
- (void)syncFavoriteFoods:(NSString *)dateString
      withCompletionBlock:(completionBlockWithError)completionBlock;

/// Fetches Foods for the Food database.
- (void)syncFoods:(NSString *)dateString
       pageNumber:(NSInteger)pageNumber
     fetchedItems:(NSArray *)fetchedItems
        withCompletionBlock:(completionBlockWithError)completionBlock;
/// Fetches a Food for the given key from the server.
- (void)fetchFoodForKey:(NSNumber *)foodKey;
/// Gets the missing foods, if any, for the meal plan items passed.
- (void)getMissingFoodsForMealItems:(NSArray<DMMealPlanItem *> *)itemsArray;
/// Gets a food from the local database.
- (DMFood *)getFoodForFoodKey:(NSNumber *)foodKey;

/// Gets the measure description for MeasureID and FoodKey provided.
- (NSString *)getMeasureDescriptionForMeasureId:(NSNumber *)measureId
                                     forFoodKey:(NSNumber *)foodKey;

#pragma mark - Weight Log

- (void)saveWeightLogWithCompletionBlock:(completionBlockWithError)completionBlock;

#pragma mark - Log

/// Returns the MealID from Food_Log_Items for the date provided. This is used
/// for saving items to the log on a given date.
- (NSNumber *)getLogMealIDForDate:(NSDate *)date;

#pragma mark - Meals

/// Saves a favorite meal to the database.
- (void)saveFavoriteMeal:(NSDictionary *)mealDict withName:(NSString *)mealName;

@end

NS_ASSUME_NONNULL_END
