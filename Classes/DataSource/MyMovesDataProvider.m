//
//  MyMovesDataProvider.m
//
//  Created by Henry T. Kirk on 6/26/2023.
//

#import "MyMovesDataProvider.h"
#import "FMDatabase.h"
#import "DMMove.h"
#import "DMMoveTag.h"
#import "DMMoveCategory.h"
#import "DMMovePickerRow.h"
#import "DMMovePlan.h"
#import "DMMyLogDataProvider.h"
#import "DMDataFetcher.h"
#import "DMMovePickerRow.h"

@interface MyMovesDataProvider()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation MyMovesDataProvider

- (instancetype)init {
    self = [super init];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return self;
}

#pragma mark - Fetch

- (void)fetchAllUserPlanDataWithCompletionBlock:(completionBlockWithError)completionBlock {
    DMUser *currentUser = [[DMAuthManager sharedInstance] loggedInUser];
    if (!currentUser) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = [DMGUtilities errorWithMessage:@"Error: User not logged in." code:943];
            if (completionBlock) {
                completionBlock(NO, error);
            }
        });
        return;
    }
    NSString *authHash = currentUser.authToken;
    
    // TODO: Uncomment when server can receive data.
//        NSArray *userPlanListUpdates = [self getUserPlanListUpdates];
//        NSArray *userPlanDateListUpdates = [self getUserPlanDateListUpdates];
//        NSArray *userPlanMoveListUpdates = [self getUserPlanMoveListUpdates];
//        NSArray *userPlanMoveSetListUpdates = [self getUserPlanMoveSetListUpdates];
          
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 authHash, @"AuthHash",
                                 @(YES), @"SendAllServerData",
                                 // TODO: Hook up server at a later date. It isn't working properly (HTK).
                                 //userPlanListUpdates, @"MobileUserPlanList",
                                 //userPlanDateListUpdates, @"MobileUserPlanDateList",
                                 //userPlanMoveListUpdates, @"MobileUserPlanMoveList",
                                 //userPlanMoveSetListUpdates, @"MobileUserPlanMoveSetList",
                                 nil];
    NSURL *url = [NSURL URLWithString:@"https://dmwebpro.com/MobileAPI/SyncUser"];
    [DMDataFetcher fetchDataWithJSONParams:params url:url method:@"POST" completion:^(NSObject *object, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(NO, error);
                }
            });
            return;
        }
        
        // Process the fetch from the server.
        NSDictionary *results = (NSDictionary *)object;
        [self saveUserPlanListData:results];

        // TODO: Uncomment this once the server accepts updates being sent.
        // [strongSelf removeRowsWithDeletedStatus];
        // [strongSelf updateDBStatusFrom:@"New" toStatus:@"Normal"];
        // [strongSelf updateDBStatusFrom:@"Changed" toStatus:@"Normal"];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(YES, nil);
            }
        });
    }];
}

- (void)getMyMovesDataWithCompletionBlock:(completionBlockWithError)completionBlock {
    DMAuthManager *authManager = [DMAuthManager sharedInstance];
    DMUser *currentUser = [authManager loggedInUser];
   
    // Change FALSE to TRUE to include all moves.
    NSString *urlString = [NSString stringWithFormat:@"https://api.dmwebpro.com/MyMoves/GetMoves/%i/true", currentUser.companyId.intValue];
    NSURL *url = [NSURL URLWithString:urlString];

    [DMDataFetcher fetchDataWithJSONParams:nil url:url method:@"GET" completion:^(NSObject *object, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(NO, error);
                }
            });
            return;
        }

        NSDictionary *responseDict = (NSDictionary *)object;
        [self saveMyMovesData:responseDict];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(YES, nil);
            }
        });
    }];
}

#pragma mark - Local Database

/// Gets all rows that were New, Deleted, or Updated.
- (NSArray<NSDictionary *> *)getUserPlanListUpdates {
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
        return @[];
    }
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM ServerUserPlanList WHERE Status != 'Normal'"];
    FMResultSet *rs = [db executeQuery:sql];
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        [arr addObject:dict];
    }
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        return @[];
    }
     
    return [arr copy];
}

/// Gets all rows that were New, Deleted, or Updated.
- (NSArray<NSDictionary *> *)getUserPlanDateListUpdates {
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
        return @[];
    }
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM ServerUserPlanDateList WHERE Status != 'Normal'"];
    FMResultSet *rs = [db executeQuery:sql];
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        [arr addObject:dict];
    }
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        return @[];
    }
        
    return [arr copy];
}

/// Gets all rows that were New, Deleted, or Updated.
- (NSArray<NSDictionary *> *)getUserPlanMoveListUpdates {
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
        return @[];
    }
     
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM ServerUserPlanMoveList WHERE Status != 'Normal'"];
    FMResultSet *result = [db executeQuery:sql];
    
    while ([result next]) {
        NSDictionary *dict = [result resultDictionary];
        [arr addObject:dict];
    }
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        return @[];
    }

    return [arr copy];
}

/// Gets all rows that were New, Deleted, or Updated.
- (NSArray<NSDictionary *> *)getUserPlanMoveSetListUpdates {
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
        return @[];
    }
        
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM ServerUserPlanMoveSetList WHERE Status != 'Normal'"];
    FMResultSet *rs = [db executeQuery:sql];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    while ([rs next]) {
         NSDictionary *dict = [rs resultDictionary];
        
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        NSDate *currentDate = [NSDate date];
        NSString *lastUpdated = [formatter stringFromDate:currentDate];

        [arr addObject:dict];
    }
     
     if ([db hadError]) {
         DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
         return @[];
     }
         
    return [arr copy];
}

