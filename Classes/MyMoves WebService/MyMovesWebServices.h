//
//  MyMovesWebServices.h
//  MyMoves
//
//  Created by Samson  on 29/01/19.
//

#import <Foundation/Foundation.h>

@protocol WSWorkoutList,WSCategoryList,WSGetUserWorkoutplanOffline;

@interface MyMovesWebServices : NSObject <NSURLConnectionDelegate, NSXMLParserDelegate, NSURLSessionDelegate> {
    BOOL recordResults;
    BOOL SendAllServerData;
    // Vars to Hold Data for Session
    int tempID;
    NSTimer *timeOutTimer;
    NSString * tempStr;
}

@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSString *apiRequestType;
@property (nonatomic) BOOL myBool;

@property (nonatomic, weak) id<WSWorkoutList> WSWorkoutListDelegate;
@property (nonatomic, weak) id<WSCategoryList> WSCategoryListListDelegate;
@property (nonatomic, weak) id<WSGetUserWorkoutplanOffline> WSGetUserWorkoutplanOfflineDelegate;

@property (nonatomic, strong) NSMutableData *webData;
@property (nonatomic, strong) NSMutableString *soapResults;
@property (nonatomic, strong) NSXMLParser *xmlParser;

-(void)callGetWebservice:(NSDictionary *)requestDict;
-(void)timeOutWebservice:(NSTimer *)theTimer;

- (NSArray *)loadExerciseFromDb;
-(NSMutableArray *)loadWorkoutFromDb;

-(NSMutableArray *)loadListOfTitleToDb;
/// Loads a list of the categories from the database. Also called "Bodyparts".
-(NSArray *)loadListOfBodyPart;
/// Loads a list of tags from the database.
- (NSArray *)loadListOfTags;

-(NSMutableArray *)loadFilteredListOfTitleToDb;
-(NSMutableArray *)loadCategoryFilteredListOfTitleToDb:(int)catId;

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

-(void)updateUserCommentsToDb:(NSString *)exerciseDate commentsToUpdate:(NSString *)comments;
-(NSMutableArray *)loadUserComments;

-(void)deleteWorkoutFromDb:(int)workoutTempId;

-(void)saveDeletedExerciseToDb:(int)workoutTempId UserId:(int)userId WorkoutUserDateID:(int)workoutUserDateID;

-(NSMutableArray *)loadDeletedExerciseFromDb;

-(void)updateTimeToDb:(NSString *)WorkingStatus timeToSet:(NSString *)CurrentDuration excerciseDict:(NSDictionary *)dict;
-(NSMutableArray *)loadWorkoutTime;

-(void)saveMovesTagsCategoriesToDb:(NSDictionary *)movesDict;

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

-(NSMutableArray *)loadFirstHeaderTable;
-(NSMutableArray *)loadSecondHeaderTable;


//new API
-(NSMutableArray *)MobileUserPlanList;
- (NSMutableArray *)MobileUserPlanDateList;
- (NSMutableArray *)MobileUserPlanMoveList;
- (NSMutableArray *)MobileUserPlanMoveSetList;
- (NSMutableArray *)loadUserPlanListFromDb;
- (NSMutableArray *)loadUserPlanDateListFromDb;
- (NSMutableArray *)loadUserPlanMoveListFromDb;
- (NSMutableArray *)loadUserPlanMoveSetListFromDb;
- (NSMutableArray *)loadListOfMovesFromDb;

-(void)serverUserPlans:(NSDictionary *)planListDict;

-(void)getMyMovesData;

@end


@protocol WSWorkoutList <NSObject>
- (void)getWorkoutListFinished:(NSDictionary *)responseArray;
- (void)getWorkoutListFailed:(NSString *)failedMessage;
@end

@protocol WSCategoryList <NSObject>
- (void)getCategoryListFinished:(NSDictionary *)responseArray;
- (void)getCategoryListFailed:(NSString *)failedMessage;
@end

@protocol WSGetUserWorkoutplanOffline <NSObject>
- (void)getUserWorkoutplanOfflineListFinished:(NSDictionary *)responseArray;
- (void)getUserWorkoutplanOfflineListFailed:(NSString *)failedMessage;
@end
