//
//  FoodsHome.h
//  DietMasterGo
//
//  Created by Andrew Moffitt on 3/1/11.
//  Copyright 2011 AE Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMMealPlan.h"

@interface FoodsHome : UIViewController

/// Task mode the user wishes to take.
@property (nonatomic) DMTaskMode taskMode;

- (instancetype)initWithMealTitle:(NSString *)mealTitle
                         mealCode:(DMLogMealCode)mealCode
                         mealPlan:(DMMealPlan *)mealPlan
                     selectedDate:(NSDate *)selectedDate NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
@end
