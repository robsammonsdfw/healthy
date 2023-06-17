//
//  DMMessage.m
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/15/23.
//

#import "DMMessage.h"

@interface DMMessage()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong, readwrite) NSString *messageId;
@property (nonatomic, strong, readwrite) NSString *text;
@property (nonatomic, strong, readwrite) NSDate *dateSent;
@property (nonatomic, strong, readwrite) NSString *senderName;
@end

@implementation DMMessage

- (instancetype)init {
    return [self initWithDictionary:@{}];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
        
        // Note: YES! There is a typo on the server. It is DsteTime, not DateTime.
        NSString *dateSent = ValidString(dictionary[@"DsteTime"]);
        if (dateSent.length) {
            _dateSent = [_dateFormatter dateFromString:dateSent];
        }
        
        _messageId = ValidString(dictionary[@"MessageID"]);
        _senderName = ValidString(dictionary[@"Sender"]);
        
        // Escape quotes.
        NSString *text = dictionary[@"Text"];
        if (text) {
            [text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            _text = text;
        }
        
        _isRead = [ValidString(dictionary[@"MsgRead"]) isEqualToString:@"True"] ? YES : NO;
    }
    return self;
}

- (NSString *)replaceIntoSQLString {
    NSString *sqlString = [NSString stringWithFormat:@"REPLACE INTO Messages "
                            "(Text, Sender, Date, Id, Read) VALUES (\"%@\", \"%@\", %f, %@, %d)",
                           self.text,
                           self.senderName,
                           [self.dateSent timeIntervalSince1970],
                           self.messageId,
                           self.isRead];
    return sqlString;
}

- (void)updateText:(NSString *)text senderName:(NSString *)senderName dateSent:(NSDate *)dateSent {
    self.text = [text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    self.senderName = senderName;
    self.dateSent = dateSent;
}

#pragma mark - Equality

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[DMMessage class]]) {
        return NO;
    }
    
    return [self isEqualToMessage:object];
}

- (BOOL)isEqualToMessage:(DMMessage *)message {
    if (![self.messageId isEqualToString:message.messageId]) {
        return NO;
    }

    return YES;
}

- (NSUInteger)hash {
    return [self.messageId hash];
}

@end
