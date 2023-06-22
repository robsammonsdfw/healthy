//
//  FoodsSearch.m
//  DietMasterGo
//
//  Created by Andrew Moffitt on 3/1/11.
//  Copyright 2011 AE Studios. All rights reserved.
//

#import "FoodsSearch.h"
#import "DetailViewController.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "DietmasterEngine.h"
#import "ManageFoods.h"
#import "FavoriteMealsViewController.h"
#import "MyLogTableViewCell.h"
#import "TTTAttributedLabel.h"
@import ScrollableSegmentedControl;

static NSString *CellIdentifier = @"MyLogTableViewCell";

@interface FoodsSearch() <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, TTTAttributedLabelDelegate>
/// Search bar for searching foods.
@property (nonatomic, strong) UISearchBar *mySearchBar;
/// Tableview for showing results.
@property (nonatomic, strong) UITableView *tableView;
/// Segmented control for users to choose different categories.
@property (nonatomic, strong) ScrollableSegmentedControl *segmentedControl;
@property (nonatomic, strong) NSMutableArray *foodResults;

@end

@implementation FoodsSearch

@synthesize date_currentDate, int_mealID;

#pragma mark - VIEW LIFECYCLE

- (instancetype)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _searchType = DMFoodSearchTypeAllFoods;
        _foodResults = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    self.view.backgroundColor = [UIColor whiteColor];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.estimatedRowHeight = 46;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    UINib *cellNib = [UINib nibWithNibName:@"MyLogTableViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:CellIdentifier];
    [self.view addSubview:self.tableView];

    self.segmentedControl = [[ScrollableSegmentedControl alloc] init];
    self.segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    self.segmentedControl.underlineSelected = YES;
    self.segmentedControl.segmentStyle = ScrollableSegmentedControlSegmentStyleTextOnly;
    self.segmentedControl.segmentContentColor = [UIColor darkGrayColor];
    self.segmentedControl.selectedSegmentContentColor = [UIColor blackColor];
    self.segmentedControl.backgroundColor = [UIColor whiteColor];
    [self.segmentedControl addTarget:self action:@selector(categorySegmentChanged:) forControlEvents:UIControlEventValueChanged];
    // Set the different segment values.
    [self.segmentedControl insertSegmentWithTitle:@"All Foods" at:0];
    [self.segmentedControl insertSegmentWithTitle:@"My Foods" at:1];
    [self.segmentedControl insertSegmentWithTitle:@"Fav Foods" at:2];
    [self.segmentedControl insertSegmentWithTitle:@"Program" at:3];
    [self.segmentedControl insertSegmentWithTitle:@"Fav Meals" at:4];
    self.segmentedControl.selectedSegmentIndex = (int)DMFoodSearchTypeAllFoods;
    [self.view addSubview:self.segmentedControl];
    
    self.mySearchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.mySearchBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.mySearchBar.placeholder = @"Search";
    self.mySearchBar.delegate = self;
    self.mySearchBar.showsCancelButton = YES;
    [self.mySearchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.view addSubview:self.mySearchBar];
    
    // Constrain views.
    [self.mySearchBar.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:0].active = YES;
    [self.mySearchBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:0].active = YES;
    [self.mySearchBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:0].active = YES;

    [self.segmentedControl.topAnchor constraintEqualToAnchor:self.mySearchBar.bottomAnchor constant:0].active = YES;
    [self.segmentedControl.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:0].active = YES;
    [self.segmentedControl.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:0].active = YES;
    [self.segmentedControl.heightAnchor constraintEqualToConstant:40.0].active = YES;

    [self.tableView.topAnchor constraintEqualToAnchor:self.segmentedControl.bottomAnchor constant:0].active = YES;
    [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:0].active = YES;
    [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:0].active = YES;
    [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:0].active = YES;
    
    [self categorySegmentChanged:self.segmentedControl];
}

