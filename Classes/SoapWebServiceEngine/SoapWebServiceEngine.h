//
//  SoapWebServiceEngine.h
//  DietMasterGo
//
//  Created by Henry Kirk on 2/14/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLReader.h"
// DOWN SYNC
@protocol WSGetUserInfoDelegate;
@protocol WSSyncFoodsDelegate;
@protocol WSSyncFoodLogDelegate;
@protocol WSSyncFoodLogItemsDelegate;
@protocol WSSyncFavoriteFoodsDelegate;
@protocol WSSyncFavoriteMealsDelegate;
@protocol WSSyncFavoriteMealItemsDelegate;
@protocol WSSyncExerciseLogDelegate;
//HHT new exercise sync
@protocol WSSyncExerciseLogNewDelegate;

@protocol WSSyncWeightLogDelegate;
@protocol WSGetFoodDelegate;
@protocol WSGetMessagesDelegate;

// UP SYNC
@protocol WSSaveMealDelegate;
@protocol WSSaveMealItemDelegate;
@protocol WSSaveExerciseLogsDelegate;
@protocol WSSaveWeightLogDelegate;
@protocol WSSaveFoodDelegate;
@protocol WSSaveFavoriteFoodDelegate;
@protocol WSSaveFavoriteMealDelegate;
@protocol WSSaveFavoriteMealItemDelegate;
@protocol WSDeleteMealItemDelegate;
@protocol WSDeleteFavoriteFoodDelegate;
@protocol WSSendMessageDelegate;
@protocol WSSendDeviceTokenDelegate;
@protocol WSSetMessageReadDelegate;

@interface SoapWebServiceEngine : NSObject <NSURLConnectionDelegate, NSXMLParserDelegate> {
    
    // delegates
    // DOWN SYNC
    id<WSGetUserInfoDelegate> wsGetUserInfoDelegate;
    id<WSSyncFoodsDelegate> wsSyncFoodsDelegate;
    id<WSSyncFoodLogDelegate> wsSyncFoodLogDelegate;
    id<WSSyncFoodLogItemsDelegate> wsSyncFoodLogItemsDelegate;
    id<WSSyncFavoriteFoodsDelegate> wsSyncFavoriteFoodsDelegate;
    id<WSSyncFavoriteMealsDelegate> wsSyncFavoriteMealsDelegate;
    id<WSSyncFavoriteMealItemsDelegate> wsSyncFavoriteMealItemsDelegate;
    id<WSSyncExerciseLogDelegate> wsSyncExerciseLogDelegate;
    //HHT new exercise sync
    id<WSSyncExerciseLogNewDelegate> wsSyncExerciseLogNewDelegate;
    id<WSSyncWeightLogDelegate> wsSyncWeightLogDelegate;
    id<WSGetFoodDelegate> wsGetFoodDelegate;
    
    // UP SYNC
    id<WSSaveMealDelegate> wsSaveMealDelegate;
    id<WSSaveMealItemDelegate> wsSaveMealItemDelegate;
    id<WSSaveExerciseLogsDelegate> wsSaveExerciseLogsDelegate;
    id<WSSaveWeightLogDelegate> wsSaveWeightLogDelegate;
    id<WSSaveFoodDelegate> wsSaveFoodDelegate;
    id<WSSaveFavoriteFoodDelegate> wsSaveFavoriteFoodDelegate;
    id<WSSaveFavoriteMealDelegate> wsSaveFavoriteMealDelegate;
    id<WSSaveFavoriteMealItemDelegate> wsSaveFavoriteMealItemDelegate;
    id<WSDeleteMealItemDelegate> wsDeleteMealItemDelegate;
    id<WSDeleteFavoriteFoodDelegate> wsDeleteFavoriteFoodDelegate;
    
    NSMutableData *webData;
    NSMutableString *soapResults;
    NSXMLParser *xmlParser;
    BOOL recordResults;
    
    // Vars to Hold Data for Session
    int tempID;
    
    NSTimer *timeOutTimer;
    
}
@property (nonatomic, retain) NSTimer *timeOutTimer;
@property (nonatomic, retain) NSDictionary *requestDict;

