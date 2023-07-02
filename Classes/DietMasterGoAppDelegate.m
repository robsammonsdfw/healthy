//  DietMasterGoAppDelegate.m
//  DietMasterGo
//
//  Created by Andrew Moffitt on 11/23/10.
//  Copyright 2010 AE Studios. All rights reserved.

#import "DietMasterGoAppDelegate.h"

#import "DietMasterGoViewController.h"
#import "MyLogViewController.h"
#import "LoginViewController.h"
#import "DietmasterEngine.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "MyMovesDetailsViewController.h"
#import "PurchaseIAPHelper.h"

#import "DietMasterGoPlus-Swift.h"
#import "DMGUtilities.h"
#import "DMUser.h"
#import "DMMyLogDataProvider.h"

@import StoreKit;
@import Firebase;

#define D_MINUTE	60
#define D_HOUR		3600
#define D_DAY		86400
#define D_WEEK		604800
#define D_YEAR		31556926

@interface DietMasterGoAppDelegate()
@property (nonatomic, strong) IBOutlet DietMasterGoViewController *viewController;
@property (nonatomic, strong) IBOutlet DetailViewController *navigationController;
@property (nonatomic, strong) LoginViewController *loginViewController;
@end

@implementation DietMasterGoAppDelegate

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [PurchaseIAPHelper sharedInstance];

    // Note: See -checkUserLogin as it will wipe these values if the user is Logged out.
    // -checkUserLogin will set the values to enable MyMoves and NewDesign.
    /*==========================================To Enable & Disable MyMoves==========================*/
        [[NSUserDefaults standardUserDefaults]setObject:@"MyMoves" forKey:@"switch"]; // To Enable MyMoves
//      [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"switch"]; // To disable MyMoves
        
    [FIRApp configure];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    UITableView.appearance.sectionHeaderTopPadding = 0;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoginStateDidChangeNotification:) name:UserLoginStateDidChangeNotification object:nil];

    // Print out the location of the database
    DMLog(@"Database path: %@", [[DMDatabaseUtilities database] databasePath]);

    // Perform updates.
    [self upgradeSystem];
    
    // NOTE: The RootViewController is created in the SceneDelegate now.

    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    DMLog(@"Open the URL: %@", url);
    DMAuthManager *authManager = [DMAuthManager sharedInstance];
    if (![authManager isUserLoggedIn]) {
        NSString *authString = [url absoluteString];
        authString = [authString stringByReplacingOccurrencesOfString:@"dietmastersoftware://" withString:@""];
        self.loginViewController = [[LoginViewController alloc] init];
        // Make sure the view is loaded so the string will populate.
        if (self.loginViewController.view) {
            [self.loginViewController loginFromUrl:authString];
        }
        [self showLoginIfNeeded];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [DMMyLogDataProvider uploadDatabaseWithCompletionBlock:^(BOOL completed, NSError *error) {
        DM_LOG(@"ResignActiveSync: %@, %@", completed ? @"Success":@"Fail", error);
    }];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self checkUserLogin];
    
    DMAuthManager *authManager = [DMAuthManager sharedInstance];
    if ([authManager isUserLoggedIn]) {
        [DMMyLogDataProvider syncDatabaseWithCompletionBlock:^(BOOL completed, NSError *error) {
            DM_LOG(@"BecomeActiveFetch: %@, %@", completed ? @"Success":@"Fail", error);
        }];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

#pragma mark USER LOGIN

- (void)userLoginStateDidChangeNotification:(NSNotification *)notification {
    if ([NSThread isMainThread]) {
        [self checkUserLogin];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self userLoginStateDidChangeNotification:notification];
        });
    }
}

- (void)checkUserLogin {
    DMAuthManager *authManager = [DMAuthManager sharedInstance];
    if ([authManager isUserLoggedIn] == NO) {
        [authManager migrateUserIfNeeded];
        [self showLoginIfNeeded];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:nil];
    }
}

