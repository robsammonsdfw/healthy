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

@import StoreKit;
@import Firebase;

#define D_MINUTE	60
#define D_HOUR		3600
#define D_DAY		86400
#define D_WEEK		604800
#define D_YEAR		31556926

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

    // Print out the location of the database
    DMLog(@"Database path: %@", [[DietmasterEngine sharedInstance] databasePath]);

    // Perform updates.
    [self upgradeSystem];
    
    // NOTE: The RootViewController is created in the SceneDelegate now.

    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    DMLog(@"Open the URL: %@", url);
    
    BOOL userLogout = [[NSUserDefaults standardUserDefaults] boolForKey:@"logout_dietmastergo"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if ([prefs boolForKey:@"user_loggedin"] == NO || userLogout == YES) {
        NSString *authString = [url absoluteString];
        authString = [authString stringByReplacingOccurrencesOfString:@"dietmastersoftware://" withString:@""];
        
        if (!self.loginViewController) {
            self.loginViewController = [[LoginViewController alloc] init];
            self.loginViewController.view.frame = [[UIScreen mainScreen] applicationFrame];
            self.loginViewController.view.tag = 40;
            self.loginViewController.view.alpha = 0.0;
            self.loginViewController.view.hidden = YES;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userLoginFinished:) name:@"UserLoginFinished" object:nil];
        
        if (self.loginViewController.view.hidden == YES) {
            
            self.loginViewController.view.frame = [[UIScreen mainScreen] applicationFrame];
            self.loginViewController.view.tag = 40;
            self.loginViewController.view.alpha = 0.0;
            self.loginViewController.view.hidden = NO;
            
            [self.window insertSubview:[self.loginViewController view] atIndex:0];
            [self.window bringSubviewToFront:self.loginViewController.view];
            
            [UIView animateWithDuration:0.75 animations:^{
                self.loginViewController.view.alpha = 1.0;
            }];

            UIView *v = [self.window viewWithTag:30];
            v.alpha = 0.0;
            v.hidden = YES;
            
            UIView *v1 = [self.window viewWithTag:35];
            v1.alpha = 0.0;
            v1.hidden = YES;
        }
        
        [self.loginViewController loginFromUrl:authString];
    }
    return YES;
}

- (void)loginFromUrl:(NSString *)loginUrl {
    BOOL userLogout = [[NSUserDefaults standardUserDefaults] boolForKey:@"logout_dietmastergo"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if ([prefs boolForKey:@"user_loggedin"] == NO || userLogout == YES) {
        if (!self.loginViewController) {
            self.loginViewController = [[LoginViewController alloc] init];
            self.loginViewController.view.frame = [[UIScreen mainScreen] applicationFrame];
            self.loginViewController.view.tag = 40;
            self.loginViewController.view.alpha = 0.0;
            self.loginViewController.view.hidden = YES;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userLoginFinished:) name:@"UserLoginFinished" object:nil];
        
        if (self.loginViewController.view.hidden == YES) {
            
            self.loginViewController.view.frame = [[UIScreen mainScreen] applicationFrame];
            self.loginViewController.view.tag = 40;
            self.loginViewController.view.alpha = 0.0;
            self.loginViewController.view.hidden = NO;
            
            [self.window insertSubview:[self.loginViewController view] atIndex:0];
            [self.window bringSubviewToFront:self.loginViewController.view];
                        
            [UIView animateWithDuration:0.75 animations:^{
                self.loginViewController.view.alpha = 1.0;
            }];

            UIView *v = [self.window viewWithTag:30];
            v.alpha = 0.0;
            v.hidden = YES;
            
            UIView *v1 = [self.window viewWithTag:35];
            v1.alpha = 0.0;
            v1.hidden = YES;
        }
        
        [self.loginViewController loginFromUrl:loginUrl];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSString *lastUpdate = [formatter stringFromDate:[[NSUserDefaults standardUserDefaults] valueForKey:@"lastsyncdate"]];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    [dietmasterEngine saveMealItems:lastUpdate]; //should not be passing nil
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [self checkUserLogin];
    
    if ([prefs boolForKey:@"user_loggedin"] == YES) {
        [self syncDatabase];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

#pragma mark USER LOGIN

- (void)checkUserLogin {
    BOOL userLogout = [[NSUserDefaults standardUserDefaults] boolForKey:@"logout_dietmastergo"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if ([prefs boolForKey:@"user_loggedin"] == NO || userLogout == YES) {
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
                
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"userid_dietmastergo"];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"companyemail1_dietmastergo"];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"companyemail2_dietmastergo"];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"companyname_dietmastergo"];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"authkey_dietmastergo"];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"lastmodified_splash"];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"splashimage_filename"];
        
        // This rmoves ALL entries from NSUserDefaults.
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setBool:NO forKey:@"user_loggedin"];
        
        //keep these defaulted to app build hardcode. this effects CREATE USERS
        [prefs setValue:@"3271" forKey:@"companyid_dietmastergo"];
        [prefs setValue:@"p54118!" forKey:@"companyPassThru_dietmastergo"];
        
        // Set MyMOves and NewDesign again here because -removePersistentDomainForName: wipes
        // NSUserDefaults out.
        [prefs setObject:@"MyMoves" forKey:@"switch"]; // To Enable MyMoves
        [prefs setObject:@"NewDesign" forKey:@"changeDesign"]; /// To Enable NEW DESIGN
        
        [dietmasterEngine.mealPlanArray removeAllObjects];
        [self.viewController reloadData];
        
        #pragma mark DELETE ALL USER DATA
        FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
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
        [self getUserLogin];

    } else {
        [self.viewController reloadData];
    }
}

