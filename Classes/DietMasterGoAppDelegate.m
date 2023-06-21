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
#import "DMUser.h"

@import StoreKit;
@import Firebase;

#define D_MINUTE	60
#define D_HOUR		3600
#define D_DAY		86400
#define D_WEEK		604800
#define D_YEAR		31556926

@implementation DietMasterGoAppDelegate

@synthesize viewController, navigationController, loginViewController;
@synthesize splashView;
@synthesize incomingDBFilePath;
@synthesize isSessionExp;
@synthesize isFromAlert;
@synthesize caloriesremaning;
@synthesize strchekeditornot;

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

    // NOTE: The RootViewController is created in the SceneDelegate now.

    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    DMLog(@"Handle the URL: %@", url);
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSString *filepath = [url path];
    incomingDBFilePath = @"";
    
    if ([sourceApplication isEqualToString:@"com.apple.mobilemail"]) {
        incomingDBFilePath = [[NSString alloc] initWithFormat:@"%@", filepath];
        [self confirmUpdateDatabase];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    DMLog(@"Open the URL: %@", url);
    
    BOOL userLogout = [[NSUserDefaults standardUserDefaults] boolForKey:@"logout_dietmastergo"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if ([prefs boolForKey:@"user_loggedin"] == NO || userLogout == YES) {
        NSString *authString = [url absoluteString];
        authString = [authString stringByReplacingOccurrencesOfString:@"dietmastersoftware://" withString:@""];
        
        if (!loginViewController) {
            loginViewController = [[LoginViewController alloc] init];
            loginViewController.view.frame = [[UIScreen mainScreen] applicationFrame];
            loginViewController.view.tag = 40;
            loginViewController.view.alpha = 0.0;
            loginViewController.view.hidden = YES;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userLoginFinished:) name:@"UserLoginFinished" object:nil];
        
        if (loginViewController.view.hidden == YES) {
            
            loginViewController.view.frame = [[UIScreen mainScreen] applicationFrame];
            loginViewController.view.tag = 40;
            loginViewController.view.alpha = 0.0;
            loginViewController.view.hidden = NO;
            
            [self.window insertSubview:[loginViewController view] atIndex:0];
            [self.window bringSubviewToFront:loginViewController.view];
            
            [UIView animateWithDuration:0.75 animations:^{
                loginViewController.view.alpha = 1.0;
            }];

            UIView *v = [self.window viewWithTag:30];
            v.alpha = 0.0;
            v.hidden = YES;
            
            UIView *v1 = [self.window viewWithTag:35];
            v1.alpha = 0.0;
            v1.hidden = YES;
        }
        
        [loginViewController loginFromUrl:authString];
    }
    return YES;
}

