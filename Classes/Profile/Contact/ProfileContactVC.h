
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface ProfileContactVC : UIViewController<MFMailComposeViewControllerDelegate>
- (IBAction)btnNextClicked:(id)sender;

@property (retain, nonatomic) IBOutlet UITextField *txtUsername;
@property (retain, nonatomic) IBOutlet UITextField *txtPassword;
@property (retain, nonatomic) IBOutlet UITextField *txtFirstName;
@property (retain, nonatomic) IBOutlet UITextField *txtLastName;
@property (retain, nonatomic) IBOutlet UITextField *txtEmail;
@property (retain, nonatomic) NSMutableDictionary *userInfoDict;

@end
