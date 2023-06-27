//
//  DMDatabaseProvider.m
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/25/23.
//

#import "DMDatabaseProvider.h"
#import "FMDatabase.h"
#import "DMDataFetcher.h"

@interface DMDatabaseProvider()
@property (nonatomic, strong) NSDateFormatter *dateformatter;
@property (nonatomic, strong) dispatch_queue_t syncQueue;
@property (nonatomic, strong, readonly) FMDatabase *database;
@property (nonatomic, strong) NSMutableArray *arrExerciseSyncNew;
@property (nonatomic) NSInteger pageNumber;
@end

@implementation DMDatabaseProvider

- (instancetype)init {
    self = [super init];
    if (self) {
        _syncQueue = dispatch_queue_create("com.dietmaster.syncQueue", DISPATCH_QUEUE_SERIAL);
        _dateformatter = [[NSDateFormatter alloc] init];
        _pageNumber = 1;
        _arrExerciseSyncNew = [NSMutableArray array];
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
    __weak typeof(self) weakSelf = self;
    __block NSError *syncError = nil;

    // First fetch all the user plan data.
    dispatch_group_enter(fetchGroup);
    dispatch_async(self.syncQueue, ^{
        MyMovesDataProvider *provider = [[MyMovesDataProvider alloc] init];
        [provider fetchAllUserPlanDataWithCompletionBlock:^(BOOL completed, NSError *error) {
            dispatch_group_leave(fetchGroup);
            if (error) {
                syncError = error;
            }
        }];
    });

    // Next, fetch MyMoves data.
    dispatch_group_enter(fetchGroup);
    dispatch_async(self.syncQueue, ^{
        MyMovesDataProvider *provider = [[MyMovesDataProvider alloc] init];
        [provider getMyMovesDataWithCompletionBlock:^(BOOL completed, NSError *error) {
            dispatch_group_leave(fetchGroup);
            if (error) {
                syncError = error;
            }
        }];
    });

    dispatch_group_enter(fetchGroup);
    dispatch_async(self.syncQueue, ^{
        DMAuthManager *authMangager = [DMAuthManager sharedInstance];
        [authMangager updateUserInfoWithCompletion:^(NSObject *object, NSError *error) {
            dispatch_group_leave(fetchGroup);
            if (error) {
                syncError = error;
            }
        }];
    });

    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:-90];
        
    NSString *dateString;
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"FirstTime"] isEqualToString:@"FirstTime"]) {
        dateString = @"1970-01-01";
        [[NSUserDefaults standardUserDefaults]setObject:@"SecondTime" forKey:@"FirstTime"];
    } else {
        NSDate *currentDate = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastsyncdate"];
        if (!currentDate) {
            currentDate = [NSDate date];
        }
        NSDate *oneDayAgo = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay
                                                                     value:-8
                                                                    toDate:currentDate
                                                                   options:0];
        
        self.dateformatter.timeZone = [NSTimeZone systemTimeZone];
        [self.dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        dateString = [self.dateformatter stringFromDate:oneDayAgo];
    }
    [self.arrExerciseSyncNew removeAllObjects];

    dispatch_group_enter(fetchGroup);
    dispatch_async(self.syncQueue, ^{
        [weakSelf getDataSinceLastSyncDate:dateString withCompletionBlock:^(BOOL completed, NSError *error) {
            dispatch_group_leave(fetchGroup);
            if (error) {
                syncError = error;
            }
        }];
    });

    dispatch_group_enter(fetchGroup);
    dispatch_async(self.syncQueue, ^{
        [weakSelf syncFavoriteFoods:dateString withCompletionBlock:^(BOOL completed, NSError *error) {
            dispatch_group_leave(fetchGroup);
            if (error) {
                syncError = error;
            }
        }];
    });

    dispatch_group_enter(fetchGroup);
    dispatch_async(self.syncQueue, ^{
        [weakSelf syncFavoriteMealsWithCompletionBlock:^(BOOL completed, NSError *error) {
            dispatch_group_leave(fetchGroup);
            if (error) {
                syncError = error;
            }
        }];
    });

    dispatch_group_enter(fetchGroup);
    dispatch_async(self.syncQueue, ^{
        [weakSelf syncFavoriteMealItemsWithCompletionBlock:^(BOOL completed, NSError *error) {
            dispatch_group_leave(fetchGroup);
            if (error) {
                syncError = error;
            }
        }];
    });

