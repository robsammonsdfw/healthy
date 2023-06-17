
#import <UIKit/UIKit.h>

@interface UserMealType : UIViewController 
- (IBAction)btnPreviousClicked:(id)sender;
- (IBAction)btnNextClicked:(id)sender;
- (IBAction)btnMedicalConditionClicked:(id)sender;
@property (nonatomic, strong) IBOutlet UITextField *txtMealType;
@property (nonatomic, strong) NSXMLParser *xmlParser;
@property (nonatomic, strong) LoginViewController *loginViewController;
@property (nonatomic, strong) NSMutableDictionary *userInfoDict;
@end
