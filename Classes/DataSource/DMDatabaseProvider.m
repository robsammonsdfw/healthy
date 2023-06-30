//
//  DMDatabaseProvider.m
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/25/23.
//

#import "DMDatabaseProvider.h"
#import "FMDatabase.h"
#import "DMDataFetcher.h"
#import "DMFood.h"

@interface DMDatabaseProvider()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong, readonly) FMDatabase *database;
@end

@implementation DMDatabaseProvider

- (instancetype)init {
    self = [super init];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return self;
}

- (FMDatabase *)database {
    DietmasterEngine *engine = [DietmasterEngine sharedInstance];
    return [FMDatabase databaseWithPath:[engine databasePath]];
}

#pragma mark - Sync Everything

- (void)syncDatabaseWithCompletionBlock:(completionBlockWithError)completionBlock {
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

    dispatch_group_enter(fetchGroup);
    [self getDataSinceLastSyncDate:dateString withCompletionBlock:^(BOOL completed, NSError *error) {
        dispatch_group_leave(fetchGroup);
        if (error) {
            syncError = error;
        }
    }];

    dispatch_group_enter(fetchGroup);
    [self syncFavoriteFoods:dateString withCompletionBlock:^(BOOL completed, NSError *error) {
        dispatch_group_leave(fetchGroup);
        if (error) {
            syncError = error;
        }
    }];

    dispatch_group_enter(fetchGroup);
    [self syncFavoriteMealsWithCompletionBlock:^(BOOL completed, NSError *error) {
        dispatch_group_leave(fetchGroup);
        if (error) {
            syncError = error;
        }
    }];

    dispatch_group_enter(fetchGroup);
    [self syncFavoriteMealItemsWithCompletionBlock:^(BOOL completed, NSError *error) {
        dispatch_group_leave(fetchGroup);
        if (error) {
            syncError = error;
        }
    }];

    dispatch_group_enter(fetchGroup);
    [self syncExerciseLog:dateString pageNumber:1 fetchedItems:@[] withCompletionBlock:^(BOOL completed, NSError *error) {
        dispatch_group_leave(fetchGroup);
        if (error) {
            syncError = error;
        }
    }];;

    dispatch_group_notify(fetchGroup, dispatch_get_main_queue(),^{
        // Finished!!
        [self syncDatabaseFinished];
        if (completionBlock) {
            completionBlock(syncError != nil, syncError);
        }
    });
}

- (void)syncDatabaseFinished {
    [DMGUtilities setLastSyncToDate:[NSDate date]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:nil];
}

#pragma mark - Individual Syncs

