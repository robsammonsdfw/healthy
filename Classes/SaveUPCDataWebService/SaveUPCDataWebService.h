//
//  SaveUPCDataWebService.h
//  DMG
//
//  Created by Henry T Kirk on 12/31/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SaveUPCDataWSDelegate <NSObject>
- (void)saveUPCDataWSFinished:(NSMutableDictionary *)responseDict;
- (void)saveUPCDataWSFailed:(NSString *)failedMessage;
@end

@interface SaveUPCDataWebService : NSObject {
    
	NSMutableData *responseData;
    NSURL *url;
    
}

@property (nonatomic, weak) id<SaveUPCDataWSDelegate> delegate;
@property (nonatomic,strong) NSMutableData *responseData;

-(void)callWebservice:(NSDictionary *)userData;

@end
