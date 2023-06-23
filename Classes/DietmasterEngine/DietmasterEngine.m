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
#import "ZipArchive.h"
#import "UIDevice+machine.h"
#import "DietMasterGoAppDelegate.h"
#import "NSString+ConvertToDate.h"
#import "MBProgressHUD.h"
#import "NSNull+NullCategoryExtension.h"

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

float const UpdateMessagesTimeInterval = 10.;
NSString * const UpdatingMessageNotification = @"UpdatingMessageNotification";

@interface DietmasterEngine () {
    BOOL updatingMessage;
    
}
@property (nonatomic, strong) NSDateFormatter *dateformatter;
@property (nonatomic, strong) NSTimer *messagesUpdateTimer;
@end

@implementation DietmasterEngine
@synthesize wsGetFoodDelegate;

@synthesize exerciseSelectedDict, foodSelectedDict, currentWeight, taskMode, dateSelected, dateSelectedFormatted,userHeight,userGender;
@synthesize selectedMealID, selectedMeasureID, selectedCategoryID;
@synthesize syncDatabaseDelegate, syncUPDatabaseDelegate;
@synthesize mealPlanArray, isMealPlanItem, mealPlanItemToExchangeDict, indexOfItemToExchange, selectedMealPlanID, didInsertNewFood;
@synthesize groceryArray;

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
        foodSelectedDict = [[NSMutableDictionary alloc] init];
        
        mealPlanArray = [[NSMutableArray alloc] init];
        groceryArray = [[NSMutableArray alloc] init];
        _myMovesAssignedArray = [[NSMutableArray alloc] init];
        
        //HHT new exercise sync
        _arrExerciseSyncNew = [[NSMutableArray alloc] init];
        _pageNumber = 1;
        
        dateSelected = [[NSDate alloc] init];
        
        [_dateformatter setDateFormat:@"MMMM d, yyyy"];
        dateSelectedFormatted = [_dateformatter stringFromDate:dateSelected];
        
        isMealPlanItem = NO;
        mealPlanItemToExchangeDict = [[NSMutableDictionary alloc] init];
        didInsertNewFood = NO;
                
        getDataComplete = NO;
        getDataDidFail = NO;
    }
    return self;
}

#pragma mark MAIN SYNC METHOD
-(void)syncDatabase {
    syncsCompleted = 0;
    syncsFailed = 0;
    syncsToComplete = 3; // changed by henry
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:-90];
        
    NSString *dateString;
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"FirstTime"] isEqualToString:@"FirstTime"]) {
        dateString = @"1970-01-01";
        [[NSUserDefaults standardUserDefaults]setObject:@"SecondTime" forKey:@"FirstTime"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    else {
        NSDate *currentDate;
        if(![[NSUserDefaults standardUserDefaults] valueForKey:@"lastsyncdate"]){
            currentDate = [NSDate date];
        }
        else{
            currentDate = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastsyncdate"];
        }
        
        NSDate *oneDayAgo = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay
                                                                     value:-8
                                                                    toDate:currentDate
                                                                   options:0];
        
        self.dateformatter.timeZone = [NSTimeZone systemTimeZone];
        [self.dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        dateString = [self.dateformatter stringFromDate:oneDayAgo];

    }
    
    [self getDataFrom:dateString withBlock:^(BOOL success, NSError *error) {
        if (success) {
            syncsCompleted++;
            [self syncDatabaseFinished];
        } else {
            syncsFailed++;
            [self syncDatabaseFailed];
        }
    }];
    
    [self syncFavoriteFoods:dateString];

    [self syncFavoriteMeals:dateString];
    //[self syncExerciseLog:dateString];
    [self syncExerciseLogNew:dateString];
}

-(void)syncDatabaseFinished {
    if (syncsCompleted == syncsToComplete) {
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
        
        [syncDatabaseDelegate syncDatabaseFinished:@"success"];
    }
}

- (void)uploadDatabase {
    
    upsyncsCompleted = 0;
    upsyncsFailed = 0;
    upsyncsToComplete = 0;
    
    NSString *dateString = @"";
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
    if ([prefs valueForKey:@"lastsyncdate"]) {
        [self.dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        dateString = [self.dateformatter stringFromDate:[prefs valueForKey:@"lastsyncdate"]];
    }
    
    [self saveMeals:dateString];
    [self saveExerciseLogs:dateString];
    [self saveWeightLog:dateString];
    [self saveFavoriteFood:dateString];
    [self saveFavoriteMeal:dateString];
    [self performSelectorInBackground:@selector(saveAllCustomFoods) withObject:nil];
}

-(void)uploadDatabaseFinished {
    if (upsyncsCompleted == (upsyncsToComplete + 6)) {
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
        [syncUPDatabaseDelegate syncUPDatabaseFinished:@"success"];
        [self syncFavoriteFoods:nil];
    }
}
-(void)syncDatabaseFailed {
    if (syncsFailed > 0) {
        if ([syncDatabaseDelegate respondsToSelector:@selector(syncDatabaseFailed:)]) {
            [syncDatabaseDelegate syncDatabaseFailed:@"error"];
        }
    }
}
-(void)uploadDatabaseFailed {
    if (upsyncsFailed > 0) {
        if ([syncUPDatabaseDelegate respondsToSelector:@selector(syncUPDatabaseFailed:)]) {
            [syncUPDatabaseDelegate syncUPDatabaseFailed:@"error"];
        }
    }
}

#pragma mark - Sync User Details

- (void)syncUserInfo:(id)sender {
    DataFetcher *fetcher = [[DataFetcher alloc] init];
    [fetcher getUserDetailsWithCompletion:^(DMUser *user, NSError *error) {
        if (error) {
            return;
        }
        [self updateUserInfo:user];
    }];
}

- (void)updateUserInfo:(DMUser *)user {
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
    if (![db open]) {
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
                           "BMR = %i "
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
                           user.userBMR.intValue];
    
    [db executeUpdate:updateSQL];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
}

#pragma mark DOWN SYNC METHODS

-(void)syncFavoriteFoods:(NSString *)dateString {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if([[[NSUserDefaults standardUserDefaults]valueForKey:@"FirstTime"] isEqualToString:@"FirstTime"]) {
        dateString = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"lastsyncdate"]];
    }
    else {
        dateString = @"01-01-1970";
    }
    
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"SyncFavoriteFoods", @"RequestType",
                              [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                              [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                              dateString, @"LastSync",
                              nil];
    
    SoapWebServiceEngine *soapWebService = [[SoapWebServiceEngine alloc] init];
    soapWebService.wsSyncFavoriteFoodsDelegate = self;
    [soapWebService callWebservice:infoDict];
}

-(void)syncFavoriteMeals:(NSString *)dateString {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"SyncFavoriteMeals", @"RequestType",
                              [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                              [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                              nil];
    
    SoapWebServiceEngine *soapWebService = [[SoapWebServiceEngine alloc] init];
    soapWebService.wsSyncFavoriteMealsDelegate = self;
    [soapWebService callWebservice:infoDict];
}

-(void)syncFavoriteMealItems:(NSString *)dateString {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
    if (![db open]) {
        
    }
    
    NSString *query;
    
    query = [NSString stringWithFormat:@"SELECT Favorite_MealID, modified FROM Favorite_Meal WHERE Favorite_MealID > %@", @"0"];
    
    FMResultSet *rs = [db executeQuery:query];
    int resultCounts = 0;
    while ([rs next]) {
        
        NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  @"GetFavoriteMealItems", @"RequestType",
                                  [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                                  [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                                  [rs stringForColumn:@"Favorite_MealID"], @"Favorite_MealID",
                                  nil];
        
        SoapWebServiceEngine *soapWebService = [[SoapWebServiceEngine alloc] init];
        soapWebService.wsSyncFavoriteMealItemsDelegate = self;
        [soapWebService callWebservice:infoDict];
        resultCounts++;
    }
    
    [rs close];
    
    syncsToComplete = syncsToComplete + resultCounts;
    
    if (resultCounts == 0) {
        syncsCompleted++;
        [self syncDatabaseFinished];
    }
}

-(void)syncExerciseLog:(NSString *)dateString {
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"FirstTime"] isEqualToString:@"FirstTime"]) {
        dateString = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"lastsyncdate"]];
    } else {
        dateString = @"01-01-1970";
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"SyncExerciseLog", @"RequestType",
                              [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                              [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                              dateString, @"LastSync",
                              nil];
    
    SoapWebServiceEngine *soapWebService = [[SoapWebServiceEngine alloc] init];
    soapWebService.wsSyncExerciseLogDelegate = self;
    [soapWebService callWebservice:infoDict];
}

//HHT new exercise sync
-(void)syncExerciseLogNew:(NSString *)dateString {
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"FirstTime"] isEqualToString:@"FirstTime"]) {
        dateString = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"lastsyncdate"]];
    } else {
        dateString = @"01-01-1970";
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"SyncExerciseLogNew", @"RequestType",
                              [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                              [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                              dateString, @"LastSync",
                              [NSString stringWithFormat:@"%d",20],@"PageSize",
                              [NSString stringWithFormat:@"%d",_pageNumber],@"PageNumber",
                              nil];
    
    DMLog(@"SyncExerciseLogNew Dict is :: %@",infoDict);
    
    SoapWebServiceEngine *soapWebService = [[SoapWebServiceEngine alloc] init];
    soapWebService.wsSyncExerciseLogNewDelegate = self;
    [soapWebService callWebservice:infoDict];
}

#pragma mark - MESSAGES

- (void)stopUpdatingMessages {
    [self.messagesUpdateTimer invalidate];
    self.messagesUpdateTimer = nil;
    updatingMessage = NO;
}

- (void)startUpdatingMessages {
    if (updatingMessage == NO) {
        updatingMessage = YES;
        [self syncMessages];
    }
}

- (void)syncMessages {
    DataFetcher *fetcher = [[DataFetcher alloc] init];
    [fetcher getMessagesWithCompletion:^(NSArray<DMMessage *> *messages, NSError *error) {
        if (error) {
            return;
        }
        [self processIncomingMessages:messages];
        [[NSNotificationCenter defaultCenter] postNotificationName:UpdatingMessageNotification object:nil];
    }];
}

- (void)processIncomingMessages:(NSArray<DMMessage *> *)messages {
    if (!messages.count) {
        return;
    }
    
    FMDatabase* dataBase = [FMDatabase databaseWithPath:[self databasePath]];
    if (![dataBase open]) {
    }
    
    for (DMMessage *message in messages) {
        [dataBase beginTransaction];
        NSString *sqlQuery = [message replaceIntoSQLString];
        [dataBase executeUpdate:sqlQuery];

        BOOL statusMsg = YES;
        
        if ([dataBase hadError]) {
            DM_LOG(@"Err %d: %@", [dataBase lastErrorCode], [dataBase lastErrorMessage]);
            statusMsg = NO;
        }
        [dataBase commit];
    }
    
    self.messagesUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:UpdateMessagesTimeInterval target:self selector:@selector(startUpdatingMessages) userInfo:nil repeats:YES];
    updatingMessage = NO;
}

