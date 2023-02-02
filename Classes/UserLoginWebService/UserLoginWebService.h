//
//  UserLoginWebService.h
//  DietMasterGo
//
//  Created by Henry Kirk on 2/14/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WSAuthenticateUserDelegate;

@interface UserLoginWebService : NSObject <NSURLConnectionDelegate, NSXMLParserDelegate> {
    
    // delegates
	id<WSAuthenticateUserDelegate> wsAuthenticateUserDelegate;
    
    NSMutableData *webData;
	NSMutableString *soapResults;
	NSXMLParser *xmlParser;
	BOOL recordResults;
}

// delegates
@property(nonatomic,assign) id<WSAuthenticateUserDelegate> wsAuthenticateUserDelegate;

@property(nonatomic, retain) NSMutableData *webData;
@property(nonatomic, retain) NSMutableString *soapResults;
@property(nonatomic, retain) NSXMLParser *xmlParser;

-(void)callWebservice:(NSString *)text;

@end
@protocol WSAuthenticateUserDelegate <NSObject>
- (void)getAuthenticateUserFinished:(NSMutableArray *)responseArray;
- (void)getAuthenticateUserFailed:(NSString *)failedMessage;
@end
