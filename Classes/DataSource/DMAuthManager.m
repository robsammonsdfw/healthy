//
//  DMAuthManager.m
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/26/23.
//

#import "DMAuthManager.h"
#import "MyMovesDataProvider.h"
#import "DMDatabaseProvider.h"
#import "FMDatabase.h"

@interface DMAuthManager()
@property (nonatomic, strong) DMUser *currentUser;
@end

@implementation DMAuthManager

+ (instancetype)sharedInstance {
    static DMAuthManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DMAuthManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // If we had a previously signed in user.
        _currentUser = [self getUserFromDefaults];
    }
    return self;
}

- (void)setCurrentUser:(DMUser *)currentUser {
    _currentUser = currentUser;
    [self saveUserToDefaults:currentUser];
}

- (void)loginUserWithToken:(NSString *)token completionBlock:(completionBlockWithObject)completionBlock {
    UserDataFetcher *fetcher = [[UserDataFetcher alloc] init];
    __weak typeof(self) weakSelf = self;
    [fetcher signInUserWithPassword:token
                         completion:^(DMUser *user, NSString *status, NSString *message) {
        __strong typeof(self) strongSelf = weakSelf;
        NSError *error = [weakSelf checkIfErrorForStatus:status withMessage:message];
        if (error) {
            strongSelf.currentUser = nil;
            if (completionBlock) {
                completionBlock(nil, error);
            }
            return;
        }

        // Save user, but is missing user details.
        strongSelf.currentUser = user;

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        // Set a key regarding first time sync.
        [defaults setObject:@"FirstTime" forKey:@"FirstTime"];
        [DMGUtilities setLastSyncToDate:nil];

        DMLog(@"User signed in: %@, Message: %@", user.firstName, message);
        
        // Now get the user's details.
        [weakSelf updateUserInfoWithCompletion:^(NSObject *user, NSError *error) {
            if (completionBlock) {
                completionBlock(strongSelf.currentUser, error);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:UserLoginStateDidChangeNotification object:nil];
        }];
    }];
}

/// Logs out the current user with the completion block provided (optional).
- (void)logoutCurrentUserWithCompletion:(completionBlockWithError)completionBlock {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:nil forKey:@"lastmodified_splash"];

    // Wipe all NSUserDefaults, incase the above weren't the only ones needed to whack.
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];

    // Clear all MyMoves data.
    MyMovesDataProvider *provider = [[MyMovesDataProvider alloc] init];
    [provider clearTableData];
    
    // Set new defaults.
    //keep these defaulted to app build hardcode. this effects CREATE USERS
    [defaults setValue:@"3271" forKey:@"companyid_dietmastergo"];
    [defaults setValue:@"p54118!" forKey:@"companyPassThru_dietmastergo"];
    
    // Set MyMOves and NewDesign again here because -removePersistentDomainForName: wipes
    // NSUserDefaults out.
    [defaults setObject:@"MyMoves" forKey:@"switch"]; // To Enable MyMoves
    [defaults setObject:@"NewDesign" forKey:@"changeDesign"]; /// To Enable NEW DESIGN
    
    DietmasterEngine *dietmasterEngine = [DietmasterEngine sharedInstance];
    [dietmasterEngine.mealPlanArray removeAllObjects];
    
    #pragma mark DELETE ALL USER DATA
    FMDatabase* db = [dietmasterEngine database];
    if ([db open]) {
        [db beginTransaction];
        [db executeUpdate:@"DELETE FROM Food_Log"];
        [db executeUpdate:@"DELETE FROM Food_Log_Items"];
        [db executeUpdate:@"DELETE FROM Food WHERE UserID <> 0 OR CompanyID <> 0"];
        [db executeUpdate:@"DELETE FROM Favorite_Food"];
        [db executeUpdate:@"DELETE FROM Favorite_Meal"];
        [db executeUpdate:@"DELETE FROM Favorite_Meal_Items"];
        [db executeUpdate:@"DELETE FROM weightlog"];
        [db executeUpdate:@"DELETE FROM Messages"];
        [db commit];
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *logoFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"SplashImage.png"];
    NSString *logoFilePath2x = [NSTemporaryDirectory() stringByAppendingPathComponent:@"SplashImage@2x.png"];
    if([[NSFileManager defaultManager] fileExistsAtPath: logoFilePath]) {
        [fileManager removeItemAtPath:logoFilePath error:NULL];
        [fileManager removeItemAtPath:logoFilePath2x error:NULL];
    }
    
    // This will also delete from saved preferences.
    self.currentUser = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UserLoginStateDidChangeNotification object:nil];
    
    if (completionBlock) {
        completionBlock(YES, nil);
    }
}

/// Returns if a user is currently logged in or not.
- (BOOL)isUserLoggedIn {
    return self.currentUser != nil;
}

/// The currently logged in user. Nil if not logged in.
- (DMUser *)loggedInUser {
    return self.currentUser;
}

