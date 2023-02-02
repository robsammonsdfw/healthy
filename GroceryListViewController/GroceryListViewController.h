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


@interface GroceryListViewController : UIViewController <MBProgressHUDDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, WSGetGroceryList, UIAlertViewDelegate, TTTAttributedLabelDelegate> {
        
    IBOutlet UILabel *titleLabel;
    MBProgressHUD *HUD;
    int selectedIndex;
    NSMutableArray *selectedRows;
    IBOutlet UITableView *tableView;
}

@property (nonatomic, assign) int selectedIndex;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIImageView *imgBackground;

-(void)loadData;
-(void)showLoading;
-(void)hideLoading;
-(void)showCompleted;
-(void)checkButtonTapped:(id)sender event:(id)event;
-(void)editGroceryList;

@end
