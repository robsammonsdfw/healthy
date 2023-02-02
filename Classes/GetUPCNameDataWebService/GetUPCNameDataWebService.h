//
//  GetUPCNameDataWebService.h
//  DMG
//
//  Created by Henry T Kirk on 12/31/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GetUPCNameDataWSDelegate <NSObject>
- (void)getUPCNameDataWSFinished:(NSMutableDictionary *)responseDict;
- (void)getUPCNameDataWSFailed:(NSString *)failedMessage;
@end

@interface GetUPCNameDataWebService : NSObject {
    
	NSMutableData *responseData;
    NSURL *url;
    
}

@property(nonatomic,assign) id<GetUPCNameDataWSDelegate> delegate;
@property(nonatomic,strong) NSMutableData *responseData;

-(void)callWebservice:(NSDictionary *)userData;

@end
