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

@interface MyMovesWebServices()

@property (nonatomic, strong) NSMutableData *webData;
@property (nonatomic, strong) NSMutableString *soapResults;
@property (nonatomic, strong) NSXMLParser *xmlParser;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSString *apiRequestType;
@property (nonatomic) BOOL myBool;

@end

@implementation MyMovesWebServices

- (void)offlineSyncApi {
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *AuthHash = [prefs valueForKey:@"authkey_dietmastergo"];

        DietmasterEngine *engine = [DietmasterEngine sharedInstance];
        _myBool =  engine.sendAllServerData;
        
        NSMutableArray *mobileUserPlanListArr = [[NSMutableArray alloc] initWithArray:[self MobileUserPlanList]];
        
        NSMutableArray *mobileUserPlanDateListArr = [[NSMutableArray alloc] initWithArray:[self MobileUserPlanDateList]];
        
        NSMutableArray *MobileUserPlanMoveListArr = [[NSMutableArray alloc] initWithArray:[self MobileUserPlanMoveList]];
        
        NSMutableArray *MobileUserPlanMoveSetListArr = [[NSMutableArray alloc] initWithArray:[self MobileUserPlanMoveSetList]];
              
        NSDictionary *requestDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     AuthHash, @"AuthHash",
                                     [NSNumber numberWithBool:YES], @"SendAllServerData",
                                     nil];
        
        __block NSMutableDictionary *resultsDictionary;
        if ([NSJSONSerialization isValidJSONObject:requestDict]) {//validate it
            NSError* error;
            NSData* jsonData = [NSJSONSerialization dataWithJSONObject:requestDict options:NSJSONWritingPrettyPrinted error: &error];
            NSURL* url = [NSURL URLWithString:@"https://dmwebpro.com/MobileAPI/SyncUser"];
            NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:jsonData];
            __block NSError *error1 = [[NSError alloc] init];

            [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse* response,NSData* data,NSError* error)
             {
                 if ([data length] && error == nil) {
                     resultsDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error1];
                    
                     [self clearTableDataS];
                     [self serverUserPlans:resultsDictionary];
                     [self.WSGetUserWorkoutplanOfflineDelegate getUserWorkoutplanOfflineListFinished:resultsDictionary];
                     [self updateFromNewToNormalToDb];
                     [self updateFromChangedToNormalToDb];
                   
                     DietmasterEngine *engine = [DietmasterEngine sharedInstance];
                     engine.sendAllServerData = false;
                 }
             }];
        }
    }];
    [operationQueue addOperation:blockOperation];
}

-(void)clearTableData
{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
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
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
    
}

//new API
- (NSMutableArray *)MobileUserPlanList
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    
    if (![db open]) {
    }
    
    [db beginTransaction];
    
    NSString *addSql = [NSString stringWithFormat:@"SELECT * FROM ServerUserPlanList WHERE Status = 'Deleted'"];
    FMResultSet *rs = [db executeQuery:addSql];
    
    while ([rs next]) {
     
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
      
        int planID    =  [rs intForColumn:@"PlanID"];
        int userID    =  [rs intForColumn:@"UserID"];
        NSString * planName = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"PlanName"]];
        NSString * notes = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"Notes"]];
        NSString * lastUpdated = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"LastUpdated"]];
        NSString * uniqueID = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"UniqueID"]];
        NSString * status = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"Status"]];
        NSString * userPlanDates = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"UserPlanDates"]];
        NSString * syncResult = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"SyncResult"]];

        [dict setObject: [NSNumber numberWithInt:planID]  forKey: @"PlanID"];
        [dict setObject: [NSNumber numberWithInt:userID]  forKey: @"UserID"];
        [dict setObject: planName  forKey: @"PlanName"];
        [dict setObject: notes  forKey: @"Notes"];
        [dict setObject: lastUpdated  forKey: @"LastUpdated"];
        [dict setObject: uniqueID  forKey: @"UniqueID"];
        [dict setObject: status  forKey: @"Status"];
        [dict setObject: userPlanDates  forKey: @"UserPlanDates"];
        [dict setObject: syncResult  forKey: @"SyncResult"];

        [arr addObject:dict];
    }
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
 
    return arr;
}

//new API
- (NSMutableArray *)MobileUserPlanDateList
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    
    if (![db open]) {
    }
    
    [db beginTransaction];
    NSString * Status = @"New";
//    NSString *workoutSql = [NSString stringWithFormat:@"SELECT * FROM ServerUserPlanDateList WHERE Status = 'New'"];
    NSString *workoutSql = [NSString stringWithFormat:@"SELECT * FROM ServerUserPlanDateList WHERE Status = 'Deleted'"];
    FMResultSet *rs = [db executeQuery:workoutSql];
    
    while ([rs next]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        int UserPlanDateID = [rs intForColumn:@"UserPlanDateID"];
        int PlanID = [rs intForColumn:@"PlanID"];
        
        NSString * PlanDate = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"PlanDate"]];
        NSString * LastUpdated = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"LastUpdated"]];
        NSString * UniqueID = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"UniqueID"]];
        NSString * Status = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"Status"]];
        NSString * SyncResult = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"SyncResult"]];
        NSString * ParentUniqueID = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"ParentUniqueID"]];
        NSString * UserPlanMoves = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"UserPlanMoves"]];
        
        [dict setObject: [NSNumber numberWithInt:UserPlanDateID]  forKey: @"UserPlanDateID"];
        [dict setObject: [NSNumber numberWithInt:PlanID]  forKey: @"PlanID"];
        [dict setObject: PlanDate  forKey: @"PlanDate"];
        [dict setObject: LastUpdated  forKey: @"LastUpdated"];
        [dict setObject: UniqueID  forKey: @"UniqueID"];
        [dict setObject: Status  forKey: @"Status"];
        [dict setObject: SyncResult  forKey: @"SyncResult"];
        [dict setObject: ParentUniqueID  forKey: @"ParentUniqueID"];
        [dict setObject: UserPlanMoves  forKey: @"UserPlanMoves"];

        
        [arr addObject:dict];
    }
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
    
    return arr;
}

//new API
- (NSMutableArray *)MobileUserPlanMoveList
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
           DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
     FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
     
     if (![db open]) {
     }
     
    [db beginTransaction];
    
    NSString *deleteMoveSql = [NSString stringWithFormat:@"SELECT * FROM ServerUserPlanMoveList WHERE Status = 'Deleted'"];
    FMResultSet *result = [db executeQuery:deleteMoveSql];
    
    while ([result next]) {
        NSMutableDictionary *deletedDict = [NSMutableDictionary dictionary];
        
        int UserPlanMoveID = [result intForColumn:@"UserPlanMoveID"];
        int UserPlanDateID = [result intForColumn:@"UserPlanDateID"];
        int MoveID = [result intForColumn:@"MoveID"];
        
        NSString * MoveName = [NSString stringWithFormat:@"%@", [result stringForColumn:@"MoveName"]];
        NSString * VideoLink = [NSString stringWithFormat:@"%@", [result stringForColumn:@"VideoLink"]];
        NSString * Notes = [NSString stringWithFormat:@"%@", [result stringForColumn:@"Notes"]];
        NSString * LastUpdated = [NSString stringWithFormat:@"%@", [result stringForColumn:@"LastUpdated"]];
        NSString * UniqueID = [NSString stringWithFormat:@"%@", [result stringForColumn:@"UniqueID"]];
        NSString * Status = [NSString stringWithFormat:@"%@", [result stringForColumn:@"Status"]];
        NSString * SyncResult = [NSString stringWithFormat:@"%@", [result stringForColumn:@"SyncResult"]];
        NSString * ParentUniqueID = [NSString stringWithFormat:@"%@", [result stringForColumn:@"ParentUniqueID"]];
        NSString * UserPlanMoveSets = [NSString stringWithFormat:@"%@", [result stringForColumn:@"UserPlanMoveSets"]];
        
        [deletedDict setObject: [NSNumber numberWithInt:UserPlanMoveID]  forKey: @"UserPlanMoveID"];
        [deletedDict setObject: [NSNumber numberWithInt:UserPlanDateID]  forKey: @"UserPlanDateID"];
        [deletedDict setObject: [NSNumber numberWithInt:MoveID]  forKey: @"MoveID"];
        
        [deletedDict setObject: MoveName  forKey: @"MoveName"];
        [deletedDict setObject: VideoLink  forKey: @"VideoLink"];
        [deletedDict setObject: Notes  forKey: @"Notes"];
        [deletedDict setObject: LastUpdated  forKey: @"LastUpdated"];
        [deletedDict setObject: UniqueID  forKey: @"UniqueID"];
        [deletedDict setObject: Status  forKey: @"Status"];
        [deletedDict setObject: SyncResult  forKey: @"SyncResult"];
        [deletedDict setObject: ParentUniqueID  forKey: @"ParentUniqueID"];
        [deletedDict setObject: UserPlanMoveSets  forKey: @"UserPlanMoveSets"];
        
        [arr addObject:deletedDict];
    }
    
     if ([db hadError]) {
     DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
     }
     
     [db commit];
    
    return arr;
}

