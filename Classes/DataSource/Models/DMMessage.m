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
        
        NSString *dateSent = ObjectOrEmptyString(dictionary[@"DateTime"]);
        if (dateSent.length) {
            _dateSent = [_dateFormatter dateFromString:dateSent];
        }
        
        _messageId = ObjectOrEmptyString(dictionary[@"MessageID"]);
        _senderName = ObjectOrEmptyString(dictionary[@"Sender"]);
        
        // Escape quotes.
        NSString *text = [ObjectOrEmptyString(dictionary[@"Text"]) stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        _text = text;
        
        _isRead = [ObjectOrEmptyString(dictionary[@"MsgRead"]) isEqualToString:@"True"] ? YES : NO;
    }
    return self;
}

@end
