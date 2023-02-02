//
//  SendView.h
//  OutFlair
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"

@class SendView;

@protocol SendViewDelegate <NSObject>

- (void)sendView:(SendView *)sendView didSendText:(NSString *)text;

@end

@interface SendView : UIView

@property (nonatomic ,assign) IBOutlet id<SendViewDelegate>delegate;
@property (nonatomic, readonly) IBOutlet UIButton *sendButton;
@property (nonatomic, readonly) IBOutlet HPGrowingTextView *messageView;

@end
