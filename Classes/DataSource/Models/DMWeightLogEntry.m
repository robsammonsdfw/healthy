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
@property (nonatomic, strong, readwrite) NSString *logDateTimeString;
@property (nonatomic, strong, readwrite) NSNumber *value;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation DMWeightLogEntry

- (instancetype)init {
    return [self initWithDictionary:@{} entryType:DMWeightLogEntryTypeWeight];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
                         entryType:(DMWeightLogEntryType)entryType {
    self = [super init];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        
        _entryType = entryType;
        
        // Check if value came from server.
        if (dictionary[@"Value"]) {
            _value = ValidNSNumber(dictionary[@"Value"]);
        } else {
            // Came from local database.
            _value = ValidNSNumber(dictionary[@"weight"] ?: dictionary[@"bodyfat"]);
        }

        // Format for device.
        NSString *dateTimeString = ValidString(dictionary[@"LogDate"] ?: dictionary[@"logtime"]);
        NSArray *dateArray = [dateTimeString componentsSeparatedByString:@" "];
        NSString *dateString = @"";
        if (dateArray.count) {
            dateString = dateArray[0];
        }
        
        // Format date for server.
        [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
        // Re-attach the time as midnight. TBH, not sure why the system does this. Perhaps to standardize
        // time zones on the server?
        NSString *dateTimeStandardizedString = [NSString stringWithFormat:@"%@ 12:00:00 AM", dateString];

        _logDateString = dateString;
        _logDateTimeString = dateTimeStandardizedString;
    }
    return self;
}

- (NSString *)description {
    NSString *base = [super description];
    return [NSString stringWithFormat:@"%@: %@", base, [self listPropertiesAsString]];
}

@end
