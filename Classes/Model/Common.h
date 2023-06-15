//
//  Common.h
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

id loadNib(Class aClass, NSString *nibName, id owner);
id loadNibForCell(NSString *identifier, NSString *nibName, id owner);

static UIEdgeInsets viewInsetsInSuperview(UIView *view) {
	UIEdgeInsets insets;
	insets.top = CGRectGetMinY(view.frame);
	insets.bottom = CGRectGetHeight(view.superview.bounds)-CGRectGetMaxY(view.frame);
	insets.left = CGRectGetMinX(view.frame);
	insets.right = CGRectGetWidth(view.superview.bounds)-CGRectGetMaxX(view.frame);
	return insets;
}
