//
//  DMMyLogDataProvider.m
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/25/23.
//

#import "DMMyLogDataProvider.h"
#import "FMDatabase.h"
#import "DMDataFetcher.h"
#import "DMFood.h"
#import "DMMealPlanItem.h"
#import "MyMovesDataProvider.h"

@interface DMMyLogDataProvider()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong, readonly) FMDatabase *database;
/// The queue that long running operations happens on.
@property (nonatomic, strong) dispatch_queue_t syncQueue;
@end

@implementation DMMyLogDataProvider

- (instancetype)init {
    self = [super init];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _syncQueue = dispatch_queue_create("com.dietmaster.fetchQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (FMDatabase *)database {
    return [DMDatabaseUtilities database];
}

#pragma mark - Sync Everything

+ (void)uploadDatabaseWithCompletionBlock:(completionBlockWithError)completionBlock {
    DMUser *currentUser = [[DMAuthManager sharedInstance] loggedInUser];
    if (!currentUser) {
        if (completionBlock) {
            completionBlock(YES, nil);
        }
        return;
    }
    dispatch_group_t saveGroup = dispatch_group_create();
    __block NSError *syncError = nil;

    DMMyLogDataProvider *mealProvider = [[DMMyLogDataProvider alloc] init];
    dispatch_group_enter(saveGroup);
    [mealProvider saveMealsWithCompletionBlock:^(BOOL completed, NSError *error) {
        syncError = error;
        dispatch_group_leave(saveGroup);
    }];
    dispatch_group_enter(saveGroup);
    [mealProvider saveMealItemsWithCompletionBlock:^(BOOL completed, NSError *error) {
        syncError = error;
        dispatch_group_leave(saveGroup);
    }];

    DMMyLogDataProvider *exerciseAndWeightProvider = [[DMMyLogDataProvider alloc] init];
    dispatch_group_enter(saveGroup);
    [exerciseAndWeightProvider saveExerciseLogsWithCompletionBlock:^(BOOL completed, NSError *error) {
        syncError = error;
        dispatch_group_leave(saveGroup);
    }];
    dispatch_group_enter(saveGroup);
    [exerciseAndWeightProvider saveWeightLogWithCompletionBlock:^(BOOL completed, NSError *error) {
        syncError = error;
        dispatch_group_leave(saveGroup);
    }];
    
    DMMyLogDataProvider *foodsProvider = [[DMMyLogDataProvider alloc] init];
    dispatch_group_enter(saveGroup);
    [foodsProvider saveFavoriteFoodsWithCompletion:^(BOOL completed, NSError *error) {
        syncError = error;
        dispatch_group_leave(saveGroup);
    }];
    dispatch_group_enter(saveGroup);
    [foodsProvider saveFavoriteMealsWithCompletionBlock:^(BOOL completed, NSError *error) {
        syncError = error;
        dispatch_group_leave(saveGroup);
    }];
    dispatch_group_enter(saveGroup);
    [foodsProvider saveAllCustomFoodsWithCompletion:^(BOOL completed, NSError *error) {
        syncError = error;
        dispatch_group_leave(saveGroup);
    }];
    
    dispatch_group_notify(saveGroup, dispatch_get_main_queue(),^{
        if (completionBlock) {
            completionBlock(syncError == nil, syncError);
        }
    });
}

+ (void)syncDatabaseWithCompletionBlock:(completionBlockWithError)completionBlock {
    DMAuthManager *authManager = [DMAuthManager sharedInstance];
    if (![authManager isUserLoggedIn]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                NSError *error = [DMGUtilities errorWithMessage:@"User not logged in." code:100];
                completionBlock(NO, error);
            }
        });
        return;
    }

    dispatch_group_t fetchGroup = dispatch_group_create();
    __block NSError *syncError = nil;

    // First fetch all the user plan data.
    dispatch_group_enter(fetchGroup);
    MyMovesDataProvider *provider = [[MyMovesDataProvider alloc] init];
    [provider fetchAllUserPlanDataWithCompletionBlock:^(BOOL completed, NSError *error) {
        dispatch_group_leave(fetchGroup);
        if (error) {
            syncError = error;
        }
    }];

    // Next, fetch MyMoves data.
    dispatch_group_enter(fetchGroup);
    MyMovesDataProvider *myMovesFetch = [[MyMovesDataProvider alloc] init];
    [myMovesFetch getMyMovesDataWithCompletionBlock:^(BOOL completed, NSError *error) {
        dispatch_group_leave(fetchGroup);
        if (error) {
            syncError = error;
        }
    }];

    dispatch_group_enter(fetchGroup);
    DMAuthManager *authMangager = [DMAuthManager sharedInstance];
    [authMangager updateUserInfoWithCompletion:^(NSObject *object, NSError *error) {
        dispatch_group_leave(fetchGroup);
        if (error) {
            syncError = error;
        }
    }];
        
    NSString *dateString = [DMGUtilities lastSyncDateString];

    DMMyLogDataProvider *userDataProvider = [[DMMyLogDataProvider alloc] init];
    dispatch_group_enter(fetchGroup);
    [userDataProvider getDataSinceLastSyncDate:dateString withCompletionBlock:^(BOOL completed, NSError *error) {
        dispatch_group_leave(fetchGroup);
        if (error) {
            syncError = error;
        }
    }];

    DMMyLogDataProvider *favoriteProvider = [[DMMyLogDataProvider alloc] init];
    dispatch_group_enter(fetchGroup);
    [favoriteProvider syncFavoriteFoods:dateString withCompletionBlock:^(BOOL completed, NSError *error) {
        dispatch_group_leave(fetchGroup);
        if (error) {
            syncError = error;
        }
    }];

    dispatch_group_enter(fetchGroup);
    [favoriteProvider syncFavoriteMealsWithCompletionBlock:^(BOOL completed, NSError *error) {
        dispatch_group_leave(fetchGroup);
        if (error) {
            syncError = error;
        }
    }];

    dispatch_group_enter(fetchGroup);
    [favoriteProvider syncFavoriteMealItemsWithCompletionBlock:^(BOOL completed, NSError *error) {
        dispatch_group_leave(fetchGroup);
        if (error) {
            syncError = error;
        }
    }];

    DMMyLogDataProvider *exerciseProvider = [[DMMyLogDataProvider alloc] init];
    dispatch_group_enter(fetchGroup);
    [exerciseProvider syncExerciseLog:dateString pageNumber:1 fetchedItems:@[] withCompletionBlock:^(BOOL completed, NSError *error) {
        dispatch_group_leave(fetchGroup);
        if (error) {
            syncError = error;
        }
    }];;

    dispatch_group_notify(fetchGroup, dispatch_get_main_queue(),^{
        DMMyLogDataProvider *provider = [[DMMyLogDataProvider alloc] init];
        if (!syncError) {
            [provider syncDatabaseFinished];
        }
        if (completionBlock) {
            completionBlock(syncError == nil, syncError);
        }
    });
}