//    dispatch_group_enter(fetchGroup);
//    dispatch_async(self.syncQueue, ^{
//        [weakSelf syncExerciseLogNew:dateString withCompletionBlock:^(BOOL completed, NSError *error) {
//            dispatch_group_leave(fetchGroup);
//            if (error) {
//                syncError = error;
//            }
//        }];;
//    });
    
    // Finished!!
    dispatch_group_notify(fetchGroup, dispatch_get_main_queue(),^{
        [self syncDatabaseFinished];
        if (completionBlock) {
            completionBlock(syncError != nil, syncError);
        }
    });
}

- (void)syncDatabaseFinished {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDate *oneDayAgo = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay
                                                                 value:0
                                                                toDate:[NSDate date]
                                                               options:0];
    
    self.dateformatter.timeZone = [NSTimeZone systemTimeZone];
    [self.dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [self.dateformatter stringFromDate:oneDayAgo];
    NSDate *date1 = [self.dateformatter dateFromString:dateString];
    [prefs setValue:date1 forKey:@"lastsyncdate"];
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
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if([[prefs valueForKey:@"FirstTime"] isEqualToString:@"FirstTime"]) {
        dateString = [NSString stringWithFormat:@"%@",[prefs valueForKey:@"lastsyncdate"]];
    }
    else {
        dateString = @"01-01-1970";
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
            [weakSelf.dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
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
        dispatch_async(self.syncQueue, ^{
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
        });
    }
    [rs close];
    
    dispatch_group_notify(fetchGroup, dispatch_get_main_queue(),^{
        if (completionBlock) {
            completionBlock(YES, nil);
        }
    });
}

- (void)syncExerciseLogNew:(NSString *)dateString withCompletionBlock:(completionBlockWithError)completionBlock {
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

    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"FirstTime"] isEqualToString:@"FirstTime"]) {
        dateString = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"lastsyncdate"]];
    } else {
        dateString = @"01-01-1970";
    }
    
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"SyncExerciseLogNew", @"RequestType",
                              dateString, @"LastSync",
                              [NSString stringWithFormat:@"%d",20],@"PageSize",
                              [NSString stringWithFormat:@"%li",self.pageNumber], @"PageNumber",
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
        NSMutableArray *arrTemp = [[NSMutableArray alloc] init];
        int totalCount = 0;
        
        FMDatabase* db = [self database];
        if (![db open]) {
        }
        
        [db beginTransaction];
        if ([responseArray count]>0){
            NSDictionary *dictTemp = [[NSDictionary alloc] initWithDictionary:[responseArray objectAtIndex:0]];
            arrTemp = [dictTemp valueForKey:@"ExerciseLogs"];
            
            totalCount = [[dictTemp valueForKey:@"TotalCount"] intValue];
            
            for (int i=0; i < [arrTemp count]; i++) {
                NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[arrTemp objectAtIndex:i]];
                
                [strongSelf.dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSLocale *en_US = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                [strongSelf.dateformatter setLocale:en_US];
                NSDate *logTimeDate = [strongSelf.dateformatter dateFromString:[dict valueForKey:@"ExerciseDate"]];
                
                [strongSelf.dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *logTimeString = [strongSelf.dateformatter stringFromDate:logTimeDate];
                
                [strongSelf.dateformatter setDateFormat:@"yyyyMMdd"];
                NSString *keyDate = [strongSelf.dateformatter stringFromDate:logTimeDate];
                
                int exerciseID = [[dict valueForKey:@"ExerciseID"] intValue];
                NSString *exerciseLogStrID = [NSString stringWithFormat:@"%@-%i", keyDate, exerciseID];
                
                NSDate* sourceDate = [NSDate date];
                [strongSelf.dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                
                NSString *queryString = [NSString stringWithFormat:@"REPLACE INTO Exercise_Log "
                                         "(Exercise_Log_StrID, ExerciseID, Exercise_Time_Minutes, Log_Date, Date_Modified) VALUES "
                                         "('%@', %i, %i, '%@', '%@') ",
                                         exerciseLogStrID,
                                         exerciseID,
                                         [[dict valueForKey:@"Duration"] intValue],
                                         logTimeString,
                                         sourceDate
                                         ];
            
                [db executeUpdate:queryString];
                [strongSelf.arrExerciseSyncNew addObject:dict];
            }
            if ([db hadError]) {
                DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
            [db commit];
            
            if (strongSelf.arrExerciseSyncNew.count < totalCount) {
                NSString *dateString;
                if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"FirstTime"] isEqualToString:@"FirstTime"]) {
                    dateString = @"1970-01-01";
                    [[NSUserDefaults standardUserDefaults]setObject:@"SecondTime" forKey:@"FirstTime"];
                } else {
                    dateString = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"lastsyncdate"]];
                }
                strongSelf.pageNumber = strongSelf.pageNumber + 1;
                [strongSelf syncExerciseLogNew:dateString withCompletionBlock:completionBlock];
            }
            else {
                strongSelf.pageNumber = 1;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completionBlock) {
                        completionBlock(YES, nil);
                    }
                });
            }
        }
    }];
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
        syncDate = @"";
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
        [strongSelf getDataFinished:responseDict];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(YES, nil);
            }
        });
    }];
}