- (void)viewDidLoad {
    [super viewDidLoad];
         
    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRight setFrame:CGRectMake(0, 0, 24, 18)];
    UIImage *plusImage = [UIImage imageNamed:@"05-plus"];
    plusImage = [plusImage imageWithTintColor:[UIColor whiteColor] renderingMode:UIImageRenderingModeAlwaysTemplate];
    [btnRight setImage:plusImage forState:UIControlStateNormal];
    [btnRight setBackgroundColor:[UIColor clearColor]];
    [btnRight addTarget:self action:@selector(userTappedAddNewFoodButton:) forControlEvents:UIControlEventTouchUpInside];
    [btnRight setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *barBtnRight = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    self.navigationItem.rightBarButtonItem = barBtnRight;
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];

    if (!date_currentDate) {
        NSDate* sourceDate = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
        [dateFormat setTimeZone:systemTimeZone];
        NSString *date_string = [dateFormat stringFromDate:sourceDate];
        NSDate *date_today = [dateFormat dateFromString:date_string];
        
        self.date_currentDate = date_today;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [DMActivityIndicator showActivityIndicator];
    [self loadSearchData:self.mySearchBar.text];
    if (self.searchType == DMFoodSearchTypeAllFoods && [self.mySearchBar.text length] == 0) {
        [self.mySearchBar becomeFirstResponder];
    }
    
    // If we're coming back from Favorite Meals, reset view.
    if (self.searchType == DMFoodSearchTypeFavoriteMeals) {
        self.searchType = DMFoodSearchTypeAllFoods;
        [self loadSearchData:self.mySearchBar.text];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];

    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    if (dietmasterEngine.isMealPlanItem) {
        self.title = @"Equivalent Foods";
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    self.tableView.scrollEnabled = NO;
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar*) theSearchBar {
    self.tableView.scrollEnabled = YES;
    [self.mySearchBar resignFirstResponder];
    [DMActivityIndicator showActivityIndicator];

    [self loadSearchData:theSearchBar.text];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self.tableView reloadData];
    return YES;
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [self.tableView reloadData];
    return YES;
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    self.tableView.scrollEnabled = YES;
    [self loadSearchData:searchText];
    [self.tableView reloadData];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    self.tableView.scrollEnabled = YES;
    self.tableView.userInteractionEnabled = YES;
        
    searchBar.text = @"";
    [DMActivityIndicator showActivityIndicator];

    [self loadSearchData:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.mySearchBar isFirstResponder] && [touch view] != self.mySearchBar) {
        [self.mySearchBar resignFirstResponder];
        self.tableView.scrollEnabled = YES;
        self.tableView.userInteractionEnabled = YES;
    }
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - DATA METHODS

