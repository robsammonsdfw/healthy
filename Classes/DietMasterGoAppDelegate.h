//  DietMasterGoAppDelegate.h
//  DietMasterGo
//
//  Created by Andrew Moffitt on 11/23/10.
//  Copyright 2010 AE Studios. All rights reserved.

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "DietmasterEngine.h"
#import "MBProgressHUD.h"
#import <MessageUI/MessageUI.h>
#import "MyMovesWebServices.h"

#import "UserLoginWebService.h"
#import "PurchaseIAPHelper.h"

@class DietMasterGoViewController;
@class DetailViewController;
@class LoginViewController;

@interface DietMasterGoAppDelegate : NSObject <UIApplicationDelegate, UPSyncDatabaseDelegate, SyncDatabaseDelegate, MBProgressHUDDelegate, UIAlertViewDelegate, UITextFieldDelegate,WSAuthenticateUserDelegate,UITabBarControllerDelegate,MFMailComposeViewControllerDelegate,UINavigationControllerDelegate> {
                          
    DietMasterGoViewController *viewController;     //To Enable NEW DESIGN
    
    
    UIWindow *window;
    DetailViewController *navigationController;
    LoginViewController *loginViewController;
    UITabBarController *rootController;
    sqlite3 *database;
    
    UIImageView *splashView;
    double caloriesremaning;
    NSString *strchekeditornot;
}

@property (nonatomic, strong) IBOutlet DietMasterGoViewController *viewController;    //To Enable NEW DESIGN

@property(strong,nonatomic) NSString *strchekeditornot;
@property (nonatomic) double caloriesremaning;
@property (readwrite) BOOL isFromBarcode;
@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UIViewController *rootController;
@property (nonatomic, strong) IBOutlet DetailViewController *navigationController;

@property (nonatomic, strong) LoginViewController *loginViewController;
@property (nonatomic, strong) UIImageView *splashView;

@property (nonatomic, strong) NSString *incomingDBFilePath;
@property (nonatomic, strong) NSString *idStr;

@property (nonatomic) BOOL isSessionExp;
@property(retain) UserLoginWebService *userLoginWS;

@property (nonatomic)BOOL isFromAlert;

-(void)showSplashScreen;
-(void)removeSplashScreen;

-(void)loadMainViews;
-(void)checkUserLogin;
-(void)getUserLogin;
- (void)userLoginFinished:(NSString *)statusMessage;
-(void)loginFromUrl:(NSString *)loginUrl;

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