- (void)clearTableData {
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
        return;
    }
    [db beginTransaction];
    
    NSString * deleteServerUserPlanList = [NSString stringWithFormat: @"DELETE FROM ServerUserPlanList"];
    [db executeUpdate:deleteServerUserPlanList];
    
    NSString * deleteServerUserPlanDateList = [NSString stringWithFormat: @"DELETE FROM ServerUserPlanDateList"];
    [db executeUpdate:deleteServerUserPlanDateList];
    
    NSString * deleteServerUserPlanMoveList = [NSString stringWithFormat: @"DELETE FROM ServerUserPlanMoveList"];
    [db executeUpdate:deleteServerUserPlanMoveList];
    
    NSString * deleteServerUserPlanMoveSetList = [NSString stringWithFormat: @"DELETE FROM ServerUserPlanMoveSetList"];
    [db executeUpdate:deleteServerUserPlanMoveSetList];
    
    NSString * deletePlanDateUniqueID_Table = [NSString stringWithFormat: @"DELETE FROM PlanDateUniqueID_Table"];
    [db executeUpdate:deletePlanDateUniqueID_Table];
    
    NSString * deletePlanDateTable = [NSString stringWithFormat: @"DELETE FROM PlanDateTable"];
    [db executeUpdate:deletePlanDateTable];
    
    NSString *deleteWeightlog = [NSString stringWithFormat:@"DELETE FROM weightlog"];
    [db executeUpdate:deleteWeightlog];
    
    NSString *deleteCompanyMoves = [NSString stringWithFormat:@"DELETE FROM MoveDetails WHERE companyID > 0"];
    [db executeUpdate:deleteCompanyMoves];

    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
}

