//
//  MyMovesListTableViewCell.m
//  MyMoves
//
//  Created by CIPL0681 on 27/03/19.
//

#import "MyMovesListTableViewCell.h"

@implementation MyMovesListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [_bgView release];
    [_arrowImgView release];
    [super dealloc];
}
@end
