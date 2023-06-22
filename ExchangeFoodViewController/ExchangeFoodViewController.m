#import "ExchangeFoodViewController.h"
#import "DietMasterGoAppDelegate.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "DietmasterEngine.h"
#import "GetDataWebService.h"

@interface ExchangeFoodViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, WSDeleteUserPlannedMealItems, WSInsertUserPlannedMealItems, GetDataWSDelegate>

@property (nonatomic, strong) NSDictionary *deleteDict;
@property (nonatomic, strong) NSDictionary *insertDict;
@property (nonatomic, strong) NSMutableArray *foodResults;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *mySearchBar;
@property (nonatomic) BOOL bSearchIsOn;

-(void) searchBar:(id) object;
-(void)loadSearchData:(NSString *)searchTerm;
-(void)confirmExchangeItem;
-(void)exchangeFood;
-(void)deleteFood:(NSDictionary *)dict;
-(void)insertFood:(NSDictionary *)dict;
-(void)loadData;

@end

@implementation ExchangeFoodViewController

@synthesize CaloriesToMaintain, ExchangeOldDataDict;

-(id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle {
    return [self init];
}

-(id)init {
    self = [super initWithNibName:@"ExchangeFoodViewController" bundle:nil];
    return self;
}

#pragma mark SEARCH BAR METHODS
- (void)searchBar: (id) object {
    if (_bSearchIsOn) {
        _bSearchIsOn = NO;
    }
    else {
        _bSearchIsOn = YES;
    }
    
    if (_bSearchIsOn) {
        self.tableView.tableHeaderView = _mySearchBar;
        [_mySearchBar becomeFirstResponder];
    }
    else {
        [UIView beginAnimations:@"foo" context:NULL];
        [UIView setAnimationDuration:0.5f];
        [self.tableView setContentOffset:CGPointMake(0,44)];
        [UIView commitAnimations];
        [_mySearchBar resignFirstResponder];
    }
    [self.tableView scrollRectToVisible:[[self.tableView tableHeaderView] bounds] animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    _bSearchIsOn = YES;
    self.tableView.scrollEnabled = NO;
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar*) theSearchBar  {
    self.tableView.scrollEnabled = YES;
    [_mySearchBar resignFirstResponder ];
    [self loadSearchData];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if (isExchangeFood == YES) {
        isExchangeFood = NO;
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
    else {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
    
    _bSearchIsOn = YES;
    [self.tableView reloadData];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    [self.tableView reloadData];
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    self.tableView.scrollEnabled = YES;
    self.tableView.userInteractionEnabled = YES;
    
    [UIView beginAnimations:@"foo" context:NULL];
    [UIView setAnimationDuration:0.25f];
    [self.tableView setContentOffset:CGPointMake(0,44)];
    [UIView commitAnimations];
    
    _bSearchIsOn = NO;
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    searchBar.text = @"";
    
    [_foodResults removeAllObjects];
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    if([searchText length] > 0) {
        _bSearchIsOn = YES;
        self.tableView.scrollEnabled = NO;
    }
    else {
        _bSearchIsOn = NO;
        self.tableView.scrollEnabled = YES;
    }
    
    [self.tableView reloadData];
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

#pragma mark VIEW LIFECYCLE
- (void)viewDidLoad {
    UIBarButtonItem* bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemSearch target:self action:@selector(searchBar:)];
    bi.style = UIBarButtonItemStylePlain;
    self.navigationItem.rightBarButtonItem = bi;
    
    _mySearchBar = [[UISearchBar alloc] init];
    _mySearchBar.placeholder = @"Search";
    _mySearchBar.delegate = self;
    [_mySearchBar sizeToFit];
    self.bSearchIsOn = NO;
    _mySearchBar.showsCancelButton = YES;
    [_mySearchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_mySearchBar sizeToFit];
    
    self.tableView.tableHeaderView = _mySearchBar;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        
    if (!_foodResults) {
        _foodResults = [[NSMutableArray alloc] init];
    }
    
    indexToExchange = -1;
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self performSelector:@selector(loadData) withObject:nil afterDelay:0.25];
    
    if ([_mySearchBar.text length] == 0) {
        [_mySearchBar becomeFirstResponder];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_bSearchIsOn) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        [self.tableView setContentOffset:CGPointMake(0,0)];
    }
    else {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        [self.tableView setContentOffset:CGPointMake(0,44)];
    }
}

#pragma mark DATA METHODS
- (void)loadSearchData {
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"Name CONTAINS[cd] %@", self.mySearchBar.text];
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"Name"
                                                                 ascending:YES];
    NSArray *results = [[_foodResults filteredArrayUsingPredicate:predicate]
                        sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    
    [_foodResults removeAllObjects];
    if (results.count > 0) {
        [_foodResults addObjectsFromArray:results];
    }
    [self.tableView reloadData];
}

#pragma mark EXCHANGE METHODS

- (void)confirmExchangeItem {
    NSString *message = @"Are you sure you wish to exchange with this food?";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirm Exchange"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self exchangeFood];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"No"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)exchangeFood_Original {
    isExchangeFood = YES;
    [DMActivityIndicator showActivityIndicator];

    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    NSMutableDictionary *exchangeDict = dietmasterEngine.mealPlanItemToExchangeDict;
    
    double totalCaloriesToExchange = 0;
    
    double numberOfExchangedCalories = [[exchangeDict valueForKey:@"Calories"] doubleValue];
    double exchangeGramWeight = [[exchangeDict valueForKey:@"GramWeight"] doubleValue] / 100;
    double exchangeServingSize = [[exchangeDict valueForKey:@"ServingSize"] doubleValue];
    double exchangeServings = [[exchangeDict valueForKey:@"Servings"] doubleValue];
    
    totalCaloriesToExchange = exchangeServings * ((numberOfExchangedCalories * exchangeGramWeight) / exchangeServingSize);
    
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[_foodResults objectAtIndex:indexToExchange]];
    
    NSNumber *measureID = [dietmasterEngine getMeasureIDForFood:@([[dict valueForKey:@"FoodKey"] intValue])];
    
    NSDictionary *tempFoodDict = [[NSDictionary alloc] initWithObjectsAndKeys:[dict valueForKey:@"FoodKey"], @"FoodID", measureID, @"MeasureID", nil];
    NSDictionary *newDict = [[NSDictionary alloc] initWithDictionary:[dietmasterEngine getFoodDetails:tempFoodDict]];
    
    double totalCalories = 0;
    double numberOfCalories = [[dict valueForKey:@"Calories"] doubleValue];
    double gramWeight = [[dict valueForKey:@"GramWeight"] doubleValue] / 100;
    double servingSize = [[dict valueForKey:@"ServingSize"] doubleValue];
    double servings = 0;
    
    servings = totalCaloriesToExchange / ((numberOfCalories * gramWeight) / servingSize);
    servings = round(servings);
    totalCalories = servings * ((numberOfCalories * gramWeight) / servingSize);
    
    NSDictionary *deleteDictTemp = [[NSDictionary alloc] initWithObjectsAndKeys: [NSNumber numberWithInt:dietmasterEngine.selectedMealPlanID], @"MealID", dietmasterEngine.selectedMealID, @"MealCode", [dietmasterEngine.mealPlanItemToExchangeDict valueForKey:@"FoodID"], @"FoodID", nil];
    _deleteDict = nil;
    
    if (!_deleteDict) {
        _deleteDict = [[NSDictionary alloc] initWithDictionary:deleteDictTemp];
    }
    
    NSDictionary *insertDictTemp = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [NSNumber numberWithInt:dietmasterEngine.selectedMealPlanID], @"MealID",
                                    dietmasterEngine.selectedMealID, @"MealCode",
                                    [dict valueForKey:@"FoodKey"], @"FoodID",
                                    measureID, @"MeasureID",
                                    [NSNumber numberWithDouble:servingSize], @"ServingSize",
                                    nil];
    
    _insertDict = nil;
    if (!_insertDict) {
        _insertDict = [[NSDictionary alloc] initWithDictionary:insertDictTemp];
    }
    
    [self insertFood:_insertDict];
}