//new API
- (NSMutableArray *)MobileUserPlanMoveSetList
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    
    if (![db open]) {
    }
    
    [db beginTransaction];
    
    NSString *setDeleteddSql = [NSString stringWithFormat:@"SELECT * FROM ServerUserPlanMoveSetList WHERE Status = 'Deleted'"];
    FMResultSet *deleteResult = [db executeQuery:setDeleteddSql];
    
    while ([deleteResult next]) {
        NSMutableDictionary *deleteDict = [NSMutableDictionary dictionary];
        
        int SetID = [deleteResult intForColumn:@"SetID"];
        int UserPlanMoveID = [deleteResult intForColumn:@"UserPlanMoveID"];
        int SetNumber = [deleteResult intForColumn:@"SetNumber"];
        int Unit1ID = [deleteResult intForColumn:@"Unit1ID"];
        int Unit1Value = [deleteResult intForColumn:@"Unit1Value"];
        int Unit2ID = [deleteResult intForColumn:@"Unit2ID"];
        int Unit2Value = [deleteResult intForColumn:@"Unit2Value"];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        NSDate *currentDate = [NSDate date];
        NSString *lastUpdated = [formatter stringFromDate:currentDate];
        
        
        NSString * Unit1Name = [NSString stringWithFormat:@"%@", [deleteResult stringForColumn:@"Unit1Name"]];
        NSString * Unit2Name = [NSString stringWithFormat:@"%@", [deleteResult stringForColumn:@"Unit2Name"]];
        //            NSString * LastUpdated = [NSString stringWithFormat:@"%@", [changeResult stringForColumn:@"LastUpdated"]];
        NSString * UniqueID = [NSString stringWithFormat:@"%@", [deleteResult stringForColumn:@"UniqueID"]];
        NSString * Status = [NSString stringWithFormat:@"%@", [deleteResult stringForColumn:@"Status"]];
        NSString * SyncResult = [NSString stringWithFormat:@"%@", [deleteResult stringForColumn:@"SyncResult"]];
        NSString * ParentUniqueID = [NSString stringWithFormat:@"%@", [deleteResult stringForColumn:@"ParentUniqueID"]];
        
        [deleteDict setObject: [NSNumber numberWithInt:SetID]  forKey: @"SetID"];
        [deleteDict setObject: [NSNumber numberWithInt:UserPlanMoveID]  forKey: @"UserPlanMoveID"];
        [deleteDict setObject: [NSNumber numberWithInt:SetNumber]  forKey: @"SetNumber"];
        [deleteDict setObject: [NSNumber numberWithInt:Unit1ID]  forKey: @"Unit1ID"];
        [deleteDict setObject: [NSNumber numberWithInt:Unit1Value]  forKey: @"Unit1Value"];
        [deleteDict setObject: [NSNumber numberWithInt:Unit2ID]  forKey: @"Unit2ID"];
        [deleteDict setObject: [NSNumber numberWithInt:Unit2Value]  forKey: @"Unit2Value"];
        
        [deleteDict setObject: Unit1Name  forKey: @"Unit1Name"];
        [deleteDict setObject: Unit2Name  forKey: @"Unit2Name"];
        [deleteDict setObject: lastUpdated  forKey: @"LastUpdated"];
        [deleteDict setObject: UniqueID  forKey: @"UniqueID"];
        [deleteDict setObject: Status  forKey: @"Status"];
        [deleteDict setObject: SyncResult  forKey: @"SyncResult"];
        [deleteDict setObject: ParentUniqueID  forKey: @"ParentUniqueID"];
        
        [arr addObject:deleteDict];
    }
     
     if ([db hadError]) {
     DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
     }
     
     [db commit];
    
    return arr;
}