- (void)getUserLogin {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"logout_dietmastergo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (!self.loginViewController) {
        self.loginViewController = [[LoginViewController alloc] init];
    }
    
    [self.loginViewController presentLoginInController:nil
                                        withCompletion:^(BOOL completed, NSError *error) {
        // Login successful!
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UserLoginFinished" object:nil];
        
        //    UIAlertController *alert = [UIAlertController alertControllerWithTitle:APP_NAME
        //                                                                   message:@"Do you want to make changes to optional settings?"
        //                                                            preferredStyle:UIAlertControllerStyleAlert];
        //    [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //        AppDel.isFromAlert = YES;
        //        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFromAlert"];
        //    }]];
        //    [alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        //        [alert dismissViewControllerAnimated:YES completion:nil];
        //    }]];
        //    [[DMGUtilities rootViewController] presentViewController:alert animated:YES completion:nil];

        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setBool:YES forKey:@"user_loggedin"];
        [prefs setValue:[NSDate date] forKey:@"lastmodified"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:nil];
        [self syncDatabase];
        [self.viewController reloadData];
        UINavigationController *rootController = (UINavigationController *)[DMGUtilities rootViewController];
        [rootController popToRootViewControllerAnimated:YES];
    }];
}

//DownSync
#pragma mark SYNC DELEGATE METHODS

- (void)syncDatabaseFinished:(NSString *)responseMessage {
    [DMActivityIndicator hideActivityIndicator];
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    dietmasterEngine.syncDatabaseDelegate = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:nil];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:[NSDate date] forKey:@"lastmodified"];
}

- (void)syncDatabaseFailed:(NSString *)failedMessage {
    DMLog(@"SYNC FAIL: %@", failedMessage);
    [DMActivityIndicator hideActivityIndicator];

    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    dietmasterEngine.syncDatabaseDelegate = nil;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:nil forKey:@"lastmodified"];
    [prefs setValue:nil forKey:@"lastsyncdate"];
}

- (void)syncUPDatabaseFinished:(NSString *)responseMessage {
    [self performSelector:@selector(callSyncDatabase) withObject:nil afterDelay:1.00];
}

-(void)callSyncDatabase {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    dietmasterEngine.syncUPDatabaseDelegate = nil;
    dietmasterEngine.syncDatabaseDelegate = self;
    
    [dietmasterEngine syncDatabase];
        
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:[NSDate date] forKey:@"lastmodified"];
}

- (void)syncUPDatabaseFailed:(NSString *)failedMessage {
    DMLog(@"SYNC FAIL: %@", failedMessage);
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    dietmasterEngine.syncUPDatabaseDelegate = nil;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:nil forKey:@"lastmodified"];
    [prefs setValue:nil forKey:@"lastsyncdate"];
    
    [DMActivityIndicator hideActivityIndicator];
}

- (NSInteger)hoursAfterDate:(NSDate *)aDate {
    NSTimeInterval ti = [[NSDate date] timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_HOUR);
}

- (NSInteger)minutesAfterDate:(NSDate *)aDate {
    NSTimeInterval ti = [[NSDate date] timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_MINUTE);
}

