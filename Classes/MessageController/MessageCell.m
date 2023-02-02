//
//  OwnMessageCell.m
//  DietMasterGo
//

#import "MessageCell.h"

@interface MessageCell () {
    IBOutlet UIImageView *bgImageView;
    UIImage *bgOpponentImage;
    UIImage *bgOwnerImage;
    UIColor *opponentTextColor;
    UIColor *ownerTextColor;
}
@end

@implementation MessageCell
@synthesize messageLabel,timeLabel,messageType;

- (void)setMessageType:(MessageType)messageType_ {
    messageType = messageType_;
    bgImageView.image = (messageType == MessageOpponentType)?bgOpponentImage:bgOwnerImage;
    bgImageView.image = [bgImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    if (messageType == MessageOwnerType){
        bgImageView.tintColor = PrimaryColor
    }
    else {
        bgImageView.tintColor = OpponentMessageImageColor
    }
//    messageLabel.textColor = (messageType == MessageOpponentType)?opponentTextColor:ownerTextColor;
    messageLabel.textColor = UIColor.blackColor;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    bgOpponentImage = [UIImage imageNamed:IsIOS7?@"opponent_bg_ios7":@"opponent_bg"];
    bgOwnerImage = [UIImage imageNamed:IsIOS7?@"owner_bg_ios7":@"owner_bg"];
    
    opponentTextColor = [UIColor blackColor];
    ownerTextColor = [UIColor whiteColor]; //UIColorFromHex(IsIOS7?0xFFFFFF:0x0);
    
    messageLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:IsIOS7?18:15];
    
    //HHT change 2018 to set link color
    NSMutableDictionary *mutableActiveLinkAttributes = [NSMutableDictionary dictionary];
    [mutableActiveLinkAttributes setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    [mutableActiveLinkAttributes setObject:[UIColor whiteColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    messageLabel.linkAttributes = [NSDictionary dictionaryWithDictionary:mutableActiveLinkAttributes];
}

- (void)dealloc {
    
}
@end
