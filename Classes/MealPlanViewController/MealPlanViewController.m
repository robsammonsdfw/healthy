//
//  MealPlanViewController.m
//  DietMasterGo
//
//  Created by Henry Kirk on 6/1/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

@import SafariServices;
#import "MealPlanViewController.h"
#import "DietmasterEngine.h"
#import "MealPlanDetailViewController.h"
#import "GroceryListViewController.h"
#import "AppSettings.h"
#import "PopUpView.h"
#import "MyMovesViewController.h"

@interface MyLogViewController ()<GotoViewControllerDelegate, SFSafariViewControllerDelegate> {
}
@end
@implementation MealPlanViewController{
    UIBarButtonItem *aBarButtonItem;
}

@synthesize soapWebService;

-(id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle {
    return [self init];
}

-(id)init {
    self = [super initWithNibName:@"MealPlanViewController" bundle:nil];
    return self;
}

-(IBAction)goToSafetyGuidelines:(id)sender {
    SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://advancedwebservicegroup.com/AWSGDocuments/GuidelinesAndSafety.html"]];
    [self presentViewController:sfvc animated:YES completion:nil];
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark VIEW LIFECYCLE
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"changeDesign"]  isEqual: @"NewDesign"])
    {
        self.showPopUpVw.hidden = false;
    }
    else
    {
        self.showPopUpVw.hidden = true;
    }
    
    [self.navigationController setNavigationBarHidden:NO];

    _imgbg.backgroundColor=[UIColor whiteColor];
    
    self.navigationItem.title=@"My Meals";
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.tableView setBackgroundView:nil];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStylePlain
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    [backButton release];
    
    aBarButtonItem = [[UIBarButtonItem alloc] initWithImage:
                      [UIImage imageNamed:@"80-shopping-cart"]
                                                      style:UIBarButtonItemStylePlain
                                                     target:self action:@selector(showActionSheet:)];
    aBarButtonItem.tintColor=[UIColor whiteColor];
    [self.navigationItem setLeftBarButtonItem:aBarButtonItem];
    [aBarButtonItem release];
    
    selectedRows = [[NSMutableArray alloc] init];
    isChoosingForGroceryList = NO;
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:PLIST_NAME];
    NSDictionary *appDefaults = [[[NSDictionary alloc] initWithContentsOfFile:finalPath] autorelease];
    
    UIImageView *backgroundImage = (UIImageView *)[self.view viewWithTag:501];
    if ([[appDefaults valueForKey:@"account_code"] isEqualToString:@"ezdietplanner"]) {
        backgroundImage.image = [UIImage imageNamed:@"My_Plan_Background"];
    }
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.navigationController.navigationBar setTranslucent:NO];
    
//    UIImage *btnImage1 = [[UIImage imageNamed:@"set32.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn1.bounds = CGRectMake( 0, 0, btnImage1.size.width, btnImage1.size.height );
//    btn1.tintColor = [UIColor whiteColor];
//    [btn1 addTarget:self action:@selector(showSettings:) forControlEvents:UIControlEventTouchDown];
//    [btn1 setImage:btnImage1 forState:UIControlStateNormal];
//    
//    UIBarButtonItem * settingsBtn = [[UIBarButtonItem alloc] initWithCustomView:btn1];
//    self.navigationItem.rightBarButtonItem = settingsBtn;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.isMovingFromParentViewController) {
        [[self navigationController] setNavigationBarHidden:YES animated:YES];
    }
}

