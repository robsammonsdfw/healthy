//
//  MealPlanViewController.h
//  DietMasterGo
//
//  Created by Henry Kirk on 6/1/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MealPlanWebService.h"
#import "PullRefreshTableViewController.h"
#import "MBProgressHUD.h"

@interface MealPlanViewController : PullRefreshTableViewController <UITableViewDelegate, UITableViewDataSource, WSGetUserPlannedMealNames, WSGetGroceryList, UIActionSheetDelegate> {
    
    NSMutableArray *selectedRows;
    BOOL isChoosingForGroceryList;
    
    IBOutlet UIButton *learnHowWeCalculateBtn;
}
@property (nonatomic, strong) IBOutlet UIImageView *imgbg;
@property (nonatomic,retain) MealPlanWebService *soapWebService;

-(void)loadData;
-(void)showGroceryList;
-(void)checkButtonTapped:(id)sender event:(id)event;
-(void)loadGroceryList;

-(void)showActionSheet:(id)sender;
-(IBAction)goToSafetyGuidelines;

@end
