//
//  NSString+ConvertToDate.m
//  CreditWise
//

#import "NSString+ConvertToDate.h"

@implementation NSString (ConvertToDate)

- (NSDate *)dateWithFormat:(NSString *)format locale:(NSLocale *)locale
{
  NSDateFormatter *formatter = [NSDateFormatter new];
	if (locale)
		[formatter setLocale:locale];
  [formatter setDateFormat:format];
  
  NSDate *result = [formatter dateFromString:self];
  return result;
}

- (NSDate *)dateWithFormat:(NSString *)format
{
  return [self dateWithFormat:format locale:[NSLocale localeWithLocaleIdentifier:@"en"]];
}

@end
