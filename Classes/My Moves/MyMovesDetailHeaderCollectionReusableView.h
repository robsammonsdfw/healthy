//
//  MyMovesDetailHeaderCollectionReusableView.h
//  MyMoves
//
//  Created by Samson  on 17/01/19.
//

#import <UIKit/UIKit.h>

@interface MyMovesDetailHeaderCollectionReusableView : UICollectionReusableView
@property (retain, nonatomic) IBOutlet UIButton *repsHeadBtn;
@property (retain, nonatomic) IBOutlet UIButton *weightHeadBtn;
@property (retain, nonatomic) IBOutlet UILabel *repsLbl;
@property (retain, nonatomic) IBOutlet UILabel *weightLbl;

@end
