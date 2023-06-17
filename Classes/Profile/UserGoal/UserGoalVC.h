
#import <UIKit/UIKit.h>

@interface UserGoalVC : UIViewController

- (IBAction)btnNextClicked:(id)sender;
- (IBAction)btnPreviousClicked:(id)sender;
- (IBAction)btnGoalWeightClicked:(id)sender;

@property (nonatomic, strong) IBOutlet UITextField *txtGoalWeight;
@property (nonatomic, strong) IBOutlet UITextField *txtGoalRate;
@property (nonatomic, strong) NSMutableDictionary *userInfoDict;
@end
