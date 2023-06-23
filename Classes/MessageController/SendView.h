//
//  SendView.h
//  OutFlair
//

#import <UIKit/UIKit.h>
@class SendView;

@protocol SendViewDelegate <NSObject>
/// Called when user presses the "Send" button.
- (void)sendView:(SendView *)sendView didSendText:(NSString *)text;
/// Called when the user types in multi-line text and the view needs
/// to grow.
- (void)sendView:(SendView *)textView didChangeHeight:(CGFloat)height;
@end

/// View that looks like an iMessage text entry.
@interface SendView : UIView
@property (nonatomic, weak) id<SendViewDelegate> delegate;
- (void)resignFirstResponder;
@end
