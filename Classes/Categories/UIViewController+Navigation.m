//
//  UIViewController+Navigation.m
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/21/23.
//

#import "UIViewController+Navigation.h"

@interface UIViewController (DMNavigation) <UIBarPositioningDelegate>
@end

@implementation UIViewController (DMNavigation)

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar {
    return UIBarPositionTop;
}

@end