-(IBAction)showSettings:(id)sender {
    
    AppSettings *appVC = [[AppSettings alloc]initWithNibName:@"AppSettings" bundle:nil];
    appVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:appVC animated:YES];
    
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"changeDesign"]  isEqual: @"NewDesign"])
       {
           self.showPopUpVw.hidden = false;
       }
       else
       {
           self.showPopUpVw.hidden = true;
       }
       [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    if ([dietmasterEngine.mealPlanArray count] == 0) {
        [self startLoading];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    selectedRows = nil;
}

#pragma mark GROCERY LIST
-(void)showGroceryList {
    if (isChoosingForGroceryList) {
        isChoosingForGroceryList = NO;
        UIBarButtonItem *aBarButtonItem1 = [[UIBarButtonItem alloc] initWithImage:
                                            [UIImage imageNamed:@"80-shopping-cart"]
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self action:@selector(showActionSheet:)];
        
        [self.navigationItem setRightBarButtonItem:aBarButtonItem1];
        [aBarButtonItem1 release];
        
        [self.navigationItem setLeftBarButtonItem:nil];
    }
    else {
        isChoosingForGroceryList = YES;
        
        UIBarButtonItem *aBarButtonItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(loadGroceryList)];
        [self.navigationItem setRightBarButtonItem:aBarButtonItem2];
        [aBarButtonItem2 release];
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(showGroceryList)];
        [self.navigationItem setLeftBarButtonItem:cancelButton];
        [cancelButton release];
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

-(void)loadGroceryList {
    [self showLoading];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *mealIDArray = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in selectedRows) {
        
        NSMutableDictionary *mealIDDict = [[NSMutableDictionary alloc] init];
        DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
        NSDictionary *tempDict = [[NSDictionary alloc] initWithDictionary:[dietmasterEngine.mealPlanArray objectAtIndex:[indexPath row]]];
        [mealIDDict setValue:[tempDict valueForKey:@"MealID"] forKey:@"MealID"];
        [mealIDArray addObject:mealIDDict];
        [tempDict release];
        [mealIDDict release];
    }
    
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"GetGroceryList", @"RequestType",
                              [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                              [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                              mealIDArray, @"GroceryItems",
                              nil];
    
    self.soapWebService = [[MealPlanWebService alloc] init];
    soapWebService.wsGetGroceryList = self;
    [soapWebService callWebservice:infoDict];
    [soapWebService release];
    
    [mealIDArray release];
    [infoDict release];
}

#pragma mark LOAD DATA METHODS
-(void)loadData {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"GetUserPlannedMealNames", @"RequestType",
                              [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                              [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                              nil];
    
    self.soapWebService = [[MealPlanWebService alloc] init];
    soapWebService.wsGetUserPlannedMealNames = self;
    [soapWebService callWebservice:infoDict];
    [soapWebService release];
    
    [infoDict release];
}

#pragma mark TABLE VIEW METHODS
- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    
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
    return 48;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    return ([dietmasterEngine.mealPlanArray count] > 0 ? [dietmasterEngine.mealPlanArray count] : 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];

        UIImageView * rowCellImgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"row_Silver.png"]] autorelease];
        rowCellImgView.tintColor = PrimaryColor;
        
        cell.backgroundView = rowCellImgView;
    }
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    
    if ([dietmasterEngine.mealPlanArray count] > 0) {
        
        NSDictionary *tempDict = [[NSDictionary alloc] initWithDictionary:[dietmasterEngine.mealPlanArray objectAtIndex:[indexPath row]]];
        
        cell.textLabel.text			= [tempDict valueForKey:@"MealName"];
        cell.textLabel.textColor = [UIColor whiteColor];
        
        [cell textLabel].adjustsFontSizeToFitWidth = YES;
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.textLabel.minimumScaleFactor = 10.0f;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
        
        if (isChoosingForGroceryList) {
            UIImage *image = nil;
            if ([selectedRows containsObject:indexPath]) {
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
        
        [tempDict release];
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
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    
    if ([dietmasterEngine.mealPlanArray count] > 0) {
        if (isChoosingForGroceryList) {
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            UIImage *image = nil;
            if ([selectedRows containsObject:indexPath]) {
                [selectedRows removeObject:indexPath];
                image = [UIImage imageNamed:@"checkmark_off"];
            }
            else {
                [selectedRows addObject:indexPath];
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
            [detailVC release];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
    else {
        return;
    }
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}

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
    [self hideLoading];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    [dietmasterEngine.groceryArray removeAllObjects];
    
    for (id obj in responseArray) {
        NSMutableArray *foods = [obj valueForKey:@"CategoryItems"];
        foods = [dietmasterEngine getGroceryFoodDetails:foods];
    }
    
    [dietmasterEngine.groceryArray addObjectsFromArray:responseArray];
    
    GroceryListViewController *groceryListVC = [[GroceryListViewController alloc] init];
    [self.navigationController pushViewController:groceryListVC animated:YES];
    [groceryListVC release];
    
    [self showGroceryList];
}

- (void)getGroceryListFailed:(NSString *)failedMessage {
    [self hideLoading];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"An error occurred! Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert setTag:200];
    [alert show];
    [alert release];
}

#pragma mark GET MEAL PLAN NAME DELEGATES

- (void)getUserPlannedMealNamesFinished:(NSMutableArray *)responseArray {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    [dietmasterEngine.mealPlanArray removeAllObjects];
    [dietmasterEngine.mealPlanArray addObjectsFromArray:responseArray];
    
    [self stopLoading];
    [[self tableView] reloadData];
    
}
- (void)getUserPlannedMealNamesFailed:(NSString *)failedMessage {
    [self stopLoading];
    [[self tableView] reloadData];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"An error occurred. Please pull to refresh & try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert setTag:200];
    [alert show];
    [alert release];
}

#pragma mark PULL REFRESH METHODS
- (void)refresh {
    [self performSelector:@selector(loadData) withObject:nil afterDelay:1.0];
}

#pragma mark ACTION SHEET METHODS

-(void)showActionSheet:(id)sender {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    
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
        [popupQuery release];
    }
    else {
        
        return;
    }
}

#pragma mark ACTION SHEET DELEGATES
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 10) {
        if (buttonIndex == 0) {
            [self showGroceryList];
        }
        else if (buttonIndex == 1) {
            DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
            if ([dietmasterEngine.groceryArray count] > 0) {
                GroceryListViewController *groceryListVC = [[GroceryListViewController alloc] init];
                [self.navigationController pushViewController:groceryListVC animated:YES];
                [groceryListVC release];
            }
        }
    }
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
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
    HUD.mode = MBProgressHUDModeCustomView;
    
    HUD.delegate = nil;
    HUD.labelText = @"Completed";
    
    [HUD show:YES];
    [HUD hide:YES afterDelay:1.0];
}

- (void)dealloc {
    [_imgbg release];
    selectedRows = nil;
    [super dealloc];
}

- (IBAction)popUpBtn:(id)sender {
    PopUpView* popUpView = [[PopUpView alloc]initWithNibName:@"PopUpView" bundle:nil];
    popUpView.modalPresentationStyle = UIModalPresentationOverFullScreen;
    popUpView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    popUpView.gotoDelegate = self;
    _showPopUpVw.hidden = true;
    popUpView.vc = @"MealPlanViewController";
    [self presentViewController:popUpView animated:YES completion:nil];
}
-(void)DietMasterGoViewController
{
    DietMasterGoViewController *vc = [[DietMasterGoViewController alloc] initWithNibName:@"DietMasterGoViewController" bundle:nil];
    vc.title = @"Today";
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:false] ;
    [self RemovePreviousViewControllerFromStack];
}
-(void)MyGoalViewController
{
    MyGoalViewController *vc = [[MyGoalViewController alloc] initWithNibName:@"MyGoalViewController" bundle:nil];
    vc.title = @"My Goal";
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:false] ;
    [self RemovePreviousViewControllerFromStack];
}
- (void)MyLogViewController
{
    MyLogViewController *vc = [[MyLogViewController alloc] initWithNibName:@"MyLogViewController" bundle:nil];
    vc.title = @"My Log";
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:false] ;
    [self RemovePreviousViewControllerFromStack];
}