- (void)loginFromUrl:(NSString *)loginUrl {
    BOOL userLogout = [[NSUserDefaults standardUserDefaults] boolForKey:@"logout_dietmastergo"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if ([prefs boolForKey:@"user_loggedin"] == NO || userLogout == YES) {
        if (!loginViewController) {
            loginViewController = [[LoginViewController alloc] init];
            loginViewController.view.frame = [[UIScreen mainScreen] applicationFrame];
            loginViewController.view.tag = 40;
            loginViewController.view.alpha = 0.0;
            loginViewController.view.hidden = YES;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userLoginFinished:) name:@"UserLoginFinished" object:nil];
        
        if (loginViewController.view.hidden == YES) {
            
            loginViewController.view.frame = [[UIScreen mainScreen] applicationFrame];
            loginViewController.view.tag = 40;
            loginViewController.view.alpha = 0.0;
            loginViewController.view.hidden = NO;
            
            [self.window insertSubview:[loginViewController view] atIndex:0];
            [self.window bringSubviewToFront:loginViewController.view];
                        
            [UIView animateWithDuration:0.75 animations:^{
                loginViewController.view.alpha = 1.0;
            }];

            UIView *v = [self.window viewWithTag:30];
            v.alpha = 0.0;
            v.hidden = YES;
            
            UIView *v1 = [self.window viewWithTag:35];
            v1.alpha = 0.0;
            v1.hidden = YES;
        }
        
        [loginViewController loginFromUrl:loginUrl];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSString *lastUpdate = [formatter stringFromDate:[[NSUserDefaults standardUserDefaults] valueForKey:@"lastsyncdate"]];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    [dietmasterEngine saveMealItems:lastUpdate]; //should not be passing nil
    [dietmasterEngine saveMealPlanArray];
    [dietmasterEngine saveGroceryListArray];
    [dietmasterEngine saveMyMovesAssignedOnDateArray];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (self.selectedIndex == 4) {
        
    }
    else
    {
        [self checkUserLogin];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
        if (![db open]) {
            DMLog(@"Could not open db.");
        }
        
#pragma mark ON APP LOAD
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [paths objectAtIndex:0];
        NSString *fullPath = [path stringByAppendingPathComponent:@"DMGO_v3.9.2.sqlite"];
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL exists = [fm fileExistsAtPath:fullPath];
        if (exists) {
            [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:fullPath]];
        }
        
        if ([dietmasterEngine hasMealPlanSaved]) {
            [dietmasterEngine loadSavedMealPlan];
        }
        
        if ([dietmasterEngine hasMyMovesAssignedSaved]){
            [dietmasterEngine loadMyMovesAssignedOnDateList];
        }
        
        if ([dietmasterEngine hasGroceryListSaved]) {
            [dietmasterEngine loadSavedGroceryList];
        }
        
        if ([dietmasterEngine hasMyMovesAssignedSaved]) {
            [dietmasterEngine loadMyMovesAssignedOnDateList];
        }
                
        BOOL upgraded11 = [[NSUserDefaults standardUserDefaults] boolForKey:@"1.1"];
        if (upgraded11 == NO && [prefs boolForKey:@"user_loggedin"] == YES) {
            [self performSelectorInBackground:@selector(updateMeasureTable) withObject:nil];
        }
                
        BOOL upgraded102 = [[NSUserDefaults standardUserDefaults] boolForKey:@"1.0.2"];
        if (upgraded102 == NO) {
            
            DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
            FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
            if (![db open]) {
                DMLog(@"Could not open db.");
            }
            
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
            
            DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
            FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
            if (![db open]) {
                DMLog(@"Could not open db.");
            }
            
            BOOL upgraded103 = [[NSUserDefaults standardUserDefaults] boolForKey:@"1.0.3"];
            if (upgraded103 == NO && [prefs boolForKey:@"user_loggedin"] == YES) {
                
                [prefs setBool:YES forKey:@"1.0.3"];
            }
            
            [prefs setBool:YES forKey:@"1.1.11.1"];
        }
        
        BOOL upgraded121 = [[NSUserDefaults standardUserDefaults] boolForKey:@"1.2.1.1"];
        upgraded121 = NO;
        if (upgraded121 == NO) {
            
            DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
            FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
            [db close];
            if (![db open]) {
                DMLog(@"Could not open db.");
            }
            
            if (![db columnExists:@"FactualID" inTableWithName:@"Food"]) {
                NSString *updateSQL = @"ALTER TABLE Food ADD FactualID TEXT";
                [db beginImmediateTransaction];
                [db executeUpdate:updateSQL];
                if ([db hadError]) {
                    DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                }
                [db commit];
            }
            
            [prefs setBool:YES forKey:@"1.2.1.1"];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        BOOL upgraded14 = [[NSUserDefaults standardUserDefaults] boolForKey:@"1.4"];
        if (upgraded14 == NO) {
            
            DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
            FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
            [db close];
            if (![db open]) {
                DMLog(@"Could not open db.");
            }
            
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
            
            DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
            FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
            [db close];
            if (![db open]) {
                DMLog(@"Could not open db.");
            }
            
            if (![db tableExists:@"Messages"]) {
                [db beginTransaction];
                NSString *messageSQL = @"CREATE TABLE 'Messages' (Id INTEGER, 'Text' TEXT, Sender TEXT, 'Date' DATE, Read BOOLEAN)";
                [db executeUpdate:messageSQL];
                if ([db hadError]) {
                    DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                }
                [db commit];
            }
            
            [prefs setBool:YES forKey:@"1.5"];
        }
        
        // MIGRATING, Moving old tables out of the way.
//        NSString *dropTableSQL1;
//        [db beginTransaction];
//        dropTableSQL1 = [NSString stringWithFormat:@"DROP TABLE IF EXISTS MoveTags"];
//        [db executeUpdate:dropTableSQL1];
//        dropTableSQL1 = [NSString stringWithFormat:@"DROP TABLE IF EXISTS MoveCategories"];
//        [db executeUpdate:dropTableSQL1];
//        dropTableSQL1 = [NSString stringWithFormat:@"DROP TABLE IF EXISTS MovesCategories"];
//        [db executeUpdate:dropTableSQL1];
//        dropTableSQL1 = [NSString stringWithFormat:@"DROP TABLE IF EXISTS MovesTags"];
//        [db executeUpdate:dropTableSQL1];
//        dropTableSQL1 = [NSString stringWithFormat:@"DROP TABLE IF EXISTS MovesTags"];
//        [db executeUpdate:dropTableSQL1];
//        dropTableSQL1 = [NSString stringWithFormat:@"DROP TABLE IF EXISTS MoveDetailsTable"];
//        [db executeUpdate:dropTableSQL1];
//        [db commit];

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

        BOOL userLogout = [[NSUserDefaults standardUserDefaults] boolForKey:@"logout_dietmastergo"];
        if ([prefs boolForKey:@"user_loggedin"] == YES && userLogout == NO) {
            NSString *pngFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"SplashImage.png"];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:pngFilePath]) {
                [self performSelector:@selector(removeSplashScreen) withObject:nil afterDelay:3.5];
            }
            else {
                
            }
        }
        
        if ([prefs boolForKey:@"user_loggedin"] == YES) {
            [self syncDatabase];
        }