- (void)syncDatabaseFinished {
    [DMGUtilities setLastSyncToDate:[NSDate date]];
    [[NSNotificationCenter defaultCenter] postNotificationName:DMReloadDataNotification object:nil];
}

#pragma mark - Foods

- (void)syncFavoriteFoods:(NSString *)dateString withCompletionBlock:(completionBlockWithError)completionBlock {
    if (!dateString.length) {
        dateString = [DMGUtilities lastSyncDateString];
    }
    DMAuthManager *authManager = [DMAuthManager sharedInstance];
    if (![authManager isUserLoggedIn]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                NSError *error = [DMGUtilities errorWithMessage:@"User not logged in." code:100];
                completionBlock(NO, error);
            }
        });
        return;
    }
    
    if (!dateString) {
        dateString = [DMGUtilities lastSyncDateString];
    }
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"SyncFavoriteFoods", @"RequestType",
                              dateString, @"LastSync",
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
        NSArray *responseArray = (NSArray *)object;
        FMDatabase* db = [self database];
        if (![db open]) {
        }
        
        [db beginTransaction];
        for (NSDictionary *dict in responseArray) {            
            NSDate* sourceDate = [NSDate date];
            [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            NSString *queryString = [NSString stringWithFormat:@"REPLACE INTO Favorite_Food "
                                     "(FoodID, MeasureID, modified) VALUES "
                                     "(%i, %i, '%@') ",
                                     ValidInt([dict valueForKey:@"FoodId"]),
                                     ValidInt([dict valueForKey:@"MeasureID"]),
                                     sourceDate
                                     ];
            
            [db executeUpdate:queryString];
            if ([db hadError]) {
                DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
        }
        [db commit];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(YES, nil);
            }
        });
    }];
}

- (void)saveFavoriteFoodsWithCompletion:(completionBlockWithError)completionBlock {
    FMDatabase* db = [self database];
    if (![db open]) {
    }
    
    NSString *query = @"SELECT Favorite_FoodID, FoodID, MeasureID, modified FROM Favorite_Food WHERE Favorite_FoodID < 0";
    dispatch_async(self.syncQueue, ^{
        FMResultSet *rs = [db executeQuery:query];
        NSInteger resultCount = 0;
        dispatch_group_t favFoodGroup = dispatch_group_create();
        __block NSError *syncError = nil;
        while ([rs next]) {
            NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  @"SaveFavoriteFood", @"RequestType",
                                  [rs stringForColumn:@"Favorite_FoodID"], @"Favorite_FoodID",
                                  [rs stringForColumn:@"FoodID"], @"FoodID",
                                  [rs stringForColumn:@"MeasureID"], @"MeasureID",
                                  nil];
            
            dispatch_group_enter(favFoodGroup);
            [DMDataFetcher fetchDataWithRequestParams:infoDict completion:^(NSObject *object, NSError *error) {
                if (error) {
                    dispatch_group_leave(favFoodGroup);
                    syncError = error;
                    return;
                }
                dispatch_group_leave(favFoodGroup);
            }];
            resultCount++;
        }
        [rs close];

        // If we had no results, return.
        if (resultCount == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(YES, nil);
                }
            });
            return;
        }

        dispatch_group_notify(favFoodGroup, dispatch_get_main_queue(),^{
            if (completionBlock) {
                completionBlock(syncError == nil, syncError);
            }
        });
    });
}

- (void)saveFavoriteMealsWithCompletionBlock:(completionBlockWithError)completionBlock {
    FMDatabase* db = [self database];
    if (![db open]) {
    }
    
    NSString *query = [NSString stringWithFormat:@"SELECT Favorite_MealID, Favorite_Meal_Name FROM Favorite_Meal WHERE Favorite_MealID <= %@", @"0"];
    
    dispatch_async(self.syncQueue, ^{
        FMResultSet *rs = [db executeQuery:query];
        NSInteger resultCount = 0;
        dispatch_group_t favMealGroup = dispatch_group_create();
        __block NSError *syncError = nil;
        while ([rs next]) {
            // goMealID is Favorite_MealID in database.
            // MealName is Favorite_Meal_Name in database
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  @"SaveFavoriteMeal", @"RequestType",
                                  [rs stringForColumn:@"Favorite_MealID"], @"goMealID",
                                  [rs stringForColumn:@"Favorite_Meal_Name"], @"MealName",
                                  nil];
            dispatch_group_enter(favMealGroup);
            [DMDataFetcher fetchDataWithRequestParams:dict completion:^(NSObject *object, NSError *error) {
                if (error) {
                    syncError = error;
                    dispatch_group_leave(favMealGroup);
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
                
                dispatch_group_leave(favMealGroup);
            }];
            resultCount++;
        }
        [rs close];

        // If we had no results, return.
        if (resultCount == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(YES, nil);
                }
            });
            return;
        }

        dispatch_group_notify(favMealGroup, dispatch_get_main_queue(),^{
            if (completionBlock) {
                completionBlock(syncError == nil, syncError);
            }
        });
    });
}

- (void)saveFavoriteMealItem:(int)mealID withCompletionBlock:(completionBlockWithError)completionBlock {
    FMDatabase* db = [self database];
    if (![db open]) {
    }
    
    NSString *query = [NSString stringWithFormat:@"SELECT Favorite_Meal_ID, FoodKey, MeasureID, Servings FROM Favorite_Meal_Items WHERE Favorite_Meal_ID = %i ", mealID];
    
    dispatch_async(self.syncQueue, ^{
        FMResultSet *rs = [db executeQuery:query];
        dispatch_group_t favMealItemGroup = dispatch_group_create();
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
            
            dispatch_group_enter(favMealItemGroup);
            [DMDataFetcher fetchDataWithRequestParams:dict completion:^(NSObject *object, NSError *error) {
                if (error) {
                    dispatch_group_leave(favMealItemGroup);
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
                dispatch_group_leave(favMealItemGroup);
            }];
        }
        [rs close];
        
        dispatch_group_notify(favMealItemGroup, dispatch_get_main_queue(),^{
            if (completionBlock) {
                completionBlock(YES, nil);
            }
        });
    });
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
    
    dispatch_async(self.syncQueue, ^{
        FMResultSet *rs = [db executeQuery:query];
        NSInteger resultCount = 0;
        dispatch_group_t saveFoodGroup = dispatch_group_create();
        __block NSError *fetchError = nil;
        while ([rs next]) {
            NSDictionary *resultDict = [rs resultDictionary];
            DMFood *food = [[DMFood alloc] initWithDictionary:resultDict];
            NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                  @"SaveFoodNew", @"RequestType",
                                  nil];
            NSDictionary *foodDict = [food dictionaryRepresentation];
            [mutableDict addEntriesFromDictionary:foodDict];
            
            dispatch_group_enter(saveFoodGroup);
            [DMDataFetcher fetchDataWithRequestParams:mutableDict completion:^(NSObject *object, NSError *error) {
                if (error) {
                    fetchError = error;
                    dispatch_group_leave(saveFoodGroup);
                    return;
                }
                NSArray *results = (NSArray *)object;
                 [self saveFoodFinished:results forFood:food];
                dispatch_group_leave(saveFoodGroup);
             }];
            resultCount++;
        }
        [rs close];

        // If we had no results, return.
        if (resultCount == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(YES, nil);
                }
            });
            return;
        }
        
        dispatch_group_notify(saveFoodGroup, dispatch_get_main_queue(),^{
            if (completionBlock) {
                completionBlock(fetchError != nil, fetchError);
            }
        });
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

