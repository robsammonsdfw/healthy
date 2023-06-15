//
//  DMGUtilities.h
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/15/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Returns object or empty string if nil.
static id __attribute__((unused)) ObjectOrEmptyString(id object) {
    return object ? object : @"";
}

/// Returns object or empty NSNumber with value of zero if nil.
static id __attribute__((unused)) ObjectOrNSNumber(id object) {
    return object ? object : @0;
}

/// Returns int or zero if nil.
static int __attribute__((unused)) IntOrZero(NSNumber * number) {
    return number ? number.intValue : 0;
}

/// Returns double or zero if nil.
static double __attribute__((unused)) DoubleOrZero(NSNumber * number) {
    return number ? number.doubleValue : 0.0;
}

/// Returns the UIColor from Hex.
static UIColor * __attribute__((unused)) UIColorFromHex(int hexColor) {
    UIColor *colorResult = [UIColor colorWithRed:(hexColor>>16&0xFF)/255. green:(hexColor>>8&0xFF)/255. blue:(hexColor>>0&0xFF)/255. alpha:1];
    return colorResult;
}

/// Utilities used across the project.
@interface DMGUtilities : NSObject
@end

NS_ASSUME_NONNULL_END