- (void)loadSearchData:(NSString *)searchTerm {
    [self.foodResults removeAllObjects];

    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int userID = [[prefs valueForKey:@"userid_dietmastergo"] intValue];
    int companyID = [[prefs valueForKey:@"companyid_dietmastergo"] intValue];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
       
    }
    
    NSString *query = nil;
    NSString *query2 = nil;
    
    if ([searchTerm length] > 1) {
        NSMutableString *additionalQuery = [NSMutableString new];
        NSString *str = searchTerm;
        NSString *lastCharInString = [[str substringFromIndex:[str length]-1] lowercaseString];
        NSString *lastCharInString1 = [[str substringFromIndex:[str length]-2] lowercaseString];
        if ([lastCharInString isEqualToString:@"s"]) {
            if([lastCharInString1 isEqualToString:@"'s"]) {
                searchTerm = [str substringToIndex:[str length]-2];
            }
            else {
                searchTerm = [str substringToIndex:[str length]-1];
            }
        }
        
        NSArray *piecesOfOriginalString = [searchTerm componentsSeparatedByString:@" "];
        if ([piecesOfOriginalString count] > 1) {
            searchTerm = [NSString stringWithString:[piecesOfOriginalString objectAtIndex:0]];
            int counter = 0;
            for (NSString *piece in piecesOfOriginalString) {
                if (counter == 0) {
                    counter++;
                    continue;
                }
                [additionalQuery appendFormat:@" AND (Food.Name LIKE '%%%@%%' OR Food.FoodTags LIKE '%%%@%%')",piece, piece];
                counter++;
            }
        }
        
        if (self.searchType == DMFoodSearchTypeMyFoods) {
            query = [NSString stringWithFormat: @"SELECT Food.FoodID,Food.ServingSize,Food.Name,Food.Calories,Food.Fat,Food.Carbohydrates,Food.Protein,Food.FoodKey,Food.UserID,Food.FoodPK, Food.CategoryID, Food.FoodURL, Food.RecipeID FROM Food WHERE (Food.Name LIKE '%@%%') %@ AND Food.UserID = %i ORDER BY Food.FoodKey ASC LIMIT %@", searchTerm, additionalQuery, userID, @"150"];
            query2 = [NSString stringWithFormat: @"SELECT Food.FoodID,Food.ServingSize,Food.Name,Food.Calories,Food.Fat,Food.Carbohydrates,Food.Protein,Food.FoodKey,Food.UserID,Food.FoodPK, Food.CategoryID, Food.FoodURL, Food.RecipeID FROM Food WHERE (Food.Name LIKE '%%%@%%' OR Food.FoodTags LIKE '%%%@%%') %@ AND Food.UserID = %i ORDER BY Food.FoodKey DESC LIMIT %@", searchTerm, searchTerm, additionalQuery, userID, @"150"];
        } else if (self.searchType == DMFoodSearchTypeFavoriteFoods) {
            query = [NSString stringWithFormat: @"SELECT fav.Favorite_FoodID, fav.FoodID, food.ServingSize,food.Name,food.Calories,food.Fat,food.Carbohydrates,food.Protein,food.FoodKey,food.UserID,food.FoodPK, Food.CategoryID, Food.FoodURL, Food.RecipeID  FROM Favorite_Food fav INNER JOIN Food food ON fav.FoodID = food.FoodKey WHERE (food.Name LIKE '%@%%') %@ ORDER BY food.Frequency ASC LIMIT %@", searchTerm, additionalQuery, @"150"];
            query2 = [NSString stringWithFormat: @"SELECT fav.Favorite_FoodID, fav.FoodID, food.ServingSize,food.Name,food.Calories,food.Fat,food.Carbohydrates,food.Protein,food.FoodKey,food.UserID,food.FoodPK, Food.CategoryID, Food.FoodURL, Food.RecipeID  FROM Favorite_Food fav INNER JOIN Food food ON fav.FoodID = food.FoodKey WHERE (food.Name LIKE '%%%@%%' OR food.FoodTags LIKE '%%%@%%') %@ ORDER BY food.Frequency DESC LIMIT %@", searchTerm, searchTerm, additionalQuery, @"150"];
            
        } else if (self.searchType == DMFoodSearchTypeAllFoods) {
            query = [NSString stringWithFormat: @"SELECT Food.ServingSize,Food.FoodID,Food.Name,Food.Calories,Food.Fat,Food.Carbohydrates,Food.Protein,Food.FoodKey,Food.UserID,Food.FoodPK, Food.CategoryID, Food.FoodURL, Food.RecipeID FROM Food WHERE (Food.Name LIKE '%@%%') %@ ORDER BY Food.Frequency ASC LIMIT %@", searchTerm, additionalQuery, @"150"];
            query2 = [NSString stringWithFormat: @"SELECT Food.ServingSize,Food.FoodID,Food.Name,Food.Calories,Food.Fat,Food.Carbohydrates,Food.Protein,Food.FoodKey,Food.UserID,Food.FoodPK, Food.CategoryID, Food.FoodURL, Food.RecipeID FROM Food WHERE (Food.Name LIKE '%%%@%%' OR Food.FoodTags LIKE '%%%@%%') %@ ORDER BY Food.Frequency DESC LIMIT %@", searchTerm, searchTerm, additionalQuery, @"150"];
            
        }
        else if (self.searchType == DMFoodSearchTypeProgramFoods) {
            query = [NSString stringWithFormat: @"SELECT Food.ServingSize,Food.FoodID,Food.Name,Food.Calories,Food.Fat,Food.Carbohydrates,Food.Protein,Food.FoodKey,Food.UserID,Food.FoodPK, Food.CategoryID, Food.FoodURL, Food.RecipeID FROM Food WHERE (Food.Name LIKE '%@%%') %@ AND Food.CompanyID = %i ORDER BY Food.Frequency ASC LIMIT %@", searchTerm, additionalQuery, companyID, @"150"];
            query2 = [NSString stringWithFormat: @"SELECT Food.ServingSize,Food.FoodID,Food.Name,Food.Calories,Food.Fat,Food.Carbohydrates,Food.Protein,Food.FoodKey,Food.UserID,Food.FoodPK, Food.CategoryID, Food.FoodURL, Food.RecipeID FROM Food WHERE (Food.Name LIKE '%%%@%%' OR Food.FoodTags LIKE '%%%@%%') %@ AND Food.CompanyID = %i ORDER BY Food.Frequency DESC LIMIT %@", searchTerm, searchTerm, additionalQuery, companyID, @"150"];
        }
    } else {
        if (self.searchType == DMFoodSearchTypeMyFoods) {
            query = [NSString stringWithFormat: @"SELECT Food.ServingSize,Food.FoodID,Food.Name,Food.Calories,Food.Fat,Food.Carbohydrates,Food.Protein,Food.FoodKey,Food.UserID,Food.FoodPK, Food.CategoryID, Food.FoodURL, Food.RecipeID FROM Food WHERE Food.UserID = %i ORDER BY LOWER(Food.Name) ASC LIMIT %@", userID, @"150"];
        }
        else if (self.searchType == DMFoodSearchTypeFavoriteFoods) {
            query = [NSString stringWithFormat: @"SELECT fav.Favorite_FoodID, fav.FoodID, food.ServingSize,food.Name,food.Calories,food.Fat,food.Carbohydrates,food.Protein,food.FoodKey,food.UserID,food.FoodPK, Food.CategoryID, Food.FoodURL, Food.RecipeID FROM Favorite_Food fav INNER JOIN Food food ON fav.FoodID = food.FoodKey ORDER BY food.Frequency DESC LIMIT %@", @"150"];
            
        }
        else if (self.searchType == DMFoodSearchTypeAllFoods) {
            query = [NSString stringWithFormat: @"SELECT Food.ServingSize,Food.FoodID,Food.Name,Food.Calories,Food.Fat,Food.Carbohydrates,Food.Protein,Food.FoodKey,Food.UserID,Food.FoodPK, Food.CategoryID, Food.FoodURL, Food.RecipeID FROM Food ORDER BY Food.Frequency DESC LIMIT %@", @"150"];
            
        }
        else if (self.searchType == DMFoodSearchTypeProgramFoods) {
            query = [NSString stringWithFormat: @"SELECT Food.ServingSize,Food.FoodID,Food.Name,Food.Calories,Food.Fat,Food.Carbohydrates,Food.Protein,Food.FoodKey,Food.UserID,Food.FoodPK, Food.CategoryID, Food.FoodURL, Food.RecipeID FROM Food WHERE Food.CompanyID = %i ORDER BY LOWER(Food.Name) ASC LIMIT 150", companyID];
        }
    }
    
    NSMutableArray *arrFoodIDs = [[NSMutableArray alloc] init];
    FMResultSet *rs = [db executeQuery:query];
    
    while ([rs next]) {
        int_foodID = [[rs stringForColumn:@"FoodID"] intValue];
        
        NSNumber *mealID;
        mealID = dietmasterEngine.selectedMealID;
        if (!mealID) {
            mealID = [NSNumber numberWithInt:0];
        }
        
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithInt:[rs intForColumn:@"FoodID"]], @"FoodID",
                              [NSNumber numberWithInt:[rs intForColumn:@"FoodKey"]], @"FoodKey",
                              mealID, @"MealID",
                              [rs stringForColumn:@"Name"], @"Name",
                              [NSNumber numberWithInt:[rs intForColumn:@"Calories"]], @"Calories",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Fat"]], @"Fat",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Carbohydrates"]], @"Carbohydrates",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Protein"]], @"Protein",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"ServingSize"]], @"ServingSize",
                              [NSNumber numberWithInt:[rs intForColumn:@"CategoryID"]], @"CategoryID",
                              [NSNumber numberWithInt:[rs intForColumn:@"RecipeID"]], @"RecipeID",
                              [rs stringForColumn:@"FoodURL"], @"FoodURL",
                              nil];
        
        [arrFoodIDs addObject:[NSString stringWithFormat:@"%@", [rs stringForColumn:@"Name"]]];
        [self.foodResults addObject:dict];
    }
    [rs close];
    
    if (!query2) {
        [self.tableView reloadData];
        [DMActivityIndicator hideActivityIndicator];
        return;
    }
    
    FMResultSet *rs2 = [db executeQuery:query2];
    while ([rs2 next]) {
        int_foodID = [[rs2 stringForColumn:@"FoodID"] intValue];
        
        NSNumber *mealID;
        mealID = dietmasterEngine.selectedMealID;
        if (!mealID) {
            mealID = [NSNumber numberWithInt:0];
        }
        
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithInt:[rs2 intForColumn:@"FoodID"]], @"FoodID",
                              [NSNumber numberWithInt:[rs2 intForColumn:@"FoodKey"]], @"FoodKey",
                              mealID, @"MealID",
                              [rs2 stringForColumn:@"Name"], @"Name",
                              [NSNumber numberWithInt:[rs2 intForColumn:@"Calories"]], @"Calories",
                              [NSNumber numberWithDouble:[rs2 doubleForColumn:@"Fat"]], @"Fat",
                              [NSNumber numberWithDouble:[rs2 doubleForColumn:@"Carbohydrates"]], @"Carbohydrates",
                              [NSNumber numberWithDouble:[rs2 doubleForColumn:@"Protein"]], @"Protein",
                              [NSNumber numberWithDouble:[rs2 doubleForColumn:@"ServingSize"]], @"ServingSize",
                              [NSNumber numberWithInt:[rs2 intForColumn:@"CategoryID"]], @"CategoryID",
                              [NSNumber numberWithInt:[rs2 intForColumn:@"RecipeID"]], @"RecipeID",
                              [rs2 stringForColumn:@"FoodURL"], @"FoodURL",
                              nil];
        
        if (![arrFoodIDs containsObject:[rs2 stringForColumn:@"Name"]]) {
            [self.foodResults addObject:dict];
            
            if ([self.foodResults count] >= 150) {
                break;
            }
        }
        
    }
    [rs2 close];
    
    [self.tableView reloadData];
    
    [DMActivityIndicator hideActivityIndicator];
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
    return UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.foodResults count] == 0) {
        return 1;
    }
    else {
        return [self.foodResults count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyLogTableViewCell *cell = (MyLogTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.lblFoodName.numberOfLines = 0;
    cell.lblFoodName.lineBreakMode = NSLineBreakByWordWrapping;
    cell.lblFoodName.textColor = [UIColor blackColor];
    cell.lblFoodName.font = [UIFont systemFontOfSize:15.0];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle =  UITableViewCellSelectionStyleGray;
    [cell lblFoodName].adjustsFontSizeToFitWidth = NO;
    cell.lblCalories = nil;

    if (self.foodResults.count == 0) {
        [cell lblFoodName].adjustsFontSizeToFitWidth = YES;
        cell.lblFoodName.textColor = [UIColor lightGrayColor];
        [[cell lblFoodName] setText:@"No results found..."];
        cell.lblFoodName.font = [UIFont systemFontOfSize:15.0];
        cell.selectionStyle =  UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.userInteractionEnabled = NO;
        cell.accessoryView = nil;
    } else {
        cell.userInteractionEnabled = YES;
        
        NSDictionary *dict1 = [[NSDictionary alloc] initWithDictionary:[self.foodResults objectAtIndex:indexPath.row]];
        NSString *nameString = [dict1 valueForKey:@"Name"];
        
        NSRange r = [nameString rangeOfString:nameString];
        cell.lblFoodName.text = nameString;
        
        NSNumber *foodCategory = [dict1 valueForKey:@"CategoryID"];
        
        if ([foodCategory intValue] == 66) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *hostname = [prefs stringForKey:@"HostName"];
            NSNumber *recipeID = [dict1 valueForKey:@"RecipeID"];
            
            if (hostname != nil && ![hostname isEqualToString:@""] && recipeID != nil && [recipeID intValue] > 0) {
                cell.userInteractionEnabled = YES;
                cell.lblFoodName.delegate = self;
                NSString *url = [NSString stringWithFormat:@"%@/PDFviewer.aspx?ReportName=CustomRecipe&ID=%@", hostname, recipeID];
                [cell.lblFoodName addLinkToURL:[NSURL URLWithString:url] withRange:r];
            }
            
        } else {
            NSString *foodURL = [dict1 valueForKey:@"FoodURL"];
            if (foodURL != nil && ![foodURL isEqualToString:@""]) {
                cell.userInteractionEnabled = YES;
                cell.lblFoodName.delegate = self;
                [cell.lblFoodName addLinkToURL:[NSURL URLWithString:foodURL] withRange:r];
            } else {
                cell.lblFoodName.delegate = nil;
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)myTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [myTableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Search"
                                   style: UIBarButtonItemStylePlain
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[self.foodResults objectAtIndex:indexPath.row]];
    [dietmasterEngine.foodSelectedDict setDictionary:dict];
    dietmasterEngine.dateSelected = date_currentDate;
    
    if ([dietmasterEngine.taskMode isEqualToString:@"View"]) {
        
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        ManageFoods *mfController = [[ManageFoods alloc] init];
        
        //HHT we save the selected Tab in appdegate and pass to manageFood and when scan complete we use that to select the current tab
        mfController.intTabId = AppDel.selectedIndex;
        
        [self.navigationController pushViewController:mfController animated:YES];
        mfController.hideAddToLog = YES;
    }
    else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        DetailViewController *dvController = [[DetailViewController alloc] init];
        dvController.foodIdValue = [NSString stringWithFormat:@"%@",[dietmasterEngine.foodSelectedDict valueForKey:@"FoodID"]];
        dvController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:dvController animated:YES];
    }
}

#pragma mark - Actions

/// Action called when the user changes the value in the segmented control.
- (void)categorySegmentChanged:(id)sender {
    ScrollableSegmentedControl *control = (ScrollableSegmentedControl *)sender;
    self.searchType = (DMFoodSearchType)control.selectedSegmentIndex;
    
    if (self.searchType == DMFoodSearchTypeFavoriteMeals) {
        FavoriteMealsViewController *favoriteMealsViewController = [[FavoriteMealsViewController alloc] init];
        [self.navigationController pushViewController:favoriteMealsViewController animated:YES];
        return;
    }

    self.tableView.scrollEnabled = YES;
    self.tableView.userInteractionEnabled = YES;
    [self loadSearchData:@""];
    [self loadSearchData:self.mySearchBar.text];
}

- (IBAction)userTappedAddNewFoodButton:(id)sender {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    dietmasterEngine.taskMode = @"Save";
    
    ManageFoods *mfController = [[ManageFoods alloc] init];
    
    //HHT we save the selected Tab in appdegate and pass to manageFood and when scan complete we use that to select the current tab
    mfController.intTabId = AppDel.selectedIndex;
    
    [self.navigationController pushViewController:mfController animated:YES];
    mfController = nil;
}

#pragma mark - TTTAttributedLabel Delegate
//HHT to redirct on link click
- (void)attributedLabel:(__unused TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

@end
