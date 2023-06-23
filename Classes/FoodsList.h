#import <UIKit/UIKit.h>

@class AppDelegate;

@interface FoodsList : UIViewController {
	NSMutableArray *foodsNameList;
	NSMutableArray *foodsIDList;
	
	NSString *str_foodName;
	NSNumber *int_foodKey;
	
	AppDelegate *mainDelegate;
}

@property (nonatomic, strong) NSMutableArray *foodsNameList;
@property (nonatomic, strong) NSMutableArray *foodsIDList;
@property (nonatomic, strong) AppDelegate *mainDelegate;

@end