- (NSArray<DMMessage *> *)unreadMessages {
    FMDatabase* dataBase = [FMDatabase databaseWithPath:[self databasePath]];
    if (![dataBase open]) {
    }
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
    FMDatabase* dataBase = [FMDatabase databaseWithPath:[self databasePath]];
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
    FMDatabase* dataBase = [FMDatabase databaseWithPath:[self databasePath]];
    
    NSDictionary *message = [self messageById:uid database:dataBase];
    
    return message;
}

- (NSDictionary *)lastMessageId {
    FMDatabase* dataBase = [FMDatabase databaseWithPath:[self databasePath]];
    if (![dataBase open]) {
        
    }
    
    NSString *query = @"SELECT * FROM Messages ORDER BY Id DESC";
    
    NSDictionary * result = nil;
    
    FMResultSet *rs = [dataBase executeQuery:query];
    
    if ([rs next])
    {
        result = [NSDictionary dictionaryWithObjectsAndKeys:
                  [rs stringForColumn:@"Id"],    @"MessageID",
                  [rs stringForColumn:@"Text"],   @"Text",
                  [rs stringForColumn:@"Sender"], @"Sender",
                  [rs dateForColumn:@"Date"],     @"DsteTime", nil];
    }
    
    if ([dataBase hadError]) {
        DMLog(@"Err %d: %@", [dataBase lastErrorCode], [dataBase lastErrorMessage]);
    }
    
    [rs close];
    
    return result;
}

- (void)setReadedMessageId:(NSNumber *)messageId {
    FMDatabase* dataBase = [FMDatabase databaseWithPath:[self databasePath]];
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
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = [[DietmasterEngine sharedInstance] unreadMessageCount];
}

