//
//  LoginViewController.m
//  DietMasterGo
//
//  Created by Henry Kirk on 2/14/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import "LoginViewController.h"

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "DietmasterEngine.h"
#import "DMDataFetcher.h"

#import "LearnMoreViewController.h"
#import "DietMasterGoViewController.h"
#import "InAppPurchaseViewController.h"
#import "MyMovesViewController.h"
#import "ProfileAlertVCViewController.h"

#import "DietMasterGoPlus-Swift.h"
#import "DMUser.h"
#import "NSString+Encode.h"

#import "DMMyLogDataProvider.h"

@interface LoginViewController() <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UITextField *usernameField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;
@property (nonatomic, strong) IBOutlet UILabel *appNameLabel;
@property (nonatomic, strong) IBOutlet UIImageView *imgtop;
@property (nonatomic, strong) IBOutlet UIButton *emailbtuuon;
@property (nonatomic, strong) IBOutlet UIButton *loginButton;
@property (nonatomic, strong) IBOutlet UIButton *signUpBtn;
@property (nonatomic, strong) IBOutlet UIImageView *backgroundImgVw;

@property (nonatomic, strong) IBOutlet UILabel *pleaseLoginLabel;
@property (nonatomic, strong) IBOutlet UILabel *needHelpLabel;
@property (nonatomic, strong) IBOutlet UILabel *secureConnectionLabel;
@property (nonatomic, strong) IBOutlet UIButton *privacyPolicyButton;
@property (nonatomic, strong) IBOutlet UIButton *termsOfServiceButton;

/// Completion block that should be called when login is complete.
@property (nonatomic, copy) completionBlockWithError completionBlock;

- (IBAction)emailUs:(id)sender;
- (IBAction)termsOfService:(id)sender;
- (IBAction)privacyPolicy:(id)sender;

@end

@implementation LoginViewController

- (instancetype)init {
    self = [super initWithNibName:@"LoginViewController" bundle:nil];
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.backgroundImgVw.image = AppConfiguration.loginBackgroundImage;
    self.appNameLabel.hidden = false;
    self.imgtop.hidden = false;

    self.loginButton.backgroundColor = AppConfiguration.buttonColor;
    self.loginButton.layer.cornerRadius = 5;
    
    self.emailbtuuon.backgroundColor = AppConfiguration.buttonColor;
    self.emailbtuuon.layer.cornerRadius = 5;
    
    self.signUpBtn.backgroundColor = AppConfiguration.buttonColor;
    self.signUpBtn.layer.cornerRadius = 5;
    self.signUpBtn.hidden = YES;
    if (self.signUpBtn.hidden) {
        [self.loginButton.leadingAnchor constraintEqualToAnchor:self.passwordField.leadingAnchor constant:0].active = YES;
    }
    
    self.imgtop.backgroundColor = AppConfiguration.headerColor;
    
    NSString *appName = AppConfiguration.appNameLong;
    self.appNameLabel.text = appName;
    
    if ([AppConfiguration.accountCode isEqualToString:@"ezdietplanner"]) {
        UIImageView *backgroundImage = (UIImageView *)[self.view viewWithTag:501];
        backgroundImage.image = [UIImage imageNamed:@"Login_Screen"];
        [self.loginButton setBackgroundImage:[UIImage imageNamed:@"button_small"] forState:UIControlStateNormal];
        [self.loginButton setBackgroundImage:[UIImage imageNamed:@"button_small"] forState:UIControlStateHighlighted];
        [self.loginButton setBackgroundImage:[UIImage imageNamed:@"button_small"] forState:UIControlStateSelected];
        UIButton *helpButton = (UIButton *)[self.view viewWithTag:601];
        [helpButton setBackgroundImage:[UIImage imageNamed:@"button_small"] forState:UIControlStateNormal];
        [helpButton setBackgroundImage:[UIImage imageNamed:@"button_small"] forState:UIControlStateHighlighted];
        [helpButton setBackgroundImage:[UIImage imageNamed:@"button_small"] forState:UIControlStateSelected];
    }
    
    // Set text colors.
    self.appNameLabel.textColor = AppConfiguration.headerTextColor;
    [self.loginButton setTitleColor:AppConfiguration.buttonTextColor forState:UIControlStateNormal];
    [self.signUpBtn setTitleColor:AppConfiguration.buttonTextColor forState:UIControlStateNormal];
    [self.emailbtuuon setTitleColor:AppConfiguration.buttonTextColor forState:UIControlStateNormal];

    self.pleaseLoginLabel.textColor = AppConfiguration.loginViewTextColor;
    self.needHelpLabel.textColor = AppConfiguration.loginViewTextColor;
    self.secureConnectionLabel.textColor = AppConfiguration.loginViewTextColor;
    [self.privacyPolicyButton setTitleColor:AppConfiguration.loginViewTextColor forState:UIControlStateNormal];
    [self.termsOfServiceButton setTitleColor:AppConfiguration.loginViewTextColor forState:UIControlStateNormal];

    // Enable iCloud Password Autofill.
    self.usernameField.textContentType = UITextContentTypeUsername;
    self.passwordField.textContentType = UITextContentTypePassword;
    self.passwordField.secureTextEntry = YES;
    
    // Add some padding to left.
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
    spacerView.backgroundColor = [UIColor clearColor];
    [self.usernameField setLeftViewMode:UITextFieldViewModeAlways];
    [self.usernameField setLeftView:spacerView];
    UIView *spacerView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
    spacerView2.backgroundColor = [UIColor clearColor];
    [self.passwordField setLeftViewMode:UITextFieldViewModeAlways];
    [self.passwordField setLeftView:spacerView2];
}

