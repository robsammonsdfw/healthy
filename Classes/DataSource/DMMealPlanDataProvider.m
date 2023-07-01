//
//  DMMealPlanDataProvider.m
//  DietMasterGo
//
//  Created by Henry Kirk on 6/26/2023.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import "DMMealPlanDataProvider.h"
#import "DietmasterEngine.h"
#import "DMMyLogDataProvider.h"

@interface DMMealPlanDataProvider()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation DMMealPlanDataProvider

- (instancetype)init {
    self = [super init];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return self;
}

- (FMDatabase *)database {
    return [DMDatabaseUtilities database];
}

#pragma mark - Meal Fetched

- (void)updateUserPlannedMealItems:(NSArray *)mealItems withCompletionBlock:(completionBlockWithError)completionBlock {
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
    
    if (!mealItems) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                NSError *error = [DMGUtilities errorWithMessage:@"No items to update." code:150];
                completionBlock(NO, error);
            }
        });
    }
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"UpdateUserPlannedMealItems", @"RequestType",
                              nil];
    [DMDataFetcher fetchDataWithRequestParams:params
                                   jsonObject:mealItems
                                   completion:^(NSObject *object, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(error == nil, error);
            }
        });
    }];
}

- (void)saveUserPlannedMealItems:(NSArray *)mealItems withCompletionBlock:(completionBlockWithError)completionBlock {
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
    
    if (!mealItems) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                NSError *error = [DMGUtilities errorWithMessage:@"No items to save." code:150];
                completionBlock(NO, error);
            }
        });
    }
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"InsertUserPlannedMealItems", @"RequestType",
                              nil];
    [DMDataFetcher fetchDataWithRequestParams:params
                                   jsonObject:mealItems
                                   completion:^(NSObject *object, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(error == nil, error);
            }
        });
    }];
}

- (void)deleteUserPlannedMealItems:(NSArray *)mealItems withCompletionBlock:(completionBlockWithError)completionBlock {
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
    
    if (!mealItems) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                NSError *error = [DMGUtilities errorWithMessage:@"No items to delete." code:150];
                completionBlock(NO, error);
            }
        });
    }
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"DeleteUserPlannedMealItems", @"RequestType",
                              nil];
    [DMDataFetcher fetchDataWithRequestParams:params jsonObject:mealItems completion:^(NSObject *object, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(error == nil, error);
            }
        });
    }];
}

- (void)exchangeUserPlannedMealItem:(nonnull NSDictionary *)mealItem
                           withItem:(nonnull NSDictionary *)newMealItem
                withCompletionBlock:(nonnull completionBlockWithError)completionBlock {
    dispatch_group_t fetchGroup = dispatch_group_create();
    __block NSError *fetchError = nil;
    
    dispatch_group_enter(fetchGroup);
    [self saveUserPlannedMealItems:@[newMealItem] withCompletionBlock:^(BOOL completed, NSError *error) {
        fetchError = error;
        dispatch_group_leave(fetchGroup);
    }];
    
    dispatch_group_enter(fetchGroup);
    [self deleteUserPlannedMealItems:@[mealItem] withCompletionBlock:^(BOOL completed, NSError *error) {
        fetchError = error;
        dispatch_group_leave(fetchGroup);
    }];
    
    dispatch_group_notify(fetchGroup, dispatch_get_main_queue(),^{
        if (completionBlock) {
            completionBlock(fetchError == nil, fetchError);
        }
    });
}

- (void)fetchUserPlannedMealsWithCompletionBlock:(completionBlockWithObject)completionBlock {
    DMAuthManager *authManager = [DMAuthManager sharedInstance];
    if (![authManager isUserLoggedIn]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                NSError *error = [DMGUtilities errorWithMessage:@"User not logged in." code:100];
                completionBlock(nil, error);
            }
        });
        return;
    }

    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"GetUserPlannedMealNames", @"RequestType",
                              nil];
    [DMDataFetcher fetchDataWithRequestParams:params completion:^(NSObject *object, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(nil, error);
                }
            });
            return;
        }
        
        // The data is not formatted well, so we need to reformat it to be in an order we can work with.
        // Existing structure is an array of dictionaries not sorted by meal code.
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        NSMutableArray *results = [NSMutableArray array];
        NSArray *responseArray = (NSArray *)object;
        for (NSDictionary *mealDict in responseArray) {
            
            NSMutableDictionary *newMealPlanDict = [NSMutableDictionary dictionary];
            newMealPlanDict[@"MealName"] = [mealDict valueForKey:@"MealName"];
            newMealPlanDict[@"MealID"] = [mealDict valueForKey:@"MealID"];
            newMealPlanDict[@"MealTypeID"] = [mealDict valueForKey:@"MealTypeID"];
            
            // Add meal items.
            NSMutableArray *newMealItemsArray = [[NSMutableArray alloc] init];
            for (int i = 0; i <=5; i++) {
                NSMutableArray *mealItemsTemp = [[NSMutableArray alloc] init];
                for (NSDictionary *mealItems in mealDict[@"MealItems"]) {
                    int mealCode = [[mealItems valueForKey:@"MealCode"] intValue];
                    if (mealCode == i) {
                        [mealItemsTemp addObject:mealItems];
                    }
                }
                // Get missing foods, if needed.
                DMMyLogDataProvider *provider = [[DMMyLogDataProvider alloc] init];
                [provider getMissingFoodsIfNeededForFoods:[mealItemsTemp copy]];
                [newMealItemsArray addObject:mealItemsTemp];
            }
            newMealPlanDict[@"MealItems"] = newMealItemsArray;
            
            // Add Meal Notes.
            if ([[mealDict valueForKey:@"MealNotes"] count] != 0) {
                NSMutableArray *newMealNotesArray = [[NSMutableArray alloc] init];
                for (NSDictionary *mealNotes in [mealDict valueForKey:@"MealNotes"]) {
                    [newMealNotesArray addObject:mealNotes];
                }
                newMealPlanDict[@"MealNotes"] = newMealNotesArray;
            }
            
            // Add converted object.
            [results addObject:newMealPlanDict];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock([results copy], nil);
            }
        });
    }];
}

