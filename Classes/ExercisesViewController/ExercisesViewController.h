//
//  ExercisesViewController.h
//  DietMasterGo
//
//  Created by Henry Kirk on 1/28/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <UIKit/UIKit.h>

/// Displays exercises for the user to choose for their day's plan.
@interface ExercisesViewController : UIViewController
/// The task mode that the controller is going to perform.
@property (nonatomic) DMTaskMode taskMode;

- (instancetype)initWithSelectedDate:(NSDate *)selectedDate NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@end
