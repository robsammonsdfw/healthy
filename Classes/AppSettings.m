@import SafariServices;
#import "AppSettings.h"
#import "DietMasterGoAppDelegate.h"
#import "DetailViewController.h"
#import "ManageFoods.h"
#import "FoodsSearch.h"
#import "LoginViewController.h"
#import "UIDevice+machine.h"
#import "LearnMoreViewController.h"
#import "DietMasterGoAppDelegate.h"
#import "MBProgressHUD.h"
#import <HealthKit/HealthKit.h>
#import "StepData.h"
#import "NSNull+NullCategoryExtension.h"
#import "PopUpView.h"
#import "MyMovesViewController.h"

@interface AppSettings () <SFSafariViewControllerDelegate>
{
     
}

@property (nonatomic) IBOutlet UIButton *hcgBookletButton;
@property (nonatomic) IBOutlet UIButton *mwlBookletButton;

- (IBAction)showHCGBooklet:(id)sender;
- (IBAction)showMWLBooklet:(id)sender;
- (IBAction)myFoods:(id) sender;
- (IBAction)addFoods:(id)sender;
- (IBAction)forceDBSync:(id)sender;
- (IBAction)forceUPDBSync:(id)sender;
- (IBAction)CheckForFoodUpdateSync:(id)sender;
- (IBAction)sendSupportEmail:(id)sender;

@property (nonatomic, strong) IBOutlet UIButton *btnoptionsetting;
@property (nonatomic, strong) IBOutlet UIButton *btnmycustomfood;
@property (nonatomic, strong) IBOutlet UIButton *btnaddcustomfood;
@property (nonatomic, strong) IBOutlet UIButton *btnperformdownsync;
@property (nonatomic, strong) IBOutlet UIButton *btnperfomupsync;
@property (nonatomic, strong) IBOutlet UIButton *btnchekforfoodupdate;
@property (nonatomic, strong) IBOutlet UIButton *btnsenddatabasetosupport;

//HHT apple watch
@property (nonatomic,retain) HKHealthStore *healthStore;
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) NSSet *readDataTypes;
@property (nonatomic, strong) StepData * sd;

@end

@implementation AppSettings
@synthesize userLoginWS, myScrollBG;

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"changeDesign"]  isEqual: @"NewDesign"])
    {
        self.showPopUpVw.hidden = false;
    }
    else
    {
        self.showPopUpVw.hidden = true;
    }
    
//    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
//    dietmasterEngine.sendAllServerData = true;

    
    pageSize = 1000;
    pageNumberCounter = 1;
    viewSetting.hidden=TRUE;
    
    self.arrData = [NSMutableArray new];
    self.healthStore = [[HKHealthStore alloc] init];
    self.sd = [[StepData alloc]init];
    
    if (!IS_IPHONE_5) {
        //HHT change 2018 to solve issue in ipad setting lbl cut
        [myScrollBG setContentSize:CGSizeMake(self.view.frame.size.width, versionLabel.frame.origin.y + versionLabel.frame.size.height + 20)];
        
        //OLD
        //[myScrollBG setContentSize:CGSizeMake(320, 568)];
    }
    else{
        //OLD
        //self.view.frame.size.height-80
        //HHT change
        //[myScrollBG setContentSize:CGSizeMake(320, viewSetting.frame.size.height+ 20)];
        
        //HHT change 2018 to solve issue in ipad setting lbl cut
        [myScrollBG setContentSize:CGSizeMake(self.view.frame.size.width, versionLabel.frame.origin.y + versionLabel.frame.size.height + 20)];
    }
    
    self.btnoptionsetting.backgroundColor = PrimaryColor
    _btnoptionsetting.layer.cornerRadius = 5;
    
    self.btnmycustomfood.backgroundColor = PrimaryColor
    _btnmycustomfood.layer.cornerRadius = 5;
    
    self.btnaddcustomfood.backgroundColor =PrimaryColor
    _btnaddcustomfood.layer.cornerRadius =5;
    
    self.btnperformdownsync.backgroundColor = PrimaryDarkColor
    _btnperformdownsync.layer.cornerRadius =5;
    
    self.btnperfomupsync.backgroundColor = PrimaryDarkColor
    _btnperfomupsync.layer.cornerRadius=5;
    
    self.btnchekforfoodupdate.backgroundColor = PrimaryDarkColor
    _btnchekforfoodupdate.layer.cornerRadius = 5;
    
    self.btnsenddatabasetosupport.backgroundColor = AccentColor
    _btnsenddatabasetosupport.layer.cornerRadius = 5;
    
    self.hcgBookletButton.hidden = YES;
    self.mwlBookletButton.hidden = YES;
    
    self.navigationItem.title=@"Settings";
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]  initWithTitle: @"Back" style: UIBarButtonItemStylePlain target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:PLIST_NAME];
    NSDictionary *appDefaults = [[NSDictionary alloc] initWithContentsOfFile:finalPath];
    
    UIImageView *backgroundImage = (UIImageView *)[self.view viewWithTag:501];
    
    if ([[appDefaults valueForKey:@"account_code"] isEqualToString:@"ezdietplanner"]) {
        backgroundImage.image = [UIImage imageNamed:@"Settings_Screen"];
        versionLabel.textColor = [UIColor blackColor];
        lastSyncLabel.textColor = [UIColor blackColor];
    }
    
    if ([[appDefaults valueForKey:@"account_code"] isEqualToString:@"trdietpro"]) {
        self.hcgBookletButton.hidden = NO;
        self.mwlBookletButton.hidden = NO;
    }
    
    [self.navigationController.navigationBar setTranslucent:NO];
}