- (NSString *)getMeasureDescriptionForMeasureId:(NSNumber *)measureId
                                     forFoodKey:(NSNumber *)foodKey {
    FMDatabase* db = [self database];
    if (![db open]) {
    }
        
    NSString *query = [NSString stringWithFormat: @"SELECT m.MeasureID, m.Description, fm.GramWeight FROM Measure m INNER JOIN FoodMeasure fm ON fm.MeasureID = m.MeasureID WHERE fm.FoodID = %@ AND m.MeasureID = %@ ORDER BY m.Description", foodKey, measureId];
    
    NSString *measureDescription = nil;
    FMResultSet *rs = [db executeQuery:query];
    while ([rs next]) {
        measureDescription = [rs stringForColumn:@"Description"];
    }
    [rs close];
    
    return measureDescription;
}

- (NSArray<NSDictionary *> *)getMeasureDetailsForFoodKey:(NSNumber *)foodKey {
    FMDatabase* db = [self database];
    if (![db open]) {
    }
        
    NSString *query = [NSString stringWithFormat: @"SELECT m.MeasureID, m.Description, fm.GramWeight FROM Measure m INNER JOIN FoodMeasure fm ON fm.MeasureID = m.MeasureID WHERE fm.FoodID = %@ ORDER BY m.Description", foodKey];
        
    NSMutableArray *results = [NSMutableArray array];
    FMResultSet *rs = [db executeQuery:query];
    while ([rs next]) {
        [results addObject:[rs resultDictionary]];
    }
    [rs close];
    
    return [results copy];
}

- (BOOL)isFoodFavoritedForFoodKey:(NSNumber *)foodKey {
    FMDatabase* db = [self database];
    if (![db open]) {
    }
        
    NSString *query = [NSString stringWithFormat: @"SELECT count(*) as favCount FROM Favorite_Food WHERE FoodID = %@", foodKey];
    
    BOOL isFavorite = NO;
    FMResultSet *rs = [db executeQuery:query];
    while ([rs next]) {
        isFavorite = [rs intForColumn:@"favCount"] > 0;
    }
    [rs close];
    
    return isFavorite;
}

#pragma mark - Meals

- (void)syncFavoriteMealsWithCompletionBlock:(completionBlockWithError)completionBlock {
    DMAuthManager *authManager = [DMAuthManager sharedInstance];
    if (![authManager isUserLoggedIn]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                NSError *error = [DMGUtilities errorWithMessage:@"User not logged in." code:100];
                completionBlock(NO, error);
            }
        });
        return;
    }

    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"SyncFavoriteMeals", @"RequestType",
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
        NSArray *responseArray = (NSArray *)object;
        FMDatabase* db = [self database];
        if (![db open]) {
        }
        
        [db beginTransaction];
        for (NSDictionary *dict in responseArray) {
            NSString *mealName = ValidString([dict valueForKey:@"MealFavoriteName"]);
            NSRange range = [mealName rangeOfString:@"\\s*$" options:NSRegularExpressionSearch];
            NSString *favoriteMealName = [mealName stringByReplacingCharactersInRange:range withString:@""];
            
            NSDate *sourceDate = [NSDate date];
            
            NSString *queryString = [NSString stringWithFormat:@"REPLACE INTO Favorite_Meal "
                                     "(Favorite_MealID, Favorite_Meal_Name, modified) VALUES "
                                     "(%i, '%@', '%@') ",
                                     ValidInt([dict valueForKey:@"MealFavoriteID"]),
                                     favoriteMealName,
                                     sourceDate
                                     ];
            [db executeUpdate:queryString];
            if ([db hadError]) {
                DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
        }
        [db commit];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(YES, nil);
            }
        });
    }];
}

- (void)syncFavoriteMealItemsWithCompletionBlock:(completionBlockWithError)completionBlock {
    DMAuthManager *authManager = [DMAuthManager sharedInstance];
    if (![authManager isUserLoggedIn]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                NSError *error = [DMGUtilities errorWithMessage:@"User not logged in." code:100];
                completionBlock(NO, error);
            }
        });
        return;
    }
    
    dispatch_async(self.syncQueue, ^{
        FMDatabase* db = [self database];
        if (![db open]) {
        }
        
        NSString *query = [NSString stringWithFormat:@"SELECT Favorite_MealID, modified FROM Favorite_Meal WHERE Favorite_MealID > %@", @"0"];
        FMResultSet *rs = [db executeQuery:query];
        
        dispatch_group_t getMealItemsGroup = dispatch_group_create();
        while ([rs next]) {
            // MealID is equal to Favorite_MealID in database.
            NSString *mealId = [rs stringForColumn:@"Favorite_MealID"];
            __block NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                              @"GetFavoriteMealItems", @"RequestType",
                                              [rs stringForColumn:@"Favorite_MealID"], @"MealID", nil];
            dispatch_group_enter(getMealItemsGroup);
            [DMDataFetcher fetchDataWithRequestParams:infoDict completion:^(NSObject *object, NSError *error) {
                if (error) {
                    dispatch_group_leave(getMealItemsGroup);
                    return;
                }
                NSArray *responseArray = (NSArray *)object;
                // Add the ID back to Favorite_MealID, or just fix the save statement.
                NSMutableArray *fixedArray = [NSMutableArray array];
                for (NSDictionary *dict in responseArray) {
                    NSMutableDictionary *newDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
                    [newDict setValue:mealId forKey:@"Favorite_Meal_ID"];
                    [fixedArray addObject:newDict];
                }
                responseArray = fixedArray;
                [self saveFavoriteMealItems:responseArray forFavoriteMealID:nil];
                dispatch_group_leave(getMealItemsGroup);
            }];
        }
        [rs close];
        
        dispatch_group_notify(getMealItemsGroup, dispatch_get_main_queue(),^{
            if (completionBlock) {
                completionBlock(YES, nil);
            }
        });
    });
}

