//
//  MyMovesWebServices.m
//  MyMoves
//
//  Created by Samson  on 29/01/19.
//

#import "MyMovesWebServices.h"
#import "FMDatabase.h"
#import "DMMove.h"
#import "DMMoveTag.h"
#import "DMMoveCategory.h"
#import "DMMovePickerRow.h"
#import "DMMovePlan.h"

@interface MyMovesWebServices()

@property (nonatomic, strong) NSXMLParser *xmlParser;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation MyMovesWebServices

- (instancetype)init {
    self = [super init];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return self;
}

#pragma mark - UpSync Helpers

/// Gets all rows that were New, Deleted, or Updated.
- (NSArray<NSDictionary *> *)getUserPlanListUpdates {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
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
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
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
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
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
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
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

#pragma mark - DownSync Helpers

- (void)fetchAllUserPlanData {
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *AuthHash = [prefs valueForKey:@"authkey_dietmastergo"];
        
        // TODO: Uncomment when server can receive data.
//        NSArray *userPlanListUpdates = [self getUserPlanListUpdates];
//        NSArray *userPlanDateListUpdates = [self getUserPlanDateListUpdates];
//        NSArray *userPlanMoveListUpdates = [self getUserPlanMoveListUpdates];
//        NSArray *userPlanMoveSetListUpdates = [self getUserPlanMoveSetListUpdates];
              
        NSDictionary *requestDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     AuthHash, @"AuthHash",
                                     @(YES), @"SendAllServerData",
                                     // TODO: Hook up server at a later date. It isn't working properly (HTK).
                                     //userPlanListUpdates, @"MobileUserPlanList",
                                     //userPlanDateListUpdates, @"MobileUserPlanDateList",
                                     //userPlanMoveListUpdates, @"MobileUserPlanMoveList",
                                     //userPlanMoveSetListUpdates, @"MobileUserPlanMoveSetList",
                                     nil];
        
        __block NSMutableDictionary *resultsDictionary;
        if ([NSJSONSerialization isValidJSONObject:requestDict]) {
            NSError* error;
            NSData* jsonData = [NSJSONSerialization dataWithJSONObject:requestDict options:NSJSONWritingPrettyPrinted error: &error];
            NSURL* url = [NSURL URLWithString:@"https://dmwebpro.com/MobileAPI/SyncUser"];
            NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:jsonData];
            [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse* response,NSData* data, NSError* error) {
                if (error) {
                    DMLog(@"Error fetching: %@", error.localizedDescription);
                }
                 if ([data length] && !error) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         NSError *jsonError = nil;
                         resultsDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                         if (jsonError) {
                             DMLog(@"Error parsing JSON: %@", jsonError.localizedDescription);
                             return;
                         }
                         [self serverUserPlans:resultsDictionary];
                         if ([self.delegate respondsToSelector:@selector(getUserWorkoutPlansFinished:)]) {
                             [self.delegate getUserWorkoutPlansFinished:resultsDictionary];
                         }
                         // TODO: Uncomment this once the server accepts updates being sent.
                         // [self removeRowsWithDeletedStatus];
                         // [self updateDBStatusFrom:@"New" toStatus:@"Normal"];
                         // [self updateDBStatusFrom:@"Changed" toStatus:@"Normal"];
                     });
                 }
             }];
        }
    }];
    [operationQueue addOperation:blockOperation];
}

