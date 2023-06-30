//
//  DietmasterEngine.m
//  DietMasterGo
//
//  Created by Henry Kirk on 2/4/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import "DietmasterEngine.h"
@import Firebase;
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "NSData+Blocks.h"
#import "UIDevice+machine.h"
#import "DietMasterGoAppDelegate.h"
#import "NSString+ConvertToDate.h"
#import "MBProgressHUD.h"
#import "NSNull+NullCategoryExtension.h"

#import "DMDatabaseProvider.h"

#import "DMUser.h"
#import "DMMessage.h"
#import "DMFood.h"
#import "DMWeightLogEntry.h"

#import "DietMasterGoPlus-Swift.h"
#import "DMUser.h"

#define D_MINUTE	60
#define D_HOUR		3600
#define D_DAY		86400
#define D_WEEK		604800
#define D_YEAR		31556926

NSString * const UpdatingMessageNotification = @"UpdatingMessageNotification";

@interface DietmasterEngine ()
@property (nonatomic, strong) NSDateFormatter *dateformatter;
@property (nonatomic, strong, readwrite) FMDatabase *database;
@end

@implementation DietmasterEngine

@synthesize exerciseSelectedDict, taskMode, dateSelected, dateSelectedFormatted;
@synthesize selectedMealID, selectedMeasureID, selectedCategoryID;
@synthesize mealPlanArray, isMealPlanItem, mealPlanItemToExchangeDict, indexOfItemToExchange, selectedMealPlanID, didInsertNewFood;

+ (instancetype)sharedInstance {
    static DietmasterEngine *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DietmasterEngine alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _dateformatter = [[NSDateFormatter alloc] init];
        exerciseSelectedDict = [[NSMutableDictionary alloc] init];
        
        mealPlanArray = [[NSMutableArray alloc] init];
        
        dateSelected = [[NSDate alloc] init];
        
        [_dateformatter setDateStyle:NSDateFormatterLongStyle];
        dateSelectedFormatted = [_dateformatter stringFromDate:dateSelected];
        
        isMealPlanItem = NO;
        mealPlanItemToExchangeDict = [[NSMutableDictionary alloc] init];
        didInsertNewFood = NO;
    }
    return self;
}

#pragma mark MAIN SYNC METHOD

- (FMDatabase *)database {
    return [FMDatabase databaseWithPath:[self databasePath]];
}

- (void)uploadDatabaseWithCompletionBlock:(completionBlockWithError)completionBlock {
    dispatch_group_t fetchGroup = dispatch_group_create();
    __block NSError *syncError = nil;
    
    dispatch_group_enter(fetchGroup);
    [self saveMealsWithCompletionBlock:^(BOOL completed, NSError *error) {
        syncError = error;
        dispatch_group_leave(fetchGroup);
    }];
    dispatch_group_enter(fetchGroup);
    [self saveMealItemsWithCompletionBlock:^(BOOL completed, NSError *error) {
        syncError = error;
        dispatch_group_leave(fetchGroup);
    }];
    dispatch_group_enter(fetchGroup);
    [self saveExerciseLogsWithCompletionBlock:^(BOOL completed, NSError *error) {
        syncError = error;
        dispatch_group_leave(fetchGroup);
    }];
    dispatch_group_enter(fetchGroup);
    [self saveWeightLogWithCompletionBlock:^(BOOL completed, NSError *error) {
        syncError = error;
        dispatch_group_leave(fetchGroup);
    }];
    dispatch_group_enter(fetchGroup);
    [self saveFavoriteFoodsWithCompletion:^(BOOL completed, NSError *error) {
        syncError = error;
        dispatch_group_leave(fetchGroup);
    }];
    dispatch_group_enter(fetchGroup);
    [self saveFavoriteMealsWithCompletionBlock:^(BOOL completed, NSError *error) {
        syncError = error;
        dispatch_group_leave(fetchGroup);
    }];
    dispatch_group_enter(fetchGroup);
    [self saveAllCustomFoodsWithCompletion:^(BOOL completed, NSError *error) {
        syncError = error;
        dispatch_group_leave(fetchGroup);
    }];
    
    dispatch_group_notify(fetchGroup, dispatch_get_main_queue(),^{
        if (completionBlock) {
            completionBlock(syncError != nil, syncError);
        }
    });
}

#pragma mark DOWN SYNC METHODS

