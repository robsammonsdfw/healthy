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
@interface DMDataFetcher : NSObject

/// Calls the fetch with params with optional completion block. If error is returned in block, the
/// sync was not successful.
/// The completion block returns on the main queue.
+ (void)fetchDataWithRequestParams:(NSDictionary *)params completion:(completionBlockWithObject)completionBlock;

/// Calls the fetch with params with optional completion block.
/// If you need to send an array in strJSON field, provide the NSArray in the jsonArray argument.
/// If error is returned in block, the sync was not successful.
/// The completion block returns on the main queue.
+ (void)fetchDataWithRequestParams:(NSDictionary *)params
                         jsonArray:(NSArray *)jsonArray
                        completion:(completionBlockWithObject)completionBlock;

/// Calls a fetch to the JSON service with the params provided to the URL given.
/// If error is returned, sync was not successful. Completion block returns on main queue.
/// NOTE: This currently only calls the "/MobileAPI/SyncUser" API.
+ (void)fetchDataWithJSONParams:(NSDictionary *)params
                            url:(NSURL *)url
                     completion:(completionBlockWithObject)completionBlock;

@end
