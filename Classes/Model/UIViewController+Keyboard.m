//
//  UIViewController+Keyboard.m

#import "UIViewController+Keyboard.h"
#import <objc/runtime.h>

static char kKeyboardInfo;
static char kKeyboardRecognizer;
static char kKeyboardScrolling;
static char kKeyboardDismissing;


@implementation UIViewController (Keyboard)


- (NSDictionary *)keyboardInfo {
	return objc_getAssociatedObject(self, &kKeyboardInfo);
}

- (void)setKeyboardInfo:(NSDictionary *)keyboardInfo {
	objc_setAssociatedObject(self,&kKeyboardInfo,keyboardInfo,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIGestureRecognizer *)keyboardRecognizer {
	return objc_getAssociatedObject(self, &kKeyboardRecognizer);
}

- (void)setKeyboardRecognizer:(UIGestureRecognizer *)recognizer {
	objc_setAssociatedObject(self,&kKeyboardRecognizer,recognizer,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)keyboardAutoScrolling {
	return [objc_getAssociatedObject(self, &kKeyboardScrolling) boolValue];
}

- (void)setKeyboardAutoScrolling:(BOOL)keyboardAutoScrolling {
	objc_setAssociatedObject(self,&kKeyboardScrolling,
													 @(keyboardAutoScrolling),
													 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	if (self.keyboardAutoScrolling) {
//		self.scrollView.bounces = NO;
		
		[self addKeyboardObservers];
	}
	else {
		[self removeKeyboardObservers];
	}
}

- (BOOL)keyboardAutoDismissing {
	return [objc_getAssociatedObject(self, &kKeyboardDismissing) boolValue];
}

- (void)setKeyboardAutoDismissing:(BOOL)keyboardAutoDismissing view:(UIView *)view {
	objc_setAssociatedObject(self,&kKeyboardDismissing,
													 @(keyboardAutoDismissing),
													 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	if (keyboardAutoDismissing) {
		if (!self.keyboardRecognizer) {
			self.keyboardRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
																																				action:@selector(tapGestureRecognized:)];
			self.keyboardRecognizer.cancelsTouchesInView = NO;
			[view addGestureRecognizer:self.keyboardRecognizer];
		}
  }
	else {
		if (self.keyboardRecognizer) {
			[view removeGestureRecognizer:self.keyboardRecognizer];
		}
	}
}




- (UIScrollView *)scrollView {
	if ([self.view isKindOfClass:UIScrollView.class]) {
		return (UIScrollView *)self.view;
	}
	return nil;
}



- (void)tapGestureRecognized:(UIGestureRecognizer *)recognizer {
	if (self.keyboardAutoDismissing) {
		[self dismissKeyboard];
	}
}

- (CGRect)contentBoundsInView:(UIView *)view {
	CGFloat minx = 0, miny = 0, maxx = 0, maxy = 0;
	for (UIView *subview in view.subviews) {
		if (subview.alpha != 0) {
			// avoid scroll indicators
			minx = fminf(CGRectGetMinX(subview.frame), minx);
			maxx = fmaxf(CGRectGetMaxX(subview.frame), maxx);
			miny = fminf(CGRectGetMinY(subview.frame), miny);
			maxy = fmaxf(CGRectGetMaxY(subview.frame), maxy);
		}
	}
	return CGRectMake(minx, miny, maxx-minx, maxy-miny);
}

- (void)fitContentToSize {
	
	UIView *container = self.scrollView.superview;
	
	UIWindow *window = [UIApplication sharedApplication].keyWindow;
	
	
    CGRect keyboardFrame = CGRectZero;
    
	if (self.keyboardInfo) {
		CGRect keyboardFrameInWindow = [[self.keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
		keyboardFrame = [container convertRect:keyboardFrameInWindow fromView:window];
	}    
	
	CGRect contentBounds = [self contentBoundsInView:self.scrollView];
    contentBounds.size.height += keyboardFrame.size.height;
	self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(contentBounds),CGRectGetMaxY(contentBounds));
    
    if (self.keyboardInfo) {
        UIView *responder = [self firstResponderInView:self.scrollView];
        if (responder) {
            CGRect frame = [responder convertRect:responder.bounds toView:self.scrollView];
        
            if (frame.origin.y < self.scrollView.contentOffset.y) {
                [self.scrollView scrollRectToVisible:frame animated:YES];
                
            } else {
                CGFloat diff = (frame.origin.y + frame.size.height) -
																			self.scrollView.contentOffset.y - keyboardFrame.origin.y;
                diff += 20.0;
                if (diff > 0) {
                    CGPoint newOffset = CGPointMake(0, self.scrollView.contentOffset.y + diff);
                    [self.scrollView setContentOffset:newOffset animated:YES];
                }
            }
        }
    } else {
        [self.scrollView setContentOffset:CGPointZero animated:YES];
    }

}


#pragma mark Keyboard support

- (UIView *)firstResponderInView:(UIView *)view {
	
  if (view.isFirstResponder) {
    return view;
	}
	
  for (UIView *subview in view.subviews) {
		UIView *potentiallyResponder = [self firstResponderInView:subview];
    if (potentiallyResponder) {
      return potentiallyResponder;
		}
  }
  
  return nil;
}

- (void)dismissKeyboard {
	[[self firstResponderInView:self.view] resignFirstResponder];
}

#pragma mark Keyboard notifications

- (void)addKeyboardObservers {
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	
	[center addObserver:self
						 selector:@selector(keyboardWillShow:)
								 name:UIKeyboardWillShowNotification object:nil];
	[center addObserver:self
						 selector:@selector(keyboardWillHide:)
								 name:UIKeyboardWillHideNotification object:nil];
  
}

- (void)removeKeyboardObservers {
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	
	[center removeObserver:self
										name:UIKeyboardWillShowNotification object:nil];
	[center removeObserver:self
										name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardLayoutSubviews {
	[self fitContentToSize];
}

- (void)keyboardWillShow:(NSNotification *)notification {
 	NSDictionary *info = [notification userInfo];
	self.keyboardInfo = info;
	
	UIViewAnimationCurve animationCurve = [[info valueForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
	NSTimeInterval animationDuration = [[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  
    [UIView animateWithDuration:animationDuration animations:^{
        [self keyboardLayoutSubviews];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
	NSDictionary *info = [notification userInfo];
    self.keyboardInfo = nil;
	
    if (info) {
        UIViewAnimationCurve animationCurve = [[info valueForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
        NSTimeInterval animationDuration = [[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        [UIView animateWithDuration:animationDuration animations:^{
            [self keyboardLayoutSubviews];
        }];
    }
}

@end
