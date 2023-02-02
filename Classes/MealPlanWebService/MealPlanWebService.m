//
//  MealPlanWebService.m
//  DietMasterGo
//
//  Created by Henry Kirk on 6/11/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import "MealPlanWebService.h"
#import "JSON.h"
#import "DietmasterEngine.h"

@implementation MealPlanWebService

@synthesize webData, soapResults, xmlParser;

@synthesize wsGetUserPlannedMealNames;
@synthesize wsGetGroceryList;

@synthesize wsDeleteUserPlannedMealItems;
@synthesize wsInsertUserPlannedMealItems;
@synthesize wsInsertUserPlannedMeals;
@synthesize wsUpdateUserPlannedMealItems;
@synthesize wsUpdateUserPlannedMealNames;

@synthesize timeOutTimer;

-(void)callWebservice:(NSDictionary *)requestDict {
    NSLog(@"SOAP CALL ----BEGIN---- MealPlanWebService");
    [timeOutTimer invalidate];
    timeOutTimer = nil;

	recordResults = FALSE;
    
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
        NSString *jsonString = [[requestDict valueForKey:@"GroceryItems"] JSONRepresentation];
        
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
        NSString *jsonString = [[requestDict valueForKey:@"MealItems"] JSONRepresentation];
        
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
        
        NSString *jsonString = [[requestDict valueForKey:@"MealItems"] JSONRepresentation];

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
        
         	
        NSString *jsonString = [[requestDict valueForKey:@"MealItems"] JSONRepresentation];
        
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
        
         	
        NSString *jsonString = [[requestDict valueForKey:@"MealItems"] JSONRepresentation];
        
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
        
        
        NSString *jsonString = [[requestDict valueForKey:@"MealItems"] JSONRepresentation];
        
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
    
    NSLog(@"%@", soapMessage);
	
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
		webData = [[NSMutableData data] retain];
	}
	else
	{
		NSLog(@"theConnection is NULL");
	}
    
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[webData setLength: 0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[webData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [timeOutTimer invalidate];
    timeOutTimer = nil;

    if ([wsGetUserPlannedMealNames respondsToSelector:@selector(getUserPlannedMealNamesFailed:)]) {
        [wsGetUserPlannedMealNames getUserPlannedMealNamesFailed:[error localizedDescription]];
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
    
	[connection release];
	[webData release];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [timeOutTimer invalidate];
    timeOutTimer = nil;

	NSString *theXML = [[NSString alloc] initWithBytes: [webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
    
    
	[theXML release];
	
	if( xmlParser )
	{
		[xmlParser release];
	}
	
	xmlParser = [[NSXMLParser alloc] initWithData: webData];
	[xmlParser setDelegate: self];
	[xmlParser setShouldResolveExternalEntities: YES];
	[xmlParser parse];
	
	[connection release];
	[webData release];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *)qName attributes: (NSDictionary *)attributeDict {
	if( [elementName isEqualToString:@"DeleteUserPlannedMealItemsResult"] || [elementName isEqualToString:@"GetUserPlannedMealNamesResult"] ||
       [elementName isEqualToString:@"InsertUserPlannedMealItemsResult"] || [elementName isEqualToString:@"InsertUserPlannedMealsResult"] ||
       [elementName isEqualToString:@"UpdateUserPlannedMealItemsResult"] || [elementName isEqualToString:@"UpdateUserPlannedMealNamesResult"] ||
       [elementName isEqualToString:@"GetGroceryListResult"]) {
		if(!soapResults) {
			soapResults = [[NSMutableString alloc] init];
		}
		recordResults = TRUE;
	}
    
    if( [elementName isEqualToString:@"faultstring"]) {
        
        if ([wsGetUserPlannedMealNames respondsToSelector:@selector(getUserPlannedMealNamesFailed:)]) {
            [wsGetUserPlannedMealNames getUserPlannedMealNamesFailed:@"error"];
        }
        if ([wsGetGroceryList respondsToSelector:@selector(getGroceryListFailed:)]) {
            [wsGetGroceryList getGroceryListFailed:@"error"];
        }
        
        if ([wsDeleteUserPlannedMealItems respondsToSelector:@selector(deleteUserPlannedMealItemsFailed:)]) {
            [wsDeleteUserPlannedMealItems deleteUserPlannedMealItemsFailed:@"error"];
        }
        if ([wsInsertUserPlannedMealItems respondsToSelector:@selector(insertUserPlannedMealItemsFailed:)]) {
            [wsInsertUserPlannedMealItems insertUserPlannedMealItemsFailed:@"error"];
        }
        if ([wsInsertUserPlannedMeals respondsToSelector:@selector(insertUserPlannedMealsFailed:)]) {
            [wsInsertUserPlannedMeals insertUserPlannedMealsFailed:@"error"];
        }
        if ([wsUpdateUserPlannedMealItems respondsToSelector:@selector(updateUserPlannedMealItemsFailed:)]) {
            [wsUpdateUserPlannedMealItems updateUserPlannedMealItemsFailed:@"error"];
        }
        if ([wsUpdateUserPlannedMealNames respondsToSelector:@selector(updateUserPlannedMealNamesFailed:)]) {
            [wsUpdateUserPlannedMealNames updateUserPlannedMealNamesFailed:@"error"];
        }
	}
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if( recordResults )
	{
		[soapResults appendString: string];
	}
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    recordResults = FALSE;
    if ([soapResults isEqualToString:@"\"Empty\""]) {
        [soapResults release];
        soapResults = nil;
        soapResults = [[NSMutableString alloc] init];
		[soapResults appendFormat:@"%@",@"[]"];
    }
    
    
    NSMutableArray *responseArray = [soapResults JSONValue];
    NSString *strCheck;
    if([responseArray count]!= 0) {
        NSDictionary *dictCheck = [responseArray objectAtIndex:0];
        strCheck = [dictCheck objectForKey:@"Response"];
    } else {
        strCheck = @"";
    }
    
	if([elementName isEqualToString:@"GetUserPlannedMealNamesResult"]) {
        if ([strCheck isEqualToString:@"Invalid Auth"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_NAME message:@"Service has been terminated. Contact your plan provider." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alertView.tag = 1;
            [alertView show];
        } else {
            DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
            
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
                            [tempDict release];
                        }
                    }
                    [newMealItemsArray addObject:mealItemsTemp];
                    [mealItemsTemp release];
                }
                [newMealPlanDict setObject:newMealItemsArray forKey:@"MealItems"];
                [newMealItemsArray release];
                
                if ([[mealDict valueForKey:@"MealNotes"] count] != 0) {
                    NSMutableArray *newMealNotesArray = [[NSMutableArray alloc] init];
                    for (NSDictionary *mealNotes in [mealDict valueForKey:@"MealNotes"]) {
                        [newMealNotesArray addObject:mealNotes];
                    }
                    [newMealPlanDict setObject:newMealNotesArray forKey:@"MealNotes"];
                    [newMealNotesArray release];
                }
                [tempArray addObject:newMealPlanDict];
                
            }
            
            
            if ([wsGetUserPlannedMealNames respondsToSelector:@selector(getUserPlannedMealNamesFinished:)]) {
                [wsGetUserPlannedMealNames getUserPlannedMealNamesFinished:tempArray];
            }
            [tempArray release];
        }
    }
    if([elementName isEqualToString:@"GetGroceryListResult"]) {
        
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
    
    [soapResults release];
    soapResults = nil;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1) {
        exit(0);
    }
}

//- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
//	return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
//	[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
//}

#pragma mark TIMEOUT METHOD
-(void)timeOutWebservice:(NSTimer *)theTimer {
    
    NSURLConnection *connection = [[theTimer userInfo] objectForKey:@"connection"];
    [connection cancel];
    [connection release];
    connection = nil;
    
    [timeOutTimer invalidate];
    timeOutTimer = nil;
    
    [webData release];
    webData = nil;
    
    if ([wsGetUserPlannedMealNames respondsToSelector:@selector(getUserPlannedMealNamesFailed:)]) {
        [wsGetUserPlannedMealNames getUserPlannedMealNamesFailed:@"error"];
    }
    if ([wsGetGroceryList respondsToSelector:@selector(getGroceryListFailed:)]) {
        [wsGetGroceryList getGroceryListFailed:@"error"];
    }

    if ([wsDeleteUserPlannedMealItems respondsToSelector:@selector(deleteUserPlannedMealItemsFailed:)]) {
        [wsDeleteUserPlannedMealItems deleteUserPlannedMealItemsFailed:@"error"];
    }
    if ([wsInsertUserPlannedMealItems respondsToSelector:@selector(insertUserPlannedMealItemsFailed:)]) {
        [wsInsertUserPlannedMealItems insertUserPlannedMealItemsFailed:@"error"];
    }
    if ([wsInsertUserPlannedMeals respondsToSelector:@selector(insertUserPlannedMealsFailed:)]) {
        [wsInsertUserPlannedMeals insertUserPlannedMealsFailed:@"error"];
    }
    if ([wsUpdateUserPlannedMealItems respondsToSelector:@selector(updateUserPlannedMealItemsFailed:)]) {
        [wsUpdateUserPlannedMealItems updateUserPlannedMealItemsFailed:@"error"];
    }
    if ([wsUpdateUserPlannedMealNames respondsToSelector:@selector(updateUserPlannedMealNamesFailed:)]) {
        [wsUpdateUserPlannedMealNames updateUserPlannedMealNamesFailed:@"error"];
    }
}

- (void)dealloc {
	[xmlParser release];
    [timeOutTimer invalidate];
    timeOutTimer = nil;
    [timeOutTimer release];
	[super dealloc];
}
@end
