//
//  UserLoginWebService.m
//  DietMasterGo
//
//  Created by Henry Kirk on 2/14/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import "UserLoginWebService.h"
#import "XMLReader.h"

@implementation UserLoginWebService

@synthesize webData, soapResults, xmlParser;

-(void)callWebservice:(NSString *)text
{
    DMLog(@"CALL WEB SERVICE ----BEGIN---- UserLoginWebService");
    recordResults = FALSE;
    
    NSString *soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                              "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                              "<soap:Body>"
                              "<Authenticate xmlns=\"http://webservice.dmwebpro.com/\">"
                              "<AuthKey>%@</AuthKey>"
                              "</Authenticate>"
                              "</soap:Body>"
                              "</soap:Envelope>",text];
    
    NSURL *url = [NSURL URLWithString:@"http://webservice.dmwebpro.com/DMGoWS.asmx?op=Authenticate"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%li", [soapMessage length]];
        
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: @"http://webservice.dmwebpro.com/Authenticate" forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (theConnection) {
        webData = [NSMutableData data];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [webData setLength: 0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [webData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    DMLog(@"ERROR with Connection");
    
    if ([self.wsAuthenticateUserDelegate respondsToSelector:@selector(getAuthenticateUserFailed:)]) {
        [self.wsAuthenticateUserDelegate getAuthenticateUserFailed:[error description]];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *theXML = [[NSString alloc] initWithBytes: [webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
    
    NSError *error=nil;
    NSDictionary *xmlDict = [XMLReader dictionaryForXMLString:theXML error:&error];
    
    NSString *responseString = [[[[[xmlDict objectForKey:@"soap:Envelope"] objectForKey:@"soap:Body"] objectForKey:@"AuthenticateResponse"] objectForKey:@"AuthenticateResult"] objectForKey:@"text"];
    DMLog(@"%@", responseString);
    
    NSDictionary *jsonObject = @{};
    if (responseString.length) {
        jsonObject = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil][0];
    }
    
    NSString *strAlertMessage = jsonObject[@"Message"];
    NSString *strEmail = jsonObject[@"Email1"];
    NSString *strUsername = jsonObject[@"Username"];
    
    [[NSUserDefaults standardUserDefaults] setObject:strEmail forKey:@"LoginEmail"];
    [[NSUserDefaults standardUserDefaults] setObject:strUsername forKey:@"username_dietmastergo"];
       
    //change BY HHT
    if ([strAlertMessage containsString:@"Service has been terminated."]) {
        AppDel.isSessionExp = YES;
        [DMGUtilities showAlertWithTitle:APP_NAME message:strAlertMessage okActionBlock:^(BOOL completed) {
            exit(0);
        } inViewController:nil];
        [[NSUserDefaults standardUserDefaults] setObject:@"SecondTime" forKey:@"FirstTime"];
    }
    
    xmlParser = [[NSXMLParser alloc] initWithData: webData];
    [xmlParser setDelegate: self];
    [xmlParser setShouldResolveExternalEntities: YES];
    [xmlParser parse];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *)qName
   attributes: (NSDictionary *)attributeDict {
    if([elementName isEqualToString:@"AuthenticateResult"]) {
        if (!soapResults) {
            soapResults = [[NSMutableString alloc] init];
        }
        recordResults = TRUE;
    }
    
    if ([elementName isEqualToString:@"faultstring"]) {
        DMLog(@"ERROR with Connection");
        
        if ([self.wsAuthenticateUserDelegate respondsToSelector:@selector(getAuthenticateUserFailed:)]) {
            [self.wsAuthenticateUserDelegate getAuthenticateUserFailed:@"error"];
        }
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (recordResults) {
        [soapResults appendString: string];
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"AuthenticateResult"])
    {
        recordResults = FALSE;
        
        // Create a dictionary from the JSON string
        NSMutableArray *responseArray = [NSJSONSerialization JSONObjectWithData:[soapResults dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];

        if ([self.wsAuthenticateUserDelegate respondsToSelector:@selector(getAuthenticateUserFinished:)]) {
            [self.wsAuthenticateUserDelegate getAuthenticateUserFinished:responseArray];
        }
        soapResults = nil;
    }
}

@end
