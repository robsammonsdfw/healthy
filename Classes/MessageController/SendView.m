//
//  SendView.m
//  OutFlair
//

#import "SendView.h"

@interface SendView() {
    IBOutlet UIImageView *bgImageView;
    IBOutlet UIImageView *inputFieldBgImageView;
}

@end

@implementation SendView

@synthesize sendButton;
@synthesize messageView;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    messageView.isScrollable = NO;
    messageView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
    messageView.minNumberOfLines = 1;
    messageView.maxNumberOfLines = 100;
    messageView.returnKeyType = UIReturnKeyDefault;
    messageView.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0];
    messageView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    messageView.backgroundColor = [UIColor whiteColor];
    messageView.placeholder = @"Text";
    messageView.placeholderColor = UIColorFromHex(0xababab);
    [messageView setBackgroundColor:[UIColor clearColor]];
    
    if (IsIOS7) {
        [sendButton setBackgroundImage:nil forState:UIControlStateNormal];
        [sendButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
        sendButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0];
        bgImageView.image = [UIImage imageNamed:@"send_bg_ios7"];
        inputFieldBgImageView.image = [UIImage imageNamed:@"inutfield_bg_ios7"];
    }
    
    [sendButton setTitleColor:UIColorFromHex(IsIOS7?0x8e8e93:0xffffff) forState:UIControlStateNormal];
    [sendButton setTitleColor:UIColorFromHex(IsIOS7?0x8e8e93:0xa7c88e) forState:UIControlStateDisabled];
}

- (IBAction)sendButtonTouched:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(sendView:didSendText:)]) {
        [self.delegate sendView:self didSendText:self.messageView.text];
    }
    self.messageView.text = @"";
}

@end