//HHT change 2018
-(void)openOpetionalSetting {
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"isFromAlert"] boolValue]){
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isFromAlert"];
        
        //HHT change 2018 to open default setting screen after login
        [self btnClkOpenSetting:self];
        
        if (IS_IPHONE_5) {
            
        } else {
            
        }
        //viewSetting.frame = CGRectMake(0, 0, viewSetting.frame.size.width, viewSetting.frame.size.height);
    }
    else {
        viewSetting.frame = CGRectMake(0, myScrollBG.contentSize.height, viewSetting.frame.size.width, viewSetting.frame.size.height);
        
        {
            [btnWkgs.layer setCornerRadius:btnWkgs.frame.size.height/2];
            [btnWlbs.layer setCornerRadius:btnWlbs.frame.size.height/2];
            [btnHcm.layer setCornerRadius:btnHcm.frame.size.height/2];
            [btnHinches.layer setCornerRadius:btnHinches.frame.size.height/2];
            [btnDddmm.layer setCornerRadius:btnDddmm.frame.size.height/2];
            [btnDmmdd.layer setCornerRadius:btnDmmdd.frame.size.height/2];
            [btnCalorieTracking.layer setCornerRadius:btnCalorieTracking.frame.size.height/2];
            [btnLoggedExeTracking.layer setCornerRadius:btnLoggedExeTracking.frame.size.height/2];
            [btnAppleWatchTracking.layer setCornerRadius:btnLoggedExeTracking.frame.size.height/2];
            
            [btnWkgs.layer setBorderWidth:0.5];
            [btnWlbs.layer setBorderWidth:0.5];
            [btnHcm.layer setBorderWidth:0.5];
            [btnHinches.layer setBorderWidth:0.5];
            [btnDddmm.layer setBorderWidth:0.5];
            [btnDmmdd.layer setBorderWidth:0.5];
            [btnCalorieTracking.layer setBorderWidth:0.5];
            [btnLoggedExeTracking.layer setBorderWidth:0.5];
            [btnAppleWatchTracking.layer setBorderWidth:0.5];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (![_viewtoptobottom isKindOfClass:[UIControl class]]) {
        [self btnClkCloseSetting:self];
        return YES;
    }
    else {
        return NO;
    }
    // handle the touch
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //HHT change 2018
    [self openOpetionalSetting];
    
    //HHT change 28-11
    DMLog(@"LoggedExeTracking :: %d",[[NSUserDefaults standardUserDefaults] boolForKey:@"LoggedExeTracking"]);
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"LoggedExeTracking"] == NO){
        [btnLoggedExeTracking setImage:[UIImage imageNamed:@"radio_btn_act.png"] forState:UIControlStateNormal];
    }
    else {
        [btnLoggedExeTracking setImage:[UIImage imageNamed:@"radio_btn.png"] forState:UIControlStateNormal];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CalorieTrackingDevice"] == NO){
        [btnCalorieTracking setImage:[UIImage imageNamed:@"radio_btn_act.png"] forState:UIControlStateNormal];
    }
    else {
        [btnCalorieTracking setImage:[UIImage imageNamed:@"radio_btn.png"] forState:UIControlStateNormal];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"LoggedAppleWatchTracking"] == YES){
        [btnAppleWatchTracking setImage:[UIImage imageNamed:@"radio_btn_act.png"] forState:UIControlStateNormal];
    }
    else {
        [btnAppleWatchTracking setImage:[UIImage imageNamed:@"radio_btn.png"] forState:UIControlStateNormal];
    }
    
    //LoggedAppleWatchTracking
    
    NSString *dateString;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (![prefs valueForKey:@"lastsyncdate"]) {
        dateString = @"Not Available";
    }
    else {
        NSDateFormatter *outdateformatter = [[NSDateFormatter alloc] init];
        [outdateformatter setDateFormat:@"M-d-yyyy h:mm:ss a"];
        dateString = [outdateformatter stringFromDate:[prefs valueForKey:@"lastsyncdate"]];
    }
    
    lastSyncLabel.text = [NSString stringWithFormat:@"Last Sync: %@", dateString];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *appVersion = [NSString stringWithFormat:@"Version: %@ Build %@", version, build];
    versionLabel.text = appVersion;
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isKgs"]) {
        [btnWlbs setImage:[UIImage imageNamed:@"radio_btn_act.png"] forState:UIControlStateNormal];
        [btnWkgs setImage:[UIImage imageNamed:@"radio_btn.png"] forState:UIControlStateNormal];
    }
    else {
        [btnWlbs setImage:[UIImage imageNamed:@"radio_btn.png"] forState:UIControlStateNormal];
        [btnWkgs setImage:[UIImage imageNamed:@"radio_btn_act.png"] forState:UIControlStateNormal];
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isCm"]) {
        [btnHinches setImage:[UIImage imageNamed:@"radio_btn_act.png"] forState:UIControlStateNormal];
        [btnHcm setImage:[UIImage imageNamed:@"radio_btn.png"] forState:UIControlStateNormal];
    }
    else {
        [btnHinches setImage:[UIImage imageNamed:@"radio_btn.png"] forState:UIControlStateNormal];
        [btnHcm setImage:[UIImage imageNamed:@"radio_btn_act.png"] forState:UIControlStateNormal];
    }
    
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"isddmm"] boolValue]) {
        [btnDmmdd setImage:[UIImage imageNamed:@"radio_btn_act.png"] forState:UIControlStateNormal];
        [btnDddmm setImage:[UIImage imageNamed:@"radio_btn.png"] forState:UIControlStateNormal];
    }
    else {
        [btnDmmdd setImage:[UIImage imageNamed:@"radio_btn.png"] forState:UIControlStateNormal];
        [btnDddmm setImage:[UIImage imageNamed:@"radio_btn_act.png"] forState:UIControlStateNormal];
    }
}

