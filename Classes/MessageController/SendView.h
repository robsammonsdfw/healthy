//
//  SendView.h
//  OutFlair
//

#import <UIKit/UIKit.h>
@import GrowingTextView;

@class SendView;

@protocol SendViewDelegate <NSObject>
- (void)sendView:(SendView *)sendView didSendText:(NSString *)text;
@end

/// View that looks like an iMessage text entry.
@interface SendView : UIView

@property (nonatomic, weak) IBOutlet id<SendViewDelegate> delegate;
@property (nonatomic, readonly) IBOutlet UIButton *sendButton;
@property (nonatomic, readonly) IBOutlet GrowingTextView *messageView;

@end