- (void)clearTableData {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
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

/// Saves User Plan data to the database. This is from a FULL Sync.
- (void)serverUserPlans:(NSDictionary *)planListDict {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
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
                
                int userPlanMoveId = [dict[@"UserPlanMoveID"] integerValue];
                int userPlanDateID = [dict[@"UserPlanDateID"] integerValue];
                int moveId = [dict[@"MoveID"] integerValue];
                
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

#pragma mark - Local DataSource

- (NSArray<DMMovePlan *> *)getUserMovePlans {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
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
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
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
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
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

-(NSArray<DMMoveDay *> *)getUserPlanDaysForDate:(NSDate *)date {
    if (!date) {
        return @[];
    }
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
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
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
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
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
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
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
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
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
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
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
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
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
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
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
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
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
        return NO;
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
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
        return;
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
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
        return;
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

-(void)addMovesToDb:(NSDictionary *)dict
       SelectedDate:(NSDate*)planDate
           planName:(NSString *)planName
       categoryName:(NSString*)CatName
         CategoryID:(int)categoryID
           tagsName:(NSString*)tag
             TagsId:(int)tagsId
             status:(NSString*)status
     PlanNameUnique:(NSString*)PlanNameUnique
     DateListUnique:(NSString*)DateListUnique
     MoveNameUnique:(NSString*)MoveNameUnique {

    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    [db beginTransaction];
    
    int moveId = [dict[@"WorkoutID"] integerValue];
    
    NSString *notes = [[dict[@"Notes"] stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];;
    NSString *moveName = [[dict[@"WorkoutName"] stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *videoUrl = dict[@"Link"];
    NSString *syncResult = @"";
   
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSString * planDateStr = [dateFormatter stringFromDate:planDate];
    NSArray *items = [planDateStr componentsSeparatedByString:@"T"];
    planDateStr = [[items objectAtIndex:0] stringByAppendingString:@"T00:00:00"];
       
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate *currentDate = [NSDate date];
    NSString *lastUpdated = [formatter stringFromDate:currentDate];

    
    NSString *selectQuery = [NSString stringWithFormat:@"SELECT * from PlanDateUniqueID_Table WHERE PlanDate = '%@'",planDateStr];
    FMResultSet *rs = [db executeQuery:selectQuery];

    NSMutableArray *arr = [NSMutableArray new];

    while ([rs next]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        NSString *uniqueIDs = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"UniqueID"]];
        NSString *planDate = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"PlanDate"]];

        [dict setObject: uniqueIDs  forKey: @"UniqueID"];
        [dict setObject: planDate  forKey: @"PlanDate"];

        [arr addObject:dict];
    }
    //DMLog(@"%@",arr);

    if ([arr count] != 0)
    {
        if ([planDateStr isEqualToString:arr[0][@"PlanDate"]])
        {

            NSString *UpdateSQL = [NSString stringWithFormat:@"UPDATE PlanDateUniqueID_Table SET UniqueID = %@ Where PlanDate = %@",PlanNameUnique,planDateStr];
            [db executeUpdate:UpdateSQL];

            NSString * insertSQL = [NSString stringWithFormat: @"REPLACE INTO ServerUserPlanList (PlanName,Notes,LastUpdated,UniqueID,syncResult) VALUES (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",planName,notes,lastUpdated,arr[0][@"UniqueID"],syncResult];
            [db executeUpdate:insertSQL];

            NSMutableDictionary *setDict = [NSMutableDictionary dictionary];

            [setDict setObject: planName  forKey: @"PlanName"];
            [setDict setObject: notes  forKey: @"Notes"];
            [setDict setObject: planDateStr  forKey: @"LastUpdated"];
            [setDict setObject: arr[0][@"UniqueID"]  forKey: @"UniqueID"];
            [setDict setObject: status  forKey: @"Status"];
            [setDict setObject: syncResult forKey: @"syncResult"];
            [setDict setObject: notes  forKey: @"notes"];
            [setDict setObject: moveName  forKey: @"moveName"];
            [setDict setObject: videoUrl  forKey: @"videoUrl"];
            [setDict setObject: [NSNumber numberWithInt:moveId]  forKey: @"moveId"];
            [setDict setObject: DateListUnique  forKey: @"DateListUnique"];
            [setDict setObject: MoveNameUnique  forKey: @"MoveNameUnique"];
            [db commit];
            [self mobilePlanDateList:planDate DateUniqueID:DateListUnique Dict:setDict];
        }
        else
        {
            NSString * insertSQLite = [NSString stringWithFormat: @"REPLACE INTO PlanDateUniqueID_Table (PlanDate,UniqueID) VALUES (\"%@\",\"%@\")",planDateStr,PlanNameUnique];
            [db executeUpdate:insertSQLite];

            NSMutableDictionary *setDict = [NSMutableDictionary dictionary];

            [setDict setObject: planName  forKey: @"PlanName"];
            [setDict setObject: notes  forKey: @"Notes"];
            [setDict setObject: planDateStr  forKey: @"LastUpdated"];
            [setDict setObject: PlanNameUnique  forKey: @"UniqueID"];
            [setDict setObject: status  forKey: @"Status"];
            [setDict setObject: [NSString stringWithFormat:@"%@", syncResult]  forKey: @"syncResult"];
            [setDict setObject: notes  forKey: @"notes"];
            [setDict setObject: moveName  forKey: @"moveName"];
            [setDict setObject: videoUrl  forKey: @"videoUrl"];
            [setDict setObject: [NSNumber numberWithInt:moveId]  forKey: @"moveId"];
            [setDict setObject: DateListUnique  forKey: @"DateListUnique"];
            [setDict setObject: MoveNameUnique  forKey: @"MoveNameUnique"];

            NSString * insertSQL = [NSString stringWithFormat: @"REPLACE INTO ServerUserPlanList (PlanName,Notes,LastUpdated,UniqueID,Status,syncResult) VALUES (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",planName,notes,lastUpdated,PlanNameUnique,status,syncResult];
            [db executeUpdate:insertSQL];
            [db commit];



            [self mobilePlanDateList:planDate DateUniqueID:DateListUnique Dict:setDict];
        }
    }
    else
    {
        NSString * insertSQLite = [NSString stringWithFormat: @"REPLACE INTO PlanDateUniqueID_Table (PlanDate,UniqueID) VALUES (\"%@\",\"%@\")",planDateStr,PlanNameUnique];
        [db executeUpdate:insertSQLite];
    
        NSMutableDictionary *setDict = [NSMutableDictionary dictionary];
        
        [setDict setObject: planName  forKey: @"PlanName"];
        [setDict setObject: notes  forKey: @"Notes"];
        [setDict setObject: planDateStr  forKey: @"LastUpdated"];
        [setDict setObject: PlanNameUnique  forKey: @"UniqueID"];
        [setDict setObject: status  forKey: @"Status"];
        [setDict setObject: [NSString stringWithFormat:@"%@", syncResult]  forKey: @"syncResult"];
        [setDict setObject: notes  forKey: @"notes"];
        [setDict setObject: moveName  forKey: @"moveName"];
        [setDict setObject: videoUrl  forKey: @"videoUrl"];
        [setDict setObject: [NSNumber numberWithInt:moveId]  forKey: @"moveId"];
        [setDict setObject: DateListUnique  forKey: @"DateListUnique"];
        [setDict setObject: MoveNameUnique  forKey: @"MoveNameUnique"];
        
        NSString * insertSQL = [NSString stringWithFormat: @"REPLACE INTO ServerUserPlanList (PlanName,Notes,LastUpdated,UniqueID,Status,syncResult) VALUES (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",planName,notes,lastUpdated,PlanNameUnique,status,syncResult];
        [db executeUpdate:insertSQL];
        [db commit];
        
        [self mobilePlanDateList:planDate DateUniqueID:DateListUnique Dict:setDict];
    }
    

    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
    
    [[NSUserDefaults standardUserDefaults] setObject:MoveNameUnique forKey:@"MoveNameUnique"];
}

-(void)mobilePlanDateList:(NSDate *)planDate
             DateUniqueID:(NSString *)uniqueID
                     Dict:(NSDictionary *)dict {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    
    [db beginTransaction];
   
    NSString * parentUniqueId = dict[@"UniqueID"];
    
    NSString * moveName = [[dict[@"moveName"]stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString * videoUrl = dict[@"videoUrl"];
    NSString * notes = [[dict[@"notes"] stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    int moveId = [dict[@"moveId"] integerValue];
    NSString * DateListUnique = dict[@"DateListUnique"];
    NSString * MoveNameUnique = dict[@"MoveNameUnique"];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate *currentDate = [NSDate date];
    NSString *lastUpdated = [formatter stringFromDate:currentDate];


    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSString * planDateStr = [dateFormatter stringFromDate:planDate];
    NSArray *items = [planDateStr componentsSeparatedByString:@"T"];
    planDateStr = [[items objectAtIndex:0] stringByAppendingString:@"T00:00:00"];
    
    NSString *status = @"New";
    NSString *syncResult = @"";

    NSString * insertSQL = [NSString stringWithFormat: @"REPLACE INTO ServerUserPlanDateList (PlanDate,LastUpdated,UniqueID,Status,SyncResult,ParentUniqueID) VALUES (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",planDateStr,lastUpdated,uniqueID,status,syncResult,parentUniqueId];

    [db executeUpdate:insertSQL];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
    
    [self mobilePlanMoveList:moveName VideoLink:videoUrl Notes:notes UniqueID:MoveNameUnique ParentUniqueID:DateListUnique MoveID:moveId PlanDateStr:planDateStr];
}

//new API
- (void)mobilePlanMoveList:(NSString *)MoveName
                 VideoLink:(NSString *)VideoLink
                     Notes:(NSString *)Notes
                  UniqueID:(NSString *)UniqueID
            ParentUniqueID:(NSString *)ParentUniqueID
                    MoveID:(int)MoveID
               PlanDateStr:(NSString *)PlanDateStr
{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    
    [db beginTransaction];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate *currentDate = [NSDate date];
    NSString *lastUpdated = [formatter stringFromDate:currentDate];

    
    NSString *status = @"New";
    NSString *syncResult = @"";
    NSString *isCheckBoxClicked = @"no";
    
    NSString * insertSQL = [NSString stringWithFormat: @"REPLACE INTO PlanDateTable (PlanDate) VALUES (\"%@\")",PlanDateStr];

    [db executeUpdate:insertSQL];

    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];

        NSString * insertSQLite = [NSString stringWithFormat: @"REPLACE INTO ServerUserPlanMoveList (MoveID,MoveName,VideoLink,Notes,LastUpdated,UniqueID,Status,SyncResult,ParentUniqueID,isCheckBoxClicked) VALUES (\"%d\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",MoveID,MoveName,VideoLink,Notes,lastUpdated,UniqueID,status,syncResult,ParentUniqueID,isCheckBoxClicked];
        [db executeUpdate:insertSQLite];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
    
    NSMutableDictionary *moveDict = [NSMutableDictionary dictionary];
    [moveDict setObject: MoveName  forKey: @"MoveName"];
    [moveDict setObject: VideoLink  forKey: @"VideoLink"];
    [moveDict setObject: Notes  forKey: @"Notes"];
    [moveDict setObject: lastUpdated  forKey: @"LastUpdated"];
    [moveDict setObject: UniqueID  forKey: @"UniqueID"];
    [moveDict setObject: [NSString stringWithFormat:@"%@", status]  forKey: @"Status"];
    [moveDict setObject: [NSString stringWithFormat:@"%@", syncResult]  forKey: @"syncResult"];
    [moveDict setObject: ParentUniqueID  forKey: @"ParentUniqueID"];
}

- (void)addMoveSet:(DMMoveSet *)moveSet toRoutine:(DMMoveRoutine *)routine {
    if (!moveSet || !routine) {
        return;
    }
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
        return;
    }

    // Get the highest ID in the SetList table.
    NSNumber *highestSetId = [self getMaxValueForColumn:@"SetID" inTable:@"ServerUserPlanMoveSetList"];
    if (highestSetId) {
        highestSetId = @(highestSetId.integerValue + 1);
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
    
    NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO ServerUserPlanMoveSetList (SetID, UserPlanMoveID, SetNumber, Unit1ID, Unit1Value, Unit2ID, Unit2Value, LastUpdated, UniqueID, Status, SyncResult, ParentUniqueID) VALUES "
                        "('%@', '%@', '%@', \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")",
                           highestSetId, routine.routineId, setNumber, moveSet.unitOneId, moveSet.unitOneValue, moveSet.unitTwoId, moveSet.unitTwoValue, lastUpdated, uniqueID, status, syncResult, parentUniqueID];
    [db executeUpdate:insertSQL];
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
}
                                        
- (NSArray<DMMoveTag *> *)loadListOfTags {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
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
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
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
    DietmasterEngine *dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase *db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
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

- (void)deleteMoveSet:(DMMoveSet *)moveSet {
    if (!moveSet) {
        return;
    }
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
        return;
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
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
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


#pragma mark - Helpers

/// Gets the max value for the column provided in the table name.
/// Used to help get ID values since most tables aren't auto incremented.
- (NSNumber *)getMaxValueForColumn:(NSString *)columnName inTable:(NSString *)tableName {
    if (!columnName.length || !tableName.length) {
        return nil;
    }
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
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


#pragma mark - Monthly Exercise

- (void)saveMonthlyExerciseToDb:(NSDictionary *)monthlyDict {
    if (monthlyDict[@"UserWorkoutPlan"] != [NSNull null])
        {
            DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
            FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
            if (![db open]) {
            }
            [db beginTransaction];
            
            NSMutableArray * monthlyArr = [[NSMutableArray alloc]init];
            
            [monthlyArr addObjectsFromArray:monthlyDict[@"UserWorkoutPlan"]];
            
            if ([monthlyArr count] != 0)
            {
                for (NSDictionary*dict in monthlyArr) {
                    
                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                    
                    int UserID = [[prefs valueForKey:@"userid_dietmastergo"] integerValue];
                    int WorkoutUserID = [dict[@"WorkoutUserID"] integerValue];
                    
                    NSString * tempName = dict[@"TemplateName"];
                    
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
                    NSArray *arr = [dict[@"WorkoutDate"] componentsSeparatedByString:@"T"];
                    NSString *dateString = [NSString stringWithFormat:@"%@T00:00:00",[arr objectAtIndex:0]];
                    NSDate *date = [dateFormatter dateFromString:dateString];
                    NSString * workoutDate = [dateFormatter stringFromDate:date];
                    
                    int workoutTempId = [dict[@"WorkoutTemplateId"] integerValue];
                    int workOutUserDateID = [dict[@"WorkoutUserDateID"] integerValue];
                    
                    int categoryId = [dict[@"CategoryID"] integerValue];
                    NSString * categoryName = dict[@"CategoryName"];
                    int workoutId = [dict[@"WorkoutID"] integerValue];
                    NSString * exerciseName = dict[@"ExerciseName"];
                    NSString * sessionNotes = dict[@"SessionNotes"];
                    NSString * exerciseNotes = dict[@"ExerciseNotes"];
                    NSString * videoUrl = dict[@"VideoURL"];
                    NSString * currentDuration = dict[@"CurrentDuration"];
                    NSString * workingStatus = dict[@"WorkingStatus"];
                    NSString * comments = dict[@"Comments"];
                    int processID = [dict[@"ProcessID"] integerValue];
                    int tagsId = [dict[@"TagsId"] integerValue];
                    NSString * tags = dict[@"Tags"];
                    NSString * isEdited = @"no";
                    NSString * ToBeAdded = @"no";
                    NSString * isCommented = @"no";
                    NSString * isStatusUpdated = @"no";
                    
                    NSString * insertSQL = [NSString stringWithFormat: @"REPLACE INTO UserWorkoutPlan (UserID,TemplateName,WorkoutDate,WorkoutTemplateId,CategoryID,CategoryName,WorkoutID,ExerciseName,SessionNotes,ExerciseNotes,VideoURL,CurrentDuration,WorkingStatus,Comments,ProcessID,TagsId,Tags,isEdited,WorkoutUserID,ToBeAdded,isCommented,isStatusUpdated,WorkoutUserDateID) VALUES(\"%d\",\"%@\",\"%@\",\"%d\",\"%d\",\"%@\",\"%d\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%d\",\"%d\",\"%@\",\"%@\",\"%d\",\"%@\",\"%@\",\"%@\",\"%d\")",UserID,tempName,workoutDate,workoutTempId,categoryId,categoryName,workoutId,exerciseName,sessionNotes,exerciseNotes,videoUrl,currentDuration,workingStatus,comments,processID,tagsId,tags,isEdited,WorkoutUserID,ToBeAdded,isCommented,isStatusUpdated,workOutUserDateID];
                    
                    [db executeUpdate:insertSQL];
                    
                }
            }
            
            if ([db hadError]) {
                DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
            [db commit];
            
            NSOperationQueue *operationQueue = [NSOperationQueue new];
            NSBlockOperation *blockCompletionOperation = [NSBlockOperation blockOperationWithBlock:^{
                DMLog(@"The block operation ended, Do something such as show a successmessage etc");
                //This the completion block operation
            }];
            NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
                //This is the worker block operation
                [self saveWorkoutDetailToDb:monthlyArr];
            }];
            [blockCompletionOperation addDependency:blockOperation];
            [operationQueue addOperation:blockCompletionOperation];
            [operationQueue addOperation:blockOperation];
            
        }

}

- (void)setFirstUnitId:(NSNumber *)unitId forMoveSet:(DMMoveSet *)moveSet {
    if (!unitId || !moveSet) {
        return;
    }
    DietmasterEngine *dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
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
    DietmasterEngine *dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
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
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
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
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
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

- (void)deleteMoveRoutine:(DMMoveRoutine *)moveRoutine {
    if (!moveRoutine) {
        return;
    }
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
        return;
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

-(void)addExerciseToDb:(NSDictionary *)dict
           workoutDate:(NSDate*)date
                userId:(int)userID
          categoryName:(NSString*)name
            CategoryID:(int)categoryID
              tagsName:(NSString*)tag
                TagsId:(int)tagsId
          templateName:(NSString*)templateNameStr
         WorkoutDateID:(int)WorkoutDateID
{
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        
        FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
        if (![db open]) {
        }
        [db beginTransaction];
        
        int UserID = userID;
        int WorkoutUserID = 0;
    
        NSString * tempName = templateNameStr;
    
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];

        NSString * workoutDate = [dateFormatter stringFromDate:date];
    
        NSArray *items = [workoutDate componentsSeparatedByString:@"T"];
    
        workoutDate = [[items objectAtIndex:0] stringByAppendingString:@"T00:00:00"];
  
        int workoutId = [dict[@"WorkoutID"] integerValue];
    
    NSString * exerciseName = dict[@"WorkoutName"];
    
    if ([exerciseName containsString:@"("]) {
        NSArray *arr1 = [exerciseName componentsSeparatedByString:@"("];
        exerciseName = [NSString stringWithFormat:@"%@",[arr1 objectAtIndex:0]];
    }
    
        NSString * sessionNotes = dict[@"Notes"];
        NSString * exerciseNotes = dict[@"Notes"];
        NSString * videoUrl = dict[@"Link"];
        NSString * currentDuration = @"";
        NSString * workingStatus = @"false";
        int processID = 0;
        NSString * tags = tag;
        NSString * isEdited = @"no";
        NSString * comments = @"";
        NSString * ToBeAdded = @"yes";
        NSString * isCommented = @"no";
        NSString * isStatusUpdated = @"no";

    int workoutTempId = arc4random_uniform(1000000);

        NSString * insertSQL = [NSString stringWithFormat: @"REPLACE INTO UserWorkoutPlan (UserID,TemplateName,WorkoutDate,WorkoutTemplateId,CategoryID,CategoryName,WorkoutID,ExerciseName,SessionNotes,ExerciseNotes,VideoURL,CurrentDuration,WorkingStatus,Comments,ProcessID,TagsId,Tags,isEdited,WorkoutUserID,ToBeAdded,isCommented,isStatusUpdated,WorkoutUserDateID) VALUES(\"%d\",\"%@\",\"%@\",\"%d\",\"%d\",\"%@\",\"%d\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%d\",\"%d\",\"%@\",\"%@\",\"%d\",\"%@\",\"%@\",\"%@\",\"%d\")",UserID,tempName,workoutDate,WorkoutDateID,categoryID,name,workoutId,exerciseName,sessionNotes,exerciseNotes,videoUrl,currentDuration,workingStatus,comments,processID,tagsId,tags,isEdited,WorkoutUserID,ToBeAdded,isCommented,isStatusUpdated,WorkoutDateID];

                [db executeUpdate:insertSQL];
    
                if ([db hadError]) {
                    DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                }
    
        [db commit];
    
    NSMutableDictionary *setDict = [NSMutableDictionary dictionary];
    
    [setDict setObject: [NSNumber numberWithInt:1]  forKey: @"P1Number"];
    [setDict setObject: [NSNumber numberWithInt:0]  forKey: @"P2Value"];
    [setDict setObject: [NSNumber numberWithInt:0]  forKey: @"P3Value"];
    
    [setDict setObject: [NSNumber numberWithInt:1]  forKey: @"TableP2ID"];
    [setDict setObject: [NSNumber numberWithInt:1]  forKey: @"TableP3ID"];
    [setDict setObject: @"reps"  forKey: @"TableP2Name"];
    [setDict setObject: @"Weight"  forKey: @"TableP3Name"];
    
    [setDict setObject: [NSNumber numberWithInt:0]  forKey: @"WorkoutMethodID"];
    [setDict setObject: [NSNumber numberWithInt:workoutTempId]  forKey: @"WorkoutMethodValueID"];
    
    //[self addSetsForExercise:WorkoutDateID Dict:setDict];
}

-(void)updateWorkoutToDb:(NSString *)exerciseDate {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    
    [db beginTransaction];
    
    NSString *updateComments = [NSString stringWithFormat: @"UPDATE UserWorkoutPlan SET isEdited = 'yes' WHERE WorkoutDate = '%@'",exerciseDate];
    
    [db executeUpdate:updateComments];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
    
}

-(void)updateTimeToDb:(NSString *)WorkingStatus timeToSet:(NSString *)CurrentDuration excerciseDict:(NSDictionary *)dict
{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    
    [db beginTransaction];
    
    int WorkoutTemplateId = [dict[@"WorkoutUserDateID"] integerValue];
    int ProcessID = [dict[@"ProcessID"] integerValue];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int UserID = [[prefs valueForKey:@"userid_dietmastergo"] integerValue];
    
    NSString * WorkoutDate = dict[@"WorkoutDate"];

    NSString *updateComments = [NSString stringWithFormat: @"UPDATE UserWorkoutPlan SET WorkingStatus = '%@',CurrentDuration = '%@',ProcessID = '%d',UserID = '%d',isEdited = 'yes' WHERE WorkoutUserDateID = '%d'",WorkingStatus,CurrentDuration,ProcessID,UserID,WorkoutTemplateId];
    
    [db executeUpdate:updateComments];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
}

- (void)deletePlanWorkoutFromDbWithUserDateID:(NSNumber *)userDateID {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }

    [db beginTransaction];
    NSString *userWorkoutPlanDeleteSQL = [NSString stringWithFormat: @"DELETE FROM UserWorkoutPlan WHERE WorkoutUserDateID = %i", userDateID.intValue];
    [db executeUpdate:userWorkoutPlanDeleteSQL];

    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }

    [db commit];
}

-(void)saveDeletedExerciseToDb:(int)workoutTempId UserId:(int)userId WorkoutUserDateID:(int)workoutUserDateID {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    
    [db beginTransaction];
    
    NSString * insertSQL = [NSString stringWithFormat: @"REPLACE INTO DeleteWorkoutTemplate (WorkoutTemplateId,UserId,WorkoutUserDateID) VALUES(\"%d\",\"%d\",\"%d\")",workoutTempId,userId,workoutUserDateID];
    
    [db executeUpdate:insertSQL];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
    //DMLog(@"%@",[self loadDeletedExerciseFromDb]);
}

-(NSMutableArray *)loadDeletedExerciseFromDb {
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    
    [db beginTransaction];
    NSString *getWeightSQL = [NSString stringWithFormat:@"SELECT * FROM DeleteWorkoutTemplate"];
    FMResultSet *rs = [db executeQuery:getWeightSQL];
    
    while ([rs next]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        int WorkoutTemplateId = [rs intForColumn:@"WorkoutTemplateId"];
        int UserId = [rs intForColumn:@"UserId"];
        int WorkoutUserDateID = [rs intForColumn:@"WorkoutUserDateID"];

        [dict setObject: [NSNumber numberWithInt:WorkoutTemplateId]  forKey: @"WorkoutTemplateId"];
        [dict setObject: [NSNumber numberWithInt:UserId]  forKey: @"UserId"];
        [dict setObject: [NSNumber numberWithInt:WorkoutUserDateID]  forKey: @"WorkoutUserDateID"];

        [arr addObject:dict];
    }
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
    return arr;
}

-(void)saveWorkoutDetailToDb:(NSArray *)dataArr {
    if ([dataArr count] != 0)
    {
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        
        FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
        if (![db open]) {
        }
        
        [db beginTransaction];
        
        NSString * deleteSQL = [NSString stringWithFormat: @"DELETE FROM workout"];
        
        [db executeUpdate:deleteSQL];
        
        
        if ([dataArr count] != 0)
        {
            for (NSDictionary*exerciseDict in dataArr) {
                
                NSArray* workoutArr = [[NSArray alloc]initWithArray:exerciseDict[@"workout"]];
                
                for (NSDictionary*dict in workoutArr) {
                    
                    int  WorkoutTemplateIdID = [exerciseDict[@"WorkoutTemplateId"] integerValue];
                    int  WorkoutUserDateID = [exerciseDict[@"WorkoutUserDateID"] integerValue];
                    int  WorkoutMethodID = [dict[@"WorkoutMethodID"] integerValue];
                    int  WorkoutMethodValueID = [dict[@"WorkoutMethodValueID"] integerValue];
                    int  P1Number = [dict[@"P1Number"] integerValue];
                    int  TableP2ID = [dict[@"TableP2ID"] integerValue];
                    NSString * TableP2Name = dict[@"TableP2Name"];
                    int  P2Value = [dict[@"P2Value"] integerValue];
                    int  TableP3ID = [dict[@"TableP3ID"] integerValue];
                    NSString * TableP3Name = dict[@"TableP3Name"];
                    int  P3Value = [dict[@"P3Value"] integerValue];
                    NSString * ToBeAdded = @"no";
                    NSString * isEdited = @"no";
                    NSString * isDeleted = @"no";
                    
                    NSString * insertSQL = [NSString stringWithFormat: @"REPLACE INTO workout (WorkoutTemplateId,WorkoutMethodID,WorkoutMethodValueID,P1Number,TableP2ID,TableP2Name,P2Value,TableP3ID,TableP3Name,P3Value,ToBeAdded,isEdited,isDeleted,WorkoutUserDateID) VALUES(\"%d\",\"%d\",\"%d\",\"%d\",\"%d\",\"%@\",\"%d\",\"%d\",\"%@\",\"%d\",\"%@\",\"%@\",\"%@\",\"%d\")",WorkoutTemplateIdID,WorkoutMethodID,WorkoutMethodValueID,P1Number,TableP2ID,TableP2Name,P2Value,TableP3ID,TableP3Name,P3Value,ToBeAdded,isEdited,isDeleted, WorkoutUserDateID];
                    
                    [db executeUpdate:insertSQL];
                    [db commit];
                }
            }
            
            if ([db hadError]) {
                DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
        }
    }
}

- (NSArray *)loadWorkoutFromDb {
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    
    if (![db open]) {
    }
    
    [db beginTransaction];
    NSString *getWeightSQL = [NSString stringWithFormat:@"SELECT * FROM workout"];
    FMResultSet *rs = [db executeQuery:getWeightSQL];
    
    while ([rs next]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        int WorkoutUserDateID = [rs intForColumn:@"WorkoutUserDateID"];
        int WorkoutMethodID = [rs intForColumn:@"WorkoutMethodID"];
        int WorkoutMethodValueID = [rs intForColumn:@"WorkoutMethodValueID"];
        int P1Number = [rs intForColumn:@"P1Number"];
        int TableP2ID = [rs intForColumn:@"TableP2ID"];
        int P2Value = [rs intForColumn:@"P2Value"];
        int TableP3ID = [rs intForColumn:@"TableP3ID"];
        int P3Value = [rs intForColumn:@"P3Value"];

        NSString * TableP2Name = [NSString stringWithFormat:@"%d", [rs intForColumn:@"TableP2Name"]];
        NSString * TableP3Name = [NSString stringWithFormat:@"%d", [rs intForColumn:@"TableP3Name"]];
        NSString * isDeleted = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"isDeleted"]];
        [dict setObject: isDeleted  forKey: @"isDeleted"];

        [dict setObject: [NSNumber numberWithInt:WorkoutUserDateID]  forKey: @"WorkoutUserDateID"];
        [dict setObject: [NSNumber numberWithInt:WorkoutMethodID]  forKey: @"WorkoutMethodID"];
        [dict setObject: [NSNumber numberWithInt:WorkoutMethodValueID]  forKey: @"WorkoutMethodValueID"];
        [dict setObject: [NSNumber numberWithInt:P1Number]  forKey: @"P1Number"];
        [dict setObject: [NSNumber numberWithInt:TableP2ID]  forKey: @"TableP2ID"];
        [dict setObject: [NSNumber numberWithInt:P2Value]  forKey: @"P2Value"];
        [dict setObject: [NSNumber numberWithInt:TableP3ID]  forKey: @"TableP3ID"];
        [dict setObject: TableP2Name  forKey: @"TableP2Name"];
        [dict setObject: TableP3Name  forKey: @"TableP3Name"];
        [dict setObject: [NSNumber numberWithInt:P3Value]  forKey: @"P3Value"];

        [arr addObject:dict];
    }
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
    
    return [arr copy];
}

- (NSArray *)loadExerciseFromDb {
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    
    if (![db open]) {
    }
    
    [db beginTransaction];
        
         NSString *workoutSql = [NSString stringWithFormat:@"SELECT * FROM UserWorkoutPlan"];
         FMResultSet *rs = [db executeQuery:workoutSql];
    
         while ([rs next]) {
             NSMutableDictionary *dict = [NSMutableDictionary dictionary];

             int UserID = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userid_dietmastergo"] integerValue];
             int WorkoutUserID = [rs intForColumn:@"WorkoutUserID"];
             
             NSString * strTempName = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"TemplateName"]];
             NSString * strWorkoutTempId = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"WorkoutDate"]];
             int WorkoutTemplateId =  [rs intForColumn:@"WorkoutTemplateId"];
             int workoutDateId =  [rs intForColumn:@"WorkoutUserDateID"];
             int CategoryID =  [rs intForColumn:@"CategoryID"];
             NSString * CategoryName = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"CategoryName"]];
             int WorkoutID = [rs intForColumn:@"WorkoutID"];
             NSString * ExerciseName = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"ExerciseName"]];
             NSString * SessionNotes = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"SessionNotes"]];
             NSString * ExerciseNotes = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"ExerciseNotes"]];
             NSString * VideoURL = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"VideoURL"]];
             
             NSString * currentDuration = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"CurrentDuration"]];
             NSString * workingStatus = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"WorkingStatus"]];
             NSString * comments = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"Comments"]];
             
             NSString * ToBeAdded = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"ToBeAdded"]];

             NSString * isCommented = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"isCommented"]];

             NSString * isStatusUpdated = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"isStatusUpdated"]];
             
             
             int processID = [rs intForColumn:@"ProcessID"];
             int tagsId = [rs intForColumn:@"TagsId"];
             NSString * tags = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"Tags"]];

             [dict setObject: isStatusUpdated  forKey: @"isStatusUpdated"];
             [dict setObject: isCommented  forKey: @"isCommented"];
             [dict setObject: ToBeAdded  forKey: @"ToBeAdded"];
             [dict setObject: [NSNumber numberWithInt:WorkoutUserID]  forKey: @"WorkoutUserID"];
             [dict setObject: [NSNumber numberWithInt:UserID]  forKey: @"UserID"];
             [dict setObject: strTempName  forKey: @"TemplateName"];
             [dict setObject: strWorkoutTempId  forKey: @"WorkoutDate"];
             [dict setObject: [NSNumber numberWithInt:WorkoutTemplateId]  forKey: @"WorkoutTemplateId"];
             [dict setObject: [NSNumber numberWithInt:workoutDateId]  forKey: @"WorkoutUserDateID"];
             [dict setObject: [NSNumber numberWithInt:CategoryID]  forKey: @"CategoryID"];
             [dict setObject: CategoryName  forKey: @"CategoryName"];
             [dict setObject: [NSNumber numberWithInt:WorkoutID]  forKey: @"WorkoutID"];
             [dict setObject: ExerciseName  forKey: @"ExerciseName"];
             [dict setObject: SessionNotes  forKey: @"SessionNotes"];
             [dict setObject: ExerciseNotes  forKey: @"ExerciseNotes"];
             [dict setObject: VideoURL  forKey: @"VideoURL"];
             [dict setObject: currentDuration  forKey: @"CurrentDuration"];
             [dict setObject: workingStatus  forKey: @"WorkingStatus"];
             [dict setObject: comments  forKey: @"Comments"];
             [dict setObject: [NSNumber numberWithInt:processID]  forKey: @"ProcessID"];
             [dict setObject: [NSNumber numberWithInt:tagsId]  forKey: @"TagsId"];
             [dict setObject: tags  forKey: @"Tags"];
             
             
             [arr addObject:dict];
         }
    
         if ([db hadError]) {
             DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
         }
    
         [db commit];
    
    NSSet * setForArr = [[NSMutableSet alloc] initWithArray:arr];
    NSMutableArray *exerArr = [[NSMutableArray alloc]initWithArray:[setForArr allObjects]];
    
    return [exerArr copy];
}

