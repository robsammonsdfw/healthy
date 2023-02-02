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
    
    // delegates
    id<GetDataWSDelegate> getDataWSDelegate;
    
    NSMutableData *webData;
	NSMutableString *soapResults;
	NSXMLParser *xmlParser;
	BOOL recordResults;
    
    // Vars to Hold Data for Session
    int tempID;
        
    NSString *requestType;

}
@property (nonatomic, retain) NSDictionary *requestDict;

// delegates
@property(nonatomic,assign) id<GetDataWSDelegate> getDataWSDelegate;

@property(nonatomic, retain) NSMutableData *webData;
@property(nonatomic, retain) NSMutableString *soapResults;
@property(nonatomic, retain) NSXMLParser *xmlParser;

-(void)callWebservice:(NSDictionary *)requestDict;

@end