//HHT change 2018 to solve setting issue solve
- (void)viewWillDisappear:(BOOL)animated {
    [self btnClkCloseSetting:self];
}

-(IBAction) myFoods:(id) sender {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    dietmasterEngine.taskMode = @"View";
    
    FoodsSearch *fsController = [[FoodsSearch alloc] initWithNibName:@"FoodsSearch" bundle:nil];
    fsController.searchType = @"My Foods";
    fsController.title = @"My Foods";
    [self.navigationController pushViewController:fsController animated:YES];
}

-(IBAction)addFoods:(id)sender {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    dietmasterEngine.taskMode = @"";
    
    ManageFoods *mfController = [[ManageFoods alloc] initWithNibName:@"ManageFoods" bundle:nil];
    
    //HHT we save the selected Tab in appdegate and pass to manageFood and when scan complete we use that to select the current tab
    mfController.intTabId = AppDel.selectedIndex;
    
    [self.navigationController pushViewController:mfController animated:YES];
    mfController.hideAddToLog = YES;
    mfController = nil;
}

-(IBAction)forceDBSync:(id)sender {
    [downSyncSpinner startAnimating];
    MyMovesWebServices *soapWebService = [[MyMovesWebServices alloc] init];
    [soapWebService offlineSyncApi];

    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    dietmasterEngine.syncDatabaseDelegate = self;

    //HHT new exercise sync
    [dietmasterEngine.arrExerciseSyncNew removeAllObjects];
    [dietmasterEngine syncDatabase];
}

-(IBAction)forceUPDBSync:(id)sender {
    [upSyncSpinner startAnimating];
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    dietmasterEngine.syncUPDatabaseDelegate = self;
    [dietmasterEngine uploadDatabase];
}

-(IBAction)goToSafetyGuidelines:(id)sender {
    SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://advancedwebservicegroup.com/AWSGDocuments/GuidelinesAndSafety.html"]];
    [self presentViewController:sfvc animated:YES completion:nil];
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [self dismissViewControllerAnimated:true completion:nil];
}

-(void)clearTableData
{
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

    //get company moves
    NSString *selectCompanyMoves = [NSString stringWithFormat:@"SELECT MoveID From MoveDetailsTable WHERE CompanyID > 0"];
    
    FMResultSet *rs = [db executeQuery:selectCompanyMoves];
    NSMutableString *idString = [NSMutableString stringWithFormat:@""];
    while ([rs next]) {
        if ([idString isEqualToString:@""]) {
            idString = [NSMutableString stringWithFormat:@"%@", [rs stringForColumn:@"MoveID"]];
        } else {
            idString = [NSMutableString stringWithFormat:@"%@,%@", idString, [rs stringForColumn:@"MoveID"]];
        }
    }
    
    NSString *deleteTitles = [NSString stringWithFormat:@"DELETE FROM ListOfTitle_Table WHERE WorkoutID IN (%@)", idString];
    [db executeUpdate:deleteTitles];
    
    NSString *deleteCompanyMoves = [NSString stringWithFormat:@"DELETE FROM MoveDetailsTable WHERE CompanyID > 0"];
    [db executeUpdate:deleteCompanyMoves];
    
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    
    [db commit];
    
}

#pragma mark ==== Update and SyncFood method...
-(IBAction)CheckForFoodUpdateSync:(id)sender {
    [FoodUpdateSyncSpinner startAnimating];
    strSyncDate = [[NSUserDefaults standardUserDefaults] valueForKey:@"FoodUpdateLastsyncDate"];
    if (!strSyncDate) {
        [[NSUserDefaults standardUserDefaults] setValue:@"2015-01-01" forKey:@"FoodUpdateLastsyncDate"];
        strSyncDate = [[NSUserDefaults standardUserDefaults] valueForKey:@"FoodUpdateLastsyncDate"];
    }
    [self SyncFood];
}

