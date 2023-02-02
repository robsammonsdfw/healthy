//
//  MyMovesDetailCollectionViewCell.m
//  MyMoves
//
//  Created by Samson  on 17/01/19.
//

#import "MyMovesDetailCollectionViewCell.h"

@implementation MyMovesDetailCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)dealloc {
    [_setNoLbl release];
    [_repsLbl release];
    [_weightLbl release];
    [_repsBtn release];
    [_weightBtn release];
    [_deleteImgV release];
    [_repsTxtFld release];
    [_weightTxtFld release];
    [_deleteBtn release];
    [_repsBtn release];
    [_headerRepsBtn release];
    [_headerWeightBtn release];
    [_editRepsImgView release];
    [_editWeightImgView release];
    [super dealloc];
}
@end