/// Saves MyMoves data for the user. E.g. MoveTags, MoveCategories, etc.
- (void)saveMyMovesData:(NSDictionary *)responseDict {
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
        return;
    }

    [db beginTransaction];
    for (NSDictionary *dict in responseDict) {
        DMMove *move = [[DMMove alloc] initWithDictionary:dict];
        // Save the Move itself.
        NSString *moveReplaceIntoSQL = [move replaceIntoSQLString];
        [db executeUpdate:moveReplaceIntoSQL];
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        
        // Save Tags, then save the Tags to the Move.
        NSArray *tags = [dict objectForKey:@"moveTags"];
        for (NSDictionary *tagDict in tags) {
            DMMoveTag *tag = [[DMMoveTag alloc] initWithDictionary:tagDict];
            NSString *replaceIntoTagSQL = [tag replaceIntoSQLString];
            [db executeUpdate:replaceIntoTagSQL];
            if ([db hadError]) {
                DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
            
            // Now save the TagID into the MovesTags database to link them to the Move.
            NSString *replaceIntoSQL = [NSString stringWithFormat: @"REPLACE INTO MovesTags (tagID, moveID) VALUES(\"%d\",\"%d\")",
                                         move.moveId.intValue,
                                         tag.tagId.intValue];
            [db executeUpdate:replaceIntoSQL];
            if ([db hadError]) {
                DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
        }
        
        // Save the CategoryID into the MovesCategories table to link to the Move. NOTE: Category = Bodypart.
        // We don't need to save the Category itself, as it's hardcoded in "MoveCategories" table.
        NSArray *categories = [dict objectForKey:@"moveCategories"];
        for (NSDictionary *categoryDict in categories) {
            DMMoveCategory *category = [[DMMoveCategory alloc] initWithDictionary:categoryDict];
            NSString *replaceIntoSQL = [NSString stringWithFormat: @"REPLACE INTO MovesCategories (moveID, categoryID) VALUES(\"%d\",\"%d\")",
                                         move.moveId.intValue,
                                         category.categoryId.intValue];
            [db executeUpdate:replaceIntoSQL];
            if ([db hadError]) {
                DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
        }
    }
    [db commit];
}
/// Saves User Plan data to the database. This is from a FULL Sync for MyMoves.
- (void)saveUserPlanListData:(NSDictionary *)planListDict {
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
        return;
    }

    if (planListDict[@"ServerUserPlanList"] != [NSNull null]) {
        NSMutableArray * planArr = [[NSMutableArray alloc]init];
        [planArr addObjectsFromArray:planListDict[@"ServerUserPlanList"]];
        
        // Determine the deleted rows.
        NSArray *deletedIdsArray = [self getDeletedIdsForColumn:@"PlanID" inTable:@"ServerUserPlanList"];

        [db beginTransaction];
        if ([planArr count] != 0) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            for (NSDictionary *dict in planArr) {
                
                int planId = [dict[@"PlanID"] intValue];
                int userId = [dict[@"UserID"] intValue];

                NSString *planName = [[dict[@"PlanName"] stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *notes = [[dict[@"Notes"] stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
                NSArray *arr = [dict[@"LastUpdated"] componentsSeparatedByString:@"T"];
                NSString *dateString = [NSString stringWithFormat:@"%@T00:00:00",[arr objectAtIndex:0]];
                NSDate *date = [dateFormatter dateFromString:dateString];
                NSString * lastUpdated = [dateFormatter stringFromDate:date];
                
                NSString *uniqueId = dict[@"UniqueID"];
                // Override status if we've been deleted.
                NSString *status = [deletedIdsArray containsObject:dict[@"PlanID"]] ? @"Deleted" : dict[@"Status"];
                NSString *syncResult = dict[@"SyncResult"];
                NSString *userPlanDates = dict[@"UserPlanDates"];
                
                NSString * insertSQL = [NSString stringWithFormat: @"REPLACE INTO ServerUserPlanList (PlanID,UserID,PlanName,Notes,LastUpdated,UniqueID,Status,SyncResult,UserPlanDates) VALUES (\"%d\",\"%d\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",planId,userId,planName,notes,lastUpdated,uniqueId,status,syncResult,userPlanDates];
                [db executeUpdate:insertSQL];
            }
        }
        
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
    }
    
    if (planListDict[@"ServerUserPlanDateList"] != [NSNull null]) {
        
        NSMutableArray * planDateListArr = [[NSMutableArray alloc]init];
        [planDateListArr addObjectsFromArray:planListDict[@"ServerUserPlanDateList"]];

        NSArray *deletedIdsArray = [self getDeletedIdsForColumn:@"UserPlanDateID" inTable:@"ServerUserPlanDateList"];

        [db beginTransaction];
        if ([planDateListArr count] != 0) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            for (NSDictionary *dict in planDateListArr) {
               
                int userPlanDateID = [dict[@"UserPlanDateID"] intValue];
                int planId = [dict[@"PlanID"] intValue];
                
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
                NSArray *lastUpdateArr = [dict[@"LastUpdated"] componentsSeparatedByString:@"T"];
                NSString *dateString = [NSString stringWithFormat:@"%@T00:00:00",[lastUpdateArr objectAtIndex:0]];
                NSDate *date = [dateFormatter dateFromString:dateString];
                NSString * lastUpdated = [dateFormatter stringFromDate:date];
                
                NSArray *arr = [dict[@"PlanDate"] componentsSeparatedByString:@"T"];
                NSString *dateStr = [NSString stringWithFormat:@"%@T00:00:00",[arr objectAtIndex:0]];
                NSDate *dateFormate = [dateFormatter dateFromString:dateStr];
                NSString * planDate = [dateFormatter stringFromDate:dateFormate];
                
                NSString *uniqueId = dict[@"UniqueID"];
                NSString *status = [deletedIdsArray containsObject:dict[@"UserPlanDateID"]] ? @"Deleted" : dict[@"Status"];
                NSString *syncResult = dict[@"SyncResult"];
                NSString *parentUniqueId = dict[@"ParentUniqueID"];
                NSString *userPlanMoves = dict[@"UserPlanMoves"];
                
                NSString * insertSQL = [NSString stringWithFormat: @"REPLACE INTO ServerUserPlanDateList (UserPlanDateID,PlanID,PlanDate,LastUpdated,UniqueID,Status,SyncResult,ParentUniqueID,UserPlanMoves) VALUES (\"%d\",\"%d\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",userPlanDateID,planId,planDate,lastUpdated,uniqueId,status,syncResult,parentUniqueId,userPlanMoves];
                
                [db executeUpdate:insertSQL];
                
            }
        }
        
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
    }
    
    if (planListDict[@"ServerUserPlanMoveList"] != [NSNull null]) {
        NSMutableArray * planMoveListArr = [[NSMutableArray alloc]init];
        [planMoveListArr addObjectsFromArray:planListDict[@"ServerUserPlanMoveList"]];

        NSArray *deletedIdsArray = [self getDeletedIdsForColumn:@"UserPlanMoveID" inTable:@"ServerUserPlanMoveList"];

        [db beginTransaction];
        if ([planMoveListArr count] != 0) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            for (NSDictionary*dict in planMoveListArr) {
                
                int userPlanMoveId = [dict[@"UserPlanMoveID"] intValue];
                int userPlanDateID = [dict[@"UserPlanDateID"] intValue];
                int moveId = [dict[@"MoveID"] intValue];
                
                NSString *moveName = dict[@"MoveName"];
                NSString *videoLink = dict[@"VideoLink"];
                NSString *notes = [[dict[@"Notes"] stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
                NSArray *arr = [dict[@"LastUpdated"] componentsSeparatedByString:@"T"];
                NSString *dateString = [NSString stringWithFormat:@"%@T00:00:00",[arr objectAtIndex:0]];
                NSDate *date = [dateFormatter dateFromString:dateString];
                NSString * lastUpdated = [dateFormatter stringFromDate:date];
                
                NSString *uniqueId = dict[@"UniqueID"];
                NSString *status = [deletedIdsArray containsObject:dict[@"UserPlanMoveID"]] ? @"Deleted" : dict[@"Status"];
                NSString *syncResult = dict[@"SyncResult"];
                NSString *parentUniqueId = dict[@"ParentUniqueID"];
                NSString *userPlanMoveSets = dict[@"UserPlanMoveSets"];
                NSString *isCheckBoxClicked = @"no";
                
                NSString * insertSQL = [NSString stringWithFormat: @"REPLACE INTO ServerUserPlanMoveList (UserPlanMoveID,UserPlanDateID,MoveID,MoveName,VideoLink,Notes,LastUpdated,UniqueID,Status,SyncResult,ParentUniqueID,UserPlanMoveSets,isCheckBoxClicked) VALUES (\"%d\",\"%d\",\"%d\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",userPlanMoveId,userPlanDateID,moveId,moveName,videoLink,notes,lastUpdated,uniqueId,status,syncResult,parentUniqueId,userPlanMoveSets,isCheckBoxClicked];
                
                [db executeUpdate:insertSQL];
            }
        }
        
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
    }
    if (planListDict[@"ServerUserPlanMoveSetList"] != [NSNull null]) {
        
        NSMutableArray * planMoveSetListArr = [[NSMutableArray alloc]init];
        [planMoveSetListArr addObjectsFromArray:planListDict[@"ServerUserPlanMoveSetList"]];
        
        NSArray *deletedIdsArray = [self getDeletedIdsForColumn:@"SetID" inTable:@"ServerUserPlanMoveSetList"];

        [db beginTransaction];
        if ([planMoveSetListArr count] != 0) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            for (NSDictionary*dict in planMoveSetListArr) {
                
                int setId = [dict[@"SetID"] intValue];
                int userPlanMoveID = [dict[@"UserPlanMoveID"] intValue];
                int setNumber = [dict[@"SetNumber"] intValue];
                int unit1ID = [dict[@"Unit1ID"] intValue];
                int unit1Value = [dict[@"Unit1Value"] intValue];
                int unit2ID = [dict[@"Unit2ID"] intValue];
                int unit2Value = [dict[@"Unit2Value"] intValue];
                
                NSString *unit1Name = dict[@"Unit1Name"];
                NSString *unit2Name = dict[@"Unit2Name"];
                
                [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
                NSDate *currentDate = [NSDate date];
                NSString *dateStringS = [formatter stringFromDate:currentDate];
                NSArray *arrS = [dateStringS componentsSeparatedByString:@"T"];
                NSString *dt = [NSString stringWithFormat:@"%@T00:00:00",[arrS objectAtIndex:0]];
                NSDate *dateS = [formatter dateFromString:dt];
                NSString * lastUpdated = [formatter stringFromDate:dateS];

                NSString *uniqueId = dict[@"UniqueID"];
                NSString *status = [deletedIdsArray containsObject:dict[@"SetID"]] ? @"Deleted" : dict[@"Status"];
                NSString *syncResult = dict[@"SyncResult"];
                NSString *parentUniqueId = dict[@"ParentUniqueID"];
                
                NSString * insertSQL = [NSString stringWithFormat: @"REPLACE INTO ServerUserPlanMoveSetList (SetID,UserPlanMoveID,SetNumber,Unit1ID,Unit1Value,Unit2ID,Unit2Value,Unit1Name,Unit2Name,LastUpdated,UniqueID,Status,SyncResult,ParentUniqueID) VALUES (\"%d\",\"%d\",\"%d\",\"%d\",\"%d\",\"%d\",\"%d\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",setId,userPlanMoveID,setNumber,unit1ID,unit1Value,unit2ID,unit2Value,unit1Name,unit2Name,lastUpdated,uniqueId,status,syncResult,parentUniqueId];
                
                [db executeUpdate:insertSQL];
                
            }
        }
        
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
    }
    
    if (planListDict[@"ServerCustomMoveList"] != [NSNull null]) {
        [db beginTransaction];
        
        NSMutableArray * customPlanMoveListArr = [[NSMutableArray alloc]init];
        [customPlanMoveListArr addObjectsFromArray:planListDict[@"ServerCustomMoveList"]];
        
        if ([customPlanMoveListArr count] != 0) {
            for (NSDictionary *dict in customPlanMoveListArr) {
                
                int moveId = [dict[@"MoveID"] intValue];
                int companyID = [dict[@"CompanyID"] intValue];
                NSString *moveName = dict[@"MoveName"];
                NSString *videoLink = dict[@"VideoLink"];
                NSString *notes = dict[@"Notes"];
                
                NSString * insertSQL = [NSString stringWithFormat: @"REPLACE INTO MoveDetails (moveID,companyID,moveName,videoLink,notes) VALUES (\"%d\",\"%d\",\"%@\",\"%@\",\"%@\")",moveId,companyID,moveName,videoLink,notes];
                [db executeUpdate:insertSQL];
            }
        }
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
    }
}

- (NSArray<DMMovePlan *> *)getUserMovePlans {
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
        return @[];
    }

    NSString *sql = [NSString stringWithFormat:@"SELECT DISTINCT * FROM ServerUserPlanList WHERE Status != 'Deleted'"];
    FMResultSet *rs = [db executeQuery:sql];

    NSMutableArray *results = [NSMutableArray array];
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        DMMovePlan *object = [[DMMovePlan alloc] initWithDictionary:dict];
        
        // Now fetch the composed object.
        NSArray *moveDays = [self getUserPlanDaysForPlanId:object.planId];
        [object setMovePlanDays:moveDays];
        
        [results addObject:object];
    }
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
        
    return [results copy];
}

- (DMMovePlan *)getUserMovePlanForPlanId:(NSNumber *)planId {
    if (!planId) {
        return nil;
    }
FMDatabase* db = [DMDatabaseUtilities database];    if (![db open]) {
    }
        
    NSString *sql = [NSString stringWithFormat:@"SELECT DISTINCT * FROM ServerUserPlanList WHERE "
                                                "PlanID = '%@' AND Status != 'Deleted'", planId];
    FMResultSet *rs = [db executeQuery:sql];

    DMMovePlan *object = nil;
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        object = [[DMMovePlan alloc] initWithDictionary:dict];
        
        // Now fetch the composed object.
        NSArray *moveDays = [self getUserPlanDaysForPlanId:object.planId];
        [object setMovePlanDays:moveDays];
    }
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
        
    return object;
}

- (NSArray<DMMoveDay *> *)getUserPlanDays {
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
        return @[];
    }

    NSString *workoutSql = [NSString stringWithFormat:@"SELECT DISTINCT * FROM ServerUserPlanDateList WHERE Status != 'Deleted'"];
    FMResultSet *rs = [db executeQuery:workoutSql];

    NSMutableArray *results = [NSMutableArray array];
    while ([rs next]) {
        NSDictionary *tempDict = [rs resultDictionary];
        DMMoveDay *object = [[DMMoveDay alloc] initWithDictionary:tempDict];
        
        // Get Routines for the day.
        NSArray *routines = [self getUserPlanRoutinesForDayID:object.dayId];
        [object setDayRoutines:routines];
        
        [results addObject:object];
    }
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
        
    return [results copy];
}