-(void)exchangeFood_MyNew {
    
    isExchangeFood = YES;
    [DMActivityIndicator showActivityIndicator];

    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    NSMutableDictionary *exchangeDict = dietmasterEngine.mealPlanItemToExchangeDict;
    
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[_foodResults objectAtIndex:indexToExchange]];
    double newCalories = [[dict valueForKey:@"Calories"] doubleValue];
    double servings = CaloriesToMaintain/(newCalories/[[exchangeDict valueForKey:@"GramWeight"] doubleValue]);
    
    servings = [[NSString stringWithFormat:@"%.1f", servings] doubleValue];
    
    NSNumber *measureID = [dietmasterEngine getMeasureIDForFood:@([[dict valueForKey:@"FoodKey"] intValue])];
    
    NSDictionary *deleteDictTemp = [[NSDictionary alloc] initWithObjectsAndKeys: [NSNumber numberWithInt:dietmasterEngine.selectedMealPlanID], @"MealID", dietmasterEngine.selectedMealID, @"MealCode", [dietmasterEngine.mealPlanItemToExchangeDict valueForKey:@"FoodID"], @"FoodID", nil];
    _deleteDict = nil;
    
    if (!_deleteDict) {
        _deleteDict = [[NSDictionary alloc] initWithDictionary:deleteDictTemp];
    }
    
    NSDictionary *insertDictTemp = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [NSNumber numberWithInt:dietmasterEngine.selectedMealPlanID], @"MealID",
                                    dietmasterEngine.selectedMealID, @"MealCode",
                                    [dict valueForKey:@"FoodKey"], @"FoodID",
                                    measureID, @"MeasureID",
                                    [NSNumber numberWithDouble:servings], @"ServingSize",
                                    nil];
    
    _insertDict = nil;
    if (!_insertDict) {
        _insertDict = [[NSDictionary alloc] initWithDictionary:insertDictTemp];
    }
    
    [self insertFood:_insertDict];
}

