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
    [self clearActions];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self clearActions];
}

// In reused cells, adding a target too many times will lead to duplicate events.
- (void)clearActions {
    [self.repsHeadBtn removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.weightHeadBtn removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
}

@end
