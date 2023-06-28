//
//  DMDataFetcher.h
//  DietMasterGo
//
//  Created by Henry Kirk on 6/26/2023.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMConstants.h"

/// Class that handles a fetch to the server.
/// It does not save any data, just fetches and returns a
/// response from the server, be it an error or returned object.
/// DietMaster APIs are mostly documented here:
/// https://webservice.dmwebpro.com/DMGoWS.asmx
/// NOTE: This Fetcher uses the "Soap 1.2" specs.
@interface DMDataFetcher : NSObject

/// Calls the fetch with params with optional completion block. If error is returned in block, the
/// sync was not successful.
/// The completion block returns on the main queue.
+ (void)fetchDataWithRequestParams:(nullable NSDictionary *)params completion:(nonnull completionBlockWithObject)completionBlock;

/// Calls the fetch with params with optional completion block.
/// If you need to send an [array or dict] in strJSON field, provide the object in the jsonObject argument.
/// If error is returned in block, the sync was not successful.
/// The completion block returns on the main queue.
+ (void)fetchDataWithRequestParams:(nullable NSDictionary *)params
                        jsonObject:(nonnull NSObject *)jsonObject
                        completion:(nullable completionBlockWithObject)completionBlock;

/// Calls a fetch to the JSON service with the params provided to the URL given.
/// If error is returned, sync was not successful. Completion block returns on main queue.
+ (void)fetchDataWithJSONParams:(nullable NSDictionary *)params
                            url:(nonnull NSURL *)url
                         method:(nonnull NSString *)method
                     completion:(nullable completionBlockWithObject)completionBlock;

@end
