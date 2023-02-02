
#import <UIKit/UIKit.h>

@interface UserGoalVC : UIViewController

- (IBAction)btnNextClicked:(id)sender;
- (IBAction)btnPreviousClicked:(id)sender;
- (IBAction)btnGoalWeightClicked:(id)sender;

@property (retain, nonatomic) IBOutlet UITextField *txtGoalWeight;
@property (retain, nonatomic) IBOutlet UITextField *txtGoalRate;
@property (retain, nonatomic) NSMutableDictionary *userInfoDict;
@end
