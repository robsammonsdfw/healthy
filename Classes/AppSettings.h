//
//  AppSettings.h
//  DietMasterGo
//
//  Created by Andrew Moffitt on 11/23/10.
//  Copyright 2010 AE Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DietmasterEngine.h"
#import <MessageUI/MessageUI.h>
#import "MyMovesWebServices.h"

@interface AppSettings : UIViewController <UPSyncDatabaseDelegate, SyncDatabaseDelegate, MFMailComposeViewControllerDelegate,UINavigationControllerDelegate,WSAuthenticateUserDelegate, GetDataWSDelegate,UIGestureRecognizerDelegate> {
	
    IBOutlet UIActivityIndicatorView *downSyncSpinner;
    IBOutlet UIActivityIndicatorView *upSyncSpinner;
    IBOutlet UIActivityIndicatorView *FoodUpdateSyncSpinner;
    IBOutlet UILabel *lastSyncLabel;
    IBOutlet UILabel *versionLabel;
    IBOutlet UIView *viewSetting;
    IBOutlet UIButton *btnWkgs;
    IBOutlet UIButton *btnWlbs;
    IBOutlet UIButton *btnHinches;
    IBOutlet UIButton *btnHcm;
    IBOutlet UIButton *btnDmmdd;
    IBOutlet UIButton *btnDddmm;
    IBOutlet UIButton *btnCalorieTracking;
    IBOutlet UIButton *btnLoggedExeTracking;
    IBOutlet UIButton *btnAppleWatchTracking;
    IBOutlet UIButton *btnSafetyGuidelines;
    
    int pageNumberCounter;
    int pageSize;
    NSString *strSyncDate;
	UISwipeGestureRecognizer *leftSwipe ;
    
    //HHT change 2018
    IBOutlet UILabel *lblStaticLoggedExe;
}

@property (retain, nonatomic) IBOutlet UIView *viewtoptobottom;
@property(retain) UserLoginWebService *userLoginWS;
@property (retain, nonatomic) IBOutlet UIScrollView *myScrollBG;
@property (retain, nonatomic) IBOutlet UIView *popUpView;
@property (retain, nonatomic) IBOutlet UIView *showPopUpVw;


@end