- (DMMoveDay *)getUserPlanDayForDayId:(NSNumber *)dayId {
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
        return nil;
    }

    NSString *sql = [NSString stringWithFormat:@"SELECT DISTINCT * FROM ServerUserPlanDateList WHERE UserPlanDateID = %@", dayId];
    FMResultSet *rs = [db executeQuery:sql];

    DMMoveDay *object = nil;
    while ([rs next]) {
        NSDictionary *tempDict = [rs resultDictionary];
        object = [[DMMoveDay alloc] initWithDictionary:tempDict];
        
        // Get Routines for the day.
        NSArray *routines = [self getUserPlanRoutinesForDayID:object.dayId];
        [object setDayRoutines:routines];
    }
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
        
    return object;
}

- (NSArray<DMMoveDay *> *)getUserPlanDaysForDate:(NSDate *)date {
    if (!date) {
        return @[];
    }
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
        return @[];
    }

    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    self.dateFormatter.timeZone = [NSTimeZone systemTimeZone];
    NSString *dateSelected = [self.dateFormatter stringFromDate:date];
    [self.dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];

    NSString *sql = [NSString stringWithFormat:@"SELECT DISTINCT * FROM ServerUserPlanDateList WHERE "
                                                "PlanDate LIKE '%%%@T%%' AND Status != 'Deleted'", dateSelected];
    FMResultSet *rs = [db executeQuery:sql];

    NSMutableArray *results = [NSMutableArray array];
    while ([rs next]) {
        NSDictionary *tempDict = [rs resultDictionary];
        DMMoveDay *object = [[DMMoveDay alloc] initWithDictionary:tempDict];
        
        // Get Routines for the day.
        NSArray *routines = [self getUserPlanRoutinesForDayID:object.dayId];
        [object setDayRoutines:routines];

        [results addObject:object];
    }
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
        
    return [results copy];
}

