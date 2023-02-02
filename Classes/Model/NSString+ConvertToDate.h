//
//  NSString+ConvertToDate.h
//  CreditWise
//

#import <Foundation/Foundation.h>

@interface NSString (ConvertToDate)

- (NSDate *)dateWithFormat:(NSString *)format locale:(NSLocale *)locale;
- (NSDate *)dateWithFormat:(NSString *)format;

@end