-(void)exchangeFood {
    isExchangeFood = YES;
    [DMActivityIndicator showActivityIndicator];

    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    NSMutableDictionary *exchangeDict = dietmasterEngine.mealPlanItemToExchangeDict;
    
    double numberOfExchangedCalories = [[exchangeDict valueForKey:@"Calories"] doubleValue];
    double exchangeGramWeight = [[exchangeDict valueForKey:@"GramWeight"] doubleValue] / 100;
    double exchangeServingSize = [[exchangeDict valueForKey:@"ServingSize"] doubleValue];
    double exchangeServings = [[exchangeDict valueForKey:@"Servings"] doubleValue];
    
    double totalCaloriesToExchange = exchangeServings * ((numberOfExchangedCalories * exchangeGramWeight) / exchangeServingSize);
    
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[_foodResults objectAtIndex:indexToExchange]];
    NSNumber *measureID = [dietmasterEngine getMeasureIDForFood:@([[dict valueForKey:@"FoodKey"] intValue])];
    
    double totalCalories = 0;
    double numberOfCalories = [[dict valueForKey:@"Calories"] doubleValue];
    double gramWeight = [[dietmasterEngine getGramWeightForFoodID:@([[dict valueForKey:@"FoodKey"] intValue]) andMeasureID:measureID] doubleValue];
    
    //change by HHT on 23-08-2016
    //if gramWeight = 0 exchage food error occuered
    
    if (gramWeight == 0){
        gramWeight = 100;
    }
    
    double servingSize = [[dict valueForKey:@"ServingSize"] doubleValue];
    double servings = 0;
    
    servings = totalCaloriesToExchange / ((numberOfCalories * gramWeight) / servingSize);
    totalCalories = servings * ((numberOfCalories * gramWeight) / servingSize);
    
    
    double dblNewFoodCaloriesPerServing = numberOfCalories / servingSize;
    double dblNewFoodNumberOfServings = ((totalCalories) * 100) / (dblNewFoodCaloriesPerServing * gramWeight);
    
    float totalServingAmount = dblNewFoodNumberOfServings;
    double fraction = 0;
    fraction = (totalServingAmount - (int) totalServingAmount);
    
    if (0 < fraction && fraction < 0.25) {
        totalServingAmount = (int) totalServingAmount;
    }
    else if (0.25 < fraction && fraction < 0.75) {
        totalServingAmount = (int) totalServingAmount + 0.5;
    }
    else if (fraction > 0.75) {
        totalServingAmount = (int) totalServingAmount + 1;
    }
    if (totalServingAmount == 0) {
        totalServingAmount = 0.5;
    }
    
    
    NSDictionary *deleteDictTemp = [[NSDictionary alloc] initWithObjectsAndKeys: [NSNumber numberWithInt:dietmasterEngine.selectedMealPlanID], @"MealID", dietmasterEngine.selectedMealID, @"MealCode", [dietmasterEngine.mealPlanItemToExchangeDict valueForKey:@"FoodID"], @"FoodID", nil];
    _deleteDict = nil;
    if (!_deleteDict) {
        _deleteDict = [[NSDictionary alloc] initWithDictionary:deleteDictTemp];
    }
    
    if (isnan(totalServingAmount))
    {
        NSDictionary *insertDictTemp = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        [NSNumber numberWithInt:dietmasterEngine.selectedMealPlanID], @"MealID",
                                        dietmasterEngine.selectedMealID, @"MealCode",
                                        [dict valueForKey:@"FoodKey"], @"FoodID",
                                        measureID, @"MeasureID",
                                        [NSNumber numberWithDouble:0.5], @"ServingSize",
                                        nil];
        _insertDict = nil;
        if (!_insertDict) {
            _insertDict = [[NSDictionary alloc] initWithDictionary:insertDictTemp];
        }
        
        [self insertFood:_insertDict];
    }
    else
    {
        NSDictionary *insertDictTemp = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        [NSNumber numberWithInt:dietmasterEngine.selectedMealPlanID], @"MealID",
                                        dietmasterEngine.selectedMealID, @"MealCode",
                                        [dict valueForKey:@"FoodKey"], @"FoodID",
                                        measureID, @"MeasureID",
                                        [NSNumber numberWithDouble:totalServingAmount], @"ServingSize",
                                        nil];
        _insertDict = nil;
        if (!_insertDict) {
            _insertDict = [[NSDictionary alloc] initWithDictionary:insertDictTemp];
        }
        
        [self insertFood:_insertDict];
    }
}

