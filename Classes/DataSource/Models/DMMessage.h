//
//  DMMessage.h
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/15/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Message sent between DMG user and coach.
@interface DMMessage : NSObject

@property (nonatomic, strong, readonly) NSString *messageId;
@property (nonatomic, strong, readonly) NSString *text;
@property (nonatomic, strong, readonly) NSDate *dateSent;
@property (nonatomic, strong, readonly) NSString *senderName;
@property (nonatomic) BOOL isRead;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

/// Returns a SQL statement string to replace into the database.
- (NSString *)replaceIntoSQLString;

/// Updates the text, sender, and date. This is used to create a message that was accepted by the server.
- (void)updateText:(NSString *)text senderName:(NSString *)senderName dateSent:(NSDate *)dateSent;

@end

NS_ASSUME_NONNULL_END
