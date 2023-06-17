//
//  WebServiceEngine.m
//  DietMasterGo
//
//  Created by Henry Kirk on 2/9/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import "WebserviceEngine.h"

@implementation WebserviceEngine

@synthesize wsSyncFoodsDelegate;
@synthesize wsSyncFoodLogDelegate;
@synthesize wsSyncFavoriteFoodsDelegate;
@synthesize wsSyncFavoriteMealsDelegate;

// ######################    WEB SERVICE METHODS   #######################

-(void)callWebservice:(NSString *)text
{
	
	// get our defaults
	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSString *finalPath = [path stringByAppendingPathComponent:PLIST_NAME];
	NSDictionary *appDefaults = [[NSDictionary alloc] initWithContentsOfFile:finalPath];
	
	// get last modified now
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[dateFormatter setLocale:usLocale];
	NSTimeZone *est = [NSTimeZone timeZoneWithAbbreviation:@"EST"];
	[dateFormatter setTimeZone:est];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSString *lastmodified = [dateFormatter stringFromDate:[prefs valueForKey:@"lastmodified"]];
    
    NSString *webservicekey;
    NSString *accountid;

    webservicekey = [prefs valueForKey:@"webservicekey"];
    accountid = [prefs valueForKey:@"accountid"];
    
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
									webservicekey,@"webservicekey",
									accountid,@"accountid",
									text,@"type",
									lastmodified,@"lastupdated",
									nil];
	
    NSString *jsonString = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:nil];

	NSString *urlString = [NSString stringWithFormat:@"%@/webservice/webservice_SVN.php",[appDefaults valueForKey:@"syncurl"]];
	// create request object with that URL
	NSURL *url = [NSURL URLWithString:urlString];
	
    
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:90];
	
	// Setup and start async download
	// NSURLRequest *request = [[NSURLRequest alloc] initWithURL: url];
	
	NSString *post = [NSString stringWithFormat:@"&data=%@", jsonString];
        
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:NO];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
	[request setHTTPBody:postData];
    
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	responseData = [NSMutableData data];
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
			DMLog(@"Error with %i", statusCode);
			
        }
    }
	
	[responseData setLength:0];
	
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
    total_data = total_data + [data length];
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    DMLog(@"Connection failed! Error – %@",[error localizedDescription]);
	
	if ([wsSyncFoodsDelegate respondsToSelector:@selector(getSyncFoodsFailed:)]) {
        [wsSyncFoodsDelegate getSyncFoodsFailed:[error localizedDescription]];
    }
	if ([wsSyncFoodLogDelegate respondsToSelector:@selector(getSyncFoodLogFailed:)]) {
        [wsSyncFoodLogDelegate getSyncFoodLogFailed:[error localizedDescription]];
    }
	if ([wsSyncFavoriteFoodsDelegate respondsToSelector:@selector(getSyncFavoriteFoodsFailed:)]) {
        [wsSyncFavoriteFoodsDelegate getSyncFavoriteFoodsFailed:[error localizedDescription]];
    }
	if ([wsSyncFavoriteMealsDelegate respondsToSelector:@selector(getSyncFavoriteMealsFailed:)]) {
        [wsSyncFavoriteMealsDelegate getSyncFavoriteMealsFailed:[error localizedDescription]];
    }
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	// Create a dictionary from the JSON string
	NSDictionary *results = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
	
	// Build an array from the dictionary for easy access to each entry
	NSMutableArray *responseArray = [[results objectForKey:@"data"] valueForKey:@"data"];
	
 	if ([wsSyncFoodsDelegate respondsToSelector:@selector(getSyncFoodsFinished:)]) {
        [wsSyncFoodsDelegate getSyncFoodsFinished:responseArray];
    }
	if ([wsSyncFoodLogDelegate respondsToSelector:@selector(getSyncFoodLogFinished:)]) {
        [wsSyncFoodLogDelegate getSyncFoodLogFinished:responseArray];
    }
	if ([wsSyncFavoriteFoodsDelegate respondsToSelector:@selector(getSyncFavoriteFoodsFinished:)]) {
        [wsSyncFavoriteFoodsDelegate getSyncFavoriteFoodsFinished:responseArray];
    }
	if ([wsSyncFavoriteMealsDelegate respondsToSelector:@selector(getSyncFavoriteMealsFinished:)]) {
        [wsSyncFavoriteMealsDelegate getSyncFavoriteMealsFinished:responseArray];
    }
}


@end