//newAPI
-(void)serverUserPlans:(NSDictionary *)planListDict
{
    if (planListDict[@"ServerUserPlanList"] != [NSNull null])
    {
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        
        FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
        if (![db open]) {
        }
        [db beginTransaction];
        
        NSMutableArray * planArr = [[NSMutableArray alloc]init];
        
        [planArr addObjectsFromArray:planListDict[@"ServerUserPlanList"]];
        
        if ([planArr count] != 0)
        {
            for (NSDictionary*dict in planArr) {
                
                int planId = [dict[@"PlanID"] intValue];
                int userId = [dict[@"UserID"] intValue];

                NSString *planName = [[dict[@"PlanName"] stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *notes = [[dict[@"Notes"] stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
                NSArray *arr = [dict[@"LastUpdated"] componentsSeparatedByString:@"T"];
                NSString *dateString = [NSString stringWithFormat:@"%@T00:00:00",[arr objectAtIndex:0]];
                NSDate *date = [dateFormatter dateFromString:dateString];
                NSString * lastUpdated = [dateFormatter stringFromDate:date];
                
                NSString *uniqueId = dict[@"UniqueID"];
                NSString *status = dict[@"Status"];
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
    
    if (planListDict[@"ServerUserPlanDateList"] != [NSNull null])
    {
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        
        FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
        if (![db open]) {
        }
        [db beginTransaction];
        
        NSMutableArray * planDateListArr = [[NSMutableArray alloc]init];
        
        [planDateListArr addObjectsFromArray:planListDict[@"ServerUserPlanDateList"]];
        
        if ([planDateListArr count] != 0)
        {
            for (NSDictionary*dict in planDateListArr) {
               
                int userPlanDateID = [dict[@"UserPlanDateID"] intValue];
                int planId = [dict[@"PlanID"] intValue];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
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
                NSString *status = dict[@"Status"];
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
    
    if (planListDict[@"ServerUserPlanMoveList"] != [NSNull null])
    {
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        
        FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
        if (![db open]) {
        }
        [db beginTransaction];
        
        NSMutableArray * planMoveListArr = [[NSMutableArray alloc]init];
        
        [planMoveListArr addObjectsFromArray:planListDict[@"ServerUserPlanMoveList"]];
        
        if ([planMoveListArr count] != 0)
        {
            for (NSDictionary*dict in planMoveListArr) {
                
                int userPlanMoveId = [dict[@"UserPlanMoveID"] integerValue];
                int userPlanDateID = [dict[@"UserPlanDateID"] integerValue];
                int moveId = [dict[@"MoveID"] integerValue];
                
                NSString *moveName = dict[@"MoveName"];
                NSString *videoLink = dict[@"VideoLink"];
                NSString *notes = [[dict[@"Notes"] stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
                NSArray *arr = [dict[@"LastUpdated"] componentsSeparatedByString:@"T"];
                NSString *dateString = [NSString stringWithFormat:@"%@T00:00:00",[arr objectAtIndex:0]];
                NSDate *date = [dateFormatter dateFromString:dateString];
                NSString * lastUpdated = [dateFormatter stringFromDate:date];
                
                NSString *uniqueId = dict[@"UniqueID"];
                NSString *status = dict[@"Status"];
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
    if (planListDict[@"ServerUserPlanMoveSetList"] != [NSNull null])
    {
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        
        FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
        if (![db open]) {
        }
        [db beginTransaction];
        
        NSMutableArray * planMoveSetListArr = [[NSMutableArray alloc]init];
        [planMoveSetListArr addObjectsFromArray:planListDict[@"ServerUserPlanMoveSetList"]];
        
        if ([planMoveSetListArr count] != 0)
        {
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
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
                NSDate *currentDate = [NSDate date];
                NSString *dateStringS = [formatter stringFromDate:currentDate];
                NSArray *arrS = [dateStringS componentsSeparatedByString:@"T"];
                NSString *dt = [NSString stringWithFormat:@"%@T00:00:00",[arrS objectAtIndex:0]];
                NSDate *dateS = [formatter dateFromString:dt];
                NSString * lastUpdated = [formatter stringFromDate:dateS];

                
                NSString *uniqueId = dict[@"UniqueID"];
                NSString *status = dict[@"Status"];
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
    
    if (planListDict[@"ServerCustomMoveList"] != [NSNull null])
    {
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        
        FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
        if (![db open]) {
        }
        [db beginTransaction];
        
        NSMutableArray * customPlanMoveListArr = [[NSMutableArray alloc]init];
        
        [customPlanMoveListArr addObjectsFromArray:planListDict[@"ServerCustomMoveList"]];
        
        if ([customPlanMoveListArr count] != 0)
        {
            for (NSDictionary*dict in customPlanMoveListArr) {
                
                int moveId = [dict[@"MoveID"] intValue];
                int companyID = [dict[@"CompanyID"] intValue];

                NSString *moveName = dict[@"MoveName"];
                NSString *videoLink = dict[@"VideoLink"];
                NSString *notes = dict[@"Notes"];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
                NSArray *arr = [dict[@"LastUpdated"] componentsSeparatedByString:@"T"];
                NSString *dateString = [NSString stringWithFormat:@"%@T00:00:00",[arr objectAtIndex:0]];
                NSDate *date = [dateFormatter dateFromString:dateString];
                NSString * lastUpdated = [dateFormatter stringFromDate:date];
                
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

//new API
-(NSMutableArray *)loadUserPlanListFromDb
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    
    if (![db open]) {
    }
    
    [db beginTransaction];
    
    NSString *workoutSql = [NSString stringWithFormat:@"SELECT * FROM ServerUserPlanList"];
    FMResultSet *rs = [db executeQuery:workoutSql];
    
    while ([rs next]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        int PlanID = [rs intForColumn:@"PlanID"];
        int UserID = [rs intForColumn:@"UserID"];
        
        NSString * PlanName = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"PlanName"]];
        NSString * Notes = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"Notes"]];
        NSString * LastUpdated = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"LastUpdated"]];
        NSString * UniqueID = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"UniqueID"]];
        NSString * Status = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"Status"]];
        NSString * SyncResult = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"SyncResult"]];
        NSString * UserPlanDates = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"UserPlanDates"]];
        
        [dict setObject: [NSNumber numberWithInt:PlanID]  forKey: @"PlanID"];
        [dict setObject: [NSNumber numberWithInt:UserID]  forKey: @"UserID"];
        [dict setObject: PlanName  forKey: @"PlanName"];
        [dict setObject: Notes  forKey: @"Notes"];
        [dict setObject: LastUpdated  forKey: @"LastUpdated"];
        [dict setObject: UniqueID  forKey: @"UniqueID"];
        [dict setObject: Status  forKey: @"Status"];
        [dict setObject: SyncResult  forKey: @"SyncResult"];
        [dict setObject: UserPlanDates  forKey: @"UserPlanDates"];

        [arr addObject:dict];
    }
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
    
    NSSet * setForArr = [[NSMutableSet alloc] initWithArray:arr];
    NSMutableArray *userPlanListArr = [[NSMutableArray alloc]initWithArray:[setForArr allObjects]];
    
    return userPlanListArr;
}
//new API
-(NSMutableArray *)loadUserPlanDateListFromDb
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    
    if (![db open]) {
    }
    
    [db beginTransaction];
    
    NSString *workoutSql = [NSString stringWithFormat:@"SELECT * FROM ServerUserPlanDateList"];
    FMResultSet *rs = [db executeQuery:workoutSql];
    
    while ([rs next]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        int UserPlanDateID = [rs intForColumn:@"UserPlanDateID"];
        int PlanID = [rs intForColumn:@"PlanID"];

        NSString * PlanDate = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"PlanDate"]];
        NSString * LastUpdated = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"LastUpdated"]];
        NSString * UniqueID = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"UniqueID"]];
        NSString * Status = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"Status"]];
        NSString * SyncResult = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"SyncResult"]];
        NSString * ParentUniqueID = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"ParentUniqueID"]];
        NSString * UserPlanMoves = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"UserPlanMoves"]];

        
        [dict setObject: [NSNumber numberWithInt:UserPlanDateID]  forKey: @"UserPlanDateID"];
        [dict setObject: [NSNumber numberWithInt:PlanID]  forKey: @"PlanID"];
        [dict setObject: PlanDate  forKey: @"PlanDate"];
        [dict setObject: LastUpdated  forKey: @"LastUpdated"];
        [dict setObject: UniqueID  forKey: @"UniqueID"];
        [dict setObject: Status  forKey: @"Status"];
        [dict setObject: SyncResult  forKey: @"SyncResult"];
        [dict setObject: ParentUniqueID  forKey: @"ParentUniqueID"];
        [dict setObject: UserPlanMoves  forKey: @"UserPlanMoves"];

        [arr addObject:dict];
    }
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
    
    NSSet * setForArr = [[NSMutableSet alloc] initWithArray:arr];
    NSMutableArray *userPlanDateListArr = [[NSMutableArray alloc]initWithArray:[setForArr allObjects]];
    
    return userPlanDateListArr;
}
//new API
-(NSMutableArray *)loadUserPlanMoveListFromDb
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    
    if (![db open]) {
    }
    
    [db beginTransaction];
    
    NSString *workoutSql = [NSString stringWithFormat:@"SELECT * FROM ServerUserPlanMoveList"];
    FMResultSet *rs = [db executeQuery:workoutSql];
    
    while ([rs next]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
        int UserPlanMoveID = [rs intForColumn:@"UserPlanMoveID"];
        int UserPlanDateID = [rs intForColumn:@"UserPlanDateID"];
        int MoveID = [rs intForColumn:@"MoveID"];

        NSString * MoveName = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"MoveName"]];
        NSString * VideoLink = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"VideoLink"]];
        NSString * Notes = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"Notes"]];
        NSString * LastUpdated = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"LastUpdated"]];
        NSString * UniqueID = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"UniqueID"]];
        NSString * Status = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"Status"]];
        NSString * SyncResult = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"SyncResult"]];
        NSString * ParentUniqueID = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"ParentUniqueID"]];
        NSString * UserPlanMoveSets = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"UserPlanMoveSets"]];
        NSString * isCheckBoxClicked = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"isCheckBoxClicked"]];

        [dict setObject: [NSNumber numberWithInt:UserPlanMoveID]  forKey: @"UserPlanMoveID"];
        [dict setObject: [NSNumber numberWithInt:UserPlanDateID]  forKey: @"UserPlanDateID"];
        [dict setObject: [NSNumber numberWithInt:MoveID]  forKey: @"MoveID"];
        
        [dict setObject: MoveName  forKey: @"MoveName"];
        [dict setObject: VideoLink  forKey: @"VideoLink"];
        [dict setObject: Notes  forKey: @"Notes"];
        [dict setObject: LastUpdated  forKey: @"LastUpdated"];
        [dict setObject: UniqueID  forKey: @"UniqueID"];
        [dict setObject: Status  forKey: @"Status"];
        [dict setObject: SyncResult  forKey: @"SyncResult"];
        [dict setObject: ParentUniqueID  forKey: @"ParentUniqueID"];
        [dict setObject: UserPlanMoveSets  forKey: @"UserPlanMoveSets"];
        [dict setObject: isCheckBoxClicked  forKey: @"isCheckBoxClicked"];

        [arr addObject:dict];
    }
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
    
    NSSet * setForArr = [[NSMutableSet alloc] initWithArray:arr];
    NSMutableArray *userPlanMoveListArr = [[NSMutableArray alloc]initWithArray:[setForArr allObjects]];
    
    return userPlanMoveListArr;
}
//new API
- (NSMutableArray *)loadUserPlanMoveSetListFromDb
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    
    if (![db open]) {
    }
    
    [db beginTransaction];
    
    NSString *workoutSql = [NSString stringWithFormat:@"SELECT * FROM ServerUserPlanMoveSetList"];
    FMResultSet *rs = [db executeQuery:workoutSql];
    
    while ([rs next]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        int SetID = [rs intForColumn:@"SetID"];
        int UserPlanMoveID = [rs intForColumn:@"UserPlanMoveID"];
        int SetNumber = [rs intForColumn:@"SetNumber"];
        int Unit1ID = [rs intForColumn:@"Unit1ID"];
        int Unit1Value = [rs intForColumn:@"Unit1Value"];
        int Unit2ID = [rs intForColumn:@"Unit2ID"];
        int Unit2Value = [rs intForColumn:@"Unit2Value"];

        NSString * Unit1Name = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"Unit1Name"]];
        NSString * Unit2Name = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"Unit2Name"]];
        NSString * LastUpdated = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"LastUpdated"]];
        NSString * UniqueID = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"UniqueID"]];
        NSString * Status = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"Status"]];
        NSString * SyncResult = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"SyncResult"]];
        NSString * ParentUniqueID = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"ParentUniqueID"]];
        
        [dict setObject: [NSNumber numberWithInt:SetID]  forKey: @"SetID"];
        [dict setObject: [NSNumber numberWithInt:UserPlanMoveID]  forKey: @"UserPlanMoveID"];
        [dict setObject: [NSNumber numberWithInt:SetNumber]  forKey: @"SetNumber"];
        [dict setObject: [NSNumber numberWithInt:Unit1ID]  forKey: @"Unit1ID"];
        [dict setObject: [NSNumber numberWithInt:Unit1Value]  forKey: @"Unit1Value"];
        [dict setObject: [NSNumber numberWithInt:Unit2ID]  forKey: @"Unit2ID"];
        [dict setObject: [NSNumber numberWithInt:Unit2Value]  forKey: @"Unit2Value"];

        [dict setObject: Unit1Name  forKey: @"Unit1Name"];
        [dict setObject: Unit2Name  forKey: @"Unit2Name"];
        [dict setObject: LastUpdated  forKey: @"LastUpdated"];
        [dict setObject: UniqueID  forKey: @"UniqueID"];
        [dict setObject: Status  forKey: @"Status"];
        [dict setObject: SyncResult  forKey: @"SyncResult"];
        [dict setObject: ParentUniqueID  forKey: @"ParentUniqueID"];
        
        [arr addObject:dict];
    }
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
    
    NSSet * setForArr = [[NSMutableSet alloc] initWithArray:arr];
    NSMutableArray *userPlanMoveSetListArr = [[NSMutableArray alloc]initWithArray:[setForArr allObjects]];
    
    return userPlanMoveSetListArr;
}

