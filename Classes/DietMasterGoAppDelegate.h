//  DietMasterGoAppDelegate.h
//  DietMasterGo
//
//  Created by Andrew Moffitt on 11/23/10.
//  Copyright 2010 AE Studios. All rights reserved.

#import <UIKit/UIKit.h>
#import "DietmasterEngine.h"
#import <MessageUI/MessageUI.h>
#import "MyMovesWebServices.h"
#import "PurchaseIAPHelper.h"

@class DietMasterGoViewController;
@class DetailViewController;
@class LoginViewController;

@interface DietMasterGoAppDelegate : NSObject <UIApplicationDelegate, UPSyncDatabaseDelegate, SyncDatabaseDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate> {
}

@property (nonatomic, strong) IBOutlet DietMasterGoViewController *viewController;
@property (nonatomic) double caloriesremaning;
@property (nonatomic, strong) IBOutlet DetailViewController *navigationController;
@property (nonatomic, strong) LoginViewController *loginViewController;
@property (nonatomic, strong) UIImageView *splashView;

@property (nonatomic, strong) NSString *idStr;

@property (nonatomic) BOOL isSessionExp;
@property (nonatomic)BOOL isFromAlert;

-(void)checkUserLogin;
-(void)getUserLogin;
- (void)userLoginFinished:(NSString *)statusMessage;
-(void)loginFromUrl:(NSString *)loginUrl;

// Sync
- (NSInteger)hoursAfterDate:(NSDate *)aDate;
- (NSInteger)minutesAfterDate:(NSDate *)aDate;
-(void)syncDatabase;

@end