//        [dietmasterEngine downloadFileIfUpdatedInBackground];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)clearTableData {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    [db beginTransaction];
    
    NSString * deleteServerUserPlanList = [NSString stringWithFormat: @"DELETE FROM ServerUserPlanList"];
    [db executeUpdate:deleteServerUserPlanList];
    
    NSString * deleteServerUserPlanDateList = [NSString stringWithFormat: @"DELETE FROM ServerUserPlanDateList"];
    [db executeUpdate:deleteServerUserPlanDateList];
    
    NSString * deleteServerUserPlanMoveList = [NSString stringWithFormat: @"DELETE FROM ServerUserPlanMoveList"];
    [db executeUpdate:deleteServerUserPlanMoveList];
    
    NSString * deleteServerUserPlanMoveSetList = [NSString stringWithFormat: @"DELETE FROM ServerUserPlanMoveSetList"];
    [db executeUpdate:deleteServerUserPlanMoveSetList];
    
    NSString * deletePlanDateUniqueID_Table = [NSString stringWithFormat: @"DELETE FROM PlanDateUniqueID_Table"];
    [db executeUpdate:deletePlanDateUniqueID_Table];
    
    NSString * deletePlanDateTable = [NSString stringWithFormat: @"DELETE FROM PlanDateTable"];
    [db executeUpdate:deletePlanDateTable];
    
    NSString *deleteWeightlog = [NSString stringWithFormat:@"DELETE FROM weightlog"];
    [db executeUpdate:deleteWeightlog];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    [db commit];
}

#pragma mark - SPLASH METHODS

- (void)showSplashScreen {
    NSString *imageFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"SplashImage.png"];
    splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT)];
    splashView.contentMode = UIViewContentModeScaleAspectFill;
    splashView.image = [UIImage imageWithContentsOfFile:imageFilePath];
//    [window addSubview:splashView];
//    [window bringSubviewToFront:splashView];
}

- (void)removeSplashScreen {
    [splashView removeFromSuperview];
    splashView = nil;
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
        
        [dietmasterEngine purgeGroceryListArray];
        [dietmasterEngine purgeMealPlanArray];
        [viewController loadData];
        
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
            [db close];
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
        [viewController loadData];
    }
}

- (void)getUserLogin {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"logout_dietmastergo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (!loginViewController) {
        loginViewController = [[LoginViewController alloc] init];
        loginViewController.view.frame = [[UIScreen mainScreen] applicationFrame];
        loginViewController.view.tag = 40;
        loginViewController.view.alpha = 0.0;
        loginViewController.view.hidden = YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLoginFinished:) name:@"UserLoginFinished" object:nil];
    
    if (loginViewController.view.hidden == YES) {
        
        loginViewController.view.frame = [[UIScreen mainScreen] applicationFrame];
        loginViewController.view.tag = 40;
        loginViewController.view.alpha = 0.0;
        loginViewController.view.hidden = NO;
        
        [self.window insertSubview:[loginViewController view] atIndex:0];
        [self.window bringSubviewToFront:loginViewController.view];
        
        [UIView animateWithDuration:0.75 animations:^{
            loginViewController.view.alpha = 1.0;
        }];
        
        UIView *v = [self.window viewWithTag:30];
        v.alpha = 0.0;
        v.hidden = YES;
        
        UIView *v1 = [self.window viewWithTag:35];
        v1.alpha = 0.0;
        v1.hidden = YES;
    }
}

