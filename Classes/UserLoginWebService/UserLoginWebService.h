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
    NSMutableData *webData;
	NSMutableString *soapResults;
	NSXMLParser *xmlParser;
	BOOL recordResults;
}

@property (nonatomic, weak) id<WSAuthenticateUserDelegate> wsAuthenticateUserDelegate;
@property (nonatomic, strong) NSMutableData *webData;
@property (nonatomic, strong) NSMutableString *soapResults;
@property (nonatomic, strong) NSXMLParser *xmlParser;

-(void)callWebservice:(NSString *)text;

@end
@protocol WSAuthenticateUserDelegate <NSObject>
- (void)getAuthenticateUserFinished:(NSMutableArray *)responseArray;
- (void)getAuthenticateUserFailed:(NSString *)failedMessage;
@end
