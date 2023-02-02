//
//  UIView+FrameControl.m
//

#import "UIView+FrameControl.h"

@implementation UIView (FrameControl)

- (CGSize)size {
	return self.frame.size;
}

- (void)setSize:(CGSize)size {
  CGRect rect = self.frame;
  rect.size = size;
  self.frame = rect;
}

- (void)setSize:(CGSize)size anchoredToPoint:(CGPoint)point {
	CGRect rect = self.frame;
	
	CGFloat dx = size.width - rect.size.width;
	CGFloat dy = size.height - rect.size.height;
  
	rect.origin.x -= point.x*dx;
	rect.origin.y -= point.y*dy;
	rect.size.width = size.width;
	rect.size.height = size.height;
	self.frame = rect;	
}


- (void)setOrigin:(CGPoint)origin
{
  CGRect rect = self.frame;
  rect.origin = origin;
  self.frame = rect;
}

@end
