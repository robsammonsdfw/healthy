//
//  LoginViewController.m
//  DietMasterGo
//
//  Created by Henry Kirk on 2/14/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import "LoginViewController.h"
#import "SoapWebServiceEngine.h"
#import "LearnMoreViewController.h"
#import "DietMasterGoViewController.h"
#import "DietMasterGoController_Old.h"
#import "InAppPurchaseViewController.h"
#import "MyMovesViewController.h"
#import "ProfileAlertVCViewController.h"


@implementation LoginViewController

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

@synthesize appNameLabel;
@synthesize userLoginWS;

-(id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle {
    return [self init];
}

-(id)init {
    self = [super initWithNibName:@"LoginViewController" bundle:nil];
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle -
- (void)viewDidLoad {
    
    /*==========================================To Enable & Disable Old design==========================================*/
        [[NSUserDefaults standardUserDefaults]setObject:@"NewDesign" forKey:@"changeDesign"]; /// To Enable NEW DESIGN
    //    [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"changeDesign"];          /// To Enable OLD DESIGN
    /*================================================================================================================*/

    
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"changeDesign"]  isEqual: @"NewDesign"])
    {
//        appNameLabel.hidden = true;
//        _imgtop.hidden = true;
        _backgroundImgVw.image = [UIImage imageNamed:@"login-background.png"];
    }
    else
    {
        appNameLabel.hidden = false;
        _imgtop.hidden = false;
    }
    
    self.loginButton.backgroundColor=PrimaryColor
    _loginButton.layer.cornerRadius=5;
    
    self.emailbtuuon.backgroundColor=PrimaryColor
    _emailbtuuon.layer.cornerRadius=5;
    
    
    self.signUpBtn.backgroundColor=PrimaryColor
    self.signUpBtn.layer.cornerRadius=5;

    
    self.imgtop.backgroundColor=PrimaryColor
    
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:PLIST_NAME];
    NSDictionary *appDefaults = [[[NSDictionary alloc] initWithContentsOfFile:finalPath] autorelease];
    
    appNameLabel.text = [appDefaults valueForKey:@"app_name_long"];
    
    UIImageView *backgroundImage = (UIImageView *)[self.view viewWithTag:501];
    if ([[appDefaults valueForKey:@"account_code"] isEqualToString:@"ezdietplanner"]) {
        backgroundImage.image = [UIImage imageNamed:@"Login_Screen"];
//        for (id view in self.view.subviews) {
//            if ([view isKindOfClass:[UILabel class]]) {
//                UILabel *label = (UILabel *)view;
//                label.textColor = [UIColor blackColor];
//            }
//        }
        [_loginButton setBackgroundImage:[UIImage imageNamed:@"button_small"] forState:UIControlStateNormal];
        [_loginButton setBackgroundImage:[UIImage imageNamed:@"button_small"] forState:UIControlStateHighlighted];
        [_loginButton setBackgroundImage:[UIImage imageNamed:@"button_small"] forState:UIControlStateSelected];
        UIButton *helpButton = (UIButton *)[self.view viewWithTag:601];
        [helpButton setBackgroundImage:[UIImage imageNamed:@"button_small"] forState:UIControlStateNormal];
        [helpButton setBackgroundImage:[UIImage imageNamed:@"button_small"] forState:UIControlStateHighlighted];
        [helpButton setBackgroundImage:[UIImage imageNamed:@"button_small"] forState:UIControlStateSelected];
    }
    
    AppDel.isSessionExp = NO;
}

//- (void)viewDidUnload {
//    [super viewDidUnload];
//    usernameField = nil;
//    cellSpinner = nil;
//    passwordField = nil;
//    appNameLabel = nil;
//    _loginButton = nil;
//}

