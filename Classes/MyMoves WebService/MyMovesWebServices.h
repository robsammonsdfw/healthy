//
//  MyMovesWebServices.h
//  MyMoves
//
//  Created by Samson  on 29/01/19.
//

#import <Foundation/Foundation.h>
#import "DMMovePickerRow.h"
@class DMMove;
@class DMMoveCategory;
@class DMMoveTag;

@protocol WSGetUserWorkoutplanOffline;

@interface MyMovesWebServices : NSObject <NSURLConnectionDelegate, NSXMLParserDelegate, NSURLSessionDelegate> {
    BOOL recordResults;
    BOOL SendAllServerData;
    // Vars to Hold Data for Session
    int tempID;
    NSTimer *timeOutTimer;
    NSString * tempStr;
}

@property (nonatomic, weak) id<WSGetUserWorkoutplanOffline> WSGetUserWorkoutplanOfflineDelegate;

- (NSArray *)loadExerciseFromDb;
-(NSMutableArray *)loadWorkoutFromDb;

/// Loads a list of the categories from the database. Also called "Bodyparts".
- (NSArray<DMMoveCategory *> *)loadListOfBodyPart;
/// Loads a list of tags from the database.
- (NSArray<DMMoveTag *> *)loadListOfTags;
/// Loads an array of moves (exercises) from the local database. To filter, provide a
/// category or tag object to filter by.
- (NSArray<DMMove *> *)getMovesFromDatabaseWithCategoryFilter:(DMMoveCategory *)categoryFilter
                                                    tagFilter:(DMMoveTag *)tagFilter
                                                   textSearch:(NSString *)textSearch;

-(NSMutableArray *)loadWorkoutSynParamFromDb;

-(NSMutableArray *)loadAddWorkoutTemplate;

-(void)offlineSyncApi;
-(void)clearTableData;
-(void)clearTableDataS;
-(void)clearedDataFromWeb:(NSString *)uniqueId;

-(void)addMovesToDb:(NSDictionary *)dict SelectedDate:(NSDate*)planDate planName:(NSString *)planName categoryName:(NSString*)CatName CategoryID:(int)categoryID tagsName:(NSString*)tag TagsId:(int)tagsId status:(NSString*)status PlanNameUnique:(NSString*)PlanNameUnique DateListUnique:(NSString*)DateListUnique MoveNameUnique:(NSString*)MoveNameUnique;

-(void)mobilePlanDateList:(NSDate *)planDate DateUniqueID:(NSString *)uniqueID Dict:(NSDictionary *)dict;
-(void)mobilePlanMoveList:(NSString *)MoveName VideoLink:(NSString *)VideoLink Notes:(NSString *)Notes UniqueID:(NSString *)UniqueID ParentUniqueID:(NSString *)ParentUniqueID MoveID:(int)MoveID PlanDateStr:(NSString *)PlanDateStr;
-(void)mobilePlanMoveSetList:(NSString *)ParentUniqueID setDict:(NSDictionary *)dict;

-(void)deleteMoveFromDb:(NSString *)UniqueID;
-(void)deleteSetFromDb:(NSString *)UniqueID;

-(void)updateChangesFromWeb:(NSString *)uniqueID;
-(void)updateCheckBoxStatusToDb:(NSString *)UniqueID checkBoxStatus:(NSString *)checkBoxStatus;

-(void)updateFromNewToNormalToDb;
-(void)updateFromChangedToNormalToDb;

-(void)updateFirstHeaderValue:(int)unit1ID ParentUniqueID:(NSString *)ParentUniqueID;
-(void)updateSecondHeaderValue:(int)unit2ID ParentUniqueID:(NSString *)ParentUniqueID;

-(void)updateSetInFirstColumn:(int)unit1Value uniqueID:(NSString *)uniqueID;
-(void)updateSetInSecondColumn:(int)unit2Value uniqueID:(NSString *)uniqueID;

-(void)addExerciseToDb:(NSDictionary *)dict workoutDate:(NSDate*)date userId:(int)userID categoryName:(NSString*)name CategoryID:(int)categoryID tagsName:(NSString*)tag TagsId:(int)tagsId templateName:(NSString*)templateNameStr WorkoutDateID:(int)WorkoutDateID;

-(void)addExerciseToDb:(NSDictionary *)dict workoutDate:(NSDate*)date userId:(int)userID categoryName:(NSString*)name CategoryID:(int)categoryID tagsName:(NSString*)tag TagsId:(int)tagsId templateName:(NSString*)templateNameStr WorkoutTempId:(int)workoutTempId WorkoutDateID:(int)WorkoutDateID;

-(void)deleteWorkoutFromDb:(int)workoutTempId;

-(void)saveDeletedExerciseToDb:(int)workoutTempId UserId:(int)userId WorkoutUserDateID:(int)workoutUserDateID;

-(NSMutableArray *)loadDeletedExerciseFromDb;

-(void)updateTimeToDb:(NSString *)WorkingStatus timeToSet:(NSString *)CurrentDuration excerciseDict:(NSDictionary *)dict;

-(void)updateTimeForExercise:(int)WorkoutTemplateId Dict:(NSDictionary *)dict WorkoutTimer:(NSString*)WorkoutTime;
-(void)updateWorkoutToDb:(NSString *)exerciseDate;
-(void)updateSetsForExercise:(int)WorkoutTemplateId Dict:(NSDictionary *)dict;
-(void)addSetsForExercise:(int)WorkoutUserDateId Dict:(NSDictionary *)dict;
-(void)deleteSetsFromDB:(int)WorkoutMethodValueID;
-(NSMutableArray *) filterObjectsByKeys:(NSString *) key array:(NSArray *)array;

-(NSMutableArray *)loadSetsToBeAddedFromDb;
-(NSMutableArray *)loadSetsToBeUpdatedFromDb;
-(NSMutableArray *)loadSetsToBeDeletedFromDb;
-(NSMutableArray *)loadTable1Header;
-(NSMutableArray *)loadTable2Header;

/// Loads the list of options for the MyMoves set list in first option.
-(NSArray<DMMovePickerRow *> *)loadFirstHeaderTable;
/// Loads the list of options for the MyMoves set list in the second option.
-(NSArray<DMMovePickerRow *> *)loadSecondHeaderTable;

//new API
-(NSMutableArray *)MobileUserPlanList;
- (NSMutableArray *)MobileUserPlanDateList;
- (NSMutableArray *)MobileUserPlanMoveList;
- (NSMutableArray *)MobileUserPlanMoveSetList;
- (NSArray *)loadUserPlanListFromDb;
- (NSArray *)loadUserPlanDateListFromDb;
- (NSMutableArray *)loadUserPlanMoveListFromDb;
- (NSMutableArray *)loadUserPlanMoveSetListFromDb;
- (NSMutableArray *)loadListOfMovesFromDb;

-(void)serverUserPlans:(NSDictionary *)planListDict;

/// Fetches MyMoves data from the server and saves it locally.
/// This includes Exercises (Moves) and Tags / Categories.
- (void)getMyMovesData;

@end

@protocol WSGetUserWorkoutplanOffline <NSObject>
- (void)getUserWorkoutplanOfflineListFinished:(NSDictionary *)responseArray;
- (void)getUserWorkoutplanOfflineListFailed:(NSString *)failedMessage;
@end