-(void)SyncFood2{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"SyncFoods", @"RequestType",
                              @{@"UserID" : [prefs valueForKey:@"userid_dietmastergo"],
                                @"AuthKey" : [prefs valueForKey:@"authkey_dietmastergo"],
                                @"LastSync" : [prefs valueForKey:@"FoodUpdateLastsyncDate"]
                                }, @"parameters",
                              nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        GetDataWebService *webService = [[GetDataWebService alloc] init];
        webService.getDataWSDelegate = self;
        [webService callWebservice:infoDict];
    });
}

-(void)SyncFood{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"SyncFoodsNew", @"RequestType",
                              @{@"UserID" : [prefs valueForKey:@"userid_dietmastergo"],
                                @"AuthKey" : [prefs valueForKey:@"authkey_dietmastergo"],
                                @"LastSync" : strSyncDate,
                                //                                @"LastSync" : @"1970-01-01",
                                @"PageSize" : [NSString stringWithFormat:@"%d", pageSize],
                                @"PageNumber" : [NSString stringWithFormat:@"%d", pageNumberCounter],
                                }, @"parameters",
                              nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        GetDataWebService *webService = [[GetDataWebService alloc] init];
        webService.getDataWSDelegate = self;
        [webService callWebservice:infoDict];
    });
}

#pragma mark LOGIN AUTH DELEGATE METHODS
- (void)getAuthenticateUserFinished:(NSMutableArray *)responseArray {
    if (AppDel.isSessionExp == YES) {
        
    }
    else {
        [upSyncSpinner startAnimating];
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        dietmasterEngine.syncUPDatabaseDelegate = self;
        [dietmasterEngine uploadDatabase];
    }
}

#pragma mark SYNC DELEGATE METHODS
- (void)syncDatabaseFinished:(NSString *)responseMessage {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    dietmasterEngine.syncDatabaseDelegate = nil;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^
                   {
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [downSyncSpinner stopAnimating];
                           UIAlertView *alert;
                           alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"The database was sync'd successfully." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                           [alert show];
                       });
                   });
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDateFormatter *outdateformatter = [[NSDateFormatter alloc] init];
    [outdateformatter setDateFormat:@"M-d-yyyy h:mm:ss a"];
    NSString *dateString = [outdateformatter stringFromDate:[prefs valueForKey:@"lastsyncdate"]];
    
    lastSyncLabel.text = [NSString stringWithFormat:@"Last Sync: %@", dateString];
}

- (void)syncDatabaseFailed:(NSString *)failedMessage {
    
    //HHT mail change
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    dietmasterEngine.syncDatabaseDelegate = nil;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^
                   {
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [downSyncSpinner stopAnimating];
                           
                           UIAlertView *alert;
                           alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"An error occurred while processing. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Send Database to support",nil];
                           alert.tag = 1001;
                           [alert show];
                       });
                   });
    
}

- (void)syncUPDatabaseFinished:(NSString *)responseMessage {
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    dietmasterEngine.syncUPDatabaseDelegate = nil;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^
                   {
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [upSyncSpinner stopAnimating];
                           
                           if (AppDel.isSessionExp) {
                               
                           }
                           else{
                               UIAlertView *alert;
                               alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"The database was sync'd successfully." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                               [alert show];
                           }
                       });
                   });
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDateFormatter *outdateformatter = [[NSDateFormatter alloc] init];
    [outdateformatter setDateFormat:@"M-d-yyyy h:mm:ss a"];
    NSString *dateString = [outdateformatter stringFromDate:[prefs valueForKey:@"lastsyncdate"]];
    
    
    lastSyncLabel.text = [NSString stringWithFormat:@"Last Sync: %@", dateString];
}

- (void)syncUPDatabaseFailed:(NSString *)failedMessage {
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    dietmasterEngine.syncUPDatabaseDelegate = nil;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^
                   {
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [upSyncSpinner stopAnimating];
                           
                           //HHT mail change
                           UIAlertView *alert;
                           alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"An error occurred while processing. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Send Database to support",nil];
                           alert.tag = 1001;
                           [alert show];
                       });
                   });
    
}

//HHT mail change
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1001){
        if (buttonIndex == alertView.cancelButtonIndex){
            return;
        }
        else if (buttonIndex == 1){
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
                NSData *zipData = dietmasterEngine.createZipFileOfDatabase;                [mailComposer addAttachmentData:zipData mimeType:@"application/zip" fileName:@"Document.Zip"];
                [self presentViewController:mailComposer animated:YES completion:nil];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:APP_NAME message:@"There are no Mail accounts configured. You can add or create a Mail account in Settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
    }
    else {
        if (buttonIndex == 0) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"logout_dietmastergo"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFromAlert"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //HHT change 2018
            [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
            DietMasterGoAppDelegate *appDel = (DietMasterGoAppDelegate*)[UIApplication sharedApplication].delegate;
            [self clearTableData];
            [appDel checkUserLogin];
        }
    }
}

