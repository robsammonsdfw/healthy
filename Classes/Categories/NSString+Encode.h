//
//  NSString+Encode.h
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/16/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (DMEncode)
/// Encodes a string for a URL by applying URLQueryAllowedCharacterSet.
- (NSString *)encodeStringForURL;
@end

NS_ASSUME_NONNULL_END

