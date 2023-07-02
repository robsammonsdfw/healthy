#import "ExchangeFoodViewController.h"
#import "DietMasterGoAppDelegate.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "DietmasterEngine.h"
#import "DMDataFetcher.h"
#import "DMMealPlanDataProvider.h"
#import "DMMyLogDataProvider.h"

@interface ExchangeFoodViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *foodResults;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *mySearchBar;
@property (nonatomic) BOOL bSearchIsOn;

/// The food being exchanged.
@property (nonatomic, strong) DMFood *food;
/// The meal plan item that the selected food will replace.
@property (nonatomic, strong) DMMealPlanItem *mealPlanItem;
@property (nonatomic, strong) DMMealPlan *mealPlan;
@end

static NSString *CellIdentifier = @"CellIdentifier";

@implementation ExchangeFoodViewController

- (instancetype)initWithFoodToExchange:(DMFood *)food
                       forMealPlanItem:(DMMealPlanItem *)mealPlanItem
                            inMealPlan:(DMMealPlan *)mealPlan {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _food = food;
        _mealPlanItem = mealPlanItem;
        _mealPlan = mealPlan;
        _foodResults = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.view = [[UIView alloc] init];
    self.title = @"Exchange Food";
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableHeaderView = self.mySearchBar;
    self.tableView.estimatedRowHeight = 46;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    [self.view addSubview:self.tableView];

    self.mySearchBar = [[UISearchBar alloc] init];
    self.mySearchBar.placeholder = @"Search Foods";
    self.mySearchBar.delegate = self;
    self.mySearchBar.showsCancelButton = YES;
    [self.mySearchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.view addSubview:self.mySearchBar];
    
    // Constrain
    [self.mySearchBar.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:0].active = YES;
    [self.mySearchBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:0].active = YES;
    [self.mySearchBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:0].active = YES;

    [self.tableView.topAnchor constraintEqualToAnchor:self.mySearchBar.bottomAnchor constant:0].active = YES;
    [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:0].active = YES;
    [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:0].active = YES;
    [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:0].active = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar setTranslucent:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self loadData];
    [self.mySearchBar becomeFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar  {
    [self.mySearchBar resignFirstResponder];
    [self searchWithText:theSearchBar.text];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    searchBar.text = @"";
    [self.foodResults removeAllObjects];
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    [self searchWithText:searchText];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event  {
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.mySearchBar isFirstResponder] && [touch view] != self.mySearchBar)  {
        [self.mySearchBar resignFirstResponder];
        self.tableView.scrollEnabled = YES;
        self.tableView.userInteractionEnabled = YES;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    [super touchesBegan:touches withEvent:event];
}

#pragma mark EXCHANGE METHODS

- (void)confirmExchangeWithFood:(NSDictionary *)newFoodDict {
    NSString *message = @"Are you sure you wish to exchange with this food?";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirm Exchange"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self exchangeWithNewFood:newFoodDict];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"No"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)exchangeWithNewFood:(NSDictionary *)newFoodDict {
    [DMActivityIndicator showActivityIndicator];

    DMMyLogDataProvider *provider = [[DMMyLogDataProvider alloc] init];
    DMFood *oldFood = [provider getFoodForFoodKey:self.mealPlanItem.foodId];
    
    NSNumber *selectedMealPlanID = self.mealPlan.mealId;
    double newCalories = [self.food.calories doubleValue];
    double caloriesToMaintain = [oldFood.calories doubleValue];
    double gramWeight = [self.food.gramWeight doubleValue];
    
    double servings = caloriesToMaintain / (newCalories / gramWeight);
    servings = [[NSString stringWithFormat:@"%.1f", servings] doubleValue];
    
    NSNumber *measureID = [provider getMeasureIDForFoodKey:self.food.foodKey
                                          fromMealPlanItem:self.mealPlanItem];
    
    NSDictionary *deleteDictTemp = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    selectedMealPlanID, @"MealID",
                                    self.mealPlanItem.mealCode, @"MealCode",
                                    self.mealPlanItem.foodId, @"FoodID",
                                    nil];
    
    NSDictionary *insertDictTemp = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    self.mealPlan.mealId, "MealCode",
                                    self.food.foodKey, @"FoodID",
                                    measureID, @"MeasureID",
                                    @(servings), @"ServingSize",
                                    nil];
    
    [self exchangeFood:deleteDictTemp withFood:insertDictTemp];
}