#pragma mark Sets for my moves

-(void)updateSetsForExercise:(int)WorkoutTemplateId Dict:(NSDictionary *)dict
{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    
    [db beginTransaction];
    
    int P2Value  = [dict[@"P2Value"] integerValue];
    int P3Value  = [dict[@"P3Value"] integerValue];
    int P1Number = [dict[@"P1Number"] integerValue];

    int  WorkoutMethodValueID = [dict[@"WorkoutMethodValueID"] integerValue];
    NSString * isEdited = @"yes";

    NSString *updateComments = [NSString stringWithFormat: @"UPDATE workout SET P2Value = '%d',P3Value = '%d',isEdited = '%@' WHERE WorkoutMethodValueID = '%d' AND P1Number = '%d'",P2Value,P3Value,isEdited,WorkoutMethodValueID,P1Number];
    
    [db executeUpdate:updateComments];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
}

-(void)deleteSetsFromDB:(int)WorkoutMethodValueID
{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    
    [db beginTransaction];
    
    NSString *updateSQL = [NSString stringWithFormat: @"UPDATE workout SET isDeleted = 'yes' WHERE WorkoutMethodValueID = '%d'",WorkoutMethodValueID];
    
    [db executeUpdate:updateSQL];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
    
}

-(NSMutableArray *)loadSetsToBeDeletedFromDb {
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    
    if (![db open]) {
    }
    
    [db beginTransaction];
    NSString *getWeightSQL = [NSString stringWithFormat:@"SELECT * FROM workout WHERE isDeleted = 'yes'"];
    FMResultSet *rs = [db executeQuery:getWeightSQL];
    
    while ([rs next]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        int WorkoutMethodID = [rs intForColumn:@"WorkoutMethodValueID"];
        
        [dict setObject: [NSNumber numberWithInt:WorkoutMethodID]  forKey: @"WorkoutMethodValueID"];
        
        
        if (WorkoutMethodID == 0)
        {
            
        }
        else
        {
            [arr addObject:dict];
        }
    }
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
    return arr;
}

