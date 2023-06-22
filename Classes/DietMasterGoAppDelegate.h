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

#import "PurchaseIAPHelper.h"

@class DietMasterGoViewController;
@class DetailViewController;
@class LoginViewController;

@interface DietMasterGoAppDelegate : NSObject <UIApplicationDelegate, UPSyncDatabaseDelegate, SyncDatabaseDelegate, UITextFieldDelegate, UITabBarControllerDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate> {
                          
    DetailViewController *navigationController;
    LoginViewController *loginViewController;
    sqlite3 *database;
    
    UIImageView *splashView;
    double caloriesremaning;
    NSString *strchekeditornot;
}

@property (nonatomic, strong) IBOutlet DietMasterGoViewController *viewController;

@property(strong,nonatomic) NSString *strchekeditornot;
@property (nonatomic) double caloriesremaning;
@property (readwrite) BOOL isFromBarcode;
@property (nonatomic, strong) IBOutlet DetailViewController *navigationController;

@property (nonatomic, strong) LoginViewController *loginViewController;
@property (nonatomic, strong) UIImageView *splashView;

@property (nonatomic, strong) NSString *incomingDBFilePath;
@property (nonatomic, strong) NSString *idStr;

@property (nonatomic) BOOL isSessionExp;

@property (nonatomic)BOOL isFromAlert;

-(void)showSplashScreen;
-(void)removeSplashScreen;

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

// store selected index
@property (readwrite) int selectedIndex;

@end

