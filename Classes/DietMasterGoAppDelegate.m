//  DietMasterGoAppDelegate.m
//  DietMasterGo
//
//  Created by Andrew Moffitt on 11/23/10.
//  Copyright 2010 AE Studios. All rights reserved.

#import "DietMasterGoAppDelegate.h"
#import "DietMasterGoViewController.h"
#import "DietMasterGoController_Old.h"
#import "MyLogViewController.h"
#import "LoginViewController.h"
#import "DietmasterEngine.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "MyMovesDetailsViewController.h"
#import "PopUpView.h"
#import "UITextViewWorkaround.h"
#import "PurchaseIAPHelper.h"

//HHT remove SplunkMint
//#import <SplunkMint/SplunkMint.h>

@import StoreKit;
@import Firebase;

#define D_MINUTE	60
#define D_HOUR		3600
#define D_DAY		86400
#define D_WEEK		604800
#define D_YEAR		31556926

@implementation DietMasterGoAppDelegate

@synthesize window, viewController, navigationController, rootController, loginViewController;
@synthesize splashView;
@synthesize incomingDBFilePath;
@synthesize isSessionExp;
@synthesize userLoginWS;
@synthesize isFromAlert;
@synthesize caloriesremaning;
@synthesize strchekeditornot;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    //    dietmasterEngine.sendAllServerData = true;
    [UITextViewWorkaround executeWorkaround];
    
    [PurchaseIAPHelper sharedInstance];
    
    /*==========================================To Enable & Disable MyMoves==========================================*/
        [[NSUserDefaults standardUserDefaults]setObject:@"MyMoves" forKey:@"switch"]; // To Enable MyMoves