- (void)saveFavoriteMeal:(NSDictionary *)mealDict withName:(NSString *)mealName {
    [DMActivityIndicator showActivityIndicator];

    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }
    
    int minIDvalue = 0;
    NSString *idQuery = @"SELECT min(Favorite_MealID) as Favorite_MealID FROM Favorite_Meal";
    FMResultSet *rsID = [db executeQuery:idQuery];
    while ([rsID next]) {
        minIDvalue = [rsID intForColumn:@"Favorite_MealID"];
    }
    [rsID close];
    minIDvalue = minIDvalue - 1;
    if (minIDvalue >=0) {
        int maxValue = minIDvalue;
        for (int i=0; i<maxValue; i++) {
            if (minIDvalue < 0){
                break;
            }
            minIDvalue--;
        }
    }
    
    [db beginTransaction];
    
    NSDate *sourceDate = [NSDate date];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
    [self.dateFormatter setTimeZone:systemTimeZone];
    NSString *date_string = [self.dateFormatter stringFromDate:sourceDate];
    
    NSString *insertSQL = [NSString stringWithFormat: @"REPLACE INTO Favorite_Meal (Favorite_MealID, Favorite_Meal_Name, modified) VALUES (%i, '%@',DATETIME('%@'))", minIDvalue, mealName, date_string];
    [db executeUpdate:insertSQL];
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
    
    int favoriteMealID = (int)[db lastInsertRowId];
    [self saveFavoriteMealItems:mealDict[@"Foods"]
              forFavoriteMealID:@(favoriteMealID)];
}

- (void)saveMealsWithCompletionBlock:(completionBlockWithError)completionBlock {
    FMDatabase* db = [self database];
    if (![db open]) {
    }
    
    NSString *query = @"SELECT MealID, MealDate FROM Food_Log WHERE MealID <= 0";
    dispatch_async(self.syncQueue, ^{
        __block NSInteger resultCount = 0;
        dispatch_group_t mealsFetchGroup = dispatch_group_create();
        __block NSError *syncError = nil;
        FMResultSet *rs = [db executeQuery:query];
        while ([rs next]) {
            [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *log_Date = [self.dateFormatter dateFromString:[rs stringForColumn:@"MealDate"]];
            if (log_Date == nil) {
                continue;
            }
            
            [self.dateFormatter setDateFormat:@"M/dd/yyyy"];
            NSString *logTimeString = [self.dateFormatter stringFromDate:log_Date];
            
            // goMealID = MealID in database.
            // LogDate = MealDate in database
            NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      @"SaveMeal", @"RequestType",
                                      logTimeString, @"LogDate",
                                      [rs stringForColumn:@"MealID"], @"goMealID",
                                      nil];
            dispatch_group_enter(mealsFetchGroup);
            [DMDataFetcher fetchDataWithRequestParams:infoDict completion:^(NSObject *object, NSError *error) {
                if (error) {
                    dispatch_group_leave(mealsFetchGroup);
                    syncError = error;
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
                dispatch_group_leave(mealsFetchGroup);
            }];
            resultCount++;
        }
        [rs close];
        
        // Incase we had no results.
        if (resultCount == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(YES, nil);
                }
            });
            return;
        }
        
        dispatch_group_notify(mealsFetchGroup, dispatch_get_main_queue(),^{
            if (completionBlock) {
                completionBlock(syncError == nil, syncError);
            }
        });
    });
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
                    BOOL success = (error == nil);
                    completionBlock(success, error);
                }
            });
            return;
        }
        NSArray *results = (NSArray *)object;
        [self processSaveMealItemResults:results];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(YES, nil);
            }
        });
    }];
}

/// Saves favorite meal items to the database. If favoriteMealID is nil,
/// it will attempt to grab "Favorite_Meal_ID" from the array.
- (void)saveFavoriteMealItems:(NSArray *)mealItems
            forFavoriteMealID:(NSNumber *)favoriteMealID {
    if (!mealItems.count) {
        return;
    }
    
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }

    for (NSDictionary *dict in mealItems) {
        if (!favoriteMealID) {
            favoriteMealID = dict[@"Favorite_Meal_ID"];
        }
        [db beginTransaction];
        NSDate* sourceDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
        [dateFormatter setTimeZone:systemTimeZone];
        NSString *date_string = [dateFormatter stringFromDate:sourceDate];
        
        double numOfServings = 1.0;
        if ([dict valueForKey:@"Servings"]) {
            numOfServings = [[dict valueForKey:@"Servings"] floatValue];
        } else if ([dict valueForKey:@"NumberOfServings"]) {
            numOfServings = [[dict valueForKey:@"NumberOfServings"] floatValue];
        }
        
        NSString *insertSQLItems = [NSString stringWithFormat: @"REPLACE INTO Favorite_Meal_Items (FoodKey, Favorite_Meal_ID, FoodID, MeasureID, Servings, Last_Modified) VALUES (%i, %i, %i, %i, %f, DATETIME('%@'))",
                                    [[dict valueForKey:@"FoodID"] intValue], // FoodKey??
                                    favoriteMealID.intValue,
                                    [[dict valueForKey:@"FoodID"] intValue],
                                    [[dict valueForKey:@"MeasureID"] intValue],
                                    numOfServings,
                                    date_string];
        [db executeUpdate:insertSQLItems];
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
    }
}

