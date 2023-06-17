//
//  PlansTableViewCell.h
//  DietMaster Go ND
//
//  Created by CIPL0688 on 2/27/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlansTableViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *planNameLbl;
@property (nonatomic, strong) IBOutlet UILabel *priceLbl;
@property (nonatomic, strong) IBOutlet UILabel *perMonthLbl;
@property (nonatomic, strong) IBOutlet UILabel *initialActFeeLbl;
@property (nonatomic, strong) IBOutlet UILabel *dayAccessLbl;
@property (nonatomic, strong) IBOutlet UILabel *accessDescriptionLbl;
@property (nonatomic, strong) IBOutlet UIButton *signUpBtn;
@property (nonatomic, strong) IBOutlet UIView *blueView;

@end

NS_ASSUME_NONNULL_END
