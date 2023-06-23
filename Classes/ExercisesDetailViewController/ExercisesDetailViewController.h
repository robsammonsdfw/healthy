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
    
}
@property (nonatomic) int exerciseLogID;


- (IBAction) delLog:(id) sender;
-(void) saveToLog:(id) sender;

-(void)loadData;
-(void)cleanUpView;
-(void)showActionSheet:(id)sender;
-(void) deleteFromFavorites;
-(void)saveToFavorites;
-(void)updateCalorieLabel;

@end