/// Processes food for both old and new APIs, so this is it's own method.
- (void)saveFoodFinished:(NSArray *)responseArray forFood:(DMFood *)food {
    NSInteger foodIDSaved = 0;
    FMDatabase* db = [self database];
    if (![db open]) {
    }
    
    [db beginTransaction];
    for (NSDictionary *dict in responseArray) {
        foodIDSaved = [[dict valueForKey:@"FoodID"] intValue];
        NSString *queryString = [NSString stringWithFormat:@"UPDATE Food "
                                 " SET FoodPK = %i, FoodKey = %i, FoodID = %i WHERE FoodKey = %i ",
                                 ValidInt([dict valueForKey:@"FoodID"]),
                                 ValidInt([dict valueForKey:@"FoodID"]),
                                 ValidInt([dict valueForKey:@"FoodID"]),
                                 ValidInt([dict valueForKey:@"GoID"])
                                 ];
        
        [db executeUpdate:queryString];
    }
    
    for (NSDictionary *dict in responseArray) {
        NSString *queryString = [NSString stringWithFormat:@"UPDATE FoodMeasure "
                                 " SET FoodID = %i WHERE FoodID = %i ",
                                 [[dict valueForKey:@"FoodID"] intValue],
                                 [[dict valueForKey:@"GoID"] intValue]
                                 ];
        [db executeUpdate:queryString];
    }
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
}

- (void)saveMealsWithCompletionBlock:(completionBlockWithError)completionBlock {
    FMDatabase* db = [self database];
    if (![db open]) {
    }
    
    NSString *query = @"SELECT MealID, MealDate FROM Food_Log WHERE MealID <= 0";
    FMResultSet *rs = [db executeQuery:query];

    NSInteger resultCount = 0;
    while ([rs next]) {
        [self.dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *log_Date = [self.dateformatter dateFromString:[rs stringForColumn:@"MealDate"]];
        if (log_Date == nil) {
            continue;
        }
        
        [self.dateformatter setDateFormat:@"M/dd/yyyy"];
        NSString *logTimeString = [self.dateformatter stringFromDate:log_Date];
        
        // goMealID = MealID in database.
        // LogDate = MealDate in database
        NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  @"SaveMeal", @"RequestType",
                                  logTimeString, @"LogDate",
                                  [rs stringForColumn:@"MealID"], @"goMealID",
                                  nil];
        [DMDataFetcher fetchDataWithRequestParams:infoDict completion:^(NSObject *object, NSError *error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completionBlock) {
                        completionBlock(NO, error);
                    }
                });
                return;
            }
            
            [db beginTransaction];
            NSArray *responseArray = (NSArray *)object;
            for (NSDictionary *dict in responseArray) {
                NSString *queryString = [NSString stringWithFormat:@"UPDATE Food_Log "
                                         " SET MealID = %i WHERE MealID = %i ",
                                         [[dict valueForKey:@"MealID"] intValue],
                                         [[dict valueForKey:@"goMealID"] intValue]
                                         ];
                [db executeUpdate:queryString];
            }
            
            for (NSDictionary *dict in responseArray) {
                NSString *queryString = [NSString stringWithFormat:@"UPDATE Food_Log_Items "
                                         " SET MealID = %i WHERE MealID = %i ",
                                         [[dict valueForKey:@"MealID"] intValue],
                                         [[dict valueForKey:@"goMealID"] intValue]
                                         ];
                [db executeUpdate:queryString];
            }
            if ([db hadError]) {
                DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
            [db commit];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(YES, nil);
                }
            });
        }];
        resultCount++;
    }
    // Incase we had no results.
    if (resultCount == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(YES, nil);
            }
        });
    }
    [rs close];
}

- (void)saveMealItemsWithCompletionBlock:(completionBlockWithError)completionBlock {
    FMDatabase* db = [self database];
    if (![db open]) {
    }
    
    NSString *dateString = [DMGUtilities lastSyncDateString];
    NSString *query = [NSString stringWithFormat:@"SELECT MealID, FoodID, MealCode, MeasureID, NumberOfServings, LastModified "
             " FROM Food_Log_Items WHERE LastModified > '%@' ", dateString];
    FMResultSet *rs = [db executeQuery:query];
    
    NSMutableArray *tempDataArray = [[NSMutableArray alloc] init];
    while ([rs next]) {
        NSDictionary *tempDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  [rs stringForColumn:@"MealID"], @"MealID",
                                  [rs stringForColumn:@"FoodID"], @"FoodID",
                                  [rs stringForColumn:@"MealCode"], @"MealCode",
                                  [rs stringForColumn:@"MeasureID"], @"MeasureID",
                                  [rs stringForColumn:@"NumberOfServings"], @"ServingSize",
                                  nil];
        [tempDataArray addObject:tempDict];
    }
    [rs close];
    
    if (!tempDataArray.count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(YES, nil);
            }
        });
        return;
    }
    
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"SaveMealItems", @"RequestType",
                              nil];    
    [DMDataFetcher fetchDataWithRequestParams:infoDict
                                   jsonObject:[tempDataArray copy]
                                   completion:^(NSObject *object, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(error != nil, error);
                }
            });
            return;
        }
        NSArray *results = (NSArray *)object;
        [self saveMealItemFinished:results];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(YES, nil);
            }
        });
    }];
}