/// Fetches the user's information from the server.
- (void)updateUserInfoWithCompletion:(completionBlockWithObject)completionBlock {
    UserDataFetcher *fetcher = [[UserDataFetcher alloc] init];
    __weak typeof(self) weakSelf = self;
    [fetcher getUserDetailsWithCompletion:^(NSDictionary *userDict, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(strongSelf.currentUser, error);
                }
            });
            return;
        }
        [strongSelf.currentUser updateUserDetails:userDict];
        [strongSelf saveUserToDefaults:strongSelf.currentUser];
        [strongSelf saveUserInfoToDatabase:strongSelf.currentUser];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(strongSelf.currentUser, nil);
            }
        });
    }];
}

#pragma mark - Helpers

- (FMDatabase *)database {
    DietmasterEngine *engine = [DietmasterEngine sharedInstance];
    return [FMDatabase databaseWithPath:[engine databasePath]];
}

- (void)saveUserInfoToDatabase:(DMUser *)user {
    FMDatabase* db = [self database];
    if (![db open]) {
    }
    
    [db beginTransaction];
    NSString *updateSQL = [NSString stringWithFormat: @"UPDATE user SET "
                           
                           "weight_goal = %@, "
                           "Height = %@, "
                           "Goals = %@, "
                           "BirthDate = '%@', "
                           "Profession = %@, "
                           "BodyType = %@, "
                           "GoalStartDate = '%@', "
                           "ProteinRequirements = %@, "
                           "gender = %@, "
                           "lactating = %@, "
                           "goalrate = %@, "
                           "BMR = %@, "
                           "CarbRatio = %@, "
                           "ProteinRatio = %@, "
                           "FatRatio = %@, "
                           "HostName = '%@' "
                           "WHERE id = 1",
                           user.weightGoal,
                           user.height,
                           user.goals,
                           [user birthDateString],
                           user.profession,
                           user.bodyType,
                           [user goalStartDateString],
                           user.proteinRequirements,
                           user.gender,
                           user.lactating,
                           user.goalRate,
                           user.userBMR,
                           user.carbRatio,
                           user.proteinRatio,
                           user.fatRatio,
                           user.hostName];
    
    [db executeUpdate:updateSQL];
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
}

- (NSError *)checkIfErrorForStatus:(NSString *)status withMessage:(NSString *)message {
    NSError *error = nil;
    
    // Incorrect Password.
    if ([status isEqualToString:@"False"] && [message containsString:@"Username or Password is incorrect"]) {
        NSString *alertMessage = @"Incorrect Login. Please check your username and/or mobile password and try again.";
        error = [DMGUtilities errorWithMessage:alertMessage code:330];
    }
    
    // Terminated Service.
    if ([status isEqualToString:@"False"] && [message containsString:@"Service has been terminated"]) {
        NSString *alertMessage = @"Service has been terminated. Please contact your provider.";
        error = [DMGUtilities errorWithMessage:alertMessage code:330];
    }
    
    // Other error.
    if ([status isEqualToString:@"False"]) {
        NSString *alertMessage = message? : @"Unknown Error. Please try again.";
        error = [DMGUtilities errorWithMessage:alertMessage code:330];
    }
    
    return error;
}

#pragma mark User State

- (void)migrateUserIfNeeded {
    if (self.currentUser) {
        return;
    }
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //  [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
    //  [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
    NSString *userId = [prefs stringForKey:@"userid_dietmastergo"];
    NSString *authKey = [prefs stringForKey:@"authkey_dietmastergo"];
    if (userId.length && authKey.length) {
        [self loginUserWithToken:authKey completionBlock:^(NSObject *object, NSError *error) {
            DMUser *user = (DMUser *)object;
            if (user) {
                // Successfully migrated.
                [prefs removeObjectForKey:@"userid_dietmastergo"];
                [prefs removeObjectForKey:@"AuthKey"];
            }
        }];
    }
}

- (void)saveCurrentUserToDefaultsAndDatabase {
    [self saveUserToDefaults:self.currentUser];
    [self saveUserInfoToDatabase:self.currentUser];
}

static NSString *DMCurrentUserDefaultsKey = @"DMCurrentUser";
- (void)saveUserToDefaults:(DMUser *)user {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (!user) {
        // Wipe from defaults.
        [defaults removeObjectForKey:DMCurrentUserDefaultsKey];
    }
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:user requiringSecureCoding:YES error:nil];
    [defaults setObject:encodedObject forKey:DMCurrentUserDefaultsKey];
}

- (DMUser *)getUserFromDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *decodedObject = [defaults objectForKey:DMCurrentUserDefaultsKey];
    if (!decodedObject) {
        return nil;
    }
    NSSet *set = [NSSet setWithArray:@[[DMUser class], [NSString class], [NSNumber class], [NSDate class]]];
    DMUser *user = [NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:decodedObject error:nil];
    return user;
}

@end
