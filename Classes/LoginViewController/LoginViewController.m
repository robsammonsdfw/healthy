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
#import "SoapWebServiceEngine.h"

#import "SoapWebServiceEngine.h"
#import "LearnMoreViewController.h"
#import "DietMasterGoViewController.h"
#import "InAppPurchaseViewController.h"
#import "MyMovesViewController.h"
#import "ProfileAlertVCViewController.h"

#import "DietMasterGoPlus-Swift.h"
#import "DMUser.h"
#import "NSString+Encode.h"

@interface LoginViewController() <UITextFieldDelegate, MFMailComposeViewControllerDelegate, SyncDatabaseDelegate>

@property (nonatomic, strong) IBOutlet UITextField *usernameField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;
@property (nonatomic, strong) IBOutlet UILabel *appNameLabel;
@property (nonatomic, strong) IBOutlet UIImageView *imgtop;
@property (nonatomic, strong) IBOutlet UIButton *emailbtuuon;
@property (nonatomic, strong) IBOutlet UIButton *loginButton;
@property (nonatomic, strong) IBOutlet UIButton *signUpBtn;
@property (nonatomic, strong) IBOutlet UIImageView *backgroundImgVw;

@property (nonatomic, assign) CGFloat animatedDistance;

- (IBAction)emailUs:(id)sender;
- (IBAction)termsOfService:(id)sender;
- (IBAction)privacyPolicy:(id)sender;

@end

@implementation LoginViewController

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

