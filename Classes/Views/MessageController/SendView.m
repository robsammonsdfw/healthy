//
//  SendView.m
//  OutFlair
//

#import "SendView.h"

@interface SendView() <GrowingTextViewDelegate>
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) GrowingTextView *messageView;
@property (nonatomic, strong) UIImageView *inputFieldBgImageView;
@end

@implementation SendView

@synthesize sendButton;
@synthesize messageView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = UIColorFromHexString(@"#F3F3F3");
    
    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.sendButton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    self.sendButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0];
    [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
    self.sendButton.enabled = YES;
    [self.sendButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self.sendButton addTarget:self action:@selector(sendButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.sendButton];
    
    // Background of text input. Should match sizes.
    self.inputFieldBgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.inputFieldBgImageView.translatesAutoresizingMaskIntoConstraints = NO;
    UIImage *bgImage = [UIImage imageNamed:@"inutfield_bg_ios7"];
    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(3, 14, 3, 14) resizingMode:UIImageResizingModeStretch];
    self.inputFieldBgImageView.image = bgImage;
    
    [self addSubview:self.inputFieldBgImageView];
    
    // Input text field.
    self.messageView = [[GrowingTextView alloc] initWithFrame:CGRectZero textContainer:nil];
    self.messageView.delegate = self;
    self.messageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.messageView.scrollEnabled = NO;
    self.messageView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    self.messageView.returnKeyType = UIReturnKeyDefault;
    self.messageView.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0];
    self.messageView.backgroundColor = [UIColor whiteColor];
    self.messageView.placeholder = @"Text Message";
    self.messageView.placeholderColor = UIColorFromHexString(@"#ababab");
    [self.messageView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.messageView];
    
    [self.sendButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-12].active = YES;
    [self.sendButton.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-5].active = YES;
    [self.sendButton setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.messageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10].active = YES;
    [self.messageView.trailingAnchor constraintEqualToAnchor:self.sendButton.leadingAnchor constant:-12].active = YES;
    [self.messageView.topAnchor constraintEqualToAnchor:self.topAnchor constant:10].active = YES;
    [self.messageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-3].active = YES;
    [self.messageView setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.messageView setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];

    [self.inputFieldBgImageView.leadingAnchor constraintEqualToAnchor:self.messageView.leadingAnchor constant:0].active = YES;
    [self.inputFieldBgImageView.trailingAnchor constraintEqualToAnchor:self.messageView.trailingAnchor constant:0].active = YES;
    [self.inputFieldBgImageView.topAnchor constraintEqualToAnchor:self.messageView.topAnchor constant:0].active = YES;
    [self.inputFieldBgImageView.bottomAnchor constraintEqualToAnchor:self.messageView.bottomAnchor constant:0].active = YES;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(self.messageView.intrinsicContentSize.width +
                      self.sendButton.intrinsicContentSize.width + 30.0,
                      self.messageView.intrinsicContentSize.height + 20);
}

- (void)sendButtonTouched:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(sendView:didSendText:)]) {
        [self.delegate sendView:self didSendText:self.messageView.text];
    }
    self.messageView.text = @"";
    [self.messageView forceLayoutSubviews];
}

- (void)resignFirstResponder {
    [self.messageView resignFirstResponder];
}

- (void)textViewDidChangeHeight:(GrowingTextView *)textView height:(CGFloat)height {
    [self layoutIfNeeded];
    if ([self.delegate respondsToSelector:@selector(sendView:didChangeHeight:)]) {
        [self.delegate sendView:self didChangeHeight:height];
    }
}

@end
