//
//  PlansTableViewCell.h
//  DietMaster Go ND
//
//  Created by CIPL0688 on 2/27/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlansTableViewCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *planNameLbl;
@property (retain, nonatomic) IBOutlet UILabel *priceLbl;
@property (retain, nonatomic) IBOutlet UILabel *perMonthLbl;
@property (retain, nonatomic) IBOutlet UILabel *initialActFeeLbl;
@property (retain, nonatomic) IBOutlet UILabel *dayAccessLbl;
@property (retain, nonatomic) IBOutlet UILabel *accessDescriptionLbl;
@property (retain, nonatomic) IBOutlet UIButton *signUpBtn;
@property (retain, nonatomic) IBOutlet UIView *blueView;

@end

NS_ASSUME_NONNULL_END