#pragma mark SUPPORT METHODS
-(IBAction)sendSupportEmail:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_NAME
                                                    message:@"Are you sure you want to log out?"
                                                   delegate:self
                                          cancelButtonTitle:@"Yes"
                                          otherButtonTitles:@"Cancel",nil];
    [alert show];
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
    [self dismissViewControllerAnimated:YES completion:nil];
    //                   });
    
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
    //                   });
    
    
}

#pragma mark Custom Buttons for Tampa Rejuvination
-(IBAction)showMWLBooklet:(id)sender {
    LearnMoreViewController *learnMoreViewController = [[LearnMoreViewController alloc] init];
    learnMoreViewController.learnMoreTitle = @"mwlbooklet";
    learnMoreViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:learnMoreViewController animated:YES];
}

-(IBAction)showHCGBooklet:(id)sender {
    LearnMoreViewController *learnMoreViewController = [[LearnMoreViewController alloc] init];
    learnMoreViewController.learnMoreTitle = @"hcgbooklet";
    learnMoreViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:learnMoreViewController animated:YES];
}

#pragma mark SettingView
-(IBAction)btnClkOpenSetting:(id)sender{
    self.navigationItem.title=@"Optional Settings";
    viewSetting.hidden=FALSE;
    btnSafetyGuidelines.hidden = TRUE;
    if (IS_IPHONE_5) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        viewSetting.frame = CGRectMake(0, 0, viewSetting.frame.size.width, viewSetting.frame.size.height+44);
        //HHT change 2018 to solve issue of large scroll in main screen
        [myScrollBG setContentSize:CGSizeMake(self.view.frame.size.width, lblStaticLoggedExe.frame.origin.y + lblStaticLoggedExe.frame.size.height + 20)];
        [UIView commitAnimations];
    }
    else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        viewSetting.frame = CGRectMake(0, 0, viewSetting.frame.size.width, viewSetting.frame.size.height + 44);
        //HHT change 2018 to solve issue of large scroll in main screen
        [myScrollBG setContentSize:CGSizeMake(self.view.frame.size.width, lblStaticLoggedExe.frame.origin.y + lblStaticLoggedExe.frame.size.height + 20)];
        
        [UIView commitAnimations];
    }
}

-(IBAction)btnClkCloseSetting:(id)sender{
    btnSafetyGuidelines.hidden = FALSE;
    self.navigationItem.title=@"Settings";
    if (AppDel.isFromAlert) {
        AppDel.isFromAlert = NO;
        [self.tabBarController setSelectedIndex:0];
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    viewSetting.frame = CGRectMake(0, myScrollBG.contentSize.height, viewSetting.frame.size.width, viewSetting.frame.size.height);
    
    //HHT change 2018 to solve issue in ipad setting lbl cut
    [myScrollBG setContentSize:CGSizeMake(self.view.frame.size.width, versionLabel.frame.origin.y + versionLabel.frame.size.height + 20)];
    
    [UIView commitAnimations];
    viewSetting.hidden=TRUE;
}

//-(IBAction)btnClkOpenSetting:(id)sender{
//    self.navigationItem.title=@"Optional Settings";
//    viewSetting.hidden=FALSE;
//    if (IS_IPHONE_5) {
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationDuration:0.5];
//        viewSetting.frame = CGRectMake(0, 0, viewSetting.frame.size.width, viewSetting.frame.size.height+44);
//        [UIView commitAnimations];
//    }
//    else {
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationDuration:0.5];
//        viewSetting.frame = CGRectMake(0, 0, viewSetting.frame.size.width, viewSetting.frame.size.height);
//        [UIView commitAnimations];
//    }
//}
//
//-(IBAction)btnClkCloseSetting:(id)sender{
//    self.navigationItem.title=@"Settings";
//    if (AppDel.isFromAlert) {
//        AppDel.isFromAlert = NO;
//        [self.tabBarController setSelectedIndex:0];
//    }
//
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.5];
//    viewSetting.frame = CGRectMake(0, myScrollBG.contentSize.height, viewSetting.frame.size.width, viewSetting.frame.size.height);
//    [UIView commitAnimations];
//    viewSetting.hidden=TRUE;
//}

