//
//  ExercisesDetailViewController.h
//  DietMasterGo
//
//  Created by Henry Kirk on 2/4/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMConstants.h"

@interface ExercisesDetailViewController : UIViewController

/// The task mode that the controller is going to perform.
@property (nonatomic) DMTaskMode taskMode;


- (instancetype)initWithExerciseDict:(NSDictionary *)exerciseDict
                        selectedDate:(NSDate *)selectedDate NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@end
