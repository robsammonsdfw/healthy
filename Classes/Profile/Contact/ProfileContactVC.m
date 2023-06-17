

#import "ProfileContactVC.h"
#import "DietMasterGoViewController.h"
#import "LoginViewController.h"
#import "ProfileVC.h"

@interface ProfileContactVC ()<UIAlertViewDelegate,UITextFieldDelegate> {
    CGFloat viewOriginY;
}

@end

@implementation ProfileContactVC

#pragma mark - viewLifeCycle method -
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(dismissKeyboard)];

    [self.view addGestureRecognizer:tap];
    
    [_txtUsername setDelegate:self];
    [_txtPassword setDelegate:self];
    [_txtFirstName setDelegate:self];
    [_txtLastName setDelegate:self];
    [_txtEmail setDelegate:self];
    
    if (_userInfoDict == nil) {
        _userInfoDict = [[NSMutableDictionary alloc] init];
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    self.navigationItem.hidesBackButton = YES;
    self.txtUsername.layer.borderWidth=2.0;
    self.txtUsername.layer.borderColor= [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0].CGColor;
    self.txtUsername.layer.cornerRadius=4;
    self.txtUsername.clipsToBounds=YES;
    
    self.txtPassword.layer.borderWidth=2.0;
    self.txtPassword.layer.borderColor=[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0].CGColor;
    self.txtPassword.layer.cornerRadius=4;
    self.txtPassword.clipsToBounds=YES;
    
    self.txtFirstName.layer.borderWidth=2.0;
    self.txtFirstName.layer.borderColor=[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0].CGColor;
    self.txtFirstName.layer.cornerRadius=4;
    self.txtFirstName.clipsToBounds=YES;
    
    self.txtLastName.layer.borderWidth=2.0;
    self.txtLastName.layer.borderColor=[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0].CGColor;
    self.txtLastName.layer.cornerRadius=4;
    self.txtLastName.clipsToBounds=YES;
    
    self.txtEmail.layer.borderWidth=2.0;
    self.txtEmail.layer.borderColor=[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0].CGColor;
    self.txtEmail.layer.cornerRadius=4;
    self.txtEmail.clipsToBounds=YES;
    
    self.title=@"Create Profile";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationItem.hidesBackButton = YES;
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Button Actio nmethod -
- (IBAction)btnNextClicked:(id)sender {
    if ([self validation])
    {
        ProfileVC *desVc= [[ProfileVC alloc] initWithNibName:@"ProfileVC" bundle:nil];
        desVc.userInfoDict = _userInfoDict;
        [self.navigationController pushViewController:desVc animated:YES];
    }
}

-(BOOL)validation {
    if(self.txtUsername.text.length > 3 && self.txtUsername.text.length < 50)
    {
        [_userInfoDict setValue:self.txtUsername.text forKey:@"Username"];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please enter a username between 4 and 50 characters." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    
    //password 4-25chars
    if(self.txtPassword.text.length > 3 && self.txtPassword.text.length < 25)
    {
        [_userInfoDict setObject:self.txtPassword.text forKey:@"Password"];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please enter a password between 4 and 25 characters." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    
    //max 50 for both
    if(self.txtFirstName.text.length > 0 && self.txtLastName.text.length > 0 && self.txtLastName.text.length < 50 && self.txtFirstName.text.length < 50)
    {
        [_userInfoDict setObject:self.txtFirstName.text forKey:@"FirstName"];
        [_userInfoDict setObject:self.txtLastName.text forKey:@"LastName"];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please enter first and last name (max 50 characters)." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    
    //max 100
    if(self.txtEmail.text.length > 0 && self.txtEmail.text.length < 100)
    {
        [_userInfoDict setObject:self.txtEmail.text forKey:@"Email"];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please enter your email (max 100 characters)." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    
    return  YES;
}

-(void)doneClicked:(id)sender
{
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect theFrame = textField.frame;
    float y = theFrame.origin.y - 15;
    y -= (y/1.7);
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        if (viewOriginY == 0.0f) {
            viewOriginY = f.origin.y;
        }
        f.origin.y = -y;
        self.view.frame = f;
    }];
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = viewOriginY;
        self.view.frame = f;
    }];
    [textField resignFirstResponder];
}

#pragma mark - keyboard movements
//- (void)keyboardWillShow:(NSNotification *)notification
//{
//    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//
//    [UIView animateWithDuration:0.3 animations:^{
//        CGRect f = self.view.frame;
//        if (viewOriginY == 0.0f) {
//            viewOriginY = f.origin.y;
//        }
//        f.origin.y = -(keyboardSize.height - 50);
//        self.view.frame = f;
//    }];
//}
//
//-(void)keyboardWillHide:(NSNotification *)notification
//{
//    [UIView animateWithDuration:0.3 animations:^{
//        CGRect f = self.view.frame;
//        f.origin.y = viewOriginY;
//        self.view.frame = f;
//    }];
//}


#pragma mark - MailComposer Delegate Method -
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    
    [self dismissViewControllerAnimated:YES completion:^{
        UIAlertView *alert;
        //alert.delegate=self;
        switch (result)
        {
            case MFMailComposeResultCancelled:
                //message.text = @"Result: canceled";
                alert = [[UIAlertView alloc] initWithTitle:@"Cancelled" message:@"Email was cancelled." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                break;
            case MFMailComposeResultSaved:
                //message.text = @"Result: saved";
                alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Email was saved as a draft." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                break;
            case MFMailComposeResultSent:
                //message.text = @"Result: sent";
                alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Email was sent successfully." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                break;
            case MFMailComposeResultFailed:
                //message.text = @"Result: failed";
                alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Email was not sent." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                break;
            default:
                //message.text = @"Result: not sent";
                alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Email was not sent." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                break;
        }
        [alert show];
        
        [[NSUserDefaults standardUserDefaults]setObject:@"False" forKey:@"Reserved"];
        if(AppDel.loginViewController){
            [AppDel.loginViewController syncUserInfo:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            AppDel.loginViewController = [[LoginViewController alloc] init];
            [AppDel.loginViewController syncUserInfo:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}
@end

