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
    IBOutlet UISearchBar *searchBar;
}
@property (nonatomic, weak) id<loadDataToMovesTbl> passDataDel;

@property (nonatomic, strong) NSMutableArray *originalDataListArr;
@property (nonatomic, strong) NSMutableArray *workOutListArr;
@property (nonatomic, strong) NSMutableArray *categoryFilteredListArr;
@property (nonatomic, strong) NSMutableArray *filteredTableArr;

@property (nonatomic, strong) NSMutableArray *tableData;

@property (nonatomic, strong) IBOutlet UITextField *searchtxtfld;
@property (nonatomic, strong) IBOutlet UITextField *bodypartTxtFld;
@property (nonatomic, strong) IBOutlet UITextField *filter1;
@property (nonatomic, strong) IBOutlet UITextField *filter2;
@property (nonatomic, strong) IBOutlet UIButton *filterOneBtn;
@property (nonatomic, strong) IBOutlet UIButton *bodyPartBtn;

@property (nonatomic) BOOL isExchange;
@property (nonatomic, strong) NSDate * selectedDate;
@property (nonatomic) NSInteger userId;
@property (nonatomic) NSInteger categoryID;
@property (nonatomic) NSInteger tagsId;
@property (nonatomic) NSInteger newCount;

@property (nonatomic, strong) NSDictionary * moveDetailDictToDelete;
@property (nonatomic, weak) id<exchangeDelegate> exchangeDel;
@end

@protocol loadDataToMovesTbl <NSObject>
- (void)passDataOnAdd;
@end
NS_ASSUME_NONNULL_END
