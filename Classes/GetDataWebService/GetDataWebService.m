//
//  GetDataWebService.m
//  DietMasterGo
//
//  Created by Henry Kirk on 8/12/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import "GetDataWebService.h"
#import "NSNull+NullCategoryExtension.h"

@implementation GetDataWebService

@synthesize webData, soapResults, xmlParser;
@synthesize getDataWSDelegate;
@synthesize requestDict = _requestDict;

- (void)callWebservice:(NSDictionary *)requestDict {
    DMLog(@"SOAP CALL ----BEGIN---- GetDataWebService");
    
    recordResults = FALSE;
    self.requestDict = nil;
    self.requestDict = [[NSDictionary alloc] initWithDictionary:requestDict];
    
    requestType = [requestDict valueForKey:@"RequestType"];
    NSMutableString *requestString = [NSMutableString new];
    
    [requestString appendFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
     "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
     "<soap:Body>"
     "<%@ xmlns=\"http://webservice.dmwebpro.com/\">", requestType];
    
    NSDictionary *parameterDict = [requestDict valueForKey:@"parameters"];
    for (id key in [parameterDict allKeys]) {
        [requestString appendFormat:@"<%@>%@</%@>", key, [parameterDict valueForKey:key], key];
    }
    
    [requestString appendFormat:@"</%@>", requestType];
    [requestString appendString:@"</soap:Body></soap:Envelope>"];
    
    [requestString replaceOccurrencesOfString:@"&" withString:@"and" options:NULL range:NSMakeRange(0, requestString.length)];
    
    NSString *urlToWebservice = [NSString stringWithFormat:@"http://webservice.dmwebpro.com/DMGoWS.asmx?op=%@", requestType];
    NSString *tempuriValue = [NSString stringWithFormat:@"http://webservice.dmwebpro.com/%@", requestType];
    
    DMLog(@"%@", requestString);
    
    NSURL *url = [NSURL URLWithString:urlToWebservice];
    
    DMLog(@"%@", url);
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[requestString length]];
    
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: tempuriValue forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [requestString dataUsingEncoding:NSUTF8StringEncoding]];
    
    webData = [NSMutableData data];
    
    [NSURLConnection sendAsynchronousRequest:theRequest queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               [webData setLength: 0];
                               [webData appendData:data];
                               
                               if (error) {
                                   if ([getDataWSDelegate respondsToSelector:@selector(getDataFailed:)]) {
                                       [getDataWSDelegate getDataFailed:[error localizedDescription]];
                                   }
                               }
                               else {
                                   NSString *theXML = [[NSString alloc] initWithBytes:[webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
                                   
                                   xmlParser = [[NSXMLParser alloc] initWithData: webData];
                                   [xmlParser setDelegate: self];
                                   [xmlParser setShouldResolveExternalEntities: YES];
                                   [xmlParser parse];
                               }
                           }];
    
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *)qName attributes: (NSDictionary *)attributeDict {
	if( [elementName isEqualToString:[NSString stringWithFormat:@"%@Result",requestType]]) {
		if(!soapResults) {
			soapResults = [[NSMutableString alloc] init];
		}
		recordResults = TRUE;
	}
    
    if( [elementName isEqualToString:@"faultstring"]) {
        if ([getDataWSDelegate respondsToSelector:@selector(getDataFailed:)]) {
            [getDataWSDelegate getDataFailed:@"error"];
        }
	}
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if( recordResults) {
		[soapResults appendString: string];
	}
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    recordResults = FALSE;
    
	if([elementName isEqualToString:[NSString stringWithFormat:@"%@Result",requestType]]) {
        NSData *data = [[soapResults copy] dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError* error;
        NSDictionary *responseDict = [NSJSONSerialization
                                      JSONObjectWithData:data
                                      options:0
                                      error:&error];
        
        if ([getDataWSDelegate respondsToSelector:@selector(getDataFinished:)]) {
			            [getDataWSDelegate getDataFinished:responseDict];
        }
    }
      
    soapResults = nil;
}

@end
