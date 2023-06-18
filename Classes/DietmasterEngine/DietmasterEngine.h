//
//  DietmasterEngine.h
//  DietMasterGo
//
//  Created by Henry Kirk on 2/4/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SoapWebServiceEngine.h"
// get data
#import "GetDataWebService.h"

#import "SaveUPCDataWebService.h"
#import "FactualAPI.h"
#import "FactualQuery.h"

@class DMMessage;
@class DMUser;

@protocol WSGetFoodDelegate;

extern NSString * const UpdatingMessageNotification;

typedef void (^DMGBooleanResponseBlock)(BOOL success, NSError *error);

@protocol SyncDatabaseDelegate;
@protocol UPSyncDatabaseDelegate;

@interface DietmasterEngine : NSObject <WSSyncFavoriteFoodsDelegate, WSSyncFavoriteMealsDelegate,
WSSyncFavoriteMealItemsDelegate, WSSyncExerciseLogDelegate,WSSyncExerciseLogNewDelegate, WSSaveMealDelegate, WSSaveMealItemDelegate, WSSaveExerciseLogsDelegate, WSGetFoodDelegate, WSSaveWeightLogDelegate, WSSaveFoodDelegate, WSSaveFavoriteFoodDelegate, WSSaveFavoriteMealDelegate, WSSaveFavoriteMealItemDelegate, SaveUPCDataWSDelegate, FactualAPIDelegate, GetDataWSDelegate> {
    
    NSMutableDictionary *exerciseSelectedDict;
    // Dict for Food Selected Detail
    NSMutableDictionary *foodSelectedDict;
    
    NSNumber *currentWeight;
    
    // For Food Log - "Edit" or "Save" functionality
    NSString *taskMode;
    
    NSDate *dateSelected;
    NSString *dateSelectedFormatted;
    
    NSNumber *selectedMealID; // selected ID of meal working on.
    
    NSNumber *selectedCategoryID; // for editing My Foods.
    NSNumber *selectedMeasureID; // for editing My Foods.
    
    // delegates
    int syncsCompleted;
    int upsyncsCompleted;
    int syncsToComplete;
    int upsyncsToComplete;
    int syncsFailed;
    int upsyncsFailed;
    
    // Meal Plan
    NSMutableArray *mealPlanArray;
    NSMutableArray *myMovesAssignedArray;

    // For detail view
    BOOL isMealPlanItem;
    NSMutableDictionary *mealPlanItemToExchangeDict;
    int indexOfItemToExchange;
    int selectedMealPlanID;
    BOOL didInsertNewFood;
    // Grocery List
    NSMutableArray *groceryArray;
    
    // Factual API
    FactualAPI* _apiObject;
    FactualQueryResult* _queryResult;
    FactualAPIRequest* _activeRequest;
    
    // Get Data
    __block BOOL getDataComplete;
    __block BOOL getDataDidFail;
    dispatch_semaphore_t semaphore;
    
    
}

// delegate
@property (nonatomic, weak) id<WSGetFoodDelegate> wsGetFoodDelegate;

@property (nonatomic, weak) id<SyncDatabaseDelegate> syncDatabaseDelegate;
@property (nonatomic, weak) id<UPSyncDatabaseDelegate> syncUPDatabaseDelegate;

@property (nonatomic, strong) NSMutableDictionary *exerciseSelectedDict;
@property (nonatomic, strong) NSMutableDictionary *foodSelectedDict;
@property (nonatomic, strong) NSNumber *currentWeight;

//HHT apple watch
@property (nonatomic,retain) NSNumber *userHeight;
@property (nonatomic) int userGender;

@property (nonatomic, strong) NSString *taskMode;
@property (nonatomic, strong) NSDate *dateSelected;
@property (nonatomic, strong) NSString *dateSelectedFormatted;
@property (nonatomic, strong) NSNumber *selectedMealID;

@property (nonatomic, strong) NSNumber *selectedCategoryID;
@property (nonatomic, strong) NSNumber *selectedMeasureID;

// Meal Plan
@property (nonatomic, strong) NSMutableArray *mealPlanArray;
@property (nonatomic, strong) NSMutableArray *ArrMealNotes; // BHADRESH
@property (nonatomic) BOOL isMealPlanItem;
@property (nonatomic) BOOL sendAllServerData;
@property (nonatomic, strong) NSMutableDictionary *mealPlanItemToExchangeDict;
@property (nonatomic) int indexOfItemToExchange;
@property (nonatomic) int selectedMealPlanID;
@property (nonatomic) BOOL didInsertNewFood;

//Assigned my moves
@property (nonatomic, strong) NSMutableArray *myMovesAssignedArray;

// Grocery List
@property (nonatomic, strong) NSMutableArray *groceryArray;

// factual api
@property (nonatomic, readonly) FactualAPI* apiObject;
@property (nonatomic,retain)  FactualQueryResult* queryResult;