//        [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"switch"]; // To disable MyMoves
    /*================================================================================================================*/
        

    /*==========================================To Enable & Disable Old design==========================================*/
        [[NSUserDefaults standardUserDefaults]setObject:@"NewDesign" forKey:@"changeDesign"]; /// To Enable NEW DESIGN
    //    [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"changeDesign"];          /// To Enable OLD DESIGN
    /*================================================================================================================*/
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
//    [Fabric with:@[[Crashlytics class]]];
    [FIRApp configure];
    //    [[UITabBar appearance] setSelectedImageTintColor:[UIColor redColor]];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    
    if (@available(iOS 15.0, *))
    {
        UITableView.appearance.sectionHeaderTopPadding = 0;
        
    }
    
    self.isFromBarcode = NO;
    viewController.view.tag = 35;
    viewController.view.alpha = 0.0;
    viewController.view.hidden = YES;
    rootController.view.tag = 30;
    rootController.view.alpha = 0.0;
    rootController.view.hidden = YES;
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"changeDesign"]  isEqual: @"NewDesign"])
    {
        self.window.rootViewController = rootController;
        [self.window makeKeyAndVisible];
        
        UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
        tabBarController.view.frame = CGRectMake(viewController.view.frame.origin.x, viewController.view.frame.origin.y, viewController.view.frame.size.width, viewController.view.frame.size.height);
        tabBarController.delegate = self;
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    else
    {
        self.window.rootViewController = rootController;
        [self.window makeKeyAndVisible];
        
        UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
        tabBarController.delegate = self;
        UITabBar *tabBar = tabBarController.tabBar;
        
        UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
        UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
        UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];
        UITabBarItem *tabBarItem4 = [tabBar.items objectAtIndex:3];
        UITabBarItem *tabBarItem5 = [tabBar.items objectAtIndex:4];
        
        tabBarItem1.selectedImage = [[UIImage imageNamed:@"today_active.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        tabBarItem1.image = [[UIImage imageNamed:@"today_inactive.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        
        tabBarItem2.selectedImage = [[UIImage imageNamed:@"mygoal_active.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        tabBarItem2.image = [[UIImage imageNamed:@"mygoal_inactive.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        
        tabBarItem3.selectedImage = [[UIImage imageNamed:@"mylog_active.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        tabBarItem3.image = [[UIImage imageNamed:@"mylog_inactive.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        
        
        tabBarItem4.selectedImage = [[UIImage imageNamed:@"myplan_active.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        tabBarItem4.image = [[UIImage imageNamed:@"myplan_inactive.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        
        //    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"switch"]  isEqual: @"MyMoves"])
        //    {
        //        tabBarItem5.selectedImage = [[UIImage imageNamed:@"MyMovesactives.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        //        tabBarItem5.image = [[UIImage imageNamed:@"MyMovesinactives.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        //    }
        //    else
        //    {
        tabBarItem5.selectedImage = [[UIImage imageNamed:@"settings_active.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        tabBarItem5.image = [[UIImage imageNamed:@"settings_inactive.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        //    }
    }
    //    [self hidetabbar];
    return YES;
}

- (void) hidetabbar {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.0];

    for(UIView *view in rootController.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            if (rootController) {
                [view setFrame:CGRectMake(view.frame.origin.x, 431, view.frame.size.width, view.frame.size.height)];
            } else {
                [view setFrame:CGRectMake(view.frame.origin.x, 480, view.frame.size.width, view.frame.size.height)];
            }
        } else {
            if (rootController) {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 431)];
            } else {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 480)];
            }
        }
    }
    [UIView commitAnimations];
    rootController = !rootController;
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"Handle the URL: %@", url);
    return YES;
}

//HHT (Set taskMode to View when user select Setting tab)
-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (tabBarController.selectedIndex == 4){
        DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
        dietmasterEngine.taskMode = @"View";
    }
    //HHT save selected current index for scan page (Managefood)
    self.selectedIndex = (int)tabBarController.selectedIndex;
    
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
    NSLog(@"Open the URL: %@", url);
    
    [[NSUserDefaults standardUserDefaults] synchronize];
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
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.75];
            [UIView setAnimationDelegate:self];
            loginViewController.view.alpha = 1.0;
            [UIView commitAnimations];
            
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

-(void)loginFromUrl:(NSString *)loginUrl {
    [[NSUserDefaults standardUserDefaults] synchronize];
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
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.75];
            [UIView setAnimationDelegate:self];
            loginViewController.view.alpha = 1.0;
            [UIView commitAnimations];
            
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

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
//    NSString *currentDate = [formatter stringFromDate:[NSDate date]];
    NSString *lastUpdate = [formatter stringFromDate:[[NSUserDefaults standardUserDefaults] valueForKey:@"lastsyncdate"]];
    
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    [dietmasterEngine saveMealItems:lastUpdate]; //should not be passing nil
    [dietmasterEngine saveMealPlanArray];
    [dietmasterEngine saveGroceryListArray];
    [dietmasterEngine saveMyMovesAssignedOnDateArray];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *dToken = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    dToken = [dToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    [DietmasterEngine instance].deviceToken = dToken;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    if (self.selectedIndex == 4) {
        
    }
    else
    {
        [self checkUserLogin];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
        //        dietmasterEngine.sendAllServerData = true;
        FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
        if (![db open]) {
            NSLog(@"Could not open db.");
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
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        BOOL upgraded11 = [[NSUserDefaults standardUserDefaults] boolForKey:@"1.1"];
        if (upgraded11 == NO && [prefs boolForKey:@"user_loggedin"] == YES) {
            [self performSelectorInBackground:@selector(updateMeasureTable) withObject:nil];
        }
        
        BOOL upgraded103 = [[NSUserDefaults standardUserDefaults] boolForKey:@"1.0.3"];
        if (upgraded103 == NO && [prefs boolForKey:@"user_loggedin"] == YES) {
            
            if (![prefs valueForKey:@"splashimage_filename"]) {
            }
            
            [prefs setBool:YES forKey:@"1.0.3"];
        }
        
        BOOL upgraded102 = [[NSUserDefaults standardUserDefaults] boolForKey:@"1.0.2"];
        if (upgraded102 == NO) {
            
            DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
            FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
            if (![db open]) {
                NSLog(@"Could not open db.");
            }
            
            NSString *updateSQL = @"DELETE FROM Food WHERE Name LIKE '%infant%'";
            [db beginTransaction];
            [db executeUpdate:updateSQL];
            if ([db hadError]) {
                NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
            [db commit];
            
            NSString *updateSQL2 = @"DELETE FROM Food WHERE Name LIKE '%babyfood%'";
            [db beginTransaction];
            [db executeUpdate:updateSQL2];
            if ([db hadError]) {
                NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
            [db commit];
            
            NSString *updateSQL3 = @"DELETE FROM Food WHERE Name LIKE '%baby meal%'";
            [db beginTransaction];
            [db executeUpdate:updateSQL3];
            if ([db hadError]) {
                NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
            [db commit];
            
            [prefs setBool:YES forKey:@"1.0.2"];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        BOOL upgraded111 = [[NSUserDefaults standardUserDefaults] boolForKey:@"1.1.11.1"];
        if (upgraded111 == NO) {
            
            DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
            FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
            if (![db open]) {
                NSLog(@"Could not open db.");
            }
            
            BOOL upgraded103 = [[NSUserDefaults standardUserDefaults] boolForKey:@"1.0.3"];
            if (upgraded103 == NO && [prefs boolForKey:@"user_loggedin"] == YES) {
                
                [prefs setBool:YES forKey:@"1.0.3"];
            }
            
            [prefs setBool:YES forKey:@"1.1.11.1"];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        BOOL upgraded121 = [[NSUserDefaults standardUserDefaults] boolForKey:@"1.2.1.1"];
        upgraded121 = NO;
        if (upgraded121 == NO) {
            
            DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
            FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
            [db close];
            if (![db open]) {
                NSLog(@"Could not open db.");
            }
            
            if (![db columnExists:@"Food" columnName:@"FactualID"]) {
                NSString *updateSQL = @"ALTER TABLE Food ADD FactualID VARCHAR(150)";
                [db beginImmediateTransaction];
                [db executeUpdate:updateSQL];
                if ([db hadError]) {
                    NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                }
                [db commit];
            }
            
            [prefs setBool:YES forKey:@"1.2.1.1"];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        BOOL upgraded14 = [[NSUserDefaults standardUserDefaults] boolForKey:@"1.4"];
        if (upgraded14 == NO) {
            
            DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
            FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
            [db close];
            if (![db open]) {
                NSLog(@"Could not open db.");
            }
            
            if (![db columnExists:@"user" columnName:@"ProteinRatio"]) {
                [db beginTransaction];
                NSString *proteinSQL = @"ALTER TABLE user ADD ProteinRatio INTEGER DEFAULT 0";
                [db executeUpdate:proteinSQL];
                if ([db hadError]) {
                    NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                }
                [db commit];
            }
            
            if (![db columnExists:@"user" columnName:@"CarbRatio"]) {
                [db beginTransaction];
                NSString *carbSQL = @"ALTER TABLE user ADD CarbRatio INTEGER DEFAULT 0";
                [db executeUpdate:carbSQL];
                if ([db hadError]) {
                    NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                }
                [db commit];
            }
            
            if (![db columnExists:@"user" columnName:@"FatRatio"]) {
                [db beginTransaction];
                NSString *fatSQL = @"ALTER TABLE user ADD FatRatio INTEGER DEFAULT 0";
                [db executeUpdate:fatSQL];
                if ([db hadError]) {
                    NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                }
                [db commit];
            }
            
            if (![db columnExists:@"user" columnName:@"CompanyID"]) {
                [db beginTransaction];
                NSString *companySQL = @"ALTER TABLE user ADD CompanyID INTEGER DEFAULT 0";
                [db executeUpdate:companySQL];
                if ([db hadError]) {
                    NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                }
                [db commit];
            }
            
            if (![db columnExists:@"weightlog" columnName:@"bodyfat"]) {
                [db beginTransaction];
                NSString *bodyFatSQL = @"ALTER TABLE weightlog ADD bodyfat REAL DEFAULT 0";
                [db executeUpdate:bodyFatSQL];
                if ([db hadError]) {
                    NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                }
                [db commit];
            }
            
            if (![db columnExists:@"weightlog" columnName:@"entry_type"]) {
                [db beginTransaction];
                NSString *entryTypeSQL = @"ALTER TABLE weightlog ADD entry_type INTEGER DEFAULT 0";
                [db executeUpdate:entryTypeSQL];
                if ([db hadError]) {
                    NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                }
                [db commit];
            }
            
            [prefs setBool:YES forKey:@"1.4"];
        }
        
        BOOL upgraded15 = [[NSUserDefaults standardUserDefaults] boolForKey:@"1.5"];
        if (upgraded15 == NO) {
            
            DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
            FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
            [db close];
            if (![db open]) {
                NSLog(@"Could not open db.");
            }
            
            if (![db tableExists:@"Messages"]) {
                [db beginTransaction];
                NSString *messageSQL = @"CREATE TABLE 'Messages' (Id INTEGER, 'Text' TEXT, Sender TEXT, 'Date' DATE, Read BOOLEAN)";
                [db executeUpdate:messageSQL];
                if ([db hadError]) {
                    NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                }
                [db commit];
            }
            
            [prefs setBool:YES forKey:@"1.5"];
        }
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
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
-(void)clearTableData
{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    
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
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
    
}


#pragma mark SPLASH METHODS
-(void)showSplashScreen {
    NSString *imageFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"SplashImage.png"];
    splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT)];
    splashView.contentMode = UIViewContentModeScaleAspectFill;
    splashView.image = [UIImage imageWithContentsOfFile:imageFilePath];
    [window addSubview:splashView];
    [window bringSubviewToFront:splashView];
}

-(void)removeSplashScreen {
    [splashView removeFromSuperview];
    splashView = nil;
}

#pragma mark -
#pragma mark Memory management
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    
}

#pragma mark LOAD VIEW METHODS
-(void)loadMainViews {
    [viewController loadData];
    
    UIView *v = [self.window viewWithTag:30];
    UIView *v1 = [self.window viewWithTag:35];
    UIView *v2 = [self.window viewWithTag:40];
    if(!self.isFromBarcode){
        rootController.selectedIndex = 0;
    }
    else {
        self.isFromBarcode = NO;
    }
    
    if (v.hidden == YES) {
        v.hidden = NO;
        v1.hidden = NO;
        v1.alpha = 1.0;
        v.alpha = 1.0;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.75];
        [UIView setAnimationDelegate:self];
        v2.alpha = 0.0;
        [UIView commitAnimations];
        
        v2.hidden = YES;
        [self.window sendSubviewToBack:v2];
    }
}

#pragma mark USER LOGIN
-(void)checkUserLogin {
    [[NSUserDefaults standardUserDefaults] synchronize];
    BOOL userLogout = [[NSUserDefaults standardUserDefaults] boolForKey:@"logout_dietmastergo"];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if ([prefs boolForKey:@"user_loggedin"] == NO || userLogout == YES) {
        DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
//        NSArray *paths2 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *tempPath2 = [paths2 objectAtIndex:0];
//        NSFileManager *fileManager2 = [NSFileManager defaultManager];
//        NSString *tempFile2 = [tempPath2 stringByAppendingPathComponent:@"DMGO_v3.9.2.sqlite"];
//        [fileManager2 removeItemAtPath:tempFile2 error:NULL];
//        if(![[NSFileManager defaultManager] fileExistsAtPath: tempFile2]) {
//            NSLog(@"DMG.sqlite does not exist anymore");
//        }
        
#pragma mark LOG OUT
        
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"userid_dietmastergo"];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"companyemail1_dietmastergo"];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"companyemail2_dietmastergo"];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"companyname_dietmastergo"];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"authkey_dietmastergo"];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"lastmodified_splash"];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"splashimage_filename"];
        
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setBool:NO forKey:@"user_loggedin"];
        
        //keep these defaulted to app build hardcode. this effects CREATE USERS
        [prefs setValue:@"3271" forKey:@"companyid_dietmastergo"];
        [prefs setValue:@"p54118!" forKey:@"companyPassThru_dietmastergo"];
        
        [prefs synchronize];
        
        [dietmasterEngine purgeGroceryListArray];
        [dietmasterEngine purgeMealPlanArray];
        [viewController loadData];
        
        #pragma mark DELETE ALL FOOD LOG ITEMS
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
    }
    else {
#pragma mark Logged In
        [self loadMainViews];
        [viewController loadData];
    }
}

