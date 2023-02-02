//
//  MyMovesTableViewCell.m
//  MyMoves
//
//  Created by Samson  on 14/01/19.
//

#import "MyMovesTableViewCell.h"

@implementation MyMovesTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [_checkBoxBtn release];
    [_checkBoxImgView release];
    [_exerciseNameLbl release];
    [_exerciseDescriptionLbl release];
    [_addMoveLbl release];
    [_bgView release];
    [_templateNameLbl release];
    [_tempLblView release];
    [_arrowImgV release];
    [super dealloc];
}
@end
