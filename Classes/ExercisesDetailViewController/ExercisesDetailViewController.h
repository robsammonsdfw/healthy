//
//  ExercisesDetailViewController.h
//  DietMasterGo
//
//  Created by Henry Kirk on 2/4/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <UIKit/UIKit.h>
// FMDB
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

@interface ExercisesDetailViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic) int exerciseLogID;

@end
