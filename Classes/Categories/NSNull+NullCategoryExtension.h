//
//  NSNull+NullCategoryExtension.h
//  MyMoves
//
//  Created by Benjamin Luria on 6/17/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Ensures that if we call intValue on NSNull, it returns zero.
@interface NSNull (NullCategoryExtension)
- (int)intValue;
@end

NS_ASSUME_NONNULL_END
