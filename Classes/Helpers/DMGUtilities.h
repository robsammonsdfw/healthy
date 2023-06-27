//
//  DMGUtilities.h
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/15/23.
//

#import <Foundation/Foundation.h>
#import "DMConstants.h"

NS_ASSUME_NONNULL_BEGIN

/// Returns object or empty string if nil.
static NSString * __attribute__((unused)) ValidString(id object) {
    return (object && object != [NSNull null]) ? object : @"";
}

/// Returns object or empty NSNumber with value of zero if nil.
static NSNumber * __attribute__((unused)) ValidNSNumber(id object) {
    return (object && object != [NSNull null]) ? object : @0;
}

/// Returns int or zero if nil.
static int __attribute__((unused)) ValidInt(NSNumber * number) {
    return (number && number != [NSNull null]) ? number.intValue : 0;
}

/// Returns double or zero if nil.
static double __attribute__((unused)) ValidDouble(NSNumber * number) {
    return (number && number != [NSNull null]) ? number.doubleValue : 0.0;
}

/// Returns the UIColor from Hex.
static UIColor * __attribute__((unused)) UIColorFromHex(int hexColor) {
    UIColor *colorResult = [UIColor colorWithRed:(hexColor>>16&0xFF)/255. green:(hexColor>>8&0xFF)/255. blue:(hexColor>>0&0xFF)/255. alpha:1];
    return colorResult;
}

/// Utilities used across the project.
@interface DMGUtilities : NSObject

/// Returns an image with the provided UIColor.
+ (UIImage *)imageWithColor:(UIColor *)color;

#pragma mark - View Helpers

/// Iterates presentedViewController until it finds the top most controller.
/// Note: This could be an UIAlertController, which will stop the presenting.
+ (UIViewController *)topMostViewController;

/// Returns the RootViewController, taking into account iOS 13's scene delegate.
+ (UIViewController *)rootViewController;

/// Returns the UIWindow, taking into account iOS 13's scene delegate.
+ (UIWindow *)window;

#pragma mark - Alert Helpers

/// Shows an alert error message to the user. Appends Error code and message to end of message.
+ (void)showError:(nullable NSError *)error withTitle:(NSString *)title message:(NSString *)message inViewController:(nullable UIViewController *)viewController;

/// Shows an alert error message to the user. Appends Error code and message to end of message. Also has OK action button block.
+ (void)showError:(nullable NSError *)error withTitle:(NSString *)title message:(NSString *)message okActionBlock:(completionBlock)actionBlock inViewController:(nullable UIViewController *)viewController;

/// Shows an alert to user with OK button.
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message inViewController:(nullable UIViewController *)viewController;

/// Shows an alert to user with OK button and an action block for the OK button.
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message okActionBlock:(completionBlock)actionBlock inViewController:(nullable UIViewController *)viewController;

#pragma mark - Error Handling

/// Helper to create a generic error with message and code.
+ (NSError *)errorWithMessage:(NSString *)message code:(NSInteger)code;

@end

NS_ASSUME_NONNULL_END
