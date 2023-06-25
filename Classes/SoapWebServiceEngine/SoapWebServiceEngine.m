//
//  SoapWebServiceEngine.m
//  DietMasterGo
//
//  Created by Henry Kirk on 2/14/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import "SoapWebServiceEngine.h"
#import "XMLReader.h"

@interface SoapWebServiceEngine()
/// Optional completion block called when a sync finishes.
@property (nonatomic, copy) completionBlockWithObject completionBlock;

@property (nonatomic, strong) NSMutableData *webData;
@property (nonatomic, strong) NSMutableString *soapResults;
@property (nonatomic, strong) NSXMLParser *xmlParser;
@property (nonatomic, strong) NSDictionary *requestDict;

@end

@implementation SoapWebServiceEngine

@synthesize requestDict = _requestDict;
- (void)callWebserviceForFoodNew:(NSDictionary *)requestDict withCompletion:(void (^)(id))completion {
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
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(dicObj);
                }
            });
        }
    }];
}

- (void)callFoodsWebservice:(NSDictionary *)requestDict withCompletion:(void(^)(id obj))completion {
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
            id dicObj = [NSJSONSerialization JSONObjectWithData:[strJson dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(dicObj);
                }
            });
        }
    }];
}

- (void)callWebservice:(NSDictionary *)requestDict withCompletion:(completionBlockWithObject)completionBlock {
    self.completionBlock = completionBlock;
    [self callWebservice:requestDict];
}

- (void)callWebservice:(NSDictionary *)requestDict {
    recordResults = FALSE;
    self.soapResults = [[NSMutableString alloc] init];

    self.requestDict = nil;
    self.requestDict = [[NSDictionary alloc] initWithDictionary:requestDict];
    
    NSString *requestType = [requestDict valueForKey:@"RequestType"];
    NSString *soapMessage = nil;
    
    // Now lay out the different requests:
    if ([requestType isEqualToString:@"SyncWeightLog"]) {
        
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
        
        NSString *jsonString = @"[]";
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[requestDict valueForKey:@"MealItems"] options:0 error:nil];
        if (jsonData) {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        
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
        
        NSString *jsonString = @"[]";
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[requestDict valueForKey:@"ExerciseLog"] options:0 error:nil];
        if (jsonData) {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }

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
        
        
        
        
    } else if ([requestType isEqualToString:@"GetFood"]) {
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
                        "</soap:Envelope>",[requestDict valueForKey:@"UserID"],
                        [requestDict valueForKey:@"AuthKey"],
                        [[requestDict valueForKey:@"FoodKey"] intValue]];

    } else if ([requestType isEqualToString:@"SaveWeightLogs"]) {
        
        NSString *jsonString = @"[]";
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[requestDict valueForKey:@"WeightLog"] options:0 error:nil];
        if (jsonData) {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }

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
                        [NSString stringWithFormat:@"%i",[[requestDict valueForKey:@"FoodKey"] intValue]],
                        [requestDict valueForKey:@"AuthKey"], [requestDict valueForKey:@"ScannedFood"]];
        
    } else if ([requestType isEqualToString:@"SaveFavoriteFood"]) {
        
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
        
    } else if ([requestType isEqualToString:@"SaveFavoriteMeal"]) {
        
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
        
    } else if ([requestType isEqualToString:@"GetFoodNew"]) {
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
    
    // Fix error causing string
    soapMessage = [soapMessage stringByReplacingOccurrencesOfString:@"&" withString:@"and"];
    NSString *urlToWebservice = [NSString stringWithFormat:@"http://webservice.dmwebpro.com/DMGoWS.asmx?op=%@", requestType];
    NSString *tempuriValue = [NSString stringWithFormat:@"http://webservice.dmwebpro.com/%@", requestType];
    
    NSURL *url = [NSURL URLWithString:urlToWebservice];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url
                                                              cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                          timeoutInterval:120];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: tempuriValue forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:NO];
    [theConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [theConnection start];
    
    if (theConnection) {
        self.webData = [NSMutableData data];
    } else {
        DMLog(@"theConnection is NULL");
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //DMLog(@"response is : %@", response);
    [self.webData setLength: 0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.webData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self processError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.xmlParser = [[NSXMLParser alloc] initWithData: self.webData];
    [self.xmlParser setDelegate: self];
    [self.xmlParser setShouldResolveExternalEntities: YES];
    [self.xmlParser parse];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *)qName
   attributes: (NSDictionary *)attributeDict {
    if( [elementName isEqualToString:@"SyncUserResult"] ||
       [elementName isEqualToString:@"SyncWeightLogResult"] ||
       [elementName isEqualToString:@"SyncFoodLogResult"] ||
       [elementName isEqualToString:@"GetMealItemsResult"] ||
       [elementName isEqualToString:@"SyncFavoriteFoodsResult"] ||
       [elementName isEqualToString:@"SyncFavoriteMealsResult"] ||
       [elementName isEqualToString:@"GetFavoriteMealItemsResult"] ||
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
       [elementName isEqualToString:@"DeleteFavoriteFoodResult"])
    {
        recordResults = TRUE;
    }
    
    if( [elementName isEqualToString:@"faultstring"]) {
        NSError *error = [DMGUtilities errorWithMessage:@"Error. Fault during sync." code:444];
        if (self.completionBlock) {
            self.completionBlock(nil, error);
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ( recordResults ) {
        [self.soapResults appendString: string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    recordResults = FALSE;
    
    // Empty results?
    if ([self.soapResults isEqualToString:@"\"Empty\""]) {
        self.soapResults = [[NSMutableString alloc] init];
        [self.soapResults appendFormat:@"%@",@"[]"];
    }
    
    // Create a dictionary from the JSON string
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

    if([elementName isEqualToString:@"GetMealItemsResult"]) {
        NSString *mealIDString = [NSString stringWithFormat:@"%i",tempID];
        NSMutableArray *fixedArray = [NSMutableArray array];
        for (NSDictionary *dict in responseArray) {
            NSMutableDictionary *newDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
            [newDict setValue:mealIDString forKey:@"MealID"];
            [fixedArray addObject:newDict];
        }
        responseArray = fixedArray;
    }
    
    if([elementName isEqualToString:@"GetFavoriteMealItemsResult"]) {
        NSString *mealIDString = [NSString stringWithFormat:@"%i",tempID];
        
        NSMutableArray *fixedArray = [NSMutableArray array];
        for (NSDictionary *dict in responseArray) {
            
            NSMutableDictionary *newDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
            [newDict setValue:mealIDString forKey:@"Favorite_Meal_ID"];
            [fixedArray addObject:newDict];
        }
        responseArray = fixedArray;
    }
    
    if([elementName isEqualToString:@"SaveMealResult"]) {
        if ([self.soapResults rangeOfString:@"System.Data.SqlClient.SqlException"].location != NSNotFound) {
            DMLog(@"System.Data.SqlClient.SqlException!!!!!");
            NSError *error = [DMGUtilities errorWithMessage:@"System.Data.SqlClient.SqlException" code:999];
            [self processError:error];
            return;
        }
    }
    
    // Success!
    if (self.completionBlock) {
        self.completionBlock(responseArray, nil);
    }
}

/// Processes an incoming error.
- (void)processError:(NSError *)error {
    DM_LOG(@"Error: %@", error.localizedDescription);
    
    if (self.completionBlock) {
        self.completionBlock(nil, error);
    }
}

@end
