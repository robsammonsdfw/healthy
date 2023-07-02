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
 * Completion block with BOOL and Error.
 */
typedef void(^completionBlockWithStatus)(BOOL authorized, NSError *error);

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

/// Notification that will trigger a UI refresh.
static NSString *DMReloadDataNotification = @"DMReloadDataNotification";

/// Notifications that when fired off, will trigger an up or down sync.
static NSString *DMTriggerUpSyncNotification = @"DMTriggerUpSyncNotification";
static NSString *DMTriggerDownSyncNotification = @"DMTriggerDownSyncNotification";

/// Different task modes that help shape the UI layouts
/// or functionality.
typedef NS_ENUM(NSUInteger, DMTaskMode) {
    // Unknknown task mode. Likely a bug.
    DMTaskModeUnknown = 0,
    // The user is just browsing something.
    DMTaskModeView,
    // The user wishes to edit what's in the view.
    DMTaskModeEdit,
    // The user wishes to add something.
    DMTaskModeAdd,
    // The user wishes to add something to a plan.
    DMTaskModeAddToPlan,
    // The user wishes to exchange something.
    DMTaskModeExchange
};

NS_ASSUME_NONNULL_BEGIN
/// Houses the constants for use in the DMG app.
@interface DMConstants : NSObject
@end
NS_ASSUME_NONNULL_END
