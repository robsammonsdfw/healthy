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

@interface MealPlanViewController : PullRefreshTableViewController <MBProgressHUDDelegate, UITableViewDelegate, UITableViewDataSource, WSGetUserPlannedMealNames, WSGetGroceryList, UIActionSheetDelegate> {
    
    NSMutableArray *selectedRows;
    BOOL isChoosingForGroceryList;
    MBProgressHUD *HUD;
    IBOutlet UIButton *learnHowWeCalculateBtn;
}
@property (retain, nonatomic) IBOutlet UIImageView *imgbg;
@property (nonatomic,retain)MealPlanWebService *soapWebService;
@property (retain, nonatomic) IBOutlet UIView *showPopUpVw;

-(void)loadData;
-(void)showGroceryList;
-(void)checkButtonTapped:(id)sender event:(id)event;
-(void)loadGroceryList;

-(void)showLoading;
-(void)hideLoading;
-(void)showCompleted;

-(void)showActionSheet:(id)sender;
-(IBAction)goToSafetyGuidelines;

@end
