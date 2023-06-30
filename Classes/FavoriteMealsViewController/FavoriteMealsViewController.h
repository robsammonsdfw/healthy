//
//  FavoriteMealsViewController.h
//  DietMasterGo
//
//  Created by Henry Kirk on 2/8/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoriteMealsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSString *searchType;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSString *searchType;

@end