/// Processes the results from a save meal item save to server.
- (void)processSaveMealItemResults:(NSArray *)responseArray {
    FMDatabase* db = [self database];
    if (![db open]) {
        DM_LOG(@"Error, Database not open.");
        return;
    }
    
    [db beginTransaction];
    for (NSDictionary *dict in responseArray) {
        NSDate* sourceDate = [NSDate date];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
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

- (NSNumber *)getMeasureIDForFoodKey:(NSNumber *)foodKey fromMealPlanItem:(DMMealPlanItem *)mealPlanItem {
    FMDatabase* db = [self database];
    if (![db open]) {
    }
    DMFood *mealPlanFood = [self getFoodForFoodKey:mealPlanItem.foodId];
    
    NSNumber *exchangeID = 0;
    NSInteger measureID = 0;
    NSString *query = @"";
    int exchangeGramWeight = 0;
    if (mealPlanItem != nil) {
        exchangeGramWeight = [mealPlanFood.gramWeight intValue];
        exchangeID = mealPlanItem.measureId;
        
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

#pragma mark - Exercise

- (void)syncExerciseLog:(NSString *)dateString
             pageNumber:(NSInteger)pageNumber
           fetchedItems:(NSArray *)fetchedItems
    withCompletionBlock:(completionBlockWithError)completionBlock {
    if (!dateString.length) {
        dateString = [DMGUtilities lastSyncDateString];
    }
    DMAuthManager *authManager = [DMAuthManager sharedInstance];
    if (![authManager isUserLoggedIn]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                NSError *error = [DMGUtilities errorWithMessage:@"User not logged in." code:100];
                completionBlock(NO, error);
            }
        });
        return;
    }

    // Must start at one.
    if (pageNumber == 0) {
        pageNumber = 1;
    }
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"SyncExerciseLogNew", @"RequestType",
                              dateString, @"LastSync",
                              @1000, @"PageSize",
                              @(pageNumber), @"PageNumber",
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
        
        NSArray *responseArray = (NSArray *)object;
        // Process response with things.
        NSArray *exerciseLogs = responseArray.firstObject[@"ExerciseLogs"];
        exerciseLogs = [exerciseLogs arrayByAddingObjectsFromArray:fetchedItems];

        int totalCount = 0;
        if (responseArray.count) {
            totalCount = [responseArray.firstObject[@"TotalCount"] intValue];
        }
        if (exerciseLogs.count < totalCount) {
            [self syncExerciseLog:dateString
                       pageNumber:(pageNumber + 1)
                     fetchedItems:[exerciseLogs copy]
              withCompletionBlock:completionBlock];
            return;
        }
        
        [self saveExerciseLogs:exerciseLogs];
        
        // Done fetching everything!
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(YES, nil);
            }
        });
    }];
}

/// Saves an array of exercise logs to the local database.
- (void)saveExerciseLogs:(NSArray *)exerciseLogs {
    FMDatabase* db = [self database];
    if (![db open]) {
    }
    
    [db beginTransaction];
    for (NSDictionary *exercise in exerciseLogs) {
        
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSLocale *en_US = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [self.dateFormatter setLocale:en_US];
        NSDate *logTimeDate = [self.dateFormatter dateFromString:[exercise valueForKey:@"ExerciseDate"]];
        NSString *logTimeString = [self.dateFormatter stringFromDate:logTimeDate];
        
        [self.dateFormatter setDateFormat:@"yyyyMMdd"];
        NSString *keyDate = [self.dateFormatter stringFromDate:logTimeDate];
        
        int exerciseID = [[exercise valueForKey:@"ExerciseID"] intValue];
        NSString *exerciseLogStrID = [NSString stringWithFormat:@"%@-%i", keyDate, exerciseID];
        NSDate *sourceDate = [NSDate date];
        
        NSString *queryString = [NSString stringWithFormat:@"REPLACE INTO Exercise_Log "
                                 "(Exercise_Log_StrID, ExerciseID, Exercise_Time_Minutes, Log_Date, Date_Modified) VALUES "
                                 "('%@', %i, %i, '%@', '%@') ",
                                 exerciseLogStrID,
                                 exerciseID,
                                 [[exercise valueForKey:@"Duration"] intValue],
                                 logTimeString,
                                 sourceDate ];
    
        [db executeUpdate:queryString];
    }
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
}

- (void)saveExerciseLogsWithCompletionBlock:(completionBlockWithError)completionBlock {
    FMDatabase* db = [self database];
    if (![db open]) {
    }
    
    NSString *query = @"SELECT ExerciseID, Exercise_Time_Minutes, Log_Date, Exercise_Log_StrID FROM Exercise_Log";
    FMResultSet *rs = [db executeQuery:query];
    
    NSMutableArray *tempDataArray = [[NSMutableArray alloc] init];
    while ([rs next]) {
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *log_Date = [self.dateFormatter dateFromString:[rs stringForColumn:@"Log_Date"]];
        if (log_Date == nil) {
            continue;
        }
        
        [self.dateFormatter setDateFormat:@"M/dd/yyyy"];
        NSString *logTimeString = [self.dateFormatter stringFromDate:log_Date];
        NSString *finalLogString = [NSString stringWithFormat:@"%@ 12:00:00 AM", logTimeString];
        NSDictionary *tempDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  [rs stringForColumn:@"ExerciseID"], @"ExerciseID",
                                  finalLogString, @"LogDate",
                                  [rs stringForColumn:@"Exercise_Time_Minutes"], @"Duration",
                                  nil];
        [tempDataArray addObject:tempDict];
    }
    [rs close];

    if (!tempDataArray.count) {
        if (completionBlock) {
            completionBlock(YES, nil);
        }
        return;
    }

    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"SaveExerciseLogs", @"RequestType",
                              nil];
    [DMDataFetcher fetchDataWithRequestParams:infoDict
                                   jsonObject:[tempDataArray copy]
                                   completion:^(NSObject *object, NSError *error) {
        if (completionBlock) {
            BOOL success = (error == nil);
            completionBlock(success, error);
        }
    }];
}

#pragma mark - Weight Log

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
    [rs close];

    if (!tempDataArray.count) {
        if (completionBlock) {
            completionBlock(YES, nil);
        }
        return;
    }
    
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"SaveWeightLogs", @"RequestType",
                                nil];
    
    [DMDataFetcher fetchDataWithRequestParams:infoDict
                                   jsonObject:[tempDataArray copy]
                                   completion:^(NSObject *object, NSError *error) {
        if (completionBlock) {
            BOOL success = (error == nil);
            completionBlock(success, error);
        }
    }];
}

#pragma mark - Log

- (NSNumber *)getLogMealIDForDate:(NSDate *)date {
    FMDatabase* db = [self database];
    if (![db open]) {
    }

    int mealIDValue = 0;
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
    [self.dateFormatter setTimeZone:systemTimeZone];
    NSString *date_Today = [self.dateFormatter stringFromDate:date];
    
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
    
    return @(minIDvalue);
}

- (void)deleteFoodFromLogWithID:(NSNumber *)foodKey
                      logMealId:(NSNumber *)logMealId
                       mealCode:(DMLogMealCode)mealCode
                completionBlock:(completionBlockWithError)completionBlock {
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"DeleteMealItem", @"RequestType",
                                logMealId, @"MealID",
                                @(mealCode), @"MealCode",
                                foodKey, @"FoodID",
                                nil];

    [DMDataFetcher fetchDataWithRequestParams:infoDict completion:^(NSObject *object, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(error == nil, error);
            }
        });
    }];
}

#pragma mark - Foods

