//
//  MyMovesDetailCollectionViewCell.h
//  MyMoves
//
//  Created by Samson  on 17/01/19.
//

#import <UIKit/UIKit.h>

@interface MyMovesDetailCollectionViewCell : UICollectionViewCell
@property (retain, nonatomic) IBOutlet UILabel *setNoLbl;
@property (retain, nonatomic) IBOutlet UILabel *repsLbl;
@property (retain, nonatomic) IBOutlet UILabel *weightLbl;
@property (retain, nonatomic) IBOutlet UIButton *repsBtn;
@property (retain, nonatomic) IBOutlet UIButton *weightBtn;
@property (retain, nonatomic) IBOutlet UIImageView *deleteImgV;
@property (retain, nonatomic) IBOutlet UITextField *repsTxtFld;
@property (retain, nonatomic) IBOutlet UITextField *weightTxtFld;
@property (retain, nonatomic) IBOutlet UIButton *deleteBtn;
@property (retain, nonatomic) IBOutlet UIButton *headerRepsBtn;
@property (retain, nonatomic) IBOutlet UIButton *headerWeightBtn;
@property (retain, nonatomic) IBOutlet UIImageView *editRepsImgView;
@property (retain, nonatomic) IBOutlet UIImageView *editWeightImgView;

@end