#pragma mark UP SYNC METHODS
-(void)saveMeals:(NSString *)dateString {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
    if (![db open]) {
        
    }
    
    NSString *query;
    
    query = @"SELECT MealID, MealDate FROM Food_Log WHERE MealID <= 0";
    
    FMResultSet *rs = [db executeQuery:query];
    int resultCounts = 0;
    while ([rs next]) {
        
        [self.dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *log_Date = [self.dateformatter dateFromString:[rs stringForColumn:@"MealDate"]];
        
        if (log_Date == nil) {
            continue;
        }
        
        [self.dateformatter setDateFormat:@"M/dd/yyyy"];
        NSString *logTimeString = [self.dateformatter stringFromDate:log_Date];
        
        NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  @"SaveMeal", @"RequestType",
                                  [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                                  [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                                  logTimeString, @"MealDate",
                                  [rs stringForColumn:@"MealID"], @"MealID",
                                  nil];
        
        SoapWebServiceEngine *soapWebService = [[SoapWebServiceEngine alloc] init];
        soapWebService.wsSaveMealDelegate = self;
        [soapWebService callWebservice:infoDict];
        resultCounts++;
    }
    
    [rs close];
    
    syncsToComplete = syncsToComplete + resultCounts;
    
    if (resultCounts == 0) {
        upsyncsCompleted++;
        [self saveMealItems:dateString];
    }
}

- (void)saveMealItems:(NSString *)dateString {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
    if (![db open]) {
        
    }
    
    NSString *query;
    if (dateString != nil && [dateString containsString:@"T"]) {
        dateString = [dateString stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    }
    
    query = [NSString stringWithFormat:@"SELECT MealID, FoodID, MealCode, MeasureID, NumberOfServings, LastModified "
             " FROM Food_Log_Items WHERE LastModified > '%@' ", dateString];
    
    int resultCounts = 0;
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
        
        resultCounts++;
    }
    
    [rs close];
    
    if (resultCounts == 0) {
        upsyncsCompleted++;
        [self uploadDatabaseFinished];
        return;
    }
    
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"SaveMealItems", @"RequestType",
                              [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                              [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                              tempDataArray, @"MealItems",
                              nil];
    
    SoapWebServiceEngine *soapWebService = [[SoapWebServiceEngine alloc] init];
    soapWebService.wsSaveMealItemDelegate = self;
    [soapWebService callWebservice:infoDict];
}

- (void)saveExerciseLogs:(NSString *)dateString {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
    if (![db open]) {
        
    }
    
    NSString *query;
    
    query = [NSString stringWithFormat:@"SELECT ExerciseID, Exercise_Time_Minutes, Log_Date, Exercise_Log_StrID "
             " FROM Exercise_Log %@", @""];
    
    int resultCounts = 0;
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
        
        resultCounts++;
    }
    
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"SaveExerciseLogs", @"RequestType",
                              [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                              [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                              tempDataArray, @"ExerciseLog",
                              nil];
    
    SoapWebServiceEngine *soapWebService = [[SoapWebServiceEngine alloc] init];
    soapWebService.wsSaveExerciseLogsDelegate = self;
    [soapWebService callWebservice:infoDict];
    
    [rs close];
    
    if (resultCounts == 0) {
        upsyncsCompleted++;
        [self uploadDatabaseFinished];
    }
}

- (void)saveWeightLog:(NSString *)dateString {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
    if (![db open]) {
        
    }
    
    NSString *query = [NSString stringWithFormat:@"SELECT weight, logtime FROM weightlog"];
    int resultCounts = 0;
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
        
        resultCounts++;
    }
    
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"SaveWeightLogs", @"RequestType",
                                [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                                [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                                [tempDataArray copy], @"WeightLog", nil];
    
    SoapWebServiceEngine *soapWebService = [[SoapWebServiceEngine alloc] init];
    soapWebService.wsSaveWeightLogDelegate = self;
    [soapWebService callWebservice:infoDict];

    [rs close];
    
    if (resultCounts == 0) {
        upsyncsCompleted++;
        [self uploadDatabaseFinished];
    }
}

- (void)saveAllCustomFoods {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
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
    int resultCounts = 0;
    
    while ([rs next]) {
        
        NSDictionary *resultDict = [rs resultDictionary];
        DMFood *food = [[DMFood alloc] initWithDictionary:resultDict];
        NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                              @"SaveFoodNew", @"RequestType",
                              [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                              [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                              nil];
        [mutableDict addEntriesFromDictionary:[food dictionaryRepresentation]];

        SoapWebServiceEngine *soapWebService = [[SoapWebServiceEngine alloc] init];
        [soapWebService callWebservice:[mutableDict copy] withCompletion:^(id obj)
         {
             [self saveFoodFinished:obj];
         }];
        
        resultCounts++;
    }
    
    [rs close];
}

-(void)saveFood:(int)foodKey {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
    if (![db open]) {
        
    }
    
    NSString *query = [NSString stringWithFormat:@"SELECT f.FoodKey,f.FoodID,f.Name,f.CategoryID, f.Calories, f.Fat, "
                       "f.Sodium, f.Carbohydrates, f.SaturatedFat, f.Cholesterol,f.Protein, "
                       "f.Fiber,f.Sugars, f.Pot,f.A, "
                       "f.Thi, f.Rib,f.Nia, f.B6, "
                       "f.B12,f.Fol,f.C, f.Calc, "
                       "f.Iron,f.Mag,f.Zn,f.ServingSize, "
                       "f.Transfat, f.E, f.D,f.Folate, "
                       "f.Frequency, f.UserID, f.CompanyID, f.ScannedFood, fm.MeasureID, f.UPCA, f.FactualID FROM Food f INNER JOIN FoodMeasure fm ON fm.FoodID = f.FoodKey WHERE f.FoodKey = %i", foodKey];
    
    FMResultSet *rs = [db executeQuery:query];
    int resultCounts = 0;
    
    while ([rs next]) {

        NSDictionary *resultDict = [rs resultDictionary];
        DMFood *food = [[DMFood alloc] initWithDictionary:resultDict];
        
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"SaveFoodNew", @"RequestType",
                              [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                              [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                              
                              food.foodKey, @"FoodKey",
                              food.foodId, @"FoodID",
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
                              food.scannedFood, @"ScannedFood", nil];
        SoapWebServiceEngine *soapWebService = [[SoapWebServiceEngine alloc] init];
        soapWebService.wsSaveFoodDelegate = self;
        [soapWebService callWebservice:dict];
        resultCounts++;
    }
    
    [rs close];
    
}
-(void)saveFavoriteFood:(NSString *)dateString {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
    if (![db open]) {
        
    }
    
    NSString *query = [NSString stringWithFormat:@"SELECT Favorite_FoodID, FoodID, MeasureID, modified FROM Favorite_Food WHERE Favorite_FoodID < %@", @"0"];
    
    FMResultSet *rs = [db executeQuery:query];
    int resultCounts = 0;
    
    while ([rs next]) {
        
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"SaveFavoriteFood", @"RequestType",
                              [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                              [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                              [rs stringForColumn:@"Favorite_FoodID"], @"Favorite_FoodID",
                              [rs stringForColumn:@"FoodID"], @"FoodID",
                              [rs stringForColumn:@"MeasureID"], @"MeasureID",
                              nil];
        
        SoapWebServiceEngine *soapWebService = [[SoapWebServiceEngine alloc] init];
        soapWebService.wsSaveFavoriteFoodDelegate = self;
        [soapWebService callWebservice:dict];
        resultCounts++;
    }
    
    [rs close];
    
    syncsToComplete = syncsToComplete + resultCounts;
    
    if (resultCounts == 0) {
        upsyncsCompleted++;
        [self uploadDatabaseFinished];
    }
}

-(void)saveFavoriteMeal:(NSString *)dateString {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
    if (![db open]) {
        
    }
    
    
    NSString *query = [NSString stringWithFormat:@"SELECT Favorite_MealID, Favorite_Meal_Name FROM Favorite_Meal WHERE Favorite_MealID <= %@", @"0"];
    
    FMResultSet *rs = [db executeQuery:query];
    int resultCounts = 0;
    
    while ([rs next]) {
        
        
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"SaveFavoriteMeal", @"RequestType",
                              [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                              [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                              [rs stringForColumn:@"Favorite_MealID"], @"Favorite_MealID",
                              [rs stringForColumn:@"Favorite_Meal_Name"], @"Favorite_Meal_Name",
                              nil];
        
        
        
        SoapWebServiceEngine *soapWebService = [[SoapWebServiceEngine alloc] init];
        soapWebService.wsSaveFavoriteMealDelegate = self;
        [soapWebService callWebservice:dict];
        resultCounts++;
        
    }
    
    [rs close];
    
    syncsToComplete = syncsToComplete + resultCounts;
    
    if (resultCounts == 0) {
        upsyncsCompleted++;
        [self uploadDatabaseFinished];
    }
}

- (void)saveFavoriteMealItem:(int)mealID {
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
    if (![db open]) {
        
    }
    
    
    NSString *query = [NSString stringWithFormat:@"SELECT Favorite_Meal_ID, FoodKey, MeasureID, Servings FROM Favorite_Meal_Items WHERE Favorite_Meal_ID = %i ", mealID];
    
    
    FMResultSet *rs = [db executeQuery:query];
    int resultCounts = 0;
    
    while ([rs next]) {
        
        
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"SaveFavoriteMealItem", @"RequestType",
                              [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                              [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                              [rs stringForColumn:@"Favorite_Meal_ID"], @"Favorite_Meal_ID",
                              [rs stringForColumn:@"FoodKey"], @"FoodKey",
                              [rs stringForColumn:@"MeasureID"], @"MeasureID",
                              [rs stringForColumn:@"Servings"], @"Servings",
                              nil];
        
        SoapWebServiceEngine *soapWebService = [[SoapWebServiceEngine alloc] init];
        soapWebService.wsSaveFavoriteMealItemDelegate = self;
        [soapWebService callWebservice:dict];
        resultCounts++;
        
    }
    
    [rs close];
    
    
    if (resultCounts == 0) {
        
    }
}

#pragma mark DOWN SYNC DELEGATE METHODS

- (void)getSyncFavoriteFoodsFinished:(NSMutableArray *)responseArray {
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
    if (![db open]) {
    }
    
    [db beginTransaction];
    for (int i=0; i < [responseArray count]; i++) {
        
        NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[responseArray objectAtIndex:i]];
        
        NSDate* sourceDate = [NSDate date];
        [self.dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSString *queryString = [NSString stringWithFormat:@"REPLACE INTO Favorite_Food "
                                 "(FoodID, MeasureID, modified) VALUES "
                                 "(%i, %i, '%@') ",
                                 ValidInt([dict valueForKey:@"FoodId"]),
                                 ValidInt([dict valueForKey:@"MeasureID"]),
                                 sourceDate
                                 ];
        
        [db executeUpdate:queryString];
    }
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
    
    syncsCompleted++;
    [self syncDatabaseFinished];
}

- (void)getSyncFavoriteFoodsFailed:(NSString *)failedMessage {
    syncsFailed++;
    [self syncDatabaseFailed];
}

- (void)getSyncFavoriteMealsFinished:(NSMutableArray *)responseArray {
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
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
    }
    
    [db commit];
    
    [self syncFavoriteMealItems:nil];
    syncsCompleted++;
    [self syncDatabaseFinished];
    
}
- (void)getSyncFavoriteMealsFailed:(NSString *)failedMessage {
    syncsFailed++;
    [self syncDatabaseFailed];
}

- (void)getSyncFavoriteMealItemsFinished:(NSMutableArray *)responseArray {
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
    if (![db open]) {
    }
    
    [db beginTransaction];
    
    for (int i=0; i < [responseArray count]; i++) {
        
        NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[responseArray objectAtIndex:i]];
        
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
    
    syncsCompleted++;
    [self syncDatabaseFinished];
    
}
- (void)getSyncFavoriteMealItemsFailed:(NSString *)failedMessage {
    syncsFailed++;
    [self syncDatabaseFailed];
}

- (void)getSyncExerciseLogFinished:(NSMutableArray *)responseArray {
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
    if (![db open]) {
        
    }
    
    [db beginTransaction];
    for (int i=0; i < [responseArray count]; i++) {
        
        NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[responseArray objectAtIndex:i]];
        
        [self.dateformatter setDateFormat:@"MM/dd/yyyy h:mm:ss aaa"];
        NSLocale *en_US = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [self.dateformatter setLocale:en_US];
        NSDate *logTimeDate = [self.dateformatter dateFromString:[dict valueForKey:@"ExerciseDate"]];
        
        [self.dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *logTimeString = [self.dateformatter stringFromDate:logTimeDate];
        
        [self.dateformatter setDateFormat:@"yyyyMMdd"];
        NSString *keyDate = [self.dateformatter stringFromDate:logTimeDate];
        
        int exerciseID = [[dict valueForKey:@"ExerciseID"] intValue];
        NSString *exerciseLogStrID = [NSString stringWithFormat:@"%@-%i", keyDate, exerciseID];
        
        NSDate* sourceDate = [NSDate date];
        [self.dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *date_string = [self.dateformatter stringFromDate:sourceDate];
        
        NSString *queryString = [NSString stringWithFormat:@"REPLACE INTO Exercise_Log"
                                 "(Exercise_Log_StrID, ExerciseID, Exercise_Time_Minutes, Log_Date, Date_Modified) VALUES "
                                 "('%@', %i, %i, '%@', '%@') ",
                                 exerciseLogStrID,
                                 exerciseID,
                                 ValidInt([dict valueForKey:@"Duration"]),
                                 logTimeString,
                                 date_string
                                 ];
        
        [db executeUpdate:queryString];
    }
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
    
    syncsCompleted++;
    [self syncDatabaseFinished];
}

- (void)getSyncExerciseLogFailed:(NSString *)failedMessage {
    syncsFailed++;
    [self syncDatabaseFailed];
}

//HHT new exercise sync
#pragma mark - getSyncExerciseLogNewFinished
- (void)getSyncExerciseLogNewFinished:(NSMutableArray *)responseArray {
    
    NSMutableArray *arrTemp = [[NSMutableArray alloc] init];
    int totalCount = 0;
    
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
    if (![db open]) {
        
    }
    
    [db beginTransaction];

    if ([responseArray count]>0){
        NSDictionary *dictTemp = [[NSDictionary alloc] initWithDictionary:[responseArray objectAtIndex:0]];
        arrTemp = [dictTemp valueForKey:@"ExerciseLogs"];
        
        totalCount = [[dictTemp valueForKey:@"TotalCount"] intValue];
        
        for (int i=0; i < [arrTemp count]; i++) {
            NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[arrTemp objectAtIndex:i]];
            
            //HHT change 2018 (Date format change)
            [self.dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            //[dateformatter setDateFormat:@"MM/dd/yyyy h:mm:ss aaa"];
            NSLocale *en_US = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [self.dateformatter setLocale:en_US];
            NSDate *logTimeDate = [self.dateformatter dateFromString:[dict valueForKey:@"ExerciseDate"]];
            
            [self.dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *logTimeString = [self.dateformatter stringFromDate:logTimeDate];
            
            [self.dateformatter setDateFormat:@"yyyyMMdd"];
            NSString *keyDate = [self.dateformatter stringFromDate:logTimeDate];
            
            int exerciseID = [[dict valueForKey:@"ExerciseID"] intValue];
            NSString *exerciseLogStrID = [NSString stringWithFormat:@"%@-%i", keyDate, exerciseID];
            
            NSDate* sourceDate = [NSDate date];
            [self.dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
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
            
            [_arrExerciseSyncNew addObject:dict];
        }
        
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
        
        if (_arrExerciseSyncNew.count < totalCount){
            NSString *dateString;
            if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"FirstTime"] isEqualToString:@"FirstTime"]) {
                dateString = @"1970-01-01";
                [[NSUserDefaults standardUserDefaults]setObject:@"SecondTime" forKey:@"FirstTime"];
            }
            else {
                dateString = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"lastsyncdate"]];
            }
            _pageNumber = _pageNumber + 1;
            [self syncExerciseLogNew:dateString];
        }
        else {
            _pageNumber = 1;
            
            syncsCompleted++;
            [self syncDatabaseFinished];
        }
    }
}

//HHT new exercise sync
- (void)getSyncExerciseLogNewFailed:(NSString *)failedMessage {
    syncsFailed++;
    [self syncDatabaseFailed];
}

#pragma mark - Get Food Finish Method
- (void)getFoodFinished:(NSMutableArray *)responseArray {
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
    if (![db open]) {
        
    }
    
    [db beginTransaction];
    
    for (int i=0; i < [responseArray count]; i++) {
        
        NSDictionary *dict = [responseArray[i] copy];
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
- (void)getFoodFailed:(NSString *)failedMessage {
    DMLog(@"getFoodFailed, value of response is %@", failedMessage);
}

#pragma mark UP SYNC DELEGATE METHODS
- (void)saveMealFinished:(NSMutableArray *)responseArray {
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
    if (![db open]) {
    }
    
    for (int i=0; i < [responseArray count]; i++) {
        
        NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[responseArray objectAtIndex:i]];
        
        NSString *queryString = [NSString stringWithFormat:@"UPDATE Food_Log "
                                 " SET MealID = %i WHERE MealID = %i ",
                                 [[dict valueForKey:@"MealID"] intValue],
                                 [[dict valueForKey:@"goMealID"] intValue]
                                 ];
        
        
        [db executeUpdate:queryString];
    }
    
    for (int i=0; i < [responseArray count]; i++) {
        
        NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[responseArray objectAtIndex:i]];
        
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
    
    
    [self saveMealItems:nil];
    
    upsyncsCompleted++;
    [self uploadDatabaseFinished];
}

- (void)saveMealFailed:(NSString *)failedMessage {
    if (![failedMessage isEqualToString:@"error"]) {
        if ([failedMessage intValue] < 0) {
            //why were they deleting meals from the app if the same failed? that seems counter-intuitive
//            FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
//            if (![db open]) {
//            }
//            int mealIDToDelete = [failedMessage intValue];
//            [db beginTransaction];
//            NSString *updateSQL = [NSString stringWithFormat: @"DELETE FROM Food_Log WHERE MealID = %i", mealIDToDelete];
//            [db executeUpdate:updateSQL];
//            updateSQL = [NSString stringWithFormat: @"DELETE FROM Food_Log_Items WHERE MealID = %i", mealIDToDelete];
//            [db executeUpdate:updateSQL];
//            if ([db hadError]) {
//                DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
//            }
//            [db commit];
        }
    }
    
    upsyncsFailed++;
    [self uploadDatabaseFailed];
}

- (void)saveMealItemFinished:(NSMutableArray *)responseArray {
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
    if (![db open]) {
        DM_LOG(@"Error, Database not open.");
        return;
    }
    
    for (int i=0; i < [responseArray count]; i++) {
        NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[responseArray objectAtIndex:i]];
        
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
    
    upsyncsCompleted++;
    [self uploadDatabaseFinished];
}

- (void)saveMealItemFailed:(NSString *)failedMessage {
    upsyncsFailed++;
    [self uploadDatabaseFailed];
}

- (void)saveExerciseLogsFinished:(NSMutableArray *)responseArray {
    upsyncsCompleted++;
    [self uploadDatabaseFinished];
}

- (void)saveExerciseLogsFailed:(NSString *)failedMessage {
    upsyncsFailed++;
    [self uploadDatabaseFailed];
}

- (void)saveWeightLogFinished:(NSMutableArray *)responseArray {
    upsyncsCompleted++;
    [self uploadDatabaseFinished];
}

- (void)saveWeightLogFailed:(NSString *)failedMessage {
    upsyncsFailed++;
    [self uploadDatabaseFailed];
}

- (void)saveFoodFinished:(NSMutableArray *)responseArray {
    NSInteger foodIDSaved = 0;
    
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
    if (![db open]) {
    }
    
    [db beginTransaction];
    for (int i=0; i < [responseArray count]; i++) {
        
        NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[responseArray objectAtIndex:i]];
        
        foodIDSaved = [[dict valueForKey:@"FoodID"] intValue];
        
        NSString *queryString = [NSString stringWithFormat:@"UPDATE Food "
                                 " SET FoodKey = %i WHERE FoodKey = %i ",
                                 ValidInt([dict valueForKey:@"FoodID"]),
                                 ValidInt([dict valueForKey:@"GoID"])
                                 ];
        
        [db executeUpdate:queryString];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self saveUPCFood:[[dict valueForKey:@"FoodID"] intValue]];
        });
    }
    
    for (int i=0; i < [responseArray count]; i++) {
        
        NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[responseArray objectAtIndex:i]];
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FoodWasSavedToCloud" object:nil userInfo:@{@"FoodID" : @(foodIDSaved), @"success" : @(YES)}];
}

- (void)saveFoodFailed:(NSString *)failedMessage {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FoodWasSavedToCloud" object:nil userInfo:@{@"success" : @(NO)}];
}

- (void)saveFavoriteFoodFinished:(NSMutableArray *)responseArray {
    upsyncsCompleted++;
    [self uploadDatabaseFinished];
}

- (void)saveFavoriteFoodFailed:(NSString *)failedMessage {
    upsyncsFailed++;
    [self uploadDatabaseFailed];
}

- (void)saveFavoriteMealFinished:(NSMutableArray *)responseArray {
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
    if (![db open]) {
        
    }
    
    [db beginTransaction];
    for (int i=0; i < [responseArray count]; i++) {
        
        NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[responseArray objectAtIndex:i]];
        
        NSString *queryString = [NSString stringWithFormat:@"UPDATE Favorite_Meal "
                                 " SET Favorite_MealID = %i WHERE Favorite_MealID = %i ",
                                 [[dict valueForKey:@"MealID"] intValue],
                                 [[dict valueForKey:@"goMealID"] intValue]
                                 ];
        
        [db executeUpdate:queryString];
    }
    
    for (int i=0; i < [responseArray count]; i++) {
        
        NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[responseArray objectAtIndex:i]];
        
        NSString *queryString = [NSString stringWithFormat:@"UPDATE Favorite_Meal_Items "
                                 " SET Favorite_Meal_ID = %i WHERE Favorite_Meal_ID = %i ",
                                 [[dict valueForKey:@"MealID"] intValue],
                                 [[dict valueForKey:@"goMealID"] intValue]
                                 ];
        
        [db executeUpdate:queryString];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.30 * NSEC_PER_SEC), dispatch_get_main_queue(), ^
                       {
                           [self saveFavoriteMealItem:[[dict valueForKey:@"MealID"] intValue]];
                       });
    }
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
    
    upsyncsCompleted++;
    [self uploadDatabaseFinished];
}