#pragma mark - UITextField Delegate

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    
    if ([self.usernameField isFirstResponder] && [touch view] != self.usernameField) {
        [self.usernameField resignFirstResponder];
    }
    
    if ([self.passwordField isFirstResponder] && [touch view] != self.passwordField) {
        [self.passwordField resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

- (BOOL)textFieldShouldReturn:(UITextField*)aTextField {
    [aTextField resignFirstResponder];
    return YES;
}

#pragma mark - Actions

- (void)loginFromUrl:(NSString *)authcode {
    if (authcode.length) {
        NSArray *items = [authcode componentsSeparatedByString:@":"];
        if (items.count == 2) {
            self.passwordField.text = [items objectAtIndex:0];
            self.usernameField.text = [items objectAtIndex:1];
        }
    }
}

- (void)presentLoginInController:(UIViewController *)controller
                  withCompletion:(completionBlockWithError)completionBlock {
    UIViewController *rootController = [DMGUtilities rootViewController];
    // If our login controller is already presented modally, exit this.
    if ([rootController.presentedViewController isKindOfClass:[self class]]) {
        return;
    }
    if (controller) {
        rootController = controller;
    }
    self.completionBlock = completionBlock;
    self.modalPresentationStyle = UIModalPresentationPageSheet;
    self.sheetPresentationController.detents = @[[UISheetPresentationControllerDetent largeDetent]];
    self.modalInPresentation = YES; // Prevent dismissal with swipe.
    [rootController presentViewController:self animated:YES completion:nil];
}

#pragma mark - Button Actions

/// Sends login to server to login the user.
- (IBAction)sendLoginInfo:(id)sender {
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [DMActivityIndicator showActivityIndicator];

    if (!self.passwordField.text.length || !self.usernameField.text.length) {
        [DMGUtilities showAlertWithTitle:@"Oops!" message:@"Username or Mobile Password field is empty. Please try again." inViewController:nil];
        self.loginButton.enabled = YES;
        [DMActivityIndicator hideActivityIndicator];
    } else {
        self.loginButton.enabled = NO;
        
        NSString *tokenToSend = [[NSString stringWithString:self.passwordField.text] uppercaseString];
        DMAuthManager *authManager = [DMAuthManager sharedInstance];
        [authManager loginUserWithToken:tokenToSend completionBlock:^(NSObject *user, NSError *error) {
            [DMActivityIndicator hideActivityIndicator];
            self.loginButton.enabled = YES;
            if (error) {
                [DMGUtilities showAlertWithTitle:AppConfiguration.appNameShort message:error.localizedDescription inViewController:nil];
                return;
            }
            if (self.completionBlock) {
                self.completionBlock(YES, nil);
            }
        }];
    }
}

- (IBAction)emailUs:(id)sender {
    NSString *appName = AppConfiguration.appNameShort;
    NSString *subjectString = [NSString stringWithFormat:@"%@ App Help & Support", appName];

    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        [mailComposer setSubject:subjectString];
        [mailComposer setMessageBody:@"" isHTML:NO];
        [mailComposer setToRecipients:@[AppConfiguration.supportEmail]];
        mailComposer.mailComposeDelegate = self;
        mailComposer.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:mailComposer animated:YES completion:nil];
    }
    else {
        NSString *urlString = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@", AppConfiguration.supportEmail, [subjectString encodeStringForURL], [@"" encodeStringForURL]];
        NSURL *mailToURL = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:mailToURL options:@{} completionHandler:^(BOOL success) {
            if (!success) {
                [DMGUtilities showAlertWithTitle:AppConfiguration.appNameShort
                                         message:@"There are no Mail accounts configured. You can add or create a Mail account in Settings."
                                inViewController:nil];
            }
        }];
    }
}

- (IBAction)signUpBtnAction:(id)sender {    
    InAppPurchaseViewController *vc = [[InAppPurchaseViewController alloc] initWithNibName:@"InAppPurchaseViewController" bundle:nil];
    vc.hidesBottomBarWhenPushed = YES;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark MFMailComposeDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    
    NSString *title = nil;
    NSString *message = nil;
    switch (result) {
        case MFMailComposeResultCancelled:
            title = @"Cancelled";
            message = @"Email was cancelled.";
            break;
        case MFMailComposeResultSaved:
            title = @"Saved";
            message = @"Email was saved as a draft.";
            break;
        case MFMailComposeResultSent:
            title = @"Success!";
            message = @"Email was sent successfully.";
            break;
        case MFMailComposeResultFailed:
            title = @"Error";
            message = @"Email was not sent.";
            break;
        default:
            title = @"Error";
            message = @"Email was not sent.";
            break;
    }

    [DMGUtilities showAlertWithTitle:title message:message inViewController:nil];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TOS PRIVACY POLICY ACTIONS

- (IBAction)privacyPolicy:(id)sender {
    LearnMoreViewController *learnMoreViewController = [[LearnMoreViewController alloc] init];
    learnMoreViewController.learnMoreTitle = @"privacypolicy";
    learnMoreViewController.hidesBottomBarWhenPushed = YES;
    learnMoreViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:learnMoreViewController animated:YES completion:nil];
}

- (IBAction)termsOfService:(id)sender {
    LearnMoreViewController *learnMoreViewController = [[LearnMoreViewController alloc] init];
    learnMoreViewController.learnMoreTitle = @"termsofservice";
    learnMoreViewController.hidesBottomBarWhenPushed = YES;
    learnMoreViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:learnMoreViewController animated:YES completion:nil];
}

@end
