//
//  FavoriteMealsViewController.m
//  DietMasterGo
//
//  Created by Henry Kirk on 2/8/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import "FavoriteMealsViewController.h"
#import "FMDatabase.h"
#import "DMDetailTableViewCell.h"

static NSString *CellIdentifier = @"CellIdentifier";

@interface FavoriteMealsViewController() <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic) DMLogMealCode mealCode;
@property (nonatomic, strong) NSDate *selectedDate;
@end

@implementation FavoriteMealsViewController

#pragma mark VIEW LIFECYCLE

- (instancetype)initWithMealCode:(DMLogMealCode)mealCode
                    selectedDate:(NSDate *)selectedDate {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        _searchResults = [[NSMutableArray alloc] init];
        _mealCode = mealCode;
        _selectedDate = selectedDate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationItem setTitle:@"Favorite Meals"];
    self.tableView.estimatedRowHeight = 46;
    [self.tableView registerClass:[DMDetailTableViewCell class] forCellReuseIdentifier:CellIdentifier];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [DMActivityIndicator showActivityIndicator];
    [self loadSearchData:nil];
}

- (void)loadSearchData:(NSString *)searchTerm {
    [self.searchResults removeAllObjects];
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }
    
    NSString *query = @"SELECT Favorite_Meal.Favorite_MealID, Favorite_Meal.Favorite_Meal_Name FROM Favorite_Meal";
    
    FMResultSet *rs = [db executeQuery:query];
    while ([rs next]) {
        
        NSNumber *favoriteMealID = [NSNumber numberWithInt:[rs intForColumn:@"Favorite_MealID"]];
        NSString *favoriteMealName = [[NSString alloc] initWithString:[rs stringForColumn:@"Favorite_Meal_Name"]];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                     favoriteMealID, @"Favorite_MealID",
                                     favoriteMealName, @"Favorite_Meal_Name",
                                     nil];
        
        NSString *favMealFoodsQuery = [NSString stringWithFormat:@"SELECT DISTINCT Fav.Favorite_Meal_Items_ID, Fav.FoodKey, Fav.FoodID, Fav.MeasureID, Fav.Servings, Food.Name FROM Favorite_Meal_Items Fav INNER JOIN Food ON Fav.FoodKey = Food.FoodKey WHERE Fav.Favorite_Meal_ID = %i", [favoriteMealID intValue]];
        NSMutableArray *favFoodItemsArray = [[NSMutableArray alloc] init];
        NSMutableArray *favFoodItemsIds = [[NSMutableArray alloc] init];
        FMResultSet *rs2 = [db executeQuery:favMealFoodsQuery];
        while ([rs2 next]) {
            
            NSNumber *favoriteMealItemsID = [NSNumber numberWithInt:[rs2 intForColumn:@"Favorite_Meal_Items_ID"]];
            NSNumber *foodKey = [NSNumber numberWithInt:[rs2 intForColumn:@"FoodKey"]];
            NSNumber *foodID = [NSNumber numberWithInt:[rs2 intForColumn:@"FoodID"]];
            NSNumber *measureID = [NSNumber numberWithInt:[rs2 intForColumn:@"MeasureID"]];
            NSNumber *servingsNum = [NSNumber numberWithDouble:[rs2 doubleForColumn:@"Servings"]];
            NSString *foodName = [[NSString alloc] initWithString:[rs2 stringForColumn:@"Name"]];
            
            if (![favFoodItemsIds containsObject:foodKey]) {
                [favFoodItemsIds addObject:foodKey];
                
                
                NSDictionary *dict2 = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       favoriteMealItemsID, @"Favorite_Meal_Items_ID",
                                       foodKey, @"FoodKey",
                                       foodID, @"FoodID",
                                       measureID, @"MeasureID",
                                       servingsNum, @"Servings",
                                       foodName, @"Name",
                                       nil];
                
                [favFoodItemsArray addObject:dict2];
            }
        }
        
        [dict setValue:favFoodItemsArray forKey:@"Food_Items_Array"];
        
        if ([favFoodItemsArray count] > 0) {
            [self.searchResults addObject:dict];
        }
    }
    
    [rs close];
    
    [DMActivityIndicator hideActivityIndicator];
    [self.tableView reloadData];
}

