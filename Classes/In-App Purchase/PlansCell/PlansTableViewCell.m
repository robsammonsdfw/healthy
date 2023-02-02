//
//  PlansTableViewCell.m
//  DietMaster Go ND
//
//  Created by CIPL0688 on 2/27/20.
//

#import "PlansTableViewCell.h"

@implementation PlansTableViewCell





- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)dealloc {
    [_planNameLbl release];
    [_priceLbl release];
    [_perMonthLbl release];
    [_initialActFeeLbl release];
    [_dayAccessLbl release];
    [_accessDescriptionLbl release];
    [_signUpBtn release];
    [_blueView release];
    [super dealloc];
}
@end