- (void)syncFoods:(NSString *)dateString pageNumber:(NSInteger)pageNumber fetchedItems:(NSArray *)fetchedItems withCompletionBlock:(completionBlockWithError)completionBlock {
    DMAuthManager *authManager = [DMAuthManager sharedInstance];
    if (![authManager isUserLoggedIn]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                NSError *error = [DMGUtilities errorWithMessage:@"User not logged in." code:100];
                completionBlock(NO, error);
            }
        });
        return;
    }

    if (!dateString) {
        dateString = [DMGUtilities lastFoodSyncDateString];
    }
    dateString = @"2015-01-01";
    // Must start at one.
    if (pageNumber == 0) {
        pageNumber = 1;
    }
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"SyncFoodsNew", @"RequestType",
                              dateString, @"LastSync",
                              @1000, @"PageSize",
                              @(pageNumber), @"PageNumber",
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
        
        NSArray *responseArray = (NSArray *)object;
        // Process response with things.
        NSArray *foodArray = responseArray.firstObject[@"Foods"];
        foodArray = [foodArray arrayByAddingObjectsFromArray:fetchedItems];

        int totalCount = 0;
        if (responseArray.count) {
            totalCount = [responseArray.firstObject[@"TotalCount"] intValue];
        }
        if (foodArray.count < totalCount) {
            [self syncFoods:dateString
                 pageNumber:(pageNumber + 1)
               fetchedItems:[foodArray copy]
        withCompletionBlock:completionBlock];
            return;
        }
        
        [self saveFoods:foodArray];
        
        // Done fetching everything!
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(YES, nil);
            }
        });
    }];
}

- (void)fetchFoodForFoodId:(NSNumber *)foodId {
    if (!foodId) {
        return;
    }
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"GetFoodNew", @"RequestType",
                              foodId, @"FoodKey", // Same as FoodID.
                              nil];
    
    [DMDataFetcher fetchDataWithRequestParams:infoDict completion:^(NSObject *object, NSError *error) {
         [self saveFoods:(NSArray *)object];
     }];
}

- (void)getMissingFoodsForMealItems:(NSArray<DMMealPlanItem *> *)itemsArray {
    FMDatabase* db = [self database];
    if (![db open]) {
    }
    
    NSMutableArray *missingFoods = [NSMutableArray array];
    for (DMMealPlanItem *planItem in itemsArray) {
        NSString *query = [NSString stringWithFormat: @"SELECT COUNT (Food.FoodID) as FoodCount FROM Food "
                           "INNER JOIN FoodMeasure ON FoodMeasure.FoodID = Food.FoodKey "
                           "INNER JOIN Measure ON FoodMeasure.MeasureID = Measure.MeasureID "
                           "WHERE Food.FoodKey = %i AND Measure.MeasureID = %i LIMIT 1",
                           planItem.foodId.intValue,
                           planItem.measureId.intValue];
        
        FMResultSet *rs = [db executeQuery:query];
        NSNumber  *resultCount = @0;
        while ([rs next]) {
            resultCount = @([rs intForColumn:@"FoodCount"]);
        }
        [rs close];
        if (resultCount.intValue == 0) {
            [missingFoods addObject:planItem.foodId];
        }
    }

    for (NSNumber *foodId in missingFoods) {
        [self fetchFoodForFoodId:foodId];
    }
}

- (DMFood *)getFoodForFoodKey:(NSNumber *)foodKey {
    FMDatabase* db = [self database];
    if (![db open]) {
    }
    
    NSString *query = [NSString stringWithFormat: @"SELECT * FROM Food WHERE FoodKey = %@", foodKey];
    FMResultSet *rs = [db executeQuery:query];
    DMFood *food = nil;
    while ([rs next]) {
        NSDictionary *resultDict = [rs resultDictionary];
        food = [[DMFood alloc] initWithDictionary:resultDict];
    }
    [rs close];

    return food;
}

