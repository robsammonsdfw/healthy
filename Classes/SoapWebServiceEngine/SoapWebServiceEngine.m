//
//  SoapWebServiceEngine.m
//  DietMasterGo
//
//  Created by Henry Kirk on 2/14/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import "SoapWebServiceEngine.h"

@implementation SoapWebServiceEngine

@synthesize webData, soapResults, xmlParser;
// DOWN SYNC
@synthesize wsGetUserInfoDelegate;
@synthesize wsSyncFoodsDelegate;
@synthesize wsSyncFoodLogDelegate;
@synthesize wsSyncFavoriteFoodsDelegate;
@synthesize wsSyncFavoriteMealsDelegate;
@synthesize wsSyncWeightLogDelegate;
@synthesize wsSyncFoodLogItemsDelegate;
@synthesize wsSyncFavoriteMealItemsDelegate;
@synthesize wsSyncExerciseLogDelegate;
//HHT new exercise sync
@synthesize wsSyncExerciseLogNewDelegate;
@synthesize wsGetFoodDelegate;

// UP SYNC
@synthesize wsSaveMealDelegate;
@synthesize wsSaveMealItemDelegate;
@synthesize wsSaveExerciseLogsDelegate;
@synthesize wsSaveWeightLogDelegate;
@synthesize wsSaveFoodDelegate;
@synthesize wsSaveFavoriteFoodDelegate;
@synthesize wsSaveFavoriteMealDelegate;
@synthesize wsSaveFavoriteMealItemDelegate;
@synthesize wsDeleteMealItemDelegate;
@synthesize wsDeleteFavoriteFoodDelegate;

@synthesize timeOutTimer;

@synthesize requestDict = _requestDict;
- (void)callWebserviceForFoodNew:(NSDictionary *)requestDict withCompletion:(void (^)(id))completion {
    [timeOutTimer invalidate];
    timeOutTimer = nil;
    
    recordResults = FALSE;
    
    self.requestDict = nil;
    self.requestDict = [[NSDictionary alloc] initWithDictionary:requestDict];
    
    NSString *requestType = [requestDict valueForKey:@"RequestType"];
    NSString *soapMessage = nil;
    
    // Now lay out the different requests:
    
    if ([requestType isEqualToString:@"GetFoodNew"])
    {
        //FOR COMMA1 SEPRETED
        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<GetFoodNew xmlns=\"http://webservice.dmwebpro.com/\">"
                        "<UserID>%@</UserID>"
                        "<AuthKey>%@</AuthKey>"
                        "<FoodKey>%i</FoodKey>"
                        "</GetFoodNew>"
                        "</soap:Body>"
                        "</soap:Envelope>",[requestDict valueForKey:@"UserID"], [requestDict valueForKey:@"AuthKey"], [[requestDict valueForKey:@"FoodKey"] intValue]];
        
    }
    
    soapMessage = [soapMessage stringByReplacingOccurrencesOfString:@"&" withString:@"and"];
    
    
    
    NSString *urlToWebservice = [NSString stringWithFormat:@"http://webservice.dmwebpro.com/DMGoWS.asmx?op=GetFoodNew"];
    NSString *tempuriValue = [NSString stringWithFormat:@"http://webservice.dmwebpro.com/GetFoodNew"];
        
    NSURL *url = [NSURL URLWithString:urlToWebservice];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: tempuriValue forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
        
    [NSURLConnection sendAsynchronousRequest:theRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (!connectionError) {
            NSString *theXML = [[NSString alloc] initWithBytes: [data bytes] length:[data length] encoding:NSUTF8StringEncoding];
            NSDictionary *dic= [XMLReader dictionaryForXMLString:theXML error:nil];
            NSString *strJson=[NSString stringWithFormat:@"%@",dic[@"soap:Envelope"][@"soap:Body"][@"GetFoodNewResponse"][@"GetFoodNewResult"][@"text"]];
            id dicObj = [NSJSONSerialization JSONObjectWithData:[strJson dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            
            if (completion) {
                completion(dicObj);
            }
        }
    }];
}

-(void)callWebservice:(NSDictionary *)requestDict withCompletion:(void(^)(id obj))completion{
    DMLog(@"CALL WEB SERVICE ----BEGIN---- SoapWebServiceEngine-withCompletion");
    
    NSString *soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                              "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                              "<soap:Body>"
                              "<SaveFoodNew xmlns=\"http://webservice.dmwebpro.com/\">"
                              "<CategoryID>%@</CategoryID>"
                              "<UserID>%@</UserID>"
                              "<Name>%@</Name>"
                              "<Calories>%@</Calories>"
                              "<Fat>%@</Fat>"
                              "<Sodium>%@</Sodium>"
                              "<Carbohydrates>%@</Carbohydrates>"
                              "<SaturatedFat>%@</SaturatedFat>"
                              "<Cholesterol>%@</Cholesterol>"
                              "<Protein>%@</Protein>"
                              "<Fiber>%@</Fiber>"
                              "<Sugars>%@</Sugars>"
                              "<Pot>%@</Pot>"
                              "<A>%@</A>"
                              "<Thi>%@</Thi>"
                              "<Rib>%@</Rib>"
                              "<Nia>%@</Nia>"
                              "<B6>%@</B6>"
                              "<B12>%@</B12>"
                              "<Fol>%@</Fol>"
                              "<C>%@</C>"
                              "<Calc>%@</Calc>"
                              "<Iron>%@</Iron>"
                              "<Mag>%@</Mag>"
                              "<Zn>%@</Zn>"
                              "<D>%@</D>"
                              "<E>%@</E>"
                              "<ServingSize>%@</ServingSize>"
                              "<MeasureID>%@</MeasureID>"
                              "<GoID>%@</GoID>"
                              "<AuthKey>%@</AuthKey>"
                              "<ScannedFood>%@</ScannedFood>"
                              "</SaveFoodNew>"
                              "</soap:Body>"
                              "</soap:Envelope>",
                              
                              [NSString stringWithFormat:@"%i",[[requestDict valueForKey:@"CategoryID"] intValue]],
                              [requestDict valueForKey:@"UserID"],
                              [requestDict valueForKey:@"Name"],
                              [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Calories"] doubleValue]],
                              [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Fat"] doubleValue]],
                              [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Sodium"] doubleValue]],
                              [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Carbohydrates"] doubleValue]],
                              [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"SaturatedFat"] doubleValue]],
                              [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Cholesterol"] doubleValue]],
                              [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Protein"] doubleValue]],
                              [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Fiber"] doubleValue]],
                              [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Sugars"] doubleValue]],
                              [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Pot"] doubleValue]],
                              [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"A"] doubleValue]],
                              [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Thi"] doubleValue]],
                              [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Rib"] doubleValue]],
                              [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Nia"] doubleValue]],
                              [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"B6"] doubleValue]],
                              [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"B12"] doubleValue]],
                              [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Fol"] doubleValue]],
                              [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"C"] doubleValue]],
                              [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Calc"] doubleValue]],
                              [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Iron"] doubleValue]],
                              [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Mag"] doubleValue]],
                              [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Zn"] doubleValue]],
                              [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"D"] doubleValue]],
                              [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"E"] doubleValue]],
                              [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"ServingSize"] doubleValue]],
                              [NSString stringWithFormat:@"%i",[[requestDict valueForKey:@"MeasureID"] intValue]],
                              
                              //  [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Folate"] doubleValue]],
                              //  [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Transfat"] doubleValue]],
                              [NSString stringWithFormat:@"%i",[[requestDict valueForKey:@"FoodKey"] intValue]],
                              [requestDict valueForKey:@"AuthKey"], [requestDict valueForKey:@"ScannedFood"]];
    
    
    
    soapMessage = [soapMessage stringByReplacingOccurrencesOfString:@"&" withString:@"and"];
       
    NSString *urlToWebservice = [NSString stringWithFormat:@"http://webservice.dmwebpro.com/DMGoWS.asmx?op=SaveFoodNew"];
    NSString *tempuriValue = [NSString stringWithFormat:@"http://webservice.dmwebpro.com/SaveFoodNew"];
        
    NSURL *url = [NSURL URLWithString:urlToWebservice];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: tempuriValue forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
       
    [NSURLConnection sendAsynchronousRequest:theRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (!connectionError) {
            NSString *theXML = [[NSString alloc] initWithBytes: [data bytes] length:[data length] encoding:NSUTF8StringEncoding];
            NSDictionary *dic= [XMLReader dictionaryForXMLString:theXML error:nil];
            NSString *strJson=[NSString stringWithFormat:@"%@",dic[@"soap:Envelope"][@"soap:Body"][@"SaveFoodNewResponse"][@"SaveFoodNewResult"][@"text"]];
            id dicObj = [NSJSONSerialization JSONObjectWithData:[strJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONWritingPrettyPrinted error:nil];
            
            if (completion) {
                completion(dicObj);
            }
        }
    }];
    
    
    
}

