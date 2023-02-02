//
//  UIView+FrameControl.h
//

#import <UIKit/UIKit.h>

@interface UIView (FrameControl)

@property (nonatomic) CGSize size;

// Sets size anchored to point. (0,0) - left top corner, (1,1) - bottom right corner
- (void)setSize:(CGSize)size anchoredToPoint:(CGPoint)point;

- (void)setOrigin:(CGPoint)origin;

@end
