//
//  MyMovesDetailFooterCollectionReusableView.h
//  MyMoves
//
//  Created by Samson  on 23/01/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyMovesDetailFooterCollectionReusableView : UICollectionReusableView
/// Button that will add a set when the user presses it.
@property (nonatomic, strong) IBOutlet UIButton *addSetButton;
@end

NS_ASSUME_NONNULL_END