- (void)saveFavoriteMealToLog:(NSDictionary *)mealDict {
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }
        
    for (NSDictionary *dict in [mealDict valueForKey:@"Food_Items_Array"]) {
        
        int num_measureID	= [[dict valueForKey:@"MeasureID"] intValue];
        double servingAmount = [[dict valueForKey:@"Servings"] floatValue];
        int foodID = [[dict valueForKey:@"FoodKey"] intValue];
      
        DMMyLogDataProvider *provider = [[DMMyLogDataProvider alloc] init];
        NSNumber *logMealID = [provider getLogMealIDForDate:self.selectedDate];

        [db beginTransaction];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSTimeZone* systemTimeZone1 = [NSTimeZone systemTimeZone];
        [dateFormatter setTimeZone:systemTimeZone1];
        NSString *date_string = [dateFormatter stringFromDate:self.selectedDate];
        
        NSString *insertSQL = [NSString stringWithFormat: @"REPLACE INTO Food_Log (MealID, MealDate) VALUES (%@, DATETIME('%@'))", logMealID, date_string];
        
        [db executeUpdate:insertSQL];
                
        NSDate* sourceDate = [NSDate date];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *lastModifiedString = [dateFormatter stringFromDate:sourceDate];
        
        insertSQL = [NSString stringWithFormat: @"REPLACE INTO Food_Log_Items "
                     "(MealID, FoodID, MealCode, MeasureID, NumberOfServings, LastModified) "
                     " VALUES (%@, %i, %i, %i, %f, DATETIME('%@'))",
                     logMealID, foodID, (int)self.mealCode, num_measureID, servingAmount, lastModifiedString];
        
        [db executeUpdate:insertSQL];
        
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        
        [db commit];
    }
    
    [DMActivityIndicator showCompletedIndicator];
    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
}

- (void)deleteMealFromFavorites:(NSDictionary *)mealDict {
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
    }
        
    int favoriteMealID	= [[mealDict valueForKey:@"Favorite_MealID"] intValue];
    
    [db beginTransaction];
    NSString *deleteSQL = [NSString stringWithFormat: @"DELETE FROM Favorite_Meal WHERE Favorite_MealID = %i",favoriteMealID];
    [db executeUpdate:deleteSQL];
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    deleteSQL = [NSString stringWithFormat: @"DELETE FROM Favorite_Meal_Items WHERE Favorite_Meal_ID = %i",favoriteMealID];
    [db executeUpdate:deleteSQL];
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
    
    [self loadSearchData:nil];
}

#pragma mark ACTION SHEET METHODS

- (void)confirmAddMealToLog:(NSDictionary *)mealDict {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Action" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    [alert addAction:[UIAlertAction actionWithTitle:@"Add to Log"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self saveFavoriteMealToLog:mealDict];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Remove Favorite Meal"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self confirmRemoveMealFromLog:mealDict];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)confirmRemoveMealFromLog:(NSDictionary *)mealDict {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Remove from Favorites?"
                                                                   message:@"Are you sure you wish to remove this?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes, Remove"
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self deleteMealFromFavorites:mealDict];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Don't Remove" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)checkButtonTapped:(id)sender event:(id)event {
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
    if (indexPath != nil) {
        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    }
}

#pragma mark TABLE VIEW METHODS
- (NSIndexPath *)tableView :(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MAX([self.searchResults count], 1);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)myTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DMDetailTableViewCell *cell = (DMDetailTableViewCell *)[myTableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    if ([self.searchResults count] == 0) {
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16.0];
        cell.detailTextLabel.text = @"";
        [[cell textLabel] setText:@"No results found..."];
        cell.selectionStyle =  UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.userInteractionEnabled = NO;
        cell.detailTextLabel.numberOfLines = 0;
        cell.textLabel.numberOfLines = 0;
        cell.accessoryView = nil;
        return cell;
    }
    
    NSDictionary *dict = [self.searchResults objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [[dict valueForKey:@"Favorite_Meal_Name"] capitalizedString];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
    cell.selectionStyle =  UITableViewCellSelectionStyleGray;
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.detailTextLabel.numberOfLines = 0;
    cell.textLabel.numberOfLines = 0;
    cell.userInteractionEnabled = YES;
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    
    NSMutableString *foodItemsString = [NSMutableString stringWithString:@""];
    
    for (NSDictionary *dict2 in [dict valueForKey:@"Food_Items_Array"]) {
        
        NSString *nameString = [dict2 valueForKey:@"Name"];
        NSRange range = [nameString rangeOfString:@"\\s*$" options:NSRegularExpressionSearch];
        [nameString stringByReplacingCharactersInRange:range withString:@""];
        double servings = [[dict2 valueForKey:@"Servings"] floatValue];
        if (servings == 0) {
            servings = 1.0;
        }
        [foodItemsString appendFormat:@"%.1f Servings: %@ \n",servings, nameString];
    }
    
    cell.detailTextLabel.text = foodItemsString;
    
    UIImage *image = [UIImage imageNamed:@"05-plus.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0.0, 0.0, 16, 16);
    button.frame = frame;
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(checkButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor clearColor];
    cell.accessoryView = button;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (!self.searchResults.count) {
        return;
    }
    NSDictionary *dict = [self.searchResults objectAtIndex:indexPath.row];
    [self confirmAddMealToLog:dict];
}

@end
