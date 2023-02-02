//  DietMasterGoAppDelegate.h
//  DietMasterGo
//
//  Created by Andrew Moffitt on 11/23/10.
//  Copyright 2010 AE Studios. All rights reserved.

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "DietmasterEngine.h"
#import "MBProgressHUD.h"
//#import <Fabric/Fabric.h>
//#import <Crashlytics/Crashlytics.h>
#import <MessageUI/MessageUI.h>
#import "MyMovesWebServices.h"

// For splash updating
#import "UserLoginWebService.h"
#import "PurchaseIAPHelper.h"

@class DietMasterGoViewController;
@class DietMasterGoController_Old;
@class DetailViewController;
@class LoginViewController;

@interface DietMasterGoAppDelegate : NSObject <UIApplicationDelegate, UPSyncDatabaseDelegate, SyncDatabaseDelegate, MBProgressHUDDelegate, UIAlertViewDelegate, UITextFieldDelegate,WSAuthenticateUserDelegate,UITabBarControllerDelegate,MFMailComposeViewControllerDelegate,UINavigationControllerDelegate> {
                          
/*==========================================Enable & Disable Old design==========================================*/
    DietMasterGoViewController *viewController;     //To Enable NEW DESIGN
//    DietMasterGoController_Old *viewController;     //To Enable OLD DESIGN
/*================================================================================================================*/
    
    
    UIWindow *window;
    DetailViewController *navigationController;
    LoginViewController *loginViewController;
    UITabBarController *rootController;
    sqlite3 *database;
    MBProgressHUD *HUD;
    UIImageView *splashView;
    double caloriesremaning;
    NSString *strchekeditornot;
}

/*==========================================Enable & Disable Old design==========================================*/
@property (nonatomic, retain) IBOutlet DietMasterGoViewController *viewController;    //To Enable NEW DESIGN
//@property (retain, nonatomic) IBOutlet DietMasterGoController_Old *viewController;      //To Enable OLD DESIGN
/*================================================================================================================*/


@property(strong,nonatomic) NSString *strchekeditornot;
//@property (nonatomic,assign) caloriesremaning;
@property (nonatomic,assign) double caloriesremaning;
@property (readwrite) BOOL isFromBarcode;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UIViewController *rootController;
@property (nonatomic, retain) IBOutlet DetailViewController *navigationController;

@property (nonatomic, retain) LoginViewController *loginViewController;
@property (nonatomic, retain) UIImageView *splashView;

@property (nonatomic, retain) NSString *incomingDBFilePath;
@property (nonatomic, retain) NSString *idStr;


@property (nonatomic)    BOOL isSessionExp;
@property(retain) UserLoginWebService *userLoginWS;

@property (nonatomic)BOOL isFromAlert;

-(void)showSplashScreen;
-(void)removeSplashScreen;

-(void)loadMainViews;
-(void)checkUserLogin;
-(void)getUserLogin;
- (void)userLoginFinished:(NSString *)statusMessage;
-(void)loginFromUrl:(NSString *)loginUrl;
// Loading methods
-(void)showLoading;
-(void)hideLoading;
-(void)showCompleted;
-(void)showWithProgressIndicator;
-(void)hideLoadingNow;
-(void)changeLoadingMessage:(NSString *)message;
-(void)updateLoadingProgress:(double)progress;

// Sync
- (NSInteger)hoursAfterDate:(NSDate *)aDate;
- (NSInteger)minutesAfterDate:(NSDate *)aDate;
-(void)syncDatabase;

// Update 1.1. Method
-(void)updateMeasureTable;

// remove from icloud
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

// update database
-(void)confirmUpdateDatabase;
-(void)confirmDatabaseUserPassword;
-(void)processDatabaseMessage:(NSDictionary *)messageDict;

//store selected index

@property (readwrite) int selectedIndex;

@end