#pragma mark - Meal Local

- (NSNumber *)getCaloriesForMealCodes:(NSArray *)array {
    FMDatabase* db = [self database];
    if (![db open]) {
        return @0;
    }
    
    double num_totalCalories = 0;
    
    for (NSDictionary *dict in array) {
        int num_measureID = [[NSString stringWithFormat:@"%@",[dict valueForKey:@"MeasureID"]] intValue];
        
        NSString *query = [NSString stringWithFormat: @"SELECT Food.ServingSize,Food.FoodID,Food.Name,Food.Calories,Food.Fat,Food.Carbohydrates,Food.Protein,Food.FoodKey,Food.UserID,Food.FoodPK, FoodMeasure.GramWeight, Measure.MeasureID, Measure.Description FROM Food INNER JOIN FoodMeasure ON FoodMeasure.FoodID = Food.FoodKey INNER JOIN Measure ON FoodMeasure.MeasureID = Measure.MeasureID WHERE FoodMeasure.MeasureID = %i AND Food.FoodKey = %i LIMIT 1", num_measureID, [[dict valueForKey:@"FoodID"] intValue]];
        
        FMResultSet *rs = [db executeQuery:query];
        double numberOfServings = [[dict valueForKey:@"NumberOfServings"] doubleValue];
        double totalCalories = 0;
        while ([rs next]) {
            totalCalories = numberOfServings * (([rs doubleForColumn:@"Calories"] * ([rs doubleForColumn:@"GramWeight"] / 100)) / [rs doubleForColumn:@"ServingSize"]);
        }
        
        [rs close];
        
        num_totalCalories = num_totalCalories + totalCalories;
    }
    
    return @(num_totalCalories);
}

- (BOOL)insertMealPlanToLog:(NSDictionary *)dict toDate:(NSDate *)date {
    FMDatabase* db = [self database];
    if (![db open]) {
        return NO;
    }
    
    int mealIDValue = 0;
   
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    self.dateFormatter.timeZone = [NSTimeZone systemTimeZone];
    NSString *date_Today = [self.dateFormatter stringFromDate:date];
    [self.dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]]; // Prevent adjustment to user's local time zone.
    
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
    
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *date_string = [self.dateFormatter stringFromDate:[NSDate date]];
    
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

#pragma mark - Grocery Fetched

- (void)fetchGroceryListForMealItems:(nonnull NSArray *)mealItems withCompletionBlock:(nonnull completionBlockWithObject)completionBlock {
    DMAuthManager *authManager = [DMAuthManager sharedInstance];
    if (![authManager isUserLoggedIn]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                NSError *error = [DMGUtilities errorWithMessage:@"User not logged in." code:100];
                completionBlock(nil, error);
            }
        });
        return;
    }
    
    if (!mealItems) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                NSError *error = [DMGUtilities errorWithMessage:@"No items selected." code:150];
                completionBlock(nil, error);
            }
        });
    }
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"GetGroceryList", @"RequestType",
                              nil];
    [DMDataFetcher fetchDataWithRequestParams:params
                                   jsonObject:mealItems
                                   completion:^(NSObject *object, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(object, error);
            }
        });
    }];
}

#pragma mark - Grocery Local

- (NSArray *)getGroceryFoodDetailsForFoods:(NSArray *)foods {
    FMDatabase* db = [self database];
    if (![db open]) {
        return @[];
    }
    
    NSMutableArray *results = [NSMutableArray array];
    for (NSDictionary *food in foods) {
        NSMutableDictionary *foodMutable = [food mutableCopy];
        NSString *query = [NSString stringWithFormat: @"SELECT FoodKey, name, FoodURL, RecipeID, CategoryID FROM Food WHERE name = '%@' ORDER BY FoodURL DESC LIMIT 1", [food valueForKey:@"FoodName"]];
        FMResultSet *rs = [db executeQuery:query];
        while ([rs next]) {
            NSString *FoodURL = [rs stringForColumn:@"FoodURL"];
            if (FoodURL != nil && ![FoodURL isEqualToString:@""]) {
                [foodMutable setObject:FoodURL forKey:@"FoodURL"];
            }
            int recipeID = [rs intForColumn:@"RecipeID"];
            if (recipeID > 0) {
                [foodMutable setObject:@(recipeID) forKey:@"RecipeID"];
            }
            int catID = [rs intForColumn:@"CategoryID"];
            if (catID > 0) {
                [foodMutable setObject:@(catID) forKey:@"CategoryID"];
            }
            [results addObject:[foodMutable copy]];
        }
        [rs close];
    }
    
    return [results copy];
}

static NSString *DMSavedGroceryListKey = @"DMSavedGroceryList";

/// Gets a saved grocery list from NSUserDefaults.
- (NSArray<NSDictionary *> *)getSavedGroceryList {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *objects = [defaults objectForKey:DMSavedGroceryListKey];
    return [objects copy];
}

/// Saves a grocery list to NSUserDefaults.
- (void)saveGroceryList:(NSArray<NSDictionary *> *)groceryList {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:groceryList forKey:DMSavedGroceryListKey];
    [defaults synchronize];
}

@end
