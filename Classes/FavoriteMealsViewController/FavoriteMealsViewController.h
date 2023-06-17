//
//  FavoriteMealsViewController.h
//  DietMasterGo
//
//  Created by Henry Kirk on 2/8/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface FavoriteMealsViewController : UIViewController <MBProgressHUDDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
	    
	IBOutlet UITableView *tableView;
	
    NSString *searchType;
    NSMutableArray *searchResults;
    int rowToSaveToLog;
    
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSString *searchType;

-(void)loadSearchData:(NSString *)searchTerm;
-(void)checkButtonTapped:(id)sender event:(id)event;
-(void)confirmAddToLog;
-(void)saveToLog:(id) sender;
-(void)confirmRemoveFromLog;
-(void)deleteFromFavorites;

@end