- (instancetype)init {
    self = [super initWithNibName:@"LoginViewController" bundle:nil];
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"changeDesign"]  isEqual: @"NewDesign"]) {
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"switch"]  isEqual: @"MyMoves"])
            self.backgroundImgVw.image = [UIImage imageNamed:@"login-background-plus.png"];
        else
            self.backgroundImgVw.image = [UIImage imageNamed:@"login-background.png"];
    } else {
        self.appNameLabel.hidden = false;
        self.imgtop.hidden = false;
    }
    
    self.loginButton.backgroundColor=PrimaryColor
    self.loginButton.layer.cornerRadius=5;
    
    self.emailbtuuon.backgroundColor=PrimaryColor
    self.emailbtuuon.layer.cornerRadius=5;
    
    self.signUpBtn.backgroundColor=PrimaryColor
    self.signUpBtn.layer.cornerRadius=5;
    
    self.imgtop.backgroundColor=PrimaryColor
        
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:PLIST_NAME];
    NSDictionary *appDefaults = [[NSDictionary alloc] initWithContentsOfFile:finalPath];
    
    self.appNameLabel.text = [appDefaults valueForKey:@"app_name_long"];
    
    UIImageView *backgroundImage = (UIImageView *)[self.view viewWithTag:501];
    if ([[appDefaults valueForKey:@"account_code"] isEqualToString:@"ezdietplanner"]) {
        backgroundImage.image = [UIImage imageNamed:@"Login_Screen"];
        [self.loginButton setBackgroundImage:[UIImage imageNamed:@"button_small"] forState:UIControlStateNormal];
        [self.loginButton setBackgroundImage:[UIImage imageNamed:@"button_small"] forState:UIControlStateHighlighted];
        [self.loginButton setBackgroundImage:[UIImage imageNamed:@"button_small"] forState:UIControlStateSelected];
        UIButton *helpButton = (UIButton *)[self.view viewWithTag:601];
        [helpButton setBackgroundImage:[UIImage imageNamed:@"button_small"] forState:UIControlStateNormal];
        [helpButton setBackgroundImage:[UIImage imageNamed:@"button_small"] forState:UIControlStateHighlighted];
        [helpButton setBackgroundImage:[UIImage imageNamed:@"button_small"] forState:UIControlStateSelected];
    }
    
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

    AppDel.isSessionExp = NO;
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

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0) {
        heightFraction = 0.0;
    } else if (heightFraction > 1.0) {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown) {
        self.animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    } else {
        self.animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= self.animatedDistance;
       
    [UIView animateWithDuration:KEYBOARD_ANIMATION_DURATION animations:^{
        [self.view setFrame:viewFrame];
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += self.animatedDistance;
    
    [UIView animateWithDuration:KEYBOARD_ANIMATION_DURATION animations:^{
        [self.view setFrame:viewFrame];
    }];
}

#pragma mark - LOGIN FROM URL

- (void)loginFromUrl:(NSString *)authcode {
    if (authcode.length) {
        NSArray *items = [authcode componentsSeparatedByString:@":"];
        if (items.count == 2) {
            self.passwordField.text = [items objectAtIndex:0];
            self.usernameField.text = [items objectAtIndex:1];
        }

        [self.loginButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
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

        DietmasterEngine *engine = [DietmasterEngine sharedInstance];
        engine.sendAllServerData = true;
        
        NSString *tokenToSend = [[NSString stringWithString:self.passwordField.text] uppercaseString];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:tokenToSend forKey:@"loginPwd"];
        [defaults setObject:@"FirstTime" forKey:@"FirstTime"];
        
        DataFetcher *fetcher = [[DataFetcher alloc] init];
        __weak typeof(self) weakSelf = self;
        [fetcher signInUserWithPassword:tokenToSend
                             completion:^(DMUser *user, NSString *status, NSString *message) {
            [DMActivityIndicator hideActivityIndicator];

            // Incorrect Password.
            if ([status isEqualToString:@"False"] && [message containsString:@"Username or Password is incorrect"]) {
                NSString *alertMessage = @"Incorrect Login. Please check your username and/or mobile password and try again.";
                [DMGUtilities showAlertWithTitle:APP_NAME message:alertMessage inViewController:nil];
                return;
            }
            
            // Terminated Service.
            if ([status isEqualToString:@"False"] && [message containsString:@"Service has been terminated"]) {
                AppDel.isSessionExp = YES;
                // Delete all prefs.
                [defaults removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
                NSString *alertMessage = @"Service has been terminated. Please contact your provider.";
                [DMGUtilities showAlertWithTitle:APP_NAME message:alertMessage okActionBlock:^(BOOL completed) {
                    exit(0);
                } inViewController:nil];
                return;
            }
            
            // Other error.
            if ([status isEqualToString:@"False"]) {
                NSString *alertMessage = message? : @"Unknown Error. Please try again.";
                [DMGUtilities showAlertWithTitle:APP_NAME message:alertMessage inViewController:nil];
                return;
            }
            
            // Success!
            [defaults setObject:user.email1 forKey:@"LoginEmail"];
            [defaults setObject:user.userName forKey:@"username_dietmastergo"];
            [defaults setObject:user.userId forKey:@"userid_dietmastergo"];
            [defaults setObject:user.userName forKey:@"username_dietmastergo"];
            [defaults setObject:user.companyName forKey:@"companyid_dietmastergo"];
            [defaults setObject:user.email1 forKey:@"companyemail1_dietmastergo"];
            [defaults setObject:user.email2 forKey:@"companyemail2_dietmastergo"];
            [defaults setObject:user.companyName forKey:@"companyname_dietmastergo"];
            [defaults setObject:user.mobileGraphicImageName forKey:@"splashimage_filename"];
            [defaults setObject:tokenToSend forKey:@"authkey_dietmastergo"];
            [defaults setObject:user.firstName forKey:@"FirstName_dietmastergo"];
            [defaults setObject:user.lastName forKey:@"LastName_dietmastergo"];
            [defaults setBool:NO forKey:@"logout_dietmastergo"];
            [defaults setBool:YES forKey:@"user_loggedin"];

            DMLog(@"User signed in: %@, Message: %@", user.firstName, message);
            
            // Now get the user's details.
            [weakSelf syncUserInfo:nil];
        }];
    }
}

- (IBAction)emailUs:(id)sender {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:PLIST_NAME];
    NSDictionary *appDefaults = [[NSDictionary alloc] initWithContentsOfFile:finalPath];
    NSString *subjectString = [NSString stringWithFormat:@"%@ App Help & Support", [appDefaults valueForKey:@"app_name_short"]];

    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        [mailComposer setSubject:subjectString];
        [mailComposer setMessageBody:@"" isHTML:NO];
        [mailComposer setToRecipients:@[Support_Email]];
        mailComposer.mailComposeDelegate = self;
        mailComposer.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:mailComposer animated:YES completion:nil];
    }
    else {
        NSString *urlString = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@", Support_Email, [subjectString encodeStringForURL], [@"" encodeStringForURL]];
        NSURL *mailToURL = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:mailToURL options:@{} completionHandler:^(BOOL success) {
            if (!success) {
                [DMGUtilities showAlertWithTitle:APP_NAME message:@"There are no Mail accounts configured. You can add or create a Mail account in Settings." inViewController:nil];
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
}

#pragma mark - USER SYNC METHODS

- (void)syncUserInfo:(id)sender {
    [DMActivityIndicator showActivityIndicatorWithMessage:@"Loading..."];

    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    DataFetcher *fetcher = [[DataFetcher alloc] init];
    [fetcher getUserDetailsWithCompletion:^(DMUser *user, NSError *error) {
        self.loginButton.enabled = YES;
        [DMActivityIndicator hideActivityIndicator];
        if (error) {
            [DMGUtilities showError:error withTitle:@"Error" message:@"Error updating." inViewController:nil];
            return;
        }
        [dietmasterEngine updateUserInfo:user];
    }];
    
#pragma mark TODO: Hook up the exercise sync.
    //HHT new exercise sync
    [dietmasterEngine.arrExerciseSyncNew removeAllObjects];
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"userid_dietmastergo"] != nil) {
       [dietmasterEngine syncDatabase];
   }

}

#pragma mark - SYNC DELEGATE METHODS

- (void)syncDatabaseFinished:(NSString *)responseMessage {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    dietmasterEngine.syncDatabaseDelegate = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLoginFinished" object:responseMessage];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:nil];
    
    [DMActivityIndicator hideActivityIndicator];
    _loginButton.enabled = YES;
}

- (void)syncDatabaseFailed:(NSString *)failedMessage {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    dietmasterEngine.syncDatabaseDelegate = nil;
    
    [DMGUtilities showAlertWithTitle:@"Error" message:@"An error occurred. Please try again.." inViewController:nil];
    
    [DMActivityIndicator hideActivityIndicator];
    _loginButton.enabled = YES;
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
