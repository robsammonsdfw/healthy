//
//  ExercisesViewController.h
//  DietMasterGo
//
//  Created by Henry Kirk on 1/28/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface ExercisesViewController : UIViewController <UISearchBarDelegate, MBProgressHUDDelegate, UITableViewDelegate, UITableViewDataSource> {
	
    UISearchBar *mySearchBar;
    BOOL bSearchIsOn;
	IBOutlet UITableView *tableView;
	MBProgressHUD *HUD;
    NSString *searchType;
    NSMutableArray *searchResults;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, copy) NSString *searchType;
@property (nonatomic, retain) UISearchBar *mySearchBar; 
@property (nonatomic, assign) BOOL bSearchIsOn;

-(void)searchBar: (id) object;
-(void)loadSearchData:(NSString *)searchTerm;
-(void)showLoading;
-(void)hideLoading;

@end