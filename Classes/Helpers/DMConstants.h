//
//  DMConstants.h
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/16/23.
//

#import <UIKit/UIKit.h>

/**
 * Completion block with BOOL
 */
typedef void(^completionBlock)(BOOL completed);

/**
 * Completion block with BOOL and Error.
 */
typedef void(^completionBlockWithError)(BOOL completed, NSError *error);

/**
 * Completion block with Object and Error.
 */
typedef void(^completionBlockWithObject)(NSObject *object, NSError *error);

/**
 * Completion block with NSString name and Error.
 */
typedef void(^completionBlockWithNameAndError)(NSString *name, NSError *error);

/// Block for calling an action.
typedef void(^actionBlock)(void);

NS_ASSUME_NONNULL_BEGIN
/// Houses the constants for use in the DMG app.
@interface DMConstants : NSObject
@end
NS_ASSUME_NONNULL_END
