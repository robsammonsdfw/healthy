//
//  MyMovesListViewController.h
//  MyMoves
//
//  Created by Sathis Kumar on 24/01/19.
//

#import <UIKit/UIKit.h>
#import "MyMovesViewController.h"
@class DMMovePlan;
@class DMMoveDay;

@protocol MyMovesListViewDelegate <NSObject>
- (void)userDidSelectOption:(nullable NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_BEGIN

/// View that displays a list of Moves (aka exercises) with a search bar and filters.
@interface MyMovesListViewController : UIViewController
/// Delegate for receiving selections from the controller.
@property (nonatomic, weak) id<MyMovesListViewDelegate> delegate;
/// The move plan that the user is viewing moves for.
@property (nonatomic, strong) DMMovePlan *movePlan;

/// The selected date the user is reviewing moves for, if set.
@property (nonatomic, strong) NSDate *selectedDate;
/// The day the user is adding a new move to, if set.
@property (nonatomic, strong) DMMoveDay *moveDay;

@end

NS_ASSUME_NONNULL_END
