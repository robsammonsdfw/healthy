//
//  LoginViewController.h
//  DietMasterGo
//
//  Created by Henry Kirk on 2/14/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMConstants.h"

/// Displays a login UI to the user.
@interface LoginViewController : BaseViewController

/// Logins the user automatically from the authcode provided.
- (void)loginFromUrl:(NSString *)authcode;

/// Presents the login controller as a full sheet modal (iOS 15+), with
/// completion block when login is complete. If controller is nil, the
/// rootViewController will be used.
- (void)presentLoginInController:(UIViewController *)controller
                  withCompletion:(completionBlockWithError)completionBlock;

@end