//new API
-(NSMutableArray *)loadListOfMovesFromDb
{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    [db beginTransaction];
    
    NSString *getWeightSQL = [NSString stringWithFormat:@"SELECT * FROM MoveDetails"];
    FMResultSet *rs = [db executeQuery:getWeightSQL];
    
    NSMutableArray *listOfMoveArr = [[NSMutableArray alloc]init];
    
    while ([rs next]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        int WorkoutID = [rs intForColumn:@"moveID"];
        NSString * WorkoutName = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"moveName"]];
        
        NSArray *arrExercise = [WorkoutName componentsSeparatedByString:@"("];
        
        if ([WorkoutName containsString:@"("]) {
            WorkoutName = [NSString stringWithFormat:@"%@",[arrExercise objectAtIndex:0]];
        }
        
        NSString * Link = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"videoLink"]];
        NSString * Notes = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"notes"]];
        
        [dict setObject: [NSNumber numberWithInt:WorkoutID]  forKey: @"moveID"];
        
        [dict setObject: WorkoutName  forKey: @"moveName"];
        [dict setObject: Link  forKey: @"videoLink"];
        [dict setObject: Notes  forKey: @"notes"];
        
        [listOfMoveArr addObject:dict];
        
    }
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
    
    return listOfMoveArr;
}

//new API
-(void)clearTableDataS
{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    [db beginTransaction];
    
    NSString * deleteServerUserPlanList = [NSString stringWithFormat: @"DELETE FROM ServerUserPlanList WHERE Status = 'Deleted'"];
    
    [db executeUpdate:deleteServerUserPlanList];
   
    NSString * deleteServerUserPlanDateList = [NSString stringWithFormat: @"DELETE FROM ServerUserPlanDateList WHERE Status = 'Deleted'"];
    [db executeUpdate:deleteServerUserPlanDateList];
   
    NSString * deleteServerUserPlanMoveList = [NSString stringWithFormat: @"DELETE FROM ServerUserPlanMoveList WHERE Status = 'Deleted'"];
    [db executeUpdate:deleteServerUserPlanMoveList];
  
    NSString * deleteServerUserPlanMoveSetList = [NSString stringWithFormat: @"DELETE FROM ServerUserPlanMoveSetList WHERE Status = 'Deleted'"];
    [db executeUpdate:deleteServerUserPlanMoveSetList];

    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
}

-(void)clearedDataFromWeb:(NSString *)uniqueId
{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    [db beginTransaction];
    
    NSString * deleteServerUserPlanList = [NSString stringWithFormat: @"DELETE FROM ServerUserPlanList WHERE UniqueID = '%@'",uniqueId];
    
    [db executeUpdate:deleteServerUserPlanList];
    
    NSString * deleteServerUserPlanDateList = [NSString stringWithFormat: @"DELETE FROM ServerUserPlanDateList WHERE ParentUniqueID = '%@'",uniqueId];
    [db executeUpdate:deleteServerUserPlanDateList];
    
    NSString * deleteServerUserPlanDateLists = [NSString stringWithFormat: @"DELETE FROM ServerUserPlanDateList WHERE UniqueID = '%@'",uniqueId];
    [db executeUpdate:deleteServerUserPlanDateLists];

    NSString * deleteServerUserPlanMoveList = [NSString stringWithFormat: @"DELETE FROM ServerUserPlanMoveList WHERE UniqueID = '%@'",uniqueId];
    [db executeUpdate:deleteServerUserPlanMoveList];
    
    NSString * deleteServerUserPlanMoveSetList = [NSString stringWithFormat: @"DELETE FROM ServerUserPlanMoveSetList WHERE UniqueID = '%@'",uniqueId];
    [db executeUpdate:deleteServerUserPlanMoveSetList];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
}

-(void)updateFromNewToNormalToDb
{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    [db beginTransaction];
    
    NSString *normalStatus = @"Normal";
    NSString *newStatus = @"New";
   
    NSString * updateServerUserPlanList = [NSString stringWithFormat: @"UPDATE ServerUserPlanList SET Status = '%@' Where Status = '%@'",normalStatus,newStatus];
    [db executeUpdate:updateServerUserPlanList];
    
    NSString * updateServerUserPlanDateList = [NSString stringWithFormat: @"UPDATE ServerUserPlanDateList SET Status = '%@' Where Status = '%@'",normalStatus,newStatus];
    [db executeUpdate:updateServerUserPlanDateList];
    
    NSString * updateServerUserPlanMoveList = [NSString stringWithFormat: @"UPDATE ServerUserPlanMoveList SET Status = '%@' Where Status = '%@'",normalStatus,newStatus];
    [db executeUpdate:updateServerUserPlanMoveList];
    
    NSString * updateServerUserPlanMoveSetList = [NSString stringWithFormat: @"UPDATE ServerUserPlanMoveSetList SET Status = '%@' Where Status = '%@'",normalStatus,newStatus];
    [db executeUpdate:updateServerUserPlanMoveSetList];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
}

-(void)updateFromChangedToNormalToDb
{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    [db beginTransaction];
    
    NSString *normalStatus = @"Normal";
    NSString *changedStatus = @"Changed";
    
    NSString * updateServerUserPlanList = [NSString stringWithFormat: @"UPDATE ServerUserPlanList SET Status = '%@' Where Status = '%@'",normalStatus,changedStatus];
    [db executeUpdate:updateServerUserPlanList];
    
    NSString * updateServerUserPlanDateList = [NSString stringWithFormat: @"UPDATE ServerUserPlanDateList SET Status = '%@' Where Status = '%@'",normalStatus,changedStatus];
    [db executeUpdate:updateServerUserPlanDateList];
    
    NSString * updateServerUserPlanMoveList = [NSString stringWithFormat: @"UPDATE ServerUserPlanMoveList SET Status = '%@' Where Status = '%@'",normalStatus,changedStatus];
    [db executeUpdate:updateServerUserPlanMoveList];
    
    NSString * updateServerUserPlanMoveSetList = [NSString stringWithFormat: @"UPDATE ServerUserPlanMoveSetList SET Status = '%@' Where Status = '%@'",normalStatus,changedStatus];
    [db executeUpdate:updateServerUserPlanMoveSetList];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
}

-(void)updateChangesFromWeb:(NSString *)uniqueID
{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    [db beginTransaction];
    
    NSString *normalStatus = @"Normal";
    
    NSString * updateServerUserPlanList = [NSString stringWithFormat: @"UPDATE ServerUserPlanList SET Status = '%@' Where UniqueID = '%@'",normalStatus,uniqueID];
    [db executeUpdate:updateServerUserPlanList];
    
    NSString * updateServerUserPlanDateList = [NSString stringWithFormat: @"UPDATE ServerUserPlanDateList SET Status = '%@' Where UniqueID = '%@'",normalStatus,uniqueID];
    [db executeUpdate:updateServerUserPlanDateList];
    
    NSString * updateServerUserPlanMoveList = [NSString stringWithFormat: @"UPDATE ServerUserPlanMoveList SET Status = '%@' Where UniqueID = '%@'",normalStatus,uniqueID];
    [db executeUpdate:updateServerUserPlanMoveList];
    
    NSString * updateServerUserPlanMoveSetList = [NSString stringWithFormat: @"UPDATE ServerUserPlanMoveSetList SET Status = '%@' Where UniqueID = '%@'",normalStatus,uniqueID];
    [db executeUpdate:updateServerUserPlanMoveSetList];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
}

