//  DietMasterGoAppDelegate.h
//  DietMasterGo
//
//  Created by Andrew Moffitt on 11/23/10.
//  Copyright 2010 AE Studios. All rights reserved.

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "PurchaseIAPHelper.h"

@class DietMasterGoViewController;
@class DetailViewController;
@class LoginViewController;

@interface DietMasterGoAppDelegate : NSObject <UIApplicationDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate>;

@property (nonatomic, strong) NSString *idStr;

- (void)loginFromUrl:(NSString *)loginUrl;

@end

