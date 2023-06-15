//
//  FavoriteMealsViewController.m
//  DietMasterGo
//
//  Created by Henry Kirk on 2/8/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import "FavoriteMealsViewController.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "DietmasterEngine.h"

@implementation FavoriteMealsViewController

@synthesize tableView;
@synthesize searchType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(id)init {
    self = [super initWithNibName:@"FavoriteMealsViewController" bundle:nil];
    return self;
}

#pragma mark VIEW LIFECYCLE
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    HUD.delegate = self;
    
    if (!searchResults) {
        searchResults = [[NSMutableArray alloc] init];
    }
    
    [self.navigationItem setTitle:@"Favorite Meals"];
    rowToSaveToLog = -1;
    [self.navigationController.navigationBar setTranslucent:NO];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showLoading];
    [self performSelector:@selector(loadSearchData:) withObject:nil afterDelay:0.25];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//- (void)viewDidUnload {
//    [super viewDidUnload];
//    searchResults = nil;
//    tableView = nil;
//}

- (void)dealloc {
    [searchType release];
    [searchResults release];
    
    searchResults = nil;
    tableView = nil;

    [super dealloc];
}

#pragma mark DATA METHODS
-(void)loadSearchData:(NSString *)searchTerm {
    if (searchResults) {
        [searchResults removeAllObjects];
    }
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
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
                [dict2 release];
            }
            
            [foodName release];
        }
        
        [dict setValue:favFoodItemsArray forKey:@"Food_Items_Array"];
        
        if ([favFoodItemsArray count] > 0) {
            [searchResults addObject:dict];
        }
        [favFoodItemsArray release];
        
        [dict release];
        [favoriteMealName release];
    }
    
    [rs close];
    
    [self hideLoading];
    [self.tableView reloadData];
}

-(void) saveToLog:(id) sender {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
        
    }
    
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[searchResults objectAtIndex:rowToSaveToLog]];
    
    for (NSDictionary *dict2 in [dict valueForKey:@"Food_Items_Array"]) {
        
        int num_measureID	= [[dict2 valueForKey:@"MeasureID"] intValue];
        double servingAmount = [[dict2 valueForKey:@"Servings"] floatValue];
        
        int foodID = [[dict2 valueForKey:@"FoodKey"] intValue];
        int mealCode = [dietmasterEngine.selectedMealID intValue];
      
        int mealIDValue = 0;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
                NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
                [dateFormat setTimeZone:systemTimeZone];
                NSString *date_Today = [dateFormat stringFromDate:dietmasterEngine.dateSelected];
//        [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]]; // Prevent adjustment to user's local time zone.
        
//        NSString *date_Today = [dateFormat stringFromDate:[NSDate date]];
        [dateFormat release];

        NSString *mealIDQuery = [NSString stringWithFormat:@"SELECT MealID FROM Food_Log WHERE (MealDate BETWEEN DATETIME('%@ 00:00:00') AND DATETIME('%@ 23:59:59'))", date_Today, date_Today];
        DMLog(@"mealIDQuery for DetailView is %@", mealIDQuery);
        FMResultSet *rsMealID = [db executeQuery:mealIDQuery];
        while ([rsMealID next]) {
            
            mealIDValue = [rsMealID intForColumn:@"MealID"];
        }
        [rsMealID close];
        
        int minIDvalue = 0;
        if (mealIDValue == 0) {
            NSString *idQuery = @"SELECT MIN(MealID) as MealID FROM Food_Log";
            FMResultSet *rsID = [db executeQuery:idQuery];
            
            while ([rsID next]) {
                minIDvalue = [rsID intForColumn:@"MealID"];
            }
            
            [rsID close];
            minIDvalue = minIDvalue - 1;
            if (minIDvalue >=0) {
                int maxValue = minIDvalue;
                
                for (int i=0; i<=maxValue; i++) {
                    if (minIDvalue < 0){
                        break;
                    }
                    minIDvalue--;
                }
            }
        }
        
        if (mealIDValue > 0 || mealIDValue < 0) {
            minIDvalue = mealIDValue;
        }
        
        [db beginTransaction];
        
//        NSDate* sourceDate1 = dietmasterEngine.dateSelected;
//        NSDateFormatter *dateFormatter1 = [[[NSDateFormatter alloc] init] autorelease];
//        [dateFormatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//        NSTimeZone* systemTimeZone1 = [NSTimeZone systemTimeZone];
//        [dateFormatter1 setTimeZone:systemTimeZone1];
//        NSString *date_string1 = [dateFormatter1 stringFromDate:sourceDate1];
        
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        NSTimeZone* systemTimeZone1 = [NSTimeZone systemTimeZone];
        [dateFormatter setTimeZone:systemTimeZone1];
        NSString *date_string = [dateFormatter stringFromDate:dietmasterEngine.dateSelected];
        
        NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO Food_Log (MealID, MealDate) VALUES (%i, DATETIME('%@'))", minIDvalue, date_string];
        
        [db executeUpdate:insertSQL];
        
        int mealID = minIDvalue;
        
        NSDate* sourceDate = [NSDate date];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]]; // Prevent adjustment to user's local time zone.
        NSString *date_string1 = [dateFormatter stringFromDate:sourceDate];
        
        insertSQL = [NSString stringWithFormat: @"INSERT INTO Food_Log_Items "
                     "(MealID, FoodID, MealCode, MeasureID, NumberOfServings, LastModified) "
                     " VALUES (%i, %i, %i, %i, %f, DATETIME('%@'))",
                     mealID, foodID, mealCode, num_measureID, servingAmount, date_string1];
        
        [db executeUpdate:insertSQL];
        
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        
        [db commit];
    }
    
    [dict release];
    [self performSelector:@selector(showCompleted) withObject:nil afterDelay:0.25];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)deleteFromFavorites {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
        
    }
    
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[searchResults objectAtIndex:rowToSaveToLog]];
    
    int favoriteMealID	= [[dict valueForKey:@"Favorite_MealID"] intValue];
    
    [db beginTransaction];
    
    NSString *deleteSQL = [NSString stringWithFormat: @"DELETE FROM Favorite_Meal WHERE Favorite_MealID = %i",favoriteMealID];
    
    [db executeUpdate:deleteSQL];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
    
    [db beginTransaction];
    
    deleteSQL = [NSString stringWithFormat: @"DELETE FROM Favorite_Meal_Items WHERE Favorite_Meal_ID = %i",favoriteMealID];
    
    [db executeUpdate:deleteSQL];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
    [dict release];
    [self performSelector:@selector(loadSearchData:) withObject:nil afterDelay:0.10];
}

