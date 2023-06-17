//
//  DMActivityIndicator.m
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/16/23.
//

#import "DMActivityIndicator.h"
#import <MBProgressHUD/MBProgressHUD.h>

static MBProgressHUD *activityView;

@implementation DMActivityIndicator

+ (void)initialize {
    // create static instance
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    // SDK expects a key window at this point, if it is not, make it one
    if (keyWindow !=  nil && !keyWindow.isKeyWindow) {
        [keyWindow makeKeyWindow];
    }

    UIViewController *rootViewController = keyWindow.rootViewController;
    activityView = [[MBProgressHUD alloc] initWithView:rootViewController.view];
    activityView.removeFromSuperViewOnHide = YES;
    activityView.contentColor = [UIColor colorWithWhite:0.0f alpha:0.8f];
}

+ (void)defaultSetup {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    // SDK expects a key window at this point, if it is not, make it one
    if (keyWindow !=  nil && !keyWindow.isKeyWindow) {
        [keyWindow makeKeyWindow];
    }

    [keyWindow addSubview:activityView];
    activityView.animationType = MBProgressHUDAnimationZoom;
    activityView.mode = MBProgressHUDModeIndeterminate;
    activityView.label.text = nil;
}

+ (void)showActivityIndicator {
    if ([NSThread isMainThread]) {
        [DMActivityIndicator showActivityIndicatorWithMessage:nil];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [DMActivityIndicator showActivityIndicator];
        });
    }
}

+ (void)showActivityIndicatorWithMessage:(NSString *)message {
    if ([NSThread isMainThread]) {
        [DMActivityIndicator defaultSetup];
        activityView.label.text = [message copy];
        [activityView showAnimated:YES];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [DMActivityIndicator showActivityIndicatorWithMessage:message];
        });
    }
}

+ (void)showCompletedIndicator {
    if ([NSThread isMainThread]) {
        [DMActivityIndicator showCompletedIndicatorWithMessage:@"Completed"];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [DMActivityIndicator showCompletedIndicator];
        });
    }
}

+ (void)showCompletedIndicatorWithMessage:(NSString *)message {
    if ([NSThread isMainThread]) {
        UIImage *image = [UIImage imageNamed:@"37x-Checkmark"];
        [DMActivityIndicator showWithCustomImage:image andMessage:message];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [DMActivityIndicator showCompletedIndicatorWithMessage:message];
        });
    }
}

+ (void)showWithCustomImage:(UIImage *)image andMessage:(NSString *)message {
    if ([NSThread isMainThread]) {
        [DMActivityIndicator defaultSetup];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        activityView.customView = imageView;
        activityView.mode = MBProgressHUDModeCustomView;
        activityView.label.text = [message copy];
        [activityView showAnimated:YES];
        [activityView hideAnimated:YES afterDelay:1.5];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [DMActivityIndicator showWithCustomImage:image andMessage:message];
        });
    }
}

+ (void)showProgressIndicator {
    if ([NSThread isMainThread]) {
        [DMActivityIndicator defaultSetup];
        activityView.mode = MBProgressHUDModeDeterminate;
        [activityView showAnimated:YES];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [DMActivityIndicator showProgressIndicator];
        });
    }
}

+ (void)showProgressIndicatorWithMessage:(NSString *)message {
    if ([NSThread isMainThread]) {
        [DMActivityIndicator defaultSetup];
        activityView.mode = MBProgressHUDModeDeterminate;
        activityView.label.text = [message copy];
        activityView.label.numberOfLines = 0;
        [activityView showAnimated:YES];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [DMActivityIndicator showProgressIndicatorWithMessage:message];
        });
    }
}

+ (void)updateProgressIndicatorWithMessage:(NSString *)message {
    if ([NSThread isMainThread]) {
        activityView.label.text = [message copy];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [DMActivityIndicator updateProgressIndicatorWithMessage:message];
        });
    }
}

+ (void)updateProgressIndicatorWithProgress:(CGFloat)progress {
    if ([NSThread isMainThread]) {
        activityView.progress = (float)progress;
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [DMActivityIndicator updateProgressIndicatorWithProgress:progress];
        });
    }
}

+ (void)hideActivityIndicator {
    if ([NSThread isMainThread]) {
        [activityView hideAnimated:YES afterDelay:0.25];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [DMActivityIndicator hideActivityIndicator];
        });
    }
}

+ (void)hideActivityIndicatorExceptProgress {
    if ([NSThread isMainThread]) {
        if (activityView.mode != MBProgressHUDModeDeterminate) {
            [activityView hideAnimated:YES afterDelay:0.25];
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [DMActivityIndicator hideActivityIndicatorExceptProgress];
        });
    }
}

@end
