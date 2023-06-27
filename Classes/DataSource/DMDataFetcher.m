//
//  DMDataFetcher.m
//  DietMasterGo
//
//  Created by Henry Kirk on 6/26/2023.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import "DMDataFetcher.h"
#import "NSNull+NullCategoryExtension.h"

@interface DMDataFetcher()
/// Optional completion block called when a sync finishes.
@property (nonatomic, copy) completionBlockWithObject completionBlock;
@end

@implementation DMDataFetcher

- (instancetype)init {
    self = [super init];
    return self;
}

+ (void)fetchDataWithJSONParams:(NSDictionary *)params
                            url:(NSURL *)url
                     completion:(completionBlockWithObject)completionBlock {
    DMDataFetcher *fetcher = [[DMDataFetcher alloc] init];
    fetcher.completionBlock = completionBlock;
    DMAuthManager *authManager = [DMAuthManager sharedInstance];
    DMUser *currentUser = [authManager loggedInUser];
    if (!currentUser && [authManager isUserLoggedIn] == NO) {
        NSError *error = [DMGUtilities errorWithMessage:@"User not logged in." code:100];
        [fetcher processError:error];
        return;
    }

    NSData *jsonData = nil;
    @try {
        NSError *jsonError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error: &jsonError];
        // Handle error.
        if (jsonError) {
            [fetcher processError:jsonError];
            return;
        }
        if (!jsonData) {
            NSError *error = [DMGUtilities errorWithMessage:@"Error: No data returned." code:777];
            [fetcher processError:error];
            return;
        }
    } @catch (NSException *exception) {
        DM_LOG(@"Fetch JSON Exception: %@", exception);
        NSError *error = [DMGUtilities errorWithMessage:exception.reason code:999];
        [fetcher processError:error];
        return;
    }

    NSString *authString = [NSString stringWithFormat:@"%@:%@", currentUser.userName, currentUser.authToken];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"mobile" forHTTPHeaderField:@"DMSource"];
    [request setHTTPMethod:@"POST"];
    NSData *nsdata = [authString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
    [request addValue:base64Encoded forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:jsonData];

    NSURLSession *session = [NSURLSession sharedSession];
    __weak typeof(fetcher) weakSelf = fetcher;
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            NSDictionary *resultDict = @{}; // Should this be nil or empty?
            @try {
                NSError *jsonError = nil;
                if (jsonData) {
                    resultDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
                }
                // Handle error.
                if (error) {
                    [strongSelf processError:error];
                    return;
                }
                if (!jsonData) {
                    NSError *error = [DMGUtilities errorWithMessage:@"Error: No data returned." code:777];
                    [strongSelf processError:error];
                    return;
                }
            } @catch (NSException *exception) {
                DM_LOG(@"Fetch JSON Exception: %@", exception);
                NSError *error = [DMGUtilities errorWithMessage:exception.reason code:999];
                [strongSelf processError:error];
                return;
            }
        
            dispatch_async(dispatch_get_main_queue(), ^{
                if (strongSelf.completionBlock) {
                    strongSelf.completionBlock(resultDict, nil);
                }
            });
      }] resume];
}

