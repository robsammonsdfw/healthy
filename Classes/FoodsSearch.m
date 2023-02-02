//
//  FoodsSearch.m
//  DietMasterGo
//
//  Created by Andrew Moffitt on 3/1/11.
//  Copyright 2011 AE Studios. All rights reserved.
//

#import "FoodsSearch.h"
#import "DietMasterGoAppDelegate.h"
#import "DetailViewController.h"
#import "DietmasterEngine/DietmasterEngine.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "DietmasterEngine.h"
#import "ManageFoods.h"
#import "FavoriteMealsViewController.h"
#import "MyLogTableViewCell.h"

@implementation FoodsSearch {
    UISearchController *searchDisplayController;
}

@synthesize tableView, date_currentDate, int_mealID;
@synthesize mySearchBar, bSearchIsOn, searchType;

#pragma mark SEARCH BAR METHODS
- (void)searchBar:(id)object {
    if (bSearchIsOn) {
        bSearchIsOn = NO;
    }
    else {
        bSearchIsOn = YES;
    }
    
    if (bSearchIsOn) {
        self.tableView.tableHeaderView = mySearchBar;
        [mySearchBar becomeFirstResponder];
    }
    else {
        [UIView beginAnimations:@"foo" context:NULL];
        [UIView setAnimationDuration:0.5f];
        [UIView commitAnimations];
        [mySearchBar resignFirstResponder];
    }
    
    [self.tableView scrollRectToVisible:[[self.tableView tableHeaderView] bounds] animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    bSearchIsOn = YES;
    self.tableView.scrollEnabled = NO;
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar*) theSearchBar {
    self.tableView.scrollEnabled = YES;
    [mySearchBar resignFirstResponder];
    DietMasterGoAppDelegate *appDelegate = (DietMasterGoAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showLoading];
    
    [self performSelector:@selector(loadSearchData:) withObject:theSearchBar.text afterDelay:0.25];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    bSearchIsOn = YES;
    [self.tableView reloadData];
    return YES;
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.tableView reloadData];
    return YES;
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    if([searchText length] > 0) {
        bSearchIsOn = YES;
        self.tableView.scrollEnabled = YES;
    }
    else {
        bSearchIsOn = NO;
        self.tableView.scrollEnabled = YES;
    }
    
    [self performSelector:@selector(loadSearchData:) withObject:theSearchBar.text afterDelay:0.25];
    [self.tableView reloadData];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.mySearchBar isFirstResponder] && [touch view] != self.mySearchBar) {
        [self.mySearchBar resignFirstResponder];
        self.tableView.scrollEnabled = YES;
        self.tableView.userInteractionEnabled = YES;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    [super touchesBegan:touches withEvent:event];
}

