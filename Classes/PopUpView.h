//
//  PopUpView.h
//  MyMoves
//
//  Created by CIPL0688 on 11/25/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// This view controller is the main navigation menu
/// that you get when you press the hamburger button on the
/// home screen.
@interface PopUpView : UIViewController
@property (nonatomic, strong) IBOutlet UIView *popUpView;
@property (nonatomic) NSString *vc;
@end

NS_ASSUME_NONNULL_END
