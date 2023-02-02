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
    MBProgressHUD *HUD;
}
@property (nonatomic, strong) InAppPurchaseViewController *inAppPurchaseViewController;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIView *contentVw;


@property (strong, nonatomic) NSArray<NSString *> *dayPlansArr;
@property (strong, nonatomic) NSArray<NSString *> *planNameArr;
@property (strong, nonatomic) NSArray<NSString *> *threeMonthsPlanPriceArr;
@property (strong, nonatomic) NSArray<NSString *> *oneMonthPlanPriceArr;
@property (strong, nonatomic) NSArray<NSString *> *planAccessArr;
@property (strong, nonatomic) NSArray<NSString *> *descriptionArr;
@property (nonatomic, assign) NSString *statusStr;
- (void)closeModal;



@end

NS_ASSUME_NONNULL_END
