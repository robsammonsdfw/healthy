//
//  NSObject+Description.m
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/19/23.
//

#import "NSObject+Description.h"

@implementation NSObject (DMDescription)

- (NSString *)listPropertiesAsString {
    unsigned int numberOfProperties = 0;
    objc_property_t *propertyArray = class_copyPropertyList([self class], &numberOfProperties);
    NSMutableString *output = [NSMutableString string];
    for (NSUInteger i = 0; i < numberOfProperties; i++) {
        objc_property_t property = propertyArray[i];
        NSString *name = [[NSString alloc] initWithUTF8String:property_getName(property)];
        NSString *value = [NSString stringWithFormat:@"%@: '%@'", name, [self valueForKey:name]];
        [output appendString:value];
        if (i < numberOfProperties - 1) {
            [output appendString:@", "];
        }
    }
    return [output copy];
}

@end
