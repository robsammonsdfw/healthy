//
//  SHA1PHPClass.m
//  TheAnalyst
//
//  Created by Henry T Kirk on 4/16/11.
//  Copyright 2011 Blyncc, LLC. All rights reserved.
//

#import "SHA1PHPClass.h"
#import <CommonCrypto/CommonDigest.h>

@implementation SHA1PHPClass

+(NSString*) digest:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
    
}
@end
