//
//  GetDataWebService.h
//  DietMasterGo
//
//  Created by Henry Kirk on 8/12/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GetDataWSDelegate <NSObject>
- (void)getDataFinished:(NSDictionary *)responseDict;
- (void)getDataFailed:(NSString *)failedMessage;
@end

@interface GetDataWebService : NSObject <NSURLConnectionDelegate, NSXMLParserDelegate> {
	BOOL recordResults;
    // Vars to Hold Data for Session
    int tempID;
}

@property (nonatomic, weak) id<GetDataWSDelegate> getDataWSDelegate;

-(void)callWebservice:(NSDictionary *)requestDict;

@end