-(void)getUserLogin {
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
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.75];
        [UIView setAnimationDelegate:self];
        loginViewController.view.alpha = 1.0;
        [UIView commitAnimations];
        
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
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UserLoginFinished" object:nil]; //today
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:[NSDate date] forKey:@"lastmodified"];
    [prefs synchronize];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:APP_NAME message:@"Do you want to make changes to optional settings?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alertView.tag = 1;
    [alertView show];
    [alertView release];
    
    [self syncDatabase];
    
    [self loadMainViews];
}

//DownSync
#pragma mark SYNC DELEGATE METHODS
- (void)syncDatabaseFinished:(NSString *)responseMessage {
    [self performSelectorOnMainThread:@selector(hideLoading) withObject:nil waitUntilDone:NO];
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    dietmasterEngine.syncDatabaseDelegate = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:nil];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:[NSDate date] forKey:@"lastmodified"];
    [prefs synchronize];
    
}

- (void)syncDatabaseFailed:(NSString *)failedMessage {
    NSLog(@"SYNC FAIL: %@", failedMessage);
    [self performSelectorOnMainThread:@selector(hideLoading) withObject:nil waitUntilDone:NO];

    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    dietmasterEngine.syncDatabaseDelegate = nil;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:nil forKey:@"lastmodified"];
    [prefs setValue:nil forKey:@"lastsyncdate"];
    [prefs synchronize];
        
    //HHT mail change
