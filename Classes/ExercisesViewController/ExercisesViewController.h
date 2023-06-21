//
//  ExercisesViewController.h
//  DietMasterGo
//
//  Created by Henry Kirk on 1/28/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface ExercisesViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource> {
	
    UISearchBar *mySearchBar;
    BOOL bSearchIsOn;
	IBOutlet UITableView *tableView;
	
    NSString *searchType;
    NSMutableArray *searchResults;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSString *searchType;
@property (nonatomic, strong) UISearchBar *mySearchBar; 
@property (nonatomic) BOOL bSearchIsOn;

-(void)searchBar: (id) object;
-(void)loadSearchData:(NSString *)searchTerm;

@end
