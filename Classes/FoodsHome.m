#import "FoodsHome.h"
#import "DietMasterGoAppDelegate.h"
#import "FoodsSearch.h"
#import "FavoriteMealsViewController.h"
#import "ManageFoods.h"

@interface FoodsHome() <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) IBOutlet UITableView *tblFoodsHome;
@property (nonatomic, strong) NSArray *arrySearch;
@property (nonatomic, strong) NSArray *arryOptions;
@property (nonatomic, strong) NSArray *arrayFavoriteMeals;

@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic) DMLogMealCode mealCode;
@property (nonatomic, strong) DMMealPlan *mealPlan;
@end

static NSString *CellIdentifier = @"Cell";

@implementation FoodsHome

- (instancetype)initWithMealTitle:(NSString *)mealTitle
                         mealCode:(DMLogMealCode)mealCode
                         mealPlan:(DMMealPlan *)mealPlan
                     selectedDate:(NSDate *)selectedDate {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.title = mealTitle;
        self.navigationItem.title = mealTitle;
        _mealCode = mealCode;
        _mealPlan = mealPlan;
        _selectedDate = selectedDate ?: [NSDate date];
        
        _arrySearch = [[NSArray alloc] initWithObjects:@"All Foods",nil];
        _arryOptions = [[NSArray alloc] initWithObjects:@"My Foods", @"Favorite Foods", @"Program Foods", @"Scan or Enter New Food",nil];
        _arrayFavoriteMeals = [[NSArray alloc] initWithObjects:@"Favorite Meals",nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
		
	self.tblFoodsHome.estimatedRowHeight = 44;
    [self.tblFoodsHome registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    NSString *accountCode = [DMGUtilities configValueForKey:@"account_code"];
    if ([accountCode isEqualToString:@"ezdietplanner"]) {
        self.tblFoodsHome.backgroundView = nil;
        self.tblFoodsHome.backgroundColor = [UIColor clearColor];
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Select_Meal_TVGray"]];
    }

    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
		return self.arrySearch.count;
    }
    else if (section == 1) {
		return self.arryOptions.count;
	}
    else if (section == 2) {
        return self.arrayFavoriteMeals.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	
    if(indexPath.section == 0) {
		cell.textLabel.text = [self.arrySearch objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 1) {
		cell.textLabel.text = [self.arryOptions objectAtIndex:indexPath.row];
        if (indexPath.row == 3) {
            cell.imageView.image = [UIImage imageNamed:@"195-barcode"];
        }
        else {
            cell.imageView.image = nil;
        }
	}
    else if (indexPath.section == 2) {
		cell.textLabel.text = [self.arrayFavoriteMeals objectAtIndex:indexPath.row];
    }
	
	cell.textLabel.font = [UIFont systemFontOfSize:13.0];
	cell.detailTextLabel.font = [UIFont systemFontOfSize:13.0];
    cell.selectionStyle =  UITableViewCellSelectionStyleGray;

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tblFoodsHome deselectRowAtIndexPath:indexPath animated:NO];
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc]  initWithTitle: @"Back"
                                                                    style: UIBarButtonItemStylePlain
                                                                   target:nil action:nil];
	[self.navigationItem setBackBarButtonItem:backButton];
	
    if (indexPath.section == 2) {
        FavoriteMealsViewController *favoriteMealsViewController = [[FavoriteMealsViewController alloc] initWithMealCode:self.mealCode selectedDate:self.selectedDate];
        [self.navigationController pushViewController:favoriteMealsViewController animated:YES];
    } else {

        FoodsSearch *fsController = [[FoodsSearch alloc] initWithMealCode:self.mealCode
                                                                 mealPlan:self.mealPlan
                                                             mealPlanItem:nil
                                                             selectedDate:self.selectedDate];
        fsController.taskMode = self.taskMode;
        if (indexPath.section == 0) {
            fsController.searchType = DMFoodSearchTypeAllFoods;
            fsController.title = @"All Foods";
        }
        
        if (indexPath.section == 1) {
            if (indexPath.row == 3) {
                ManageFoods *mfController = [[ManageFoods alloc] initWithFood:nil
                                                                     mealCode:self.mealCode
                                                                     mealPlan:self.mealPlan
                                                                 selectedDate:self.selectedDate];
                mfController.taskMode = self.taskMode;
                [self.navigationController pushViewController:mfController animated:YES];
                return;
            }
            else {
                fsController.searchType = (DMFoodSearchType)indexPath.row;
                fsController.title = [self.arryOptions objectAtIndex:indexPath.row];
            }
        }
        [self.navigationController pushViewController:fsController animated:YES];
    }
}

@end
