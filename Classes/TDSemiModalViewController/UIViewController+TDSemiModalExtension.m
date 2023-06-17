//
//  UIViewController+TDSemiModalExtension.m
//  TDSemiModal
//
//  Created by Nathan  Reed on 18/10/10.
//  Copyright 2010 Nathan Reed. All rights reserved.
//

#import "UIViewController+TDSemiModalExtension.h"

@implementation UIViewController (TDSemiModalExtension)

// Use this to show the modal view (pops-up from the bottom)
- (void) presentSemiModalViewController:(TDSemiModalViewController*)vc {
#define DEGREES_TO_RADIANS(x) (M_PI * (x)/180.0)

    
	UIView* modalView = vc.view;
	UIView* coverView = vc.coverView;

	//UIWindow* mainWindow = [(id)[[UIApplication sharedApplication] delegate] window];

	CGPoint middleCenter = self.view.center;
    CGSize offSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);

	UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];

	CGPoint offScreenCenter = CGPointZero;

	if(orientation == UIInterfaceOrientationLandscapeLeft ||
	   orientation == UIInterfaceOrientationLandscapeRight) {
		
		offScreenCenter = CGPointMake(offSize.height / 2.0, offSize.width * 1.2);
		middleCenter = CGPointMake(middleCenter.y, middleCenter.x);
		[modalView setBounds:CGRectMake(0, 0, SCREEN_HEIGHT, 300)];
	}
	else {
		offScreenCenter = CGPointMake(offSize.width / 2.0, offSize.height * 1.2);
        [modalView setBounds:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [coverView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
}
	
	// we start off-screen
	modalView.center = offScreenCenter;
	 
	coverView.alpha = 0.0f;
	
	[self.view addSubview:coverView];
	[self.view addSubview:modalView];
	
    [UIView animateWithDuration:0.6 animations:^{
        modalView.center = middleCenter;
        coverView.alpha = 0.5;
    }];
}

// Use this to slide the semi-modal view back down.
-(void)dismissSemiModalViewController:(TDSemiModalViewController*)vc {
	double animationDelay = 0.7;
	UIView* modalView = vc.view;
	UIView* coverView = vc.coverView;

	CGSize offSize = [UIScreen mainScreen].bounds.size;

	CGPoint offScreenCenter = CGPointZero;
	
	UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
	if(orientation == UIInterfaceOrientationLandscapeLeft || 
			orientation == UIInterfaceOrientationLandscapeRight) {
		offScreenCenter = CGPointMake(offSize.height / 2.0, offSize.width * 1.5);		
	}
	else {
		offScreenCenter = CGPointMake(offSize.width / 2.0, offSize.height * 1.5);
	}

    [UIView animateWithDuration:animationDelay animations:^{
        modalView.center = offScreenCenter;
        coverView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [modalView removeFromSuperview];
    }];

    [coverView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:animationDelay];
}

@end
