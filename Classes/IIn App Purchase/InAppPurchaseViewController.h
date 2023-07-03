//
//  InAppPurchaseViewController.h
//  DietMaster Go ND
//
//  Created by CIPL0688 on 2/27/20.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

NS_ASSUME_NONNULL_BEGIN

@interface InAppPurchaseViewController : UIViewController
{
    BOOL areAdsRemoved;
    
}
@property (nonatomic, strong) InAppPurchaseViewController *inAppPurchaseViewController;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *contentVw;


@property (nonatomic, strong) NSArray<NSString *> *dayPlansArr;
@property (nonatomic, strong) NSArray<NSString *> *planNameArr;
@property (nonatomic, strong) NSArray<NSString *> *threeMonthsPlanPriceArr;
@property (nonatomic, strong) NSArray<NSString *> *oneMonthPlanPriceArr;
@property (nonatomic, strong) NSArray<NSString *> *planAccessArr;
@property (nonatomic, strong) NSArray<NSString *> *descriptionArr;
@property (nonatomic) NSString *statusStr;
- (void)closeModal;



@end

NS_ASSUME_NONNULL_END