//new API
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
    DMLog(@"%@",arr);

    if ([arr count] != 0)
    {
        if ([planDateStr isEqualToString:arr[0][@"PlanDate"]])
        {

            NSString *UpdateSQL = [NSString stringWithFormat:@"UPDATE PlanDateUniqueID_Table SET UniqueID = %@ Where PlanDate = %@",PlanNameUnique,planDateStr];
            [db executeUpdate:UpdateSQL];

            NSString * insertSQL = [NSString stringWithFormat: @"INSERT INTO ServerUserPlanList (PlanName,Notes,LastUpdated,UniqueID,syncResult) VALUES (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",planName,notes,lastUpdated,arr[0][@"UniqueID"],syncResult];
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
            NSString * insertSQLite = [NSString stringWithFormat: @"INSERT INTO PlanDateUniqueID_Table (PlanDate,UniqueID) VALUES (\"%@\",\"%@\")",planDateStr,PlanNameUnique];
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

            NSString * insertSQL = [NSString stringWithFormat: @"INSERT INTO ServerUserPlanList (PlanName,Notes,LastUpdated,UniqueID,Status,syncResult) VALUES (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",planName,notes,lastUpdated,PlanNameUnique,status,syncResult];
            [db executeUpdate:insertSQL];
            [db commit];



            [self mobilePlanDateList:planDate DateUniqueID:DateListUnique Dict:setDict];
        }
    }
    else
    {
        NSString * insertSQLite = [NSString stringWithFormat: @"INSERT INTO PlanDateUniqueID_Table (PlanDate,UniqueID) VALUES (\"%@\",\"%@\")",planDateStr,PlanNameUnique];
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
        
        NSString * insertSQL = [NSString stringWithFormat: @"INSERT INTO ServerUserPlanList (PlanName,Notes,LastUpdated,UniqueID,Status,syncResult) VALUES (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",planName,notes,lastUpdated,PlanNameUnique,status,syncResult];
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

//new API
-(void)mobilePlanDateList:(NSDate *)planDate DateUniqueID:(NSString *)uniqueID Dict:(NSDictionary *)dict
{
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

    NSString * insertSQL = [NSString stringWithFormat: @"INSERT INTO ServerUserPlanDateList (PlanDate,LastUpdated,UniqueID,Status,SyncResult,ParentUniqueID) VALUES (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",planDateStr,lastUpdated,uniqueID,status,syncResult,parentUniqueId];

    [db executeUpdate:insertSQL];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
    
    [self mobilePlanMoveList:moveName VideoLink:videoUrl Notes:notes UniqueID:MoveNameUnique ParentUniqueID:DateListUnique MoveID:moveId PlanDateStr:planDateStr];

}

//new API
- (void)mobilePlanMoveList:(NSString *)MoveName VideoLink:(NSString *)VideoLink Notes:(NSString *)Notes UniqueID:(NSString *)UniqueID ParentUniqueID:(NSString *)ParentUniqueID MoveID:(int)MoveID PlanDateStr:(NSString *)PlanDateStr
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
    
    NSString * insertSQL = [NSString stringWithFormat: @"INSERT INTO PlanDateTable (PlanDate) VALUES (\"%@\")",PlanDateStr];

    [db executeUpdate:insertSQL];

    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];

        NSString * insertSQLite = [NSString stringWithFormat: @"INSERT INTO ServerUserPlanMoveList (MoveID,MoveName,VideoLink,Notes,LastUpdated,UniqueID,Status,SyncResult,ParentUniqueID,isCheckBoxClicked) VALUES (\"%d\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",MoveID,MoveName,VideoLink,Notes,lastUpdated,UniqueID,status,syncResult,ParentUniqueID,isCheckBoxClicked];
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

-(void)mobilePlanMoveSetList:(NSString *)ParentUniqueID setDict:(NSDictionary *)dict
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
    
    long setNumber = [dict[@"SetNumber"] integerValue];
    long unit1id = [dict[@"Unit1ID"] integerValue];
    long unit2id = [dict[@"Unit2ID"] integerValue];
    long unit1Value = [dict[@"Unit1Value"] integerValue];
    long unit2Value = [dict[@"Unit2Value"] integerValue];
    NSString *uniqueID = dict[@"UniqueID"];

    NSString * insertSQL = [NSString stringWithFormat: @"INSERT INTO ServerUserPlanMoveSetList (SetNumber,Unit1ID,Unit1Value,Unit2ID,Unit2Value,LastUpdated,UniqueID,Status,SyncResult,ParentUniqueID) VALUES (\"%ld\",\"%ld\",\"%ld\",\"%ld\",\"%ld\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",setNumber,unit1id,unit1Value,unit2id,unit2Value,lastUpdated,uniqueID,status,syncResult,ParentUniqueID];

    [db executeUpdate:insertSQL];

    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
}
-(void)mobilePlanMoveSetLists:(NSString *)ParentUniqueID
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
    
    NSString * insertSQL = [NSString stringWithFormat: @"INSERT INTO ServerUserPlanMoveSetList (SetNumber,Unit1ID,Unit1Value,Unit2ID,Unit2Value,LastUpdated,UniqueID,Status,SyncResult,ParentUniqueID) VALUES (\"%d\",\"%d\",\"%d\",\"%d\",\"%d\",\"%@\",\"%s\",\"%@\",\"%@\",\"%@\")",0,0,0,0,0,lastUpdated,"",status,syncResult,ParentUniqueID];
    
    [db executeUpdate:insertSQL];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
}
                                        

-(void)clearOfflineSynParamsDb
{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    [db beginTransaction];
    
    NSString * deleteSQL = [NSString stringWithFormat: @"DELETE FROM DeleteWorkoutTemplate"];
    [db executeUpdate:deleteSQL];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    NSString *updateEditedAddedSQL = [NSString stringWithFormat: @"UPDATE UserWorkoutPlan SET isEdited = 'no',ToBeAdded = 'no',isCommented = 'no',isStatusUpdated = 'no'"];
    
    [db executeUpdate:updateEditedAddedSQL];

    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    NSString *updateAddedSetSQL = [NSString stringWithFormat: @"UPDATE workout SET isEdited = 'no',ToBeAdded = 'no'"];
    
    [db executeUpdate:updateAddedSetSQL];
    
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
    [db beginTransaction];
    
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
    
    [db commit];
    
    return [tagArray copy];
}

- (NSArray<DMMoveCategory *> *)loadListOfBodyPart {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    [db beginTransaction];
    
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
    
    [db commit];
    
    return [categoriesArray copy];
}

- (NSArray<DMMove *> *)getMovesFromDatabaseWithCategoryFilter:(DMMoveCategory *)categoryFilter
                                                    tagFilter:(DMMoveTag *)tagFilter
                                                   textSearch:(NSString *)textSearch {
    DietmasterEngine *dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase *db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    [db beginTransaction];
    
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
    
    [db commit];
    
    return [movesArray copy];
}

