//
//  MealPlanWebService.m
//  DietMasterGo
//
//  Created by Henry Kirk on 6/11/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import "MealPlanWebService.h"
#import "DietmasterEngine.h"

@interface MealPlanWebService()
@property (nonatomic, strong) NSMutableData *webData;
@property (nonatomic, strong) NSMutableString *soapResults;
@property (nonatomic, strong) NSXMLParser *xmlParser;
@end

@implementation MealPlanWebService

@synthesize wsGetUserPlannedMealNames;
@synthesize wsGetGroceryList;

@synthesize wsDeleteUserPlannedMealItems;
@synthesize wsInsertUserPlannedMealItems;
@synthesize wsInsertUserPlannedMeals;
@synthesize wsUpdateUserPlannedMealItems;
@synthesize wsUpdateUserPlannedMealNames;

@synthesize timeOutTimer;

- (void)callWebservice:(NSDictionary *)requestDict {
    DMLog(@"SOAP CALL ----BEGIN---- MealPlanWebService");
    [timeOutTimer invalidate];
    timeOutTimer = nil;

	recordResults = FALSE;
    self.soapResults = [[NSMutableString alloc] init];

    NSString *requestType = [requestDict valueForKey:@"RequestType"];
    NSString *soapMessage = nil;
        
    if ([requestType isEqualToString:@"GetUserPlannedMealNames"]) {
        
        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<GetUserPlannedMealNames xmlns=\"http://webservice.dmwebpro.com/\">"
                        "<UserID>%@</UserID>"
                        "<AuthKey>%@</AuthKey>"
                        "</GetUserPlannedMealNames>"
                        "</soap:Body>"
                        "</soap:Envelope>",
                        [requestDict valueForKey:@"UserID"], 
                        [requestDict valueForKey:@"AuthKey"]];
    }
    
    if ([requestType isEqualToString:@"GetGroceryList"]) {

        NSString *jsonString = @"[]";
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[requestDict valueForKey:@"GroceryItems"] options:0 error:nil];
        if (jsonData) {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }

        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<GetGroceryList xmlns=\"http://webservice.dmwebpro.com/\">"
                        "<UserID>%@</UserID>"
                        "<strJSON>%@</strJSON>"
                        "<Planned>%@</Planned>"
                        "<AuthKey>%@</AuthKey>"
                        "</GetGroceryList>"
                        "</soap:Body>"
                        "</soap:Envelope>",
                        [requestDict valueForKey:@"UserID"], 
                        jsonString, 
                        @"false", 
                        [requestDict valueForKey:@"AuthKey"]];
        
    }
    
    if ([requestType isEqualToString:@"DeleteUserPlannedMealItems"]) {
        NSString *jsonString = @"[]";
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[requestDict valueForKey:@"MealItems"] options:0 error:nil];
        if (jsonData) {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }

        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<DeleteUserPlannedMealItems xmlns=\"http://webservice.dmwebpro.com/\">"
                        "<UserID>%@</UserID>"
                        "<strJSON>[%@]</strJSON>"
                        "<AuthKey>%@</AuthKey>"
                        "</DeleteUserPlannedMealItems>"
                        "</soap:Body>"
                        "</soap:Envelope>",
                        [requestDict valueForKey:@"UserID"], 
                        jsonString,
                        [requestDict valueForKey:@"AuthKey"]];
        
    }
    if ([requestType isEqualToString:@"InsertUserPlannedMealItems"]) {
        
        NSString *jsonString = @"[]";
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[requestDict valueForKey:@"MealItems"] options:0 error:nil];
        if (jsonData) {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }

        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<InsertUserPlannedMealItems xmlns=\"http://webservice.dmwebpro.com/\">"
                        "<UserID>%@</UserID>"
                        "<strJSON>[%@]</strJSON>"
                        "<AuthKey>%@</AuthKey>"
                        "</InsertUserPlannedMealItems>"
                        "</soap:Body>"
                        "</soap:Envelope>",
                        [requestDict valueForKey:@"UserID"], 
                        jsonString,
                        [requestDict valueForKey:@"AuthKey"]];
        
    }
    if ([requestType isEqualToString:@"InsertUserPlannedMeals"]) {
        
         	
        NSString *jsonString = @"[]";
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[requestDict valueForKey:@"MealItems"] options:0 error:nil];
        if (jsonData) {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }

        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<InsertUserPlannedMeals xmlns=\"http://webservice.dmwebpro.com/\">"
                        "<UserID>%@</UserID>"
                        "<strJSON>%@</strJSON>"
                        "<AuthKey>%@</AuthKey>"
                        "</InsertUserPlannedMeals>"
                        "</soap:Body>"
                        "</soap:Envelope>",
                        [requestDict valueForKey:@"UserID"], 
                        jsonString,
                        [requestDict valueForKey:@"AuthKey"]];
        
    }
    if ([requestType isEqualToString:@"UpdateUserPlannedMealItems"]) {
        
        NSString *jsonString = @"[]";
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[requestDict valueForKey:@"MealItems"] options:0 error:nil];
        if (jsonData) {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }

        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<UpdateUserPlannedMealItems xmlns=\"http://webservice.dmwebpro.com/\">"
                        "<UserID>%@</UserID>"
                        "<strJSON>[%@]</strJSON>"
                        "<AuthKey>%@</AuthKey>"
                        "</UpdateUserPlannedMealItems>"
                        "</soap:Body>"
                        "</soap:Envelope>",
                        [requestDict valueForKey:@"UserID"], 
                        jsonString,
                        [requestDict valueForKey:@"AuthKey"]];
    }
    
    if ([requestType isEqualToString:@"UpdateUserPlannedMealNames"]) {
        
        NSString *jsonString = @"[]";
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[requestDict valueForKey:@"MealItems"] options:0 error:nil];
        if (jsonData) {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }

        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<UpdateUserPlannedMealNames xmlns=\"http://webservice.dmwebpro.com/\">"
                        "<UserID>%@</UserID>"
                        "<strJSON>%@</strJSON>"
                        "<AuthKey>%@</AuthKey>"
                        "</UpdateUserPlannedMealNames>"
                        "</soap:Body>"
                        "</soap:Envelope>",
                        [requestDict valueForKey:@"UserID"],
                        jsonString,
                        [requestDict valueForKey:@"AuthKey"]];
    }
    
    NSString *urlToWebservice = [NSString stringWithFormat:@"http://webservice.dmwebpro.com/DMGoWS.asmx?op=%@", requestType];
    NSString *tempuriValue = [NSString stringWithFormat:@"http://webservice.dmwebpro.com/%@", requestType];
    
    //DMLog(@"%@", soapMessage);
	
	NSURL *url = [NSURL URLWithString:urlToWebservice];
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
	NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMessage length]];
	
	[theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	[theRequest addValue: tempuriValue forHTTPHeaderField:@"SOAPAction"];
	[theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
    timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:120.0
                                                    target:self
                                                  selector:@selector(timeOutWebservice:)
                                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:theConnection, @"connection", nil]
                                                   repeats:NO];
    
	if( theConnection )
	{
		self.webData = [NSMutableData data];
	}
	else
	{
		DMLog(@"theConnection is NULL");
	}
    
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[self.webData setLength: 0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self.webData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self processError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [timeOutTimer invalidate];
    timeOutTimer = nil;

    if (self.webData.length) {
        self.xmlParser = [[NSXMLParser alloc] initWithData:self.webData];
        [self.xmlParser setDelegate: self];
        [self.xmlParser setShouldResolveExternalEntities: YES];
        [self.xmlParser parse];
    } else {
        DMLog(@"Error loading connection.");
    }
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *)qName attributes: (NSDictionary *)attributeDict {
	if( [elementName isEqualToString:@"DeleteUserPlannedMealItemsResult"] || [elementName isEqualToString:@"GetUserPlannedMealNamesResult"] ||
       [elementName isEqualToString:@"InsertUserPlannedMealItemsResult"] || [elementName isEqualToString:@"InsertUserPlannedMealsResult"] ||
       [elementName isEqualToString:@"UpdateUserPlannedMealItemsResult"] || [elementName isEqualToString:@"UpdateUserPlannedMealNamesResult"] ||
       [elementName isEqualToString:@"GetGroceryListResult"]) {
		recordResults = TRUE;
	}
    
    if ([elementName isEqualToString:@"faultstring"]) {
        NSError *error = [DMGUtilities errorWithMessage:@"The webservice returned a fault." code:200];
        [self processError:error];
	}
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (recordResults) {
		[self.soapResults appendString: string];
	}
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    recordResults = FALSE;
    if ([self.soapResults isEqualToString:@"\"Empty\""]) {
        self.soapResults = [[NSMutableString alloc] init];
		[self.soapResults appendFormat:@"%@",@"[]"];
    }
    
    NSArray *responseArray;
    @try {
        NSError *error;
        NSData *data = [self.soapResults dataUsingEncoding:NSUTF8StringEncoding];
        if (data) {
            responseArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        }
        // Handle error.
        if (error || !data) {
            [self processError:error];
            return;
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
        NSError *error = [DMGUtilities errorWithMessage:exception.reason code:999];
        [self processError:error];
        return;
    }
    
	if ([elementName isEqualToString:@"GetUserPlannedMealNamesResult"]) {
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        
        for (NSDictionary *mealDict in responseArray) {
            
            NSMutableDictionary *newMealPlanDict = [[NSMutableDictionary alloc] init];
            [newMealPlanDict setObject:[mealDict valueForKey:@"MealName"] forKey:@"MealName"];
            [newMealPlanDict setObject:[mealDict valueForKey:@"MealID"] forKey:@"MealID"];
            [newMealPlanDict setObject:[mealDict valueForKey:@"MealTypeID"] forKey:@"MealTypeID"];
            
            NSMutableArray *newMealItemsArray = [[NSMutableArray alloc] init];
            for (int i = 0; i <=5; i++) {
                NSMutableArray *mealItemsTemp = [[NSMutableArray alloc] init];
                for (NSDictionary *mealItems in [mealDict valueForKey:@"MealItems"]) {
                    int mealCode = [[mealItems valueForKey:@"MealCode"] intValue];
                    if (mealCode == i) {
                        [mealItemsTemp addObject:mealItems];
                       
                        NSDictionary *tempDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:[[mealItems valueForKey:@"FoodID"] intValue]], @"FoodID",
                                                  [NSNumber numberWithInt:[[mealItems valueForKey:@"MeasureID"] intValue]], @"MeasureID", nil];
                        
                        [dietmasterEngine getMissingFoods:tempDict];
                    }
                }
                [newMealItemsArray addObject:mealItemsTemp];
            }
            [newMealPlanDict setObject:newMealItemsArray forKey:@"MealItems"];
            
            if ([[mealDict valueForKey:@"MealNotes"] count] != 0) {
                NSMutableArray *newMealNotesArray = [[NSMutableArray alloc] init];
                for (NSDictionary *mealNotes in [mealDict valueForKey:@"MealNotes"]) {
                    [newMealNotesArray addObject:mealNotes];
                }
                [newMealPlanDict setObject:newMealNotesArray forKey:@"MealNotes"];
            }
            [tempArray addObject:newMealPlanDict];
            
        }
        
        if ([wsGetUserPlannedMealNames respondsToSelector:@selector(getUserPlannedMealNamesFinished:)]) {
            [wsGetUserPlannedMealNames getUserPlannedMealNamesFinished:[tempArray copy]];
        }
    }
    if ([elementName isEqualToString:@"GetGroceryListResult"]) {
        
        if ([wsGetGroceryList respondsToSelector:@selector(getGroceryListFinished:)]) {
            [wsGetGroceryList getGroceryListFinished:responseArray];
        }
        
    }
    
    if([elementName isEqualToString:@"DeleteUserPlannedMealItemsResult"]) {
        
        if ([wsDeleteUserPlannedMealItems respondsToSelector:@selector(deleteUserPlannedMealItemsFinished:)]) {
            [wsDeleteUserPlannedMealItems deleteUserPlannedMealItemsFinished:responseArray];
        }
        
    }
    if([elementName isEqualToString:@"InsertUserPlannedMealItemsResult"]) {
        
        if ([wsInsertUserPlannedMealItems respondsToSelector:@selector(insertUserPlannedMealItemsFinished:)]) {
            [wsInsertUserPlannedMealItems insertUserPlannedMealItemsFinished:responseArray];
        }
        
    }
     if([elementName isEqualToString:@"InsertUserPlannedMealsResult"]) {
        
        if ([wsInsertUserPlannedMeals respondsToSelector:@selector(insertUserPlannedMealsFinished:)]) {
            [wsInsertUserPlannedMeals insertUserPlannedMealsFinished:responseArray];
        }
        
    }
    if([elementName isEqualToString:@"UpdateUserPlannedMealItemsResult"])
	{
        if ([wsUpdateUserPlannedMealItems respondsToSelector:@selector(updateUserPlannedMealItemsFinished:)]) {
            [wsUpdateUserPlannedMealItems updateUserPlannedMealItemsFinished:responseArray];
        }
        
    }
    if([elementName isEqualToString:@"UpdateUserPlannedMealNamesResult"])
	{
        if ([wsUpdateUserPlannedMealNames respondsToSelector:@selector(updateUserPlannedMealNamesFinished:)]) {
            [wsUpdateUserPlannedMealNames updateUserPlannedMealNamesFinished:responseArray];
        }
        
    }
}