+ (void)fetchDataWithRequestParams:(NSDictionary *)params
                        completion:(completionBlockWithObject)completionBlock {
    DMDataFetcher *fetcher = [[DMDataFetcher alloc] init];
    fetcher.completionBlock = completionBlock;
    DMAuthManager *authManager = [DMAuthManager sharedInstance];
    DMUser *currentUser = [authManager loggedInUser];
    if (!currentUser && [authManager isUserLoggedIn] == NO) {
        NSError *error = [DMGUtilities errorWithMessage:@"User not logged in." code:100];
        [fetcher processError:error];
        return;
    }
    NSString *requestType = params[@"RequestType"];

    // Build the request.
    NSMutableString *soapMessage = [NSMutableString string];
    // Base format.
    [soapMessage appendString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                                "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                                "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"  xmlns:soap12=\"http://www.w3.org/2003/05/soap-envelope\">"
                                "<soap12:Body>"];
    // Set request type.
    [soapMessage appendFormat:@"<%@ xmlns=\"http://webservice.dmwebpro.com/\">", requestType];
    // Append UserID and Authkey.
    [soapMessage appendFormat:@"<UserID>%@</UserID>", currentUser.userId.stringValue];
    // Build the request from the dictionary provided.
    for (NSString *key in params.allKeys) {
        if ([key isEqualToString:requestType]) {
            continue; // Skip the request type.
        }
        [soapMessage appendFormat:@"<%@>%@</%@>", key, params[key], key];
    }
    [soapMessage appendFormat:@"<AuthKey>%@</AuthKey>", currentUser.authToken];
    [soapMessage appendFormat:@"</%@>", requestType];
    [soapMessage appendString:@"</soap12:Body></soap12:Envelope>"];
    // Sanitize the resulting string.
    soapMessage = [[soapMessage stringByReplacingOccurrencesOfString:@"&" withString:@"and"] mutableCopy];
    
    NSString *urlToWebservice = [NSString stringWithFormat:@"http://webservice.dmwebpro.com/DMGoWS.asmx?op=%@", requestType];
    NSString *uriString = [NSString stringWithFormat:@"http://webservice.dmwebpro.com/%@", requestType];
    NSURL *url = [NSURL URLWithString:urlToWebservice];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    [request addValue:@"application/soap+xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:uriString forHTTPHeaderField:@"SOAPAction"];
    [request addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    __weak typeof(fetcher) weakSelf = fetcher;
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            NSString *xmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSData *jsonData = [FetchUtilities processXMLToDataWithXmlString:xmlString methodName:requestType];
            NSDictionary *resultDict = @{}; // Should this be nil or empty?
            @try {
                NSError *jsonError = nil;
                if (jsonData) {
                    resultDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
                }
                // Handle errors.
                if (error) {
                    [strongSelf processError:error];
                    return;
                }
                if (!jsonData) {
                    NSError *error = [DMGUtilities errorWithMessage:@"Error: No data returned." code:777];
                    [strongSelf processError:error];
                    return;
                }
            } @catch (NSException *exception) {
                DM_LOG(@"Fetch JSON Exception: %@", exception);
                NSError *error = [DMGUtilities errorWithMessage:exception.reason code:999];
                [strongSelf processError:error];
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (strongSelf.completionBlock) {
                    strongSelf.completionBlock(resultDict, nil);
                }
            });
      }] resume];
}

+ (void)fetchDataWithRequestParams:(NSDictionary *)params
                         jsonArray:(NSArray *)jsonArray
                        completion:(completionBlockWithObject)completionBlock {
    // Convert the JSON Array into data, then call fetch.
    NSString *jsonString = @"[]"; // Default.
    NSData *jsonData = nil;
    @try {
        NSError *jsonError = nil;
        jsonData = [NSJSONSerialization dataWithJSONObject:jsonArray options:0 error: &jsonError];
        // Handle error.
        if (jsonError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(nil, jsonError);
                }
            });
            return;
        }
    } @catch (NSException *exception) {
        DM_LOG(@"Fetch JSON Exception: %@", exception);
        NSError *error = [DMGUtilities errorWithMessage:exception.reason code:999];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(nil, error);
            }
        });
        return;
    }
    
    NSMutableDictionary *mutableParams = [params mutableCopy];
    // Convert JSON Data to string.
    jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    // Append strJSON.
    mutableParams[@"strJSON"] = jsonString;
    
    // Fetch!
    [self fetchDataWithRequestParams:[mutableParams copy] completion:completionBlock];
}

/// OLD API to be removed.
- (void)callWebservice:(NSDictionary *)requestDict {
    return;
    // Note: GetMealItems response needs to include MealID.
    // Now lay out the different requests:
    NSString *requestType = nil;
    DMAuthManager *authManager = [DMAuthManager sharedInstance];
    DMUser *currentUser = [authManager loggedInUser];
    NSString *soapMessage = nil;
    if ([requestType isEqualToString:@"GetMealItems"]) {
        //tempID = [[requestDict valueForKey:@"MealID"] intValue];
    } else if ([requestType isEqualToString:@"SyncExerciseLogNew"]) {
        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<SyncExerciseLogNew xmlns=\"http://webservice.dmwebpro.com/\">"
                        "<UserID>%@</UserID>"
                        "<AuthKey>%@</AuthKey>"
                        "<LastSync>%@</LastSync>"
                        "<PageSize>%@</PageSize>"
                        "<PageNumber>%@</PageNumber>"
                        "</SyncExerciseLogNew>"
                        "</soap:Body>"
                        "</soap:Envelope>",
                        currentUser.userId,
                        currentUser.authToken,
                        [requestDict valueForKey:@"LastSync"],
                        [requestDict valueForKey:@"PageSize"],
                        [requestDict valueForKey:@"PageNumber"]];
    }
}

/// Processes an incoming error.
- (void)processError:(NSError *)error {
    DM_LOG(@"Fetch Error: %@, Code: %li", error.localizedDescription, error.code);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.completionBlock) {
            self.completionBlock(nil, error);
        }
    });
}

@end