-(NSMutableArray *)loadTable1Header
{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    [db beginTransaction];
    
    NSString *getWeightSQL = [NSString stringWithFormat:@"SELECT * FROM TableP1"];
    FMResultSet *rs = [db executeQuery:getWeightSQL];
    
    NSMutableArray *ListTable1 = [[NSMutableArray alloc]init];
    
    while ([rs next]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        int TableP1ID = [rs intForColumn:@"TableP1ID"];
        
        NSString * P1Text = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"P1Text"]];
        
        [dict setObject: [NSNumber numberWithInt:TableP1ID]  forKey: @"TableP1ID"];
        [dict setObject: P1Text  forKey: @"P1Text"];
        
        [ListTable1 addObject:dict];
    }
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
    
    return ListTable1;
}
-(NSMutableArray *)loadTable2Header
{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    [db beginTransaction];
    
    NSString *getWeightSQL = [NSString stringWithFormat:@"SELECT * FROM TableP2"];
    FMResultSet *rs = [db executeQuery:getWeightSQL];
    
    NSMutableArray *ListTable2 = [[NSMutableArray alloc]init];
    
    while ([rs next]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        int TableP2ID = [rs intForColumn:@"TableP2ID"];
        
        NSString * P2Text = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"P2Text"]];
        
        [dict setObject: [NSNumber numberWithInt:TableP2ID]  forKey: @"TableP2ID"];
        [dict setObject: P2Text  forKey: @"P2Text"];
        
        [ListTable2 addObject:dict];
    }
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
    
    return ListTable2;
}
#pragma mark Monthly Exercise
-(void)saveMonthlyExerciseToDb:(NSDictionary *)monthlyDict
{
    if (monthlyDict[@"UserWorkoutPlan"] != [NSNull null])
        {
            DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
            
            FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
            if (![db open]) {
            }
            [db beginTransaction];
            
            
            //        NSString * deleteSQL = [NSString stringWithFormat: @"DELETE FROM UserWorkoutPlan"];
            //        [db executeUpdate:deleteSQL];
            
            
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
                    
                    NSString * insertSQL = [NSString stringWithFormat: @"INSERT INTO UserWorkoutPlan (UserID,TemplateName,WorkoutDate,WorkoutTemplateId,CategoryID,CategoryName,WorkoutID,ExerciseName,SessionNotes,ExerciseNotes,VideoURL,CurrentDuration,WorkingStatus,Comments,ProcessID,TagsId,Tags,isEdited,WorkoutUserID,ToBeAdded,isCommented,isStatusUpdated,WorkoutUserDateID) VALUES(\"%d\",\"%@\",\"%@\",\"%d\",\"%d\",\"%@\",\"%d\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%d\",\"%d\",\"%@\",\"%@\",\"%d\",\"%@\",\"%@\",\"%@\",\"%d\")",UserID,tempName,workoutDate,workoutTempId,categoryId,categoryName,workoutId,exerciseName,sessionNotes,exerciseNotes,videoUrl,currentDuration,workingStatus,comments,processID,tagsId,tags,isEdited,WorkoutUserID,ToBeAdded,isCommented,isStatusUpdated,workOutUserDateID];
                    
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
    if (monthlyDict[@"TableP1"] != nil)
    {
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        
        FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
        if (![db open]) {
        }
        [db beginTransaction];
        
        
        NSString * deleteSQL = [NSString stringWithFormat: @"DELETE FROM TableP1"];
        [db executeUpdate:deleteSQL];
        
        
        NSMutableArray * monthlyArr = [[NSMutableArray alloc]init];
        [monthlyArr addObjectsFromArray:monthlyDict[@"TableP1"]];
        
        if ([monthlyArr count] != 0)
        {
            for (NSDictionary*dict in monthlyArr) {
                
                int TableP1ID = [dict[@"TableP1ID"] integerValue];
                
                NSString * P1Text = dict[@"P1Text"];
               
                
                NSString * insertSQL = [NSString stringWithFormat: @"INSERT INTO TableP1 (TableP1ID,P1Text) VALUES(\"%d\",\"%@\")",TableP1ID,P1Text];
                
                [db executeUpdate:insertSQL];
                if ([db hadError]) {
                    DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                }
                [db commit];
            }
        }
        
    }
    if (monthlyDict[@"TableP2"] != nil)
    {
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        
        FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
        if (![db open]) {
        }
        [db beginTransaction];
        
        
        NSString * deleteSQL = [NSString stringWithFormat: @"DELETE FROM TableP2"];
        [db executeUpdate:deleteSQL];
        
        
        NSMutableArray * monthlyArr = [[NSMutableArray alloc]init];
        [monthlyArr addObjectsFromArray:monthlyDict[@"TableP2"]];
        
        if ([monthlyArr count] != 0)
        {
            for (NSDictionary*dict in monthlyArr) {
                
                int TableP2ID = [dict[@"TableP2ID"] integerValue];
                
                NSString * P2Text = dict[@"P2Text"];
                
                
                NSString * insertSQL = [NSString stringWithFormat: @"INSERT INTO TableP2 (TableP2ID,P2Text) VALUES(\"%d\",\"%@\")",TableP2ID,P2Text];
                
                [db executeUpdate:insertSQL];
                if ([db hadError]) {
                    DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                }
                [db commit];
            }
        }
    }
    
}
-(void)updateFirstHeaderValue:(int)unit1ID ParentUniqueID:(NSString *)ParentUniqueID;
{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    [db beginTransaction];
    
    NSString *status = @"Changed";
    NSString *updateUnit1ID = [NSString stringWithFormat:@"UPDATE ServerUserPlanMoveSetList SET Unit1ID = '%d',Status = '%@' Where ParentUniqueID = '%@'",unit1ID,status,ParentUniqueID];
    
    [db executeUpdate:updateUnit1ID];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
}

-(void)updateSecondHeaderValue:(int)unit2ID ParentUniqueID:(NSString *)ParentUniqueID
{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    [db beginTransaction];
    
    NSString *status = @"Changed";
    NSString *updateUnit1ID = [NSString stringWithFormat:@"UPDATE ServerUserPlanMoveSetList SET Unit2ID = '%d',Status = '%@' Where ParentUniqueID = '%@'",unit2ID,status,ParentUniqueID];
    
    [db executeUpdate:updateUnit1ID];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
}

-(void)updateSetInFirstColumn:(int)unit1Value uniqueID:(NSString *)uniqueID
{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    [db beginTransaction];
    
    NSString *status = @"Changed";
    NSString *updateUnit1Value = [NSString stringWithFormat:@"UPDATE ServerUserPlanMoveSetList SET Unit1Value = '%d',Status = '%@' Where UniqueID = '%@'",unit1Value,status,uniqueID];
    
    [db executeUpdate:updateUnit1Value];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
}

-(void)updateSetInSecondColumn:(int)unit2Value uniqueID:(NSString *)uniqueID
{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    [db beginTransaction];
    
    NSString *status = @"Changed";
    NSString *updateUnit2Value = [NSString stringWithFormat:@"UPDATE ServerUserPlanMoveSetList SET Unit2Value = '%d',Status = '%@' Where UniqueID = '%@'",unit2Value,status,uniqueID];
    
    [db executeUpdate:updateUnit2Value];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
}



-(NSMutableArray *)loadFirstHeaderTable
{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    [db beginTransaction];
    
//    NSString *isPickerOpen = @"yes";
//    NSString *getWeightSQL = [NSString stringWithFormat:@"SELECT * FROM ServerUserPlanMoveSetList WHERE isPickerOpen = 'yes'"];
    NSString *getWeightSQL = [NSString stringWithFormat:@"SELECT * FROM ServerUserPlanMoveSetList"];
    FMResultSet *rs = [db executeQuery:getWeightSQL];
    
    NSMutableArray *ListTable1 = [[NSMutableArray alloc]init];
    
    while ([rs next]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        int Unit1ID = [rs intForColumn:@"Unit1ID"];
        
        NSString * Unit1Value = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"Unit1Value"]];
        
        [dict setObject: [NSNumber numberWithInt:Unit1ID]  forKey: @"Unit1ID"];
        [dict setObject: Unit1Value  forKey: @"Unit1Value"];
        
        [ListTable1 addObject:dict];
    }
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
    
    return ListTable1;
}
-(NSMutableArray *)loadSecondHeaderTable
{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    [db beginTransaction];
    
    NSString *getWeightSQL = [NSString stringWithFormat:@"SELECT * FROM ServerUserPlanMoveSetList"];
    FMResultSet *rs = [db executeQuery:getWeightSQL];
    
    NSMutableArray *ListTable2 = [[NSMutableArray alloc]init];
    
    while ([rs next]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        int Unit2ID = [rs intForColumn:@"Unit2ID"];
        
        NSString * Unit2Value = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"Unit2Value"]];
        
        [dict setObject: [NSNumber numberWithInt:Unit2ID]  forKey: @"Unit2ID"];
        [dict setObject: Unit2Value  forKey: @"Unit2Value"];
        
        [ListTable2 addObject:dict];
    }
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
    
    return ListTable2;
}

-(void)deleteMoveFromDb:(NSString *)UniqueID
{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    
    [db beginTransaction];
    
    NSString *status = @"Deleted";
    
//    NSString *userWorkoutPlanDeleteSQL = [NSString stringWithFormat: @"UPDATE ServerUserPlanMoveList SET Status = %@ WHERE UniqueID = %@",status,UniqueID];
    
    NSString *userWorkoutPlanDeleteSQL = [NSString stringWithFormat: @"UPDATE ServerUserPlanMoveList SET Status = '%@' Where UniqueID = '%@'",status,UniqueID];

    
    [db executeUpdate:userWorkoutPlanDeleteSQL];
    
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
    
}

-(void)deleteSetFromDb:(NSString *)UniqueID
{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    
    [db beginTransaction];
    
    NSString *status = @"Deleted";
    
    NSString *userWorkoutPlanDeleteSQL = [NSString stringWithFormat: @"UPDATE ServerUserPlanMoveSetList SET Status = '%@' Where UniqueID = '%@'",status,UniqueID];

    [db executeUpdate:userWorkoutPlanDeleteSQL];
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
    
}

