//
//  NSDate+ConvertToString.h
//  CreditWise
//

#import <Foundation/Foundation.h>

@interface NSDate (ConvertToString)

- (NSString *)stringWithFormat:(NSString *)format locale:(NSLocale *)locale;
- (NSString *)stringWithFormat:(NSString *)format;

@end
