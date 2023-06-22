//
//  MealPlanViewController.m
//  DietMasterGo
//
//  Created by Henry Kirk on 6/1/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import "MealPlanViewController.h"

@import SafariServices;
#import "DietmasterEngine.h"
#import "MealPlanDetailViewController.h"
#import "GroceryListViewController.h"
#import "MyMovesViewController.h"
#import "MealPlanWebService.h"

@interface MealPlanViewController() <SFSafariViewControllerDelegate, WSGetUserPlannedMealNames, WSGetGroceryList, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) MealPlanWebService *soapWebService;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *selectedRows;
@property (nonatomic) BOOL isChoosingForGroceryList;
@property (nonatomic, strong) UIBarButtonItem *aBarButtonItem;
@end

static NSString *CellIdentifier = @"Cell";

@implementation MealPlanViewController

#pragma mark VIEW LIFECYCLE

- (instancetype)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _selectedRows = [[NSMutableArray alloc] init];
        _isChoosingForGroceryList = NO;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.estimatedRowHeight = 48;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    [self.view addSubview:self.tableView];
    
    UILayoutGuide *guide = [self.view safeAreaLayoutGuide];
    [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:0].active = YES;
    [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:0].active = YES;
    [self.tableView.topAnchor constraintEqualToAnchor:guide.topAnchor constant:0].active = YES;
    [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:0].active = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStylePlain
                                   target: nil action: nil];
    [self.navigationItem setBackBarButtonItem: backButton];
    
    
    UIImage *shopCartImage = [UIImage imageNamed:@"80-shopping-cart"];
    shopCartImage = [shopCartImage imageWithTintColor:[UIColor whiteColor] renderingMode:UIImageRenderingModeAlwaysTemplate];
    self.aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:shopCartImage
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(showActionSheet:)];
    self.aBarButtonItem.tintColor = [UIColor whiteColor];
    [self.navigationItem setLeftBarButtonItem:self.aBarButtonItem];
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:PLIST_NAME];
    NSDictionary *appDefaults = [[NSDictionary alloc] initWithContentsOfFile:finalPath];
    UIImageView *backgroundImage = (UIImageView *)[self.view viewWithTag:501];
    if ([[appDefaults valueForKey:@"account_code"] isEqualToString:@"ezdietplanner"]) {
        backgroundImage.image = [UIImage imageNamed:@"My_Plan_Background"];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.title = @"My Meals";
    self.parentViewController.title = @"My Meals";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    if ([dietmasterEngine.mealPlanArray count] == 0) {
        [self loadData];
    }
}

#pragma mark - Safari