- (NSArray<DMMoveRoutine *> *)getUserMoveRoutines {
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
        return @[];
    }

    NSString *workoutSql = [NSString stringWithFormat:@"SELECT DISTINCT * FROM ServerUserPlanMoveList WHERE Status != 'Deleted'"];
    FMResultSet *rs = [db executeQuery:workoutSql];
    
    NSMutableArray *results = [NSMutableArray array];
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        DMMoveRoutine *object = [[DMMoveRoutine alloc] initWithDictionary:dict];
        
        // Get sets.
        NSArray *sets = [self getUserPlanMoveSetsForRoutineID:object.routineId];
        [object setRoutineSets:sets];
        
        // Set the Move.
        DMMove *move = [self getMoveForID:object.moveId];
        [object setMove:move];
        
        [results addObject:object];
    }
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
        
    return [results copy];
}

- (NSArray<DMMoveSet *> *)getUserPlanMoveSets {
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
        return @[];
    }

    NSString *sql = [NSString stringWithFormat:@"SELECT DISTINCT * FROM ServerUserPlanMoveSetList WHERE Status != 'Deleted'"];
    FMResultSet *rs = [db executeQuery:sql];
    
    NSMutableArray *results = [NSMutableArray array];
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        DMMoveSet *object = [[DMMoveSet alloc] initWithDictionary:dict];
        [results addObject:object];
    }
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    return [results copy];
}

- (NSArray<DMMoveSet *> *)getUserPlanMoveSetsForRoutineID:(NSNumber *)routineId {
    if (!routineId) {
        return @[];
    }
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }

    NSString *sql = [NSString stringWithFormat:@"SELECT DISTINCT * FROM ServerUserPlanMoveSetList WHERE "
                                                "UserPlanMoveID = '%@' AND Status != 'Deleted'", routineId];
    FMResultSet *rs = [db executeQuery:sql];
    
    NSMutableArray *results = [NSMutableArray array];
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        DMMoveSet *object = [[DMMoveSet alloc] initWithDictionary:dict];
        [results addObject:object];
    }
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    return [results copy];
}

- (DMMove *)getMoveForID:(NSNumber *)moveId {
    if (!moveId) {
        return nil;
    }
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM MoveDetails WHERE MoveID = '%@'", moveId];
    FMResultSet *rs = [db executeQuery:sql];
    
    DMMove *move = nil;
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        move = [[DMMove alloc] initWithDictionary:dict];
    }
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    return move;
}

- (NSArray<DMMoveDay *> *)getUserPlanDaysForPlanId:(NSNumber *)planId {
    if (!planId) {
        return @[];
    }
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }
    
    NSString *workoutSql = [NSString stringWithFormat:@"SELECT DISTINCT * FROM ServerUserPlanDateList WHERE "
                                                        "PlanID = '%@' AND Status != 'Deleted'", planId];
    FMResultSet *rs = [db executeQuery:workoutSql];

    NSMutableArray *results = [NSMutableArray array];
    while ([rs next]) {
        NSDictionary *tempDict = [rs resultDictionary];
        DMMoveDay *object = [[DMMoveDay alloc] initWithDictionary:tempDict];
        
        // Get Routines for the day.
        NSArray *routines = [self getUserPlanRoutinesForDayID:object.dayId];
        [object setDayRoutines:routines];

        [results addObject:object];
    }
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
        
    return [results copy];
}

