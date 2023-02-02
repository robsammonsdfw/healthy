//
//  ExchangeFoodViewController.h
//  DietMasterGo
//
//  Created by Henry Kirk on 6/13/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "MealPlanWebService.h"

@interface ExchangeFoodViewController : UIViewController {
	MBProgressHUD *HUD;
    int indexToExchange;
    BOOL isExchangeFood;
}

@property (nonatomic, assign) double CaloriesToMaintain;
@property (nonatomic, strong) NSMutableDictionary *ExchangeOldDataDict;
@property (nonatomic, retain) NSNumber *foodID;
@property (nonatomic, retain) NSNumber *mealTypeID;

@end