-(NSMutableArray *)loadSetsToBeUpdatedFromDb
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    
    if (![db open]) {
    }
    
    [db beginTransaction];
    NSString *getWeightSQL = [NSString stringWithFormat:@"SELECT * FROM workout WHERE isEdited = 'yes'"];
    FMResultSet *rs = [db executeQuery:getWeightSQL];
    
    while ([rs next]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        int WorkoutMethodID = [rs intForColumn:@"WorkoutMethodValueID"];
        int P1Number = [rs intForColumn:@"P1Number"];
        int P2Value = [rs intForColumn:@"P2Value"];
        int P3Value = [rs intForColumn:@"P3Value"];
        
        [dict setObject: [NSNumber numberWithInt:WorkoutMethodID]  forKey: @"WorkoutMethodValueID"];
        [dict setObject: [NSNumber numberWithInt:P1Number]  forKey: @"P1Number"];
        [dict setObject: [NSNumber numberWithInt:P2Value]  forKey: @"P2Value"];
        [dict setObject: [NSNumber numberWithInt:P3Value]  forKey: @"P3Value"];
        
        if (WorkoutMethodID == 0)
        {
            
        }
        else
        {
            [arr addObject:dict];
        }
    }
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
    return arr;
}

-(NSMutableArray *)loadSetsToBeAddedFromDb
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    
    if (![db open]) {
    }
    
    [db beginTransaction];
    NSString *getWeightSQL = [NSString stringWithFormat:@"SELECT * FROM workout WHERE ToBeAdded = 'yes'"];
    FMResultSet *rs = [db executeQuery:getWeightSQL];
    
    while ([rs next]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        int WorkoutMethodID = [rs intForColumn:@"WorkoutMethodID"];
        int P1Number = [rs intForColumn:@"P1Number"];
        int P2Value = [rs intForColumn:@"P2Value"];
        int P3Value = [rs intForColumn:@"P3Value"];
       
        
        [dict setObject: [NSNumber numberWithInt:WorkoutMethodID]  forKey: @"WorkoutMethodID"];
        [dict setObject: [NSNumber numberWithInt:P1Number]  forKey: @"P1Number"];
        [dict setObject: [NSNumber numberWithInt:P2Value]  forKey: @"P2Value"];
        [dict setObject: [NSNumber numberWithInt:P3Value]  forKey: @"P3Value"];
        
        if (WorkoutMethodID != 0) {
            [arr addObject:dict];
        }
    }
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
    return arr;
}

