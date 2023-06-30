//
//  DMDetailTableViewCell.h
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/30/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Class that provides a title and detail label.
/// This is for use with dequeueReusableCellForIdentifier:indexPath because
/// it doesn't support cells with other styles.
@interface DMDetailTableViewCell : UITableViewCell
@end

NS_ASSUME_NONNULL_END
