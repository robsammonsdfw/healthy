//
//  Log_Add.h
//  DietMasterGo
//
//  Created by Andrew Moffitt on 1/7/11.
//  Copyright 2011 AE Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

/// User selects a meal code to then proceed to selecting foods for.
@interface Log_Add : UIViewController
@property (nonatomic) DMTaskMode taskMode;

- (instancetype)initWithMealPlan:(DMMealPlan *)mealPlan selectedDate:(NSDate *)selectedDate;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
@end