- (NSArray<DMMoveRoutine *> *)getUserPlanRoutinesForDayID:(NSNumber *)dayId {
    if (!dayId) {
        return @[];
    }
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }
        
    NSString *sql = [NSString stringWithFormat:@"SELECT DISTINCT * FROM ServerUserPlanMoveList WHERE "
                                                "UserPlanDateID = '%@' AND Status != 'Deleted'", dayId];
    FMResultSet *rs = [db executeQuery:sql];
    
    NSMutableArray *results = [NSMutableArray array];
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        DMMoveRoutine *object = [[DMMoveRoutine alloc] initWithDictionary:dict];
        
        // Get sets.
        NSArray *sets = [self getUserPlanMoveSetsForRoutineID:object.routineId];
        [object setRoutineSets:sets];

        // Set the Move.
        DMMove *move = [self getMoveForID:object.moveId];
        [object setMove:move];

        [results addObject:object];
    }
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
        
    return [results copy];
}

- (DMMoveRoutine *)getUserPlanRoutineForRoutineId:(NSNumber *)routineId {
    if (!routineId) {
        return nil;
    }
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }
    
    NSString *sql = [NSString stringWithFormat:@"SELECT DISTINCT * FROM ServerUserPlanMoveList WHERE "
                                                "UserPlanMoveID = '%@' AND Status != 'Deleted'", routineId];
    FMResultSet *rs = [db executeQuery:sql];

    DMMoveRoutine *object = nil;
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        object = [[DMMoveRoutine alloc] initWithDictionary:dict];
        
        // Get sets.
        NSArray *sets = [self getUserPlanMoveSetsForRoutineID:object.routineId];
        [object setRoutineSets:sets];

        // Set the Move.
        DMMove *move = [self getMoveForID:object.moveId];
        [object setMove:move];
    }
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
        
    return object;
}

- (BOOL)setMoveCompleted:(BOOL)completed forRoutine:(DMMoveRoutine *)routine {
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }
        [db beginTransaction];
    NSString *sql = [NSString stringWithFormat:@"UPDATE ServerUserPlanMoveList SET "
                        "isCheckBoxClicked = '%@' Where UserPlanMoveID = '%@'",
                        @(completed), routine.routineId];
    [db executeUpdate:sql];
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        return NO;
    }
    [db commit];
    
    return YES;
}

/// Deletes the rows that are marked deleted. This should be called after
/// performing a successful sync that sends the data to the server.
- (void)removeRowsWithDeletedStatus {
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }
    
    [db beginTransaction];
    NSString *sqlStatement = [NSString stringWithFormat: @"DELETE FROM ServerUserPlanList WHERE Status = 'Deleted'"];
    [db executeUpdate:sqlStatement];
   
    sqlStatement = [NSString stringWithFormat: @"DELETE FROM ServerUserPlanDateList WHERE Status = 'Deleted'"];
    [db executeUpdate:sqlStatement];
   
    sqlStatement = [NSString stringWithFormat: @"DELETE FROM ServerUserPlanMoveList WHERE Status = 'Deleted'"];
    [db executeUpdate:sqlStatement];
  
    sqlStatement = [NSString stringWithFormat: @"DELETE FROM ServerUserPlanMoveSetList WHERE Status = 'Deleted'"];
    [db executeUpdate:sqlStatement];

    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
}

/// Updates all of the tables status, e.g. from "New" to "Normal" or "Changed" to "Normal".
/// (I believe this has to do with remote server sync.)
- (void)updateDBStatusFrom:(NSString *)fromStatus toStatus:(NSString *)toStatus {
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }
    [db beginTransaction];
    
    NSString *sqlStatement = [NSString stringWithFormat: @"UPDATE ServerUserPlanList SET Status = '%@' WHERE Status = '%@'", toStatus, fromStatus];
    [db executeUpdate:sqlStatement];
    
    sqlStatement = [NSString stringWithFormat: @"UPDATE ServerUserPlanDateList SET Status = '%@' WHERE Status = '%@'", toStatus, fromStatus];
    [db executeUpdate:sqlStatement];
    
    sqlStatement = [NSString stringWithFormat: @"UPDATE ServerUserPlanMoveList SET Status = '%@' WHERE Status = '%@'", toStatus, fromStatus];
    [db executeUpdate:sqlStatement];
    
    sqlStatement = [NSString stringWithFormat: @"UPDATE ServerUserPlanMoveSetList SET Status = '%@' WHERE Status = '%@'", toStatus, fromStatus];
    [db executeUpdate:sqlStatement];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
}

