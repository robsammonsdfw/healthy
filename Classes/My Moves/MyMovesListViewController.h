//
//  MyMovesListViewController.h
//  MyMoves
//
//  Created by Sathis Kumar on 24/01/19.
//

#import <UIKit/UIKit.h>
#import "MyMovesWebServices.h"
#import "PickerViewController.h"
#import "MyMovesViewController.h"

@protocol exchangeDelegate;
@protocol loadDataToMovesTbl <NSObject>
- (void)passDataOnAdd;
@end

NS_ASSUME_NONNULL_BEGIN

/// View that displays a list of Moves (aka exercises) with a search bar and filters.
@interface MyMovesListViewController : UIViewController
@property (nonatomic, weak) id<loadDataToMovesTbl> passDataDel;
@property (nonatomic, weak) id<exchangeDelegate> exchangeDel;
@end

NS_ASSUME_NONNULL_END