- (void)saveFavoriteMealFailed:(NSString *)failedMessage {
    upsyncsFailed++;
    [self uploadDatabaseFailed];
}

- (void)saveFavoriteMealItemFinished:(NSMutableArray *)responseArray {
    
}

- (void)saveFavoriteMealItemFailed:(NSString *)failedMessage {
    DMLog(@"saveFavoriteMealItemFailed, value of response is %@", failedMessage);
}

#pragma mark GET DATA METHODS (NEW)
-(void)getDataFrom:(NSString *)syncDate withBlock:(DMGBooleanResponseBlock)block {
    getDataComplete = NO;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    //set userid in logs
        [[FIRCrashlytics crashlytics] logWithFormat:@"GetUserData API called. UserId: %@",
         [prefs valueForKey:@"userid_dietmastergo"]];
    
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"GetUserData", @"RequestType",
                              @{@"UserID" : [prefs valueForKey:@"userid_dietmastergo"],
                                @"AuthKey" : [prefs valueForKey:@"authkey_dietmastergo"],
                                @"LastSync" : syncDate
                                }, @"parameters",
                              nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        GetDataWebService *webService = [[GetDataWebService alloc] init];
        webService.getDataWSDelegate = self;
        [webService callWebservice:infoDict];
    });
    
    semaphore = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (getDataComplete == YES) {
                if (!getDataDidFail) {
                    block(YES, nil);
                } else {
                    block(NO, nil);
                }
            }
        });
    });
}