-(void)updateCheckBoxStatusToDb:(NSString *)UniqueID checkBoxStatus:(NSString *)checkBoxStatus
{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    [db beginTransaction];
    
    NSString *updateCheckBoxStatus = [NSString stringWithFormat:@"UPDATE ServerUserPlanMoveList SET isCheckBoxClicked = '%@' Where UniqueID = '%@'",checkBoxStatus,UniqueID];
    
    [db executeUpdate:updateCheckBoxStatus];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
}
-(void)addExerciseToDb:(NSDictionary *)dict
           workoutDate:(NSDate*)date
                userId:(int)userID categoryName:(NSString*)name CategoryID:(int)categoryID tagsName:(NSString*)tag TagsId:(int)tagsId templateName:(NSString*)templateNameStr WorkoutDateID:(int)WorkoutDateID
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
//        int tagsId = tagsId;
        NSString * tags = tag;
        NSString * isEdited = @"no";
        NSString * comments = @"";
        NSString * ToBeAdded = @"yes";
        NSString * isCommented = @"no";
        NSString * isStatusUpdated = @"no";

    int workoutTempId = arc4random_uniform(1000000);

        NSString * insertSQL = [NSString stringWithFormat: @"INSERT INTO UserWorkoutPlan (UserID,TemplateName,WorkoutDate,WorkoutTemplateId,CategoryID,CategoryName,WorkoutID,ExerciseName,SessionNotes,ExerciseNotes,VideoURL,CurrentDuration,WorkingStatus,Comments,ProcessID,TagsId,Tags,isEdited,WorkoutUserID,ToBeAdded,isCommented,isStatusUpdated,WorkoutUserDateID) VALUES(\"%d\",\"%@\",\"%@\",\"%d\",\"%d\",\"%@\",\"%d\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%d\",\"%d\",\"%@\",\"%@\",\"%d\",\"%@\",\"%@\",\"%@\",\"%d\")",UserID,tempName,workoutDate,WorkoutDateID,categoryID,name,workoutId,exerciseName,sessionNotes,exerciseNotes,videoUrl,currentDuration,workingStatus,comments,processID,tagsId,tags,isEdited,WorkoutUserID,ToBeAdded,isCommented,isStatusUpdated,WorkoutDateID];

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
    
//    [self addSetsForExercise:workoutTempId Dict:setDict];
    [self addSetsForExercise:WorkoutDateID Dict:setDict];
}

-(void)updateUserCommentsToDb:(NSString *)exerciseDate commentsToUpdate:(NSString *)comments
{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    
    [db beginTransaction];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:exerciseDate];
    
    NSString *isCommented = @"yes";
    
    NSString*dateToUpdate = [dateFormatter stringFromDate:date];
    NSString *updateComments = [NSString stringWithFormat: @"UPDATE UserWorkoutPlan SET Comments = '%@',isCommented = '%@' WHERE WorkoutDate = '%@'",comments,isCommented,dateToUpdate];
    
    [db executeUpdate:updateComments];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
    
}
-(void)updateWorkoutToDb:(NSString *)exerciseDate
{
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
-(NSMutableArray *)loadUserComments
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    
    if (![db open]) {
    }
    
    [db beginTransaction];
    
    NSString * isCommented = @"yes";
    NSString *getWeightSQL = [NSString stringWithFormat:@"SELECT * FROM UserWorkoutPlan WHERE isCommented = '%@'",isCommented];
    FMResultSet *rs = [db executeQuery:getWeightSQL];
    
    while ([rs next]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        int UserID = [rs intForColumn:@"UserID"];
        
        NSString * WorkoutDate = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"WorkoutDate"]];
        NSString * Comments = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"Comments"]];
        
        [dict setObject: [NSNumber numberWithInt:UserID]  forKey: @"UserID"];
        
        [dict setObject: Comments  forKey: @"Comments"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        NSDate *date = [dateFormatter dateFromString:WorkoutDate];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];

        [dict setObject: [dateFormatter stringFromDate:date]  forKey: @"WorkoutDate"];
        
        [arr addObject:dict];
        
    }
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
    
    return arr;
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
//    int UserID = 10;
    
    NSString * WorkoutDate = dict[@"WorkoutDate"];

    NSString *updateComments = [NSString stringWithFormat: @"UPDATE UserWorkoutPlan SET WorkingStatus = '%@',CurrentDuration = '%@',ProcessID = '%d',UserID = '%d',isEdited = 'yes' WHERE WorkoutUserDateID = '%d'",WorkingStatus,CurrentDuration,ProcessID,UserID,WorkoutTemplateId];
    
    [db executeUpdate:updateComments];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
    
    DMLog(@"%@",[self loadWorkoutTime]);
}

-(NSMutableArray *)loadWorkoutTime
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    
    if (![db open]) {
    }
    
    [db beginTransaction];
    NSString *getWeightSQL = [NSString stringWithFormat:@"SELECT * FROM UserWorkoutPlan WHERE isEdited = 'yes'"];
    FMResultSet *rs = [db executeQuery:getWeightSQL];
    
    while ([rs next]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];

        int UserID = [rs intForColumn:@"UserID"];
        int WorkoutUserID = [rs intForColumn:@"WorkoutUserID"];
        int WorkoutProcessID = [rs intForColumn:@"ProcessID"];
        int WorkoutUserDateID = [rs intForColumn:@"WorkoutUserDateID"];

        NSString * CurrentDuration = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"CurrentDuration"]];
//        NSString * Stop = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"WorkingStatus"]];
        NSString * WorkingStatus = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"WorkingStatus"]];


        [dict setObject: [NSNumber numberWithInt:UserID]  forKey: @"UserID"];
        [dict setObject: [NSNumber numberWithInt:WorkoutUserID]  forKey: @"WorkoutUserID"];
        [dict setObject: [NSNumber numberWithInt:WorkoutUserDateID]  forKey: @"WorkoutUserDateID"];
        [dict setObject: [NSNumber numberWithInt:WorkoutProcessID]  forKey: @"WorkoutProcessID"];

        [dict setObject: CurrentDuration  forKey: @"CurrentDuration"];
        [dict setObject: [NSString stringWithFormat:@"true"]  forKey: @"Stop"];
        [dict setObject: WorkingStatus  forKey: @"WorkingStatus"];
    
        [arr addObject:dict];
    }
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
    return arr;
}

-(void)deleteWorkoutFromDb:(int)workoutTempId
{
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        
        FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
        if (![db open]) {
        }

        [db beginTransaction];

    NSString *userWorkoutPlanDeleteSQL = [NSString stringWithFormat: @"DELETE FROM UserWorkoutPlan WHERE WorkoutUserDateID = %i", workoutTempId];

        [db executeUpdate:userWorkoutPlanDeleteSQL];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
    
}

-(void)saveDeletedExerciseToDb:(int)workoutTempId UserId:(int)userId WorkoutUserDateID:(int)workoutUserDateID
{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    
    [db beginTransaction];
    
    NSString * insertSQL = [NSString stringWithFormat: @"INSERT INTO DeleteWorkoutTemplate (WorkoutTemplateId,UserId,WorkoutUserDateID) VALUES(\"%d\",\"%d\",\"%d\")",workoutTempId,userId,workoutUserDateID];
    
    [db executeUpdate:insertSQL];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
    DMLog(@"%@",[self loadDeletedExerciseFromDb]);
}

