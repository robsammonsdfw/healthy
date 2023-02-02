//
//  MealPlanWebService.h
//  DietMasterGo
//
//  Created by Henry Kirk on 6/11/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <Foundation/Foundation.h>

// DOWN SYNC
@protocol WSGetUserPlannedMealNames;

// UP SYNC
@protocol WSDeleteUserPlannedMealItems;
@protocol WSInsertUserPlannedMealItems;
@protocol WSInsertUserPlannedMeals;
@protocol WSUpdateUserPlannedMealItems;
@protocol WSUpdateUserPlannedMealNames;
@protocol WSGetGroceryList;

@interface MealPlanWebService : NSObject <NSURLConnectionDelegate, NSXMLParserDelegate> {
    
    // delegates
    // DOWN SYNC
    id<WSGetUserPlannedMealNames> wsGetUserPlannedMealNames;
    id<WSGetGroceryList> wsGetGroceryList;

    // UP SYNC
    id<WSDeleteUserPlannedMealItems> wsDeleteUserPlannedMealItems;
    id<WSInsertUserPlannedMealItems> wsInsertUserPlannedMealItems;
    id<WSInsertUserPlannedMeals> wsInsertUserPlannedMeals;
    id<WSUpdateUserPlannedMealItems> wsUpdateUserPlannedMealItems;
    id<WSUpdateUserPlannedMealNames> wsUpdateUserPlannedMealNames;
    
    NSMutableData *webData;
	NSMutableString *soapResults;
	NSXMLParser *xmlParser;
	BOOL recordResults;
    
    // Vars to Hold Data for Session
    int tempID;
    
    NSTimer *timeOutTimer;

}
@property (nonatomic, retain) NSTimer *timeOutTimer;

// delegates
// DOWN SYNC
@property(nonatomic,assign) id<WSGetUserPlannedMealNames> wsGetUserPlannedMealNames;
@property(nonatomic,assign) id<WSGetGroceryList> wsGetGroceryList;

// UP SYNC
@property(nonatomic,assign) id<WSDeleteUserPlannedMealItems> wsDeleteUserPlannedMealItems;
@property(nonatomic,assign) id<WSInsertUserPlannedMealItems> wsInsertUserPlannedMealItems;
@property(nonatomic,assign) id<WSInsertUserPlannedMeals> wsInsertUserPlannedMeals;
@property(nonatomic,assign) id<WSUpdateUserPlannedMealItems> wsUpdateUserPlannedMealItems;
@property(nonatomic,assign) id<WSUpdateUserPlannedMealNames> wsUpdateUserPlannedMealNames;

@property(nonatomic, retain) NSMutableData *webData;
@property(nonatomic, retain) NSMutableString *soapResults;
@property(nonatomic, retain) NSXMLParser *xmlParser;

-(void)callWebservice:(NSDictionary *)requestDict;
-(void)timeOutWebservice:(NSTimer *)theTimer;

@end

// DOWN SYNC
@protocol WSGetUserPlannedMealNames <NSObject>
- (void)getUserPlannedMealNamesFinished:(NSMutableArray *)responseArray;
- (void)getUserPlannedMealNamesFailed:(NSString *)failedMessage;
@end
@protocol WSGetGroceryList <NSObject>
- (void)getGroceryListFinished:(NSMutableArray *)responseArray;
- (void)getGroceryListFailed:(NSString *)failedMessage;
@end
// UP SYNC
@protocol WSDeleteUserPlannedMealItems <NSObject>
- (void)deleteUserPlannedMealItemsFinished:(NSMutableArray *)responseArray;
- (void)deleteUserPlannedMealItemsFailed:(NSString *)failedMessage;
@end
@protocol WSInsertUserPlannedMealItems <NSObject>
- (void)insertUserPlannedMealItemsFinished:(NSMutableArray *)responseArray;
- (void)insertUserPlannedMealItemsFailed:(NSString *)failedMessage;
@end
@protocol WSInsertUserPlannedMeals <NSObject>
- (void)insertUserPlannedMealsFinished:(NSMutableArray *)responseArray;
- (void)insertUserPlannedMealsFailed:(NSString *)failedMessage;
@end
@protocol WSUpdateUserPlannedMealItems <NSObject>
- (void)updateUserPlannedMealItemsFinished:(NSMutableArray *)responseArray;
- (void)updateUserPlannedMealItemsFailed:(NSString *)failedMessage;
@end
@protocol WSUpdateUserPlannedMealNames <NSObject>
- (void)updateUserPlannedMealNamesFinished:(NSMutableArray *)responseArray;
- (void)updateUserPlannedMealNamesFailed:(NSString *)failedMessage;
@end