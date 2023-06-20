//
//  NSObject+Description.h
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/19/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (DMDescription)

/// Category that will list out all the properties of a class as a formatted string.
/// e.g. "Name : [value], ...".
- (NSString *)listPropertiesAsString;

@end

NS_ASSUME_NONNULL_END