- (void)userLoginFinished:(NSString *)statusMessage {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"user_loggedin"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UserLoginFinished" object:nil];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:[NSDate date] forKey:@"lastmodified"];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_NAME message:@"Do you want to make changes to optional settings?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alertView.tag = 1;
    [alertView show];
    
    [self syncDatabase];
    
    [viewController loadData];
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
    [prefs synchronize];
    
}

- (void)syncDatabaseFailed:(NSString *)failedMessage {
    DMLog(@"SYNC FAIL: %@", failedMessage);
    [DMActivityIndicator hideActivityIndicator];

    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    dietmasterEngine.syncDatabaseDelegate = nil;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:nil forKey:@"lastmodified"];
    [prefs setValue:nil forKey:@"lastsyncdate"];
    [prefs synchronize];
}

//UpSync
- (void)syncUPDatabaseFinished:(NSString *)responseMessage {
    [self performSelector:@selector(callSyncDatabase) withObject:nil afterDelay:1.00];
}

-(void)callSyncDatabase
{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    dietmasterEngine.syncUPDatabaseDelegate = nil;
    
    dietmasterEngine.syncDatabaseDelegate = self;
    
    [dietmasterEngine syncDatabase];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:nil];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:[NSDate date] forKey:@"lastmodified"];
    [prefs synchronize];
}

- (void)syncUPDatabaseFailed:(NSString *)failedMessage {
    DMLog(@"SYNC FAIL: %@", failedMessage);
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    dietmasterEngine.syncUPDatabaseDelegate = nil;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:nil forKey:@"lastmodified"];
    [prefs setValue:nil forKey:@"lastsyncdate"];
    [prefs synchronize];
    
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

#pragma mark SYNC DATABASE
-(void)syncDatabase {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([prefs boolForKey:@"user_loggedin"] == YES) {
        
        MyMovesWebServices *soapWebService = [[MyMovesWebServices alloc] init];
        [soapWebService offlineSyncApi];
        
        [soapWebService getMyMovesData];
        
        if (![prefs valueForKey:@"lastmodified"]) {
            AppDel.isSessionExp = NO;
            DataFetcher *dataFetcher = [[DataFetcher alloc] init];
            [dataFetcher signInUserWithPassword:[prefs objectForKey:@"loginPwd"] completion:^(DMUser *user, NSString *status, NSString *message) {
                if (AppDel.isSessionExp == NO) {
                    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
                    dietmasterEngine.syncUPDatabaseDelegate = self;
                    [dietmasterEngine uploadDatabase];
                }
            }];
        }
        else {
            NSInteger hourSinceDate = [self hoursAfterDate:[prefs valueForKey:@"lastmodified"]];
            if (hourSinceDate >= 2) {
                
                AppDel.isSessionExp = NO;
                DataFetcher *dataFetcher = [[DataFetcher alloc] init];
                [dataFetcher signInUserWithPassword:[prefs objectForKey:@"loginPwd"] completion:^(DMUser *user, NSString *status, NSString *message) {
                    if (AppDel.isSessionExp == NO) {
                        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
                        dietmasterEngine.syncUPDatabaseDelegate = self;
                        [dietmasterEngine uploadDatabase];
                    }
                }];
            }
            else {
                AppDel.isSessionExp = NO;
                DataFetcher *dataFetcher = [[DataFetcher alloc] init];
                [dataFetcher signInUserWithPassword:[prefs objectForKey:@"loginPwd"] completion:^(DMUser *user, NSString *status, NSString *message) {
                    if (AppDel.isSessionExp == NO) {
                        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
                        dietmasterEngine.syncUPDatabaseDelegate = self;
                        [dietmasterEngine uploadDatabase];
                    }
                }];
            }
        }
    }
}

#pragma mark UPDATE 1.1. METHOD
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
            
            for (NSString *sql in measureArray) {
                [db beginTransaction];
                [db executeUpdate:sql];
                if ([db hadError]) {
                    DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                    success = NO;
                }
                [db commit];
            }
        }
    }
    
    if (success) {
        [prefs setBool:YES forKey:@"1.1"];
        [prefs synchronize];
    }
}

#pragma mark REMOVE DB FROM ICLOUD BACKUP
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

