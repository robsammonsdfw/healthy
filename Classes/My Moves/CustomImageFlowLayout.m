//
//  CustomImageFlowLayout.m
//  ZDT_InstaTutorial
//
//  Created by Sztanyi Szabolcs on 13/10/15.
//  Copyright © 2015 Zappdesigntemplates. All rights reserved.
//

#import "CustomImageFlowLayout.h"

@implementation CustomImageFlowLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        self.minimumLineSpacing = 0.5;
        self.minimumInteritemSpacing = 0.5;
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.collectionView.backgroundColor = [UIColor whiteColor];
        self.headerReferenceSize = CGSizeMake(self.collectionView.frame.size.width, 35);
        self.footerReferenceSize = CGSizeMake(self.collectionView.frame.size.width, 35);
    }
    return self;
}

- (CGSize)itemSize {
    NSInteger numberOfColumns = 1;
    CGFloat itemWidth = (CGRectGetWidth(self.collectionView.frame) - (numberOfColumns - 1)) / numberOfColumns;
    return CGSizeMake(itemWidth, 35);
}

@end
