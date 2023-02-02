//
//  NSObject+Blocks.h
//

#import "NSObject+Blocks.h"


@implementation NSObject (Blocks)

//- (void)runBlock:(void (^)(void))block
//{
//  block();
//}
//
//- (void)performAfterDelay:(NSTimeInterval)delay block:(void (^)(void))block
//{
//  void (^block_)() = [[block copy] autorelease];
//  [self performSelector:@selector(runBlock:) withObject:block_ afterDelay:delay];
//}

- (void)performAfterDelay:(NSTimeInterval)delay block:(void (^)(void))block
{
  int64_t delta = (int64_t)(1.0e9 * delay);
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta), dispatch_get_main_queue(), block);
}

- (void)performAsync:(void (^)(void))block
{
  dispatch_queue_t queue = dispatch_queue_create("simple async queue", DISPATCH_QUEUE_CONCURRENT);
  dispatch_async(queue, ^{
    @autoreleasepool {
      block();
    }
  });
}

- (void)performInMainThread:(void (^)(void))block
{
  dispatch_async(dispatch_get_main_queue(), ^{
    block();
  });
}

@end




