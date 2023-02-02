//
//  MyMovesListTableViewCell.h
//  MyMoves
//
//  Created by CIPL0681 on 27/03/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyMovesListTableViewCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *checkBoxImgView;
@property (retain, nonatomic) IBOutlet UILabel *templateNameLbl;
@property (retain, nonatomic) IBOutlet UIView *bgView;
@property (retain, nonatomic) IBOutlet UIImageView *arrowImgView;

@end

NS_ASSUME_NONNULL_END