/// Processes the data from the DMDataFetcher.
- (void)getDataFinished:(NSDictionary *)responseDict {
    if (!responseDict) {
        return;
    }
    
    FMDatabase* db = [self database];
    if (![db open]) {
        DM_LOG(@"Could not open db.");
        return;
    }
    
    NSDictionary *dict = [responseDict copy];
    
    // Get the model.
    NSArray *userArray = [dict valueForKey:@"User"];
    NSDictionary *userDict = dict[@"User"][0];
    
    // Update User Info
    if (userDict) {
        DMUser *user = [[DMUser alloc] initWithDictionary:userDict];
        
        // Log values to Firebase.
        [[FIRCrashlytics crashlytics] log:@"GetUserData completed."];
        for (id key in userDict) {
            [[FIRCrashlytics crashlytics] setCustomValue:[userDict valueForKey:key] forKey:key];
        }
        
        [db beginTransaction];
        NSString *updateSQL = [NSString stringWithFormat: @"UPDATE user SET "
                               
                               "weight_goal = %i, "
                               "Height = %i, "
                               "Goals = %i, "
                               "BirthDate = '%@', "
                               "Profession = %i, "
                               "BodyType = %i, "
                               "GoalStartDate = '%@', "
                               "ProteinRequirements = %i, "
                               "gender = %i, "
                               "lactating = %i, "
                               "goalrate = %i, "
                               "BMR = %i, "
                               "CarbRatio = %i, "
                               "ProteinRatio = %i, "
                               "FatRatio = %i, "
                               "HostName = '%@'"
                               
                               "WHERE id = 1",
                               
                               user.weightGoal.intValue,
                               user.height.intValue,
                               user.goals.intValue,
                               [user birthDateString],
                               user.profession.intValue,
                               user.bodyType.intValue,
                               [user goalStartDateString],
                               user.proteinRequirements.intValue,
                               user.gender.intValue,
                               user.lactating.intValue,
                               user.goalRate.intValue,
                               user.userBMR.intValue,
                               user.carbRatio.intValue,
                               user.proteinRatio.intValue,
                               user.fatRatio.intValue,
                               user.hostName];
        
        [db executeUpdate:updateSQL];
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setValue:user.hostName forKey:@"HostName"];
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
                
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                [self.dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *lastUpdate = [self.dateformatter stringFromDate:[[prefs valueForKey:@"lastsyncdate"] dateByAddingTimeInterval:-30]];
                
                if (lastUpdate == nil) {
                    [self.dateformatter setTimeZone:[NSTimeZone systemTimeZone]];
                    lastUpdate = [self.dateformatter stringFromDate:[NSDate date]];
                }

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
                    NSDate *date1 = [self.dateformatter dateFromString:lastUpdate];
                    NSDate *date2 = [self.dateformatter dateFromString:[[itemToDelete valueForKey:@"LastModified"] stringValue]];

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

@end
