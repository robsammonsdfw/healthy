//
//  GroceryListViewController.m
//  DietMasterGo
//
//  Created by Henry Kirk on 6/13/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import "GroceryListViewController.h"

#import "DietmasterEngine.h"
#import <QuartzCore/QuartzCore.h>
#import "MealPlanDetailsTableViewCell.h"

@implementation GroceryListViewController
@synthesize selectedIndex, tableView;

-(id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle {
    return [self init];
}

-(id)init {
    self = [super initWithNibName:@"GroceryListViewController" bundle:nil];
    selectedIndex = 0;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.title = @"Grocery List";
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    _imgBackground.backgroundColor = PrimaryColor
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStylePlain
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    NSDictionary *tempDict = [[NSDictionary alloc] initWithDictionary:[dietmasterEngine.mealPlanArray objectAtIndex:selectedIndex]];
    titleLabel.text = [tempDict valueForKey:@"MealName"];
    
    selectedRows = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *aBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editGroceryList)];
    [self.navigationItem setRightBarButtonItem:aBarButtonItem];
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:PLIST_NAME];
    NSDictionary *appDefaults = [[NSDictionary alloc] initWithContentsOfFile:finalPath];
    
    UIImageView *backgroundImage = (UIImageView *)[self.view viewWithTag:501];
    if ([[appDefaults valueForKey:@"account_code"] isEqualToString:@"ezdietplanner"]) {
        backgroundImage.image = [UIImage imageNamed:@"My_Plan_Background"];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    if (dietmasterEngine.didInsertNewFood == YES) {
        dietmasterEngine.didInsertNewFood = NO;
        [DMActivityIndicator showActivityIndicator];
    }
}

#pragma mark EDIT GROCERY LIST METHODS
-(void)editGroceryList {
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

#pragma mark LOAD DATA METHODS

-(void)loadData {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"GetGroceryList", @"RequestType",
                              [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                              [NSNumber numberWithInt:dietmasterEngine.selectedMealPlanID], @"MealID",
                              @"false", @"Planned",
                              [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                              nil];
    
    MealPlanWebService *soapWebService = [[MealPlanWebService alloc] init];
    soapWebService.wsGetGroceryList = self;
    [soapWebService callWebservice:infoDict];
}

#pragma mark TABLE VIEW METHODS
- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    return [dietmasterEngine.groceryArray count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    NSDictionary *categoryDict = [[NSDictionary alloc] initWithDictionary:[dietmasterEngine.groceryArray objectAtIndex:section]];
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(10, 10, 295, 18);
    label.textColor = [UIColor blackColor];
    label.font = [UIFont boldSystemFontOfSize:17.0];
    label.text = [NSString stringWithString:[categoryDict valueForKey:@"CategoryName"]];
    label.backgroundColor = [UIColor clearColor];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 28)];
    [view addSubview:label];
    
    return view;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    NSDictionary *categoryDict = [[NSDictionary alloc] initWithDictionary:[dietmasterEngine.groceryArray objectAtIndex:section]];
    NSArray *itemsArray = [[NSArray alloc] initWithArray:[categoryDict valueForKey:@"CategoryItems"]];
    
    return [itemsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)myTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MealPlanDetailsTableViewCell";
    MealPlanDetailsTableViewCell *cell = (MealPlanDetailsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MealPlanDetailsTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"row_Silver2.png"]];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"row_Silver_on2.png"]];
    }
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    //HHT Change (Temp)
    if (dietmasterEngine.groceryArray.count >0){
        NSDictionary *categoryDict = [[NSDictionary alloc] initWithDictionary:[dietmasterEngine.groceryArray objectAtIndex:[indexPath section]]];
        NSArray *itemsArray = [[NSArray alloc] initWithArray:[categoryDict valueForKey:@"CategoryItems"]];
        NSDictionary *tempDict = [[NSDictionary alloc] initWithDictionary:[itemsArray objectAtIndex:[indexPath row]]];
        
        NSString *foodName = [tempDict valueForKey:@"FoodName"];
        cell.lblMealName.text = foodName;
        
        NSNumber *foodCategory = [tempDict valueForKey:@"CategoryID"];
        NSRange r = [foodName rangeOfString:foodName];
        
        if ([foodCategory intValue] == 66) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *hostname = [prefs stringForKey:@"HostName"];
            NSNumber *recipeID = [tempDict valueForKey:@"RecipeID"];
            
            if (hostname != nil && ![hostname isEqualToString:@""] && recipeID != nil && [recipeID intValue] > 0) {
                cell.userInteractionEnabled = YES;
                cell.lblMealName.delegate = self;
                NSString *url = [NSString stringWithFormat:@"%@/PDFviewer.aspx?ReportName=CustomRecipe&ID=%@", hostname, recipeID];
                [cell.lblMealName addLinkToURL:[NSURL URLWithString:url] withRange:r];
            }
            
        } else {
            NSString *foodURL = [tempDict valueForKey:@"FoodURL"];
            if (foodURL != nil && ![foodURL isEqualToString:@""]) {
                cell.userInteractionEnabled = YES;
                cell.lblMealName.delegate = self;
                [cell.lblMealName addLinkToURL:[NSURL URLWithString:foodURL] withRange:r];
            } else {
                cell.lblMealName.delegate = nil;
            }
        }
        
        cell.lblMealName.textColor = [UIColor blackColor];
        cell.lblServingSize.text = [NSString stringWithFormat:@"Serving: %.2f - %@", [[tempDict valueForKey:@"NumberOfServings"] doubleValue], [tempDict valueForKey:@"Description"]];
        
        [cell lblMealName].adjustsFontSizeToFitWidth = YES;
        cell.lblMealName.font = [UIFont systemFontOfSize:15.0];
        cell.lblMealName.minimumScaleFactor = 10.0f;
        cell.lblServingSize.font = [UIFont systemFontOfSize:13.0];
        cell.lblServingSize.textColor = [UIColor darkGrayColor];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.lblMealName.lineBreakMode = NSLineBreakByTruncatingTail;
        
        cell.backgroundColor = [UIColor clearColor];
        
        UIImage *image = nil;
        if ([selectedRows containsObject:[tempDict valueForKey:@"FoodName"]]) {
            image = [UIImage imageNamed:@"checkmark"];
        }
        else {
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
    
    return cell;
}

