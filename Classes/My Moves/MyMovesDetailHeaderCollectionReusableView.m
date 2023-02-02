//
//  MyMovesDetailHeaderCollectionReusableView.m
//  MyMoves
//
//  Created by Samson  on 17/01/19.
//

#import "MyMovesDetailHeaderCollectionReusableView.h"

@implementation MyMovesDetailHeaderCollectionReusableView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)dealloc {
    [_repsHeadBtn release];
    [_weightHeadBtn release];
    [_repsLbl release];
    [_weightLbl release];
    [super dealloc];
}
@end
