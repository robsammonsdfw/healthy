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

@protocol WSGetFoodDelegate;

/// Notification fired when messages are done updating. Used to update the
/// app icon badge.
extern NSString * const UpdatingMessageNotification;

@protocol UPSyncDatabaseDelegate;

@interface DietmasterEngine : NSObject {
    
    NSMutableDictionary *exerciseSelectedDict;
    
    NSNumber *currentWeight;
    
    // For Food Log - "Edit" or "Save" functionality
    NSString *taskMode;
    
    NSDate *dateSelected;
    NSString *dateSelectedFormatted;
    
    NSNumber *selectedMealID; // selected ID of meal working on.
    
    NSNumber *selectedCategoryID; // for editing My Foods.
    NSNumber *selectedMeasureID; // for editing My Foods.
    
    // delegates
    int syncsCompleted;
    int upsyncsCompleted;
    int syncsToComplete;
    int upsyncsToComplete;
    int syncsFailed;
    int upsyncsFailed;
    
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
    
    // Get Data
    __block BOOL getDataComplete;
    __block BOOL getDataDidFail;
}

// delegate
@property (nonatomic, weak) id<WSGetFoodDelegate> wsGetFoodDelegate;
@property (nonatomic, weak) id<UPSyncDatabaseDelegate> syncUPDatabaseDelegate;

@property (nonatomic, strong) NSMutableDictionary *exerciseSelectedDict;
@property (nonatomic, strong) NSNumber *currentWeight;

//HHT apple watch
@property (nonatomic,retain) NSNumber *userHeight;
@property (nonatomic) int userGender;

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

-(void)uploadDatabase;
-(void)uploadDatabaseFinished;
-(void)syncDatabaseFailed;
-(void)uploadDatabaseFailed;
-(void)SyncFood:(NSString *)syncDate;

// UP SYNC
-(void)saveMeals:(NSString *)dateString;
-(void)saveMealItems:(NSString *)dateString;
-(void)saveExerciseLogs:(NSString *)dateString;
-(void)saveWeightLog:(NSString *)dateString;
-(void)saveFood:(int)foodKey;
-(void)saveAllCustomFoods;
-(void)saveFavoriteFood:(NSString *)dateString;
-(void)saveFavoriteMeal:(NSString *)dateString;
- (void)saveFavoriteMealItem:(int)mealID withCompletionBlock:(completionBlockWithError)completionBlock;

// Food Plan Methods
-(NSDictionary *)getFoodDetails:(NSDictionary *)foodDict;
-(BOOL)insertMealPlanToLog:(NSDictionary *)dict;
-(NSNumber *)getRecommendedCalories;
/// Gets the measure ID for a food against a meal plan item.
- (NSNumber *)getMeasureIDForFood:(NSNumber *)foodKey fromMealPlanItem:(NSDictionary *)mealPlanItemDict;
- (NSNumber *)getGramWeightForFoodID:(NSNumber *)foodID andMeasureID:(NSNumber *)measureID;

- (void)getMissingFoodsIfNeededForFoods:(NSArray *)foodsArray;
- (void)fetchMissingFoodForKey:(int)foodKey;

// Database helper methods
- (NSString *)databasePath;

// UPC food
-(void)saveUPCFood:(int)foodKey;

// Helpers
- (NSDictionary *)getUserRecommendedRatios;
- (NSInteger)getBMR;

@end

@protocol WSGetFoodDelegate <NSObject>
- (void)getFoodFinished:(NSMutableArray *)responseArray;
- (void)getFoodFailed:(NSString *)failedMessage;
@end
@protocol UPSyncDatabaseDelegate <NSObject>
- (void)syncUPDatabaseFinished:(NSString *)responseMessage;
- (void)syncUPDatabaseFailed:(NSString *)failedMessage;
-(void)callSyncDatabase;
@end