/// Processes an incoming error.
- (void)processError:(NSError *)error {
    DM_LOG(@"Error: %@", error.localizedDescription);
    
    [timeOutTimer invalidate];
    timeOutTimer = nil;

    if ([wsGetUserPlannedMealNames respondsToSelector:@selector(getUserPlannedMealNamesFailed:)]) {
        [wsGetUserPlannedMealNames getUserPlannedMealNamesFailed:error];
    }
    if ([wsGetGroceryList respondsToSelector:@selector(getGroceryListFailed:)]) {
        [wsGetGroceryList getGroceryListFailed:[error localizedDescription]];
    }

    if ([wsDeleteUserPlannedMealItems respondsToSelector:@selector(deleteUserPlannedMealItemsFailed:)]) {
        [wsDeleteUserPlannedMealItems deleteUserPlannedMealItemsFailed:[error localizedDescription]];
    }
    if ([wsInsertUserPlannedMealItems respondsToSelector:@selector(insertUserPlannedMealItemsFailed:)]) {
        [wsInsertUserPlannedMealItems insertUserPlannedMealItemsFailed:[error localizedDescription]];
    }
    if ([wsInsertUserPlannedMeals respondsToSelector:@selector(insertUserPlannedMealsFailed:)]) {
        [wsInsertUserPlannedMeals insertUserPlannedMealsFailed:[error localizedDescription]];
    }
    if ([wsUpdateUserPlannedMealItems respondsToSelector:@selector(updateUserPlannedMealItemsFailed:)]) {
        [wsUpdateUserPlannedMealItems updateUserPlannedMealItemsFailed:[error localizedDescription]];
    }
    if ([wsUpdateUserPlannedMealNames respondsToSelector:@selector(updateUserPlannedMealNamesFailed:)]) {
        [wsUpdateUserPlannedMealNames updateUserPlannedMealNamesFailed:[error localizedDescription]];
    }
}

- (void)timeOutWebservice:(NSTimer *)theTimer {
    
    NSURLConnection *connection = [[theTimer userInfo] objectForKey:@"connection"];
    [connection cancel];
    connection = nil;
    
    [timeOutTimer invalidate];
    timeOutTimer = nil;
    self.webData = nil;
    
    NSError *error = [DMGUtilities errorWithMessage:@"The network request timed out." code:300];
    [self processError:error];
}

@end