- (void)deleteFood:(NSDictionary *)dict {
    if (!dict) {
        return;
    }
    DMMealPlanDataProvider *provider = [[DMMealPlanDataProvider alloc] init];
    [provider deleteUserPlannedMealItems:@[dict] withCompletionBlock:^(BOOL completed, NSError *error) {
        [DMActivityIndicator hideActivityIndicator];
        [DMActivityIndicator showCompletedIndicator];
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:2] animated:YES];
    }];
}

- (void)insertFood:(NSDictionary *)dict {
    DMMealPlanDataProvider *provider = [[DMMealPlanDataProvider alloc] init];
    [provider saveUserPlannedMealItems:@[dict] withCompletionBlock:^(BOOL completed, NSError *error) {
        [DMActivityIndicator hideActivityIndicator];
        if (error) {
            [DMGUtilities showAlertWithTitle:@"Error" message:error.localizedDescription inViewController:nil];
            return;
        }
    }];
}

- (void)exchangeFood:(NSDictionary *)food withFood:(NSDictionary *)newFood {
    [DMActivityIndicator showActivityIndicator];
    DMMealPlanDataProvider *provider = [[DMMealPlanDataProvider alloc] init];
    [provider exchangeUserPlannedMealItem:food withItem:newFood withCompletionBlock:^(BOOL completed, NSError *error) {
        [DMActivityIndicator hideActivityIndicator];
        if (error) {
            [DMGUtilities showAlertWithTitle:@"Error" message:error.localizedDescription inViewController:nil];
            return;
        }
        [DMActivityIndicator showCompletedIndicator];
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:2] animated:YES];
    }];
}

#pragma mark - TableView Delegate/Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MAX(self.foodResults.count, 1);
}

- (UITableViewCell *)tableView:(UITableView *)myTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [myTableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if ([self.foodResults count] == 0) {
        cell.textLabel.textColor = [UIColor lightGrayColor];
        [[cell textLabel] setText:@"No results found..."];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.selectionStyle =  UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.userInteractionEnabled = NO;
        cell.accessoryView = nil;
        return cell;
    }

    NSDictionary *dict = [self.foodResults objectAtIndex:indexPath.row];
    cell.textLabel.text = [dict valueForKey:@"Name"];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13.0];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle =  UITableViewCellSelectionStyleGray;
    [cell textLabel].adjustsFontSizeToFitWidth = NO;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;

    return cell;
}

- (void)tableView:(UITableView *)myTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [myTableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *dict = [self.foodResults objectAtIndex:indexPath.row];
    [self confirmExchangeWithFood:dict];
}

#pragma mark - Data Loading

- (void)searchWithText:(NSString *)text {
    [self.foodResults removeAllObjects];
    if (text.length) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"Name CONTAINS[cd] %@", text];
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"Name" ascending:YES];
        NSArray *searchArray = [self.foodResults copy];
        NSArray *results = [[searchArray filteredArrayUsingPredicate:predicate] sortedArrayUsingDescriptors:@[descriptor]];
        [self.foodResults addObjectsFromArray:results];
    }
    [self.tableView reloadData];
}

- (void)loadData {
    [DMActivityIndicator showActivityIndicator];
    
    NSDictionary *params = @{ @"RequestType" : @"GetExchangeItemsForFood",
                                @"FoodID" : [self.mealPlanItem valueForKey:@"FoodKey"],
                                @"MealTypeID" : [self.mealPlanItem valueForKey:@"MealTypeID"] };
    
    [DMDataFetcher fetchDataWithRequestParams:params completion:^(NSObject *object, NSError *error) {
        [DMActivityIndicator hideActivityIndicator];
        if (error) {
            [DMGUtilities showError:error withTitle:@"Error Updating" message:@"An error occurred. Please try again." inViewController:nil];
            return;
        }
        NSDictionary *responseDict = (NSDictionary *)object;
        [self.foodResults removeAllObjects];
        [self.foodResults addObjectsFromArray:responseDict[@"Foods"]];
#warning TODO: Should we look for missing foods here?
        [self.tableView reloadData];
    }];
}

@end
