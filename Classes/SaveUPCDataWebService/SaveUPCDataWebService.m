//
//  SaveUPCDataWebService.m
//  DMG
//
//  Created by Henry T Kirk on 12/31/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import "SaveUPCDataWebService.h"
#import "DietmasterEngine.h"
#import "NSData-AES.h"
#import "Base64.h"

@implementation SaveUPCDataWebService
@synthesize delegate, responseData;

-(void)callWebservice:(NSDictionary *)userData {
    NSString *webservicekey = @"api_key_here"; // Enter Key Here
    NSData *webkeydata = [webservicekey dataUsingEncoding: NSASCIIStringEncoding];
    NSString *b64EncStrwebservicekey = [Base64 encode:webkeydata];
    
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:[userData valueForKey:@"scannerDict"]];
    [tempDict removeObjectsForKeys:@[@"size", @"ingredients", @"image_urls"]];
    
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    tempDict,@"factual_data",
                                    b64EncStrwebservicekey, @"api_key",
                                    [userData valueForKey:@"action"], @"action",
                                    nil];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    NSString *urlString = [NSString stringWithFormat:
                           @"http://mobile.dietmastergo.com/webservice/%@",
                           @"save_scanned_food_ws.php"];
    
    url = nil;
    url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:90];
    
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    
    NSString *post = [NSString stringWithFormat:@"&data=%@", jsonString];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:NO];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:postData];
    
    __unused NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    responseData = [NSMutableData data];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if ([response respondsToSelector:@selector(statusCode)]) {
        int statusCode = [((NSHTTPURLResponse *)response) statusCode];
        if (statusCode != 200) {
            [connection cancel];
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setValue:@"Server returned bad access" forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:@"myDomain" code:100 userInfo:errorDetail];
            [self connection:connection didFailWithError:error];
            DMLog(@"Error with %i", statusCode);
        }
    }
    
    [responseData setLength:0];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    DMLog(@"Connection failed! Error – %@",[error localizedDescription]);
    
    if ([delegate respondsToSelector:@selector(saveUPCDataWSFailed:)]) {
        [delegate saveUPCDataWSFailed:[error localizedDescription]];
    }
    
    responseData = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
    
    if ([delegate respondsToSelector:@selector(saveUPCDataWSFinished:)]) {
        [delegate saveUPCDataWSFinished:responseDict];
    }
    
    responseData = nil;
}

@end

