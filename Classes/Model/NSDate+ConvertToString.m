//
//  NSDate+ConvertToString.m
//  CreditWise
//

#import "NSDate+ConvertToString.h"

@implementation NSDate (ConvertToString)

- (NSString *)stringWithFormat:(NSString *)format locale:(NSLocale *)locale
{
  NSDateFormatter *formatter = [NSDateFormatter new];
	if (locale)
		[formatter setLocale:locale];
  
  [formatter setDateFormat:format];
  [formatter setAMSymbol:@"AM"];
  [formatter setPMSymbol:@"PM"];
  
  NSString *result = [formatter stringFromDate:self];
  return result;
}

- (NSString *)stringWithFormat:(NSString *)format
{
  return [self stringWithFormat:format locale:nil];
}

@end