//HHT new exercise sync
@property (nonatomic, strong) NSMutableArray *arrExerciseSyncNew;
@property (nonatomic ,assign) int pageNumber;

+ (instancetype)sharedInstance;

-(void)syncDatabase;
-(void)uploadDatabase;
-(void)syncDatabaseFinished;
-(void)uploadDatabaseFinished;
-(void)syncDatabaseFailed;
-(void)uploadDatabaseFailed;
-(void)SyncFood:(NSString *)syncDate;

// New GetData Method
-(void)getDataFrom:(NSString *)syncDate withBlock:(DMGBooleanResponseBlock)block;

// DOWN SYNC
-(void)syncFavoriteFoods:(NSString *)dateString;
-(void)syncFavoriteMeals:(NSString *)dateString;
-(void)syncFavoriteMealItems:(NSString *)dateString;
-(void)syncExerciseLog:(NSString *)dateString;

//HHT new exercise sync
-(void)syncExerciseLogNew:(NSString *)dateString;

// UP SYNC
-(void)saveMeals:(NSString *)dateString;
-(void)saveMealItems:(NSString *)dateString;
-(void)saveExerciseLogs:(NSString *)dateString;
-(void)saveWeightLog:(NSString *)dateString;
-(void)saveFood:(int)foodKey;
-(void)saveAllCustomFoods;
-(void)saveFavoriteFood:(NSString *)dateString;
-(void)saveFavoriteMeal:(NSString *)dateString;
-(void)saveFavoriteMealItem:(int)mealID;

/// Fetches any updates to a user, such as BMR, Goals, etc.
-(void)syncUserInfo:(id)sender;
/// Updates user details in the database with the user object provided.
/// This does NOT update the UserID, CompanyID, or name, only things like Height, BMR, Weight, etc.
- (void)updateUserInfo:(DMUser *)user;

// Splash Image
- (void)downloadFileIfUpdated;
- (void)downloadFileIfUpdatedInBackground;
- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;


// Food Plan Methods
-(NSDictionary *)getFoodDetails:(NSDictionary *)foodDict;
-(void)getMissingFoods:(NSDictionary *)foodDict;
-(void)retrieveMissingFood:(int)foodKey;
-(BOOL)insertMealPlanToLog:(NSDictionary *)dict;
-(NSNumber *)getMealCodeCalories:(NSArray *)array;
-(NSNumber *)getRecommendedCalories;
-(NSNumber *)getMeasureIDForFood:(NSNumber *)foodKey;
-(NSNumber *)getGramWeightForFoodID:(NSNumber *)foodID andMeasureID:(NSNumber *)measureID;

-(void)saveMealPlanArray;
-(void)saveMealNotesArray;  // BHADRESH.
-(void)GetMealNotesArray;   // BHADRESH.
-(BOOL)hasMealPlanSaved;
-(void)purgeMealPlanArray;
-(NSString *)getSavedMealPlanFilePath;
-(void)loadSavedMealPlan;

-(void)saveGroceryListArray;
-(BOOL)hasGroceryListSaved;
-(void)purgeGroceryListArray;
-(NSString *)getGroceryListFilePath;
-(void)loadSavedGroceryList;

-(void)saveMyMovesAssignedOnDateArray;
-(NSString *)getmyMovesAssignedFilePath;
-(BOOL)hasMyMovesAssignedSaved;
-(void)loadMyMovesAssignedOnDateList;


// Database helper methods
-(NSString *)databasePath;

// UPC food
-(void)saveUPCFood:(int)foodKey;

// tech support module
-(NSData *)createZipFileOfDatabase;
-(void)processIncomingDatabase:(NSDictionary *)dict;

// Factual
-(void)searchFactualDatabase:(NSString *)upcString;

// Helpers
- (NSDictionary *)getUserRecommendedRatios;
- (NSInteger)getBMR;

- (NSArray<DMMessage *> *)unreadMessages;
- (int)countOfUnreadingMessages;
- (void)setReadedMessageId:(NSString *)messageId;
- (NSDictionary *)messageById:(NSString *)uid;

-(NSMutableArray *)getGroceryFoodDetails:(NSMutableArray *) foods;

@end
@protocol WSGetFoodDelegate <NSObject>
- (void)getFoodFinished:(NSMutableArray *)responseArray;
- (void)getFoodFailed:(NSString *)failedMessage;
@end
@protocol SyncDatabaseDelegate <NSObject>
- (void)syncDatabaseFinished:(NSString *)responseMessage;
- (void)syncDatabaseFailed:(NSString *)failedMessage;
@end
@protocol UPSyncDatabaseDelegate <NSObject>
- (void)syncUPDatabaseFinished:(NSString *)responseMessage;
- (void)syncUPDatabaseFailed:(NSString *)failedMessage;
-(void)callSyncDatabase;

@end
