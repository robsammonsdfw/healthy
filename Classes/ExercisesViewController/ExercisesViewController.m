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

@interface ExercisesViewController() <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *mySearchBar;
@property (nonatomic, strong) NSMutableArray *searchResults;
@end

static NSString *CellIdentifier = @"Cell";

@implementation ExercisesViewController

#pragma mark VIEW LIFECYCLE

- (instancetype)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _searchResults = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.mySearchBar = [[UISearchBar alloc] init];
    self.mySearchBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.mySearchBar.placeholder = @"Search";
    self.mySearchBar.delegate = self;
    self.mySearchBar.showsCancelButton = YES;
    [self.mySearchBar setTranslucent:NO];
    [self.mySearchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.view addSubview:self.mySearchBar];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    [self.view addSubview:self.tableView];
    
    // Constrain.
    UILayoutGuide *layoutGuide = [self.view safeAreaLayoutGuide];
    [self.mySearchBar.topAnchor constraintEqualToAnchor:layoutGuide.topAnchor constant:0].active = YES;
    [self.mySearchBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:0].active = YES;
    [self.mySearchBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:0].active = YES;
    [self.tableView.topAnchor constraintEqualToAnchor:self.mySearchBar.bottomAnchor constant:0].active = YES;
    [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:0].active = YES;
    [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:0].active = YES;
    [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:0].active = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];

    [self.navigationItem setTitle:@"Exercises"];
    self.title = @"Exercises";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [DMActivityIndicator showActivityIndicator];
    [self loadSearchData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

#pragma mark UISearchBar

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    [self.mySearchBar resignFirstResponder];
    [DMActivityIndicator showActivityIndicator];
    [self loadSearchData];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self.tableView reloadData];
    return YES;
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [self.tableView reloadData];
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    self.tableView.scrollEnabled = YES;
    self.tableView.userInteractionEnabled = YES;
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.tableView setContentOffset:CGPointMake(0,0)];
    }];
        
    searchBar.text = @"";
    [DMActivityIndicator showActivityIndicator];
    [self loadSearchData];
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    [self loadSearchData];
}

#pragma mark DATA METHODS

-(void)loadSearchData {
    [self.searchResults removeAllObjects];
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
        
    }
    
    NSString *query;
    if ([self.mySearchBar.text length] > 0) {
        query = [NSString stringWithFormat:@"SELECT ExerciseID,ActivityName,CaloriesPerHour FROM Exercises WHERE ActivityName LIKE '%%%@%%' ORDER BY ActivityName", self.mySearchBar.text];
    }
    else {
        query = @"SELECT ExerciseID,ActivityName,CaloriesPerHour FROM Exercises ORDER BY ActivityName";
    }
    
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [bundlePath stringByAppendingPathComponent:PLIST_NAME];
    NSDictionary *appDefaults = [[NSDictionary alloc] initWithContentsOfFile:finalPath];
    
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
        [self.searchResults addObject:dict];
    }
    
    [rs close];
    
    [DMActivityIndicator hideActivityIndicator];
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
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *results = [self.searchResults copy];
    if ([results count] == 0) {
        return 1;
    } else {
        return [results count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 46;
}

- (UITableViewCell *)tableView:(UITableView *)myTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *results = [self.searchResults copy];

    UITableViewCell *cell = [myTableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    // Show empty cell if needed.
    if ([results count] == 0) {
        [cell textLabel].adjustsFontSizeToFitWidth = YES;
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
        cell.detailTextLabel.text = @"";
        [[cell textLabel] setText:@"No results found..."];
        cell.selectionStyle =  UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.userInteractionEnabled = NO;
        cell.accessoryView = nil;
        return cell;
    }
    
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[results objectAtIndex:indexPath.row]];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    double totalCaloriesBurned = [[dict valueForKey:@"CaloriesPerHour"] floatValue] * [dietmasterEngine.currentWeight floatValue];
    
    cell.textLabel.text = [dict valueForKey:@"ActivityName"];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Calories Burned Per Hour: %.2f",totalCaloriesBurned];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13.0];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle =  UITableViewCellSelectionStyleGray;
    [cell textLabel].adjustsFontSizeToFitWidth = NO;
    cell.userInteractionEnabled = YES;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *results = [self.searchResults copy];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[results objectAtIndex:indexPath.row]];
    [dietmasterEngine.exerciseSelectedDict setDictionary:dict];
    dietmasterEngine.taskMode = @"Save";
    
    ExercisesDetailViewController *eDVController = [[ExercisesDetailViewController alloc] init];
    [self.navigationController pushViewController:eDVController animated:YES];
}

@end