//    UIAlertView *alert;
//    alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"An error occurred while processing. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Send Database to support",nil];
//    alert.tag = 1001;
//    [alert show];
//    [alert release];
}

//UpSync
- (void)syncUPDatabaseFinished:(NSString *)responseMessage {
    [self performSelector:@selector(callSyncDatabase) withObject:nil afterDelay:1.00];
}

-(void)callSyncDatabase
{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    dietmasterEngine.syncUPDatabaseDelegate = nil;
    
    dietmasterEngine.syncDatabaseDelegate = self;
    
    [dietmasterEngine syncDatabase];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:nil];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:[NSDate date] forKey:@"lastmodified"];
    [prefs synchronize];
}

- (void)syncUPDatabaseFailed:(NSString *)failedMessage {
    NSLog(@"SYNC FAIL: %@", failedMessage);
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    dietmasterEngine.syncUPDatabaseDelegate = nil;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:nil forKey:@"lastmodified"];
    [prefs setValue:nil forKey:@"lastsyncdate"];
    [prefs synchronize];
    
    [self performSelectorOnMainThread:@selector(hideLoading) withObject:nil waitUntilDone:NO];
    
    //HHT mail change
//    UIAlertView *alert;
//    alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"An error occurred while processing. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Send Database to support",nil];
//    alert.tag = 1001;
//    [alert show];
//    [alert release];
    
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
            self.userLoginWS = [[UserLoginWebService alloc] init];
            userLoginWS.wsAuthenticateUserDelegate = self;
            [userLoginWS callWebservice:[[NSUserDefaults standardUserDefaults] objectForKey:@"loginPwd"]];
            [userLoginWS release];
        }
        else {
            NSInteger hourSinceDate = [self hoursAfterDate:[prefs valueForKey:@"lastmodified"]];
            if (hourSinceDate >= 2) {
                
                AppDel.isSessionExp = NO;
                self.userLoginWS = [[UserLoginWebService alloc] init];
                userLoginWS.wsAuthenticateUserDelegate = self;
                [userLoginWS callWebservice:[[NSUserDefaults standardUserDefaults] objectForKey:@"loginPwd"]];
                [userLoginWS release];
            }
            else {
                AppDel.isSessionExp = NO;
                self.userLoginWS = [[UserLoginWebService alloc] init];
                userLoginWS.wsAuthenticateUserDelegate = self;
                [userLoginWS callWebservice:[[NSUserDefaults standardUserDefaults] objectForKey:@"loginPwd"]];
                [userLoginWS release];
            }
        }
    }
}

