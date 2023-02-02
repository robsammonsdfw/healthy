//
//  GetUPCDataWebService.h
//  DMG
//
//  Created by Henry T Kirk on 12/31/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GetUPCDataWSDelegate <NSObject>
- (void)getUPCDataWSFinished:(NSMutableDictionary *)responseDict;
- (void)getUPCDataWSFailed:(NSString *)failedMessage;
@end

@interface GetUPCDataWebService : NSObject {
    
	NSMutableData *responseData;
    NSURL *url;
    
}

@property(nonatomic,assign) id<GetUPCDataWSDelegate> delegate;
@property(nonatomic,strong) NSMutableData *responseData;

-(void)callWebservice:(NSDictionary *)userData;

@end