- (void)callWebservice:(NSDictionary *)requestDict {
    // Kill the timeout timer
    [timeOutTimer invalidate];
    timeOutTimer = nil;
    
    recordResults = FALSE;
    
    self.requestDict = nil;
    self.requestDict = [[NSDictionary alloc] initWithDictionary:requestDict];
    
    NSString *requestType = [requestDict valueForKey:@"RequestType"];
    NSString *soapMessage = nil;
    
    // Now lay out the different requests:
    if ([requestType isEqualToString:@"SendDeviceToken"]) {
        
        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<SendDeviceToken xmlns=\"http://webservice.dmwebpro.com/\">"
                        "<UserID>%@</UserID>"
                        "<DeviceToken>%@</DeviceToken>"
                        "<AuthKey>%@</AuthKey>"
                        "</SendDeviceToken>"
                        "</soap:Body>"
                        "</soap:Envelope>",
                        [requestDict valueForKey:@"UserID"],
                        [requestDict valueForKey:@"DeviceToken"],
                        [requestDict valueForKey:@"AuthKey"]];
        
    } else if ([requestType isEqualToString:@"SyncUser"]) {
        
        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<SyncUser xmlns=\"http://webservice.dmwebpro.com/\">"
                        "<UserID>%@</UserID>"
                        "<AuthKey>%@</AuthKey>"
                        "</SyncUser>"
                        "</soap:Body>"
                        "</soap:Envelope>",[requestDict valueForKey:@"UserID"], [requestDict valueForKey:@"AuthKey"]];
        
        
    } else if ([requestType isEqualToString:@"SyncWeightLog"]) {
        
        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<SyncWeightLog xmlns=\"http://webservice.dmwebpro.com/\">"
                        "<UserID>%@</UserID>"
                        "<AuthKey>%@</AuthKey>"
                        "<LastSync>%@</LastSync>"
                        "</SyncWeightLog>"
                        "</soap:Body>"
                        "</soap:Envelope>",[requestDict valueForKey:@"UserID"], [requestDict valueForKey:@"AuthKey"], [requestDict valueForKey:@"LastSync"]];
        
        
    } else if ([requestType isEqualToString:@"SyncFoodLog"]) {
        
        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<SyncFoodLog xmlns=\"http://webservice.dmwebpro.com/\">"
                        "<UserID>%@</UserID>"
                        "<AuthKey>%@</AuthKey>"
                        "<LastSync>%@</LastSync>"
                        "</SyncFoodLog>"
                        "</soap:Body>"
                        "</soap:Envelope>",[requestDict valueForKey:@"UserID"], [requestDict valueForKey:@"AuthKey"], [requestDict valueForKey:@"LastSync"]];
        
        
    } else if ([requestType isEqualToString:@"GetMealItems"]) {
        
        tempID = [[requestDict valueForKey:@"MealID"] intValue];
        
        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<GetMealItems xmlns=\"http://webservice.dmwebpro.com/\">"
                        "<UserID>%@</UserID>"
                        "<AuthKey>%@</AuthKey>"
                        "<MealID>%@</MealID>"
                        "</GetMealItems>"
                        "</soap:Body>"
                        "</soap:Envelope>",[requestDict valueForKey:@"UserID"], [requestDict valueForKey:@"AuthKey"], [requestDict valueForKey:@"MealID"]];
        
    } else if ([requestType isEqualToString:@"SyncFavoriteFoods"]) {
        
        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<SyncFavoriteFoods xmlns=\"http://webservice.dmwebpro.com/\">"
                        "<UserID>%@</UserID>"
                        "<AuthKey>%@</AuthKey>"
                        "<LastSync>%@</LastSync>"
                        "</SyncFavoriteFoods>"
                        "</soap:Body>"
                        "</soap:Envelope>",[requestDict valueForKey:@"UserID"], [requestDict valueForKey:@"AuthKey"], [requestDict valueForKey:@"LastSync"]];
        
        
        
    } else if ([requestType isEqualToString:@"SyncFavoriteMeals"]) {
        
        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<SyncFavoriteMeals xmlns=\"http://webservice.dmwebpro.com/\">"
                        "<UserID>%@</UserID>"
                        "<AuthKey>%@</AuthKey>"
                        "</SyncFavoriteMeals>"
                        "</soap:Body>"
                        "</soap:Envelope>",[requestDict valueForKey:@"UserID"], [requestDict valueForKey:@"AuthKey"]];
        
        
        
    } else if ([requestType isEqualToString:@"GetFavoriteMealItems"]) {
        
        tempID = [[requestDict valueForKey:@"Favorite_MealID"] intValue];
        
        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<GetFavoriteMealItems xmlns=\"http://webservice.dmwebpro.com/\">"
                        "<UserID>%@</UserID>"
                        "<AuthKey>%@</AuthKey>"
                        "<MealID>%@</MealID>"
                        "</GetFavoriteMealItems>"
                        "</soap:Body>"
                        "</soap:Envelope>",[requestDict valueForKey:@"UserID"], [requestDict valueForKey:@"AuthKey"], [requestDict valueForKey:@"Favorite_MealID"]];
        
    } else if ([requestType isEqualToString:@"SyncFoods"]) {
        
        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<SyncFoods xmlns=\"http://webservice.dmwebpro.com/\">"
                        "<UserID>%@</UserID>"
                        "<AuthKey>%@</AuthKey>"
                        "<LastSync>%@</LastSync>"
                        "</SyncFoods>"
                        "</soap:Body>"
                        "</soap:Envelope>",[requestDict valueForKey:@"UserID"], [requestDict valueForKey:@"AuthKey"], [requestDict valueForKey:@"LastSync"]];
        
        
        
    } else if ([requestType isEqualToString:@"SyncExerciseLog"]) {
        
        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<SyncExerciseLog xmlns=\"http://webservice.dmwebpro.com/\">"
                        "<UserID>%@</UserID>"
                        "<AuthKey>%@</AuthKey>"
                        "<LastSync>%@</LastSync>"
                        "</SyncExerciseLog>"
                        "</soap:Body>"
                        "</soap:Envelope>",[requestDict valueForKey:@"UserID"], [requestDict valueForKey:@"AuthKey"], [requestDict valueForKey:@"LastSync"]];
        
        
    } else if ([requestType isEqualToString:@"SyncExerciseLogNew"]) {
        //HHT new exercise sync
        
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
                        "</soap:Envelope>",[requestDict valueForKey:@"UserID"], [requestDict valueForKey:@"AuthKey"], [requestDict valueForKey:@"LastSync"],[requestDict valueForKey:@"PageSize"],[requestDict valueForKey:@"PageNumber"]];
    } else if ([requestType isEqualToString:@"SaveMeal"]) {
        
        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<SaveMeal xmlns=\"http://webservice.dmwebpro.com/\">"
                        "<UserID>%@</UserID>"
                        "<goMealID>%@</goMealID>"
                        "<LogDate>%@</LogDate>"
                        "<AuthKey>%@</AuthKey>"
                        "</SaveMeal>"
                        "</soap:Body>"
                        "</soap:Envelope>",
                        [requestDict valueForKey:@"UserID"],
                        [requestDict valueForKey:@"MealID"],
                        [requestDict valueForKey:@"MealDate"],
                        [requestDict valueForKey:@"AuthKey"]];
        
        
        
    } else if ([requestType isEqualToString:@"DeleteMealItem"]) {
        
        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<DeleteMealItem xmlns=\"http://webservice.dmwebpro.com/\">"
                        "<UserID>%@</UserID>"
                        "<MealID>%@</MealID>"
                        "<MealCode>%@</MealCode>"
                        "<FoodID>%@</FoodID>"
                        "<AuthKey>%@</AuthKey>"
                        "</DeleteMealItem>"
                        "</soap:Body>"
                        "</soap:Envelope>",
                        [requestDict valueForKey:@"UserID"],
                        [requestDict valueForKey:@"MealID"],
                        [requestDict valueForKey:@"MealCode"],
                        [requestDict valueForKey:@"FoodID"],
                        [requestDict valueForKey:@"AuthKey"]];
        
        
        
    } else if ([requestType isEqualToString:@"DeleteFavoriteFood"]) {
        
        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<DeleteFavoriteFood xmlns=\"http://webservice.dmwebpro.com/\">"
                        "<UserID>%@</UserID>"
                        "<FoodID>%@</FoodID>"
                        "<AuthKey>%@</AuthKey>"
                        "</DeleteFavoriteFood>"
                        "</soap:Body>"
                        "</soap:Envelope>",
                        [requestDict valueForKey:@"UserID"],
                        [requestDict valueForKey:@"FoodID"],
                        [requestDict valueForKey:@"AuthKey"]];
        
        
        
    } else if ([requestType isEqualToString:@"SaveMealItem_Old"]) {
        
        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<SaveMealItem_Old xmlns=\"http://webservice.dmwebpro.com/\">"
                        "<UserID>%@</UserID>"
                        "<MealID>%@</MealID>"
                        "<goMealID>%@</goMealID>"
                        "<MealCode>%@</MealCode>"
                        "<FoodID>%@</FoodID>"
                        "<MeasureID>%@</MeasureID>"
                        "<ServingSize>%@</ServingSize>"
                        "<AuthKey>%@</AuthKey>"
                        "</SaveMealItem_Old>"
                        "</soap:Body>"
                        "</soap:Envelope>",
                        [requestDict valueForKey:@"UserID"],
                        [requestDict valueForKey:@"MealID"],
                        [requestDict valueForKey:@"MealID"],
                        [requestDict valueForKey:@"MealCode"],
                        [requestDict valueForKey:@"FoodID"],
                        [requestDict valueForKey:@"MeasureID"],
                        [requestDict valueForKey:@"NumberOfServings"],
                        [requestDict valueForKey:@"AuthKey"]];
        
        
        
    } else if ([requestType isEqualToString:@"SaveMealItems"]) {
        
        
        NSString *jsonString = [NSJSONSerialization dataWithJSONObject:[requestDict valueForKey:@"MealItems"] options:0 error:nil];

        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<SaveMealItems xmlns=\"http://webservice.dmwebpro.com/\">"
                        "<UserID>%@</UserID>"
                        "<strJSON>%@</strJSON>"
                        "<AuthKey>%@</AuthKey>"
                        "</SaveMealItems>"
                        "</soap:Body>"
                        "</soap:Envelope>",
                        [requestDict valueForKey:@"UserID"],
                        jsonString,
                        [requestDict valueForKey:@"AuthKey"]];
        
        
        
    } else if ([requestType isEqualToString:@"SaveExerciseLogs"]) {
        
        NSString *jsonString = [NSJSONSerialization dataWithJSONObject:[requestDict valueForKey:@"ExerciseLog"] options:0 error:nil];

        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<SaveExerciseLogs xmlns=\"http://webservice.dmwebpro.com/\">"
                        "<UserID>%@</UserID>"
                        "<strJSON>%@</strJSON>"
                        "<AuthKey>%@</AuthKey>"
                        "</SaveExerciseLogs>"
                        "</soap:Body>"
                        "</soap:Envelope>",
                        [requestDict valueForKey:@"UserID"],
                        jsonString,
                        [requestDict valueForKey:@"AuthKey"]];
        
        
        
        
    } else if ([requestType isEqualToString:@"GetFood"])
        {
        //api change hrp GetFoodNew //<<GetFood
        //api change hrp GetFoodNew //<<GetFood
        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<GetFoodNew xmlns=\"http://webservice.dmwebpro.com/\">"
                        "<UserID>%@</UserID>"
                        "<AuthKey>%@</AuthKey>"
                        "<FoodKey>%i</FoodKey>"
                        "</GetFoodNew>"
                        "</soap:Body>"
                        "</soap:Envelope>",[requestDict valueForKey:@"UserID"], [requestDict valueForKey:@"AuthKey"], [[requestDict valueForKey:@"FoodKey"] intValue]];
        //	  soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
        //					  "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
        //					  "<soap:Body>"
        //					  "<GetFoodNew xmlns=\"http://webservice.dmwebpro.com/\">"
        //					  "<UserID>180380</UserID>"
        //					  "<AuthKey>dmz5ege8</AuthKey>"
        //					  "<FoodKey>456704</FoodKey>"
        //					  "</GetFoodNew>"
        //					  "</soap:Body>"
        //					  "</soap:Envelope>"];
        
        //DMLog(@"requestType: %@, soapMessage: %@",requestType, soapMessage);
    } else if ([requestType isEqualToString:@"SaveWeightLogs"]) {
        
        NSString *jsonString = [NSJSONSerialization dataWithJSONObject:[requestDict valueForKey:@"WeightLog"] options:0 error:nil];

        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<SaveWeightLogs xmlns=\"http://webservice.dmwebpro.com/\">"
                        "<UserID>%@</UserID>"
                        "<strJSON>%@</strJSON>"
                        "<AuthKey>%@</AuthKey>"
                        "</SaveWeightLogs>"
                        "</soap:Body>"
                        "</soap:Envelope>",
                        [requestDict valueForKey:@"UserID"],
                        jsonString,
                        [requestDict valueForKey:@"AuthKey"]];
        
        
        
        
    } else if ([requestType isEqualToString:@"SaveFoodNew"]) {
        
        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<SaveFoodNew xmlns=\"http://webservice.dmwebpro.com/\">"    // old api - SaveFood
                        "<CategoryID>%@</CategoryID>"
                        "<UserID>%@</UserID>"
                        "<Name>%@</Name>"
                        "<Calories>%@</Calories>"
                        "<Fat>%@</Fat>"
                        "<Sodium>%@</Sodium>"
                        "<Carbohydrates>%@</Carbohydrates>"
                        "<SaturatedFat>%@</SaturatedFat>"
                        "<Cholesterol>%@</Cholesterol>"
                        "<Protein>%@</Protein>"
                        "<Fiber>%@</Fiber>"
                        "<Sugars>%@</Sugars>"
                        "<Pot>%@</Pot>"
                        "<A>%@</A>"
                        "<Thi>%@</Thi>"
                        "<Rib>%@</Rib>"
                        "<Nia>%@</Nia>"
                        "<B6>%@</B6>"
                        "<B12>%@</B12>"
                        "<Fol>%@</Fol>"
                        "<C>%@</C>"
                        "<Calc>%@</Calc>"
                        "<Iron>%@</Iron>"
                        "<Mag>%@</Mag>"
                        "<Zn>%@</Zn>"
                        "<D>%@</D>"
                        "<E>%@</E>"
                        "<ServingSize>%@</ServingSize>"
                        "<MeasureID>%@</MeasureID>"
                        "<GoID>%@</GoID>"
                        "<AuthKey>%@</AuthKey>"
                        "<ScannedFood>%@</ScannedFood>"
                        "</SaveFoodNew>"
                        "</soap:Body>"
                        "</soap:Envelope>",
                        
                        [NSString stringWithFormat:@"%i",[[requestDict valueForKey:@"CategoryID"] intValue]],
                        [requestDict valueForKey:@"UserID"],
                        [requestDict valueForKey:@"Name"],
                        [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Calories"] doubleValue]],
                        [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Fat"] doubleValue]],
                        [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Sodium"] doubleValue]],
                        [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Carbohydrates"] doubleValue]],
                        [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"SaturatedFat"] doubleValue]],
                        [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Cholesterol"] doubleValue]],
                        [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Protein"] doubleValue]],
                        [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Fiber"] doubleValue]],
                        [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Sugars"] doubleValue]],
                        [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Pot"] doubleValue]],
                        [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"A"] doubleValue]],
                        [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Thi"] doubleValue]],
                        [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Rib"] doubleValue]],
                        [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Nia"] doubleValue]],
                        [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"B6"] doubleValue]],
                        [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"B12"] doubleValue]],
                        [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Fol"] doubleValue]],
                        [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"C"] doubleValue]],
                        [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Calc"] doubleValue]],
                        [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Iron"] doubleValue]],
                        [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Mag"] doubleValue]],
                        [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Zn"] doubleValue]],
                        [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"D"] doubleValue]],
                        [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"E"] doubleValue]],
                        [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"ServingSize"] doubleValue]],
                        [NSString stringWithFormat:@"%i",[[requestDict valueForKey:@"MeasureID"] intValue]],
                        //2.6 EZON
                        //  [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Folate"] doubleValue]],
                        //  [NSString stringWithFormat:@"%.2f",[[requestDict valueForKey:@"Transfat"] doubleValue]],
                        [NSString stringWithFormat:@"%i",[[requestDict valueForKey:@"FoodKey"] intValue]],
                        [requestDict valueForKey:@"AuthKey"], [requestDict valueForKey:@"ScannedFood"]];
        
        //DMLog(@"requestType: %@",requestType);
        
        
    }
    if ([requestType isEqualToString:@"SaveFavoriteFood"]) {
        
        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<SaveFavoriteFood xmlns=\"http://webservice.dmwebpro.com/\">"
                        "<UserID>%@</UserID>"
                        "<FoodID>%@</FoodID>"
                        "<MeasureID>%@</MeasureID>"
                        "<AuthKey>%@</AuthKey>"
                        "</SaveFavoriteFood>"
                        "</soap:Body>"
                        "</soap:Envelope>",
                        [requestDict valueForKey:@"UserID"],
                        [requestDict valueForKey:@"FoodID"],
                        [requestDict valueForKey:@"MeasureID"],
                        [requestDict valueForKey:@"AuthKey"]];
        
        
        
        
    }
    if ([requestType isEqualToString:@"SaveFavoriteMeal"]) {
        
        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<SaveFavoriteMeal xmlns=\"http://webservice.dmwebpro.com/\">"
                        "<UserID>%@</UserID>"
                        "<goMealID>%@</goMealID>"
                        "<MealName>%@</MealName>"
                        "<AuthKey>%@</AuthKey>"
                        "</SaveFavoriteMeal>"
                        "</soap:Body>"
                        "</soap:Envelope>",
                        [requestDict valueForKey:@"UserID"],
                        [requestDict valueForKey:@"Favorite_MealID"],
                        [requestDict valueForKey:@"Favorite_Meal_Name"],
                        [requestDict valueForKey:@"AuthKey"]];
        
        
        
        
    } else if ([requestType isEqualToString:@"SaveFavoriteMealItem"]) {
        
        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<SaveFavoriteMealItem xmlns=\"http://webservice.dmwebpro.com/\">"
                        "<UserID>%@</UserID>"
                        "<MealID>%@</MealID>"
                        "<goMealID>%@</goMealID>"
                        "<FoodID>%@</FoodID>"
                        "<MeasureID>%@</MeasureID>"
                        "<ServingSize>%@</ServingSize>"
                        "<AuthKey>%@</AuthKey>"
                        "</SaveFavoriteMealItem>"
                        "</soap:Body>"
                        "</soap:Envelope>",
                        [requestDict valueForKey:@"UserID"],
                        [requestDict valueForKey:@"Favorite_Meal_ID"],
                        [requestDict valueForKey:@"Favorite_Meal_ID"],
                        [requestDict valueForKey:@"FoodKey"],
                        [requestDict valueForKey:@"MeasureID"],
                        [requestDict valueForKey:@"Servings"],
                        [requestDict valueForKey:@"AuthKey"]];
        
        
        
        
    } else if ([requestType isEqualToString:@"GetFoodNew"])
    {
        soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                        "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                        "<soap:Body>"
                        "<GetFoodNew xmlns=\"http://webservice.dmwebpro.com/\">"
                        "<UserID>%@</UserID>"
                        "<AuthKey>%@</AuthKey>"
                        "<FoodKey>%i</FoodKey>"
                        "</GetFoodNew>"
                        "</soap:Body>"
                        "</soap:Envelope>",[requestDict valueForKey:@"UserID"], [requestDict valueForKey:@"AuthKey"], [[requestDict valueForKey:@"FoodKey"] intValue]];
        //DMLog(@"requestType: %@, soapMessage: %@",requestType, soapMessage);
    }
    
    
    // Fix error causing string
    soapMessage = [soapMessage stringByReplacingOccurrencesOfString:@"&" withString:@"and"];
    
    //DMLog(@"%@", soapMessage);
    
    NSString *urlToWebservice = [NSString stringWithFormat:@"http://webservice.dmwebpro.com/DMGoWS.asmx?op=%@", requestType];
    NSString *tempuriValue = [NSString stringWithFormat:@"http://webservice.dmwebpro.com/%@", requestType];
    
    NSURL *url = [NSURL URLWithString:urlToWebservice];
    
    //DMLog(@"%@", url);
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: tempuriValue forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    //NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:NO];
    [theConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [theConnection start];
    
    // Start Timer
    timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:120.0
                                                    target:self
                                                  selector:@selector(timeOutWebservice:)
                                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:theConnection, @"connection", nil]
                                                   repeats:NO];
    
    
    if( theConnection ) {
        webData = [NSMutableData data];
    } else {
        DMLog(@"theConnection is NULL");
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //DMLog(@"response is : %@", response);
    [webData setLength: 0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [webData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // Kill the timeout timer
    [timeOutTimer invalidate];
    timeOutTimer = nil;
    
    DMLog(@"ERROR with Connection");
    
    if ([wsGetUserInfoDelegate respondsToSelector:@selector(getUserInfoFailed:)]) {
        [wsGetUserInfoDelegate getUserInfoFailed:[error localizedDescription]];
    }
    if ([wsSyncFoodsDelegate respondsToSelector:@selector(getSyncFoodsFailed:)]) {
        [wsSyncFoodsDelegate getSyncFoodsFailed:[error localizedDescription]];
    }
    if ([wsSyncFoodLogDelegate respondsToSelector:@selector(getSyncFoodLogFailed:)]) {
        [wsSyncFoodLogDelegate getSyncFoodLogFailed:[error localizedDescription]];
    }
    if ([wsSyncFoodLogItemsDelegate respondsToSelector:@selector(getSyncFoodLogItemsFailed:)]) {
        [wsSyncFoodLogItemsDelegate getSyncFoodLogItemsFailed:[error localizedDescription]];
    }
    if ([wsSyncFavoriteFoodsDelegate respondsToSelector:@selector(getSyncFavoriteFoodsFailed:)]) {
        [wsSyncFavoriteFoodsDelegate getSyncFavoriteFoodsFailed:[error localizedDescription]];
    }
    if ([wsSyncFavoriteMealsDelegate respondsToSelector:@selector(getSyncFavoriteMealsFailed:)]) {
        [wsSyncFavoriteMealsDelegate getSyncFavoriteMealsFailed:[error localizedDescription]];
    }
    if ([wsSyncWeightLogDelegate respondsToSelector:@selector(getSyncWeightLogFailed:)]) {
        [wsSyncWeightLogDelegate getSyncWeightLogFailed:[error localizedDescription]];
    }
    if ([wsSyncFavoriteMealItemsDelegate respondsToSelector:@selector(getSyncFavoriteMealItemsFailed:)]) {
        [wsSyncFavoriteMealItemsDelegate getSyncFavoriteMealItemsFailed:[error localizedDescription]];
    }
    if ([wsSyncExerciseLogDelegate respondsToSelector:@selector(getSyncExerciseLogFailed:)]) {
        [wsSyncExerciseLogDelegate getSyncExerciseLogFailed:[error localizedDescription]];
    }
    
    //HHT new exercise sync
    if ([wsSyncExerciseLogNewDelegate respondsToSelector:@selector(getSyncExerciseLogNewFailed:)]) {
        [wsSyncExerciseLogNewDelegate getSyncExerciseLogNewFailed:[error localizedDescription]];
    }
    
    if ([wsSaveMealDelegate respondsToSelector:@selector(saveMealFailed:)]) {
        [wsSaveMealDelegate saveMealFailed:[error localizedDescription]];
    }
    if ([wsSaveMealItemDelegate respondsToSelector:@selector(saveMealItemFailed:)]) {
        [wsSaveMealItemDelegate saveMealItemFailed:[error localizedDescription]];
    }
    if ([wsSaveExerciseLogsDelegate respondsToSelector:@selector(saveExerciseLogsFailed:)]) {
        [wsSaveExerciseLogsDelegate saveExerciseLogsFailed:[error localizedDescription]];
    }
    if ([wsGetFoodDelegate respondsToSelector:@selector(getFoodFailed:)]) {
        [wsGetFoodDelegate getFoodFailed:[error localizedDescription]];
    }
    if ([wsSaveWeightLogDelegate respondsToSelector:@selector(saveWeightLogFailed:)]) {
        [wsSaveWeightLogDelegate saveWeightLogFailed:[error localizedDescription]];
    }
    if ([wsSaveFoodDelegate respondsToSelector:@selector(saveFoodFailed:)]) {
        [wsSaveFoodDelegate saveFoodFailed:[error localizedDescription]];
    }
    if ([wsSaveFavoriteFoodDelegate respondsToSelector:@selector(saveFavoriteFoodFailed:)]) {
        [wsSaveFavoriteFoodDelegate saveFavoriteFoodFailed:[error localizedDescription]];
    }
    if ([wsSaveFavoriteMealDelegate respondsToSelector:@selector(saveFavoriteMealFailed:)]) {
        [wsSaveFavoriteMealDelegate saveFavoriteMealFailed:[error localizedDescription]];
    }
    if ([wsSaveFavoriteMealItemDelegate respondsToSelector:@selector(saveFavoriteMealItemFailed:)]) {
        [wsSaveFavoriteMealItemDelegate saveFavoriteMealItemFailed:[error localizedDescription]];
    }
    if ([wsDeleteMealItemDelegate respondsToSelector:@selector(deleteMealItemFailed:)]) {
        [wsDeleteMealItemDelegate deleteMealItemFailed:[error localizedDescription]];
    }
    if ([wsDeleteFavoriteFoodDelegate respondsToSelector:@selector(deleteFavoriteFoodFailed:)]) {
        [wsDeleteFavoriteFoodDelegate deleteFavoriteFoodFailed:[error localizedDescription]];
    }
    if ([self.wsSendDeviceTokenDelegate respondsToSelector:@selector(sendDeviceFailed:)]) {
        [self.wsSendDeviceTokenDelegate sendDeviceFailed:[error localizedDescription]];
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Kill the timeout timer
    [timeOutTimer invalidate];
    timeOutTimer = nil;
    
    NSString *theXML = [[NSString alloc] initWithBytes: [webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
          
    xmlParser = [[NSXMLParser alloc] initWithData: webData];
    [xmlParser setDelegate: self];
    [xmlParser setShouldResolveExternalEntities: YES];
    [xmlParser parse];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *)qName
   attributes: (NSDictionary *)attributeDict
{
    if( [elementName isEqualToString:@"SyncUserResult"] ||
       [elementName isEqualToString:@"SyncWeightLogResult"] ||
       [elementName isEqualToString:@"SyncFoodLogResult"] ||
       [elementName isEqualToString:@"GetMealItemsResult"] ||
       [elementName isEqualToString:@"SyncFavoriteFoodsResult"] ||
       [elementName isEqualToString:@"SyncFavoriteMealsResult"] ||
       [elementName isEqualToString:@"GetFavoriteMealItemsResult"] ||
       [elementName isEqualToString:@"SyncFoodsResult"] ||
       [elementName isEqualToString:@"SyncExerciseLogResult"] ||
       [elementName isEqualToString:@"SyncExerciseLogNewResult"] ||
       [elementName isEqualToString:@"SaveMealResult"] ||
       [elementName isEqualToString:@"SaveMealItem_OldResult"] ||
       [elementName isEqualToString:@"SaveExerciseLogsResult"] ||
       [elementName isEqualToString:@"GetFoodResult"] ||
       [elementName isEqualToString:@"SaveMealItemsResult"] ||
       [elementName isEqualToString:@"SaveWeightLogsResult"] ||
       [elementName isEqualToString:@"SaveFoodNewResult"] ||
       [elementName isEqualToString:@"SaveFavoriteFoodResult"] ||
       [elementName isEqualToString:@"SaveFavoriteMealResult"] ||
       [elementName isEqualToString:@"SaveFavoriteMealItemResult"] ||
       [elementName isEqualToString:@"DeleteMealItemResult"] ||
       [elementName isEqualToString:@"DeleteFavoriteFoodResult"] ||
       [elementName isEqualToString:@"GetMessagesResult"] ||
       [elementName isEqualToString:@"SendTokenResult"] ||
       [elementName isEqualToString:@"SendMessageResult"] ||
       [elementName isEqualToString:@"SetMessageReadResult"] )
    {
        if(!soapResults)
        {
            soapResults = [[NSMutableString alloc] init];
        }
        recordResults = TRUE;
    }
    
    if( [elementName isEqualToString:@"faultstring"])
    {
        if ([wsGetUserInfoDelegate respondsToSelector:@selector(getUserInfoFailed:)]) {
            [wsGetUserInfoDelegate getUserInfoFailed:@"error"];
        }
        
        if ([wsSyncFoodsDelegate respondsToSelector:@selector(getSyncFoodsFailed:)]) {
            [wsSyncFoodsDelegate getSyncFoodsFailed:@"error"];
        }
        
        if ([wsSyncFoodLogDelegate respondsToSelector:@selector(getSyncFoodLogFailed:)]) {
            [wsSyncFoodLogDelegate getSyncFoodLogFailed:@"error"];
        }
        
        if ([wsSyncFoodLogItemsDelegate respondsToSelector:@selector(getSyncFoodLogItemsFailed:)]) {
            [wsSyncFoodLogItemsDelegate getSyncFoodLogItemsFailed:@"error"];
        }
        
        if ([wsSyncFavoriteFoodsDelegate respondsToSelector:@selector(getSyncFavoriteFoodsFailed:)]) {
            [wsSyncFavoriteFoodsDelegate getSyncFavoriteFoodsFailed:@"error"];
        }
        
        if ([wsSyncFavoriteMealsDelegate respondsToSelector:@selector(getSyncFavoriteMealsFailed:)]) {
            [wsSyncFavoriteMealsDelegate getSyncFavoriteMealsFailed:@"error"];
        }
        
        if ([wsSyncWeightLogDelegate respondsToSelector:@selector(getSyncWeightLogFailed:)]) {
            [wsSyncWeightLogDelegate getSyncWeightLogFailed:@"error"];
        }
        
        if ([wsSyncFavoriteMealItemsDelegate respondsToSelector:@selector(getSyncFavoriteMealItemsFailed:)]) {
            [wsSyncFavoriteMealItemsDelegate getSyncFavoriteMealItemsFailed:@"error"];
        }
        
        if ([wsSyncExerciseLogDelegate respondsToSelector:@selector(getSyncExerciseLogFailed:)]) {
            [wsSyncExerciseLogDelegate getSyncExerciseLogFailed:@"error"];
        }
        
        if ([wsSaveMealDelegate respondsToSelector:@selector(saveMealFailed:)]) {
            [wsSaveMealDelegate saveMealFailed:@"error"];
        }
        
        if ([wsSaveMealItemDelegate respondsToSelector:@selector(saveMealItemFailed:)]) {
            [wsSaveMealItemDelegate saveMealItemFailed:@"error"];
        }
        
        if ([wsSaveExerciseLogsDelegate respondsToSelector:@selector(saveExerciseLogsFailed:)]) {
            [wsSaveExerciseLogsDelegate saveExerciseLogsFailed:@"error"];
        }
        
        if ([wsGetFoodDelegate respondsToSelector:@selector(getFoodFailed:)]) {
            [wsGetFoodDelegate getFoodFailed:@"error"];
        }
        
        if ([wsSaveWeightLogDelegate respondsToSelector:@selector(saveWeightLogFailed:)]) {
            [wsSaveWeightLogDelegate saveWeightLogFailed:@"error"];
        }
        
        if ([wsSaveFoodDelegate respondsToSelector:@selector(saveFoodFailed:)]) {
            [wsSaveFoodDelegate saveFoodFailed:@"error"];
        }
        
        if ([wsSaveFavoriteFoodDelegate respondsToSelector:@selector(saveFavoriteFoodFailed:)]) {
            [wsSaveFavoriteFoodDelegate saveFavoriteFoodFailed:@"error"];
        }
        
        if ([wsSaveFavoriteMealDelegate respondsToSelector:@selector(saveFavoriteMealFailed:)]) {
            [wsSaveFavoriteMealDelegate saveFavoriteMealFailed:@"error"];
        }
        
        if ([wsSaveFavoriteMealItemDelegate respondsToSelector:@selector(saveFavoriteMealItemFailed:)]) {
            [wsSaveFavoriteMealItemDelegate saveFavoriteMealItemFailed:@"error"];
        }
        
        if ([wsDeleteMealItemDelegate respondsToSelector:@selector(deleteMealItemFailed:)]) {
            [wsDeleteMealItemDelegate deleteMealItemFailed:@"error"];
        }
        
        if ([wsDeleteFavoriteFoodDelegate respondsToSelector:@selector(deleteFavoriteFoodFailed:)]) {
            [wsDeleteFavoriteFoodDelegate deleteFavoriteFoodFailed:@"error"];
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

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
    
    recordResults = FALSE;
    
    // Empty results?
    if ([soapResults isEqualToString:@"\"Empty\""]) {
        soapResults = nil;
        soapResults = [[NSMutableString alloc] init];
        [soapResults appendFormat:@"%@",@"[]"];
    }
    
    // Create a dictionary from the JSON string
    NSArray *responseArray = @[];
    if (soapResults.length) {
        responseArray = [NSJSONSerialization JSONObjectWithData:[soapResults dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    }
    
    if([elementName isEqualToString:@"SyncUserResult"])
    {
        if ([wsGetUserInfoDelegate respondsToSelector:@selector(getUserInfoFinished:)]) {
            [wsGetUserInfoDelegate getUserInfoFinished:responseArray];
        }
    }
    
    if([elementName isEqualToString:@"SyncWeightLogResult"])
    {
        
        
        if ([wsSyncWeightLogDelegate respondsToSelector:@selector(getSyncWeightLogFinished:)]) {
            [wsSyncWeightLogDelegate getSyncWeightLogFinished:responseArray];
        }
        
    }
    
    if([elementName isEqualToString:@"SyncFoodLogResult"])
    {
        
        if ([wsSyncFoodLogDelegate respondsToSelector:@selector(getSyncFoodLogFinished:)]) {
            [wsSyncFoodLogDelegate getSyncFoodLogFinished:responseArray];
        }
        
    }
    
    if([elementName isEqualToString:@"GetMealItemsResult"])
    {
        NSString *mealIDString = [NSString stringWithFormat:@"%i",tempID];
        
        NSMutableArray *fixedArray = [NSMutableArray array];
        for (NSDictionary *dict in responseArray) {
            NSMutableDictionary *newDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
            [newDict setValue:mealIDString forKey:@"MealID"];
            [fixedArray addObject:newDict];
        }
        
        if ([wsSyncFoodLogItemsDelegate respondsToSelector:@selector(getSyncFoodLogItemsFinished:)]) {
            [wsSyncFoodLogItemsDelegate getSyncFoodLogItemsFinished:responseArray];
        }
        
    }
    
    if([elementName isEqualToString:@"SyncFavoriteFoodsResult"])
    {
        
        if ([wsSyncFavoriteFoodsDelegate respondsToSelector:@selector(getSyncFavoriteFoodsFinished:)]) {
            [wsSyncFavoriteFoodsDelegate getSyncFavoriteFoodsFinished:responseArray];
        }
        
    }
    
    if([elementName isEqualToString:@"SyncFavoriteMealsResult"])
    {
        
        if ([wsSyncFavoriteMealsDelegate respondsToSelector:@selector(getSyncFavoriteMealsFinished:)]) {
            [wsSyncFavoriteMealsDelegate getSyncFavoriteMealsFinished:responseArray];
        }
        
    }
    
    if([elementName isEqualToString:@"GetFavoriteMealItemsResult"])
    {
        NSString *mealIDString = [NSString stringWithFormat:@"%i",tempID];
        
        NSMutableArray *fixedArray = [NSMutableArray array];
        for (NSDictionary *dict in responseArray) {
            
            NSMutableDictionary *newDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
            [newDict setValue:mealIDString forKey:@"Favorite_Meal_ID"];
            [fixedArray addObject:newDict];
        }
        
        if ([wsSyncFavoriteMealItemsDelegate respondsToSelector:@selector(getSyncFavoriteMealItemsFinished:)]) {
            [wsSyncFavoriteMealItemsDelegate getSyncFavoriteMealItemsFinished:fixedArray];
        }
    }
    
    if([elementName isEqualToString:@"SyncFoodsResult"])
    {
        if ([wsSyncFoodsDelegate respondsToSelector:@selector(getSyncFoodsFinished:)]) {
            [wsSyncFoodsDelegate getSyncFoodsFinished:responseArray];
        }
    }
    
    if([elementName isEqualToString:@"SyncExerciseLogResult"])
    {
        if ([wsSyncExerciseLogDelegate respondsToSelector:@selector(getSyncExerciseLogFinished:)]) {
            [wsSyncExerciseLogDelegate getSyncExerciseLogFinished:responseArray];
        }
    }
    
    //HHT new exercise sync
    if([elementName isEqualToString:@"SyncExerciseLogNewResult"])
    {
        if ([wsSyncExerciseLogNewDelegate respondsToSelector:@selector(getSyncExerciseLogNewFinished:)]) {
            [wsSyncExerciseLogNewDelegate getSyncExerciseLogNewFinished:responseArray];
        }
    }
    
    if([elementName isEqualToString:@"SaveMealResult"])
    {
        
        if ([soapResults rangeOfString:@"System.Data.SqlClient.SqlException"].location != NSNotFound) {
            DMLog(@"System.Data.SqlClient.SqlException!!!!!");
            if ([wsSaveMealDelegate respondsToSelector:@selector(saveMealFailed:)]) {
                [wsSaveMealDelegate saveMealFailed:[self.requestDict valueForKey:@"MealID"]];
            }
        } else {
            if ([wsSaveMealDelegate respondsToSelector:@selector(saveMealFinished:)]) {
                [wsSaveMealDelegate saveMealFinished:responseArray];
            }
        }
        
    }
    
    if([elementName isEqualToString:@"SaveMealItemsResult"])
    {
        
        if ([wsSaveMealItemDelegate respondsToSelector:@selector(saveMealItemFinished:)]) {
            [wsSaveMealItemDelegate saveMealItemFinished:responseArray];
        }
        
    }
    
    if([elementName isEqualToString:@"SaveMealItem_OldResult"])
    {
        
        
        if ([wsSaveMealItemDelegate respondsToSelector:@selector(saveMealItemFinished:)]) {
            [wsSaveMealItemDelegate saveMealItemFinished:responseArray];
        }
        
    }
    
    if([elementName isEqualToString:@"SaveExerciseLogsResult"])
    {
        if ([wsSaveExerciseLogsDelegate respondsToSelector:@selector(saveExerciseLogsFinished:)]) {
            [wsSaveExerciseLogsDelegate saveExerciseLogsFinished:responseArray];
        }
        
    }
    
    if([elementName isEqualToString:@"GetFoodNewResult"])
    {
        //hirpara1
        //      DMLog(@" hirpara1 GetFoodResult soapResults: %@",soapResults);
        
        /* if ([wsGetFoodDelegate respondsToSelector:@selector(getFoodFinished:)])
         {
         
         [wsGetFoodDelegate getFoodFinished:responseArray];
         }*/
        
    }
    
    if([elementName isEqualToString:@"SaveWeightLogsResult"])
    {
        if ([wsSaveWeightLogDelegate respondsToSelector:@selector(saveWeightLogFinished:)]) {
            [wsSaveWeightLogDelegate saveWeightLogFinished:responseArray];
        }
        
    }
    
    if([elementName isEqualToString:@"SaveFoodNewResult"])    //   SaveFoodResult
    {
        //2.6 EZON
        
        
        if ([wsSaveFoodDelegate respondsToSelector:@selector(saveFoodFinished:)]) {
            [wsSaveFoodDelegate saveFoodFinished:responseArray];
        }
        
    }
    
    if ([elementName isEqualToString:@"SaveFavoriteFoodResult"]) {
        if ([wsSaveFavoriteFoodDelegate respondsToSelector:@selector(saveFavoriteFoodFinished:)]) {
            [wsSaveFavoriteFoodDelegate saveFavoriteFoodFinished:responseArray];
        }
        
    }
    
    if([elementName isEqualToString:@"SaveFavoriteMealResult"])
    {
        
        if ([wsSaveFavoriteMealDelegate respondsToSelector:@selector(saveFavoriteMealFinished:)]) {
            [wsSaveFavoriteMealDelegate saveFavoriteMealFinished:responseArray];
        }
        
    }
    
    if([elementName isEqualToString:@"SaveFavoriteMealItemResult"])
    {
        
        if ([wsSaveFavoriteMealItemDelegate respondsToSelector:@selector(saveFavoriteMealItemFinished:)]) {
            [wsSaveFavoriteMealItemDelegate saveFavoriteMealItemFinished:responseArray];
        }
        
    }
    
    if([elementName isEqualToString:@"DeleteMealItemResult"])
    {
        
        if ([wsDeleteMealItemDelegate respondsToSelector:@selector(deleteMealItemFinished:)]) {
            [wsDeleteMealItemDelegate deleteMealItemFinished:responseArray];
        }
        
    }
    
    if([elementName isEqualToString:@"DeleteFavoriteFoodResult"])
    {
        if ([wsDeleteFavoriteFoodDelegate respondsToSelector:@selector(deleteFavoriteFoodFinished:)]) {
            [wsDeleteFavoriteFoodDelegate deleteFavoriteFoodFinished:responseArray];
        }
        
    }

    if([elementName isEqualToString:@"SendTokenResult"])
    {
        if ([self.wsSendDeviceTokenDelegate respondsToSelector:@selector(sendDeviceFinished:)]) {
            [self.wsSendDeviceTokenDelegate sendDeviceFinished:responseArray];
        }
    }
    
    soapResults = nil;
    
}

//- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
//    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
//    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
//}

#pragma mark TIMEOUT METHOD
-(void)timeOutWebservice:(NSTimer *)theTimer {
    
    NSURLConnection *connection = [[theTimer userInfo] objectForKey:@"connection"];
    [connection cancel];
    connection = nil;
    
    // Kill the timeout timer
    [timeOutTimer invalidate];
    timeOutTimer = nil;
    
    webData = nil;
    
    
    if ([wsGetUserInfoDelegate respondsToSelector:@selector(getUserInfoFailed:)]) {
        [wsGetUserInfoDelegate getUserInfoFailed:@"error"];
    }
    if ([wsSyncFoodsDelegate respondsToSelector:@selector(getSyncFoodsFailed:)]) {
        [wsSyncFoodsDelegate getSyncFoodsFailed:@"error"];
    }
    if ([wsSyncFoodLogDelegate respondsToSelector:@selector(getSyncFoodLogFailed:)]) {
        [wsSyncFoodLogDelegate getSyncFoodLogFailed:@"error"];
    }
    if ([wsSyncFoodLogItemsDelegate respondsToSelector:@selector(getSyncFoodLogItemsFailed:)]) {
        [wsSyncFoodLogItemsDelegate getSyncFoodLogItemsFailed:@"error"];
    }
    if ([wsSyncFavoriteFoodsDelegate respondsToSelector:@selector(getSyncFavoriteFoodsFailed:)]) {
        [wsSyncFavoriteFoodsDelegate getSyncFavoriteFoodsFailed:@"error"];
    }
    if ([wsSyncFavoriteMealsDelegate respondsToSelector:@selector(getSyncFavoriteMealsFailed:)]) {
        [wsSyncFavoriteMealsDelegate getSyncFavoriteMealsFailed:@"error"];
    }
    if ([wsSyncWeightLogDelegate respondsToSelector:@selector(getSyncWeightLogFailed:)]) {
        [wsSyncWeightLogDelegate getSyncWeightLogFailed:@"error"];
    }
    if ([wsSyncFavoriteMealItemsDelegate respondsToSelector:@selector(getSyncFavoriteMealItemsFailed:)]) {
        [wsSyncFavoriteMealItemsDelegate getSyncFavoriteMealItemsFailed:@"error"];
    }
    if ([wsSyncExerciseLogDelegate respondsToSelector:@selector(getSyncExerciseLogFailed:)]) {
        [wsSyncExerciseLogDelegate getSyncExerciseLogFailed:@"error"];
    }
    if ([wsSaveMealDelegate respondsToSelector:@selector(saveMealFailed:)]) {
        [wsSaveMealDelegate saveMealFailed:@"error"];
    }
    if ([wsSaveMealItemDelegate respondsToSelector:@selector(saveMealItemFailed:)]) {
        [wsSaveMealItemDelegate saveMealItemFailed:@"error"];
    }
    if ([wsSaveExerciseLogsDelegate respondsToSelector:@selector(saveExerciseLogsFailed:)]) {
        [wsSaveExerciseLogsDelegate saveExerciseLogsFailed:@"error"];
    }
    if ([wsGetFoodDelegate respondsToSelector:@selector(getFoodFailed:)]) {
        [wsGetFoodDelegate getFoodFailed:@"error"];
    }
    if ([wsSaveWeightLogDelegate respondsToSelector:@selector(saveWeightLogFailed:)]) {
        [wsSaveWeightLogDelegate saveWeightLogFailed:@"error"];
    }
    if ([wsSaveFoodDelegate respondsToSelector:@selector(saveFoodFailed:)]) {
        [wsSaveFoodDelegate saveFoodFailed:@"error"];
    }
    if ([wsSaveFavoriteFoodDelegate respondsToSelector:@selector(saveFavoriteFoodFailed:)]) {
        [wsSaveFavoriteFoodDelegate saveFavoriteFoodFailed:@"error"];
    }
    if ([wsSaveFavoriteMealDelegate respondsToSelector:@selector(saveFavoriteMealFailed:)]) {
        [wsSaveFavoriteMealDelegate saveFavoriteMealFailed:@"error"];
    }
    if ([wsSaveFavoriteMealItemDelegate respondsToSelector:@selector(saveFavoriteMealItemFailed:)]) {
        [wsSaveFavoriteMealItemDelegate saveFavoriteMealItemFailed:@"error"];
    }
    if ([wsDeleteMealItemDelegate respondsToSelector:@selector(deleteMealItemFailed:)]) {
        [wsDeleteMealItemDelegate deleteMealItemFailed:@"error"];
    }
}

@end
