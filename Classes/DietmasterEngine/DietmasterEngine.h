//
//  DietmasterEngine.h
//  DietMasterGo
//
//  Created by Henry Kirk on 2/4/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMDataFetcher.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "DMConstants.h"

@class DMMessage;
@class DMUser;

/// Notification fired when messages are done updating. Used to update the
/// app icon badge.
extern NSString * const UpdatingMessageNotification;

@interface DietmasterEngine : NSObject {
    
    NSMutableDictionary *exerciseSelectedDict;
    // For Food Log - "Edit" or "Save" functionality
    NSString *taskMode;
    
    NSDate *dateSelected;
    NSString *dateSelectedFormatted;
    
    NSNumber *selectedMealID; // selected ID of meal working on.
    NSNumber *selectedCategoryID; // for editing My Foods.
    NSNumber *selectedMeasureID; // for editing My Foods.
        
    // Meal Plan
    NSMutableArray *mealPlanArray;

    // For detail view
    BOOL isMealPlanItem;
    NSMutableDictionary *mealPlanItemToExchangeDict;
    int indexOfItemToExchange;
    int selectedMealPlanID;
    BOOL didInsertNewFood;
    // Grocery List
    NSMutableArray *groceryArray;
}

@property (nonatomic, strong) NSMutableDictionary *exerciseSelectedDict;

@property (nonatomic, strong) NSString *taskMode;
@property (nonatomic, strong) NSDate *dateSelected;
@property (nonatomic, strong) NSString *dateSelectedFormatted;
@property (nonatomic, strong) NSNumber *selectedMealID;

@property (nonatomic, strong) NSNumber *selectedCategoryID;
@property (nonatomic, strong) NSNumber *selectedMeasureID;

// Meal Plan
@property (nonatomic, strong) NSMutableArray *mealPlanArray;
@property (nonatomic) BOOL isMealPlanItem;
@property (nonatomic, strong) NSMutableDictionary *mealPlanItemToExchangeDict;
@property (nonatomic) int indexOfItemToExchange;
@property (nonatomic) int selectedMealPlanID;
@property (nonatomic) BOOL didInsertNewFood;

@property (nonatomic, strong, readonly) FMDatabase *database;

+ (instancetype)sharedInstance;

/// Performs a complete upload of all user data.
- (void)uploadDatabaseWithCompletionBlock:(completionBlockWithError)completionBlock;
- (void)saveWeightLogWithCompletionBlock:(completionBlockWithError)completionBlock;
- (void)saveExerciseLogsWithCompletionBlock:(completionBlockWithError)completionBlock;

- (void)fetchFoodForKey:(int)foodKey;
- (void)saveFavoriteMealItem:(int)mealID withCompletionBlock:(completionBlockWithError)completionBlock;

// Food Plan Methods
-(NSDictionary *)getFoodDetails:(NSDictionary *)foodDict;
-(BOOL)insertMealPlanToLog:(NSDictionary *)dict;
-(NSNumber *)getRecommendedCalories;
/// Gets the measure ID for a food against a meal plan item.
- (NSNumber *)getMeasureIDForFood:(NSNumber *)foodKey fromMealPlanItem:(NSDictionary *)mealPlanItemDict;
- (NSNumber *)getGramWeightForFoodID:(NSNumber *)foodID andMeasureID:(NSNumber *)measureID;

// Database helper methods
- (NSString *)databasePath;

@end