- (void)showLoginIfNeeded {
    if ([[DMAuthManager sharedInstance] isUserLoggedIn] == NO) {
        self.loginViewController = [[LoginViewController alloc] init];
        [self.loginViewController presentLoginInController:nil
                                            withCompletion:^(BOOL completed, NSError *error) {            
            // Now do a big sync.
            [DMGUtilities setLastSyncToDate:nil];
            [DMGUtilities setLastFoodSyncDate:nil];
            [DMActivityIndicator showActivityIndicator];
            [DMMyLogDataProvider syncDatabaseWithCompletionBlock:^(BOOL completed, NSError *error) {
                [DMActivityIndicator hideActivityIndicator];
                if (error) {
                    [DMGUtilities showAlertWithTitle:@"Error!" message:error.localizedDescription inViewController:nil];
                    return;
                }

                UINavigationController *rootController = (UINavigationController *)[DMGUtilities rootViewController];
                [rootController dismissViewControllerAnimated:YES completion:nil];
                [rootController popToRootViewControllerAnimated:YES];
            }];
        }];
    }
}

- (NSInteger)hoursAfterDate:(NSDate *)aDate {
    NSTimeInterval ti = [[NSDate date] timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_HOUR);
}

- (NSInteger)minutesAfterDate:(NSDate *)aDate {
    NSTimeInterval ti = [[NSDate date] timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_MINUTE);
}

#pragma mark - System Updates