#pragma mark LOGIN AUTH DELEGATE METHODS
- (void)getAuthenticateUserFinished:(NSMutableArray *)responseArray {
    if (AppDel.isSessionExp == YES) {
        
    }
    else {
//        [self performSelectorOnMainThread:@selector(showLoading) withObject:nil waitUntilDone:NO];
//        [HUD setLabelText:@"Syncing..."];
        DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
        dietmasterEngine.syncUPDatabaseDelegate = self;
        [dietmasterEngine uploadDatabase];
    }
}

- (void)dealloc {
    incomingDBFilePath = nil;
    
    [viewController release];
    [navigationController release];
    [window release];
    [loginViewController release];
    
    [super dealloc];
}

#pragma mark UPDATE 1.1. METHOD
-(void)updateMeasureTable {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
        NSLog(@"Could not open db.");
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
                    NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
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

#pragma mark -
#pragma mark MBProgressHUDDelegate methods
-(void)showLoading {
    HUD = [[MBProgressHUD showHUDAddedTo:self.window animated:YES] retain];
}

-(void)hideLoading {
    [HUD hide:YES afterDelay:0.5];
}

-(void)hideLoadingNow {
    [HUD hide:YES afterDelay:0.0];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    [HUD removeFromSuperview];
    [HUD release];
    HUD = nil;
}

- (void)showCompleted {
    HUD = [[MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES] retain];
    
    HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
    HUD.mode = MBProgressHUDModeCustomView;
    
    HUD.delegate = nil;
    HUD.labelText = @"Completed";
    
    [HUD show:YES];
    [HUD hide:YES afterDelay:1.0];
}

-(void)changeLoadingMessage:(NSString *)message {
    HUD.labelText = message;
}

-(void)updateLoadingProgress:(double)progress {
    HUD.progress = progress;
}

-(void)showWithProgressIndicator {
    HUD = [[MBProgressHUD alloc] initWithView:self.window];
    [self.window addSubview:HUD];
    
    HUD.mode = MBProgressHUDModeDeterminate;
    HUD.delegate = self;
    HUD.labelText = @"Loading";
    
    HUD.progress = 0.0;
    
    [HUD showWhileExecuting:@selector(myProgressTask) onTarget:self withObject:nil animated:YES];
}

#pragma mark REMOVE DB FROM ICLOUD BACKUP
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success) {
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

#pragma mark IMPORT DATABASE METHODS

-(void)confirmUpdateDatabase {
    if (incomingDBFilePath == nil || incomingDBFilePath.length == 0) {
        UIAlertView *alert;
        alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No database was found. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert setTag:1000];
        [alert show];
        [alert release];
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
    [alert release];
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
    [alert release];
    
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
                [alert release];
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
                [alert release];
            });
            
        }
        else if (buttonIndex == 1) {
            NSString *mobilePassword = [[alertView textFieldAtIndex:0] text];
            
            if (mobilePassword == nil || mobilePassword.length == 0) {
                UIAlertView *alert;
                alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Mobile Password is required. Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert setTag:1005];
                [alert show];
                [alert release];
                return;
            }
            
            [self showLoading];
            
            DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
            NSDictionary *dict = [[[NSDictionary alloc] initWithObjectsAndKeys:
                                   mobilePassword, @"mobilePassword",
                                   incomingDBFilePath, @"incomingDBFilePath",
                                   nil] autorelease];
            [dietmasterEngine processIncomingDatabase:dict];
            
        }
    }
    else if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            AppDel.isFromAlert = YES;
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFromAlert"];
            [rootController setSelectedIndex:4];
        }
        else {
            
        }
    }
}