- (NSNumber *)addMoveSet:(DMMoveSet *)moveSet toRoutine:(DMMoveRoutine *)routine {
    if (!moveSet || !routine) {
        return nil;
    }
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }
    
    // Get the lowest ID in the SetList table.
    NSNumber *lowestSetId = [DMDatabaseUtilities getMinValueForColumn:@"SetID" inTable:@"ServerUserPlanMoveSetList"];
    if (lowestSetId) {
        lowestSetId = @(lowestSetId.integerValue - 1);
    } else {
        lowestSetId = @(-100);
    }
    [db beginTransaction];

    /// Need to ensure SetID gets auto incremented.
    /// SetNumber is count of routine's existing sets + 1.
    NSNumber *setNumber = @(routine.sets.count + 1);
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate *currentDate = [NSDate date];
    NSString *lastUpdated = [self.dateFormatter stringFromDate:currentDate];
    NSString *status = @"New";
    NSString *syncResult = @"";
    NSString *uniqueID = [NSUUID UUID].UUIDString;
    NSString *parentUniqueID = [NSString stringWithFormat:@"M-%@", routine.routineId];
    NSNumber *setId = moveSet.setId ?: lowestSetId;
    
    NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO ServerUserPlanMoveSetList (SetID, UserPlanMoveID, SetNumber, Unit1ID, Unit1Value, Unit2ID, Unit2Value, LastUpdated, UniqueID, Status, SyncResult, ParentUniqueID) VALUES "
                        "('%@', '%@', '%@', \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")",
                           setId, routine.routineId, setNumber, moveSet.unitOneId, moveSet.unitOneValue, moveSet.unitTwoId, moveSet.unitTwoValue, lastUpdated, uniqueID, status, syncResult, parentUniqueID];
    [db executeUpdate:insertSQL];
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
    
    return setId;
}
                                        
- (NSArray<DMMoveTag *> *)loadListOfTags {
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }
    
    NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM MoveTags"];
    FMResultSet *rs = [db executeQuery:sqlString];
    NSMutableArray *tagArray = [NSMutableArray array];
    
    while ([rs next]) {
        NSDictionary *resultDict = [rs resultDictionary];
        DMMoveTag *tag = [[DMMoveTag alloc] initWithDictionary:resultDict];
        if (tag.name.length) {
            [tagArray addObject:tag];
        }
    }

    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    
    return [tagArray copy];
}

- (NSArray<DMMoveCategory *> *)loadListOfBodyPart {
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }
    
    NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM MoveCategories"];
    FMResultSet *rs = [db executeQuery:sqlString];
    NSMutableArray *categoriesArray = [NSMutableArray array];
    
    while ([rs next]) {
        NSDictionary *resultDict = [rs resultDictionary];
        DMMoveCategory *category = [[DMMoveCategory alloc] initWithDictionary:resultDict];
        [categoriesArray addObject:category];
    }

    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
        
    return [categoriesArray copy];
}

- (NSArray<DMMove *> *)getMovesFromDatabaseWithCategoryFilter:(DMMoveCategory *)categoryFilter
                                                    tagFilter:(DMMoveTag *)tagFilter
                                                   textSearch:(NSString *)textSearch {
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }
    
    NSMutableString *sqlString = [NSMutableString string];
    [sqlString appendString:@"SELECT DISTINCT d.moveID, d.companyID, d.moveName FROM MoveDetails d "];
    if (categoryFilter) {
        [sqlString appendString:@"INNER JOIN MovesCategories c ON d.moveID = c.moveID "];
    }
    if (tagFilter) {
        [sqlString appendString:@"INNER JOIN MovesTags t ON d.moveID = t.moveID "];
    }
    if (categoryFilter || tagFilter || textSearch.length) {
        [sqlString appendString:@"WHERE "];
    }
    if (categoryFilter) {
        [sqlString appendFormat:@"c.categoryID = %i ", categoryFilter.categoryId.intValue];
        if (tagFilter || textSearch.length) {
            [sqlString appendString:@"AND "];
        }
    }
    if (tagFilter) {
        [sqlString appendFormat:@"t.tagID = %i ", tagFilter.tagId.intValue];
        if (textSearch.length) {
            [sqlString appendString:@"AND "];
        }
    }
    if (textSearch.length) {
        [sqlString appendFormat:@"d.moveName LIKE '%%%@%%'", textSearch];
    }
    [sqlString appendString:@" ORDER BY d.moveName"];
    FMResultSet *rs = [db executeQuery:sqlString];
    
    NSMutableArray *movesArray = [NSMutableArray array];
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        DMMove *move = [[DMMove alloc] initWithDictionary:dict];
        [movesArray addObject:move];
    }
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
        
    return [movesArray copy];
}


- (NSNumber *)addMoveDayToDate:(NSDate *)date toMovePlan:(DMMovePlan *)movePlan {
    if (!date || !movePlan) {
        return nil;
    }
    
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }
    
    // Get the lowest ID in the MoveList table.
    NSNumber *lowestId = [DMDatabaseUtilities getMinValueForColumn:@"UserPlanDateID" inTable:@"ServerUserPlanDateList"];
    if (lowestId) {
        lowestId = @(lowestId.integerValue - 1);
    } else {
        lowestId = @(-100);
    }
    [db beginTransaction];
    
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSString *lastUpdated = [self.dateFormatter stringFromDate:[NSDate date]];
    NSString *planDate = [self.dateFormatter stringFromDate:date];
    NSString *uniqueId = [NSString stringWithFormat:@"D-%@", lowestId];
    NSString *status = @"New";
    
    NSString * insertSQL = [NSString stringWithFormat: @"REPLACE INTO ServerUserPlanDateList "
                            "(UserPlanDateID, PlanID, PlanDate, LastUpdated, UniqueID, Status, ParentUniqueID) VALUES "
                            "(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",
                            lowestId, movePlan.planId, planDate, lastUpdated, uniqueId, status, movePlan.uniqueId];
    
    [db executeUpdate:insertSQL];

    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
    
    return lowestId;
}