- (void)deleteFood:(NSDictionary *)dict {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"DeleteUserPlannedMealItems", @"RequestType",
                              [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                              [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                              dict, @"MealItems",
                              nil];
    
    MealPlanWebService *soapWebService = [[MealPlanWebService alloc] init];
    soapWebService.wsDeleteUserPlannedMealItems = self;
    [soapWebService callWebservice:infoDict];
}

- (void)insertFood:(NSDictionary *)dict {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *wsInfoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"InsertUserPlannedMealItems", @"RequestType",
                                [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                                [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                                dict, @"MealItems",
                                nil];
    
    MealPlanWebService *soapWebService2 = [[MealPlanWebService alloc] init];
    soapWebService2.wsInsertUserPlannedMealItems = self;
    [soapWebService2 callWebservice:wsInfoDict];
}

#pragma mark TABLE VIEW METHODS
- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return Nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_foodResults count] == 0) {
        return 46;
    }
    
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[_foodResults objectAtIndex:indexPath.row]];
    NSString *text = [dict valueForKey:@"Name"];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
//    CGSize labelSize = [text sizeWithFont:[UIFont systemFontOfSize:14.0]  constrainedToSize:constraintSize  lineBreakMode:NSLineBreakByWordWrapping];
    
    CGRect textRect = [text boundingRectWithSize:constraintSize
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]}
                                     context:nil];

    CGSize labelSize = textRect.size;
    
    if (labelSize.height < 46) {
        return 48;
    } else {
        return labelSize.height + 6;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([_foodResults count] == 0) {
        return 1;
    } else {
        return [_foodResults count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)myTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [myTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if ([_foodResults count] == 0) {
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [cell textLabel].adjustsFontSizeToFitWidth = YES;
        cell.textLabel.textColor = [UIColor lightGrayColor];
        [[cell textLabel] setText:@"No results found..."];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.selectionStyle =  UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.userInteractionEnabled = NO;
        cell.accessoryView = nil;
    }
    
    if ([_foodResults count] > 0) {
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        if (_bSearchIsOn) {
            cell.userInteractionEnabled = YES;
        }
        else {
            cell.userInteractionEnabled = YES;
        }
        
        NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[_foodResults objectAtIndex:indexPath.row]];
        cell.textLabel.text			= [dict valueForKey:@"Name"];
        cell.textLabel.textColor = [UIColor blackColor];
                
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle =  UITableViewCellSelectionStyleGray;
        [cell textLabel].adjustsFontSizeToFitWidth = NO;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)myTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [myTableView deselectRowAtIndexPath:indexPath animated:NO];
    indexToExchange= (int)[indexPath row];
    [self checkFoodAvailability:[[_foodResults objectAtIndex:indexPath.row] valueForKey:@"FoodKey"]];
    [self confirmExchangeItem];
}

- (void)checkFoodAvailability:(NSString *)strFoodKey {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    [db open];
    NSString *query = @"SELECT FoodKey FROM Food";
    FMResultSet *rs = [db executeQuery:query];
    NSMutableArray *arrFoodKeys = [[NSMutableArray alloc] init];
    while ([rs next]) {
        [arrFoodKeys addObject:[NSString stringWithFormat:@"%d", [rs intForColumn:@"FoodKey"]]];
    }
    
    [rs close];
    if (![arrFoodKeys containsObject:strFoodKey]) {
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        [dietmasterEngine retrieveMissingFood:[strFoodKey intValue]];
    }
}

#pragma mark MEAL PLAN ITEMS DELEGATE - This Delegate method is for Delete only.
- (void)deleteUserPlannedMealItemsFinished:(NSMutableArray *)responseArray {
    
    [DMActivityIndicator hideActivityIndicator];

    _deleteDict = nil;
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    dietmasterEngine.didInsertNewFood = YES;
    [DMActivityIndicator showCompletedIndicator];
    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:2] animated:YES];
}

