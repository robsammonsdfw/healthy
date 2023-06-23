//
//  OwnMessageCell.m
//  DietMasterGo
//

#import "MessageCell.h"
#import "TTAttributeLable/TTTAttributedLabel.h"
#import "DMMessage.h"

@interface MessageCell () <TTTAttributedLabelDelegate>
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) TTTAttributedLabel *messageLabel;
@property (nonatomic) DMMessageCellType messageCellType;

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIImage *bgOpponentImage;
@property (nonatomic, strong) UIImage *bgOwnerImage;
@property (nonatomic, strong) UIColor *opponentTextColor;
@property (nonatomic, strong) UIColor *ownerTextColor;
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
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.bgImageView = [[UIImageView alloc] init];
    self.bgImageView.contentMode = UIViewContentModeScaleToFill;
    self.messageLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    
    self.bgOpponentImage = [UIImage imageNamed:@"opponent_bg"];
    self.bgOpponentImage = [self.bgOpponentImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 15, 10, 15) resizingMode:UIImageResizingModeStretch];
    self.bgOwnerImage = [UIImage imageNamed:@"owner_bg"];
    self.bgOwnerImage = [self.bgOwnerImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 15, 10, 15) resizingMode:UIImageResizingModeStretch];
    
    self.opponentTextColor = [UIColor blackColor];
    self.ownerTextColor = [UIColor whiteColor];
    self.messageLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
    
    NSMutableDictionary *mutableActiveLinkAttributes = [NSMutableDictionary dictionary];
    [mutableActiveLinkAttributes setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    [mutableActiveLinkAttributes setObject:[UIColor blueColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    self.messageLabel.linkAttributes = [NSDictionary dictionaryWithDictionary:mutableActiveLinkAttributes];
    self.messageLabel.numberOfLines = 0;
    
    self.timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.bgImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;

    // For testing layouts.
//    self.messageLabel.layer.borderColor = [UIColor redColor].CGColor;
//    self.messageLabel.layer.borderWidth = 2.0f;
    
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.bgImageView];
    [self.contentView addSubview:self.messageLabel];
}

- (void)setMessage:(DMMessage *)message withCellType:(DMMessageCellType)cellType {
    self.messageCellType = cellType;
    
    self.bgImageView.image = (self.messageCellType == DMMessageCellTypeResponse) ? self.bgOpponentImage : self.bgOwnerImage;
    self.bgImageView.image = [self.bgImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    if (self.messageCellType == DMMessageCellTypeMine){
        self.bgImageView.tintColor = PrimaryColor
    } else {
        self.bgImageView.tintColor = OpponentMessageImageColor
    }
    
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
    
    self.messageLabel.textColor = UIColor.blackColor;
    self.messageLabel.text = message.text;
    self.messageLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    self.messageLabel.delegate = self;
    
    self.timeLabel.text = @"";
    
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
}

- (void)constrainMine {
    [self.contentView removeConstraints:[self.contentView constraints]];
    
    CGFloat topPadding = 3.0f;
    CGFloat bottomPadding = -3.0f;
    
    [self.bgImageView.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.timeLabel.trailingAnchor constant:0].active = YES;
    [self.bgImageView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-5].active = YES;
    [self.bgImageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:topPadding].active = YES;
    [self.bgImageView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:bottomPadding].active = YES;
    
    UIEdgeInsets labelInsets = UIEdgeInsetsMake(4, 8, -4, -13);
    
    [self.messageLabel.leadingAnchor constraintEqualToAnchor:self.bgImageView.leadingAnchor constant:labelInsets.left].active = YES;
    [self.messageLabel.trailingAnchor constraintEqualToAnchor:self.bgImageView.trailingAnchor constant:labelInsets.right].active = YES;
    [self.messageLabel.topAnchor constraintEqualToAnchor:self.bgImageView.topAnchor constant:labelInsets.top].active = YES;
    [self.messageLabel.bottomAnchor constraintEqualToAnchor:self.bgImageView.bottomAnchor constant:labelInsets.bottom].active = YES;
    [self.messageLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];

    [self.timeLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:0].active = YES;
    [self.timeLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:0].active = YES;
    [self.timeLabel.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor multiplier:0.3].active = YES;
    [self.timeLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
}

- (void)constrainResponse {
    [self.contentView removeConstraints:[self.contentView constraints]];
    
    CGFloat topPadding = 3.0f;
    CGFloat bottomPadding = -3.0f;

    [self.bgImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:5].active = YES;
    [self.bgImageView.trailingAnchor constraintLessThanOrEqualToAnchor:self.timeLabel.leadingAnchor constant:0].active = YES;
    [self.bgImageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:topPadding].active = YES;
    [self.bgImageView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:bottomPadding].active = YES;
    
    UIEdgeInsets labelInsets = UIEdgeInsetsMake(4, 14, -4, -8);

    [self.messageLabel.leadingAnchor constraintEqualToAnchor:self.bgImageView.leadingAnchor constant:labelInsets.left].active = YES;
    [self.messageLabel.trailingAnchor constraintEqualToAnchor:self.bgImageView.trailingAnchor constant:labelInsets.right].active = YES;
    [self.messageLabel.topAnchor constraintEqualToAnchor:self.bgImageView.topAnchor constant:labelInsets.top].active = YES;
    [self.messageLabel.bottomAnchor constraintEqualToAnchor:self.bgImageView.bottomAnchor constant:labelInsets.bottom].active = YES;
    [self.messageLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];

    [self.timeLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:0].active = YES;
    [self.timeLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:0].active = YES;
    [self.timeLabel.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor multiplier:0.3].active = YES;
    [self.timeLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
}

- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    return CGSizeMake(size.width + self.bgImageView.intrinsicContentSize.width + self.timeLabel.intrinsicContentSize.width + 5,
                      size.height + self.bgImageView.intrinsicContentSize.height + 5);
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(__unused TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

@end
