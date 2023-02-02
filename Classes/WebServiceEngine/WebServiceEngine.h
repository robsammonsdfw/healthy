//
//  WebServiceEngine.h
//  DietMasterGo
//
//  Created by Henry Kirk on 2/9/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WSSyncFoodsDelegate;
@protocol WSSyncFoodLogDelegate;
@protocol WSSyncFavoriteFoodsDelegate;
@protocol WSSyncFavoriteMealsDelegate;

@interface WebserviceEngine : NSObject <NSURLConnectionDelegate> {
	
	// delegates
	id<WSSyncFoodsDelegate> wsSyncFoodsDelegate;
	id<WSSyncFoodLogDelegate> wsSyncFoodLogDelegate;
	id<WSSyncFavoriteFoodsDelegate> wsSyncFavoriteFoodsDelegate;
	id<WSSyncFavoriteMealsDelegate> wsSyncFavoriteMealsDelegate;
    
	NSMutableData *responseData;
    
    int total_data;
	
}

// delegates
@property(nonatomic,assign) id<WSSyncFoodsDelegate> wsSyncFoodsDelegate;
@property(nonatomic,assign) id<WSSyncFoodLogDelegate> wsSyncFoodLogDelegate;
@property(nonatomic,assign) id<WSSyncFavoriteFoodsDelegate> wsSyncFavoriteFoodsDelegate;
@property(nonatomic,assign) id<WSSyncFavoriteMealsDelegate> wsSyncFavoriteMealsDelegate;

-(void)callWebservice:(NSString *)text;

@end

@protocol WSSyncFoodsDelegate <NSObject>
- (void)getSyncFoodsFinished:(NSMutableArray *)responseArray;
- (void)getSyncFoodsFailed:(NSString *)failedMessage;
@end
@protocol WSSyncFoodLogDelegate <NSObject>
- (void)getSyncFoodLogFinished:(NSMutableArray *)responseArray;
- (void)getSyncFoodLogFailed:(NSString *)failedMessage;
@end
@protocol WSSyncFavoriteFoodsDelegate <NSObject>
- (void)getSyncFavoriteFoodsFinished:(NSMutableArray *)responseArray;
- (void)getSyncFavoriteFoodsFailed:(NSString *)failedMessage;
@end
@protocol WSSyncFavoriteMealsDelegate <NSObject>
- (void)getSyncFavoriteMealsFinished:(NSMutableArray *)responseArray;
- (void)getSyncFavoriteMealsFailed:(NSString *)failedMessage;
@end
