//
//  LoginViewController.h
//  DietMasterGo
//
//  Created by Henry Kirk on 2/14/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <UIKit/UIKit.h>

/// Displays a login UI to the user.
@interface LoginViewController : UIViewController

/// Logins the user automatically from the authcode provided.
- (void)loginFromUrl:(NSString *)authcode;

/// Performs a sync of the user's info, such as BMR, Height, Goals, etc.
/// NOTE: This is redundant to the function in the DMG Engine. Need to validate
/// if this is still needed.
- (void)syncUserInfo:(id)sender;

@end
