/*
 * Copyright (c) 28/01/2013 Mario Negro (@emenegro)
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "UIAlertView+Blocks.h"
#import "NSObject+Blocks.h"
#import <objc/runtime.h>

/*
 * Runtime association key.
 */
static NSString *kHandlerAssociatedKey = @"kHandlerAssociatedKey";
static char kActivityStyle;

@implementation UIAlertView (Blocks)

#pragma mark - Showing

/*
 * Shows the receiver alert with the given handler.
 */
- (void)showWithHandler:(UIAlertViewHandler)handler {
    
    objc_setAssociatedObject(self, (__bridge const void *)(kHandlerAssociatedKey), handler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setDelegate:self];
    [self show];
}

#pragma mark - UIAlertViewDelegate

/*
 * Sent to the delegate when the user clicks a button on an alert view.
 */
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    UIAlertViewHandler completionHandler = objc_getAssociatedObject(self, (__bridge const void *)(kHandlerAssociatedKey));
    
    if (completionHandler != nil) {
        completionHandler(alertView, buttonIndex);
    }
}


- (UIActivityIndicatorView *)throbberView {
	return (UIActivityIndicatorView *)[self viewWithTag:101];
}

- (UIProgressView *)progressView {
	return (UIProgressView *)[self viewWithTag:102];
}


- (void)setActivityStyle:(UIAlertViewActivityStyle)activityStyle {
	objc_setAssociatedObject(self,&kActivityStyle,@(activityStyle),OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	if (activityStyle == UIAlertViewActivityThrobber) {
		if (!self.throbberView) {
			UIActivityIndicatorView *throbber = nil;
			throbber = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
			throbber.center = CGPointMake(139.5, 75.5);
			throbber.hidesWhenStopped = YES;
			throbber.tag = 101;
			[self addSubview:throbber];
			[throbber startAnimating];
		}
	}
	else {
		if (self.throbberView) {
			[self.throbberView removeFromSuperview];
		}
	}
	
	if (activityStyle == UIAlertViewActivityProgress) {
		if (!self.progressView) {
			UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(30.0f, 80.0f, 225.0f, 90.0f)];
			[self addSubview:progressView];
			[progressView setProgressViewStyle: UIProgressViewStyleBar];
			[progressView setTag:102];
		}
	}
	else {
		if (self.progressView) {
			[self.progressView removeFromSuperview];
		}
	}
	
}

- (UIAlertViewActivityStyle)activityStyle {
	return [objc_getAssociatedObject(self, &kActivityStyle) integerValue];
}




@end

UIAlertView *UIAlertViewShow(NSString *title,NSString *message,NSArray *buttons,UIAlertViewHandler block) {
	UIAlertView *alertView = [[UIAlertView alloc] init];
	alertView.title = title;
	alertView.message = message;
	alertView.cancelButtonIndex = 0;
	for (NSString *button in buttons) {
		[alertView addButtonWithTitle:button];
	}
	[alertView showWithHandler:block];
	return alertView;
}

UIAlertView *UIAlertViewErrorShow(NSError *error,NSArray *buttons,UIAlertViewHandler block) {
	return UIAlertViewShow(NSLocalizedString(@"WARNING!",nil),error.localizedDescription,buttons,block);
}

BOOL UIAlertViewShowOnce(NSString *title, NSString *message, NSArray *buttons,NSString *key, UIAlertViewHandler handler) {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:key]) {
		UIAlertViewShow(title, message, buttons, handler);
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
		[[NSUserDefaults standardUserDefaults] synchronize];

    return YES;
	}
	else if (handler) {
		handler(nil,0);
	}

  return NO;
}