- (void)saveExerciseLogsWithCompletionBlock:(completionBlockWithError)completionBlock {
    FMDatabase* db = [self database];
    if (![db open]) {
    }
    
    NSString *query = @"SELECT ExerciseID, Exercise_Time_Minutes, Log_Date, Exercise_Log_StrID FROM Exercise_Log";
    FMResultSet *rs = [db executeQuery:query];
    
    NSMutableArray *tempDataArray = [[NSMutableArray alloc] init];
    while ([rs next]) {
        [self.dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *log_Date = [self.dateformatter dateFromString:[rs stringForColumn:@"Log_Date"]];
        if (log_Date == nil) {
            continue;
        }
        
        [self.dateformatter setDateFormat:@"M/dd/yyyy"];
        NSString *logTimeString = [self.dateformatter stringFromDate:log_Date];
        NSString *finalLogString = [NSString stringWithFormat:@"%@ 12:00:00 AM", logTimeString];
        NSDictionary *tempDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  [rs stringForColumn:@"ExerciseID"], @"ExerciseID",
                                  finalLogString, @"LogDate",
                                  [rs stringForColumn:@"Exercise_Time_Minutes"], @"Duration",
                                  nil];
        [tempDataArray addObject:tempDict];
    }
    
    if (!tempDataArray.count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(YES, nil);
            }
        });
        return;
    }

    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"SaveExerciseLogs", @"RequestType",
                              nil];
    [DMDataFetcher fetchDataWithRequestParams:infoDict
                                   jsonObject:[tempDataArray copy]
                                   completion:^(NSObject *object, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(error != nil, error);
            }
        });
    }];

    [rs close];
}

- (void)saveWeightLogWithCompletionBlock:(completionBlockWithError)completionBlock {
    FMDatabase* db = [self database];
    if (![db open]) {
    }
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM weightlog WHERE entry_type = %li", DMWeightLogEntryTypeWeight];
    FMResultSet *rs = [db executeQuery:query];
    
    NSMutableArray *tempDataArray = [NSMutableArray array];
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        DMWeightLogEntry *weightEntry = [[DMWeightLogEntry alloc] initWithDictionary:dict entryType:DMWeightLogEntryTypeWeight];
        if (!weightEntry.logDateString.length) {
            continue;
        }
                
        NSDictionary *tempDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    weightEntry.value, @"Weight",
                                    weightEntry.logDateTimeString, @"LogDate", nil];
        [tempDataArray addObject:tempDict];
    }
    
    if (!tempDataArray.count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(YES, nil);
            }
        });
        return;
    }
    
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"SaveWeightLogs", @"RequestType",
                                nil];
    
    [DMDataFetcher fetchDataWithRequestParams:infoDict
                                   jsonObject:[tempDataArray copy]
                                   completion:^(NSObject *object, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(error != nil, error);
            }
        });
    }];
    [rs close];
}

- (void)saveAllCustomFoodsWithCompletion:(completionBlockWithError)completionBlock {
    FMDatabase* db = [self database];
    if (![db open]) {
    }
    
    NSString *query = [NSString stringWithFormat:@"SELECT f.FoodKey,f.FoodID,f.Name,f.CategoryID, f.Calories, f.Fat, "
                       "f.Sodium, f.Carbohydrates, f.SaturatedFat, f.Cholesterol,f.Protein, "
                       "f.Fiber,f.Sugars, f.Pot,f.A, "
                       "f.Thi, f.Rib,f.Nia, f.B6, "
                       "f.B12,f.Fol,f.C, f.Calc, "
                       "f.Iron,f.Mag,f.Zn,f.ServingSize, "
                       "f.Transfat, f.E, f.D,f.Folate, "
                       "f.Frequency, f.UserID, f.CompanyID, f.ScannedFood, fm.MeasureID, f.UPCA, f.FactualID FROM Food f INNER JOIN FoodMeasure fm ON fm.FoodID = f.FoodKey WHERE f.FoodKey <= %i", 0];
    FMResultSet *rs = [db executeQuery:query];
    
    NSInteger resultCount = 0;
    while ([rs next]) {
        NSDictionary *resultDict = [rs resultDictionary];
        DMFood *food = [[DMFood alloc] initWithDictionary:resultDict];
        NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                              @"SaveFoodNew", @"RequestType",
                              nil];
        NSDictionary *foodDict = [food dictionaryRepresentation];
        [mutableDict addEntriesFromDictionary:foodDict];
        
        [DMDataFetcher fetchDataWithRequestParams:foodDict completion:^(NSObject *object, NSError *error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completionBlock) {
                        completionBlock(NO, error);
                    }
                });
                return;
            }
            NSArray *results = (NSArray *)object;
             [self saveFoodFinished:results forFood:food];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(YES, nil);
                }
            });
         }];
        resultCount++;
    }
    // If we had no results, return.
    if (resultCount == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(YES, nil);
            }
        });
    }
    [rs close];
}

