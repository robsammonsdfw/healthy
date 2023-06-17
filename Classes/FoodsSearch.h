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
	
    NSString *searchType;
    NSMutableArray *foodResults;
	NSMutableArray *arrBtnNames;

}
-(NSMutableArray *) filterObjectsByKeys:(NSString *) key array:(NSMutableArray *)array;

@property (nonatomic, strong) IBOutlet UIButton *btnfavfoods;
@property (nonatomic, strong) IBOutlet UIButton *btnprogram;
@property (nonatomic, strong) IBOutlet UIButton *btnfacmeals;
@property (nonatomic, strong) IBOutlet UIButton *btnall;
@property (nonatomic, strong) IBOutlet UIButton *btnfood;

- (IBAction)ScrollBtnClick:(id)sender;

@property (nonatomic, strong) IBOutlet UIImageView *imgscrl;
@property (nonatomic, strong) IBOutlet UIScrollView *scroll;

- (IBAction)ScanbtnPressed:(id)sender;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSDate *date_currentDate;
@property (nonatomic, strong) NSNumber *int_mealID;
@property (nonatomic, copy) NSString *searchType;
@property (nonatomic, strong) UISearchBar *mySearchBar; 
@property (nonatomic) BOOL bSearchIsOn;

-(void)searchBar:(id)object;
-(void)loadSearchData:(NSString *)searchTerm;

@end