#pragma mark GET DATA DELEGATES (USER)
- (void)getDataFailed:(NSString *)failedMessage {
    getDataDidFail = NO;
    getDataComplete = YES;
}

- (void)getDataFinished:(NSDictionary *)responseDict {
    if (!responseDict) {
        return;
    }
    
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
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
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setValue:user.hostName forKey:@"HostName"];
        
        BOOL statusMsg = YES;
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            statusMsg = NO;
        }
        [db commit];
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
    
#pragma mark RESPONSE - USER FOODS
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
    
#pragma mark COMPANY FOODS
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
    
#pragma mark LOG DATA
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
    
    getDataDidFail = NO;
    getDataComplete = YES;
    dispatch_semaphore_signal(semaphore);
}

#pragma mark SPLASH IMAGE
- (void)downloadFileIfUpdatedInBackground {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if ([prefs boolForKey:@"user_loggedin"] == YES) {
        
        if (![prefs valueForKey:@"lastmodified_splash"]) {
            
            if ([[prefs valueForKey:@"splashimage_filename"] length] == 0) {
                
                NSString *tokenToSend = [NSString stringWithString:[prefs valueForKey:@"authkey_dietmastergo"]];
                DataFetcher *dataFetcher = [[DataFetcher alloc] init];
                [dataFetcher signInUserWithPassword:tokenToSend completion:^(DMUser *user, NSString *status, NSString *message) {
                    [prefs setValue:[NSDate date] forKey:@"lastmodified_splash"];
                }];
                               
                return;
            }
            else {
                [self performSelectorInBackground:@selector(downloadFileIfUpdated) withObject:nil];
                return;
            }
        }
        else {
            NSInteger hourSinceDate = [self hoursAfterDate:[prefs valueForKey:@"lastmodified_splash"]];
            if (hourSinceDate >= (24*3)) {
                if ([[prefs valueForKey:@"splashimage_filename"] length] == 0) {
                    
                    NSString *tokenToSend = [NSString stringWithString:[prefs valueForKey:@"authkey_dietmastergo"]];
                    DataFetcher *dataFetcher = [[DataFetcher alloc] init];
                    [dataFetcher signInUserWithPassword:tokenToSend completion:^(DMUser *user, NSString *status, NSString *message) {
                        [prefs setValue:[NSDate date] forKey:@"lastmodified_splash"];
                    }];
                    
                    return;
                }
                else {
                    [self performSelectorInBackground:@selector(downloadFileIfUpdated) withObject:nil];
                    return;
                }
            }
        }
    }
}

