//
//  MyMovesDataProvider.h
//
//  Created by Henry T. Kirk  on 6/26/2023.
//

#import <Foundation/Foundation.h>
#import "DMConstants.h"
@class DMMove;
@class DMMoveCategory;
@class DMMoveTag;
@class DMMovePlan;
@class DMMoveDay;
@class DMMovePickerRow;
@class DMMoveSet;
@class DMMoveRoutine;

/// Data provider for MyMoves.
@interface MyMovesDataProvider : NSObject

#pragma mark - Local Data

/// Loads a list of the categories from the database. Also called "Bodyparts".
- (NSArray<DMMoveCategory *> *)loadListOfBodyPart;
/// Loads a list of tags from the database.
- (NSArray<DMMoveTag *> *)loadListOfTags;
/// Loads an array of moves (exercises) from the local database. To filter, provide a
/// category or tag object to filter by.
- (NSArray<DMMove *> *)getMovesFromDatabaseWithCategoryFilter:(DMMoveCategory *)categoryFilter
                                                    tagFilter:(DMMoveTag *)tagFilter
                                                   textSearch:(NSString *)textSearch;

/// Gets all of the move plans for the current user.
- (NSArray<DMMovePlan *> *)getUserMovePlans;
/// Returns the "custom" move plan for a user when they wish to add a move.
/// No "move" should be added to a perscribed plan.
/// If one doesn't exist, it will be created, saved to DB and returned.
- (DMMovePlan *)getUserCustomMovePlan;
/// Saves the user plan object provided. Overwrites existing data.
- (void)saveUserCustomMovePlan:(DMMovePlan *)movePlan;
/// Gets the plan for the given planId.
- (DMMovePlan *)getUserMovePlanForPlanId:(NSNumber *)planId;
/// Gets the move days for the given move plan.
- (NSArray<DMMoveDay *> *)getUserPlanDaysForPlanId:(NSNumber *)planId;
/// Gets the user plan date list from the local database. Returns ALL data.
- (NSArray<DMMoveDay *> *)getUserPlanDays;
/// Gets the move day for the ID provided.
- (DMMoveDay *)getUserPlanDayForDayId:(NSNumber *)dayId;
/// Returns the array of move plans for the given date. Empty if none found.
- (NSArray<DMMoveDay *> *)getUserPlanDaysForDate:(NSDate *)date;
/// Gets the day for the custom user plan. Nil if no day added.
- (DMMoveDay *)getCustomUserPlanDayForDate:(NSDate *)date;
/// Gets all of the move routines for a given dayID.
- (NSArray<DMMoveRoutine *> *)getUserPlanRoutinesForDayID:(NSNumber *)dayId;
/// Gets the move routine for the given routine Id.
- (DMMoveRoutine *)getUserPlanRoutineForRoutineId:(NSNumber *)routineId;
/// Gets all sets for the current user.
- (NSArray<DMMoveSet *> *)getUserPlanMoveSets;
/// Gets all of the sets for a given routineID.
- (NSArray<DMMoveSet *> *)getUserPlanMoveSetsForRoutineID:(NSNumber *)routineId;
/// Gets a move object (exercise) for the given MoveID.
- (DMMove *)getMoveForID:(NSNumber *)moveId;
/// Sets the move completed for the routine specified.
- (BOOL)setMoveCompleted:(BOOL)completed forRoutine:(DMMoveRoutine *)routine;

/// Updates the option selected for the provided Set.
- (void)setFirstUnitId:(NSNumber *)unitId forMoveSet:(DMMoveSet *)moveSet;
- (void)setSecondUnitId:(NSNumber *)unitId forMoveSet:(DMMoveSet *)moveSet;
/// Updates the value for the provided set.
- (void)setFirstUnitValue:(NSNumber *)unitValue forMoveSet:(DMMoveSet *)moveSet;
- (void)setSecondUnitValue:(NSNumber *)unitValue forMoveSet:(DMMoveSet *)moveSet;

/// Ads a new move day to the date provided and plan.
- (NSNumber *)addMoveDayToDate:(NSDate *)date toMovePlan:(DMMovePlan *)movePlan;

/// Adds a new move set to the given routine.
/// NOTE: If the DMMoveSet passed does have a setId set, it will
/// create one. Re-fetch from the database to refresh the object.
/// Returns the setId that was saved.
- (NSNumber *)addMoveSet:(DMMoveSet *)moveSet toRoutine:(DMMoveRoutine *)routine;
/// Removes a set from the routine by marking the status to "Deleted".
- (void)deleteMoveSet:(DMMoveSet *)moveSet;
/// Sets a routine to be deleted by marking the status to "Deleted".
- (void)deleteMoveRoutine:(DMMoveRoutine *)moveRoutine;
/// Adds the routine to the moveday provided and saves to database.
/// NOTE: If the DMMoveRoutine passed does have a routineId set, it will
/// create one. Re-fetch from the database to refresh the object.
/// Returns the routineId that was saved.
- (NSNumber *)addMoveRoutine:(DMMoveRoutine *)moveRoutine toMoveDay:(DMMoveDay *)moveDay;

/// Removes all data that is present in the local database.
- (void)clearTableData;
/// Deletes all rows from the tables where status = "Deleted".
/// Should be called after a successful upsync.
- (void)removeRowsWithDeletedStatus;

#pragma mark - Fetch

/// Fetches from the server all of the user's plan data.
- (void)fetchAllUserPlanDataWithCompletionBlock:(completionBlockWithError)completionBlock;

/// Fetches MyMoves data from the server and saves it locally.
/// This includes Exercises (Moves) and Tags / Categories.
- (void)getMyMovesDataWithCompletionBlock:(completionBlockWithError)completionBlock;

@end
