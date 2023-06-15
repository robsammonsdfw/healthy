//
//  WeightLogEntry.m
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/15/23.
//

#import "DMWeightLogEntry.h"


@interface DMWeightLogEntry()
@property (nonatomic, readwrite) DMWeightLogEntryType entryType;
@property (nonatomic, strong, readwrite) NSString *logDateString;
@property (nonatomic, strong, readwrite) NSNumber *value;
@end

@implementation DMWeightLogEntry

- (instancetype)init {
    return [self initWithDictionary:@{} entryType:DMWeightLogEntryTypeWeight];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
                         entryType:(DMWeightLogEntryType)entryType {
    self = [super init];
    if (self) {
        _entryType = entryType;
        
        _value = ValidNSNumber(dictionary[@"Value"]);
        
        NSString *dateTimeString = ValidString(dictionary[@"LogDate"]);
        NSArray *dateArray = [dateTimeString componentsSeparatedByString:@" "];
        NSString *dateString = @"";
        if (dateArray.count) {
            dateString = dateArray[0];
        }
        _logDateString = dateString;
    }
    return self;
}

@end