// delegates
// DOWN SYNC
@property(nonatomic,assign) id<WSGetUserInfoDelegate> wsGetUserInfoDelegate;
@property(nonatomic,assign) id<WSSyncFoodsDelegate> wsSyncFoodsDelegate;
@property(nonatomic,assign) id<WSSyncFoodLogDelegate> wsSyncFoodLogDelegate;
@property(nonatomic,assign) id<WSSyncFoodLogItemsDelegate> wsSyncFoodLogItemsDelegate;
@property(nonatomic,assign) id<WSSyncFavoriteFoodsDelegate> wsSyncFavoriteFoodsDelegate;
@property(nonatomic,assign) id<WSSyncFavoriteMealsDelegate> wsSyncFavoriteMealsDelegate;
@property(nonatomic,assign) id<WSSyncFavoriteMealItemsDelegate> wsSyncFavoriteMealItemsDelegate;
@property(nonatomic,assign) id<WSSyncWeightLogDelegate> wsSyncWeightLogDelegate;
@property(nonatomic,assign) id<WSSyncExerciseLogDelegate> wsSyncExerciseLogDelegate;
//HHT new exercise sync
@property(nonatomic,assign) id<WSSyncExerciseLogNewDelegate> wsSyncExerciseLogNewDelegate;
@property(nonatomic,assign) id<WSGetFoodDelegate> wsGetFoodDelegate;
@property(nonatomic,assign) id<WSGetMessagesDelegate> wsGetMessagesDelegate;

// UP SYNC
@property(nonatomic,assign) id<WSSaveMealDelegate> wsSaveMealDelegate;
@property(nonatomic,assign) id<WSSaveMealItemDelegate> wsSaveMealItemDelegate;
@property(nonatomic,assign) id<WSSaveExerciseLogsDelegate> wsSaveExerciseLogsDelegate;
@property(nonatomic,assign) id<WSSaveWeightLogDelegate> wsSaveWeightLogDelegate;
@property(nonatomic,assign) id<WSSaveFoodDelegate> wsSaveFoodDelegate;
@property(nonatomic,assign) id<WSSaveFavoriteFoodDelegate> wsSaveFavoriteFoodDelegate;
@property(nonatomic,assign) id<WSSaveFavoriteMealDelegate> wsSaveFavoriteMealDelegate;
@property(nonatomic,assign) id<WSSaveFavoriteMealItemDelegate> wsSaveFavoriteMealItemDelegate;

//change by Kiran sir
@property(nonatomic,strong) id<WSDeleteMealItemDelegate> wsDeleteMealItemDelegate;

@property(nonatomic,assign) id<WSDeleteFavoriteFoodDelegate> wsDeleteFavoriteFoodDelegate;
@property(nonatomic,assign) id<WSSendMessageDelegate> wsSendMessageDelegate;
@property(nonatomic,assign) id<WSSendDeviceTokenDelegate> wsSendDeviceTokenDelegate;
@property(nonatomic,assign) id<WSSetMessageReadDelegate> wsSetMessageReadDelegate;

@property(nonatomic, retain) NSMutableData *webData;
@property(nonatomic, retain) NSMutableString *soapResults;
@property(nonatomic, retain) NSXMLParser *xmlParser;
-(void)callWebserviceForFoodNew:(NSDictionary *)requestDict withCompletion:(void (^)(id))completion;

-(void)callWebservice:(NSDictionary *)requestDict withCompletion:(void(^)(id obj))completion;
-(void)callWebservice:(NSDictionary *)requestDict;
-(void)timeOutWebservice:(NSTimer *)theTimer;

@end

// DOWN SYNC
@protocol WSGetUserInfoDelegate <NSObject>
- (void)getUserInfoFinished:(NSMutableArray *)responseArray;
- (void)getUserInfoFailed:(NSString *)failedMessage;
@end
@protocol WSSyncFoodsDelegate <NSObject>
- (void)getSyncFoodsFinished:(NSMutableArray *)responseArray;
- (void)getSyncFoodsFailed:(NSString *)failedMessage;
@end
@protocol WSSyncFoodLogDelegate <NSObject>
- (void)getSyncFoodLogFinished:(NSMutableArray *)responseArray;
- (void)getSyncFoodLogFailed:(NSString *)failedMessage;
@end
@protocol WSSyncFoodLogItemsDelegate <NSObject>
- (void)getSyncFoodLogItemsFinished:(NSMutableArray *)responseArray;
- (void)getSyncFoodLogItemsFailed:(NSString *)failedMessage;
@end
@protocol WSSyncFavoriteFoodsDelegate <NSObject>
- (void)getSyncFavoriteFoodsFinished:(NSMutableArray *)responseArray;
- (void)getSyncFavoriteFoodsFailed:(NSString *)failedMessage;
@end
@protocol WSSyncFavoriteMealsDelegate <NSObject>
- (void)getSyncFavoriteMealsFinished:(NSMutableArray *)responseArray;
- (void)getSyncFavoriteMealsFailed:(NSString *)failedMessage;
@end
@protocol WSSyncFavoriteMealItemsDelegate <NSObject>
- (void)getSyncFavoriteMealItemsFinished:(NSMutableArray *)responseArray;
- (void)getSyncFavoriteMealItemsFailed:(NSString *)failedMessage;
@end
@protocol WSSyncWeightLogDelegate <NSObject>
- (void)getSyncWeightLogFinished:(NSMutableArray *)responseArray;
- (void)getSyncWeightLogFailed:(NSString *)failedMessage;
@end
@protocol WSSyncExerciseLogDelegate <NSObject>
- (void)getSyncExerciseLogFinished:(NSMutableArray *)responseArray;
- (void)getSyncExerciseLogFailed:(NSString *)failedMessage;
@end

