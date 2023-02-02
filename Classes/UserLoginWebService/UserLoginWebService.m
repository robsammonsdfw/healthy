//
//  UserLoginWebService.m
//  DietMasterGo
//
//  Created by Henry Kirk on 2/14/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import "UserLoginWebService.h"
#import "JSON.h"
#import "XMLReader.h"
#import "CommonModule.h"

@implementation UserLoginWebService

@synthesize webData, soapResults, xmlParser;
@synthesize wsAuthenticateUserDelegate;

-(void)callWebservice:(NSString *)text
{
    NSLog(@"CALL WEB SERVICE ----BEGIN---- UserLoginWebService");
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
    NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMessage length]];
    
    NSLog(@"%@", soapMessage);
    
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: @"http://webservice.dmwebpro.com/Authenticate" forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if( theConnection )
    {
        webData = [[NSMutableData data] retain];
    }
    else
    {
        NSLog(@"theConnection is NULL");
    }
    
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [webData setLength: 0];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [webData appendData:data];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"ERROR with Connection");
    
    if ([wsAuthenticateUserDelegate respondsToSelector:@selector(getAuthenticateUserFailed:)]) {
        [wsAuthenticateUserDelegate getAuthenticateUserFailed:[error description]];
    }
    
    [connection release];
    [webData release];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *theXML = [[NSString alloc] initWithBytes: [webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
    
    NSError *error=nil;
    NSDictionary *dic = [XMLReader dictionaryForXMLString:theXML error:&error];
    
    NSLog(@"%@",[[[[[dic objectForKey:@"soap:Envelope"] objectForKey:@"soap:Body"]objectForKey:@"AuthenticateResponse"]objectForKey:@"AuthenticateResult"] objectForKey:@"text"]);
    
    SBJSON *json = [SBJSON new];
    NSMutableDictionary *jsonObject = [[json objectWithString:[[[[[dic objectForKey:@"soap:Envelope"] objectForKey:@"soap:Body"]objectForKey:@"AuthenticateResponse"]objectForKey:@"AuthenticateResult"] objectForKey:@"text"] error:NULL] objectAtIndex:0];
    
    NSString *strAlertMessage = [jsonObject objectForKey:@"Message"];
    NSString *strEmail = [jsonObject objectForKey:@"Email1"];
    NSString *strUsername = [jsonObject objectForKey:@"Username"];
        
    [[NSUserDefaults standardUserDefaults]setObject:strEmail forKey:@"LoginEmail"];
    [[NSUserDefaults standardUserDefaults] setObject:strUsername forKey:@"username_dietmastergo"];
        
    [[NSUserDefaults standardUserDefaults]synchronize];
    //Service has been terminated. Contact your plan provider.
    
    //change BY HHT
    if ([strAlertMessage containsString:@"Service has been terminated."]) {
        AppDel.isSessionExp = YES;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_NAME message:strAlertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [[NSUserDefaults standardUserDefaults]setObject:@"SecondTime" forKey:@"FirstTime"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        alertView.tag = 1;
        [alertView show];
    }
    
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1) {
        exit(0);
    }
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *)qName
   attributes: (NSDictionary *)attributeDict
{
    if( [elementName isEqualToString:@"AuthenticateResult"])
    {
        if(!soapResults)
        {
            soapResults = [[NSMutableString alloc] init];
        }
        recordResults = TRUE;
    }
    
    if( [elementName isEqualToString:@"faultstring"])
    {
        NSLog(@"ERROR with Connection");
        
        if ([wsAuthenticateUserDelegate respondsToSelector:@selector(getAuthenticateUserFailed:)]) {
            [wsAuthenticateUserDelegate getAuthenticateUserFailed:@"error"];
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
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"AuthenticateResult"])
    {
        recordResults = FALSE;
        
        // Create a dictionary from the JSON string
        NSMutableArray *responseArray = [soapResults JSONValue];
        
        if ([wsAuthenticateUserDelegate respondsToSelector:@selector(getAuthenticateUserFinished:)]) {
            [wsAuthenticateUserDelegate getAuthenticateUserFinished:responseArray];
        }
        [soapResults release];
        soapResults = nil;
    }
}

//- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
//    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
//    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
//}

- (void)dealloc 
{
    [xmlParser release];
    [super dealloc];
}
@end