- (void)saveFoods:(NSArray *)foodsArray {
    FMDatabase* db = [self database];
    if (![db open]) {
    }
    
    [db beginTransaction];
    
    for (NSDictionary *dict in foodsArray) {
        DMFood *food = [[DMFood alloc] initWithDictionary:dict];

        NSString *insertSQL = [NSString stringWithFormat:@"REPLACE INTO Food "
                                "(ScannedFood, "
                                 "FoodPK, FoodKey, "
                                 "FoodID, CategoryID, "
                                 "CompanyID, UserID, "
                                 "Name, Calories, "
                                 "Fat, Sodium, "
                                 "Carbohydrates, SaturatedFat, "
                                 "Cholesterol, Protein, "
                                 "Fiber, Sugars, "
                                 "Pot, A, "
                                 "Thi, Rib, "
                                 "Nia, B6, "
                                 "B12, Fol, "
                                 "C, Calc, "
                                 "Iron, Mag, "
                                 "Zn, ServingSize, "
                                 "FoodTags, Frequency, "
                                 "Alcohol, Folate, "
                                 "Transfat, E, "
                                 "D, UPCA, "
                                 "FactualID, ParentGroupID,"
                                 "RegionCode, LastUpdateDate,"
                                 "RecipeID, FoodURL)"
                                 "VALUES"
                                 "(%d, "
                                 "%i, %i, "
                                 "%i, %i, "
                                 "%i, %i, "
                                 "\"%@\", %f, " //Name, Calories
                                 "%f, %f, "
                                 "%f, %f, "
                                 "%f, %f, "
                                 "%f, %f, "
                                 "%f, %f, " //Pot, A
                                 "%f, %f, "
                                 "%f, %f, "
                                 "%f, %f, "
                                 "%f, %f, "
                                 "%f, %f, "
                                 "%f, %f, "
                                 "\"%@\", %i, " //FoodTags, Frequency
                                 "%f, %f, "
                                 "%f, %f, "
                                 "%f, \"%@\", "
                                 "%i , %i, "
                                 "%i, \"%@\", "
                                 "%i, \"%@\") ",
                                 
                               food.scannedFood.boolValue,
                                
                               food.foodPK.intValue,
                               food.foodKey.intValue,
                                
                               food.foodId.intValue,
                               food.categoryId.intValue,
                                
                               food.companyId.intValue,
                               food.userId.intValue,
                               
                               food.name,
                                
                               food.calories.doubleValue,
                               food.fat.doubleValue,
                               food.sodium.doubleValue,
                               food.carbohydrates.doubleValue,
                               food.saturatedFat.doubleValue,
                               food.cholesterol.doubleValue,
                               food.protein.doubleValue,
                               food.fiber.doubleValue,
                               food.sugars.doubleValue,
                               food.pot.doubleValue,
                               food.a.doubleValue,
                               food.thi.doubleValue,
                               food.rib.doubleValue,
                               food.nia.doubleValue,
                               food.b6.doubleValue,
                               food.b12.doubleValue,
                               food.fol.doubleValue,
                               food.c.doubleValue,
                               food.calc.doubleValue,
                               food.iron.doubleValue,
                               food.mag.doubleValue,
                               food.zn.doubleValue,
                               
                               food.servingSize.doubleValue,
                               food.foodTags,
                               
                               food.frequency.intValue,
                               food.alcohol.doubleValue,
                               food.folate.doubleValue,
                               food.transFat.doubleValue,
                               food.e.doubleValue,
                               food.d.doubleValue,
                               food.barcodeUPCA,
                               food.factualId.intValue,
                               food.parentGroupID.intValue,
                               food.regionCode.intValue,
                               food.lastUpdateDateString,
                               food.recipeId.intValue,
                               food.foodURL];
        
        [db executeUpdate:insertSQL];
        
        int gramWeight = 100;
        if ([dict valueForKey:@"GramWeights"]) {
            gramWeight = [[dict valueForKey:@"GramWeights"] intValue];
        }
        
        NSString *strGram = [NSString stringWithFormat:@"100"];
        if ([dict valueForKey:@"GramWeights"]) {
            strGram = [dict valueForKey:@"GramWeights"];
        }
        
        NSString *strFoodMeasID = [dict valueForKey:@"MeasureIDs"];
        NSArray *arrFoodMeasID = [strFoodMeasID componentsSeparatedByString:@","];
        NSString *strGrams = strGram;
        NSArray *arrGrams = [strGrams componentsSeparatedByString:@","];
        if (arrFoodMeasID.count>0) {
            for (int i=0 ; i<arrFoodMeasID.count; i++) {
                NSString *strFoodMeasureIDNew = [arrFoodMeasID objectAtIndex:i];
                NSString *strFoodGrams= [arrGrams objectAtIndex:i];
                NSString *insertFMSQL = [NSString stringWithFormat: @"REPLACE INTO FoodMeasure (FoodID, MeasureID, GramWeight) VALUES (%i, %i, %i)", [[dict valueForKey:@"FoodKey"] intValue],[strFoodMeasureIDNew intValue], [strFoodGrams intValue]];
                [db executeUpdate:insertFMSQL];
            }
        }
        else {
            NSString *insertFMSQL = [NSString stringWithFormat: @"REPLACE INTO FoodMeasure (FoodID, MeasureID, GramWeight) VALUES (%i, %i, %i)", [[dict valueForKey:@"FoodKey"] intValue],[[dict valueForKey:@"MeasureIDs"] intValue], gramWeight];
            [db executeUpdate:insertFMSQL];
        }
        
        NSString *strMeasureID = [dict valueForKey:@"MeasureIDs"];
        NSArray *arrMeasure = [strMeasureID componentsSeparatedByString:@","];
        NSString *strMeasureDes = [dict valueForKey:@"MeasureDescriptions"];
        NSArray *arrMeasureDesc = [strMeasureDes componentsSeparatedByString:@","];
        
        if (arrMeasure.count>0) {
            for (int i=0 ; i<arrMeasure.count; i++) {
                NSString *strMeasureIDNew = [arrMeasure objectAtIndex:i];
                NSString *strMeasureDescription;
                if (arrMeasureDesc.count > i) {
                    strMeasureDescription = [arrMeasureDesc objectAtIndex:i];
                } else {
                    //anything in here contains an invalid measureid
                    strMeasureDescription = [arrMeasureDesc objectAtIndex:(arrMeasureDesc.count - 1)];
                }
                
                NSString *insertForMessure = [NSString stringWithFormat: @"INSERT OR REPLACE INTO Measure (MeasureID, Description) VALUES (%i, '%@')",[strMeasureIDNew intValue],strMeasureDescription];
                [db executeUpdate:insertForMessure];
                
                
            }
        }
        else {
            NSString *insertForMessure = [NSString stringWithFormat: @"INSERT OR REPLACE INTO Measure (MeasureID, Description) VALUES (%i, '%@')",[[dict valueForKey:@"MeasureIDs"] intValue],[dict valueForKey:@"MeasureDescriptions"]];
            [db executeUpdate:insertForMessure];
        }
    }
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
}

#pragma mark - User Data

- (void)getDataSinceLastSyncDate:(NSString *)syncDate
             withCompletionBlock:(completionBlockWithError)completionBlock {
    if (!syncDate.length) {
        syncDate = [DMGUtilities lastSyncDateString];
    }
    DMUser *currentUser = [[DMAuthManager sharedInstance] loggedInUser];
    [[FIRCrashlytics crashlytics] logWithFormat:@"GetUserData-UserId: %@", currentUser.userId];
    
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"GetUserData", @"RequestType",
                                syncDate, @"LastSync",
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
        
        NSDictionary *responseDict = (NSDictionary *)object;
        [self saveUserData:responseDict];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(YES, nil);
            }
        });
    }];
}