//HHT new exercise sync
@protocol WSSyncExerciseLogNewDelegate <NSObject>
- (void)getSyncExerciseLogNewFinished:(NSMutableArray *)responseArray;
- (void)getSyncExerciseLogNewFailed:(NSString *)failedMessage;
@end

@protocol WSGetFoodDelegate <NSObject>
- (void)getFoodFinished:(NSMutableArray *)responseArray;
- (void)getFoodFailed:(NSString *)failedMessage;
@end

// UP SYNC
@protocol WSSaveMealDelegate <NSObject>
- (void)saveMealFinished:(NSMutableArray *)responseArray;
- (void)saveMealFailed:(NSString *)failedMessage;
@end
@protocol WSSaveMealItemDelegate <NSObject>
- (void)saveMealItemFinished:(NSMutableArray *)responseArray;
- (void)saveMealItemFailed:(NSString *)failedMessage;
@end
@protocol WSSaveExerciseLogsDelegate <NSObject>
- (void)saveExerciseLogsFinished:(NSMutableArray *)responseArray;
- (void)saveExerciseLogsFailed:(NSString *)failedMessage;
@end
@protocol WSSaveWeightLogDelegate <NSObject>
- (void)saveWeightLogFinished:(NSMutableArray *)responseArray;
- (void)saveWeightLogFailed:(NSString *)failedMessage;
@end
@protocol WSSaveFoodDelegate <NSObject>
- (void)saveFoodFinished:(NSMutableArray *)responseArray;
- (void)saveFoodFailed:(NSString *)failedMessage;
@end
@protocol WSSaveFavoriteFoodDelegate <NSObject>
- (void)saveFavoriteFoodFinished:(NSMutableArray *)responseArray;
- (void)saveFavoriteFoodFailed:(NSString *)failedMessage;
@end
@protocol WSSaveFavoriteMealDelegate <NSObject>
- (void)saveFavoriteMealFinished:(NSMutableArray *)responseArray;
- (void)saveFavoriteMealFailed:(NSString *)failedMessage;
@end
@protocol WSSaveFavoriteMealItemDelegate <NSObject>
- (void)saveFavoriteMealItemFinished:(NSMutableArray *)responseArray;
- (void)saveFavoriteMealItemFailed:(NSString *)failedMessage;
@end
@protocol WSDeleteMealItemDelegate <NSObject>
- (void)deleteMealItemFinished:(NSMutableArray *)responseArray;
- (void)deleteMealItemFailed:(NSString *)failedMessage;
@end
@protocol WSDeleteFavoriteFoodDelegate <NSObject>
- (void)deleteFavoriteFoodFinished:(NSMutableArray *)responseArray;
- (void)deleteFavoriteFoodFailed:(NSString *)failedMessage;
@end
@protocol WSGetMessagesDelegate <NSObject>
- (void)getMessagesFinished:(NSMutableArray *)responseArray;
- (void)getMessagesFailed:(NSString *)failedMessage;
@end
@protocol WSSendMessageDelegate <NSObject>
- (void)sendMessageFinished:(NSMutableArray *)responseArray;
- (void)sendMessageFailed:(NSString *)failedMessage;
@end
@protocol WSSendDeviceTokenDelegate <NSObject>
- (void)sendDeviceFinished:(NSMutableArray *)responseArray;
- (void)sendDeviceFailed:(NSString *)failedMessage;
@end
@protocol WSSetMessageReadDelegate <NSObject>
- (void)setMessageReadFinished:(NSMutableArray *)responseArray;
- (void)setMessageReadFailed:(NSString *)failedMessage;
@end
