//
//  ExchangeFoodViewController.h
//  DietMasterGo
//
//  Created by Henry Kirk on 6/13/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMFood.h"
#import "DMMealPlanItem.h"

/// Presents foods to a user that they can exchange a food with.
@interface ExchangeFoodViewController : BaseViewController

/// Main inititalizer. Pass in the food to be exchanged.
- (instancetype)initWithFoodToExchange:(DMFood *)food
                       forMealPlanItem:(DMMealPlanItem *)mealPlanItem
                            inMealPlan:(DMMealPlan *)mealPlan NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@end
