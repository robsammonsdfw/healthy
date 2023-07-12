//
//  GroceryListViewController.m
//  DietMasterGo
//
//  Created by Henry Kirk on 6/13/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import "GroceryListViewController.h"

#import "DietmasterEngine.h"
#import "MealPlanDetailsTableViewCell.h"
#import "DMMealPlanDataProvider.h"
#import "TTTAttributedLabel.h"

@interface GroceryListViewController() <UITableViewDelegate, UITableViewDataSource, TTTAttributedLabelDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *selectedRows;
@property (nonatomic) int selectedIndex;
@property (nonatomic, strong) DMMealPlanDataProvider *dataProvider;
@property (nonatomic, strong) NSArray *groceryArray;
@end

static NSString *CellIdentifier = @"MealPlanDetailsTableViewCell";

@implementation GroceryListViewController

- (instancetype)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        _selectedIndex = 0;
        _selectedRows = [[NSMutableArray alloc] init];
        _dataProvider = [[DMMealPlanDataProvider alloc] init];
    }
    return self;
}

#pragma mark - Setter / Getters

- (NSArray *)groceryArray {
    NSArray *results = [self.dataProvider getSavedGroceryList];
    return results;
}

- (void)setGroceryArray:(NSArray *)groceryArray {
    [self.dataProvider saveGroceryList:[groceryArray copy]];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UINib *nib = [UINib nibWithNibName:@"MealPlanDetailsTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
    self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 50, 0);
    self.tableView.estimatedRowHeight = 60;
    self.tableView.estimatedSectionHeaderHeight = 40;
    
    self.title = @"Grocery List";
    self.navigationItem.title = @"Grocery List";
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setTranslucent:NO];

    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStylePlain
                                   target: nil action: nil];
    backButton.tintColor = AppConfiguration.headerTextColor;
    [self.navigationItem setBackBarButtonItem: backButton];
        
    UIBarButtonItem *aBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editGroceryList)];
    aBarButtonItem.tintColor = AppConfiguration.headerTextColor;
    [self.navigationItem setRightBarButtonItem:aBarButtonItem];
    
    if ([AppConfiguration.accountCode isEqualToString:@"ezdietplanner"]) {
        UIImageView *backgroundImage = (UIImageView *)[self.view viewWithTag:501];
        backgroundImage.image = [UIImage imageNamed:@"My_Plan_Background"];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];    
    [self.tableView reloadData];
}

- (void)editGroceryList {
    if (self.tableView.editing) {
        [self.tableView setEditing:NO animated:YES];
        [self.navigationItem.leftBarButtonItem setTitle:@"Edit"];
        self.navigationItem.leftBarButtonItem.style = UIBarButtonItemStylePlain;
    }
    else {
        [self.tableView setEditing:YES animated:YES];
        [self.navigationItem.leftBarButtonItem setTitle:@"Done"];
        self.navigationItem.leftBarButtonItem.style = UIBarButtonItemStyleDone;
    }
}

#pragma mark TableView Delegate/Datasource

- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = self.groceryArray.count;
    return count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSDictionary *categoryDict = [[self.groceryArray objectAtIndex:section] copy];
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(10, 5, 295, 23);
    label.textColor = AppConfiguration.headerTextColor;
    label.font = [UIFont boldSystemFontOfSize:17.0];
    label.text = [NSString stringWithString:[categoryDict valueForKey:@"CategoryName"]];
    label.backgroundColor = [UIColor clearColor];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 32)];
    view.backgroundColor = AppConfiguration.headerColor;
    [view addSubview:label];
    
    return view;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *categoryDict = [[self.groceryArray objectAtIndex:section] copy];
    NSArray *items = [categoryDict[@"CategoryItems"] copy];
    
    return [items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MealPlanDetailsTableViewCell *cell = (MealPlanDetailsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *categoryDict = [[self.groceryArray objectAtIndex:indexPath.section] copy];
    NSArray *items = [categoryDict[@"CategoryItems"] copy];
    NSDictionary *tempDict = [items[indexPath.row] copy];
    
    NSNumber *foodCategory = [tempDict valueForKey:@"CategoryID"];
    NSString *foodName = [tempDict valueForKey:@"FoodName"];
    NSURL *foodNameURL = nil;
    
    if ([foodCategory intValue] == 66) {
        NSString *hostname = [[DMAuthManager sharedInstance] loggedInUser].hostName;
        NSNumber *recipeID = [tempDict valueForKey:@"RecipeID"];
        
        if (hostname != nil && ![hostname isEqualToString:@""] && recipeID != nil && [recipeID intValue] > 0) {
            cell.userInteractionEnabled = YES;
            NSString *url = [NSString stringWithFormat:@"%@/PDFviewer.aspx?ReportName=CustomRecipe&ID=%@", hostname, recipeID];
            foodNameURL = [NSURL URLWithString:url];
        }
    } else {
        NSString *foodURLString = [tempDict valueForKey:@"FoodURL"];
        if (foodURLString.length) {
            cell.userInteractionEnabled = YES;
            foodNameURL = [NSURL URLWithString:foodURLString];
        }
    }
    
    if (foodNameURL) {
        NSRange range = NSMakeRange(0, foodName.length);
        [cell.lblMealName addLinkToURL:foodNameURL withRange:range];
        cell.lblMealName.delegate = self;
    } else {
        cell.lblMealName.delegate = nil;
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];

    cell.lblMealName.textColor = [UIColor blackColor];
    cell.lblMealName.font = [UIFont systemFontOfSize:16.0];
    cell.lblMealName.minimumScaleFactor = 10.0f;
    
    cell.lblServingSize.font = [UIFont systemFontOfSize:14.0];
    cell.lblServingSize.textColor = [UIColor darkGrayColor];
    cell.lblMealName.lineBreakMode = NSLineBreakByTruncatingTail;
         
    cell.lblMealName.text = foodName;
    cell.lblServingSize.text = [NSString stringWithFormat:@"Serving: %.2f - %@", [[tempDict valueForKey:@"NumberOfServings"] doubleValue], [tempDict valueForKey:@"Description"]];

    UIImage *image = nil;
    if ([self.selectedRows containsObject:[tempDict valueForKey:@"FoodName"]]) {
        image = [UIImage imageNamed:@"checkmark"];
    }
    else {
        image = [UIImage imageNamed:@"checkmark_off"];
    }

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0.0, 0.0, 28, 28);
    button.frame = frame;
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(checkButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor clearColor];
    cell.accessoryView = button;

    return cell;
}

- (void)tableView:(UITableView *)myTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *categoryDict = [[self.groceryArray objectAtIndex:indexPath.section] copy];
    NSArray *items = [categoryDict[@"CategoryItems"] copy];
    NSDictionary *tempDict = [items[indexPath.row] copy];
    NSString *foodName = [tempDict valueForKey:@"FoodName"];
    
    UITableViewCell *cell = [myTableView cellForRowAtIndexPath:indexPath];
    UIImage *image = nil;
    if ([self.selectedRows containsObject:foodName]) {
        [self.selectedRows removeObject:foodName];
        image = [UIImage imageNamed:@"checkmark_off"];
    }
    else {
        [self.selectedRows addObject:foodName];
        image = [UIImage imageNamed:@"checkmark"];
    }

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0.0, 0.0, 28, 28);
    button.frame = frame;
    [button setImage:image forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(checkButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor clearColor];
    cell.accessoryView = button;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)myTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [myTableView beginUpdates];
        NSMutableArray *mutableGroceryArray = [self.groceryArray mutableCopy];
        // Get dict at the section, e.g. "Beans, Lentils".
        NSMutableDictionary *sectionDict = [mutableGroceryArray[indexPath.section] mutableCopy];
        // Get the food items.
        NSMutableArray *foodItems = [sectionDict[@"CategoryItems"] mutableCopy];

        NSDictionary *foodDict = foodItems[indexPath.row];
        if ([self.selectedRows containsObject:[foodDict valueForKey:@"FoodName"]]) {
            [self.selectedRows removeObject:[foodDict valueForKey:@"FoodName"]];
        }

        [foodItems removeObjectAtIndex:indexPath.row];
        sectionDict[@"CategoryItems"] = [foodItems copy];
        // Shove the mutated items back into the array.
        [mutableGroceryArray replaceObjectAtIndex:indexPath.section withObject:[sectionDict copy]];

        [self.dataProvider saveGroceryList:[mutableGroceryArray copy]];

        [myTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [myTableView endUpdates];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark GET GROCERY LIST DELEGATES

- (void)getGroceryListFinished:(NSMutableArray *)responseArray {
    self.groceryArray = [responseArray copy];
    [DMActivityIndicator hideActivityIndicator];
    [[self tableView] reloadData];
}

- (void)getGroceryListFailed:(NSString *)failedMessage {
    [DMActivityIndicator hideActivityIndicator];
    [[self tableView] reloadData];
    
    [DMGUtilities showAlertWithTitle:@"Error" message:@"An error occurred. Please try again.." inViewController:nil];
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

#pragma mark - TTTAttributedLabel Delegate

- (void)attributedLabel:(__unused TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

@end