- (void)tableView:(UITableView *)myTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    NSDictionary *categoryDict = [[NSDictionary alloc] initWithDictionary:[dietmasterEngine.groceryArray objectAtIndex:[indexPath section]]];
    NSArray *itemsArray = [[NSArray alloc] initWithArray:[categoryDict valueForKey:@"CategoryItems"]];
    NSDictionary *tempDict = [[NSDictionary alloc] initWithDictionary:[itemsArray objectAtIndex:[indexPath row]]];
    
    UITableViewCell *cell = [myTableView cellForRowAtIndexPath:indexPath];
    UIImage *image = nil;
    if ([selectedRows containsObject:[tempDict valueForKey:@"FoodName"]]) {
        [selectedRows removeObject:[tempDict valueForKey:@"FoodName"]];
        image = [UIImage imageNamed:@"checkmark_off"];
    }
    else {
        [selectedRows addObject:[tempDict valueForKey:@"FoodName"]];
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
    
    if ([selectedRows containsObject:[tempDict valueForKey:@"FoodName"]]) {
        [selectedRows removeObject:[tempDict valueForKey:@"FoodName"]];
        [self.tableView beginUpdates];
        
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        NSDictionary *categoryDict = [dietmasterEngine.groceryArray objectAtIndex:[indexPath section]];
        NSMutableArray *itemsArray = [categoryDict valueForKey:@"CategoryItems"];
        
        NSDictionary *tempItem = [[NSDictionary alloc] initWithDictionary:[itemsArray objectAtIndex:[indexPath row]]];
        
        [itemsArray removeObjectAtIndex:[indexPath row]];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [itemsArray addObject:tempItem];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:
                                                [NSIndexPath indexPathForRow:([itemsArray count]-1) inSection:[indexPath section]]]
                              withRowAnimation:UITableViewRowAnimationFade];
        
        [selectedRows addObject:[tempDict valueForKey:@"FoodName"]];
        [self.tableView endUpdates];
        [self.tableView reloadData];
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)tableView:(UITableView *)myTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [myTableView beginUpdates];
        
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        NSDictionary *categoryDict = [dietmasterEngine.groceryArray objectAtIndex:[indexPath section]];
        NSMutableArray *itemsArray = [categoryDict valueForKey:@"CategoryItems"];
        NSDictionary *tempDict = [[NSDictionary alloc] initWithDictionary:[itemsArray objectAtIndex:[indexPath row]]];
        
        [itemsArray removeObjectAtIndex:[indexPath row]];
        [selectedRows removeObject:[tempDict valueForKey:@"FoodName"]];
        
        [myTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [myTableView endUpdates];
        [myTableView reloadData];
        
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    //HHT change to remove BUG
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    NSDictionary *categoryDict = [dietmasterEngine.groceryArray objectAtIndex:[sourceIndexPath section]];
    NSMutableArray *itemsArray = [[categoryDict valueForKey:@"CategoryItems"]mutableCopy];
    
    NSObject *o = [itemsArray objectAtIndex:sourceIndexPath.row];
    
    //HHT change to solve Crash
    if(destinationIndexPath.row > sourceIndexPath.row) //moving a row down
        //for(int x = destinationIndexPath.row; x > sourceIndexPath.row; x--)
        //[itemsArray replaceObjectAtIndex:x-1 withObject:[itemsArray objectAtIndex:x]];
    {
        NSInteger x = destinationIndexPath.row;
        [itemsArray replaceObjectAtIndex:x+1 withObject:[itemsArray objectAtIndex:x]];
    }
    else
        //for(int x = destinationIndexPath.row; x < sourceIndexPath.row; x++)
        //[itemsArray replaceObjectAtIndex:x+1 withObject:[itemsArray objectAtIndex:x]];
    {
        NSInteger x = destinationIndexPath.row;
        [itemsArray replaceObjectAtIndex:x+1 withObject:[itemsArray objectAtIndex:x]];
    }
    
    [itemsArray replaceObjectAtIndex:destinationIndexPath.row withObject:o];
}

#pragma mark GET GROCERY LIST DELEGATES
- (void)getGroceryListFinished:(NSMutableArray *)responseArray {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    [dietmasterEngine.groceryArray removeAllObjects];
    [dietmasterEngine.groceryArray addObjectsFromArray:responseArray];
    
    [DMActivityIndicator hideActivityIndicator];
    [[self tableView] reloadData];
}

- (void)getGroceryListFailed:(NSString *)failedMessage {
    [DMActivityIndicator hideActivityIndicator];
    [[self tableView] reloadData];
    
    [DMGUtilities showAlertWithTitle:@"Error" message:@"An error occurred. Please try again.." inViewController:nil];
}

#pragma mark PULL REFRESH METHODS
- (void)refresh {
    [self performSelector:@selector(loadData) withObject:nil afterDelay:1.0];
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

#pragma mark - TTTAttributedLabel Delegate
//HHT to redirct on link click
- (void)attributedLabel:(__unused TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url];
}

@end