#pragma mark TEXTFIELD DELEGATE
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    
    if ([usernameField isFirstResponder] && [touch view] != usernameField) {
        [usernameField resignFirstResponder];
    }
    
    if ([passwordField isFirstResponder] && [touch view] != passwordField) {
        [passwordField resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

- (BOOL)textFieldShouldReturn:(UITextField*)aTextField {
    [aTextField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGRect textFieldRect =
    [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect =
    [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0) {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0) {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown) {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

#pragma mark LOGIN FROM URL
-(void)loginFromUrl:(NSString *)authcode {
    if (authcode != nil && authcode.length > 0) {
        NSArray *items = [authcode componentsSeparatedByString:@":"];

        if (items.count == 2) {
            passwordField.text = [items objectAtIndex:0];
            usernameField.text = [items objectAtIndex:1];
        }

        [_loginButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}


#pragma mark BUTTON ACTIONS
-(IBAction)sendLoginInfo:(id)sender {
    
    /*==========================================To Enable & Disable Old design==========================================*/
        [[NSUserDefaults standardUserDefaults]setObject:@"MyMoves" forKey:@"switch"]; // To Enable MyMoves
//        [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"switch"]; // To disable MyMoves
    /*================================================================================================================*/

        
    /*==========================================To Enable & Disable Old design==========================================*/
            [[NSUserDefaults standardUserDefaults]setObject:@"NewDesign" forKey:@"changeDesign"]; /// To Enable NEW DESIGN
        //    [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"changeDesign"];          /// To Enable OLD DESIGN
    /*================================================================================================================*/
        
    [usernameField resignFirstResponder];
    [passwordField resignFirstResponder];
    
    [cellSpinner startAnimating];
    
    if ([passwordField.text isEqualToString:@""] || [usernameField.text isEqualToString:@""]) {
        UIAlertView *alert;
        alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Username or Mobile Password field is empty. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        _loginButton.enabled = YES;
        [cellSpinner stopAnimating];
    }
    else {
        _loginButton.enabled = NO;
        
        DietmasterEngine *engine = [DietmasterEngine instance];
        engine.sendAllServerData = true;
        
        NSString *tokenToSend = [NSString stringWithString:passwordField.text];
        [tokenToSend uppercaseString];
        
        [[NSUserDefaults standardUserDefaults] setObject:passwordField.text forKey:@"loginPwd"];
        
        [[NSUserDefaults standardUserDefaults]setObject:@"FirstTime" forKey:@"FirstTime"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        self.userLoginWS = [[UserLoginWebService alloc] init];
        userLoginWS.wsAuthenticateUserDelegate = self;
        [userLoginWS callWebservice:tokenToSend];
        [userLoginWS release];
    }
}

-(IBAction)emailUs:(id)sender {
    [arrVlaue addObject:@""];
    
    if ([MFMailComposeViewController canSendMail]) {
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSString *finalPath = [path stringByAppendingPathComponent:PLIST_NAME];
        NSDictionary *appDefaults = [[[NSDictionary alloc] initWithContentsOfFile:finalPath] autorelease];
        
        MFMailComposeViewController *mailComposer = [[[MFMailComposeViewController alloc] init] autorelease];
        [mailComposer setSubject:[NSString stringWithFormat:@"%@ App Help & Support", [appDefaults valueForKey:@"app_name_short"]]];
        NSString *emailTo = [[[NSString alloc] initWithFormat:@""] autorelease];
        [mailComposer setMessageBody:emailTo isHTML:NO];
        NSArray *toArray = [NSArray arrayWithObjects:Support_Email, nil];
        [mailComposer setToRecipients:toArray];
        mailComposer.mailComposeDelegate = self;
        mailComposer.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:mailComposer animated:YES completion:nil];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:APP_NAME message:@"There are no Mail accounts configured. You can add or create a Mail account in Settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (IBAction)signUpBtnAction:(id)sender {    
    InAppPurchaseViewController *vc = [[InAppPurchaseViewController alloc] initWithNibName:@"InAppPurchaseViewController" bundle:nil];
    vc.hidesBottomBarWhenPushed = YES;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark MFMailComposeViewController
-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    UIAlertView *alert;
    switch (result) {
        case MFMailComposeResultCancelled:
            alert = [[UIAlertView alloc] initWithTitle:@"Cancelled" message:@"Email was cancelled." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            break;
        case MFMailComposeResultSaved:
            alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Email was saved as a draft." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            break;
        case MFMailComposeResultSent:
            alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Email was sent successfully." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            break;
        case MFMailComposeResultFailed:
            alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Email was not sent." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            break;
        default:
            alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Email was not sent." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            break;
    }
    [alert show];
    [alert release];
}

#pragma mark USER SYNC METHODS
-(void)sendDeviceToken {
    NSString *deviceToken = [DietmasterEngine instance].deviceToken;
    if (deviceToken) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  @"SendDeviceToken", @"RequestType",
                                  [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                                  [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                                  deviceToken, @"DeviceToken",
                                  nil];
        SoapWebServiceEngine *soapWebService = [[SoapWebServiceEngine alloc] init];
        [soapWebService callWebservice:infoDict];
        [soapWebService release];
        
        [infoDict release];
    }
}

-(void)syncUserInfo:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"SyncUser", @"RequestType",
                              [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                              [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                              nil];
    
    SoapWebServiceEngine *soapWebService = [[SoapWebServiceEngine alloc] init];
    soapWebService.wsGetUserInfoDelegate = self;
    [soapWebService callWebservice:infoDict];
    [soapWebService release];
    
    [infoDict release];
}

#pragma mark LOGIN AUTH DELEGATE METHODS
- (void)getAuthenticateUserFinished:(NSMutableArray *)responseArray {
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[responseArray objectAtIndex:0]];
    
    //change BY HHT
    NSString *str = [dict objectForKey:@"Message"];
    
    if ([[dict valueForKey:@"Status"] isEqualToString:@"False"] && ![str containsString:@"Service has been terminated"]) {
        UIAlertView *alert;
        alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Incorrect Login. Please check your username and/or mobile password and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
        [cellSpinner stopAnimating];
        _loginButton.enabled = YES;
    }
    //added by HHT
    else if ([[dict valueForKey:@"Status"] isEqualToString:@"False"] && [str containsString:@"Service has been terminated"]){
        NSLog(@"Service has been terminated");
    }
    else {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setValue:[dict valueForKey:@"UserID"] forKey:@"userid_dietmastergo"];
        [prefs setValue:[dict valueForKey:@"Username"] forKey:@"username_dietmastergo"];
        [prefs setValue:[dict valueForKey:@"CompanyID"] forKey:@"companyid_dietmastergo"];
        [prefs setValue:[dict valueForKey:@"Email1"] forKey:@"companyemail1_dietmastergo"];
        [prefs setValue:[dict valueForKey:@"Email2"] forKey:@"companyemail2_dietmastergo"];
        [prefs setValue:[dict valueForKey:@"CompanyName"] forKey:@"companyname_dietmastergo"];
        [prefs setValue:[dict valueForKey:@"MobileGraphic"] forKey:@"splashimage_filename"];
        [prefs setValue:passwordField.text forKey:@"authkey_dietmastergo"];
        [prefs setValue:[dict valueForKey:@"FirstName"] forKey:@"FirstName_dietmastergo"];
        [prefs setValue:[dict valueForKey:@"LastName"] forKey:@"LastName_dietmastergo"];
        
        [prefs synchronize];
        
        if (AppDel.isSessionExp == NO) {
            [self syncUserInfo:nil];
            [self sendDeviceToken];
        }
        else {
            [cellSpinner stopAnimating];
        }
    }
    [dict release];
}

- (void)getAuthenticateUserFailed:(NSString *)failedMessage {
    _loginButton.enabled = YES;
    
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Incorrect Login. Please check your username and/or mobile password and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
    [cellSpinner stopAnimating];
}

#pragma mark USER INFO DELEGATE METHODS
- (void)getUserInfoFinished:(NSMutableArray *)responseArray {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    dietmasterEngine.updateUserInfoDelegate = self;
    [dietmasterEngine updateUserInfo:responseArray];
    
    dietmasterEngine.syncDatabaseDelegate = self;
    
    //HHT new exercise sync
    [dietmasterEngine.arrExerciseSyncNew removeAllObjects];
    [dietmasterEngine syncDatabase];
}

- (void)getUserInfoFailed:(NSString *)failedMessage {
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Incorrect Login. Please check your username and/or mobile password and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
    [cellSpinner stopAnimating];
    _loginButton.enabled = YES;
}

- (void)updateUserInfoFinished:(NSString *)responseMessage {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    dietmasterEngine.updateUserInfoDelegate = nil;
}

- (void)updateUserInfoFailed:(NSString *)failedMessage {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    dietmasterEngine.updateUserInfoDelegate = nil;
    
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"An error occurred processing your request. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
    [cellSpinner stopAnimating];
    _loginButton.enabled = YES;
}

#pragma mark SYNC DELEGATE METHODS
- (void)syncDatabaseFinished:(NSString *)responseMessage {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    dietmasterEngine.syncDatabaseDelegate = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLoginFinished" object:responseMessage];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:nil];
    
    [cellSpinner stopAnimating];
    _loginButton.enabled = YES;
}

- (void)syncDatabaseFailed:(NSString *)failedMessage {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    dietmasterEngine.syncDatabaseDelegate = nil;
    
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"An error occurred processing your request. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    [cellSpinner stopAnimating];
    _loginButton.enabled = YES;
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}

#pragma mark TOS PRIVACY POLICY ACTIONS
-(IBAction)privacyPolicy:(id)sender {
    LearnMoreViewController *learnMoreViewController = [[LearnMoreViewController alloc] init];
    learnMoreViewController.learnMoreTitle = @"privacypolicy";
    learnMoreViewController.hidesBottomBarWhenPushed = YES;
    learnMoreViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:learnMoreViewController animated:YES completion:nil];
    [learnMoreViewController release];
}

-(IBAction)termsOfService:(id)sender {
    LearnMoreViewController *learnMoreViewController = [[LearnMoreViewController alloc] init];
    learnMoreViewController.learnMoreTitle = @"termsofservice";
    learnMoreViewController.hidesBottomBarWhenPushed = YES;
    learnMoreViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:learnMoreViewController animated:YES completion:nil];
    [learnMoreViewController release];
}

- (void)dealloc {
    [_emailbtuuon release];
    [_imgtop release];
    usernameField = nil;
    cellSpinner = nil;
    passwordField = nil;
    appNameLabel = nil;
    _loginButton = nil;
    
    [super dealloc];
}
@end
