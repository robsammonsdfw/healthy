//
//  DMMessagesDataProvider.h
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 7/1/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Notification fired when messages are done updating. Used to update the
/// app icon badge.
extern NSString * const UpdatingMessageNotification;

/// Provides data for the Messages feature.
@interface DMMessagesDataProvider : NSObject

/// Returns the unread messages.
- (NSArray<DMMessage *> *)unreadMessages;
/// Returns how many messages are unread in the database.
- (NSInteger)unreadMessageCount;
/// Sets a message read.
- (void)setReadedMessageId:(NSNumber *)messageId;
/// Returns the most recent message Id stored in the database.
- (NSNumber *)getLastMessageId;
/// Syncronizes messages now.
- (void)syncMessagesWithCompletionBlock:(completionBlockWithError)completionBlock;

@end

NS_ASSUME_NONNULL_END