- (void)saveFavoriteFoodsWithCompletion:(completionBlockWithError)completionBlock {
    FMDatabase* db = [self database];
    if (![db open]) {
    }
    
    NSString *query = @"SELECT Favorite_FoodID, FoodID, MeasureID, modified FROM Favorite_Food WHERE Favorite_FoodID < 0";
    FMResultSet *rs = [db executeQuery:query];
    NSInteger resultCount = 0;
    while ([rs next]) {
        
        NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"SaveFavoriteFood", @"RequestType",
                              [rs stringForColumn:@"Favorite_FoodID"], @"Favorite_FoodID",
                              [rs stringForColumn:@"FoodID"], @"FoodID",
                              [rs stringForColumn:@"MeasureID"], @"MeasureID",
                              nil];
        
        [DMDataFetcher fetchDataWithRequestParams:infoDict completion:^(NSObject *object, NSError *error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completionBlock) {
                        completionBlock(NO, error);
                    }
                });
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(YES, nil);
                }
            });
        }];
        resultCount++;
    }
    // If we had no results, return.
    if (resultCount == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(YES, nil);
            }
        });
    }
    [rs close];
}

- (void)saveFavoriteMealsWithCompletionBlock:(completionBlockWithError)completionBlock {
    FMDatabase* db = [self database];
    if (![db open]) {
    }
    
    NSString *query = [NSString stringWithFormat:@"SELECT Favorite_MealID, Favorite_Meal_Name FROM Favorite_Meal WHERE Favorite_MealID <= %@", @"0"];
    FMResultSet *rs = [db executeQuery:query];
    NSInteger resultCount = 0;
    while ([rs next]) {
        // goMealID is Favorite_MealID in database.
        // MealName is Favorite_Meal_Name in database
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"SaveFavoriteMeal", @"RequestType",
                              [rs stringForColumn:@"Favorite_MealID"], @"goMealID",
                              [rs stringForColumn:@"Favorite_Meal_Name"], @"MealName",
                              nil];
        [DMDataFetcher fetchDataWithRequestParams:dict completion:^(NSObject *object, NSError *error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completionBlock) {
                        completionBlock(NO, error);
                    }
                });
                return;
            }
            NSArray *responseArray = (NSArray *)object;
            [db beginTransaction];
            for (NSDictionary *dict in responseArray) {
                NSString *queryString = [NSString stringWithFormat:@"UPDATE Favorite_Meal "
                                         " SET Favorite_MealID = %i WHERE Favorite_MealID = %i ",
                                         [[dict valueForKey:@"MealID"] intValue],
                                         [[dict valueForKey:@"goMealID"] intValue]
                                         ];
                [db executeUpdate:queryString];
            }
            
            for (NSDictionary *dict in responseArray) {
                NSString *queryString = [NSString stringWithFormat:@"UPDATE Favorite_Meal_Items "
                                         " SET Favorite_Meal_ID = %i WHERE Favorite_Meal_ID = %i ",
                                         [[dict valueForKey:@"MealID"] intValue],
                                         [[dict valueForKey:@"goMealID"] intValue]
                                         ];
                [db executeUpdate:queryString];
                [self saveFavoriteMealItem:[[dict valueForKey:@"MealID"] intValue] withCompletionBlock:nil];
            }
            
            if ([db hadError]) {
                DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
            [db commit];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(YES, nil);
                }
            });
        }];
        resultCount++;
    }
    // If we had no results, return.
    if (resultCount == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(YES, nil);
            }
        });
    }
    [rs close];
}

