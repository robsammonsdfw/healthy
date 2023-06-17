//
//  OwnMessageCell.h
//  DietMasterGo
//

#import <UIKit/UIKit.h>
#import "TTAttributeLable/TTTAttributedLabel.h"

typedef enum {
  MessageOwnerType = 0,
  MessageOpponentType,
} MessageType;

@interface MessageCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) IBOutlet TTTAttributedLabel *messageLabel;
@property (nonatomic) MessageType messageType;

@end
