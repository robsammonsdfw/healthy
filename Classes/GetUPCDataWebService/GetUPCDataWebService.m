//
//  GetUPCDataWebService.m
//  DMG
//
//  Created by Henry T Kirk on 12/31/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import "GetUPCDataWebService.h"
#import "DietmasterEngine.h"
#import "JSON.h"
// base64 encoder
#import "NSData-AES.h"
#import "Base64.h"

@implementation GetUPCDataWebService

#define BING_SEARCH_API_KEY @"EUjHv5dDe1UBfAqDsBDEwmHl3rqD2mBxn8lbWLf79ds="
@synthesize delegate, responseData;

// ######################    WEB SERVICE METHODS   #######################

-(void)callWebservice:(NSDictionary *)userData
{
    
    /*
     {
     "auth":"Your API Key",
     "method":"MethodName",
     "params": {
     "paramName":"paramValue",
     "paramName2":"paramValue2",
     },
     "returnFormat":"optional"
     }
     */
    
    /*
     [Base64 initialize];
     NSString *webservicekey = @"api_key_here"; // Enter Key Here
     NSData *webkeydata = [webservicekey dataUsingEncoding: NSASCIIStringEncoding];
     NSString *b64EncStrwebservicekey = [Base64 encode:webkeydata];
     */
    
    [Base64 initialize];
    NSString *keyString = [NSString stringWithFormat:@"%@:%@", BING_SEARCH_API_KEY, BING_SEARCH_API_KEY];
    NSData *webkeydata = [keyString dataUsingEncoding: NSASCIIStringEncoding];
    NSString *b64EncStrwebservicekey = [Base64 encode:webkeydata];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", b64EncStrwebservicekey];

	NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    //@"Y5JmubwVH0gJpZR7u8aDCRMu4DIjDs4",@"auth",
                                    //@"FetchNutritionFactsByUPC", @"method",
                                    //userData, @"params",
                                    //@"JSON", @"returnFormat",
                                    nil];
	
    // sample UPC 852834002008 beanitos
    
	NSString *jsonString = [jsonDictionary JSONRepresentation];
	NSString *urlString = [NSString stringWithFormat:
                           @"https://api.datamarket.azure.com/GreggLondon/NutritionForFood/v1/NutritionForFood?%@%@%@",
                           @"$filter=UPCA%20eq%20%27",
                           [userData valueForKey:@"UPC"],
                           @"%27&$format=json"];
    
    // $filter=UPCA%20eq%20%27  852834002008  %27
    
    url = nil;
	url = [NSURL URLWithString:urlString];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:90];
    
	//NSString *post = [NSString stringWithFormat:@"%@", jsonString];
	//NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:NO];
	[request setHTTPMethod:@"GET"];
	//[request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
	//[request setHTTPBody:postData];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];

	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
	responseData = [[NSMutableData data] retain];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	
	if ([response respondsToSelector:@selector(statusCode)])
    {        
        int statusCode = [((NSHTTPURLResponse *)response) statusCode];
        if (statusCode != 200)
        {
			[connection cancel];
			NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:@"Server returned bad access" forKey:NSLocalizedDescriptionKey];
			NSError *error = [NSError errorWithDomain:@"myDomain" code:100 userInfo:errorDetail];
			[self connection:connection didFailWithError:error];
			NSLog(@"Error with %i", statusCode);
			
        }
    }
	
	[responseData setLength:0];
	
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}


-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	
	[responseData appendData:data];
	
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	
    NSLog(@"Connection failed! Error – %@",[error localizedDescription]);
	
	if ([delegate respondsToSelector:@selector(getUPCDataWSFailed:)]) {
        [delegate getUPCDataWSFailed:[error localizedDescription]];
    }
    
    responseData = nil;
    [responseData release];
    [connection release];

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	
	NSString *jsonString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	NSMutableDictionary *responseDict = [jsonString JSONValue];
    
    //NSLog(@"jsonString is: %@", jsonString);
    
	if ([delegate respondsToSelector:@selector(getUPCDataWSFinished:)]) {
        [delegate getUPCDataWSFinished:[responseDict valueForKey:@"d"]];
    }
    
    responseData = nil;
    [responseData release];
    [jsonString release];
    [connection release];

}

- (void)dealloc
{
	[responseData release];
	[super dealloc];
}

@end
