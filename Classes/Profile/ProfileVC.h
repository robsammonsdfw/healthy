
#import <UIKit/UIKit.h>

@interface ProfileVC : UIViewController
@property (nonatomic, strong) IBOutlet UITextField *txtBirthDate;
@property (nonatomic, strong) IBOutlet UITextField *txtWeight;
@property (nonatomic, strong) IBOutlet UITextField *txtHeight;
@property (nonatomic, strong) IBOutlet UIButton *btnLactating;
- (IBAction)btnNextClicked:(id)sender;
- (IBAction)btnPreviousClicked:(id)sender;
- (IBAction)btnFemaleType:(id)sender;
@property (nonatomic, strong) IBOutlet UIButton *btnMale;
@property (nonatomic, strong) IBOutlet UIButton *btnFemale;
@property (nonatomic, strong) NSMutableDictionary *userInfoDict;
@end
 
