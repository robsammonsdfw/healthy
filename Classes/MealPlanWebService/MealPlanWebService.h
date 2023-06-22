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
	BOOL recordResults;
    
    // Vars to Hold Data for Session
    int tempID;
}
@property (nonatomic, strong) NSTimer *timeOutTimer;

// DOWN SYNC
@property (nonatomic, weak) id<WSGetUserPlannedMealNames> wsGetUserPlannedMealNames;
@property (nonatomic, weak) id<WSGetGroceryList> wsGetGroceryList;

// UP SYNC
@property (nonatomic, weak) id<WSDeleteUserPlannedMealItems> wsDeleteUserPlannedMealItems;
@property (nonatomic, weak) id<WSInsertUserPlannedMealItems> wsInsertUserPlannedMealItems;
@property (nonatomic, weak) id<WSInsertUserPlannedMeals> wsInsertUserPlannedMeals;
@property (nonatomic, weak) id<WSUpdateUserPlannedMealItems> wsUpdateUserPlannedMealItems;
@property (nonatomic, weak) id<WSUpdateUserPlannedMealNames> wsUpdateUserPlannedMealNames;

-(void)callWebservice:(NSDictionary *)requestDict;
-(void)timeOutWebservice:(NSTimer *)theTimer;

@end

// DOWN SYNC
@protocol WSGetUserPlannedMealNames <NSObject>
- (void)getUserPlannedMealNamesFinished:(NSArray *)responseArray;
- (void)getUserPlannedMealNamesFailed:(NSError *)error;
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
