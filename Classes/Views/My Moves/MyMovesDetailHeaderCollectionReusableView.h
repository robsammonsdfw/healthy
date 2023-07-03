//
//  MyMovesDetailHeaderCollectionReusableView.h
//  MyMoves
//
//  Created by Samson  on 17/01/19.
//

#import <UIKit/UIKit.h>

@interface MyMovesDetailHeaderCollectionReusableView : UICollectionReusableView
@property (nonatomic, strong) IBOutlet UIButton *repsHeadBtn;
@property (nonatomic, strong) IBOutlet UIButton *weightHeadBtn;
@property (nonatomic, strong) IBOutlet UILabel *repsLbl;
@property (nonatomic, strong) IBOutlet UILabel *weightLbl;

@end
