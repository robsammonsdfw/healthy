//
//  NSString+Encode.m
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/16/23.
//

#import <Foundation/Foundation.h>

@implementation NSString (DMEncode)

- (NSString *)encodeStringForURL {
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

@end
