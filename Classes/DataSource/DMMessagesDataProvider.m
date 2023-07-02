//
//  DMMessagesDataProvider.m
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 7/1/23.
//

#import "DMMessagesDataProvider.h"

#import "DMMessage.h"

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

- (void)saveMessageText:(NSString *)text withCompletionBlock:(completionBlockWithObject)completionBlock {
    if (!text.length) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(nil, nil);
            }
        });
        return;
    }

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
    
    UserDataFetcher *fetcher = [[UserDataFetcher alloc] init];
    [fetcher saveMessageWithText:text completion:^(DMMessage *message, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(message, error);
            }
        });
    }];
}

- (void)processIncomingMessages:(NSArray<DMMessage *> *)messages {
    if (!messages.count) {
        return;
    }
    FMDatabase* db = [self database];
    if (![db open]) {
    }
    
    [db beginTransaction];
    for (DMMessage *message in messages) {
        NSString *sqlQuery = [message replaceIntoSQLString];
        [db executeUpdate:sqlQuery];
        if ([db hadError]) {
            DM_LOG(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }
    [db commit];
}

- (NSArray<DMMessage *> *)unreadMessages {
    FMDatabase* db = [self database];
    if (![db open]) {
    }
    // Sender = 0 means it was sent by an advisor or coach. Sender will be >0
    // if it was sent by the current user.
    NSString *query = @"SELECT * FROM Messages WHERE Sender = 0 AND Read = 0";
    
    FMResultSet *rs = [db executeQuery:query];
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
    FMDatabase* db = [self database];
    if (![db open]) {
        return 0;
    }
    NSString *query = @"SELECT * FROM Messages WHERE Sender = 0 AND Read = 0";
    
    FMResultSet *rs = [db executeQuery:query];
    NSInteger count = 0;
    while ([rs next]) {
        ++count;
    }
    [rs close];
    
    return count;
}

- (void)setReadedMessageId:(NSNumber *)messageId {
    FMDatabase* db = [self database];
    if (![db open]) {
        return;
    }
    [db beginTransaction];
    NSString *sqlQuery = [NSString stringWithFormat:@"UPDATE Messages SET Read = 1 "
                          "WHERE Id = %@", messageId];
    [db executeUpdate:sqlQuery];
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = [self unreadMessageCount];
}

- (NSDictionary<NSString *, DMMessage *> *)getMessagesByDate {
    FMDatabase  *db = [self database];
    if (![db open]) {
        return @{};
    }

    NSString *query = [NSString stringWithFormat: @"SELECT * FROM Messages ORDER BY Date ASC"];
    FMResultSet *rs = [db executeQuery:query];
    
    NSMutableDictionary *messagesDict = [NSMutableDictionary dictionary];
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        DMMessage *message = [[DMMessage alloc] initWithDictionary:dict];
        
        [self.dateFormatter setDateStyle:NSDateFormatterFullStyle];
        NSString *dateString = [self.dateFormatter stringFromDate:message.dateSent];
        if (messagesDict[dateString]) {
            NSMutableArray *messages = messagesDict[dateString];
            [messages addObject:message];
        } else {
            NSMutableArray *messages = [NSMutableArray array];
            [messages addObject:message];
            messagesDict[dateString] = messages;
        }
    }
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [rs close];
    
    return [messagesDict copy];
}

@end
