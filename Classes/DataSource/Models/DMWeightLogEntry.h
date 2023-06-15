//
//  DMWeightLogEntry.h
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/15/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// The type of weight log entry. Could be Weight or BodyFat.
typedef NS_ENUM(NSUInteger, DMWeightLogEntryType) {
    DMWeightLogEntryTypeWeight = 0,
    DMWeightLogEntryTypeBodyFat = 1
};

/// Represents a weight log entry in the database.
@interface DMWeightLogEntry : NSObject

/// The type of entry, be it weight or body fat.
@property (nonatomic, readonly) DMWeightLogEntryType entryType;

/// Formatted string of what's saved to the database. The Webservice returns Date/Time. We strip time from it.
@property (nonatomic, strong, readonly) NSString *logDateString;
// The amount of weight logged.
@property (nonatomic, strong, readonly) NSNumber *value;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
                         entryType:(DMWeightLogEntryType)entryType NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