- (void)saveFavoriteMealItem:(int)mealID withCompletionBlock:(completionBlockWithError)completionBlock {
    FMDatabase* db = [self database];
    if (![db open]) {
    }
    
    NSString *query = [NSString stringWithFormat:@"SELECT Favorite_Meal_ID, FoodKey, MeasureID, Servings FROM Favorite_Meal_Items WHERE Favorite_Meal_ID = %i ", mealID];
    FMResultSet *rs = [db executeQuery:query];
    
    dispatch_group_t fetchGroup = dispatch_group_create();
    while ([rs next]) {
        // MealID is Favorite_Meal_ID
        // goMealID is Favorite_Meal_ID
        // FoodID is FoodKey
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"SaveFavoriteMealItem", @"RequestType",
                              [rs stringForColumn:@"Favorite_Meal_ID"], @"MealID",
                              [rs stringForColumn:@"Favorite_Meal_ID"], @"goMealID",
                              [rs stringForColumn:@"FoodKey"], @"FoodID",
                              [rs stringForColumn:@"MeasureID"], @"MeasureID",
                              [rs stringForColumn:@"Servings"], @"Servings",
                              nil];
        
        dispatch_group_enter(fetchGroup);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [DMDataFetcher fetchDataWithRequestParams:dict completion:^(NSObject *object, NSError *error) {
                dispatch_group_leave(fetchGroup);
                if (error) {
                    return;
                }
                NSArray *responseArray = (NSArray *)object;

                [db beginTransaction];
                for (NSDictionary *dict in [responseArray copy]) {
                    NSString *favMealItemsStringID = [NSString stringWithFormat:@"%@-%@",[dict valueForKey:@"Favorite_Meal_ID"], [dict valueForKey:@"FoodID"]];
                    [db beginTransaction];
                    NSDate* sourceDate = [NSDate date];
                    
                    NSString *queryString = [NSString stringWithFormat:@"REPLACE INTO Favorite_Meal_Items "
                                             "(Favorite_Meal_Items_strID, Favorite_Meal_ID, FoodKey, FoodID, MeasureID, Servings, Last_Modified) VALUES "
                                             "('%@', %i, %i, %i,%i, %f, '%@') ",
                                             favMealItemsStringID,
                                             ValidInt([dict valueForKey:@"Favorite_Meal_ID"]),
                                             ValidInt([dict valueForKey:@"FoodID"]),
                                             ValidInt([dict valueForKey:@"FoodID"]),
                                             ValidInt([dict valueForKey:@"MeasureID"]),
                                             [[dict valueForKey:@"NumberOfServings"] floatValue],
                                             sourceDate
                                             ];
                    
                    [db executeUpdate:queryString];
                }
                [db commit];
                if ([db hadError]) {
                    DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                }
            }];
        });

    }
    [rs close];
    
    dispatch_group_notify(fetchGroup, dispatch_get_main_queue(),^{
        if (completionBlock) {
            completionBlock(YES, nil);
        }
    });
}

- (void)saveFoodForKey:(NSNumber *)foodKey withCompletionBlock:(completionBlockWithObject)completionBlock {
    FMDatabase* db = [self database];
    if (![db open]) {
    }
    
    NSString *query = [NSString stringWithFormat:@"SELECT f.FoodKey,f.FoodID,f.Name,f.CategoryID, f.Calories, f.Fat, "
                       "f.Sodium, f.Carbohydrates, f.SaturatedFat, f.Cholesterol,f.Protein, "
                       "f.Fiber,f.Sugars, f.Pot,f.A, "
                       "f.Thi, f.Rib,f.Nia, f.B6, "
                       "f.B12,f.Fol,f.C, f.Calc, "
                       "f.Iron,f.Mag,f.Zn,f.ServingSize, "
                       "f.Transfat, f.E, f.D,f.Folate, "
                       "f.Frequency, f.UserID, f.CompanyID, f.ScannedFood, fm.MeasureID, f.UPCA, f.FactualID FROM Food f INNER JOIN FoodMeasure fm ON fm.FoodID = f.FoodKey WHERE f.FoodKey = %@", foodKey];
    
    FMResultSet *rs = [db executeQuery:query];
    while ([rs next]) {
        NSDictionary *resultDict = [rs resultDictionary];
        DMFood *food = [[DMFood alloc] initWithDictionary:resultDict];

        // GoID = FoodID on database locally, so adding it as well.
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"SaveFoodNew", @"RequestType",
                              food.foodKey, @"FoodKey",
                              food.foodId, @"FoodID",
                              food.foodKey, @"GoID",
                              food.name, @"Name",
                              food.categoryId, @"CategoryID",
                              food.calories, @"Calories",
                              food.fat, @"Fat",
                              food.sodium, @"Sodium",
                              food.carbohydrates, @"Carbohydrates",
                              food.saturatedFat, @"SaturatedFat",
                              food.cholesterol, @"Cholesterol",
                              food.protein, @"Protein",
                              food.fiber, @"Fiber",
                              food.sugars, @"Sugars",
                              food.pot, @"Pot",
                              food.a, @"A",
                              food.thi, @"Thi",
                              food.rib, @"Rib",
                              food.nia, @"Nia",
                              food.b6, @"B6",
                              food.b12, @"B12",
                              food.fol, @"Fol",
                              food.c, @"C",
                              food.calc, @"Calc",
                              food.iron, @"Iron",
                              food.mag, @"Mag",
                              food.zn, @"Zn",
                              food.servingSize, @"ServingSize",
                              food.transFat, @"Transfat",
                              food.e, @"E",
                              food.d, @"D",
                              food.folate, @"Folate",
                              food.frequency, @"Frequency",
                              food.userId, @"UserID",
                              food.companyId, @"CompanyID",
                              food.barcodeUPCA, @"UPCA",
                              food.factualId, @"FactualID",
                              food.measureId, @"MeasureID",
                              food.scannedFood, @"ScannedFood",
                              nil];
        [DMDataFetcher fetchDataWithRequestParams:dict completion:^(NSObject *object, NSError *error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completionBlock) {
                        completionBlock(nil, error);
                    }
                });
                return;
            }
            NSArray *responseArray = (NSArray *)object;
            [self saveFoodFinished:responseArray forFood:food];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(object, nil);
                }
            });
        }];
    }
    [rs close];
}

#pragma mark UP SYNC DELEGATE METHODS

