//
//  UIViewController+Keyboard.h


#import <UIKit/UIKit.h>

@interface UIViewController (Keyboard)

#pragma mark Keyboard support

/** Returns first responder in specified view */
- (UIView *)firstResponderInView:(UIView *)view;

/** Dismisses opened keyboard */
- (void)dismissKeyboard;

/** Fit scroll view size to content view bounds */
- (void)fitContentToSize;

/** Dismisses keyboard on touch */
- (void)setKeyboardAutoDismissing:(BOOL)keyboardAutoDismissing view:(UIView *)view;

// Allows autoscrolling
@property (nonatomic) BOOL keyboardAutoScrolling;

// Sublcass these methods to customize appearance
- (void)keyboardLayoutSubviews;

/** Dictionary with ucrrent keyboard info */
@property (nonatomic,readonly) NSDictionary *keyboardInfo;

@end