#pragma mark IMPORT DATABASE METHODS

- (void)confirmUpdateDatabase {
    if (incomingDBFilePath == nil || incomingDBFilePath.length == 0) {
        UIAlertView *alert;
        alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No database was found. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert setTag:1000];
        [alert show];
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Import New Database"];
    [alert setMessage:@"Are you sure you wish to overwrite your existing database? Any data not synchronized with the cloud system will be lost."];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"No"];
    [alert addButtonWithTitle:@"Yes"];
    [alert setTag:223];
    [alert show];
}

-(void)confirmDatabaseUserPassword {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm Mobile Password"
                                                    message:@"Please enter the Mobile Password associated with this database."
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Ok", nil];
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    [alert setTag:321];
    [alert show];
}

#pragma mark ALERT VIEW DELEGATE
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 223) {
        if (buttonIndex == 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.15 * NSEC_PER_SEC), dispatch_get_main_queue(), ^
                           {
                UIAlertView *alert;
                alert = [[UIAlertView alloc] initWithTitle:@"Cancelled" message:@"Importing of new database was cancelled." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert setTag:1000];
                [alert show];
            });
            
        }
        else if (buttonIndex == 1) {
            [self confirmDatabaseUserPassword];
        }
    }
    
    if (alertView.tag == 1005) {
        [self performSelector:@selector(confirmDatabaseUserPassword) withObject:nil afterDelay:0.65];
    }
    
    if (alertView.tag == 321) {
        if (buttonIndex == 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.15 * NSEC_PER_SEC), dispatch_get_main_queue(), ^
                           {
                UIAlertView *alert;
                alert = [[UIAlertView alloc] initWithTitle:@"Cancelled" message:@"Importing of new database was cancelled." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert setTag:1000];
                [alert show];
            });
            
        }
        else if (buttonIndex == 1) {
            NSString *mobilePassword = [[alertView textFieldAtIndex:0] text];
            
            if (mobilePassword == nil || mobilePassword.length == 0) {
                UIAlertView *alert;
                alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Mobile Password is required. Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert setTag:1005];
                [alert show];
                return;
            }
            
            [DMActivityIndicator showActivityIndicator];

            DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   mobilePassword, @"mobilePassword",
                                   incomingDBFilePath, @"incomingDBFilePath",
                                   nil];
            [dietmasterEngine processIncomingDatabase:dict];
            
        }
    }
    else if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            AppDel.isFromAlert = YES;
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFromAlert"];
//            [rootController setSelectedIndex:4];
        }
        else {
            
        }
    }
}

-(void)processDatabaseMessage:(NSDictionary *)messageDict {
    [DMActivityIndicator hideActivityIndicator];

    int tag = 112233;
    if ([[messageDict valueForKey:@"try_password_again"] boolValue] == YES) {
        tag = 1005;
    }
    
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:[messageDict valueForKey:@"title"] message:[messageDict valueForKey:@"message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert setTag:tag];
    [alert show];
}


//HHT mail change
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1001){
        if (buttonIndex == alertView.cancelButtonIndex){
            return;
        }
        else if (buttonIndex == 1){
            [self openMailForApp];
        }
    }
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
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:APP_NAME message:@"There are no Mail accounts configured. You can add or create a Mail account in Settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    UIAlertView *alert;
    switch (result) {
        case MFMailComposeResultCancelled:
            alert = [[UIAlertView alloc] initWithTitle:@"Cancelled" message:@"Email was cancelled." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            break;
        case MFMailComposeResultSaved:
            alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Email was saved as a draft." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            break;
        case MFMailComposeResultSent:
            alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Email was sent successfully." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            break;
        case MFMailComposeResultFailed:
            alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Email was not sent." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            break;
        default:
            alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Email was not sent." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            break;
    }
    [alert show];
    
    // This ugly thing is required because dismissModalViewControllerAnimated causes a crash
    // if called right away when "Cancel" is touched.
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_current_queue(), ^
    //                   {
    [AppDel.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    //    });
    
    // Remove Zip File
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.05 * NSEC_PER_SEC), dispatch_get_current_queue(), ^
    //                   {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *zipFilePath = [documentsDirectory stringByAppendingPathComponent:@"dietmaster_db.dmgo"];
    if([[NSFileManager defaultManager] fileExistsAtPath:zipFilePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:zipFilePath error:NULL];
        DMLog(@"Temp DB Zip File Deleted...");
    }
    //    });
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
