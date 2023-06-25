//
//  GetDataWebService.m
//  DietMasterGo
//
//  Created by Henry Kirk on 8/12/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import "GetDataWebService.h"
#import "NSNull+NullCategoryExtension.h"

@interface GetDataWebService()
@property (nonatomic, strong) NSDictionary *requestDict;
@property (nonatomic, strong) NSMutableData *webData;
@property (nonatomic, strong) NSMutableString *soapResults;
@property (nonatomic, strong) NSXMLParser *xmlParser;
@property (nonatomic, strong) NSString *requestType;
@end

@implementation GetDataWebService

- (void)callWebservice:(NSDictionary *)requestDict {
    recordResults = FALSE;
    self.requestDict = nil;
    self.requestDict = [[NSDictionary alloc] initWithDictionary:requestDict];
    self.soapResults = [[NSMutableString alloc] init];
    self.requestType = [requestDict valueForKey:@"RequestType"];
    NSMutableString *requestString = [NSMutableString new];
    
    [requestString appendFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
     "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
     "<soap:Body>"
     "<%@ xmlns=\"http://webservice.dmwebpro.com/\">", self.requestType];
    
    NSDictionary *parameterDict = [requestDict valueForKey:@"parameters"];
    for (id key in [parameterDict allKeys]) {
        [requestString appendFormat:@"<%@>%@</%@>", key, [parameterDict valueForKey:key], key];
    }
    
    [requestString appendFormat:@"</%@>", self.requestType];
    [requestString appendString:@"</soap:Body></soap:Envelope>"];
    [requestString replaceOccurrencesOfString:@"&" withString:@"and" options:NULL range:NSMakeRange(0, requestString.length)];
    
    NSString *urlToWebservice = [NSString stringWithFormat:@"http://webservice.dmwebpro.com/DMGoWS.asmx?op=%@", self.requestType];
    NSString *tempuriValue = [NSString stringWithFormat:@"http://webservice.dmwebpro.com/%@", self.requestType];
    //DMLog(@"%@", requestString);
    NSURL *url = [NSURL URLWithString:urlToWebservice];
    //DMLog(@"%@", url);
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url
                                                              cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                          timeoutInterval:120];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[requestString length]];
    
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: tempuriValue forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [requestString dataUsingEncoding:NSUTF8StringEncoding]];
    
    self.webData = [NSMutableData data];
    
    __weak typeof(self) weakSelf = self;
    [NSURLConnection sendAsynchronousRequest:theRequest queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                __strong typeof(weakSelf) strongSelf = weakSelf;
                               [strongSelf.webData setLength: 0];
                               [strongSelf.webData appendData:data];
                               
                               if (error) {
                                   if ([strongSelf.getDataWSDelegate respondsToSelector:@selector(getDataFailed:)]) {
                                       [strongSelf.getDataWSDelegate getDataFailed:[error localizedDescription]];
                                   }
                               }
                               else {
                                   NSString *theXML = [[NSString alloc] initWithBytes:[strongSelf.webData mutableBytes] length:[strongSelf.webData length] encoding:NSUTF8StringEncoding];
                                   strongSelf.xmlParser = [[NSXMLParser alloc] initWithData: strongSelf.webData];
                                   [strongSelf.xmlParser setDelegate: self];
                                   [strongSelf.xmlParser setShouldResolveExternalEntities: YES];
                                   [strongSelf.xmlParser parse];
                               }
                           }];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *)qName attributes: (NSDictionary *)attributeDict {
	if( [elementName isEqualToString:[NSString stringWithFormat:@"%@Result", self.requestType]]) {
		recordResults = TRUE;
	}
    
    if( [elementName isEqualToString:@"faultstring"]) {
        if ([self.getDataWSDelegate respondsToSelector:@selector(getDataFailed:)]) {
            [self.getDataWSDelegate getDataFailed:@"error"];
        }
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (recordResults) {
		[self.soapResults appendString: string];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    recordResults = FALSE;
    
	if([elementName isEqualToString:[NSString stringWithFormat:@"%@Result", self.requestType]]) {
        NSData *data = [[self.soapResults copy] dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError* error;
        NSDictionary *responseDict = [NSJSONSerialization
                                      JSONObjectWithData:data
                                      options:0
                                      error:&error];
        
        if ([self.getDataWSDelegate respondsToSelector:@selector(getDataFinished:)]) {
            [self.getDataWSDelegate getDataFinished:responseDict];
        }
    }
}

@end