-(IBAction)btnClkWeightSelection:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == 1) {
        if (btnWkgs.currentImage == [UIImage imageNamed:@"radio_btn_act.png"]) {
            [btnWkgs setImage:[UIImage imageNamed:@"radio_btn.png"] forState:UIControlStateNormal];
            [btnWlbs setImage:[UIImage imageNamed:@"radio_btn_act.png"] forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isKgs"];
        }
        else{
            [btnWkgs setImage:[UIImage imageNamed:@"radio_btn_act.png"] forState:UIControlStateNormal];
            [btnWlbs setImage:[UIImage imageNamed:@"radio_btn.png"] forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isKgs"];
        }
    }
    else {
        if (btnWlbs.currentImage == [UIImage imageNamed:@"radio_btn_act.png"]) {
            [btnWlbs setImage:[UIImage imageNamed:@"radio_btn.png"] forState:UIControlStateNormal];
            [btnWkgs setImage:[UIImage imageNamed:@"radio_btn_act.png"] forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isKgs"];
        }
        else{
            [btnWlbs setImage:[UIImage imageNamed:@"radio_btn_act.png"] forState:UIControlStateNormal];
            [btnWkgs setImage:[UIImage imageNamed:@"radio_btn.png"] forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isKgs"];
        }
    }
}

//HHT change solve CM setting issue
-(IBAction)btnClkHeightSelection:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == 1) {
        if (btnHinches.currentImage == [UIImage imageNamed:@"radio_btn_act.png"]) {
            [btnHinches setImage:[UIImage imageNamed:@"radio_btn.png"] forState:UIControlStateNormal];
            [btnHcm setImage:[UIImage imageNamed:@"radio_btn_act.png"] forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isCm"];
        }
        else {
            [btnHinches setImage:[UIImage imageNamed:@"radio_btn_act.png"] forState:UIControlStateNormal];
            [btnHcm setImage:[UIImage imageNamed:@"radio_btn.png"] forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isCm"];
        }
    }
    else {
        if (btnHcm.currentImage == [UIImage imageNamed:@"radio_btn_act.png"]) {
            [btnHcm setImage:[UIImage imageNamed:@"radio_btn.png"] forState:UIControlStateNormal];
            [btnHinches  setImage:[UIImage imageNamed:@"radio_btn_act.png"] forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isCm"];
        }
        else {
            [btnHcm setImage:[UIImage imageNamed:@"radio_btn_act.png"] forState:UIControlStateNormal];
            [btnHinches setImage:[UIImage imageNamed:@"radio_btn.png"] forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isCm"];
        }
    }
}

-(IBAction)btnClkDateSelection:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == 1) {
        if (btnDmmdd.currentImage == [UIImage imageNamed:@"radio_btn_act.png"]) {
            [btnDmmdd setImage:[UIImage imageNamed:@"radio_btn.png"] forState:UIControlStateNormal];
            [btnDddmm setImage:[UIImage imageNamed:@"radio_btn_act.png"] forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isddmm"];
        }
        else {
            [btnDmmdd setImage:[UIImage imageNamed:@"radio_btn_act.png"] forState:UIControlStateNormal];
            [btnDddmm setImage:[UIImage imageNamed:@"radio_btn.png"] forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isddmm"];
        }
    }
    else {
        if (btnDddmm.currentImage == [UIImage imageNamed:@"radio_btn_act.png"]) {
            [btnDddmm setImage:[UIImage imageNamed:@"radio_btn.png"] forState:UIControlStateNormal];
            [btnDmmdd  setImage:[UIImage imageNamed:@"radio_btn_act.png"] forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isddmm"];
        }
        else {
            [btnDddmm setImage:[UIImage imageNamed:@"radio_btn_act.png"] forState:UIControlStateNormal];
            [btnDmmdd setImage:[UIImage imageNamed:@"radio_btn.png"] forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isddmm"];
        }
    }
}

-(IBAction)btnClkCalorieTracking:(id)sender {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"CalorieTrackingDevice"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"CalorieTrackingDevice"];
        [btnCalorieTracking setImage:[UIImage imageNamed:@"radio_btn.png"] forState:UIControlStateNormal];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"CalorieTrackingDevice"];
        [btnCalorieTracking setImage:[UIImage imageNamed:@"radio_btn_act.png"] forState:UIControlStateNormal];
    }
}

//HHT change
-(IBAction)btnClkLoggedExeTracking:(id)sender {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"LoggedExeTracking"]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"LoggedExeTracking"];
        [btnLoggedExeTracking setImage:[UIImage imageNamed:@"radio_btn_act.png"] forState:UIControlStateNormal];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LoggedExeTracking"];
        [btnLoggedExeTracking setImage:[UIImage imageNamed:@"radio_btn.png"] forState:UIControlStateNormal];
    }
}

//HHT change
-(IBAction)btnClkAppleWatchExeTracking:(id)sender {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"LoggedAppleWatchTracking"]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"LoggedAppleWatchTracking"];
        [btnAppleWatchTracking setImage:[UIImage imageNamed:@"radio_btn.png"] forState:UIControlStateNormal];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LoggedAppleWatchTracking"];
        [btnAppleWatchTracking setImage:[UIImage imageNamed:@"radio_btn_act.png"] forState:UIControlStateNormal];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"LoggedAppleWatchTracking"] == YES){
        [self askForPermission];
    }
}

//HHT apple watch
#pragma mark IBAction
-(void)checkForPremission {
    HKAuthorizationStatus permissionStatus = [self.healthStore authorizationStatusForType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]];
    
    if (permissionStatus == HKAuthorizationStatusSharingAuthorized) {
        
    }
    else if (permissionStatus == HKAuthorizationStatusSharingDenied) {
        DMLog(@"** HKHealthStore HKAuthorizationStatusSharingDenied **");
    }
}

