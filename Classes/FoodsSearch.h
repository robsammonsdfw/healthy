//
//  FoodsSearch.h
//  DietMasterGo
//
//  Created by Andrew Moffitt on 3/1/11.
//  Copyright 2011 AE Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "TTTAttributedLabel.h"

@interface FoodsSearch : UIViewController <UISearchBarDelegate, MBProgressHUDDelegate, UITableViewDelegate, UITableViewDataSource,UISearchDisplayDelegate,TTTAttributedLabelDelegate> {
	
    UISearchBar                 *mySearchBar;
    BOOL                        bSearchIsOn;
	IBOutlet UITableView *tableView;
	int uniqueID;
	int int_foodID;
	NSString *date_foodLogtime;
	NSDate *date_currentDate;
	NSNumber *int_mealID;
	MBProgressHUD *HUD;
    NSString *searchType;
    NSMutableArray *foodResults;
	NSMutableArray *arrBtnNames;

}
-(NSMutableArray *) filterObjectsByKeys:(NSString *) key array:(NSMutableArray *)array;

@property (retain, nonatomic) IBOutlet UIButton *btnfavfoods;
@property (retain, nonatomic) IBOutlet UIButton *btnprogram;
@property (retain, nonatomic) IBOutlet UIButton *btnfacmeals;
@property (retain, nonatomic) IBOutlet UIButton *btnall;
@property (retain, nonatomic) IBOutlet UIButton *btnfood;

- (IBAction)ScrollBtnClick:(id)sender;

@property (retain, nonatomic) IBOutlet UIImageView *imgscrl;
@property (retain, nonatomic) IBOutlet UIScrollView *scroll;

- (IBAction)ScanbtnPressed:(id)sender;

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSDate *date_currentDate;
@property (nonatomic, retain) NSNumber *int_mealID;
@property (nonatomic, copy) NSString *searchType;
@property (nonatomic, retain) UISearchBar *mySearchBar; 
@property (nonatomic, assign) BOOL bSearchIsOn;

-(void)searchBar:(id)object;
-(void)loadSearchData:(NSString *)searchTerm;

-(void)showLoading;
-(void)hideLoading;

@end