- (void)downloadFileIfUpdated {
    NSString *pngFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"SplashImage.png"];
    NSString *pngFilePath2x = [NSTemporaryDirectory() stringByAppendingPathComponent:@"SplashImage@2x.png"];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *urlString = [NSString stringWithFormat:@"http://www.dmwebpro.com/CustomMobileGraphics/%@",
                           [prefs valueForKey:@"splashimage_filename"]];
    
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
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"splashimage_filename"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString *logoFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"SplashImage.png"];
        NSString *logoFilePath2x = [NSTemporaryDirectory() stringByAppendingPathComponent:@"SplashImage@2x.png"];
        if([[NSFileManager defaultManager] fileExistsAtPath: logoFilePath])
        {
            [fileManager removeItemAtPath:logoFilePath error:NULL];
            [fileManager removeItemAtPath:logoFilePath2x error:NULL];
        }
        
        [prefs setValue:[NSDate date] forKey:@"lastmodified_splash"];
        [prefs synchronize];
        
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
                        
                        if ([data1 writeToFile:pngFilePath atomically:YES]) {
                        }
                        
                        if ([data2 writeToFile:pngFilePath2x atomically:YES]) {
                            
                        }
                        
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

-(void)saveMealNotesTemp:(NSDictionary *)foodDict {
    
}

#pragma mark Food Plan Methods

