
#import <UIKit/UIKit.h>

@interface UserMealType : UIViewController 
- (IBAction)btnPreviousClicked:(id)sender;
- (IBAction)btnNextClicked:(id)sender;
- (IBAction)btnMedicalConditionClicked:(id)sender;
@property (retain, nonatomic) IBOutlet UITextField *txtMealType;
@property(nonatomic, retain) NSXMLParser *xmlParser;
@property (nonatomic, retain) LoginViewController *loginViewController;
@property (retain, nonatomic) NSMutableDictionary *userInfoDict;
@end
