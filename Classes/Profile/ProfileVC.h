
#import <UIKit/UIKit.h>

@interface ProfileVC : UIViewController
@property (retain, nonatomic) IBOutlet UITextField *txtBirthDate;
@property (retain, nonatomic) IBOutlet UITextField *txtWeight;
@property (retain, nonatomic) IBOutlet UITextField *txtHeight;
@property (retain, nonatomic) IBOutlet UIButton *btnLactating;
- (IBAction)btnNextClicked:(id)sender;
- (IBAction)btnPreviousClicked:(id)sender;
- (IBAction)btnFemaleType:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *btnMale;
@property (retain, nonatomic) IBOutlet UIButton *btnFemale;
@property (retain, nonatomic) NSMutableDictionary *userInfoDict;
@end
 
