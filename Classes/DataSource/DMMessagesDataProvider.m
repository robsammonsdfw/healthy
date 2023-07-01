//
//  DMMessagesDataProvider.m
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 7/1/23.
//

#import "DMMessagesDataProvider.h"

@interface DMMessagesDataProvider()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong, readonly) FMDatabase *database;
@end

NSString * const UpdatingMessageNotification = @"UpdatingMessageNotification";

@implementation DMMessagesDataProvider

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

- (NSInteger)unreadMessageCount {
    FMDatabase* dataBase = [self database];
    if (![dataBase open]) {
        return 0;
    }
    NSString *query = @"SELECT * FROM Messages WHERE Sender = 0 AND Read = 0";
    
    FMResultSet *rs = [dataBase executeQuery:query];
    NSInteger count = 0;
    while ([rs next]) {
        ++count;
    }
    [rs close];
    
    return count;
}

- (NSNumber *)getLastMessageId {
    NSNumber *messageId = [DMDatabaseUtilities getMaxValueForColumn:@"MessageID" inTable:@"Messages"];
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

@end