-(void)MealPlanViewController
{
    MealPlanViewController *vc = [[MealPlanViewController alloc] initWithNibName:@"MealPlanViewController" bundle:nil];
    vc.title = @"My Meals";
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:false] ;
    [self RemovePreviousViewControllerFromStack];
}
-(void)AppSettings
{
    AppSettings *vc = [[AppSettings alloc] initWithNibName:@"AppSettings" bundle:nil];
    vc.title = @"Settings";
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:false] ;
    [self RemovePreviousViewControllerFromStack];
}
-(void)MyMovesViewController
{
    MyMovesViewController *vc = [[MyMovesViewController alloc] initWithNibName:@"MyMovesViewController" bundle:nil];
    vc.title = @"MyMovesViewController";
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:false] ;
    [self RemovePreviousViewControllerFromStack];
}

-(void)RemovePreviousViewControllerFromStack
{
    NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];

    // [navigationArray removeAllObjects];    // This is just for remove all view controller from navigation stack.
    if (navigationArray.count > 2) {
        [navigationArray removeObjectAtIndex: 1];  // You can pass your index here
        self.navigationController.viewControllers = navigationArray;
        [navigationArray release];
    }
}

- (void)hideShowPopUpView
{
    self.showPopUpVw.hidden = false;
}
@end
