//
//  GetUPCDataBackupWebService.h
//  DMG
//
//  Created by Henry T Kirk on 12/31/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GetUPCDataBackupWSDelegate <NSObject>
- (void)getUPCDataBackupWSFinished:(NSMutableDictionary *)responseDict;
- (void)getUPCDataBackupWSFailed:(NSString *)failedMessage;
@end

@interface GetUPCDataBackupWebService : NSObject {
    
	NSMutableData *responseData;
    NSURL *url;
    
}

@property(nonatomic,assign) id<GetUPCDataBackupWSDelegate> delegate;
@property(nonatomic,strong) NSMutableData *responseData;

-(void)callWebservice:(NSDictionary *)userData;

@end
