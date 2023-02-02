//
//  MyMovesListViewController.h
//  MyMoves
//
//  Created by Sathis Kumar on 24/01/19.
//

#import <UIKit/UIKit.h>
#import "MyMovesWebServices.h"
#import "PickerViewController.h"
#import "MyMovesViewController.h"

NS_ASSUME_NONNULL_BEGIN
@protocol exchangeDelegate;
@protocol loadDataToMovesTbl;
@interface MyMovesListViewController : UIViewController
{
    IBOutlet UITableView *tblView;
    PickerViewController *picker;
    CGFloat animatedDistance;
    MBProgressHUD *HUD;

    IBOutlet UISearchBar *searchBar;
}
@property(nonatomic,assign) id<loadDataToMovesTbl> passDataDel;

@property (strong, nonatomic) NSMutableArray *originalDataListArr;
@property (strong, nonatomic) NSMutableArray *workOutListArr;
@property (strong, nonatomic) NSMutableArray *categoryFilteredListArr;
@property (strong, nonatomic) NSMutableArray *filteredTableArr;

@property (strong, nonatomic) NSMutableArray *tagsArr;

@property (strong, nonatomic) NSMutableArray *tableData;

@property (strong, nonatomic) NSMutableArray *BodyPartDataArr;

@property (retain, nonatomic) IBOutlet UITextField *searchtxtfld;
@property (retain, nonatomic) IBOutlet UITextField *bodypartTxtFld;
@property (retain, nonatomic) IBOutlet UITextField *filter1;
@property (retain, nonatomic) IBOutlet UITextField *filter2;
@property (retain, nonatomic) IBOutlet UIButton *filterOneBtn;
@property (retain, nonatomic) IBOutlet UIButton *bodyPartBtn;

@property (nonatomic, assign) BOOL isExchange;
@property (strong, retain) NSDate * selectedDate;
@property(nonatomic,assign) NSInteger userId;
@property(nonatomic,assign) NSInteger categoryID;
@property(nonatomic,assign) NSInteger tagsId;
@property(nonatomic,assign) NSInteger newCount;

@property (strong, retain) NSDictionary * moveDetailDictToDelete;
@property(nonatomic,assign) id<exchangeDelegate> exchangeDel;
@end

@protocol loadDataToMovesTbl <NSObject>
- (void)passDataOnAdd;
@end
NS_ASSUME_NONNULL_END
