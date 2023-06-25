//
//  DMMoveRoutine.h
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/24/23.
//

#import <Foundation/Foundation.h>
#import "DMMoveSet.h"

NS_ASSUME_NONNULL_BEGIN

/// Represents the exercise and number of sets for a Move Plan's Day.
@interface DMMoveRoutine : NSObject
/// The ID of this routine. Same as UserPlanMoveID in the Database.
/// Renamed to provide clarity.
@property (nonatomic, strong, readonly) NSNumber *routineId;

/// The ID of the Move associated with this set. Same as MoveID.
@property (nonatomic, strong, readonly) NSNumber *moveId;
/// The move for this routine. NOTE: This is not populated unless
/// you call -setMove:.
@property (nonatomic, strong, readonly) DMMove *move;

/// The ID of the day associated with the routine. Same as UserPlanDateID.
@property (nonatomic, strong, readonly) NSNumber *dayId;

/// If the routine is completed. NOTE: Changing the value
/// here does NOT update the database. It's for tracking a user's
/// progress. Save to the database separately.
@property (nonatomic) NSNumber *isCompleted;

/// The sets to be completed for this routine. NOTE: This value
/// will not be populated unless you call -setRoutineSets: with
/// data from the database.
@property (nonatomic, strong, readonly) NSArray<DMMoveSet *> *sets;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

/// Returns the object as a dictionary with the keys that match database and webservice fields.
- (NSDictionary *)dictionaryRepresentation;

/// Sets the routine's sets. It will ignore exerciess
/// where the routineId do not match.
- (void)setRoutineSets:(NSArray<DMMoveSet *> *)sets;

/// Sets the move on the object. This is not set during init.
- (void)setMove:(DMMove *)move;

@end

NS_ASSUME_NONNULL_END