- (void)saveMealItemFinished:(NSArray *)responseArray {
    FMDatabase* db = [self database];
    if (![db open]) {
        DM_LOG(@"Error, Database not open.");
        return;
    }
    
    for (NSDictionary *dict in responseArray) {
        NSDate* sourceDate = [NSDate date];
        [self.dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSString *queryString = [NSString stringWithFormat:@"UPDATE Food_Log_Items "
                                 " SET LastModified = '%@' WHERE MealID = %i ",
                                 sourceDate,
                                 [[dict valueForKey:@"MealID"] intValue]
                                 ];
        
        [db executeUpdate:queryString];
    }
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
}

#pragma mark - Get Data Fetch


#pragma mark SPLASH IMAGE

- (void)downloadFileIfUpdated {
    NSString *pngFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"SplashImage.png"];
    NSString *pngFilePath2x = [NSTemporaryDirectory() stringByAppendingPathComponent:@"SplashImage@2x.png"];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    DMAuthManager *authManager = [DMAuthManager sharedInstance];
    DMUser *currentUser = [authManager loggedInUser];
    NSString *urlString = [NSString stringWithFormat:@"http://www.dmwebpro.com/CustomMobileGraphics/%@",
                           currentUser.mobileGraphicImageName];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSString *cachedPath = pngFilePath;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL downloadFromServer = NO;
    NSString *lastModifiedString = nil;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"HEAD"];
    NSHTTPURLResponse *response;
    NSError *error = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: &error];
    if ([response respondsToSelector:@selector(allHeaderFields)]) {
        lastModifiedString = [[response allHeaderFields] objectForKey:@"Last-Modified"];
    }
    
    if (error) {
        [prefs setValue:[NSDate date] forKey:@"lastmodified_splash"];
        [prefs synchronize];
        return;
    }
    
    NSDate *lastModifiedServer = nil;
    @try {
        self.dateformatter.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";
        self.dateformatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        self.dateformatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        lastModifiedServer = [self.dateformatter dateFromString:lastModifiedString];
    }
    @catch (NSException * e) {
        DMLog(@"Error parsing last modified date: %@ - %@", lastModifiedString, [e description]);
    }
    
    if (!lastModifiedServer) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *logoFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"SplashImage.png"];
        NSString *logoFilePath2x = [NSTemporaryDirectory() stringByAppendingPathComponent:@"SplashImage@2x.png"];
        if([[NSFileManager defaultManager] fileExistsAtPath: logoFilePath])
        {
            [fileManager removeItemAtPath:logoFilePath error:NULL];
            [fileManager removeItemAtPath:logoFilePath2x error:NULL];
        }
        
        [prefs setValue:[NSDate date] forKey:@"lastmodified_splash"];
        return;
    }
    
    NSDate *lastModifiedLocal = nil;
    if ([fileManager fileExistsAtPath:cachedPath]) {
        NSError *error = nil;
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:cachedPath error:&error];
        if (error) {
            DMLog(@"Error reading file attributes for: %@ - %@", cachedPath, [error localizedDescription]);
        }
        lastModifiedLocal = [fileAttributes fileModificationDate];
    }
    
    if (!lastModifiedLocal) {
        downloadFromServer = YES;
    }
    if ([lastModifiedLocal laterDate:lastModifiedServer] == lastModifiedServer) {
        downloadFromServer = YES;
    }
    
    if (downloadFromServer) {
        
        [NSData dataWithContentsOfURL:url completionBlock:^(NSData *data, NSError *error) {
            if(!error) {
                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                    if (data) {
                        UIImage *image = [[UIImage alloc] initWithData:data];
                        UIImage* stdImage = [self imageWithImage:image scaledToSize:CGSizeMake(320, SCREEN_HEIGHT)];
                        UIImage* stdImage2x = [self imageWithImage:image scaledToSize:CGSizeMake(640, SCREEN_HEIGHT*2)];
                        NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(stdImage)];
                        NSData *data2 = [NSData dataWithData:UIImagePNGRepresentation(stdImage2x)];
                        
                        [data1 writeToFile:pngFilePath atomically:YES];
                        [data2 writeToFile:pngFilePath2x atomically:YES];
                        
                        if (lastModifiedServer) {
                            NSDictionary *fileAttributes = [NSDictionary dictionaryWithObject:lastModifiedServer forKey:NSFileModificationDate];
                            NSError *error = nil;
                            if ([fileManager setAttributes:fileAttributes ofItemAtPath:cachedPath error:&error]) {
                                
                            }
                            if (error) {
                                DMLog(@"Error setting file attributes for: %@ - %@", cachedPath, [error localizedDescription]);
                            }
                        }
                    }
                });
            }
            else {
                DMLog(@"error %@", error);
            }
        }];
    }
    
    [prefs setValue:[NSDate date] forKey:@"lastmodified_splash"];
    [prefs synchronize];
}

- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark Food Plan Methods

- (BOOL)insertMealPlanToLog:(NSDictionary *)dict {
    FMDatabase* db = [self database];
    if (![db open]) {
        return NO;
    }
    
    int mealIDValue = 0;
   
    [self.dateformatter setDateFormat:@"yyyy-MM-dd"];
    self.dateformatter.timeZone = [NSTimeZone systemTimeZone];
    NSString *date_Today = [self.dateformatter stringFromDate:dateSelected];
    [self.dateformatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]]; // Prevent adjustment to user's local time zone.
    
    NSString *mealIDQuery = [NSString stringWithFormat:@"SELECT MealID FROM Food_Log WHERE (MealDate BETWEEN DATETIME('%@ 00:00:00') AND DATETIME('%@ 23:59:59'))", date_Today, date_Today];
    FMResultSet *rsMealID = [db executeQuery:mealIDQuery];
    while ([rsMealID next]) {
        mealIDValue = [rsMealID intForColumn:@"MealID"];
    }
    [rsMealID close];
    int minIDvalue = 0;
    if (mealIDValue == 0) {
        NSString *idQuery = @"SELECT MIN(MealID) as MealID FROM Food_Log";
        FMResultSet *rsID = [db executeQuery:idQuery];
        while ([rsID next]) {
            minIDvalue = [rsID intForColumn:@"MealID"];
        }
        [rsID close];
        minIDvalue = minIDvalue - 1;
        if (minIDvalue >=0) {
            int maxValue = minIDvalue;
            for (int i=0; i<=maxValue; i++) {
                if (minIDvalue < 0){
                    break;
                }
                minIDvalue--;
            }
        }
    }
    
    if (mealIDValue > 0 || mealIDValue < 0) {
        minIDvalue = mealIDValue;
    }
    
    int foodID = [[NSString stringWithFormat:@"%@",[dict valueForKey:@"FoodID"]] intValue];
    int mealCode = [[NSString stringWithFormat:@"%@",[dict valueForKey:@"MealCode"]] intValue];
    int num_measureID = [[NSString stringWithFormat:@"%@",[dict valueForKey:@"MeasureID"]] intValue];
    double servingAmount = [[NSString stringWithFormat:@"%@",[dict valueForKey:@"NumberOfServings"]] doubleValue];
    
    [db beginTransaction];
    NSString *insertSQL = [NSString stringWithFormat: @"REPLACE INTO Food_Log (MealID, MealDate) VALUES (%i, DATETIME('%@'))", minIDvalue, date_Today];
    [db executeUpdate:insertSQL];
    
    int mealID = minIDvalue;
    
    [self.dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *date_string = [self.dateformatter stringFromDate:[NSDate date]];
    
    insertSQL = [NSString stringWithFormat: @"REPLACE INTO Food_Log_Items "
                 "(MealID, FoodID, MealCode, MeasureID, NumberOfServings, LastModified) "
                 " VALUES (%i, %i, %i, %i, %f, DATETIME('%@'))",
                 mealID, foodID, mealCode, num_measureID, servingAmount, date_string];
    [db executeUpdate:insertSQL];

    BOOL success = YES;
    if ([db hadError]) {
        success = NO;
    }
    [db commit];
    
    return success;
}

-(NSNumber *)getRecommendedCalories {
    
    FMDatabase* db = [self database];
    if (![db open]) {
        
    }
    
    NSString *query = [NSString stringWithFormat: @"SELECT BMR FROM user"];
    
    int num_BMR = 0;
    FMResultSet *rs = [db executeQuery:query];
    while ([rs next]) {
        num_BMR = [rs intForColumn:@"BMR"];
    }
    [rs close];
    
    return [NSNumber numberWithInt:num_BMR];
}