- (void)getMissingFoods:(NSDictionary *)foodDict {
    
    int selectedFoodID = [[foodDict valueForKey:@"FoodID"] intValue];
    int measureID = [[foodDict valueForKey:@"MeasureID"] intValue];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
    if (![db open]) {
        
    }
    
    NSString *query = [NSString stringWithFormat: @"SELECT Food.CategoryID, Food.ServingSize,Food.FoodID,Food.Name,Food.Calories,Food.Fat,Food.Carbohydrates,Food.Protein,Food.FoodKey,Food.UserID,Food.FoodPK, FoodMeasure.GramWeight, Measure.MeasureID, Measure.Description FROM Food INNER JOIN FoodMeasure ON FoodMeasure.FoodID = Food.FoodKey INNER JOIN Measure ON FoodMeasure.MeasureID = Measure.MeasureID WHERE Food.FoodKey = %i AND Measure.MeasureID = %i LIMIT 1", selectedFoodID, measureID];
    
    FMResultSet *rs = [db executeQuery:query];
    
    int resultCount = 0;
    
    while ([rs next]) {
        
        resultCount++;
    }
    
    [rs close];
    
    if (resultCount == 0) {
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  @"GetFoodNew", @"RequestType",
                                  [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                                  [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                                  [NSNumber numberWithInt:selectedFoodID], @"FoodKey",
                                  nil];
        
        SoapWebServiceEngine *soapWebService = [[SoapWebServiceEngine alloc] init];
        
        [soapWebService callWebserviceForFoodNew:infoDict withCompletion:^(id obj)
         {
             [self getFoodFinished:obj];
             
         }];
    }
}

-(void)retrieveMissingFood:(int)foodKey {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    //Send Data needed
    //GetFood OLD one
    //GetFoodNew //on 23-08-2016 by HHT
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"GetFoodNew", @"RequestType",
                              [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                              [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                              [NSNumber numberWithInt:foodKey], @"FoodKey",
                              nil];
    
    SoapWebServiceEngine *soapWebService = [[SoapWebServiceEngine alloc] init];
    soapWebService.wsGetFoodDelegate = self;
    
    [soapWebService callWebserviceForFoodNew:infoDict withCompletion:^(id obj)
     {
         [self getFoodFinished:obj];
     }];
}

-(NSDictionary *)getFoodDetails:(NSDictionary *)foodDict {
    int selectedFoodID = [[foodDict valueForKey:@"FoodID"] intValue];
    int tempMeasureID = [[foodDict valueForKey:@"MeasureID"] intValue];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
    if (![db open])
    {
        
    }
    
    NSString *query = [NSString stringWithFormat: @"SELECT Food.CategoryID, Food.ServingSize,Food.FoodID,Food.Name,Food.Calories,Food.Fat,Food.Carbohydrates,Food.Protein,Food.FoodKey,Food.UserID,Food.FoodPK, FoodMeasure.GramWeight, Measure.MeasureID, Measure.Description, Food.RecipeID, Food.CategoryID, Food.FoodURL FROM Food INNER JOIN FoodMeasure ON FoodMeasure.FoodID = Food.FoodKey INNER JOIN Measure ON FoodMeasure.MeasureID = Measure.MeasureID WHERE Food.FoodKey = %i AND Measure.MeasureID = %i LIMIT 1", selectedFoodID, tempMeasureID];
    DMLog(@"query=%@",query);
    
    FMResultSet *rs = [db executeQuery:query];
    
    NSDictionary *dict = nil;
    
    while ([rs next]) {
        
        dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                [NSNumber numberWithInt:[rs intForColumn:@"FoodID"]], @"FoodID",
                [NSNumber numberWithInt:[rs intForColumn:@"FoodKey"]], @"FoodKey",
                [NSNumber numberWithInt:[rs intForColumn:@"CategoryID"]], @"CategoryID",
                [rs stringForColumn:@"Name"], @"Name",
                [NSNumber numberWithInt:[rs intForColumn:@"Calories"]], @"Calories",
                [NSNumber numberWithDouble:[rs doubleForColumn:@"Fat"]], @"Fat",
                [NSNumber numberWithDouble:[rs doubleForColumn:@"Carbohydrates"]], @"Carbohydrates",
                [NSNumber numberWithDouble:[rs doubleForColumn:@"Protein"]], @"Protein",
                [NSNumber numberWithDouble:[rs doubleForColumn:@"ServingSize"]], @"ServingSize",
                [NSNumber numberWithDouble:[rs doubleForColumn:@"GramWeight"]], @"GramWeight",
                [NSNumber numberWithInt:[rs intForColumn:@"MeasureID"]], @"MeasureID",
                [rs stringForColumn:@"Description"], @"Description",
                [NSNumber numberWithInt:[rs intForColumn:@"RecipeID"]], @"RecipeID",
                [NSNumber numberWithInt:[rs intForColumn:@"CategoryID"]], @"CategoryID",
                [rs stringForColumn:@"FoodURL"], @"FoodURL",
                nil];
    }
    
    [rs close];
    
    if (dict == nil) {
        dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"Invalid Food, Contact Support", @"Name",nil];
    }
    return dict;
}

-(BOOL)insertMealPlanToLog:(NSDictionary *)dict {
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
    if (![db open]) {
        
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
    
    NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO Food_Log (MealID, MealDate) VALUES (%i, DATETIME('%@'))", minIDvalue, date_Today];
    
    [db executeUpdate:insertSQL];
    
    int mealID = minIDvalue;
    
    [self.dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *date_string = [self.dateformatter stringFromDate:[NSDate date]];
    
    insertSQL = [NSString stringWithFormat: @"INSERT INTO Food_Log_Items "
                 "(MealID, FoodID, MealCode, MeasureID, NumberOfServings, LastModified) "
                 " VALUES (%i, %i, %i, %i, %f, DATETIME('%@'))",
                 mealID, foodID, mealCode, num_measureID, servingAmount, date_string];
    
    [db executeUpdate:insertSQL];
    
    
    
    BOOL success = YES;
    
    if ([db hadError]) {
        success = NO;
    }
    [db commit];
    
    return success = YES;
}

-(NSNumber *)getMealCodeCalories:(NSArray *)array {
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
    if (![db open]) {
        
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
        DMLog(@"%f", num_totalCalories);
    }
    
    return [NSNumber numberWithDouble:num_totalCalories];
}

-(NSNumber *)getRecommendedCalories {
    
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
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
-(NSNumber *)getMeasureIDForFood:(NSNumber *)foodKey {
    
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
    if (![db open]) {
        
    }
    
    NSNumber *exchangeID = 0;
    NSInteger measureID = 0;
    NSString *query = @"";
    int exchangeGramWeight = 0;
    if (mealPlanItemToExchangeDict != nil) {
        exchangeGramWeight = [[mealPlanItemToExchangeDict valueForKey:@"GramWeight"] intValue];
        exchangeID = [mealPlanItemToExchangeDict valueForKey:@"MeasureID"];
        
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
    
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
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

#pragma mark TIME CHECKS
- (NSInteger)hoursAfterDate:(NSDate *)aDate {
    NSTimeInterval ti = [[NSDate date] timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_HOUR);
}
- (NSInteger)minutesAfterDate:(NSDate *)aDate {
    NSTimeInterval ti = [[NSDate date] timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_MINUTE);
}

#pragma mark LOGIN AUTH DELEGATE METHODS
- (void)getAuthenticateUserFinished:(NSMutableArray *)responseArray {
    
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[responseArray objectAtIndex:0]];
    
    for (id key in dict) {
    }
    
    if (![[dict valueForKey:@"Status"] isEqualToString:@"False"]) {
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setValue:[dict valueForKey:@"MobileGraphic"] forKey:@"splashimage_filename"];
        
        
        if ([[dict valueForKey:@"MobileGraphic"] length] > 0) {
            [self performSelectorInBackground:@selector(downloadFileIfUpdated) withObject:nil];
        }
        
    }
}

- (void)getAuthenticateUserFailed:(NSString *)failedMessage {
    DMLog(@"getAuthenticateUserFailed, value of response is %@", failedMessage);
}

#pragma mark My Moves Assigned RETREIVAL METHODS

#warning TODO: I think this was never implemented (htk)
- (void)saveMyMovesAssignedOnDateToDatabase:(NSMutableArray*)movesArr {

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
        BOOL success = [fm copyItemAtPath:pathForStartingDB toPath:fullPath error:NULL];
    }
    
    return fullPath;
}

#pragma mark SAVE FOOD W UPC METHODS

- (void)saveUPCFood:(int)foodKey {
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
    if (![db open]) {
        
    }
    
    
    NSString *query = [NSString stringWithFormat:@"SELECT f.FoodKey,f.FoodID,f.Name,f.CategoryID, f.Calories, f.Fat, "
                       "f.Sodium, f.Carbohydrates, f.SaturatedFat, f.Cholesterol,f.Protein, "
                       "f.Fiber,f.Sugars, f.Pot,f.A, "
                       "f.Thi, f.Rib,f.Nia, f.B6, "
                       "f.B12,f.Fol,f.C, f.Calc, "
                       "f.Iron,f.Mag,f.Zn,f.ServingSize, "
                       "f.Transfat, f.E, f.D,f.Folate, "
                       "f.Frequency, f.UserID, f.CompanyID, fm.MeasureID, f.UPCA, f.FactualID FROM Food f INNER JOIN FoodMeasure fm ON fm.FoodID = f.FoodKey WHERE f.FoodKey = %i", foodKey];
    
    FMResultSet *rs = [db executeQuery:query];
    int resultCounts = 0;
    
    while ([rs next]) {
        
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithInt:[rs intForColumn:@"FoodKey"]], @"FoodKey",
                              [NSNumber numberWithInt:[rs intForColumn:@"FoodID"]], @"FoodID",
                              [rs stringForColumn:@"Name"], @"Name",
                              [NSNumber numberWithInt:[rs intForColumn:@"CategoryID"]], @"CategoryID",
                              [NSNumber numberWithInt:[rs intForColumn:@"Calories"]], @"Calories",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Fat"]], @"Fat",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Sodium"]], @"Sodium",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Carbohydrates"]], @"Carbohydrates",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"SaturatedFat"]], @"SaturatedFat",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Cholesterol"]], @"Cholesterol",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Protein"]], @"Protein",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Fiber"]], @"Fiber",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Sugars"]], @"Sugars",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Pot"]], @"Pot",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"A"]], @"A",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Thi"]], @"Thi",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Rib"]], @"Rib",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Nia"]], @"Nia",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"B6"]], @"B6",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"B12"]], @"B12",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Fol"]], @"Fol",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"C"]], @"C",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Calc"]], @"Calc",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Iron"]], @"Iron",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Mag"]], @"Mag",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Zn"]], @"Zn",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"ServingSize"]], @"ServingSize",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Transfat"]], @"Transfat",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"E"]], @"E",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"D"]], @"D",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Folate"]], @"Folate",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Frequency"]], @"Frequency",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"UserID"]], @"UserID",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"CompanyID"]], @"CompanyID",
                              [rs stringForColumn:@"UPCA"], @"UPCA",
                              [rs stringForColumn:@"FactualID"], @"FactualID",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"MeasureID"]], @"MeasureID", nil];
        
        if (![[rs stringForColumn:@"UPCA"] isEqualToString:@"empty"]) {
            NSDictionary *scannerDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                         dict, @"scannerDict",
                                         @"SAVE_FOOD", @"action",
                                         nil];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                SaveUPCDataWebService *webservice = [[SaveUPCDataWebService alloc] init];
                webservice.delegate = self;