- (void)addExerciseSet:(DMMoveSet *)moveSet toRoutine:(DMMoveRoutine *)routine {
    if (!moveSet || !routine) {
        return;
    }
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
        return;
    }
    
    [db beginTransaction];
    
//    int P1Number = [dict[@"P1Number"] integerValue];
//    int P2Value = [dict[@"P2Value"] integerValue];
//    int P3Value = [dict[@"P3Value"] integerValue];
//
//    //    int  WorkoutTemplateIdID = WorkoutUserDateId;
//        int  WorkoutTemplateIdID = 0;
//    int  WorkoutUserDateID = [dict[@"WorkoutUserDateID"] integerValue];
//    int  WorkoutMethodID = [dict[@"WorkoutMethodID"] integerValue];
//    int  workoutUserDateID = [dict[@"WorkoutUserDateID"] integerValue];
//    int  WorkoutMethodValueID = [dict[@"WorkoutMethodValueID"] integerValue];
//
//    int  TableP2ID = [dict[@"TableP2ID"] integerValue];
//    NSString * TableP2Name = dict[@"TableP2Name"];
//    int  TableP3ID = [dict[@"TableP3ID"] integerValue];
//    NSString * TableP3Name = dict[@"TableP3Name"];
//    NSString * ToBeAdded = @"yes";
//    NSString * isEdited = @"no";
//    NSString * isDeleted = @"no";
//
//    NSString * insertSQL = [NSString stringWithFormat: @"REPLACE INTO workout (WorkoutTemplateId,WorkoutMethodID,WorkoutMethodValueID,P1Number,TableP2ID,TableP2Name,P2Value,TableP3ID,TableP3Name,P3Value,ToBeAdded,isEdited,isDeleted,WorkoutUserDateID) VALUES(\"%d\",\"%d\",\"%d\",\"%d\",\"%d\",\"%@\",\"%d\",\"%d\",\"%@\",\"%d\",\"%@\",\"%@\",\"%@\",\"%d\")",WorkoutTemplateIdID,WorkoutMethodID,WorkoutMethodValueID,P1Number,TableP2ID,TableP2Name,P2Value,TableP3ID,TableP3Name,P3Value,ToBeAdded,isEdited,isDeleted,WorkoutUserDateId];
//
//    [db executeUpdate:insertSQL];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
}

