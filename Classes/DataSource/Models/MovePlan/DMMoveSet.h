//
//  DMMoveSet.h
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/24/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Represents an exercise and set information for a DMMovePlan's Day.
@interface DMMoveSet : NSObject
/// The ID of set. Same as SetID.
@property (nonatomic, strong, readonly) NSNumber *setId;

/// The ID of the Plan Day's Move this is associated with.
/// Same as UserPlanMoveID. Reanmed for clarity.
@property (nonatomic, strong, readonly) NSNumber *routineId;

/// ID of the plan day this belongs to. Same as UserPlanDateID
@property (nonatomic, strong, readonly) NSNumber *dayId;

/// The number of the set, e.g. 1, 2, 3.
@property (nonatomic, strong, readonly) NSNumber *setNumber;

/// A unit to describe the set. Could be reps, miles, etc.
@property (nonatomic, strong, readonly) NSNumber *unitOneId;
@property (nonatomic, strong, readonly) NSNumber *unitOneValue;

/// A unit to descri
/// be the set. Could be rest, pounds, etc.
@property (nonatomic, strong, readonly) NSNumber *unitTwoId;
@property (nonatomic, strong, readonly) NSNumber *unitTwoValue;

/// Creates a new set with default values. Note: setId will be nil.
+ (instancetype)setWithDefaultValues;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

/// Returns the object as a dictionary with the keys that match database and webservice fields.
- (NSDictionary *)dictionaryRepresentation;

@end

NS_ASSUME_NONNULL_END
