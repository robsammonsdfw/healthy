//
//  SoapWebServiceEngine.h
//  DietMasterGo
//
//  Created by Henry Kirk on 2/14/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMConstants.h"

@interface SoapWebServiceEngine : NSObject <NSURLConnectionDelegate, NSXMLParserDelegate> {
    BOOL recordResults;
    // Vars to Hold Data for Session
    int tempID;
}

-(void)callWebserviceForFoodNew:(NSDictionary *)requestDict withCompletion:(void (^)(id))completion;
-(void)callFoodsWebservice:(NSDictionary *)requestDict withCompletion:(void(^)(id obj))completion;

/// Calls the webservice with optional completion block. If error is returned in block, the
/// sync was not successful.
- (void)callWebservice:(NSDictionary *)requestDict withCompletion:(completionBlockWithObject)completionBlock;
- (void)callWebservice:(NSDictionary *)requestDict;

@end
