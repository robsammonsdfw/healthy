//
//  MealPlanDetailViewController.h
//  DietMasterGo
//
//  Created by Henry Kirk on 6/11/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MealPlanDetailViewController : UIViewController {
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *recommendedCaloriesLabel;
    IBOutlet UILabel *caloriesPlannedLabel;
    int mealCodeToAdd;
    IBOutlet UIButton *infoBtn;
}

@property (nonatomic) int selectedIndex;
@end