#pragma mark BUTTON ACTIONS
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 5) {
        if (buttonIndex == 0) {
            [self saveToLog:nil];
        }
        else if (buttonIndex == 1) {
            [self confirmRemoveFromLog];
        }
        else if (buttonIndex == 2) {
            rowToSaveToLog = -1;
        }
    }
    
    if (actionSheet.tag == 10) {
        if (buttonIndex == 0) {
            [self deleteFromFavorites];
        }
        else if (buttonIndex == 2) {
            rowToSaveToLog = -1;
        }
    }
}

#pragma mark ACTION SHEET METHODS
-(void)confirmAddToLog {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add to Log", @"Remove Favorite Meal", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    actionSheet.tag = 5;
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    [actionSheet release];
}

-(void)confirmRemoveFromLog {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Remove from Favorites?" delegate:self cancelButtonTitle:@"Don't Remove" destructiveButtonTitle:@"Yes, Remove" otherButtonTitles:nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    actionSheet.tag = 10;
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    [actionSheet release];
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
    if ([searchResults count] == 0) {
        return 1;
    }
    else {
        return [searchResults count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([searchResults count] == 0) {
        return 46;
    }
    
    if ([searchResults count] > 0) {
        
        NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[searchResults objectAtIndex:indexPath.row]];
        
        NSString *cellText = [dict valueForKey:@"Favorite_Meal_Name"];
        
        NSMutableString *foodItemsString = [NSMutableString stringWithString:@""];
        
        for (NSDictionary *dict2 in [dict valueForKey:@"Food_Items_Array"]) {
            
            NSString *nameString = [dict2 valueForKey:@"Name"];
            NSRange range = [nameString rangeOfString:@"\\s*$" options:NSRegularExpressionSearch];
            [nameString stringByReplacingCharactersInRange:range withString:@""];
            
            if ([nameString length] > 30) {
                
                NSRange stringRange = {0, MIN([nameString length], 30)};
                
                stringRange = [nameString rangeOfComposedCharacterSequencesForRange:stringRange];
                
                NSString *shortNameString = [nameString substringWithRange:stringRange];
                
                nameString = [NSString stringWithFormat:@"%@...",shortNameString];
                
            }
            double servings = [[dict2 valueForKey:@"Servings"] floatValue];
            if (servings == 0) {
                servings = 1.0;
            }
            [foodItemsString appendFormat:@"%.1f - %@ \n",servings, nameString];
            
        }
        [dict release];
        
        NSString *cellDetailText = foodItemsString;
        
        CGSize constraintSize = CGSizeMake(self.tableView.frame.size.width - 20.0, CGFLOAT_MAX);
//        CGSize labelSize = [cellText sizeWithFont:[UIFont systemFontOfSize:15.0] constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
//        CGSize detailSize = [cellDetailText sizeWithFont:[UIFont systemFontOfSize:13.0] constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
        
        NSStringDrawingOptions options = NSStringDrawingTruncatesLastVisibleLine |
                                         NSStringDrawingUsesLineFragmentOrigin;

        NSDictionary *attr = @{NSFontAttributeName: [UIFont systemFontOfSize:13.0]};
        CGRect detailSize = [cellDetailText boundingRectWithSize:constraintSize
                                                  options:options
                                               attributes:attr
                                                  context:nil];
        
        NSDictionary *attr1 = @{NSFontAttributeName: [UIFont systemFontOfSize:15.0]};
        CGRect labelSize = [cellText boundingRectWithSize:constraintSize
                                                  options:options
                                               attributes:attr1
                                                  context:nil];
        CGFloat result;
        result = MAX(46.0, labelSize.size.height + detailSize.size.height + 15.0);
//        result = MAX(46.0, labelSize.height + detailSize.height + 15.0);

        return result;
    }
    
    return 46;
}

- (UITableViewCell *)tableView:(UITableView *)myTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [myTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if ([searchResults count] == 0) {
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        [cell textLabel].adjustsFontSizeToFitWidth = YES;
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
        cell.detailTextLabel.text = @"";
        [[cell textLabel] setText:@"No results found..."];
        cell.selectionStyle =  UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.userInteractionEnabled = NO;
        cell.detailTextLabel.numberOfLines = 0;
        cell.accessoryView = nil;
    }
    
    if ([searchResults count] > 0) {
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[searchResults objectAtIndex:indexPath.row]];
        
        cell.textLabel.text = [dict valueForKey:@"Favorite_Meal_Name"];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13.0];
        cell.selectionStyle =  UITableViewCellSelectionStyleGray;
        [cell textLabel].adjustsFontSizeToFitWidth = NO;
        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.detailTextLabel.numberOfLines = 0;
        cell.userInteractionEnabled = YES;
        cell.textLabel.highlightedTextColor = [UIColor darkGrayColor];
        
        NSMutableString *foodItemsString = [NSMutableString stringWithString:@""];
        
        for (NSDictionary *dict2 in [dict valueForKey:@"Food_Items_Array"]) {
            
            NSString *nameString = [dict2 valueForKey:@"Name"];
            NSRange range = [nameString rangeOfString:@"\\s*$" options:NSRegularExpressionSearch];
            [nameString stringByReplacingCharactersInRange:range withString:@""];
            
            if ([nameString length] > 30) {
                NSRange stringRange = {0, MIN([nameString length], 30)};
                stringRange = [nameString rangeOfComposedCharacterSequencesForRange:stringRange];
                NSString *shortNameString = [nameString substringWithRange:stringRange];
                nameString = [NSString stringWithFormat:@"%@...",shortNameString];
            }
            
            double servings = [[dict2 valueForKey:@"Servings"] floatValue];
            
            if (servings == 0) {
                servings = 1.0;
            }
            [foodItemsString appendFormat:@"%.1f - %@ \n",servings, nameString];
        }
        
        cell.detailTextLabel.text = foodItemsString;
        UIImage *image = [UIImage imageNamed:@"05-plus.png"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = CGRectMake(0.0, 0.0, 13, 13);
        button.frame = frame;
        [button setBackgroundImage:image forState:UIControlStateNormal];
        [button addTarget:self action:@selector(checkButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor clearColor];
        cell.accessoryView = button;
        
        [dict release];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    rowToSaveToLog = [indexPath row];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self confirmAddToLog];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods
-(void)showLoading {
    HUD = [[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES] retain];
}

-(void)hideLoading {
    [HUD hide:YES afterDelay:0.5];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    [HUD removeFromSuperview];
    [HUD release];
    HUD = nil;
}

- (void)showCompleted {
    HUD = [[MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES] retain];
    HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
    HUD.mode = MBProgressHUDModeCustomView;
    
    HUD.delegate = nil;
    HUD.labelText = @"Completed";
    
    [HUD show:YES];
    [HUD hide:YES afterDelay:1.0];
}
@end