//                [webservice callWebservice:scannerDict];
            });
        }
        resultCounts++;
    }
    
    [rs close];
}

- (void)saveUPCDataWSFinished:(NSMutableDictionary *)responseDict {
    
    
}

- (void)saveUPCDataWSFailed:(NSString *)failedMessage {
    DMLog(@"Engine saveUPCDataWSFailed");
}

#pragma mark TECH SUPPORT METHODS
-(NSData *)createZipFileOfDatabase {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *baseDocumentPath = [paths objectAtIndex:0];
    NSString *dbSettingsPath = [baseDocumentPath stringByAppendingPathComponent:@"db_settings.plist"];
    
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *appVersion = [NSString stringWithFormat:@"%@ Build %@", version, build];
    
    UIDevice *dev = [UIDevice currentDevice];
    NSString *deviceModel = [[UIDevice currentDevice] machine]; // dev.model;
    NSString *deviceSystemVersion = dev.systemVersion;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *dateString = @"N/A";
    if ([prefs valueForKey:@"lastsyncdate"]) {
        [self.dateformatter setDateFormat:@"M-d-yyyy h:mm:ss a"];
        dateString = [self.dateformatter stringFromDate:[prefs valueForKey:@"lastsyncdate"]];
    }
    
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSString *country = [usLocale displayNameForKey: NSLocaleCountryCode value: countryCode];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          appName, @"appName",
                          appVersion, @"appVersion",
                          deviceModel, @"deviceModel",
                          deviceSystemVersion, @"deviceSystemVersion",
                          dateString, @"last_sync",
                          destinationTimeZone.name, @"time_zone",
                          country, @"country",
                          [prefs valueForKey:@"userid_dietmastergo"], @"user_id",
                          [[prefs valueForKey:@"authkey_dietmastergo"] uppercaseString], @"auth_key",
                          nil];
    
    [dict writeToFile:dbSettingsPath atomically:YES];
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *zipFilePath = [documentsDirectory stringByAppendingPathComponent:@"dietmaster_db.dmgo"];
    ZipArchive *za = [[ZipArchive alloc] init];
    [za CreateZipFile2:zipFilePath Password:@"NRTsKdxpRg$"];
    
    [za addFileToZip:[self databasePath] newname:@"User_DMG.sqlite"];
    [za addFileToZip:dbSettingsPath newname:@"db_settings.plist"];
    
    // Finalize and compress
    BOOL successCompressing = [za CloseZipFile2];
    if (successCompressing) {
        DMLog(@"Compression successful!");
    }
    else {
        DMLog(@"Compression error!");
    }
    
    if([[NSFileManager defaultManager] fileExistsAtPath:dbSettingsPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:dbSettingsPath error:NULL];
    }
    
    return [NSData dataWithContentsOfFile:zipFilePath];
}

#pragma mark Helpers
- (NSDictionary *)getUserRecommendedRatios {
    
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
    if (![db open]) {
        
    }
    
    NSString *query = [NSString stringWithFormat: @"SELECT CarbRatio, ProteinRatio, FatRatio FROM user"];
    
    NSMutableDictionary *ratioDict = [[NSMutableDictionary alloc] init];
    FMResultSet *rs = [db executeQuery:query];
    while ([rs next]) {
        [ratioDict setValue:@([rs doubleForColumn:@"CarbRatio"]/100) forKey:@"CarbRatio"];
        [ratioDict setValue:@([rs doubleForColumn:@"ProteinRatio"]/100) forKey:@"ProteinRatio"];
        [ratioDict setValue:@([rs doubleForColumn:@"FatRatio"]/100) forKey:@"FatRatio"];
    }
    
    [rs close];
    
    return ratioDict;
}

- (NSInteger)getBMR {
    
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
    if (![db open]) {
        
    }
    
    NSString *query = [NSString stringWithFormat: @"SELECT BMR FROM user"];
    
    NSInteger bmrValue = 0;
    
    FMResultSet *rs = [db executeQuery:query];
    while ([rs next]) {
        bmrValue = [rs intForColumn:@"BMR"];
    }
    
    [rs close];
    
    return bmrValue;
}

-(NSMutableArray *)getGroceryFoodDetails:(NSMutableArray *) foods {
    FMDatabase* db = [FMDatabase databaseWithPath:[self databasePath]];
    if (![db open]) {
        
    }
    
    for(NSMutableDictionary *food in foods) {
        
        NSString *query = [NSString stringWithFormat: @"SELECT FoodKey, name, FoodURL, RecipeID, CategoryID FROM Food WHERE name = '%@' ORDER BY FoodURL DESC LIMIT 1", [food valueForKey:@"FoodName"]];
        FMResultSet *rs = [db executeQuery:query];
        while ([rs next]) {
            NSString *FoodURL = [rs stringForColumn:@"FoodURL"];
            if (FoodURL != nil && ![FoodURL isEqualToString:@""]) {
                [food setObject:FoodURL forKey:@"FoodURL"];
            }
            
            int recipeID = [rs intForColumn:@"RecipeID"];
            if (recipeID > 0) {
                [food setObject:[NSNumber numberWithInt:recipeID] forKey:@"RecipeID"];
            }
            
            int catID = [rs intForColumn:@"CategoryID"];
            if (catID > 0) {
                [food setObject:[NSNumber numberWithInt:catID] forKey:@"CategoryID"];
            }
        }
        
        [rs close];

    }
    
    return foods;
}

@end