/// Processes the data from the DMDataFetcher.
- (void)saveUserData:(NSDictionary *)responseDict {
    if (!responseDict) {
        return;
    }
    
    FMDatabase* db = [self database];
    if (![db open]) {
        DM_LOG(@"Could not open db.");
        return;
    }
    
    NSDictionary *dict = responseDict;
    
    NSDictionary *userDict = [dict[@"User"] firstObject];
    // Update User Info
    if (userDict) {
        DMUser *currentUser = [[DMAuthManager sharedInstance] loggedInUser];
        [currentUser updateUserDetails:userDict];
        [[DMAuthManager sharedInstance] saveCurrentUserToDefaultsAndDatabase];
        
        // Log values to Firebase.
        [[FIRCrashlytics crashlytics] log:@"GetUserData completed."];
        for (id key in userDict) {
            [[FIRCrashlytics crashlytics] setCustomValue:[userDict valueForKey:key] forKey:key];
        }
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setValue:currentUser.hostName forKey:@"HostName"];
    }
    
    NSArray *weightArray = [dict valueForKey:@"Weight"];
    if (weightArray.count) {
        [db beginTransaction];
        for (NSDictionary *dict in weightArray) {
            
            DMWeightLogEntry *weightLogEntry = [[DMWeightLogEntry alloc] initWithDictionary:dict
                                                                                  entryType:DMWeightLogEntryTypeWeight];
            
            NSString *queryString = [NSString stringWithFormat:@"REPLACE INTO weightlog "
                                     "(weight, logtime, deleted, entry_type) VALUES "
                                     "(%f, '%@', 1, %i) ",
                                     weightLogEntry.value.doubleValue,
                                     weightLogEntry.logDateString,
                                     (int)weightLogEntry.entryType
                                     ];
            
            [db executeUpdate:queryString];
        }
        
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
    }
    
    NSArray *bodyFatArray = [dict valueForKey:@"BodyFat"];
    if (bodyFatArray.count) {
        [db beginTransaction];
        
        NSString *strTempWeight;
        NSString *strTempDeleted;
        for (NSDictionary *dict in bodyFatArray) {
            DMWeightLogEntry *weightLogEntry = [[DMWeightLogEntry alloc] initWithDictionary:dict
                                                                                  entryType:DMWeightLogEntryTypeBodyFat];

            NSString *getWeightSQL = [NSString stringWithFormat:@"SELECT weight, deleted FROM weightlog where logtime =\"%@\"",
                                      weightLogEntry.logDateString];
            FMResultSet *rs = [db executeQuery:getWeightSQL];
            while ([rs next]) {
                strTempWeight = [NSString stringWithFormat:@"%f", [rs doubleForColumn:@"weight"]];
                strTempDeleted = [NSString stringWithFormat:@"%d", [rs intForColumn:@"deleted"]];
            }
            
            NSString *queryString = [NSString stringWithFormat:@"REPLACE INTO weightlog "
                                     "(weight, bodyfat, logtime, deleted, entry_type) VALUES "
                                     "(%@, %f, '%@', %@, %i)",
                                     strTempWeight,
                                     weightLogEntry.value.doubleValue,
                                     weightLogEntry.logDateString,
                                     strTempDeleted,
                                     (int)weightLogEntry.entryType
                                     ];
            
            [db executeUpdate:queryString];
        }
        
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
    }
    
    NSArray *userFoodsArray = [dict valueForKey:@"UserFoods"];
    if (userFoodsArray.count) {
        [db beginTransaction];
        
        for (NSDictionary *dict in userFoodsArray) {
            
            DMFood *food = [[DMFood alloc] initWithDictionary:dict];
            NSString *replaceIntoSQL = [food replaceIntoSQLString];
            [db executeUpdate:replaceIntoSQL];
            
            NSString *insertFMSQL = [NSString stringWithFormat: @"REPLACE INTO FoodMeasure (FoodID, MeasureID, GramWeight) VALUES (%i, %i, %i)",
                                     food.foodKey.intValue,
                                     food.measureId.intValue,
                                     food.gramWeight.intValue];
            
            [db executeUpdate:insertFMSQL];
        }
        
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
    }
    
    NSArray *companyFoodsArray = [dict valueForKey:@"CompanyFoods"];
    if (companyFoodsArray.count) {
        [db beginTransaction];
                    
        for (NSDictionary *dict in companyFoodsArray) {
            DMFood *food = [[DMFood alloc] initWithDictionary:dict];
            NSString *replaceIntoSQL = [food replaceIntoSQLString];
            [db executeUpdate:replaceIntoSQL];
            
            NSString *insertFMSQL = [NSString stringWithFormat: @"REPLACE INTO FoodMeasure (FoodID, MeasureID, GramWeight) VALUES (%i, %i, %i)",
                                     food.foodKey.intValue,
                                     food.measureId.intValue,
                                     food.gramWeight.intValue];
            [db executeUpdate:insertFMSQL];
        }
        
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
    }
    
    if ([dict valueForKey:@"LogData"]) {
        NSArray *logArray = [dict valueForKey:@"LogData"];
        if (logArray.count > 0) {
            [db beginTransaction];
            for (NSDictionary *dict in logArray) {
                
                NSString *queryString = [NSString stringWithFormat:@"REPLACE INTO Food_Log "
                                         "(MealID, MealDate) VALUES "
                                         "(%i, '%@') ",
                                         [[dict valueForKey:@"MealID"] intValue],
                                         [dict valueForKey:@"MealDate"]
                                         ];
                [db executeUpdate:queryString];
                
                NSString *selectString = [NSString stringWithFormat:@"SELECT FoodID, MealCode, LastModified FROM Food_Log_Items WHERE MealID = %i", [[dict valueForKey:@"MealID"] intValue]];
                
                FMResultSet *rs = [db executeQuery:selectString];
                NSMutableArray *existingLogItems = [[NSMutableArray alloc] init];
                
                while ([rs next]) {
                    NSNumber *mealCode = [NSNumber numberWithInt:[rs intForColumn:@"MealCode"]];
                    NSNumber *foodId = [NSNumber numberWithInt:[rs intForColumn:@"FoodID"]];
                    NSString *foodlastmodified = [[rs stringForColumn:@"LastModified"] stringByReplacingOccurrencesOfString:@"+0000" withString:@""];

                    NSDictionary *tempDict = [[NSDictionary alloc] initWithObjectsAndKeys:mealCode, @"MealCode", foodId, @"FoodID", foodlastmodified, @"LastModified", nil];
                    [existingLogItems addObject:tempDict];
                }
                
                for (NSDictionary *mealDict in [dict valueForKey:@"Foods"]) {
                    NSNumber *incomingFoodID = [mealDict valueForKey:@"FoodID"];
                    NSNumber *incomingMealCode = [mealDict valueForKey:@"MealCode"];
                    
                    for (NSDictionary *existingItemsDict in existingLogItems) {
                        NSNumber *tempFoodID = [existingItemsDict valueForKey:@"FoodID"];
                        NSNumber *tempMealCode =[existingItemsDict valueForKey:@"MealCode"];
                        if ([tempFoodID intValue] == [incomingFoodID intValue] && [tempMealCode intValue] == [incomingMealCode intValue]) {
                            [existingLogItems removeObject:existingItemsDict];
                            break;
                        }
                    }
                    
                    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSString *lastUpdate = [self.dateFormatter stringFromDate:[NSDate date]];
                    NSString *queryString = [NSString stringWithFormat:@"REPLACE INTO Food_Log_Items "
                    "(MealID, FoodID, MealCode, MeasureID, NumberOfServings, LastModified) VALUES "
                    "(%i, %i, %i, %i, %f, '%@') ",
                                             [[mealDict valueForKey:@"MealID"] intValue],
                                             [[mealDict valueForKey:@"FoodID"] intValue],
                                             [[mealDict valueForKey:@"MealCode"] intValue],
                                             [[mealDict valueForKey:@"MeasureID"] intValue],
                                             [[mealDict valueForKey:@"NumberOfServings"] floatValue],
                                             lastUpdate
                                             ];
                    [db executeUpdate:queryString];
                    
                    for (NSDictionary *dict in [mealDict valueForKey:@"FoodDetails"]) {
                        
                        DMFood *food = [[DMFood alloc] initWithDictionary:dict];
                        NSString *replaceIntoSQL = [food replaceIntoSQLString];
                        [db executeUpdate:replaceIntoSQL];
                        
                        NSString *insertFMSQL = [NSString stringWithFormat: @"REPLACE INTO FoodMeasure (FoodID, MeasureID, GramWeight) VALUES (%i, %i, %i)",
                                                 food.foodKey.intValue,
                                                 food.measureId.intValue,
                                                 food.gramWeight.intValue];
                        [db executeUpdate:insertFMSQL];
                    }
                }
            }
            
            if ([db hadError]) {
                DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
            [db commit];
        }
    }
}

@end
