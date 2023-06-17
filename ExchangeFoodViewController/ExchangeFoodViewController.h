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
	
    int indexToExchange;
    BOOL isExchangeFood;
}

@property (nonatomic) double CaloriesToMaintain;
@property (nonatomic, strong) NSMutableDictionary *ExchangeOldDataDict;
@property (nonatomic, strong) NSNumber *foodID;
@property (nonatomic, strong) NSNumber *mealTypeID;

@end
