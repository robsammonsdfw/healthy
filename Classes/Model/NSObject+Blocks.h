//
//  NSObject+Blocks.h
//

#import <Foundation/Foundation.h>


#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_4_3
#error Blocks aren't supported if the Deployment target < 4.3
#else

@interface NSObject (Blocks)

///
- (void)performAfterDelay:(NSTimeInterval)delay block:(void (^)(void))block;

///
- (void)performAsync:(void (^)(void))block;

///
- (void)performInMainThread:(void (^)(void))block;

@end

#endif




