//
//  ExercisesDetailViewController.h
//  DietMasterGo
//
//  Created by Henry Kirk on 2/4/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "DietmasterEngine.h"
// FMDB
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

@interface ExercisesDetailViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
    
	IBOutlet UIPickerView *pickerView;
	
    NSMutableArray *pickerComponentOneArray;
    NSMutableArray *pickerComponentTwoArray;
    int exerciseLogID;
    IBOutlet UILabel *lblCaloriesBurnedTitle;
    IBOutlet UILabel *caloriesBurnedLabel;
    IBOutlet UILabel *exerciseNameLabel;
    IBOutlet UILabel *dateLabel;
    IBOutlet UITextField *tfCalories;//09-02-2016
    
    //HHT apple watch
    IBOutlet UIButton *btnAllowHealthAccess;
    IBOutlet UIView *viewAllowHealthAccess;
    
    IBOutlet UILabel *permissionTagLbl;
    
    IBOutlet UIButton *permissionBtn;
}

@property (nonatomic, strong) IBOutlet UIImageView *imgbar;
- (IBAction) delLog:(id) sender;
-(void) saveToLog:(id) sender;

-(void)loadData;
-(void)cleanUpView;
-(void)showActionSheet:(id)sender;
-(void) deleteFromFavorites;
-(void)saveToFavorites;
-(void)updateCalorieLabel;

@end
