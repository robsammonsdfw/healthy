
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface ProfileContactVC : UIViewController<MFMailComposeViewControllerDelegate>
- (IBAction)btnNextClicked:(id)sender;

@property (nonatomic, strong) IBOutlet UITextField *txtUsername;
@property (nonatomic, strong) IBOutlet UITextField *txtPassword;
@property (nonatomic, strong) IBOutlet UITextField *txtFirstName;
@property (nonatomic, strong) IBOutlet UITextField *txtLastName;
@property (nonatomic, strong) IBOutlet UITextField *txtEmail;
@property (nonatomic, strong) NSMutableDictionary *userInfoDict;

@end
