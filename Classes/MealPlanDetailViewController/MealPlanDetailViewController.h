//
//  MealPlanDetailViewController.h
//  DietMasterGo
//
//  Created by Henry Kirk on 6/11/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MealPlanWebService.h"
#import "MBProgressHUD.h"
#import "TDDatePickerController.h"
#import "TTTAttributedLabel.h"

@interface MealPlanDetailViewController : UIViewController <UIActionSheetDelegate, WSGetUserPlannedMealNames, WSDeleteUserPlannedMealItems, TTTAttributedLabelDelegate> {
    int selectedIndex;
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *recommendedCaloriesLabel;
    IBOutlet UILabel *caloriesPlannedLabel;
    int mealCodeToAdd;
    
    int addToPlanButtonIndex;
    IBOutlet UIButton *infoBtn;

}

@property (nonatomic, strong) IBOutlet UIImageView *imgbar;
@property (nonatomic) int selectedIndex;
@property (nonatomic, strong) IBOutlet UIImageView *imgbarline;
@property (nonatomic, strong) IBOutlet UILabel *staticCalPlannedLbl;
@property (nonatomic, strong) IBOutlet UILabel *staticRecomCalLbl;

-(void)loadData;
-(void)showActionSheet:(id)sender;
-(void)addPlanToLog;
-(void)deleteMealPlanItem:(NSDictionary *)dict;
-(void)updateCalorieLabels;
-(void)confirmAddToLog;
-(void)confirmAddMealToLog:(id)sender;
-(void)addMealToLog:(id)sender;
-(void)addItemToMealPlan:(id)sender;
-(void)selectMealDate:(id)sender;
-(void)selectAllMealDate:(id)sender;
-(void)removeMissingFood:(NSIndexPath *)indexPath;
-(void)checkForMissingFoods;
-(IBAction) goToSafetyGuidelines:(id) sender;

@end
