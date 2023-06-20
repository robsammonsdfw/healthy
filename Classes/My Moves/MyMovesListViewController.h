//
//  MyMovesListViewController.h
//  MyMoves
//
//  Created by Sathis Kumar on 24/01/19.
//

#import <UIKit/UIKit.h>
#import "MyMovesViewController.h"

@protocol exchangeDelegate;

NS_ASSUME_NONNULL_BEGIN

/// View that displays a list of Moves (aka exercises) with a search bar and filters.
@interface MyMovesListViewController : UIViewController
@property (nonatomic, weak) id<exchangeDelegate> exchangeDel;
@end

NS_ASSUME_NONNULL_END
