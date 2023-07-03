//
//  MyMovesTableViewCell.h
//  MyMoves
//
//  Created by Samson  on 14/01/19.
//

#import <UIKit/UIKit.h>

@interface MyMovesTableViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UIButton *checkBoxBtn;
@property (nonatomic, strong) IBOutlet UIImageView *checkBoxImgView;
@property (nonatomic, strong) IBOutlet UILabel *exerciseNameLbl;
@property (nonatomic, strong) IBOutlet UILabel *exerciseDescriptionLbl;
@property (nonatomic, strong) IBOutlet UILabel *addMoveLbl;
@property (nonatomic, strong) IBOutlet UIView *bgView;
@property (nonatomic, strong) IBOutlet UILabel *templateNameLbl;
@property (nonatomic, strong) IBOutlet UIView *tempLblView;
@property (nonatomic, strong) IBOutlet UIImageView *arrowImgV;

@end
