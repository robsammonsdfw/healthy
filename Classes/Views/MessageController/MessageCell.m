//
//  OwnMessageCell.m
//  DietMasterGo
//

#import "MessageCell.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import "DMMessage.h"

@interface MessageCell () <TTTAttributedLabelDelegate>
@property (nonatomic, strong) TTTAttributedLabel *messageLabel;
@property (nonatomic) DMMessageCellType messageCellType;

@property (nonatomic, strong) UIImageView *bgImageView;
/// Recipient of message (Coach / Professional)
@property (nonatomic, strong) UIImage *recipientImage;
/// Sender of message (User).
@property (nonatomic, strong) UIImage *userImage;
@end

@implementation MessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.contentView.backgroundColor = [UIColor clearColor];
    self.bgImageView = [[UIImageView alloc] init];
    self.bgImageView.contentMode = UIViewContentModeScaleToFill;
    self.messageLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    
    self.recipientImage = [UIImage imageNamed:@"opponent_bg"];
    self.recipientImage = [self.recipientImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 15, 10, 15) resizingMode:UIImageResizingModeStretch];
    self.userImage = [UIImage imageNamed:@"owner_bg"];
    self.userImage = [self.userImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 15, 10, 15) resizingMode:UIImageResizingModeStretch];
    
    self.messageLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
    
    NSMutableDictionary *mutableActiveLinkAttributes = [NSMutableDictionary dictionary];
    [mutableActiveLinkAttributes setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    [mutableActiveLinkAttributes setObject:[UIColor blueColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    self.messageLabel.linkAttributes = [NSDictionary dictionaryWithDictionary:mutableActiveLinkAttributes];
    self.messageLabel.numberOfLines = 0;
    
    self.bgImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [self.contentView addSubview:self.bgImageView];
    [self.contentView addSubview:self.messageLabel];
}

- (void)setMessage:(DMMessage *)message withCellType:(DMMessageCellType)cellType {
    self.messageCellType = cellType;
    
    self.bgImageView.image = (self.messageCellType == DMMessageCellTypeResponse) ? self.recipientImage : self.userImage;
    self.bgImageView.image = [self.bgImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    if (self.messageCellType == DMMessageCellTypeMine){
        self.bgImageView.tintColor = AppConfiguration.chatSenderColor;
        self.messageLabel.textColor = AppConfiguration.chatSenderTextColor;
    } else {
        self.bgImageView.tintColor = AppConfiguration.chatRecipientColor;
        self.messageLabel.textColor = AppConfiguration.chatRecipientTextColor;
    }
    
    self.messageLabel.text = message.text;
    self.messageLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    self.messageLabel.delegate = self;

    // Constrain the views.
    switch (self.messageCellType) {
        case DMMessageCellTypeMine: {
            [self constrainMine];
            break;
        }
        case DMMessageCellTypeResponse: {
            [self constrainResponse];
            break;
        }
    }
    
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
}

- (void)constrainMine {
    [self.contentView removeConstraints:[self.contentView constraints]];
    
    [self constrainBackgroundImageViewForType:DMMessageCellTypeMine];

    UIEdgeInsets labelInsets = UIEdgeInsetsMake(6, 10, -6, -17);

    [self.messageLabel.leadingAnchor constraintEqualToAnchor:self.bgImageView.leadingAnchor constant:labelInsets.left].active = YES;
    [self.messageLabel.trailingAnchor constraintEqualToAnchor:self.bgImageView.trailingAnchor constant:labelInsets.right].active = YES;
    [self.messageLabel.topAnchor constraintEqualToAnchor:self.bgImageView.topAnchor constant:labelInsets.top].active = YES;
    [self.messageLabel.bottomAnchor constraintEqualToAnchor:self.bgImageView.bottomAnchor constant:labelInsets.bottom].active = YES;
    [self.messageLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.messageLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
}

- (void)constrainResponse {
    [self.contentView removeConstraints:[self.contentView constraints]];
    
    [self constrainBackgroundImageViewForType:DMMessageCellTypeResponse];
    
    UIEdgeInsets labelInsets = UIEdgeInsetsMake(6, 17, -6, -10);
    
    [self.messageLabel.leadingAnchor constraintEqualToAnchor:self.bgImageView.leadingAnchor constant:labelInsets.left].active = YES;
    [self.messageLabel.trailingAnchor constraintEqualToAnchor:self.bgImageView.trailingAnchor constant:labelInsets.right].active = YES;
    [self.messageLabel.topAnchor constraintEqualToAnchor:self.bgImageView.topAnchor constant:labelInsets.top].active = YES;
    [self.messageLabel.bottomAnchor constraintEqualToAnchor:self.bgImageView.bottomAnchor constant:labelInsets.bottom].active = YES;
    [self.messageLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.messageLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
}

- (void)constrainBackgroundImageViewForType:(DMMessageCellType)cellType {
    CGFloat topPadding = 3.0f;
    CGFloat bottomPadding = -3.0f;
    CGFloat sidePadding = 8.0f;

    if (cellType == DMMessageCellTypeMine) {
        [self.bgImageView.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.contentView.leadingAnchor constant:sidePadding].active = YES;
        [self.bgImageView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-sidePadding].active = YES;
    } else {
        [self.bgImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:sidePadding].active = YES;
        [self.bgImageView.trailingAnchor constraintLessThanOrEqualToAnchor:self.contentView.trailingAnchor constant:-sidePadding].active = YES;
    }
    [self.bgImageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:topPadding].active = YES;
    [self.bgImageView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:bottomPadding].active = YES;

    [self.bgImageView.heightAnchor constraintGreaterThanOrEqualToConstant:38].active = YES;
    [self.bgImageView.widthAnchor constraintLessThanOrEqualToAnchor:self.contentView.widthAnchor multiplier:0.5].active = YES;
}

- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    return CGSizeMake(size.width + self.bgImageView.intrinsicContentSize.width + 10,
                      size.height + self.bgImageView.intrinsicContentSize.height + 6);
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(__unused TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

@end
