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

@property (nonatomic, retain) NSMutableArray *foodsNameList;
@property (nonatomic, retain) NSMutableArray *foodsIDList;
@property (nonatomic, retain) AppDelegate *mainDelegate;

@end
