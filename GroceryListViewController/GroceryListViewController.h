//
//  GroceryListViewController.h
//  DietMasterGo
//
//  Created by Henry Kirk on 6/13/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MealPlanWebService.h"
#import "PullRefreshTableViewController.h"
#import "MBProgressHUD.h"
#import "TTTAttributedLabel.h"

@interface GroceryListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, WSGetGroceryList, UIAlertViewDelegate, TTTAttributedLabelDelegate> {
        
    IBOutlet UILabel *titleLabel;
    
    int selectedIndex;
    NSMutableArray *selectedRows;
    IBOutlet UITableView *tableView;
}

@property (nonatomic) int selectedIndex;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIImageView *imgBackground;

-(void)loadData;
-(void)checkButtonTapped:(id)sender event:(id)event;
-(void)editGroceryList;

@end