- (void)goToSafetyGuidelines:(id)sender {
    SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://advancedwebservicegroup.com/AWSGDocuments/GuidelinesAndSafety.html"]];
    [self presentViewController:sfvc animated:YES completion:nil];
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark GROCERY LIST

- (void)showGroceryList {
    if (self.isChoosingForGroceryList) {
        self.isChoosingForGroceryList = NO;
        [self.navigationItem setRightBarButtonItem:self.aBarButtonItem];
        [self.navigationItem setLeftBarButtonItem:nil];
    }
    else {
        self.isChoosingForGroceryList = YES;
        
        UIBarButtonItem *aBarButtonItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(loadGroceryList)];
        [self.navigationItem setRightBarButtonItem:aBarButtonItem2];
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(showGroceryList)];
        [self.navigationItem setLeftBarButtonItem:cancelButton];
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)loadGroceryList {
    [DMActivityIndicator showActivityIndicator];

    NSMutableArray *mealIDArray = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in [self.selectedRows copy]) {
        
        NSMutableDictionary *mealIDDict = [[NSMutableDictionary alloc] init];
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        NSDictionary *tempDict = [[NSDictionary alloc] initWithDictionary:[dietmasterEngine.mealPlanArray objectAtIndex:[indexPath row]]];
        [mealIDDict setValue:[tempDict valueForKey:@"MealID"] forKey:@"MealID"];
        [mealIDArray addObject:mealIDDict];
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"GetGroceryList", @"RequestType",
                              [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                              [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                              mealIDArray, @"GroceryItems",
                              nil];
    
    self.soapWebService = [[MealPlanWebService alloc] init];
    self.soapWebService.wsGetGroceryList = self;
    [self.soapWebService callWebservice:infoDict];
}

#pragma mark LOAD DATA METHODS

- (void)loadData {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"GetUserPlannedMealNames", @"RequestType",
                              [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                              [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                              nil];
    
    self.soapWebService = [[MealPlanWebService alloc] init];
    self.soapWebService.wsGetUserPlannedMealNames = self;
    [self.soapWebService callWebservice:infoDict];
}

#pragma mark TABLE VIEW METHODS
- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    if ([dietmasterEngine.mealPlanArray count] > 0) {
        return indexPath;
    }
    else {
        return nil;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    NSArray *planArray = [dietmasterEngine.mealPlanArray copy];
    return MAX(planArray.count, 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    NSArray *planArray = [dietmasterEngine.mealPlanArray copy];

    if ([planArray count] > 0) {
        
        NSDictionary *tempDict = [[NSDictionary alloc] initWithDictionary:[planArray objectAtIndex:[indexPath row]]];
        
        cell.textLabel.text = [tempDict valueForKey:@"MealName"];
        cell.textLabel.textColor = [UIColor whiteColor];
        
        [cell textLabel].adjustsFontSizeToFitWidth = YES;
        cell.textLabel.font = [UIFont systemFontOfSize:16.0];
        cell.textLabel.minimumScaleFactor = 12.0f;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
        
        if (self.isChoosingForGroceryList) {
            UIImage *image = nil;
            if ([[self.selectedRows copy] containsObject:indexPath]) {
                image = [UIImage imageNamed:@"checkmark"];
            } else {
                image = [UIImage imageNamed:@"checkmark_off"];
            }
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            CGRect frame = CGRectMake(0.0, 0.0, 28, 28);
            button.frame = frame;
            [button setBackgroundImage:image forState:UIControlStateNormal];
            
            [button addTarget:self action:@selector(checkButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor = [UIColor clearColor];
            cell.accessoryView = button;
        }
        else {
            cell.accessoryView = nil;
        }
    }
    else {
        cell.textLabel.text = @"Contact your program provider regarding meal plans";
        cell.textLabel.textColor = [UIColor blackColor];
        
        [cell textLabel].adjustsFontSizeToFitWidth = YES;
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.textLabel.minimumScaleFactor = 10.0f;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.highlightedTextColor = [UIColor blackColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.accessoryView = nil;
    }
    
    cell.textLabel.textColor = PrimaryFontColor;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    NSArray *planArray = [dietmasterEngine.mealPlanArray copy];

    if ([planArray count] > 0) {
        if (self.isChoosingForGroceryList) {
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            UIImage *image = nil;
            if ([[self.selectedRows copy] containsObject:indexPath]) {
                [self.selectedRows removeObject:indexPath];
                image = [UIImage imageNamed:@"checkmark_off"];
            }
            else {
                [self.selectedRows addObject:indexPath];
                image = [UIImage imageNamed:@"checkmark"];
            }
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            CGRect frame = CGRectMake(0.0, 0.0, 28, 28);
            button.frame = frame;
            [button setBackgroundImage:image forState:UIControlStateNormal];
            
            [button addTarget:self action:@selector(checkButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor = [UIColor clearColor];
            cell.accessoryView = button;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else {
            MealPlanDetailViewController *detailVC = [[MealPlanDetailViewController alloc] init];
            detailVC.selectedIndex = (int)indexPath.row;
            [self.navigationController pushViewController:detailVC animated:YES];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

#pragma mark CHECKMARK ACTION

- (void)checkButtonTapped:(id)sender event:(id)event {
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
    if (indexPath != nil) {
        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    }
}

#pragma mark GROCERY LIST DELEGATES

- (void)getGroceryListFinished:(NSMutableArray *)responseArray {
    [DMActivityIndicator hideActivityIndicator];

    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    [dietmasterEngine.groceryArray removeAllObjects];
    
    for (id obj in responseArray) {
        NSMutableArray *foods = [obj valueForKey:@"CategoryItems"];
        foods = [dietmasterEngine getGroceryFoodDetails:foods];
    }
    
    [dietmasterEngine.groceryArray addObjectsFromArray:responseArray];
    
    GroceryListViewController *groceryListVC = [[GroceryListViewController alloc] init];
    [self.navigationController pushViewController:groceryListVC animated:YES];
    
    [self showGroceryList];
}

- (void)getGroceryListFailed:(NSString *)failedMessage {
    [DMActivityIndicator hideActivityIndicator];

    [DMGUtilities showAlertWithTitle:@"Oops!" message:@"An error occurred! Please try again." inViewController:nil];
}

#pragma mark GET MEAL PLAN NAME DELEGATES

- (void)getUserPlannedMealNamesFinished:(NSArray *)responseArray {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    [dietmasterEngine.mealPlanArray removeAllObjects];
    [dietmasterEngine.mealPlanArray addObjectsFromArray:responseArray];
    
    [[self tableView] reloadData];
}

- (void)getUserPlannedMealNamesFailed:(NSError *)error {
    [[self tableView] reloadData];
    
    [DMGUtilities showError:error withTitle:@"Error" message:@"An error occurred! Please try again." inViewController:nil];
}

#pragma mark ACTION SHEET METHODS

- (void)showActionSheet:(id)sender {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    if ([dietmasterEngine.mealPlanArray count] > 0) {
        NSString *buttonString = nil;
        if ([dietmasterEngine.groceryArray count] > 0) {
            buttonString = @"View Saved List";
        }
        UIActionSheet *popupQuery;
        
        popupQuery = [[UIActionSheet alloc] initWithTitle:@"Select Action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"New Grocery List", buttonString, nil];
        
        popupQuery.tag = 10;
        popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [popupQuery showInView:[UIApplication sharedApplication].keyWindow];
        
    }
}

#pragma mark ACTION SHEET DELEGATES

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 10) {
        if (buttonIndex == 0) {
            [self showGroceryList];
        }
        else if (buttonIndex == 1) {
            DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
            if ([dietmasterEngine.groceryArray count] > 0) {
                GroceryListViewController *groceryListVC = [[GroceryListViewController alloc] init];
                [self.navigationController pushViewController:groceryListVC animated:YES];
            }
        }
    }
}

@end