-(NSMutableArray *)loadDeletedExerciseFromDb
{
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
-(void)saveWorkoutDetailToDb:(NSArray *)dataArr
{
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
                    
                    NSString * insertSQL = [NSString stringWithFormat: @"INSERT INTO workout (WorkoutTemplateId,WorkoutMethodID,WorkoutMethodValueID,P1Number,TableP2ID,TableP2Name,P2Value,TableP3ID,TableP3Name,P3Value,ToBeAdded,isEdited,isDeleted,WorkoutUserDateID) VALUES(\"%d\",\"%d\",\"%d\",\"%d\",\"%d\",\"%@\",\"%d\",\"%d\",\"%@\",\"%d\",\"%@\",\"%@\",\"%@\",\"%d\")",WorkoutTemplateIdID,WorkoutMethodID,WorkoutMethodValueID,P1Number,TableP2ID,TableP2Name,P2Value,TableP3ID,TableP3Name,P3Value,ToBeAdded,isEdited,isDeleted, WorkoutUserDateID];
                    
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
-(NSMutableArray *)loadWorkoutSynParamFromDb
{
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
        
        int WorkoutMethodID = [rs intForColumn:@"WorkoutMethodID"];
        int WorkoutMethodValueID = [rs intForColumn:@"WorkoutMethodValueID"];
        int P1Number = [rs intForColumn:@"P1Number"];
        int TableP2ID = [rs intForColumn:@"TableP2ID"];
        int P2Value = [rs intForColumn:@"P2Value"];
        int TableP3ID = [rs intForColumn:@"TableP3ID"];
        int P3Value = [rs intForColumn:@"P3Value"];
        
        NSString * TableP2Name = [NSString stringWithFormat:@"%d", [rs intForColumn:@"TableP2Name"]];
        NSString * TableP3Name = [NSString stringWithFormat:@"%d", [rs intForColumn:@"TableP3Name"]];
        
        //        NSString * ToBeAdded = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"ToBeAdded"]];
        //
        //        NSString * isEdited = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"isEdited"]];
        
        
        //        [dict setObject:ToBeAdded forKey:@"ToBeAdded"];
        //        [dict setObject:isEdited forKey:@"isEdited"];
        
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
    return arr;
}
-(NSMutableArray *)loadWorkoutFromDb
{
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
        
//        NSString * ToBeAdded = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"ToBeAdded"]];
//
        NSString * isDeleted = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"isDeleted"]];
        
        
//        [dict setObject:ToBeAdded forKey:@"ToBeAdded"];
//        [dict setObject:isEdited forKey:@"isEdited"];

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
    return arr;
}
-(NSMutableArray *)loadWorkoutFromDbParams
{
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
        
        int WorkoutTemplateId = [rs intForColumn:@"WorkoutTemplateId"];
//        int WorkoutTemplateId = 0;
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
        
        //        NSString * ToBeAdded = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"ToBeAdded"]];
        //
//        NSString * isDeleted = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"isDeleted"]];
        
        
        //        [dict setObject:ToBeAdded forKey:@"ToBeAdded"];
        //        [dict setObject:isEdited forKey:@"isEdited"];
        
//        [dict setObject: isDeleted  forKey: @"isDeleted"];
        
        [dict setObject: [NSNumber numberWithInt:WorkoutTemplateId]  forKey: @"WorkoutTemplateId"];
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
    return arr;
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
//             [[prefs valueForKey:@"userid_dietmastergo"] integerValue]
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

-(NSMutableArray *)loadAddWorkoutTemplate
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    
    NSMutableArray * setsDbArr = [[NSMutableArray alloc]initWithArray:[self loadWorkoutFromDbParams]];

    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    
    if (![db open]) {
    }
    
    [db beginTransaction];
    
    NSString *addSql = [NSString stringWithFormat:@"SELECT * FROM UserWorkoutPlan WHERE ToBeAdded = 'yes'"];
    FMResultSet *rs = [db executeQuery:addSql];
    
    while ([rs next]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        int WorkoutTemplateIdWorkout    =  0;//[rs intForColumn:@"WorkoutTemplateId"];
        int WorkoutUserDateID           =  0;//[rs intForColumn:@"WorkoutUserDateID"];

        int WorkoutTemplateId = 0;
        int UserID = [[[NSUserDefaults standardUserDefaults] valueForKey:@"userid_dietmastergo"] integerValue];   //[rs intForColumn:@"UserID"];
        NSString * strTempName = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"TemplateName"]];
        int CategoryID =  [rs intForColumn:@"CategoryID"];
        int WorkoutID = [rs intForColumn:@"WorkoutID"];
        int tagsId = [rs intForColumn:@"TagsId"];
        NSString * SessionNotes = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"SessionNotes"]];
        NSString * ExerciseNotes = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"ExerciseNotes"]];
        NSString * strWorkoutTempId = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"WorkoutDate"]];
        NSString * VideoURL = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"VideoURL"]];
        NSString * IsActive = @"true";

        NSString * CreatedDate = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"WorkoutDate"]];
        NSString * EditedDate = [NSString stringWithFormat:@"%@", [rs stringForColumn:@"WorkoutDate"]];
        
        [dict setObject: [NSNumber numberWithInt:1]  forKey: @"P1ID"];
        [dict setObject: [NSNumber numberWithInt:2]  forKey: @"P2ID"];

        [dict setObject: [NSNumber numberWithInt:WorkoutTemplateId]  forKey: @"WorkoutTemplateId"];
        [dict setObject: [NSNumber numberWithInt:WorkoutUserDateID]  forKey: @"WorkoutUserDateID"];
        [dict setObject: [NSNumber numberWithInt:UserID]  forKey: @"UserID"];
        [dict setObject: strTempName  forKey: @"TemplateName"];
        [dict setObject: strWorkoutTempId  forKey: @"WorkoutDate"];
        [dict setObject: [NSNumber numberWithInt:WorkoutTemplateId]  forKey: @"WorkoutTemplateId"];
        [dict setObject: [NSNumber numberWithInt:CategoryID]  forKey: @"CategoryID"];
        [dict setObject: [NSNumber numberWithInt:WorkoutID]  forKey: @"WorkoutID"];
        [dict setObject: SessionNotes  forKey: @"SessionNotes"];
        [dict setObject: ExerciseNotes  forKey: @"ExerciseNotes"];
        [dict setObject: VideoURL  forKey: @"VideoURL"];
        [dict setObject: [NSNumber numberWithInt:tagsId]  forKey: @"TagsId"];
        [dict setObject: IsActive  forKey: @"IsActive"];
        [dict setObject: CreatedDate  forKey: @"CreatedDate"];
        [dict setObject: EditedDate  forKey: @"EditedDate"];
        
//        NSMutableArray * setArr = [[NSMutableArray alloc]init];
      

        NSString *filter = @"%K == %d";
                NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:filter,@"WorkoutUserDateID",[rs intForColumn:@"WorkoutUserDateID"]];

        NSMutableArray * setArr = [[NSMutableArray alloc]initWithArray:[setsDbArr filteredArrayUsingPredicate:categoryPredicate]];
        
        [dict setObject: setArr  forKey: @"WorkoutSets"];

        [arr addObject:dict];
    }
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
    
    return arr;
}

#pragma mark Sets for my moves
-(void)updateTimeForExercise:(int)WorkoutTemplateId Dict:(NSDictionary *)dict WorkoutTimer:(NSString*)WorkoutTime
{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    
    [db beginTransaction];
    
    int CurrentDuration = [dict[@"CurrentDuration"] integerValue];
    
    int  WorkoutTemplateIdID = WorkoutTemplateId;
    
    NSString *updateComments = [NSString stringWithFormat: @"UPDATE UserWorkoutPlan SET CurrentDuration = '%@' WHERE WorkoutTemplateId = '%d'",WorkoutTime,WorkoutTemplateId];
    
    [db executeUpdate:updateComments];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
}
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

-(NSMutableArray *)loadSetsToBeDeletedFromDb
{
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

-(void)addSetsForExercise:(int)WorkoutUserDateId Dict:(NSDictionary *)dict
{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    
    [db beginTransaction];
    
    int P1Number = [dict[@"P1Number"] integerValue];
    int P2Value = [dict[@"P2Value"] integerValue];
    int P3Value = [dict[@"P3Value"] integerValue];
    
    //    int  WorkoutTemplateIdID = WorkoutUserDateId;
        int  WorkoutTemplateIdID = 0;
    int  WorkoutUserDateID = [dict[@"WorkoutUserDateID"] integerValue];
    int  WorkoutMethodID = [dict[@"WorkoutMethodID"] integerValue];
    int  workoutUserDateID = [dict[@"WorkoutUserDateID"] integerValue];
    int  WorkoutMethodValueID = [dict[@"WorkoutMethodValueID"] integerValue];
    
    int  TableP2ID = [dict[@"TableP2ID"] integerValue];
    NSString * TableP2Name = dict[@"TableP2Name"];
    int  TableP3ID = [dict[@"TableP3ID"] integerValue];
    NSString * TableP3Name = dict[@"TableP3Name"];
    NSString * ToBeAdded = @"yes";
    NSString * isEdited = @"no";
    NSString * isDeleted = @"no";

    NSString * insertSQL = [NSString stringWithFormat: @"INSERT INTO workout (WorkoutTemplateId,WorkoutMethodID,WorkoutMethodValueID,P1Number,TableP2ID,TableP2Name,P2Value,TableP3ID,TableP3Name,P3Value,ToBeAdded,isEdited,isDeleted,WorkoutUserDateID) VALUES(\"%d\",\"%d\",\"%d\",\"%d\",\"%d\",\"%@\",\"%d\",\"%d\",\"%@\",\"%d\",\"%@\",\"%@\",\"%@\",\"%d\")",WorkoutTemplateIdID,WorkoutMethodID,WorkoutMethodValueID,P1Number,TableP2ID,TableP2Name,P2Value,TableP3ID,TableP3Name,P3Value,ToBeAdded,isEdited,isDeleted,WorkoutUserDateId];
    
    [db executeUpdate:insertSQL];
    
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
        if (data.length > 0 && connectionError == nil) {
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            
            DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
            
            FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
            if (![db open]) {
            }
            
            for (NSDictionary *dict in responseDict) {
                DMMove *move = [[DMMove alloc] initWithDictionary:dict];
                
                [db beginTransaction];
                
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
                
                [db commit];
                if ([db hadError]) {
                    DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                }
            }
        } else {
            DMLog(@"Error, code: %li", connectionError.code);
        }
    }];
}

@end
