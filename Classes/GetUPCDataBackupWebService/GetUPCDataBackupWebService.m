//
//  GetUPCDataBackupWebService.m
//  DMG
//
//  Created by Henry T Kirk on 12/31/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import "GetUPCDataBackupWebService.h"
#import "DietmasterEngine.h"
#import "JSON.h"

@implementation GetUPCDataBackupWebService

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
    
	NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"Y5JmubwVH0gJpZR7u8aDCRMu4DIjDs4",@"auth",
                                    @"FetchNutritionFactsByUPC", @"method",
                                    userData, @"params",
                                    @"JSON", @"returnFormat",
                                    nil];
	
	NSString *jsonString = [jsonDictionary JSONRepresentation];
	NSString *urlString = [NSString stringWithFormat:@"%@",
                           @"http://api.simpleupc.com/v1.php"];
    
    url = nil;
	url = [NSURL URLWithString:urlString];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:90];
    
	NSString *post = [NSString stringWithFormat:@"%@", jsonString];
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:NO];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
	[request setHTTPBody:postData];
    [request setValue:@"iPad" forHTTPHeaderField:@"User-Agent"];
    
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
	
    NSLog(@"Connection failed! Error â€“ %@",[error localizedDescription]);
	
	if ([delegate respondsToSelector:@selector(getUPCDataBackupWSFailed:)]) {
        [delegate getUPCDataBackupWSFailed:[error localizedDescription]];
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
    
	if ([delegate respondsToSelector:@selector(getUPCDataBackupWSFinished:)]) {
        [delegate getUPCDataBackupWSFinished:responseDict];
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