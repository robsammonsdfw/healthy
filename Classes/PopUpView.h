//
//  PopUpView.h
//  MyMoves
//
//  Created by CIPL0688 on 11/25/19.
//

#import <UIKit/UIKit.h>
#import "DietMasterGoViewController.h"
#import "MyLogViewController.h"
#import "MyGoalViewController.h"
#import "MealPlanViewController.h"
#import "AppSettings.h"

NS_ASSUME_NONNULL_BEGIN

@protocol GotoViewControllerDelegate;

@interface PopUpView : UIViewController
@property (nonatomic, strong) IBOutlet UIView *popUpView;
@property (nonatomic, weak) id<GotoViewControllerDelegate> gotoDelegate;

@property (nonatomic) NSString *vc;

@end

@protocol GotoViewControllerDelegate <NSObject>
    
- (void)DietMasterGoViewController;
- (void)MyLogViewController;
- (void)MyGoalViewController;
- (void)MealPlanViewController;
- (void)AppSettings;
- (void)MealPlanDetailVC;
- (void)MyMovesViewController;

- (void)hideShowPopUpView;


@end

NS_ASSUME_NONNULL_END
