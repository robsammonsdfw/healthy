//
//  MyMovesDetailCollectionViewCell.h
//  MyMoves
//
//  Created by Samson  on 17/01/19.
//

#import <UIKit/UIKit.h>

@interface MyMovesDetailCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) IBOutlet UILabel *setNoLbl;
@property (nonatomic, strong) IBOutlet UILabel *repsLbl;
@property (nonatomic, strong) IBOutlet UILabel *weightLbl;
@property (nonatomic, strong) IBOutlet UIButton *repsBtn;
@property (nonatomic, strong) IBOutlet UIButton *weightBtn;
@property (nonatomic, strong) IBOutlet UIImageView *deleteImgV;
@property (nonatomic, strong) IBOutlet UITextField *repsTxtFld;
@property (nonatomic, strong) IBOutlet UITextField *weightTxtFld;
@property (nonatomic, strong) IBOutlet UIButton *deleteBtn;
@property (nonatomic, strong) IBOutlet UIButton *headerRepsBtn;
@property (nonatomic, strong) IBOutlet UIButton *headerWeightBtn;
@property (nonatomic, strong) IBOutlet UIImageView *editRepsImgView;
@property (nonatomic, strong) IBOutlet UIImageView *editWeightImgView;

@end