- (void)syncDatabase {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([prefs boolForKey:@"user_loggedin"] == YES) {
        
        MyMovesWebServices *soapWebService = [[MyMovesWebServices alloc] init];
        [soapWebService fetchAllUserPlanData];
        [soapWebService getMyMovesData];
        
        NSInteger hourSinceDate = [self hoursAfterDate:[prefs valueForKey:@"lastmodified"]];
        if (![prefs valueForKey:@"lastmodified"] || hourSinceDate >= 2) {
            DataFetcher *dataFetcher = [[DataFetcher alloc] init];
            [dataFetcher signInUserWithPassword:[prefs objectForKey:@"loginPwd"] completion:^(DMUser *user, NSString *status, NSString *message) {
                DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
                dietmasterEngine.syncUPDatabaseDelegate = self;
                [dietmasterEngine uploadDatabase];
            }];
        }
    }
}

#pragma mark - System Updates

- (void)upgradeSystem {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    DietmasterEngine *dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
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
    
    BOOL upgraded11 = [[NSUserDefaults standardUserDefaults] boolForKey:@"1.1"];
    if (upgraded11 == NO) {
        [self updateMeasureTable];
    }
            
    BOOL upgraded102 = [[NSUserDefaults standardUserDefaults] boolForKey:@"1.0.2"];
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
    
    BOOL upgraded111 = [[NSUserDefaults standardUserDefaults] boolForKey:@"1.1.11.1"];
    if (upgraded111 == NO) {
        BOOL upgraded103 = [[NSUserDefaults standardUserDefaults] boolForKey:@"1.0.3"];
        if (upgraded103 == NO) {
            [prefs setBool:YES forKey:@"1.0.3"];
        }
        [prefs setBool:YES forKey:@"1.1.11.1"];
    }
    
    BOOL upgraded121 = [[NSUserDefaults standardUserDefaults] boolForKey:@"1.2.1.1"];
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
    
    BOOL upgraded14 = [[NSUserDefaults standardUserDefaults] boolForKey:@"1.4"];
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
    
    BOOL upgraded15 = [[NSUserDefaults standardUserDefaults] boolForKey:@"1.5"];
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
    BOOL upgradedMyMoves = [[NSUserDefaults standardUserDefaults] boolForKey:upgradedMyMovesKey];
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
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
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

- (void)openMailForApp {
    if ([MFMailComposeViewController canSendMail]) {
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSString *finalPath = [path stringByAppendingPathComponent:PLIST_NAME];
        NSDictionary *appDefaults = [[NSDictionary alloc] initWithContentsOfFile:finalPath];
        
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        [mailComposer setSubject:[NSString stringWithFormat:@"%@ App Help & Support", [appDefaults valueForKey:@"app_name_short"]]];
        NSString *emailTo = [[NSString alloc] initWithFormat:@""];
        [mailComposer setMessageBody:emailTo isHTML:NO];
        NSString *emailTo1 = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"LoginEmail"]];
        NSArray *toArray = [NSArray arrayWithObjects:emailTo1, nil];
        [mailComposer setToRecipients:toArray];
        mailComposer.mailComposeDelegate = self;
        
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        NSData *zipData = dietmasterEngine.createZipFileOfDatabase;
        [mailComposer addAttachmentData:zipData mimeType:@"application/zip" fileName:@"Document.Zip"];
        [AppDel.window.rootViewController presentViewController:mailComposer animated:YES completion:^{

        }];
    } else {
        [DMGUtilities showAlertWithTitle:APP_NAME
                                 message:@"There are no Mail accounts configured. You can add or create a Mail account in Settings"
                        inViewController:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    NSString *title = nil;
    NSString *message = nil;
    switch (result) {
        case MFMailComposeResultCancelled:
            title = @"Cancelled";
            message = @"Email was cancelled.";
            break;
        case MFMailComposeResultSaved:
            title = @"Saved";
            message = @"Email was saved as a draft.";
            break;
        case MFMailComposeResultSent:
            title = @"Success!";
            message = @"Email was sent successfully.";
            break;
        case MFMailComposeResultFailed:
            title = @"Error";
            message = @"Email was not sent.";
            break;
        default:
            title = @"Error";
            message = @"Email was not sent.";
            break;
    }

    [DMGUtilities showAlertWithTitle:title message:message inViewController:nil];
    [controller dismissViewControllerAnimated:YES completion:nil];
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
