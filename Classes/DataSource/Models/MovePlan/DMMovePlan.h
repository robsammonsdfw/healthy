//
//  DMMovePlan.h
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/23/23.
//

#import <Foundation/Foundation.h>
#import "DMMoveDay.h"

NS_ASSUME_NONNULL_BEGIN

/// Represents a User's Move Plan.
@interface DMMovePlan : NSObject

@property (nonatomic, strong, readonly) NSNumber *planId;
@property (nonatomic, strong, readonly) NSNumber *userId;
@property (nonatomic, copy, readonly) NSString *planName;
@property (nonatomic, copy, readonly) NSString *lastUpdated;
@property (nonatomic, copy, readonly) NSString *notes;
@property (nonatomic, copy, readonly) NSString *uniqueId;
@property (nonatomic, copy, readonly) NSString *status;
@property (nonatomic, copy, readonly) NSString *syncResult;
/// The dates the user should be exercising per the plan.
/// Note: This is not automatically set. Must be set by calling
/// -setMovePlanDays: and passing data.
@property (nonatomic, strong, readonly) NSArray<DMMoveDay *> *moveDays;

/// Returns a new instance setup as a custom user plan.
+ (instancetype)customUserPlan;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

/// If this plan is a user's custom plan, where they added exercises to.
- (BOOL)isCustomUserPlan;

/// Returns the object as a dictionary with the keys that match database and webservice fields.
- (NSDictionary *)dictionaryRepresentation;

/// Returns a SQL statement string to replace into the database.
- (NSString *)replaceIntoSQLString;

/// Sets the plan's days (dates to workout). It will ignore days
/// where the planId do not match.
- (void)setMovePlanDays:(NSArray<DMMoveDay *> *)moveDays;

@end

NS_ASSUME_NONNULL_END
