//
//  DMActivityIndicator.h
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/16/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Helper class that takes care of displaying and hiding an activity indicator.
/// It will add a HUD to root view. And will dispatch to main thread if not called from it.
@interface DMActivityIndicator : NSObject

+ (void)showActivityIndicator;

+ (void)showActivityIndicatorWithMessage:(NSString *)message;

/// Shows "Completed" with a check mark
+ (void)showCompletedIndicator;

+ (void)showCompletedIndicatorWithMessage:(NSString *)message;

+ (void)showWithCustomImage:(UIImage *)image andMessage:(NSString *)message;

+ (void)showProgressIndicator;

+ (void)showProgressIndicatorWithMessage:(NSString *)message;

+ (void)updateProgressIndicatorWithMessage:(NSString *)message;

+ (void)updateProgressIndicatorWithProgress:(CGFloat)progress;

+ (void)hideActivityIndicator;

/// Hides an activity indicator except for progress.
+ (void)hideActivityIndicatorExceptProgress;

@end

NS_ASSUME_NONNULL_END
