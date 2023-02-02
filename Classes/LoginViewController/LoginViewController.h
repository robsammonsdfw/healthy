//
//  LoginViewController.h
//  DietMasterGo
//
//  Created by Henry Kirk on 2/14/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

// password encryption
#import "SHA1PHPClass.h"

// engine
#import "DietmasterEngine.h"
#import "UserLoginWebService.h"
#import "SoapWebServiceEngine.h"

@interface LoginViewController : UIViewController  <UITextFieldDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, WSAuthenticateUserDelegate, WSGetUserInfoDelegate, UpdateUserInfoDelegate, SyncDatabaseDelegate> {
    
    IBOutlet UITextField *usernameField;
    IBOutlet UITextField *passwordField;
    IBOutlet UIActivityIndicatorView *cellSpinner;
    CGFloat animatedDistance;
    IBOutlet UILabel *appNameLabel;
    NSMutableArray*arrVlaue;

}
@property (retain, nonatomic) IBOutlet UIImageView *imgtop;
@property (retain, nonatomic) IBOutlet UIButton *emailbtuuon;
@property (nonatomic, retain) IBOutlet UILabel *appNameLabel;
@property (nonatomic, retain) IBOutlet UIButton *loginButton;
@property (retain) UserLoginWebService *userLoginWS;
@property (retain, nonatomic) IBOutlet UIButton *signUpBtn;

-(IBAction)sendLoginInfo:(id)sender;
-(IBAction)emailUs:(id)sender;
-(IBAction)termsOfService:(id)sender;
-(IBAction)privacyPolicy:(id)sender;
-(void)syncUserInfo:(id)sender;
-(void)loginFromUrl:(NSString *)authcode;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImgVw;

@end
