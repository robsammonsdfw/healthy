#import "FoodsHome.h"
#import "DietMasterGoAppDelegate.h"
#import "FoodsSearch.h"
#import "FavoriteMealsViewController.h"
#import "ManageFoods.h"

@interface FoodsHome() <UITableViewDelegate, UITableViewDataSource>
@end

static NSString *CellIdentifier = @"Cell";

@implementation FoodsHome
@synthesize date_currentDate, int_mealID;

- (instancetype)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	arrySearch = [[NSArray alloc] initWithObjects:@"All Foods",nil];
	arryOptions = [[NSArray alloc] initWithObjects:@"My Foods", @"Favorite Foods", @"Program Foods", @"Scan or Enter New Food",nil];
    arrayFavoriteMeals = [[NSArray alloc] initWithObjects:@"Favorite Meals",nil];
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	
	if(self.date_currentDate == NULL) {
        NSDate* sourceDate = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
        [dateFormat setTimeZone:systemTimeZone];
        NSString *date_string = [dateFormat stringFromDate:sourceDate];
        NSDate *destinationDate = [dateFormat dateFromString:date_string];
        
		self.date_currentDate = destinationDate;
	}
	
	tblFoodsHome.estimatedRowHeight = 44;
    [tblFoodsHome registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSString *finalPath = [path stringByAppendingPathComponent:PLIST_NAME];
	NSDictionary *appDefaults = [[NSDictionary alloc] initWithContentsOfFile:finalPath];
    if ([[appDefaults valueForKey:@"account_code"] isEqualToString:@"ezdietplanner"]) {
        tblFoodsHome.backgroundView = nil;
        tblFoodsHome.backgroundColor = [UIColor clearColor];
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Select_Meal_TVGray"]];
    }

    [self.navigationController.navigationBar setTranslucent:NO];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
		return arrySearch.count;
    }
    else if (section == 1) {
		return arryOptions.count;
	}
    else if (section == 2) {
        return arrayFavoriteMeals.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	
    if(indexPath.section == 0) {
		cell.textLabel.text = [arrySearch objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 1) {
		cell.textLabel.text = [arryOptions objectAtIndex:indexPath.row];
        if (indexPath.row == 3) {
            cell.imageView.image = [UIImage imageNamed:@"195-barcode"];
        }
        else {
            cell.imageView.image = nil;
        }
	}
    else if (indexPath.section == 2) {
		cell.textLabel.text = [arrayFavoriteMeals objectAtIndex:indexPath.row];
    }
	
	cell.textLabel.font = [UIFont systemFontOfSize:13.0];
	cell.detailTextLabel.font = [UIFont systemFontOfSize:13.0];
    cell.selectionStyle =  UITableViewCellSelectionStyleGray;

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tblFoodsHome deselectRowAtIndexPath:indexPath animated:NO];
	
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc]  initWithTitle: @"Back"
                                                                    style: UIBarButtonItemStylePlain
                                                                   target:nil action:nil];

	[self.navigationItem setBackBarButtonItem: backButton];
	
    if (indexPath.section == 2) {
        FavoriteMealsViewController *favoriteMealsViewController = [[FavoriteMealsViewController alloc] init];
        [self.navigationController pushViewController:favoriteMealsViewController animated:YES];
    }
    else {
        FoodsSearch *fsController = [[FoodsSearch alloc] init];
        fsController.date_currentDate	= date_currentDate;
        
        if (indexPath.section == 0) {
            fsController.searchType = DMFoodSearchTypeAllFoods;
            fsController.title = @"All Foods";
        }
        
        if (indexPath.section == 1) {
            if (indexPath.row == 3) {
                fsController = nil;
                DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
                dietmasterEngine.taskMode = @"Save";
                
                ManageFoods *mfController = [[ManageFoods alloc] init];
                
                [self.navigationController pushViewController:mfController animated:YES];
                mfController = nil;
                return;
            }
            else {
                fsController.searchType = [arryOptions objectAtIndex:indexPath.row];
                fsController.title = [arryOptions objectAtIndex:indexPath.row];
            }
        }
        [self.navigationController pushViewController:fsController animated:YES];
    }
}

@end
