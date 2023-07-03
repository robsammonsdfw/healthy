//
//  MyMovesListTableViewCell.h
//  MyMoves
//
//  Created by CIPL0681 on 27/03/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyMovesListTableViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UIImageView *checkBoxImgView;
@property (nonatomic, strong) IBOutlet UILabel *templateNameLbl;
@property (nonatomic, strong) IBOutlet UIView *bgView;
@property (nonatomic, strong) IBOutlet UIImageView *arrowImgView;

@end

NS_ASSUME_NONNULL_END