- (NSMutableArray *)filterObjectsByKeys:(NSString *)key array:(NSArray *)array {
    NSMutableSet *tempValues = [[NSMutableSet alloc] init];
    NSMutableArray *ret = [NSMutableArray array];
    for (id obj in array) {
        if(![tempValues containsObject:obj[key]]) {
            [tempValues addObject:obj[key]];
            [ret addObject:obj];
        }
    }
    return ret;
}

- (void)getMyMovesData {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *authString = [NSString stringWithFormat:@"%@:%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"username_dietmastergo"], [prefs valueForKey:@"authkey_dietmastergo"]];
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.dmwebpro.com/MyMoves/GetMoves/%i/true", [[prefs valueForKey:@"companyid_dietmastergo"] intValue]]; //change FALSE to TRUE to include all moves
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"mobile" forHTTPHeaderField:@"DMSource"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"*/*" forHTTPHeaderField:@"Accept"];
    
    NSData *nsdata = [authString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
    [request addValue:base64Encoded forHTTPHeaderField:@"Authorization"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *repsone, NSData *data, NSError *connectionError) {
        if (connectionError) {
            DMLog(@"Error fetching: %@", connectionError.localizedDescription);
        }
        if (data.length > 0 && !connectionError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *jsonError;
                NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                if (jsonError) {
                    DMLog(@"Error with JSON: %@", connectionError.localizedDescription);
                    return;
                }
                DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
                FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
                if (![db open]) {
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
            });
        }
    }];
}

@end