-(void)processDatabaseMessage:(NSDictionary *)messageDict {
    [self hideLoading];
    
    int tag = 112233;
    if ([[messageDict valueForKey:@"try_password_again"] boolValue] == YES) {
        tag = 1005;
    }
    
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:[messageDict valueForKey:@"title"] message:[messageDict valueForKey:@"message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert setTag:tag];
    [alert show];
    [alert release];
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

-(void)openMailForApp {
    //[self showLoading];
    
    if ([MFMailComposeViewController canSendMail]) {
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSString *finalPath = [path stringByAppendingPathComponent:PLIST_NAME];
        NSDictionary *appDefaults = [[[NSDictionary alloc] initWithContentsOfFile:finalPath] autorelease];
        
        MFMailComposeViewController *mailComposer = [[[MFMailComposeViewController alloc] init] autorelease];
        [mailComposer setSubject:[NSString stringWithFormat:@"%@ App Help & Support", [appDefaults valueForKey:@"app_name_short"]]];
        NSString *emailTo = [[NSString alloc] initWithFormat:@""];
        [mailComposer setMessageBody:emailTo isHTML:NO];
        NSString *emailTo1 = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"LoginEmail"]];
        NSArray *toArray = [NSArray arrayWithObjects:emailTo1, nil];
        [mailComposer setToRecipients:toArray];
        mailComposer.mailComposeDelegate = self;
        
        DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
        NSData *zipData = dietmasterEngine.createZipFileOfDatabase;
        [mailComposer addAttachmentData:zipData mimeType:@"application/zip" fileName:@"Document.Zip"];
        [AppDel.window.rootViewController presentViewController:mailComposer animated:YES completion:^{
            //[self hideLoading];
        }];
    }
    else {
        //[self hideLoading];
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
        NSLog(@"Temp DB Zip File Deleted...");
    }
    //    });
    
    
}


@end