-(void)askForPermission {
    //check HKHealthStore available or not
    if ([HKHealthStore isHealthDataAvailable] == NO) {
        DMLog(@"** HKHealthStore NotAvailable **");
        return;
    }
    
    //self.healthStore = [[HKHealthStore alloc] init];
    
    NSArray *shareTypes = @[[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]];
    NSArray *readTypes = @[[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]];
    
    HKAuthorizationStatus permissionStatus = [self.healthStore authorizationStatusForType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]];
    
    if (permissionStatus == HKAuthorizationStatusSharingAuthorized) {
        DMLog(@"HKAuthorizationStatusSharingAuthorized");
    }
    else {
        [self.healthStore requestAuthorizationToShareTypes:[NSSet setWithArray:shareTypes] readTypes:[NSSet setWithArray:readTypes] completion:^(BOOL success, NSError * _Nullable error) {
            if (success){
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HKHealthStoreAllow"];
            }
            else {
                DMLog(@"Error");
            }
        }];
    }
}

-(void)getDataFinished:(NSDictionary *)responseDict {
    NSMutableDictionary *dictDataTemp = [(NSMutableArray *)responseDict objectAtIndex:0];
    if (![[dictDataTemp allKeys] containsObject:@"TotalCount"]) {
        pageNumberCounter = 1;
        [FoodUpdateSyncSpinner stopAnimating];
        [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:@"FoodUpdateLastsyncDate"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"The Food database was sync'd successfully." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    pageNumberCounter++;
    
    responseDict = [dictDataTemp valueForKey:@"Foods"];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[[DietmasterEngine sharedInstance] databasePath]];
    if (![db open]) {
        DMLog(@"Could not open db.");
    }
    
    NSMutableArray *arrFoods = [dictDataTemp valueForKey:@"Foods"];
    {
        NSArray *companyFoodsArray = arrFoods;
        
        [db beginTransaction];
        
        for (NSDictionary *dict in companyFoodsArray) {
            NSString *foodName = [[dict valueForKey:@"Name"] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            
            double servingSize = [[dict valueForKey:@"ServingSize"] doubleValue];
            if (servingSize == 0) { servingSize = 1; }
            
            NSString *foodTags = [dict valueForKey:@"FoodTags"];
            if (![foodTags isEqual:[NSNull null]] && [foodTags length] > 0) {
                foodTags = [foodTags stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                foodTags = [foodTags stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                foodTags = [foodTags stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            }

            NSString *insertSQL = [NSString stringWithFormat:@"REPLACE INTO Food "
            "(ScannedFood, "
             "FoodPK, FoodKey, "
             "FoodID, CategoryID, "
             "CompanyID, UserID, "
             "Name, Calories, "
             "Fat, Sodium, "
             "Carbohydrates, SaturatedFat, "
             "Cholesterol, Protein, "
             "Fiber, Sugars, "
             "Pot, A, "
             "Thi, Rib, "
             "Nia, B6, "
             "B12, Fol, "
             "C, Calc, "
             "Iron, Mag, "
             "Zn, ServingSize, "
             "FoodTags, Frequency, "
             "Alcohol, Folate, "
             "Transfat, E, "
             "D, UPCA, "
             "FactualID, ParentGroupID,"
             "RegionCode, LastUpdateDate,"
             "RecipeID, FoodURL)"
             "VALUES"
             "(%d, "
             "%i, %i, "
             "%i, %i, "
             "%i, %i, "
             "\"%@\", %f, " //Name, Calories
             "%f, %f, "
             "%f, %f, "
             "%f, %f, "
             "%f, %f, "
             "%f, %f, " //Pot, A
             "%f, %f, "
             "%f, %f, "
             "%f, %f, "
             "%f, %f, "
             "%f, %f, "
             "%f, %f, "
             "\"%@\", %i, " //FoodTags, Frequency
             "%f, %f, "
             "%f, %f, "
             "%f, \"%@\", "
             "%i , %i, "
             "%i, \"%@\", "
             "%i, \"%@\") ",
             [[dict valueForKey:@"ScannedFood"] boolValue],
            
             [[dict valueForKey:@"FoodPK"] intValue],
             [[dict valueForKey:@"FoodKey"] intValue],
            
             [[dict valueForKey:@"FoodID"] intValue],
             [[dict valueForKey:@"CategoryID"] intValue],
            
             [[dict valueForKey:@"CompanyID"] intValue],
             [[dict valueForKey:@"UserID"] intValue],
             foodName,
            
             [[dict valueForKey:@"Calories"] doubleValue],
             [[dict valueForKey:@"Fat"] doubleValue],
             [[dict valueForKey:@"Sodium"] doubleValue],
             [[dict valueForKey:@"Carbohydrates"] doubleValue],
             [[dict valueForKey:@"SaturatedFat"] doubleValue],
             [[dict valueForKey:@"Cholesterol"] doubleValue],
             [[dict valueForKey:@"Protein"] doubleValue],
             [[dict valueForKey:@"Fiber"] doubleValue],
             [[dict valueForKey:@"Sugars"] doubleValue],
             [[dict valueForKey:@"Pot"] doubleValue],
             [[dict valueForKey:@"A"] doubleValue],
             [[dict valueForKey:@"Thi"] doubleValue],
             [[dict valueForKey:@"Rib"] doubleValue],
             [[dict valueForKey:@"Nia"] doubleValue],
             [[dict valueForKey:@"B6"] doubleValue],
             [[dict valueForKey:@"B12"] doubleValue],
             [[dict valueForKey:@"Fol"] doubleValue],
             [[dict valueForKey:@"C"] doubleValue],
             [[dict valueForKey:@"Calc"] doubleValue],
             [[dict valueForKey:@"Iron"] doubleValue],
             [[dict valueForKey:@"Mag"] doubleValue],
             [[dict valueForKey:@"Zn"] doubleValue],
             servingSize,
             foodTags,
             [[dict valueForKey:@"Frequency"] intValue],
             [[dict valueForKey:@"Alcohol"] doubleValue],
             [[dict valueForKey:@"Folate"] doubleValue],
             [[dict valueForKey:@"Transfat"] doubleValue],
             [[dict valueForKey:@"E"] doubleValue],
             [[dict valueForKey:@"D"] doubleValue],
             [dict valueForKey:@"UPCA"] ? [dict valueForKey:@"UPCA"] : @"",
             [[dict valueForKey:@"FactualID"] intValue],
             [[dict valueForKey:@"ParentGroupID"] intValue],
             [[dict valueForKey:@"RegionCode"] intValue],
             [dict valueForKey:@"LastUpdateDate"],
             [[dict valueForKey:@"RecipeID"] intValue],
             [dict valueForKey:@"FoodURL"]];
            
            
            if ([dict valueForKey:@"FoodKey"]==0) {
                
            }
            [db executeUpdate:insertSQL];
            
            NSMutableArray *arrIDs = (NSMutableArray *)[[[dict valueForKey:@"MeasureIDs"] stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","];
            NSString *insertFMSQL;
            
            for (NSString *strID in arrIDs) {
                int measureID = [strID intValue];
                insertFMSQL = [NSString stringWithFormat: @"REPLACE INTO FoodMeasure (FoodID, MeasureID, GramWeight) VALUES (%i, %i, %i)", [[dict valueForKey:@"FoodKey"] intValue], measureID, [[dict valueForKey:@"GramWeights"] intValue]];
            }
            
            [db executeUpdate:insertFMSQL];
        }
        
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
        [self SyncFood];
    }
}

-(void)getDataFailed:(NSString *)failedMessage {
    DMLog(@"Err: %@", failedMessage);
    if (pageNumberCounter > 1) {
        //in process of syncing foods
        //fail silently and continue processing
        DMLog(@"sync foods error: page %d failed.", pageNumberCounter);
        
        pageNumberCounter++;
        [self SyncFood];
        return;
    }
    [downSyncSpinner stopAnimating];
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"An error occurred while processing. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

- (IBAction)popUpBtn:(id)sender {
    PopUpView* popUpView = [[PopUpView alloc]initWithNibName:@"PopUpView" bundle:nil];
    popUpView.modalPresentationStyle = UIModalPresentationOverFullScreen;
    popUpView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    popUpView.gotoDelegate = self;
    popUpView.vc = @"AppSettings";
    _showPopUpVw.hidden = true;
    [self presentViewController:popUpView animated:YES completion:nil];
}
-(void)DietMasterGoViewController
{
    DietMasterGoViewController *vc = [[DietMasterGoViewController alloc] initWithNibName:@"DietMasterGoViewController" bundle:nil];
    vc.title = @"Today";
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:false] ;
    [self RemovePreviousViewControllerFromStack];
}
-(void)MyGoalViewController
{
    MyGoalViewController *vc = [[MyGoalViewController alloc] initWithNibName:@"MyGoalViewController" bundle:nil];
    vc.title = @"My Goal";
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:false] ;
    [self RemovePreviousViewControllerFromStack];
}
- (void)MyLogViewController
{
    MyLogViewController *vc = [[MyLogViewController alloc] initWithNibName:@"MyLogViewController" bundle:nil];
    vc.title = @"My Log";
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:false] ;
    [self RemovePreviousViewControllerFromStack];
}

-(void)MealPlanViewController
{
    MealPlanViewController *vc = [[MealPlanViewController alloc] initWithNibName:@"MealPlanViewController" bundle:nil];
    vc.title = @"My Meals";
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:false] ;
    [self RemovePreviousViewControllerFromStack];
}
-(void)AppSettings
{
    AppSettings *vc = [[AppSettings alloc] initWithNibName:@"AppSettings" bundle:nil];
    vc.title = @"Settings";
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:false] ;
    [self RemovePreviousViewControllerFromStack];
}
-(void)MyMovesViewController
{
    MyMovesViewController *vc = [[MyMovesViewController alloc] initWithNibName:@"MyMovesViewController" bundle:nil];
    vc.title = @"MyMovesViewController";
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:false] ;
    [self RemovePreviousViewControllerFromStack];
}
-(void)RemovePreviousViewControllerFromStack
{
    NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];

    // [navigationArray removeAllObjects];    // This is just for remove all view controller from navigation stack.
    if (navigationArray.count > 2) {
        [navigationArray removeObjectAtIndex: 1];  // You can pass your index here
        self.navigationController.viewControllers = navigationArray;
    }
}

- (void)hideShowPopUpView
{
    self.showPopUpVw.hidden = false;
}

@end