- (NSNumber *)getMeasureIDForFood:(NSNumber *)foodKey fromMealPlanItem:(NSDictionary *)mealPlanItemDict {
    FMDatabase* db = [self database];
    if (![db open]) {
        
    }
    NSNumber *exchangeID = 0;
    NSInteger measureID = 0;
    NSString *query = @"";
    int exchangeGramWeight = 0;
    if (mealPlanItemDict != nil) {
        exchangeGramWeight = [[mealPlanItemDict valueForKey:@"GramWeight"] intValue];
        exchangeID = [mealPlanItemDict valueForKey:@"MeasureID"];
        
        if (exchangeID != 0) {
            query = [NSString stringWithFormat: @"SELECT Measure.MeasureID, Measure.Description, FoodMeasure.FoodID, FoodMeasure.GramWeight FROM Measure INNER JOIN FoodMeasure ON Measure.MeasureID=FoodMeasure.MeasureID WHERE FoodMeasure.FoodID = %li AND FoodMeasure.MeasureID = %li", (long)[foodKey integerValue], (long)[exchangeID integerValue]];
        
            FMResultSet *rs1 = [db executeQuery:query];
            int previousGramWeight = 0;
            while ([rs1 next]) {
                int gramweight = [rs1 intForColumn:@"GramWeight"];
                
                if (measureID == 0) {
                    measureID = [rs1 intForColumn:@"MeasureID"];
                    continue;
                }
                
                int diff = gramweight - exchangeGramWeight;
                if (diff < 0) {
                    diff = diff * -1;
                }
                                
                int diff2 = exchangeGramWeight - previousGramWeight;
                if (diff2 < 0) {
                    diff2 = diff2 * -1;
                }
                
                if (diff == 0 || diff < diff2) {
                    measureID = [rs1 intForColumn:@"MeasureID"];
                    previousGramWeight = gramweight;
                    if (diff == 0) {
                        break;
                    }
                }
            }
            
            [rs1 close];
            
            if (measureID > 0) {
                return @(measureID);
            }
                
        }
    }
    
    query = [NSString stringWithFormat: @"SELECT Measure.MeasureID, Measure.Description, FoodMeasure.FoodID, FoodMeasure.GramWeight FROM Measure INNER JOIN FoodMeasure ON Measure.MeasureID=FoodMeasure.MeasureID WHERE FoodMeasure.FoodID = %li", (long)[foodKey integerValue]];
        
    FMResultSet *rs = [db executeQuery:query];
    
    
    int previousGramWeight = 0;
    while ([rs next]) {
        int gramweight = [rs intForColumn:@"GramWeight"];
        
        if (measureID == 0) {
            measureID = [rs intForColumn:@"MeasureID"];
            continue;
        }
        
        if (exchangeGramWeight != 0) {
            int diff = gramweight - exchangeGramWeight;
            if (diff < 0) {
                diff = diff * -1;
            }
                            
            int diff2 = exchangeGramWeight - previousGramWeight;
            if (diff2 < 0) {
                diff2 = diff2 * -1;
            }
            
            if (diff == 0 || diff < diff2) {
                measureID = [rs intForColumn:@"MeasureID"];
                previousGramWeight = gramweight;
                if (diff == 0) {
                    break;
                }
            }
        }
    }
    
    [rs close];
    
    return @(measureID);
}

-(NSNumber *)getGramWeightForFoodID:(NSNumber *)foodKey andMeasureID:(NSNumber *)measureID {
    
    FMDatabase* db = [self database];
    if (![db open]) {
    }
    
    NSString *query = [NSString stringWithFormat: @"SELECT FoodMeasure.GramWeight FROM Food INNER JOIN FoodMeasure ON FoodMeasure.FoodID = Food.FoodKey INNER JOIN Measure ON FoodMeasure.MeasureID = Measure.MeasureID WHERE Food.FoodKey = %li AND Measure.MeasureID = %li LIMIT 1", (long)[foodKey integerValue], (long)[measureID integerValue]];
    
    FMResultSet *rs = [db executeQuery:query];
    
    NSInteger gramWeight = 0;
    
    while ([rs next]) {
        
        gramWeight = [rs intForColumn:@"GramWeight"];    }
    
    [rs close];
    
    return @(gramWeight);
}

#pragma mark Date Helpers

- (NSInteger)hoursAfterDate:(NSDate *)aDate {
    NSTimeInterval ti = [[NSDate date] timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_HOUR);
}
- (NSInteger)minutesAfterDate:(NSDate *)aDate {
    NSTimeInterval ti = [[NSDate date] timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_MINUTE);
}

#pragma mark LOGIN AUTH DELEGATE METHODS

- (void)userLoginStateDidChangeNotification:(NSNotification *)notification {
    if ([NSThread isMainThread]) {
        DMAuthManager *authManager = [DMAuthManager sharedInstance];
        DMUser *currentUser = [authManager loggedInUser];
        if (currentUser.mobileGraphicImageName > 0) {
            [self performSelectorInBackground:@selector(downloadFileIfUpdated) withObject:nil];
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self userLoginStateDidChangeNotification:notification];
        });
    }
}

- (void)userAuth:(NSMutableArray *)responseArray {
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[responseArray objectAtIndex:0]];
    if (![[dict valueForKey:@"Status"] isEqualToString:@"False"]) {
    }
}

- (void)getAuthenticateUserFailed:(NSString *)failedMessage {
    DMLog(@"getAuthenticateUserFailed, value of response is %@", failedMessage);
}

#pragma DATABASE HELPERS

- (NSString *)databasePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *fullPath = [path stringByAppendingPathComponent:@"DMGO_v3.9.2.sqlite"];
    //DMLog(@"%@",fullPath);
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL exists = [fm fileExistsAtPath:fullPath];
    if (!exists) {
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSString *pathForStartingDB = [path stringByAppendingPathComponent:@"DMGO_v3.9.2.sqlite"];
        [fm copyItemAtPath:pathForStartingDB toPath:fullPath error:nil];
    }
    
    return fullPath;
}

@end
