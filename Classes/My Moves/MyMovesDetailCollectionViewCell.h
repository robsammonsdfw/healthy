//
//  MyMovesDetailCollectionViewCell.h
//  MyMoves
//
//  Created by Samson  on 17/01/19.
//

#import <UIKit/UIKit.h>

@interface MyMovesDetailCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) IBOutlet UILabel *setNoLbl;
@property (nonatomic, strong) IBOutlet UIImageView *deleteImgV;
@property (nonatomic, strong) IBOutlet UITextField *repsTxtFld;
@property (nonatomic, strong) IBOutlet UITextField *weightTxtFld;
@property (nonatomic, strong) IBOutlet UIButton *deleteBtn;
@end