- (void)syncFavoriteFoods:(NSString *)dateString withCompletionBlock:(completionBlockWithError)completionBlock {
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
    
    __weak typeof(self) weakSelf = self;
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
        for (int i=0; i < [responseArray count]; i++) {
            
            NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[responseArray objectAtIndex:i]];
            
            NSDate* sourceDate = [NSDate date];
            [weakSelf.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
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
        for (int i=0; i < [responseArray count]; i++) {
            NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[responseArray objectAtIndex:i]];
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

    FMDatabase* db = [self database];
    if (![db open]) {
    }

    NSString *query = [NSString stringWithFormat:@"SELECT Favorite_MealID, modified FROM Favorite_Meal WHERE Favorite_MealID > %@", @"0"];
    FMResultSet *rs = [db executeQuery:query];
    
    dispatch_group_t fetchGroup = dispatch_group_create();
    while ([rs next]) {
        // MealID is equal to Favorite_MealID in database.
        NSString *mealId = [rs stringForColumn:@"Favorite_MealID"];
        __block NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                          @"GetFavoriteMealItems", @"RequestType",
                                          [rs stringForColumn:@"Favorite_MealID"], @"MealID", nil];
        dispatch_group_enter(fetchGroup);
        [DMDataFetcher fetchDataWithRequestParams:infoDict completion:^(NSObject *object, NSError *error) {
            dispatch_group_leave(fetchGroup);
            if (error) {
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

        }];
    }
    [rs close];
    
    dispatch_group_notify(fetchGroup, dispatch_get_main_queue(),^{
        if (completionBlock) {
            completionBlock(YES, nil);
        }
    });
}

- (void)syncExerciseLog:(NSString *)dateString
             pageNumber:(NSInteger)pageNumber
           fetchedItems:(NSArray *)fetchedItems
    withCompletionBlock:(completionBlockWithError)completionBlock {
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
    dateString = @"1980-01-01";
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
        
    __weak typeof(self) weakSelf = self;
    [DMDataFetcher fetchDataWithRequestParams:infoDict completion:^(NSObject *object, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
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
            [strongSelf syncExerciseLog:dateString
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
        
    __weak typeof(self) weakSelf = self;
    [DMDataFetcher fetchDataWithRequestParams:infoDict completion:^(NSObject *object, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
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
            [strongSelf syncFoods:dateString
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

- (void)fetchFoodForKey:(NSNumber *)foodKey {
    if (!foodKey) {
        return;
    }
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"GetFoodNew", @"RequestType",
                              foodKey, @"FoodKey",
                              nil];
    
    [DMDataFetcher fetchDataWithRequestParams:infoDict completion:^(NSObject *object, NSError *error) {
         [self saveFoods:(NSArray *)object];
     }];
}

- (void)getMissingFoodsIfNeededForFoods:(NSArray *)foodsArray {
    FMDatabase* db = [self database];
    if (![db open]) {
    }
    
    NSMutableArray *missingFoods = [NSMutableArray array];
    for (NSDictionary *foodDict in foodsArray) {
        int selectedFoodID = [[foodDict valueForKey:@"FoodID"] intValue];
        int measureID = [[foodDict valueForKey:@"MeasureID"] intValue];
        NSString *query = [NSString stringWithFormat: @"SELECT COUNT (Food.FoodID) as FoodCount FROM Food INNER JOIN FoodMeasure ON FoodMeasure.FoodID = Food.FoodKey INNER JOIN Measure ON FoodMeasure.MeasureID = Measure.MeasureID WHERE Food.FoodKey = %i AND Measure.MeasureID = %i LIMIT 1", selectedFoodID, measureID];
        
        FMResultSet *rs = [db executeQuery:query];
        NSNumber  *resultCount = @0;
        while ([rs next]) {
            resultCount = @([rs intForColumn:@"FoodCount"]);
        }
        [rs close];
        
        if (resultCount.intValue == 0) {
            [missingFoods addObject:foodDict];
        }
    }
    
    for (NSDictionary *dict in missingFoods) {
        [self fetchFoodForKey:[dict valueForKey:@"FoodID"]];
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

#pragma mark - MESSAGES

- (void)syncMessagesWithCompletionBlock:(completionBlockWithError)completionBlock {
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

    UserDataFetcher *fetcher = [[UserDataFetcher alloc] init];
    [fetcher getMessagesWithCompletion:^(NSArray<DMMessage *> *messages, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(NO, error);
                }
            });
            return;
        }
        [self processIncomingMessages:messages];
        [[NSNotificationCenter defaultCenter] postNotificationName:UpdatingMessageNotification object:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(YES, nil);
            }
        });
    }];
}

- (void)processIncomingMessages:(NSArray<DMMessage *> *)messages {
    if (!messages.count) {
        return;
    }
    FMDatabase* dataBase = [self database];
    if (![dataBase open]) {
    }
    
    [dataBase beginTransaction];
    for (DMMessage *message in messages) {
        NSString *sqlQuery = [message replaceIntoSQLString];
        [dataBase executeUpdate:sqlQuery];
        if ([dataBase hadError]) {
            DM_LOG(@"Err %d: %@", [dataBase lastErrorCode], [dataBase lastErrorMessage]);
        }
    }
    [dataBase commit];
}

- (NSArray<DMMessage *> *)unreadMessages {
    FMDatabase* dataBase = [self database];
    if (![dataBase open]) {
    }
    // Sender = 0 means it was sent by an advisor or coach. Sender will be >0
    // if it was sent by the current user.
    NSString *query = @"SELECT * FROM Messages WHERE Sender = 0 AND Read = 0";
    
    FMResultSet *rs = [dataBase executeQuery:query];
    NSMutableArray *result = [NSMutableArray array];
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        DMMessage *message = [[DMMessage alloc] initWithDictionary:dict];
        [result addObject:message];
    }
    [rs close];
    
    return [result copy];
}

- (int)unreadMessageCount {
    FMDatabase* dataBase = [self database];
    if (![dataBase open]) {
        return 0;
    }
    NSString *query = @"SELECT * FROM Messages WHERE Sender = 0 AND Read = 0";
    
    FMResultSet *rs = [dataBase executeQuery:query];
    int count = 0;
    while ([rs next]) {
        ++count;
    }
    [rs close];
    
    return count;
}

- (NSDictionary *)messageById:(NSString *)uid database:(FMDatabase *)database {
    NSString *query = [NSString stringWithFormat: @"SELECT * FROM Messages WHERE Id = '%@'", uid];
    
    NSDictionary * result = nil;
    
    FMResultSet *rs = [database executeQuery:query];
    
    if ([rs next])
    {
        result = [NSDictionary dictionaryWithObjectsAndKeys:
                  [rs stringForColumn:@"Id"],    @"MessageID",
                  [rs stringForColumn:@"Text"],   @"Text",
                  [rs stringForColumn:@"Sender"], @"Sender",
                  [rs dateForColumn:@"Date"],     @"DsteTime", nil];
    }
    
    [rs close];
    
    return result;
}

- (NSDictionary *)messageById:(NSString *)uid {
    FMDatabase* dataBase = [self database];
    NSDictionary *message = [self messageById:uid database:dataBase];
    return message;
}

- (NSNumber *)getLastMessageId {
    NSNumber *messageId = [self getMaxValueForColumn:@"MessageID" inTable:@"Messages"];
    return messageId;
}

- (void)setReadedMessageId:(NSNumber *)messageId {
    FMDatabase* dataBase = [self database];
    if (![dataBase open]) {
        return;
    }
    [dataBase beginTransaction];
    NSString *sqlQuery = [NSString stringWithFormat:@"UPDATE Messages SET Read = 1 "
                          "WHERE Id = %@", messageId];
    [dataBase executeUpdate:sqlQuery];
    if ([dataBase hadError]) {
        DMLog(@"Err %d: %@", [dataBase lastErrorCode], [dataBase lastErrorMessage]);
    }
    [dataBase commit];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = [self unreadMessageCount];
}

- (void)getDataSinceLastSyncDate:(NSString *)syncDate withCompletionBlock:(completionBlockWithError)completionBlock {
    if (!syncDate.length) {
        syncDate = @"01-01-1970";
    }
    DMUser *currentUser = [[DMAuthManager sharedInstance] loggedInUser];
    [[FIRCrashlytics crashlytics] logWithFormat:@"GetUserData-UserId: %@", currentUser.userId];
    
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"GetUserData", @"RequestType",
                                syncDate, @"LastSync",
                                nil];
    __weak typeof(self) weakSelf = self;
    [DMDataFetcher fetchDataWithRequestParams:infoDict completion:^(NSObject *object, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(NO, error);
                }
            });
            return;
        }
        
        NSDictionary *responseDict = (NSDictionary *)object;
        [strongSelf saveUserData:responseDict];
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
    
    NSDictionary *dict = [responseDict copy];
    
    NSDictionary *userDict = dict[@"User"][0];
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
                
                NSString *lastUpdate = [DMGUtilities lastSyncDateString];

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
                
                for (NSDictionary *mealDict in [dict valueForKey:@"Foods"])
                {
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
                
                for(NSDictionary *itemToDelete in existingLogItems) {
                    NSDate *date1 = [self.dateFormatter dateFromString:lastUpdate];
                    NSDate *date2 = [self.dateFormatter dateFromString:[[itemToDelete valueForKey:@"LastModified"] stringValue]];

                    // if lastUpdate is more recent than LastModified, this item has been deleted
                    NSTimeInterval timeInterval = [date2 timeIntervalSinceDate:date1];
                    //if negative, food was added before sync
                    //if more than 15min before, the food was deleted on the web so it should be deleted in the app
                    if (timeInterval < -900) {
                        //dates are more than an hour apart with date2 being in the future
                        NSString *deleteFoodLogItem = [NSString stringWithFormat:@"DELETE FROM Food_Log_Items WHERE FoodID = %i AND MealCode = %i AND MealID = %i", [[itemToDelete valueForKey:@"FoodID"] intValue], [[itemToDelete valueForKey:@"MealCode"] intValue], [[dict valueForKey:@"MealID"] intValue]];
                        
                        [db executeUpdate:deleteFoodLogItem];
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

- (NSNumber *)getMaxValueForColumn:(NSString *)columnName inTable:(NSString *)tableName {
    if (!columnName.length || !tableName.length) {
        return nil;
    }
    FMDatabase* db = [self database];
    if (![db open]) {
        return  nil;
    }
    [db beginTransaction];
    
    NSString *sqlString = [NSString stringWithFormat:@"SELECT MAX(%@) as MaxValue FROM %@", columnName, tableName];
    FMResultSet *rs = [db executeQuery:sqlString];

    NSNumber *maxValue = nil;
    while ([rs next]) {
        NSDictionary *resultDict = [rs resultDictionary];
        maxValue = resultDict[@"MaxValue"];
    }
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        return nil;
    }
    [db commit];
    
    return maxValue;
}

#pragma mark - Meals

- (void)saveFavoriteMeal:(NSDictionary *)mealDict withName:(NSString *)mealName {
    [DMActivityIndicator showActivityIndicator];

    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
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

    for (NSDictionary *dict in mealDict[@"Foods"]) {
        
        [db beginTransaction];
        
        NSDate* sourceDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
        [dateFormatter setTimeZone:systemTimeZone];
        NSString *date_string = [dateFormatter stringFromDate:sourceDate];
        
        NSString *insertSQLItems = [NSString stringWithFormat: @"REPLACE INTO Favorite_Meal_Items (FoodKey, Favorite_Meal_ID, FoodID, MeasureID, Servings, Last_Modified) VALUES (%i, %i, %i, %i, %f, DATETIME('%@'))", [[dict valueForKey:@"FoodKey"] intValue], favoriteMealID, [[dict valueForKey:@"FoodID"] intValue], [[dict valueForKey:@"MeasureID"] intValue], [[dict valueForKey:@"Servings"] floatValue], date_string];
        
        [db executeUpdate:insertSQLItems];
        
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        
        [db commit];
    }
    
    [DMActivityIndicator hideActivityIndicator];
    [DMActivityIndicator showCompletedIndicator];
}

@end
