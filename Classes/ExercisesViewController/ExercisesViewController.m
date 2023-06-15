//
//  ExercisesViewController.m
//  DietMasterGo
//
//  Created by Henry Kirk on 1/28/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import "ExercisesViewController.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "DietmasterEngine.h"
#import "ExercisesDetailViewController.h"

@implementation ExercisesViewController

@synthesize tableView;
@synthesize mySearchBar, bSearchIsOn, searchType;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

-(id)init {
    if (self = [super initWithNibName:@"ExercisesViewController" bundle:nil]) {
    }
    return self;
}

#pragma mark SEARCH BAR METHODS
- (void) searchBar: (id) object {
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
        [self.tableView setContentOffset:CGPointMake(0,44)];
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

- (void) searchBarSearchButtonClicked:(UISearchBar*) theSearchBar {
    self.tableView.scrollEnabled = YES;
    [mySearchBar resignFirstResponder ];
    [self showLoading];
    [self performSelector:@selector(loadSearchData) withObject:theSearchBar.text afterDelay:0.25];
}

- (BOOL) searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    bSearchIsOn = YES;
    [self.tableView reloadData];
    return YES;
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
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
    
    bSearchIsOn = NO;
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    searchBar.text = @"";
    [self showLoading];
    [self performSelector:@selector(loadSearchData) withObject:@"" afterDelay:0.25];
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    if([searchText length] > 0) {
        bSearchIsOn = YES;
        self.tableView.scrollEnabled = NO;
    }
    else {
        bSearchIsOn = NO;
        self.tableView.scrollEnabled = YES;
    }
    
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

#pragma mark VIEW LIFECYCLE
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem* bi = [[UIBarButtonItem alloc]
                           initWithBarButtonSystemItem: UIBarButtonSystemItemSearch target:self action:@selector(searchBar:)];
    bi.style = UIBarButtonItemStylePlain;
    self.navigationItem.rightBarButtonItem = bi;
    [bi release];
    
    mySearchBar = [[UISearchBar alloc] init];
    mySearchBar.placeholder = @"Search";
    mySearchBar.delegate = self;
    [mySearchBar sizeToFit];
    self.bSearchIsOn = NO;
    mySearchBar.tintColor = [UIColor blackColor];
    mySearchBar.showsCancelButton = YES;
    [mySearchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [mySearchBar sizeToFit];
    
    self.tableView.tableHeaderView = mySearchBar;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    HUD.delegate = self;
    
    if (!searchResults) {
        searchResults = [[NSMutableArray alloc] init];
    }
    
    [self.navigationItem setTitle:@"Exercises"];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showLoading];
    [self performSelector:@selector(loadSearchData) withObject:mySearchBar.text afterDelay:0.25];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (bSearchIsOn) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        [self.tableView setContentOffset:CGPointMake(0,0)];
    }
    else {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        [self.tableView setContentOffset:CGPointMake(0,44)];
    }
}

#pragma mark DATA METHODS
-(void)loadSearchData {
    if (searchResults) {
        [searchResults removeAllObjects];
    }
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
        
    }
    
    NSString *query;
    if ([mySearchBar.text length] > 0) {
        query = [NSString stringWithFormat:@"SELECT ExerciseID,ActivityName,CaloriesPerHour FROM Exercises WHERE ActivityName LIKE '%%%@%%' ORDER BY ActivityName", mySearchBar.text];
    }
    else {
        query = @"SELECT ExerciseID,ActivityName,CaloriesPerHour FROM Exercises ORDER BY ActivityName";
    }
    
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [bundlePath stringByAppendingPathComponent:PLIST_NAME];
    NSDictionary *appDefaults = [[[NSDictionary alloc] initWithContentsOfFile:finalPath] autorelease];
    
    FMResultSet *rs = [db executeQuery:query];
    while ([rs next]) {
        NSNumber *exerciseID = [NSNumber numberWithInt:[rs intForColumn:@"ExerciseID"]];
        NSString *activityName = [[NSString alloc] initWithString:[rs stringForColumn:@"ActivityName"]];
        NSNumber *caloriesPerHour = [NSNumber numberWithDouble:[[rs stringForColumn:@"CaloriesPerHour"] doubleValue]];
        
        if (![[appDefaults valueForKey:@"account_code"] isEqualToString:@"42_onthego"]) {
            if ([exerciseID intValue] == 265 || [exerciseID intValue] == 266) {
                continue;
            }
        }
        
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              exerciseID, @"ExerciseID",
                              activityName, @"ActivityName",
                              caloriesPerHour, @"CaloriesPerHour",
                              nil];
        [searchResults addObject:dict];
        [dict release];
        [activityName release];
    }
    
    [rs close];
    
    [self hideLoading];
    [self.tableView reloadData];
}

#pragma mark TABLE VIEW METHODS
- (NSIndexPath *)tableView :(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return Nil;
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
        cell.userInteractionEnabled = NO;
        cell.accessoryView = nil;
    }
    
    if ([searchResults count] > 0) {
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        if (bSearchIsOn) {
            cell.userInteractionEnabled = YES;
        }
        else {
            cell.userInteractionEnabled = YES;
        }
        
        NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[searchResults objectAtIndex:indexPath.row]];
        
        DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
        double totalCaloriesBurned = [[dict valueForKey:@"CaloriesPerHour"] floatValue] * [dietmasterEngine.currentWeight floatValue];
        
        cell.textLabel.text = [dict valueForKey:@"ActivityName"];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Calories Burned Per Hour: %.2f",totalCaloriesBurned];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13.0];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle =  UITableViewCellSelectionStyleGray;
        [cell textLabel].adjustsFontSizeToFitWidth = NO;
        
        [dict release];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[searchResults objectAtIndex:indexPath.row]];
    [dietmasterEngine.exerciseSelectedDict setDictionary:dict];
    dietmasterEngine.taskMode = @"Save";
    
   //HHT apple watch
//    int exerciseIDTemp = [[dietmasterEngine.exerciseSelectedDict valueForKey:@"ExerciseID"] intValue];
//
//    if (exerciseIDTemp == 272 || exerciseIDTemp == 274){
//        if (exerciseIDTemp == 272) {
//            DMLog(@"Apple Calories");
//        }
//        else if (exerciseIDTemp == 274) {
//            DMLog(@"Apple Steps");
//        }
//    }
//    else {
//        ExercisesDetailViewController *eDVController = [[ExercisesDetailViewController alloc] init];
//        [self.navigationController pushViewController:eDVController animated:YES];
//        [eDVController release];
//    }
    
    ExercisesDetailViewController *eDVController = [[ExercisesDetailViewController alloc] init];
    [self.navigationController pushViewController:eDVController animated:YES];
    [eDVController release];
    [dict release];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//- (void)viewDidUnload {
//    [super viewDidUnload];
//    searchResults = nil;
//    mySearchBar = nil;
//    tableView = nil;
//}

- (void)dealloc {
    [searchType release];
    [searchResults release];
    searchResults = nil;
    mySearchBar = nil;
    tableView = nil;
    [super dealloc];
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
@end
