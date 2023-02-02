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

// For splash updating
#import "UserLoginWebService.h"

#import "SaveUPCDataWebService.h"
#import "FactualAPI.h"
#import "FactualQuery.h"
@protocol WSGetFoodDelegate;

extern NSString * const UpdatingMessageNotification;

typedef void (^DMGBooleanResponseBlock)(BOOL success, NSError *error);

typedef void (^GetMessagesCompletionBlock)(BOOL success, NSString *errorString);

@protocol SyncDatabaseDelegate;
@protocol UpdateUserInfoDelegate;
@protocol UPSyncDatabaseDelegate;

@interface DietmasterEngine : NSObject <WSSyncFavoriteFoodsDelegate, WSSyncFavoriteMealsDelegate, WSGetUserInfoDelegate,
WSSyncFavoriteMealItemsDelegate, WSSyncExerciseLogDelegate,WSSyncExerciseLogNewDelegate, WSSaveMealDelegate, WSSaveMealItemDelegate, WSSaveExerciseLogsDelegate, WSGetFoodDelegate, WSSaveWeightLogDelegate, WSSaveFoodDelegate, WSSaveFavoriteFoodDelegate, WSSaveFavoriteMealDelegate, WSSaveFavoriteMealItemDelegate, WSAuthenticateUserDelegate, SaveUPCDataWSDelegate, FactualAPIDelegate, GetDataWSDelegate, WSGetMessagesDelegate> {
    
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
    id<SyncDatabaseDelegate> syncDatabaseDelegate;
    id<UPSyncDatabaseDelegate> syncUPDatabaseDelegate;
    int syncsCompleted;
    int upsyncsCompleted;
    int syncsToComplete;
    int upsyncsToComplete;
    int syncsFailed;
    int upsyncsFailed;
    
    id<UpdateUserInfoDelegate> updateUserInfoDelegate;
    
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
    id<WSGetFoodDelegate> wsGetFoodDelegate;
    
    
}

// delegate
@property(nonatomic,assign) id<WSGetFoodDelegate> wsGetFoodDelegate;

@property(nonatomic,assign) id<SyncDatabaseDelegate> syncDatabaseDelegate;
@property(nonatomic,assign) id<UpdateUserInfoDelegate> updateUserInfoDelegate;
@property(nonatomic,assign) id<UPSyncDatabaseDelegate> syncUPDatabaseDelegate;

@property (nonatomic,copy) GetMessagesCompletionBlock messageCompletion;

@property (nonatomic, retain) NSMutableDictionary *exerciseSelectedDict;
@property (nonatomic, retain) NSMutableDictionary *foodSelectedDict;
@property (nonatomic, retain) NSNumber *currentWeight;

//HHT apple watch
@property (nonatomic,retain) NSNumber *userHeight;
@property (nonatomic,assign) int userGender;

@property (nonatomic, retain) NSString *taskMode;
@property (nonatomic, retain) NSDate *dateSelected;
@property (nonatomic, retain) NSString *dateSelectedFormatted;
@property (nonatomic, retain) NSNumber *selectedMealID;

@property (nonatomic, retain) NSNumber *selectedCategoryID;
@property (nonatomic, retain) NSNumber *selectedMeasureID;

// Meal Plan
@property (nonatomic, retain) NSMutableArray *mealPlanArray;
@property (nonatomic, retain) NSMutableArray *ArrMealNotes; // BHADRESH
@property (nonatomic, assign) BOOL isMealPlanItem;
@property (nonatomic, assign) BOOL sendAllServerData;
@property (nonatomic, retain) NSMutableDictionary *mealPlanItemToExchangeDict;
@property (nonatomic, assign) int indexOfItemToExchange;
@property (nonatomic, assign) int selectedMealPlanID;
@property (nonatomic, assign) BOOL didInsertNewFood;

//Assigned my moves
@property (nonatomic, retain) NSMutableArray *myMovesAssignedArray;

// Grocery List
@property (nonatomic, retain) NSMutableArray *groceryArray;

// factual api
@property (nonatomic, readonly) FactualAPI* apiObject;
@property (nonatomic,retain)  FactualQueryResult* queryResult;

// device token store
@property (nonatomic,retain) NSString *deviceToken;

//HHT new exercise sync
@property (nonatomic, retain) NSMutableArray *arrExerciseSyncNew;
@property (nonatomic ,assign) int pageNumber;

+(DietmasterEngine*)instance;

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
-(void)syncUserInfo:(id)sender;
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

// OTHER
-(void)updateUserInfo:(NSMutableArray *)userInfo;

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

- (void)synchMessagesWithCompletion:(GetMessagesCompletionBlock)messagesCompletion;
- (NSArray *)unreadingMessages;
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
@protocol UpdateUserInfoDelegate <NSObject>
- (void)updateUserInfoFinished:(NSString *)responseMessage;
- (void)updateUserInfoFailed:(NSString *)failedMessage;
@end
@protocol UPSyncDatabaseDelegate <NSObject>
- (void)syncUPDatabaseFinished:(NSString *)responseMessage;
- (void)syncUPDatabaseFailed:(NSString *)failedMessage;
-(void)callSyncDatabase;

@end