- (void)deleteMoveSet:(DMMoveSet *)moveSet {
    if (!moveSet) {
        return;
    }
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }
    
    [db beginTransaction];
    NSString *sql = [NSString stringWithFormat: @"UPDATE ServerUserPlanMoveSetList SET "
                                            "Status = '%@' Where SetID = '%@'",
                                            @"Deleted", moveSet.setId];
    [db executeUpdate:sql];
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
}

/// Returns a list of IDs for the given column that are deleted in the table provided.
/// This is used because the network sync isn't saving deleted moves data. So, upon sync,
/// it keeps bringing them back from the dead. So, on sync, we check to see if it's still
/// deleted and updated it accordingly.
/// NOTE: This must be called before beginning a database transaction or the DB will be locked.
- (NSArray<NSNumber *> *)getDeletedIdsForColumn:(NSString *)column inTable:(NSString *)tableName {
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }
    
    NSString *sqlString = [NSString stringWithFormat:@"SELECT %@ FROM '%@' WHERE Status = 'Deleted'", column, tableName];
    FMResultSet *rs = [db executeQuery:sqlString];
    
    NSMutableArray *results = [NSMutableArray array];
    while ([rs next]) {
        NSDictionary *resultDict = [rs resultDictionary];
        [results addObject:resultDict[column]];
    }

    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
        
    return [results copy];
}

- (void)deleteMoveRoutine:(DMMoveRoutine *)moveRoutine {
    if (!moveRoutine) {
        return;
    }
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }
    
    [db beginTransaction];
    NSString *sql = [NSString stringWithFormat: @"UPDATE ServerUserPlanMoveList SET "
                                          "Status = 'Deleted' WHERE UserPlanMoveID = %@",
                                          moveRoutine.routineId];
    [db executeUpdate:sql];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
}

- (NSNumber *)addMoveRoutine:(DMMoveRoutine *)moveRoutine toMoveDay:(DMMoveDay *)moveDay {
    if (!moveRoutine || !moveDay) {
        return nil;
    }
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }
    
    // Get the lowest ID in the MoveList table.
    NSNumber *lowestID = [DMDatabaseUtilities getMinValueForColumn:@"UserPlanMoveID" inTable:@"ServerUserPlanMoveList"];
    if (lowestID) {
        lowestID = @(lowestID.integerValue - 1);
    } else {
        lowestID = @(-100);
    }
    [db beginTransaction];

    [self.dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate *currentDate = [NSDate date];
    NSString *lastUpdated = [self.dateFormatter stringFromDate:currentDate];
    NSString *status = @"New";
    NSString *syncResult = @"";
    NSString *parentUniqueID = [NSString stringWithFormat:@"M-%@", moveDay.dayId];
    NSNumber *routineId = moveRoutine.routineId ?: lowestID;
    NSString *uniqueId = [NSString stringWithFormat:@"M-%@", routineId];

    NSString *insertSQL = [NSString stringWithFormat: @"REPLACE INTO ServerUserPlanMoveList (UserPlanMoveID, UserPlanDateID, MoveID, "
                                "LastUpdated, UniqueID, Status, SyncResult, ParentUniqueID, isCheckBoxClicked) VALUES "
                                "(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",
                                routineId, moveDay.dayId, moveRoutine.moveId, lastUpdated, uniqueId, status,
                                syncResult, parentUniqueID, @(NO)];

    [db executeUpdate:insertSQL];
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
    
    return routineId;
}

- (void)setFirstUnitId:(NSNumber *)unitId forMoveSet:(DMMoveSet *)moveSet {
    if (!unitId || !moveSet) {
        return;
    }
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
        return;
    }
    [db beginTransaction];
    NSString *updateUnit1ID = [NSString stringWithFormat:@"UPDATE ServerUserPlanMoveSetList SET Unit1ID = '%@', "
                                        "Status = 'Changed' Where SetID = '%@'", unitId, moveSet.setId];
    [db executeUpdate:updateUnit1ID];
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
}

- (void)setSecondUnitId:(NSNumber *)unitId forMoveSet:(DMMoveSet *)moveSet {
    if (!unitId || !moveSet) {
        return;
    }
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
        return;
    }
    [db beginTransaction];
    NSString *updateUnit1ID = [NSString stringWithFormat:@"UPDATE ServerUserPlanMoveSetList SET Unit2ID = '%@', "
                                        "Status = 'Changed' Where SetID = '%@'", unitId, moveSet.setId];
    [db executeUpdate:updateUnit1ID];
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
}

- (void)setFirstUnitValue:(NSNumber *)unitValue forMoveSet:(DMMoveSet *)moveSet {
    if (!unitValue || !moveSet) {
        return;
    }
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
        return;
    }
    
    [db beginTransaction];
    NSString *sql = [NSString stringWithFormat:@"UPDATE ServerUserPlanMoveSetList SET Unit1Value = '%@', "
                                            "Status = 'Changed' Where SetID = '%@'", unitValue, moveSet.setId];
    [db executeUpdate:sql];
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
}

- (void)setSecondUnitValue:(NSNumber *)unitValue forMoveSet:(DMMoveSet *)moveSet {
    if (!unitValue || !moveSet) {
        return;
    }
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
        return;
    }
    [db beginTransaction];
    NSString *sql = [NSString stringWithFormat:@"UPDATE ServerUserPlanMoveSetList SET Unit2Value = '%@', "
                                            "Status = 'Changed' Where SetID = '%@'", unitValue, moveSet.setId];
    [db executeUpdate:sql];
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
}

@end