- (void)upgradeSystem {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
        DMLog(@"Error: Could not open db to upgrade.");
        return;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *fullPath = [path stringByAppendingPathComponent:@"DMGO_v3.9.2.sqlite"];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL exists = [fm fileExistsAtPath:fullPath];
    if (exists) {
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:fullPath]];
    }
    
    BOOL upgraded11 = [prefs boolForKey:@"1.1"];
    if (upgraded11 == NO) {
        [self updateMeasureTable];
    }
            
    BOOL upgraded102 = [prefs boolForKey:@"1.0.2"];
    if (upgraded102 == NO) {
        NSString *updateSQL = @"DELETE FROM Food WHERE Name LIKE '%infant%'";
        [db beginTransaction];
        [db executeUpdate:updateSQL];
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
        
        NSString *updateSQL2 = @"DELETE FROM Food WHERE Name LIKE '%babyfood%'";
        [db beginTransaction];
        [db executeUpdate:updateSQL2];
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
        
        NSString *updateSQL3 = @"DELETE FROM Food WHERE Name LIKE '%baby meal%'";
        [db beginTransaction];
        [db executeUpdate:updateSQL3];
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
        
        [prefs setBool:YES forKey:@"1.0.2"];
    }
    
    BOOL upgraded111 = [prefs boolForKey:@"1.1.11.1"];
    if (upgraded111 == NO) {
        BOOL upgraded103 = [prefs boolForKey:@"1.0.3"];
        if (upgraded103 == NO) {
            [prefs setBool:YES forKey:@"1.0.3"];
        }
        [prefs setBool:YES forKey:@"1.1.11.1"];
    }
    
    BOOL upgraded121 = [prefs boolForKey:@"1.2.1.1"];
    upgraded121 = NO;
    if (upgraded121 == NO) {
        if (![db columnExists:@"FactualID" inTableWithName:@"Food"]) {
            NSString *updateSQL = @"ALTER TABLE Food ADD FactualID TEXT";
            [db beginTransaction];
            [db executeUpdate:updateSQL];
            if ([db hadError]) {
                DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
            [db commit];
        }
        
        [prefs setBool:YES forKey:@"1.2.1.1"];
    }
    
    BOOL upgraded14 = [prefs boolForKey:@"1.4"];
    if (upgraded14 == NO) {
        if (![db columnExists:@"ProteinRatio" inTableWithName:@"user"]) {
            [db beginTransaction];
            NSString *proteinSQL = @"ALTER TABLE user ADD ProteinRatio INTEGER DEFAULT 0";
            [db executeUpdate:proteinSQL];
            if ([db hadError]) {
                DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
            [db commit];
        }
        
        if (![db columnExists:@"CarbRatio" inTableWithName:@"user"]) {
            [db beginTransaction];
            NSString *carbSQL = @"ALTER TABLE user ADD CarbRatio INTEGER DEFAULT 0";
            [db executeUpdate:carbSQL];
            if ([db hadError]) {
                DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
            [db commit];
        }
        
        if (![db columnExists:@"FatRatio" inTableWithName:@"user"]) {
            [db beginTransaction];
            NSString *fatSQL = @"ALTER TABLE user ADD FatRatio INTEGER DEFAULT 0";
            [db executeUpdate:fatSQL];
            if ([db hadError]) {
                DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
            [db commit];
        }
        
        if (![db columnExists:@"CompanyID" inTableWithName:@"user"]) {
            [db beginTransaction];
            NSString *companySQL = @"ALTER TABLE user ADD CompanyID INTEGER DEFAULT 0";
            [db executeUpdate:companySQL];
            if ([db hadError]) {
                DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
            [db commit];
        }
        
        if (![db columnExists:@"bodyfat" inTableWithName:@"weightlog"]) {
            [db beginTransaction];
            NSString *bodyFatSQL = @"ALTER TABLE weightlog ADD bodyfat REAL DEFAULT 0";
            [db executeUpdate:bodyFatSQL];
            if ([db hadError]) {
                DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
            [db commit];
        }
        
        if (![db columnExists:@"entry_type" inTableWithName:@"weightlog"]) {
            [db beginTransaction];
            NSString *entryTypeSQL = @"ALTER TABLE weightlog ADD entry_type INTEGER DEFAULT 0";
            [db executeUpdate:entryTypeSQL];
            if ([db hadError]) {
                DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
            [db commit];
        }
        
        [prefs setBool:YES forKey:@"1.4"];
    }
    
    BOOL upgraded15 = [prefs boolForKey:@"1.5"];
    if (upgraded15 == NO) {
        if (![db tableExists:@"Messages"]) {
            [db beginTransaction];
            NSString *messageSQL = @"CREATE TABLE 'Messages' (Id INTEGER PRIMARY KEY, 'Text' TEXT, Sender TEXT, 'Date' DATE, Read BOOLEAN)";
            [db executeUpdate:messageSQL];
            if ([db hadError]) {
                DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
            [db commit];
        }
        [prefs setBool:YES forKey:@"1.5"];
    }
    
    BOOL upgrade6302023 = [prefs boolForKey:@"Upgrade6302023"];
    if (upgrade6302023 == NO) {
        [DMGUtilities setLastSyncToDate:nil];
        [DMGUtilities setLastFoodSyncDate:nil];
        [prefs setBool:YES forKey:@"Upgrade6302023"];
    }
    
    // Add optimized MyMoves Tags and Categories Tables.
    // Create table to store Tags associated with Moves.
    if (![db tableExists:@"MoveTags"]) {
        [db beginTransaction];
        NSString *createTableSQL = @"CREATE TABLE 'MoveTags' (tagID INTEGER PRIMARY KEY, tag TEXT)";
        [db executeUpdate:createTableSQL];
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
    }

    if (![db tableExists:@"MoveDetails"]) {
        [db beginTransaction];
        NSString *createTableSQL = @"CREATE TABLE 'MoveDetails' (moveID INTEGER PRIMARY KEY, companyID INTEGER, moveName TEXT, videoLink TEXT, notes TEXT)";
        [db executeUpdate:createTableSQL];
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
    }
    
    // List of Categories that moves can be associated with. NOTE: Category = Bodypart.
    if (![db tableExists:@"MoveCategories"]) {
        [db beginTransaction];
        NSString *createTableSQL = @"CREATE TABLE 'MoveCategories' (categoryID INTEGER PRIMARY KEY, categoryName TEXT)";
        [db executeUpdate:createTableSQL];
        // Now add the hard-coded values of Categories.
        NSArray *categorySQLArray = @[
            @"REPLACE INTO MoveCategories (categoryID, categoryName) VALUES (1, 'Arms')",
            @"REPLACE INTO MoveCategories (categoryID, categoryName) VALUES (2, 'Calves')",
            @"REPLACE INTO MoveCategories (categoryID, categoryName) VALUES (3, 'Full Body')",
            @"REPLACE INTO MoveCategories (categoryID, categoryName) VALUES (4, 'Chest')",
            @"REPLACE INTO MoveCategories (categoryID, categoryName) VALUES (5, 'Back')",
            @"REPLACE INTO MoveCategories (categoryID, categoryName) VALUES (6, 'Shoulders')",
            @"REPLACE INTO MoveCategories (categoryID, categoryName) VALUES (7, 'Lats')",
            @"REPLACE INTO MoveCategories (categoryID, categoryName) VALUES (8, 'Abdominals')",
            @"REPLACE INTO MoveCategories (categoryID, categoryName) VALUES (9, 'Quads')",
            @"REPLACE INTO MoveCategories (categoryID, categoryName) VALUES (10, 'Hamstrings')",
            @"REPLACE INTO MoveCategories (categoryID, categoryName) VALUES (11, 'Legs')",
            @"REPLACE INTO MoveCategories (categoryID, categoryName) VALUES (12, 'Upper Body')",
            @"REPLACE INTO MoveCategories (categoryID, categoryName) VALUES (13, 'Biceps')",
            @"REPLACE INTO MoveCategories (categoryID, categoryName) VALUES (14, 'Triceps')",
            @"REPLACE INTO MoveCategories (categoryID, categoryName) VALUES (15, 'Lower Body')",
            @"REPLACE INTO MoveCategories (categoryID, categoryName) VALUES (16, 'Traps')",
            @"REPLACE INTO MoveCategories (categoryID, categoryName) VALUES (17, 'Core')",
            @"REPLACE INTO MoveCategories (categoryID, categoryName) VALUES (18, 'Glutes')",
            @"REPLACE INTO MoveCategories (categoryID, categoryName) VALUES (19, 'Hip Flexors')",
        ];
        for (NSString *sqlStatement in categorySQLArray) {
            [db executeUpdate:sqlStatement];
            if ([db hadError]) {
                DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
        }
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
    }
    
    // Create table to store the Categories that are associated with a Move.
    if (![db tableExists:@"MovesCategories"]) {
        [db beginTransaction];
        NSString *createTableSQL = @"CREATE TABLE 'MovesCategories' (moveID INTEGER, categoryID INTEGER, PRIMARY KEY (moveID, categoryID))";
        [db executeUpdate:createTableSQL];
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
    }
    // Create a table to store the Tags associated with the Moves.
    if (![db tableExists:@"MovesTags"]) {
        [db beginTransaction];
        NSString *createTableSQL = @"CREATE TABLE 'MovesTags' (moveID INTEGER, tagID INTEGER)";
        [db executeUpdate:createTableSQL];
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
    }

    NSString *upgradedMyMovesKey = @"MyMoves2023Update4";
    BOOL upgradedMyMoves = [prefs boolForKey:upgradedMyMovesKey];
    if (upgradedMyMoves == NO) {
        // Cleanup unused, deprecated tables.
        NSString *dropTableSQL = nil;
        [db beginTransaction];
        dropTableSQL = [NSString stringWithFormat:@"DROP TABLE IF EXISTS ListOfTitle_Table"];
        [db executeUpdate:dropTableSQL];
        dropTableSQL = [NSString stringWithFormat:@"DROP TABLE IF EXISTS ListOfTitle_Table_Old"];
        [db executeUpdate:dropTableSQL];
        dropTableSQL = [NSString stringWithFormat:@"DROP TABLE IF EXISTS ListOfBodyPart_Table"];
        [db executeUpdate:dropTableSQL];
        dropTableSQL = [NSString stringWithFormat:@"DROP TABLE IF EXISTS ListOfTags_Table"];
        [db executeUpdate:dropTableSQL];
        [db commit];
        
        // Re-build Databases with correct primary keys.
        [db beginTransaction];
        dropTableSQL = [NSString stringWithFormat:@"DROP TABLE IF EXISTS ServerUserPlanDateList"];
        [db executeUpdate:dropTableSQL];
        [db commit];
        [db beginTransaction];
        if (![db tableExists:@"ServerUserPlanDateList"]) {
            NSString *createTableSQL = @"CREATE TABLE 'ServerUserPlanDateList' (UserPlanDateID INTEGER, "
                                        "PlanID INTEGER, PlanDate TEXT, LastUpdated TEXT, UniqueID TEXT, "
                                        "Status TEXT, SyncResult TEXT, ParentUniqueID TEXT, UserPlanMoves TEXT, "
                                        "PRIMARY KEY (UserPlanDateID, PlanID))";
            [db executeUpdate:createTableSQL];
            if ([db hadError]) {
                DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
        }
        [db commit];
        [db beginTransaction];
        dropTableSQL = [NSString stringWithFormat:@"DROP TABLE IF EXISTS ServerUserPlanList"];
        [db executeUpdate:dropTableSQL];
        if (![db tableExists:@"ServerUserPlanList"]) {
            NSString *createTableSQL = @"CREATE TABLE 'ServerUserPlanList' (PlanID INTEGER ,UserID INTEGER, "
                                        "PlanName TEXT, Notes TEXT, LastUpdated TEXT, UniqueID TEXT, Status TEXT, "
                                        "SyncResult TEXT, UserPlanDates TEXT, "
                                        "PRIMARY KEY (PlanID, UserID))";
            [db executeUpdate:createTableSQL];
            if ([db hadError]) {
                DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
        }
        [db commit];
        [db beginTransaction];
        dropTableSQL = [NSString stringWithFormat:@"DROP TABLE IF EXISTS ServerUserPlanMoveList"];
        [db executeUpdate:dropTableSQL];
        if (![db tableExists:@"ServerUserPlanMoveList"]) {
            NSString *createTableSQL = @"CREATE TABLE 'ServerUserPlanMoveList' (UserPlanMoveID INTEGER, UserPlanDateID INTEGER, "
                                        "MoveID INTEGER, MoveName TEXT, VideoLink TEXT, Notes TEXT, LastUpdated TEXT, "
                                        "UniqueID TEXT, Status TEXT, SyncResult TEXT, ParentUniqueID TEXT, UserPlanMoveSets TEXT, "
                                        "isCheckBoxClicked TEXT, "
                                        "PRIMARY KEY (UserPlanMoveID, UserPlanDateID, MoveID))";
            [db executeUpdate:createTableSQL];
            if ([db hadError]) {
                DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
        }
        [db commit];
        [db beginTransaction];
        dropTableSQL = [NSString stringWithFormat:@"DROP TABLE IF EXISTS ServerUserPlanMoveSetList"];
        [db executeUpdate:dropTableSQL];
        if (![db tableExists:@"ServerUserPlanMoveSetList"]) {
            NSString *createTableSQL = @"CREATE TABLE 'ServerUserPlanMoveSetList' (SetID INTEGER, UserPlanMoveID INTEGER, "
                                        "SetNumber INTEGER, Unit1ID INTEGER, Unit1Value INTEGER, Unit2ID INTEGER, "
                                        "Unit2Value INTEGER, Unit1Name TEXT, Unit2Name TEXT, LastUpdated TEXT, "
                                        "UniqueID TEXT, Status TEXT, SyncResult TEXT, ParentUniqueID TEXT, "
                                        "PRIMARY KEY (SetID, UserPlanMoveID))";
            [db executeUpdate:createTableSQL];
            if ([db hadError]) {
                DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
        }
        [db commit];
        
        [prefs setBool:YES forKey:upgradedMyMovesKey];
    }
}

- (void)updateMeasureTable {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
        DMLog(@"Could not open db.");
    }
    
    BOOL success = YES;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"measure_sql" ofType:@"sql"];
    if (filePath) {
        NSString *measure_sql = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        if (measure_sql) {
            NSArray *measureArray = [measure_sql componentsSeparatedByString:@"\n"];
            [db beginTransaction];
            for (NSString *sql in measureArray) {
                [db executeUpdate:sql];
                if ([db hadError]) {
                    DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                    success = NO;
                }
            }
            [db commit];
        }
    }
    
    if (success) {
        [prefs setBool:YES forKey:@"1.1"];
    }
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success) {
        DMLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

#pragma mark - UISceneDelegate

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions API_AVAILABLE(ios(13)) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    UISceneConfiguration *config = [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
    return config;
}

@end
