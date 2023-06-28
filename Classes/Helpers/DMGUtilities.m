//
//  DMGUtilities.m
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/15/23.
//

#import "DMGUtilities.h"
#import "DMActivityIndicator.h"
#import "NSString+Encode.h"
@import MessageUI;

@interface DMGUtilities()
@end

@implementation DMGUtilities

- (instancetype)init {
    self = [super init];
    return self;
}

#pragma mark - Sync Helpers

static NSString *DMLastSyncPrefsKey = @"lastsyncdate";
static NSString *DMFirstLaunchKey = @"FirstTime";
static NSString *DMServerDateFormat = @"yyyy-MM-dd HH:mm:ss";

/// Returns the formatted string: "yyyy-MM-dd HH:mm:ss" when the last data sync ocurred.
/// If a sync has not happened, will return a date in 1970.
+ (NSString *)lastSyncDateString {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *dateString = nil;
    
    if ([[defaults valueForKey:DMFirstLaunchKey] isEqualToString:@"FirstTime"]) {
        dateString = @"1970-01-01";
        [defaults setObject:@"SecondTime" forKey:DMFirstLaunchKey];
    } else {
        dateString = [defaults valueForKey:DMLastSyncPrefsKey];
        // If current date is missing, let's assume the last sync as a week ago.
        if (!dateString) {
            NSDate *syncDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay
                                                                        value:-8
                                                                       toDate:[NSDate date]
                                                                      options:0];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.timeZone = [NSTimeZone systemTimeZone];
            [dateFormatter setDateFormat:DMServerDateFormat];
            dateString = [dateFormatter stringFromDate:syncDate];
        }
    }
    
    return dateString;
}

+ (NSString *)setLastSyncToDate:(NSDate *)date {
    NSString *dateString = nil;
    if (!date) {
        dateString = [self lastSyncDateString];
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeZone = [NSTimeZone systemTimeZone];
        [dateFormatter setDateFormat:DMServerDateFormat];
        dateString = [dateFormatter stringFromDate:date];
    }
    
    // Save to defaults.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:dateString forKey:DMLastSyncPrefsKey];
    
    return dateString;
}

#pragma mark - Color

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

#pragma mark - View Helpers

+ (UIViewController *)topMostViewController {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    // SDK expects a key window at this point, if it is not, make it one
    if (keyWindow !=  nil && !keyWindow.isKeyWindow) {
        [keyWindow makeKeyWindow];
    }
    
    UIViewController *topController = keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}

+ (UIViewController *)rootViewController {
    UIViewController *rootViewController = nil;
    return [self window].rootViewController;
}

/// Returns the UIWindow, taking into account iOS 13's scene delegate.
+ (UIWindow *)window {
    UIScene *scene = [UIApplication sharedApplication].connectedScenes.allObjects.firstObject;
    if([scene.delegate conformsToProtocol:@protocol(UIWindowSceneDelegate)]){
        UIWindow *window = [(id <UIWindowSceneDelegate>)scene.delegate window];
        return window;
    }
    return nil;
}

#pragma mark - Alert Helpers

+ (void)showError:(NSError *)error withTitle:(NSString *)title message:(NSString *)message okActionBlock:(completionBlock)okActionBlock inViewController:(UIViewController *)viewController {
    if ([NSThread isMainThread]) {
        if (error) {
            [DMActivityIndicator hideActivityIndicatorExceptProgress];
        }
        UIViewController *rootViewController = [DMGUtilities topMostViewController];
        if (viewController) {
            rootViewController = viewController;
        }
        NSString *expandedMessage = message;
        if (error) {
            expandedMessage = [NSString stringWithFormat:@"%@ (Code: %li, Reason: %@)", message, (long)error.code, error.localizedDescription];
        }
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:expandedMessage
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    [alert dismissViewControllerAnimated:YES completion:^{
                                                        if (okActionBlock) {
                                                            okActionBlock(YES);
                                                        }
                                                    }];
                                                }]];
        if (error) {
            [alert addAction:[UIAlertAction actionWithTitle:@"Contact Support"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                [alert dismissViewControllerAnimated:YES completion:^{
                    NSString *body = [NSString stringWithFormat:@"\nPlease do not delete this Error info:\n Domain: %@, Code: %li, Description: %@\n", error.domain, (long)error.code, error.localizedDescription];
                    if ([MFMailComposeViewController canSendMail]) {
                        // Set the delegate to be "root view controller".
                        UIViewController *topMostViewController = [DMGUtilities topMostViewController];
                        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
                        mailComposer.mailComposeDelegate = (id<MFMailComposeViewControllerDelegate>)[DMGUtilities rootViewController];
                        mailComposer.modalPresentationStyle = UIModalPresentationFormSheet;
                        [mailComposer setSubject:@"Support Request"];
                        [mailComposer setToRecipients:@[@"js@dietmastersoftware.com"]];
                        [mailComposer setMessageBody:body isHTML:NO];
                        [topMostViewController presentViewController:mailComposer animated:YES completion:nil];
                    } else {
                        NSString *subjectString = @"Support Request";
                        NSString *urlString = [NSString stringWithFormat:@"mailto:js@dietmastersoftware.com?subject=%@&body=%@", [subjectString encodeStringForURL], [body encodeStringForURL]];
                        NSURL *mailToURL = [NSURL URLWithString:urlString];
                        [[UIApplication sharedApplication] openURL:mailToURL options:@{} completionHandler:^(BOOL success) {
                            if (!success) {
                                [DMGUtilities showAlertWithTitle:@"Error!" message:@"Email is not available." inViewController:nil];
                            }
                        }];
                    }
                }];
            }]];
        }
        [rootViewController presentViewController:alert animated:YES completion:nil];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showError:error withTitle:title message:message okActionBlock:okActionBlock inViewController:viewController];
        });
    }
}

+ (void)showError:(NSError *)error withTitle:(NSString *)title message:(NSString *)message inViewController:(UIViewController *)viewController {
    return [self showError:error withTitle:title message:message okActionBlock:nil inViewController:viewController];
}

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message inViewController:(UIViewController *)viewController {
    return [self showError:nil withTitle:title message:message okActionBlock:nil inViewController:viewController];
}

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message okActionBlock:(completionBlock)actionBlock inViewController:(UIViewController *)viewController {
    return [self showError:nil withTitle:title message:message okActionBlock:actionBlock inViewController:viewController];
}

#pragma mark - Error Handling

+ (NSError *)errorWithMessage:(NSString *)message code:(NSInteger)code {
    NSString *errorDomain = @"com.dietmaster.error";
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey: message
    };
    NSError *error = [NSError errorWithDomain:errorDomain code:code userInfo:userInfo];

    return error;
}

@end
