//
//  MyMovesTableViewCell.h
//  MyMoves
//
//  Created by Samson  on 14/01/19.
//

#import <UIKit/UIKit.h>

@interface MyMovesTableViewCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIButton *checkBoxBtn;
@property (retain, nonatomic) IBOutlet UIImageView *checkBoxImgView;
@property (retain, nonatomic) IBOutlet UILabel *exerciseNameLbl;
@property (retain, nonatomic) IBOutlet UILabel *exerciseDescriptionLbl;
@property (retain, nonatomic) IBOutlet UILabel *addMoveLbl;
@property (retain, nonatomic) IBOutlet UIView *bgView;
@property (retain, nonatomic) IBOutlet UILabel *templateNameLbl;
@property (retain, nonatomic) IBOutlet UIView *tempLblView;
@property (retain, nonatomic) IBOutlet UIImageView *arrowImgV;

@end
