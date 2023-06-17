#import <UIKit/UIKit.h>
#import <sqlite3.h>

@class AppDelegate;

@interface FoodsList : UIViewController {
	NSMutableArray *foodsNameList;
	NSMutableArray *foodsIDList;
	
	NSString *str_foodName;
	NSNumber *int_foodKey;
	
	AppDelegate *mainDelegate;
	
	sqlite3 *database;
	NSString *dbPath;
}

@property (nonatomic, strong) NSMutableArray *foodsNameList;
@property (nonatomic, strong) NSMutableArray *foodsIDList;
@property (nonatomic, strong) AppDelegate *mainDelegate;

@end
