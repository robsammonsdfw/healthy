//
//  DMAuthManager.h
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/26/23.
//

#import <Foundation/Foundation.h>
#import "DMConstants.h"
#import "DMUser.h"

NS_ASSUME_NONNULL_BEGIN

/// Notification for when user login state changes.
static NSString *UserLoginStateDidChangeNotification = @"UserLoginStateDidChangeNotification";

/// Handles user state (sign-in and out)
@interface DMAuthManager : NSObject

+ (instancetype)sharedInstance;

/// Logs in a user with the provided token. Completion block returns the current
/// user that was logged in. Nil if error.
- (void)loginUserWithToken:(NSString *)token completionBlock:(nullable completionBlockWithObject)completionBlock;

/// Logs out the current user with the completion block provided (optional).
- (void)logoutCurrentUserWithCompletion:(nullable completionBlockWithError)completionBlock;

/// Returns if a user is currently logged in or not.
- (BOOL)isUserLoggedIn;

/// The currently logged in user. Nil if not logged in.
- (nullable DMUser *)loggedInUser;

/// Fetches the user's information from the server and returns the updated user.
/// This does NOT update the UserID, CompanyID, or name, only things like Height, BMR, Weight, etc.
- (void)updateUserInfoWithCompletion:(nullable completionBlockWithObject)completionBlock;

/// Migrates the user from a NSUserDefaults individual key to
/// this object. Avoids having to sign the user out.
/// Old values were saved in "userid_dietmastergo" and "authkey_dietmastergo".
- (void)migrateUserIfNeeded;

@end

NS_ASSUME_NONNULL_END