- (void)deleteUserPlannedMealItemsFailed:(NSString *)failedMessage {
    [DMActivityIndicator hideActivityIndicator];
    _deleteDict = nil;
}

- (void)insertUserPlannedMealItemsFinished:(NSMutableArray *)responseArray {
    _insertDict = nil;
    
    if ([[[responseArray objectAtIndex:0] valueForKey:@"Status"] isEqualToString:@"Error"]) {
        [DMActivityIndicator hideActivityIndicator];

        [DMGUtilities showAlertWithTitle:@"Error" message:@"An error occurred. Please try again.." inViewController:nil];
    }
    else {
        [self deleteFood:_deleteDict];
    }
}

- (void)insertUserPlannedMealItemsFailed:(NSString *)failedMessage {
    [DMActivityIndicator hideActivityIndicator];
    _insertDict = nil;
    
    [DMGUtilities showAlertWithTitle:@"Error" message:@"An error occurred. Please try again.." inViewController:nil];

}

#pragma mark Webservice
- (void)loadData {
    
    [DMActivityIndicator showActivityIndicator];

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"GetExchangeItemsForFood", @"RequestType",
                              @{@"UserID" : [prefs valueForKey:@"userid_dietmastergo"],
                                @"AuthKey" : [prefs valueForKey:@"authkey_dietmastergo"],
                                @"FoodID" : [dietmasterEngine.mealPlanItemToExchangeDict valueForKey:@"FoodID"],
                                @"MealTypeID" : [dietmasterEngine.mealPlanItemToExchangeDict valueForKey:@"MealTypeID"],
                                }, @"parameters",
                              nil];
    
    GetDataWebService *webService = [[GetDataWebService alloc] init];
    webService.getDataWSDelegate = self;
    [webService callWebservice:infoDict];
    
}

- (void)getDataFailed:(NSString *)failedMessage {
    [DMActivityIndicator hideActivityIndicator];

    [DMGUtilities showAlertWithTitle:@"Error" message:@"An error occurred. Please try again.." inViewController:nil];
}

- (void)getDataFinished:(NSDictionary *)responseDict {
    [DMActivityIndicator hideActivityIndicator];

    [_foodResults removeAllObjects];
    [_foodResults addObjectsFromArray:responseDict[@"Foods"]];
    [self.tableView reloadData];
}
@end
