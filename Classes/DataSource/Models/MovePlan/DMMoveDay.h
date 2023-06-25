//
//  DMMoveDay.h
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/24/23.
//

#import <Foundation/Foundation.h>
#import "DMMoveRoutine.h"

NS_ASSUME_NONNULL_BEGIN

/// Represents a day of moves for a DMMovePlan.
@interface DMMoveDay : NSObject
/// The ID of the day. Same as UserPlanDateID.
@property (nonatomic, strong, readonly) NSNumber *dayId;
/// The plan the day is associated with.
@property (nonatomic, strong, readonly) NSNumber *planId;
/// The date for the day. Stored as a string to keep consistency
/// with the backend and other existing logic.
@property (nonatomic, copy, readonly) NSString *planDate;

/// The routine that should be followed for the day. NOTE: This will not
/// be populated unless you call -setDayRoutines: with data from the
/// database.
@property (nonatomic, strong, readonly) NSArray<DMMoveRoutine *> *routines;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

/// Returns the object as a dictionary with the keys that match database and webservice fields.
- (NSDictionary *)dictionaryRepresentation;

/// Sets the day's routines. It will ignore routines
/// where the dayIds do not match.
- (void)setDayRoutines:(NSArray<DMMoveRoutine *> *)routines;

@end

NS_ASSUME_NONNULL_END
