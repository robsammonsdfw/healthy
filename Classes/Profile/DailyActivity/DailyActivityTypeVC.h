
#import <UIKit/UIKit.h>

@interface DailyActivityTypeVC : UIViewController
- (IBAction)btnPreviousClicked:(id)sender;
- (IBAction)btnNextClicked:(id)sender;

- (IBAction)btnJobType:(id)sender;
@property (retain, nonatomic) NSMutableDictionary *userInfoDict;
@end
