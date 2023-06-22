//
//  OwnMessageCell.h
//  DietMasterGo
//

#import <UIKit/UIKit.h>
@class DMMessage;

/// The type of message, be it mine or the advisor responding.
typedef NS_ENUM(NSUInteger, DMMessageCellType) {
    DMMessageCellTypeMine = 0,
    /// A response from the person being messaged.
    DMMessageCellTypeResponse = 1
};

@interface MessageCell : UITableViewCell

/// Sets the message on the cell.
- (void)setMessage:(DMMessage *)message withCellType:(DMMessageCellType)cellType;

@end
