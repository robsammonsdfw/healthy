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
#import "DMMealPlanDataProvider.h"
#import "DMMealPlan.h"

@interface MealPlanViewController() <SFSafariViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *selectedRows;
@property (nonatomic) BOOL isChoosingForGroceryList;
@property (nonatomic, strong) UIBarButtonItem *aBarButtonItem;
@property (nonatomic, strong) NSMutableArray<DMMealPlan *> *mealPlanArray;
@end

static NSString *CellIdentifier = @"Cell";

@implementation MealPlanViewController

#pragma mark VIEW LIFECYCLE

- (instancetype)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _selectedRows = [[NSMutableArray alloc] init];
        _isChoosingForGroceryList = NO;
        _mealPlanArray = [NSMutableArray array];
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
    
    [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:0].active = YES;
    [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:0].active = YES;
    [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:0].active = YES;
    [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:0].active = YES;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"My Meals";
    [self.navigationItem setTitle:@"My Meals"];

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
    self.aBarButtonItem.tintColor = AppConfiguration.headerTextColor;
    [self.navigationItem setRightBarButtonItem:self.aBarButtonItem];

    if ([AppConfiguration.accountCode isEqualToString:@"ezdietplanner"]) {
        UIImageView *backgroundImage = (UIImageView *)[self.view viewWithTag:501];
        backgroundImage.image = [UIImage imageNamed:@"My_Plan_Background"];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
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
        [self.navigationItem setRightBarButtonItem:self.aBarButtonItem];
        [self.navigationItem setLeftBarButtonItem:nil];
    } else {
        UIBarButtonItem *aBarButtonItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(loadGroceryList)];
        aBarButtonItem2.tintColor = AppConfiguration.headerTextColor;
        [self.navigationItem setRightBarButtonItem:aBarButtonItem2];
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(showGroceryList)];
        cancelButton.tintColor = AppConfiguration.headerTextColor;
        [self.navigationItem setLeftBarButtonItem:cancelButton];
    }
    
    self.isChoosingForGroceryList = !self.isChoosingForGroceryList;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)loadGroceryList {
    [DMActivityIndicator showActivityIndicator];

    // Create an array of MealIDs to send to fetcher.
    NSMutableArray *mealIDArray = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in [self.selectedRows copy]) {
        DMMealPlan *mealPlan = self.mealPlanArray[indexPath.row];
        NSDictionary *idDict = @{ @"MealID" : mealPlan.mealId };
        [mealIDArray addObject:idDict];
    }
        
    DMMealPlanDataProvider *provider = [[DMMealPlanDataProvider alloc] init];
    [provider fetchGroceryListForMealItems:[mealIDArray copy] withCompletionBlock:^(NSObject *object, NSError *error) {
        [DMActivityIndicator hideActivityIndicator];
        if (error) {
            [DMGUtilities showAlertWithTitle:@"Error" message:error.localizedDescription inViewController:nil];
            return;
        }

        NSArray *responseArray = (NSArray *)object;
        NSMutableArray *groceryItems = [NSMutableArray array];
        for (NSDictionary *dict in responseArray) {
            NSArray *foods = [dict valueForKey:@"CategoryItems"];
            if (foods.count) {
                foods = [provider getGroceryFoodDetailsForFoods:[foods copy]];
            }
            NSMutableDictionary *mutableDict = [dict mutableCopy];
            mutableDict[@"CategoryItems"] = [foods copy];
            [groceryItems addObject:[mutableDict copy]];
        }
        [provider saveGroceryList:[groceryItems copy]];
        GroceryListViewController *groceryListVC = [[GroceryListViewController alloc] init];
        [self.navigationController pushViewController:groceryListVC animated:YES];
        [self showGroceryList];
    }];
}

- (void)loadData {
    if ([NSThread isMainThread]) {
        DMMealPlanDataProvider *provider = [[DMMealPlanDataProvider alloc] init];
        [DMActivityIndicator showActivityIndicator];
        [provider fetchUserPlannedMealsWithCompletionBlock:^(NSObject *object, NSError *error) {
            [DMActivityIndicator hideActivityIndicator];
            [self.mealPlanArray removeAllObjects];
            if (error) {
                [DMGUtilities showAlertWithTitle:@"Error" message:error.localizedDescription inViewController:nil];
                return;
            }
            NSArray *results = (NSArray *)object;
            [self.mealPlanArray addObjectsFromArray:results];
            [[self tableView] reloadData];
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadData];
        });
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MAX(self.mealPlanArray.count, 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!self.mealPlanArray.count) {
        cell.textLabel.text = @"Contact your program provider regarding meal plans";
        cell.textLabel.textColor = [UIColor blackColor];
        
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:16.0];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.highlightedTextColor = [UIColor blackColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.accessoryView = nil;
        return cell;
    }
    
    DMMealPlan *mealPlan = self.mealPlanArray[indexPath.row];
    cell.textLabel.text = mealPlan.mealName;
    cell.textLabel.font = [UIFont systemFontOfSize:16.0];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.highlightedTextColor = [UIColor whiteColor];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.textColor = [UIColor blackColor];

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
    } else {
        cell.accessoryView = nil;
    }
  
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isChoosingForGroceryList) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIImage *image = nil;
        if ([[self.selectedRows copy] containsObject:indexPath]) {
            [self.selectedRows removeObject:indexPath];
            image = [UIImage imageNamed:@"checkmark_off"];
        } else {
            [self.selectedRows addObject:indexPath];
            image = [UIImage imageNamed:@"checkmark"];
        }
        
        UIButton *button = (UIButton *)cell.accessoryView;
        [button setImage:image forState:UIControlStateNormal];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        DMMealPlan *mealPlan = self.mealPlanArray[indexPath.row];
        MealPlanDetailViewController *detailVC = [[MealPlanDetailViewController alloc] initWithMealPlan:mealPlan];
        [self.navigationController pushViewController:detailVC animated:YES];
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
}

- (void)getGroceryListFailed:(NSString *)failedMessage {
    [DMActivityIndicator hideActivityIndicator];

    [DMGUtilities showAlertWithTitle:@"Oops!" message:@"An error occurred! Please try again." inViewController:nil];
}

#pragma mark ACTION SHEET METHODS

- (void)showActionSheet:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Action" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    [alert addAction:[UIAlertAction actionWithTitle:@"New Grocery List"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self showGroceryList];
    }]];
    
    DMMealPlanDataProvider *provider = [[DMMealPlanDataProvider alloc] init];
    if ([provider getSavedGroceryList].count) {
        NSString *buttonString = @"View Last Saved List";
        [alert addAction:[UIAlertAction actionWithTitle:buttonString
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            GroceryListViewController *viewController = [[GroceryListViewController alloc] init];
            [self.navigationController pushViewController:viewController animated:YES];
        }]];
    }

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

@end