#pragma mark Keyboard Hide/Show Register
- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark Keyboard Hide/Show Delegate Methods
- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height - self.mySearchBar.frame.size.height, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height - mySearchBar.frame.size.height - mySearchBar.frame.origin.y;
    if (!CGRectContainsPoint(aRect, mySearchBar.frame.origin) ) {
        [self.tableView scrollRectToVisible:mySearchBar.frame animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

#pragma mark VIEW LIFECYCLE

- (void)viewDidLoad {
    if ([searchType isEqualToString:@"All Foods"] && [mySearchBar.text length] == 0) {
        [_btnall setTitleColor:[UIColor colorWithRed:(221/255.f) green:(134/255.f) blue:(10/255.f) alpha:1.0f] forState:UIControlStateNormal];
        [_btnfood setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    else {
        [_btnall setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_btnfood setTitleColor:[UIColor colorWithRed:(221/255.f) green:(134/255.f) blue:(10/255.f) alpha:1.0f] forState:UIControlStateNormal];
    }
    
    [_btnfavfoods setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_btnprogram setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_btnfacmeals setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    if ([searchType isEqualToString:@"All Foods"] && [mySearchBar.text length] == 0)
        _imgscrl.frame = CGRectMake(_btnall.frame.origin.x, 28, 100, 2);
    else
        _imgscrl.frame = CGRectMake(_btnfood.frame.origin.x, 28, 100, 2);
    
    _scroll.contentSize=CGSizeMake(500, 30);
    
    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRight setFrame:CGRectMake(0, 0, 24, 18)];
    [btnRight setImage:[UIImage imageNamed:@"195-barcode"] forState:UIControlStateNormal];
    [btnRight setBackgroundColor:[UIColor whiteColor]];
    [btnRight addTarget:self action:@selector(ScanbtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barBtnRight = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    [barBtnRight setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem=barBtnRight;

    mySearchBar = [[UISearchBar alloc] init];
    mySearchBar.placeholder = @"Search";
    mySearchBar.delegate = self;
    self.bSearchIsOn = NO;
    mySearchBar.tintColor = [UIColor blackColor];
    mySearchBar.showsCancelButton = YES;
    [mySearchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    mySearchBar.backgroundColor=[UIColor redColor];
    mySearchBar.frame=CGRectMake(0, 50, 50, 40);
    self.tableView.tableHeaderView = mySearchBar;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    if(!date_currentDate) {
        NSDate* sourceDate = [NSDate date];
        NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
        [dateFormat setTimeZone:systemTimeZone];
        NSString *date_string = [dateFormat stringFromDate:sourceDate];
        NSDate *date_today = [dateFormat dateFromString:date_string];
        
        self.date_currentDate = date_today;
    }
    
    HUD.delegate = self;
    
    if (!foodResults)
        foodResults = [[NSMutableArray alloc] init];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    [self registerForKeyboardNotifications];
    
    [super viewDidLoad];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    DietMasterGoAppDelegate *appDelegate = (DietMasterGoAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showLoading];
    
    [self performSelector:@selector(loadSearchData:) withObject:mySearchBar.text afterDelay:0.25];
    
    if ([searchType isEqualToString:@"All Foods"] && [mySearchBar.text length] == 0) {
        [mySearchBar becomeFirstResponder];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (bSearchIsOn) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    else {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    if (dietmasterEngine.isMealPlanItem) {
        self.title = @"Equivalent Foods";
    }
}

#pragma mark DATA METHODS
-(void)loadSearchData:(NSString *)searchTerm {
    if (foodResults) {
        [foodResults removeAllObjects];
    }
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
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
        
        if ([searchType isEqualToString:@"My Foods"]) {
            query = [NSString stringWithFormat: @"SELECT Food.FoodID,Food.ServingSize,Food.Name,Food.Calories,Food.Fat,Food.Carbohydrates,Food.Protein,Food.FoodKey,Food.UserID,Food.FoodPK, Food.CategoryID, Food.FoodURL, Food.RecipeID FROM Food WHERE (Food.Name LIKE '%@%%') %@ AND Food.UserID = %i ORDER BY Food.FoodKey ASC LIMIT %@", searchTerm, additionalQuery, userID, @"150"];
            query2 = [NSString stringWithFormat: @"SELECT Food.FoodID,Food.ServingSize,Food.Name,Food.Calories,Food.Fat,Food.Carbohydrates,Food.Protein,Food.FoodKey,Food.UserID,Food.FoodPK, Food.CategoryID, Food.FoodURL, Food.RecipeID FROM Food WHERE (Food.Name LIKE '%%%@%%' OR Food.FoodTags LIKE '%%%@%%') %@ AND Food.UserID = %i ORDER BY Food.FoodKey DESC LIMIT %@", searchTerm, searchTerm, additionalQuery, userID, @"150"];
        } else if ([searchType isEqualToString:@"Favorite Foods"]) {
            query = [NSString stringWithFormat: @"SELECT fav.Favorite_FoodID, fav.FoodID, food.ServingSize,food.Name,food.Calories,food.Fat,food.Carbohydrates,food.Protein,food.FoodKey,food.UserID,food.FoodPK, Food.CategoryID, Food.FoodURL, Food.RecipeID  FROM Favorite_Food fav INNER JOIN Food food ON fav.FoodID = food.FoodKey WHERE (food.Name LIKE '%@%%') %@ ORDER BY food.Frequency ASC LIMIT %@", searchTerm, additionalQuery, @"150"];
            query2 = [NSString stringWithFormat: @"SELECT fav.Favorite_FoodID, fav.FoodID, food.ServingSize,food.Name,food.Calories,food.Fat,food.Carbohydrates,food.Protein,food.FoodKey,food.UserID,food.FoodPK, Food.CategoryID, Food.FoodURL, Food.RecipeID  FROM Favorite_Food fav INNER JOIN Food food ON fav.FoodID = food.FoodKey WHERE (food.Name LIKE '%%%@%%' OR food.FoodTags LIKE '%%%@%%') %@ ORDER BY food.Frequency DESC LIMIT %@", searchTerm, searchTerm, additionalQuery, @"150"];
            
        } else if ([searchType isEqualToString:@"All Foods"]) {
            query = [NSString stringWithFormat: @"SELECT Food.ServingSize,Food.FoodID,Food.Name,Food.Calories,Food.Fat,Food.Carbohydrates,Food.Protein,Food.FoodKey,Food.UserID,Food.FoodPK, Food.CategoryID, Food.FoodURL, Food.RecipeID FROM Food WHERE (Food.Name LIKE '%@%%') %@ ORDER BY Food.Frequency ASC LIMIT %@", searchTerm, additionalQuery, @"150"];
            query2 = [NSString stringWithFormat: @"SELECT Food.ServingSize,Food.FoodID,Food.Name,Food.Calories,Food.Fat,Food.Carbohydrates,Food.Protein,Food.FoodKey,Food.UserID,Food.FoodPK, Food.CategoryID, Food.FoodURL, Food.RecipeID FROM Food WHERE (Food.Name LIKE '%%%@%%' OR Food.FoodTags LIKE '%%%@%%') %@ ORDER BY Food.Frequency DESC LIMIT %@", searchTerm, searchTerm, additionalQuery, @"150"];
            
        }
        else if ([searchType isEqualToString:@"Program Foods"]) {
            query = [NSString stringWithFormat: @"SELECT Food.ServingSize,Food.FoodID,Food.Name,Food.Calories,Food.Fat,Food.Carbohydrates,Food.Protein,Food.FoodKey,Food.UserID,Food.FoodPK, Food.CategoryID, Food.FoodURL, Food.RecipeID FROM Food WHERE (Food.Name LIKE '%@%%') %@ AND Food.CompanyID = %i ORDER BY Food.Frequency ASC LIMIT %@", searchTerm, additionalQuery, companyID, @"150"];
            query2 = [NSString stringWithFormat: @"SELECT Food.ServingSize,Food.FoodID,Food.Name,Food.Calories,Food.Fat,Food.Carbohydrates,Food.Protein,Food.FoodKey,Food.UserID,Food.FoodPK, Food.CategoryID, Food.FoodURL, Food.RecipeID FROM Food WHERE (Food.Name LIKE '%%%@%%' OR Food.FoodTags LIKE '%%%@%%') %@ AND Food.CompanyID = %i ORDER BY Food.Frequency DESC LIMIT %@", searchTerm, searchTerm, additionalQuery, companyID, @"150"];
        }
    } else {
        if ([searchType isEqualToString:@"My Foods"]) {
            query = [NSString stringWithFormat: @"SELECT Food.ServingSize,Food.FoodID,Food.Name,Food.Calories,Food.Fat,Food.Carbohydrates,Food.Protein,Food.FoodKey,Food.UserID,Food.FoodPK, Food.CategoryID, Food.FoodURL, Food.RecipeID FROM Food WHERE Food.UserID = %i ORDER BY LOWER(Food.Name) ASC LIMIT %@", userID, @"150"];
        }
        else if ([searchType isEqualToString:@"Favorite Foods"]) {
            query = [NSString stringWithFormat: @"SELECT fav.Favorite_FoodID, fav.FoodID, food.ServingSize,food.Name,food.Calories,food.Fat,food.Carbohydrates,food.Protein,food.FoodKey,food.UserID,food.FoodPK, Food.CategoryID, Food.FoodURL, Food.RecipeID FROM Favorite_Food fav INNER JOIN Food food ON fav.FoodID = food.FoodKey ORDER BY food.Frequency DESC LIMIT %@", @"150"];
            
        }
        else if ([searchType isEqualToString:@"All Foods"]) {
            query = [NSString stringWithFormat: @"SELECT Food.ServingSize,Food.FoodID,Food.Name,Food.Calories,Food.Fat,Food.Carbohydrates,Food.Protein,Food.FoodKey,Food.UserID,Food.FoodPK, Food.CategoryID, Food.FoodURL, Food.RecipeID FROM Food ORDER BY Food.Frequency DESC LIMIT %@", @"150"];
            
        }
        else if ([searchType isEqualToString:@"Program Foods"]) {
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
        [foodResults addObject:dict];
       
        [dict release];
    }
    [rs close];
    
    if (!query2) {
        [self.tableView reloadData];
        DietMasterGoAppDelegate *appDelegate = (DietMasterGoAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate hideLoading];
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
            [foodResults addObject:dict];
            
            if ([foodResults count]>= 150) {
                break;
            }
        }
        [dict release];
    }
    [rs2 close];
    
    [self.tableView reloadData];
    
    DietMasterGoAppDelegate *appDelegate = (DietMasterGoAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate hideLoading];
    
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
    if ([foodResults count] == 0) {
        return 46;
    }
    
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[foodResults objectAtIndex:indexPath.row]];
    NSString *text = [dict valueForKey:@"Name"];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
//    CGSize labelSize = [text sizeWithFont:[UIFont systemFontOfSize:14.0]
//                        constrainedToSize:constraintSize
//                            lineBreakMode:NSLineBreakByWordWrapping];
    CGRect textRect = [text boundingRectWithSize:constraintSize
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]}
                                     context:nil];

    CGSize labelSize = textRect.size;
    
//    BOOBIES
    
    [dict release];
    
    if (labelSize.height < 46) {
        return 48;
    }
    else {
        return labelSize.height + 6;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([foodResults count] == 0) {
        return 1;
    }
    else {
        return [foodResults count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)myTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MyLogTableViewCell";
    
    MyLogTableViewCell *cell = (MyLogTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MyLogTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.lblFoodName.numberOfLines = 0;
    cell.lblFoodName.lineBreakMode = NSLineBreakByWordWrapping;
    cell.lblCalories = nil;
    
    if ([foodResults count] == 0) {
        [cell lblFoodName].adjustsFontSizeToFitWidth = YES;
        cell.lblFoodName.textColor = [UIColor lightGrayColor];
        [[cell lblFoodName] setText:@"No results found..."];
        cell.lblFoodName.font = [UIFont systemFontOfSize:14.0];
        cell.selectionStyle =  UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.userInteractionEnabled = NO;
        cell.accessoryView = nil;
    }

    if ([foodResults count] > 0) {
        cell.userInteractionEnabled = YES;
        
        NSDictionary *dict1 = [[NSDictionary alloc] initWithDictionary:[foodResults objectAtIndex:indexPath.row]];
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
        
        [dict1 release];

        cell.lblFoodName.textColor = [UIColor blackColor];
        
        cell.lblFoodName.font = [UIFont systemFontOfSize:14.0];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle =  UITableViewCellSelectionStyleGray;
        [cell lblFoodName].adjustsFontSizeToFitWidth = NO;
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
    [backButton release];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[foodResults objectAtIndex:indexPath.row]];
    [dietmasterEngine.foodSelectedDict setDictionary:dict];
    dietmasterEngine.dateSelected = date_currentDate;
    
    if ([dietmasterEngine.taskMode isEqualToString:@"View"]) {
        
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        ManageFoods *mfController = [[ManageFoods alloc] initWithNibName:@"ManageFoods" bundle:nil];
        
        //HHT we save the selected Tab in appdegate and pass to manageFood and when scan complete we use that to select the current tab
        mfController.intTabId = AppDel.selectedIndex;
        
        [self.navigationController pushViewController:mfController animated:YES];
        mfController.hideAddToLog = YES;
        [mfController release];
    }
    else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        DetailViewController *dvController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
        dvController.foodIdValue = [NSString stringWithFormat:@"%@",[dietmasterEngine.foodSelectedDict valueForKey:@"FoodID"]];
        dvController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:dvController animated:YES];
        [dvController release];
    }
    
    [dict release];
}

//- (void)viewDidUnload {
//    [super viewDidUnload];
//    foodResults = nil;
//    tableView = nil;
//    mySearchBar = nil;
//    searchType = nil;
//}

- (void)dealloc {
    [searchType release];
    [mySearchBar release];
    [foodResults release];
    [_scroll release];
    [_imgscrl release];
    [_btnall release];
    [_btnfood release];
    [_btnfavfoods release];
    [_btnprogram release];
    [_btnfacmeals release];
    
    foodResults = nil;
    tableView = nil;
    mySearchBar = nil;
    searchType = nil;

    [super dealloc];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    self.tableView.scrollEnabled = YES;
    self.tableView.userInteractionEnabled = YES;
    
    [UIView beginAnimations:@"foo" context:NULL];
    [UIView setAnimationDuration:0.25f];
    [UIView commitAnimations];
    
    bSearchIsOn = NO;
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    searchBar.text = @"";
    DietMasterGoAppDelegate *appDelegate = (DietMasterGoAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showLoading];
    
    [self performSelector:@selector(loadSearchData:) withObject:@"" afterDelay:0.25];
    
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods
-(void)showLoading {
    HUD = [[MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES] retain];
}

-(void)hideLoading {
    [HUD hide:YES afterDelay:0.5];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    [HUD removeFromSuperview];
    [HUD release];
    HUD = nil;
}


- (IBAction)ScrollBtnClick:(id)sender {
    
    UIButton *btnn=(UIButton *)sender;
    
    if (btnn.tag ==1) {
        searchType=@"All Foods";
        
        [_btnall setTitleColor:[UIColor colorWithRed:(221/255.f) green:(134/255.f) blue:(10/255.f) alpha:1.0f] forState:UIControlStateNormal];
        [_btnfood setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_btnfavfoods setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_btnprogram setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_btnfacmeals setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        //[self loadSearchData:searchType];
        
        //HHT change 2018
        [self loadSearchData:@""];
        
        [self performSelector:@selector(loadSearchData:) withObject:mySearchBar.text afterDelay:0.25];
    }
    else if (btnn.tag==2) {
        [_btnfood setTitleColor:[UIColor colorWithRed:(221/255.f) green:(134/255.f) blue:(10/255.f) alpha:1.0f] forState:UIControlStateNormal];
        [_btnall setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_btnfavfoods setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_btnprogram setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_btnfacmeals setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        searchType = @"My Foods";
        //[self loadSearchData:searchType];
        
        //HHT change 2018
        [self loadSearchData:@""];
    }
    else if (btnn.tag==3) {
        [_btnfavfoods setTitleColor:[UIColor colorWithRed:(221/255.f) green:(134/255.f) blue:(10/255.f) alpha:1.0f] forState:UIControlStateNormal];
        [_btnfood setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_btnall setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_btnprogram setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_btnfacmeals setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        searchType=@"Favorite Foods";
        //[self loadSearchData:searchType];
        
        //HHT change 2018
        [self loadSearchData:@""];
    }
    else if (btnn.tag==4) {
        [_btnprogram setTitleColor:[UIColor colorWithRed:(221/255.f) green:(134/255.f) blue:(10/255.f) alpha:1.0f] forState:UIControlStateNormal];
        [_btnfood setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_btnfavfoods setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_btnall setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_btnfacmeals setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        self.searchType=@"Program Foods";
        //[self loadSearchData:searchType];
        
        //HHT change 2018
        [self loadSearchData:@""];
    }
    else if (btnn.tag==5) {
        [_btnfacmeals setTitleColor:[UIColor colorWithRed:(221/255.f) green:(134/255.f) blue:(10/255.f) alpha:1.0f] forState:UIControlStateNormal];
        [_btnfood setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_btnfavfoods setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_btnprogram setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_btnall setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        FavoriteMealsViewController *favoriteMealsViewController = [[FavoriteMealsViewController alloc] init];
        [self.navigationController pushViewController:favoriteMealsViewController animated:YES];
        [favoriteMealsViewController release];
    }
    
    _imgscrl.frame=CGRectMake(btnn.frame.origin.x, 28, 100, 2);
    
    self.tableView.scrollEnabled = YES;
    self.tableView.userInteractionEnabled = YES;
    
    [UIView beginAnimations:@"foo" context:NULL];
    [UIView setAnimationDuration:0.25f];
    [UIView commitAnimations];
    bSearchIsOn = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    DietMasterGoAppDelegate *appDelegate = (DietMasterGoAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showLoading];
    [self performSelector:@selector(loadSearchData:) withObject:@"" afterDelay:0.25];
}

- (IBAction)ScanbtnPressed:(id)sender {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    dietmasterEngine.taskMode = @"Save";
    
    ManageFoods *mfController = [[ManageFoods alloc] initWithNibName:@"ManageFoods" bundle:nil];
    
    //HHT we save the selected Tab in appdegate and pass to manageFood and when scan complete we use that to select the current tab
    mfController.intTabId = AppDel.selectedIndex;
    
    [self.navigationController pushViewController:mfController animated:YES];
    [mfController release];
    mfController = nil;
}
-(NSMutableArray *) filterObjectsByKeys:(NSString *) key array:(NSMutableArray *)array {
    NSMutableSet *tempValues = [[NSMutableSet alloc] init];
    NSMutableArray *ret = [NSMutableArray array];
    for(id obj in array) {
        if(! [tempValues containsObject:[obj valueForKey:key]]) {
            [tempValues addObject:[obj valueForKey:key]];
            [ret addObject:obj];
        }
    }
    [tempValues release];
    return ret;
}

#pragma mark - TTTAttributedLabel Delegate
//HHT to redirct on link click
- (void)attributedLabel:(__unused TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url];
}

@end
