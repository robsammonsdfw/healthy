//#import "DietMasterGoViewController.h"
#import "DietMasterGoController_Old.h"
#import "DietMasterGoAppDelegate.h"
#import "GroceryListViewController.h"
#import "FoodsList.h"
#import "DietmasterEngine.h"
#import "MessageViewController.h"
#import "MKNumberBadgeView.h"
#import "AppSettings.h"
#import <Crashlytics/Crashlytics.h>


@interface DietMasterGoController_Old () {
    MKNumberBadgeView *numberBadge;
    UIBarButtonItem* rightButton;
}

@end

@implementation DietMasterGoController_Old
@synthesize date_currentDate,num_BMR,carbs_circular,fat_circular,protein_Circular,progressbar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

-(id)init {
    self = [super initWithNibName:@"DietMasterGoController_Old" bundle:nil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    Test CRASH BUTTON
//    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    button.frame = CGRectMake(20, 50, 100, 30);
//    [button setTitle:@"Crash" forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(crashButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:button];
    
    
    //HHT change 2018
    NSDictionary* userDefaultsValuesDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSNumber numberWithBool:YES], @"LoggedExeTracking",
                                            nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsValuesDict];
    
    //HHT change 2018 (Scroll view added)
    [scrollViewMain setContentSize:CGSizeMake(self.view.frame.size.width, _fatBMIview.frame.origin.y + _fatBMIview.frame.size.height + 20)];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    _imghomescreenbg.backgroundColor=[UIColor whiteColor];
    
    _imgtop1.backgroundColor=PrimaryColor
    _imgtop2.backgroundColor=AccentColor
    _imgtop3.backgroundColor=PrimaryDarkColor
    _imgtop4.backgroundColor=PrimaryDarkColor
    _imglinetop.backgroundColor=RGB(255, 255, 255, 0.5);
    
    //HHT version 3.0 dynamic color changes
    lblStaticRecomCalories.backgroundColor = PrimaryDarkColor
    
    lblStaticRecomCalories.textColor = PrimaryDarkFontColor
    lblStaticDailyTotals.textColor = PrimaryDarkFontColor
    lblStaticGoalsSummary.textColor = PrimaryFontColor

    viewGoal.backgroundColor = PrimaryColor
    viewFood.backgroundColor = PrimaryColor
    viewExercise.backgroundColor = PrimaryColor
    viewNet.backgroundColor = PrimaryColor
    
    lblStaticDailyTotals.backgroundColor = PrimaryDarkColor
    lblStaticGoalsSummary.backgroundColor = PrimaryColor
    
    vwPadding.layer.cornerRadius = vwPadding.frame.size.height /2;
    vwPadding.clipsToBounds = true;
    
    self.navigationItem.title=@"Today's Summary";
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStylePlain
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    [backButton release];
    
    numberBadge = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(40, -40, 30, 30)];
    numberBadge.font = [UIFont systemFontOfSize:12];
    numberBadge.hideWhenZero = YES;
    
    //HHT change 2018 we call this in viewWillAppear
    /*UIBarButtonItem *mailButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Mail" style:UIBarButtonItemStylePlain target:self action:@selector(mailAction:)];
     self.navigationItem.leftBarButtonItem = mailButtonItem;
     [self.view addSubview:numberBadge];
     mailButtonItem.tintColor=[UIColor whiteColor];
     [mailButtonItem release];
     [numberBadge release];*/
    
//    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSheet:)];
//    self.navigationItem.rightBarButtonItem = barButtonItem;
//    barButtonItem.tintColor=[UIColor whiteColor];
//    [barButtonItem release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"ReloadData" object:nil];
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:PLIST_NAME];
    NSDictionary *appDefaults = [[[NSDictionary alloc] initWithContentsOfFile:finalPath] autorelease];
    
    UIImageView *backgroundImage = (UIImageView *)[self.view viewWithTag:501];
    UIImageView *blueBar = (UIImageView *)[self.view viewWithTag:701];
    UIImageView *orangeBar = (UIImageView *)[self.view viewWithTag:601];
    if ([[appDefaults valueForKey:@"account_code"] isEqualToString:@"ezdietplanner"]) {
        backgroundImage.image = [UIImage imageNamed:@"Today_Screen"];
        blueBar.image = nil;
        orangeBar.image = nil;
        blueBar.backgroundColor = [UIColor colorWithRed:0.267 green:0.475 blue:0.545 alpha:0.600];
        orangeBar.backgroundColor = [UIColor colorWithRed:0.157 green:0.275 blue:0.318 alpha:0.700];
        for (id view in self.view.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)view;
                if ([label.text isEqualToString:@"Goals Summary:"] || [label.text isEqualToString:@"Daily Totals:"] || [label.text isEqualToString:@"Recommended Calories"] || [label.text isEqualToString:@"Calories Remaining"]) {
                    label.textColor = PrimaryFontColor;
                    label.shadowColor = [UIColor clearColor];
                }
                else {
                    label.textColor = PrimaryFontColor;
                    label.shadowColor = [UIColor clearColor];
                }
            }
        }
        
        lbl_CalorieDifference.textColor = PrimaryFontColor;
        lbl_CaloriesRecommended.textColor = PrimaryFontColor;
        goalCalorieLabel.textColor = PrimaryFontColor;
        exerciseCaloriesLoggedLabel.textColor = PrimaryFontColor;
        netCalorieLabel.textColor = PrimaryFontColor;
        caloriesLoggedLabel.textColor = PrimaryFontColor;
    }
    
    if ([[appDefaults valueForKey:@"account_code"] isEqualToString:@"gymmatrix"]) {
        for (id view in self.view.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)view;
                label.textColor = PrimaryFontColor;
                label.shadowColor = [UIColor darkGrayColor];
            }
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoginFinished:) name:@"UserLoginFinished" object:nil];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    //Reema 15-Nov-2017 changes for New Design
    
    //HHT version 3.0 dynamic color changes
    self.remainingCalories_Circular_Progress.progressColor = AccentColor
    self.remainingCalories_Circular_Progress.emptyLineColor = [UIColor lightGrayColor];
    
    self.remainingCalories_Circular_Progress.layer.cornerRadius = self.remainingCalories_Circular_Progress.frame.size.width/2;
    self.remainingCalories_Circular_Progress.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor whiteColor]);
    self.remainingCalories_Circular_Progress.layer.borderWidth = 2;
    self.remainingCalories_Circular_Progress.clipsToBounds = YES;
    
    self.fat_circular.layer.cornerRadius = self.fat_circular.frame.size.width/2;
    self.fat_circular.clipsToBounds = YES;
    [[self.fat_circular layer] setMasksToBounds:false];
    
    self.protein_Circular.layer.cornerRadius = self.fat_circular.frame.size.width/2;
    self.protein_Circular.clipsToBounds = YES;
    [[self.protein_Circular layer] setMasksToBounds:false];
    
    self.carbs_circular.layer.cornerRadius = self.fat_circular.frame.size.width/2;
    self.carbs_circular.clipsToBounds = YES;
    [[self.carbs_circular layer] setMasksToBounds:false];
    
    [self initProgressBar];
    
   
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"switch"]  isEqual: @"MyMoves"])
    {
        UIImage *btnImage1 = [[UIImage imageNamed:@"set32.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn1.bounds = CGRectMake( 0, 0, btnImage1.size.width, btnImage1.size.height );
        btn1.tintColor = [UIColor whiteColor];
        [btn1 addTarget:self action:@selector(showSettings:) forControlEvents:UIControlEventTouchDown];
        [btn1 setImage:btnImage1 forState:UIControlStateNormal];
        UIBarButtonItem * settingsBtn = [[UIBarButtonItem alloc] initWithCustomView:btn1];
        self.navigationItem.rightBarButtonItem = settingsBtn;
    }
    else
    {
//        UIImage *btnImage1 = [[UIImage imageNamed:@"mailUs.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        
        
        rightButton = [[UIBarButtonItem alloc]
                       initWithBarButtonSystemItem: UIBarButtonSystemItemAction target:self action:@selector(emailUs:)];
        rightButton.tintColor = [UIColor whiteColor];
        rightButton.style = UIBarButtonItemStylePlain;
        self.navigationItem.rightBarButtonItem = rightButton;

        
//        btn1.bounds = CGRectMake( 0, 0, 20, 20 );
//        btn1.tintColor = [UIColor whiteColor];
//        [btn1 addTarget:self action:@selector(emailUs:) forControlEvents:UIControlEventTouchDown];
//        [btn1 setImage:btnImage1 forState:UIControlStateNormal];
//        UIBarButtonItem * settingsBtn = [[UIBarButtonItem alloc] initWithCustomView:btn1];
//        self.navigationItem.rightBarButtonItem = settingsBtn;
    }
    
//    MyMovesWebServices * soapWebService = [[MyMovesWebServices alloc] init];
//    NSDictionary *wsWorkInfoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
//                                    @"Workout", @"RequestType",nil];
//
//
//    soapWebService.WSWorkoutListDelegate = self;
//    [soapWebService callGetWebservice:wsWorkInfoDict];
//
//    [soapWebService release];
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                break;
                
            case 1334:
                printf("iPhone 6/6S/7/8");
                break;
                
            case 1920:
                printf("iPhone 6+/6S+/7+/8+");
                break;
                
            case 2436:
                printf("iPhone X, XS");
                lblStaticRecomCalories.frame                = CGRectMake(0, 0, SCREEN_WIDTH, 35);
                _remainingCalories_Circular_Progress.frame = CGRectMake(SCREEN_WIDTH - 130, 65, 120, 120);
                _bigCircleImg.frame                         = CGRectMake(SCREEN_WIDTH - 130, 65, 120, 120);
                vwPadding.frame                             = CGRectMake(SCREEN_WIDTH - 138, 61, 128, 128);
                viewGoal.frame                              = CGRectMake(20, 65, 300, 27);
                viewFood.frame                              = CGRectMake(20, 93, 300, 27);
                viewExercise.frame                          = CGRectMake(20, 121, 300, 27);
                viewNet.frame                               = CGRectMake(20, 149, 300, 27);
                
                staticGoalLbl.frame                         = CGRectMake(40, 0, 70, 27);
                staticFoodLbl.frame                         = CGRectMake(40, 0, 70, 27);
                staticExerciseLbl.frame                     = CGRectMake(40, 0, 70, 27);
                staticNetLbl.frame                          = CGRectMake(40, 0, 70, 27);
                
                lblGoal.frame                               = CGRectMake(130, 0, 70, 27);
                lblfoodCalories.frame                       = CGRectMake(130, 0, 70, 27);
                lblExerciseCalories.frame                   = CGRectMake(130, 0, 70, 27);
                lblNetCalories.frame                        = CGRectMake(130, 0, 70, 27);
                
                
                lblStaticDailyTotals.frame                  = CGRectMake(0, 210, SCREEN_WIDTH, 30);
                lblStaticGoalsSummary.frame                 = CGRectMake(0, 400, SCREEN_WIDTH, 30);
                progressbar.frame                           = CGRectMake(30, 510, SCREEN_WIDTH - 60, 23);
                _progressBarImg.frame                       = CGRectMake(30, 510, SCREEN_WIDTH - 60, 23);
                lblWeight.frame                             = CGRectMake(30, 542, SCREEN_WIDTH - 60, 20);
                _fatBMIview.frame                           = CGRectMake(0, 563, SCREEN_WIDTH, 65);
                _startGoalView.frame                        = CGRectMake(0, 440, SCREEN_WIDTH, 50);
                lblFatPercent.frame                         = CGRectMake(30, 260, 80, 20);
                lblProtinPercent.frame                      = CGRectMake((SCREEN_WIDTH/2) - 40, 260, 80, 20);
                lblCarbsPercent.frame                       = CGRectMake(SCREEN_WIDTH - 110, 260, 80, 20);
                fat_circular.frame                          = CGRectMake(40, 290, 60, 60);
                _fatSmallCircleImg.frame                    = CGRectMake(40, 290, 60, 60);
                protein_Circular.frame                      = CGRectMake((SCREEN_WIDTH/2) - 30, 290, 60, 60);
                _proteinSmallCircleImg.frame                = CGRectMake((SCREEN_WIDTH/2) - 30, 290, 60, 60);
                carbs_circular.frame                        = CGRectMake(SCREEN_WIDTH - 100, 290, 60, 60);
                _carbSmallCircleImg.frame                   = CGRectMake(SCREEN_WIDTH - 100, 290, 60, 60);
                break;
                
            case 2688:
                printf("iPhone XS Max");
                lblStaticRecomCalories.frame                = CGRectMake(0, 0, SCREEN_WIDTH, 40);
                vwPadding.frame                             = CGRectMake(SCREEN_WIDTH - 138, 61, 128, 128);
                _remainingCalories_Circular_Progress.frame  = CGRectMake(SCREEN_WIDTH - 130, 65, 120, 120);
                _bigCircleImg.frame                         = CGRectMake(SCREEN_WIDTH - 130, 65, 120, 120);
                viewGoal.frame                              = CGRectMake(20, 65, 300, 27);
                viewFood.frame                              = CGRectMake(20, 93, 300, 27);
                viewExercise.frame                          = CGRectMake(20, 121, 300, 27);
                viewNet.frame                               = CGRectMake(20, 149, 300, 27);
                
                staticGoalLbl.frame                         = CGRectMake(60, 0, 70, 27);
                staticFoodLbl.frame                         = CGRectMake(60, 0, 70, 27);
                staticExerciseLbl.frame                     = CGRectMake(60, 0, 70, 27);
                staticNetLbl.frame                          = CGRectMake(60, 0, 70, 27);
                
                lblGoal.frame                               = CGRectMake(150, 0, 70, 27);
                lblfoodCalories.frame                       = CGRectMake(150, 0, 70, 27);
                lblExerciseCalories.frame                   = CGRectMake(150, 0, 70, 27);
                lblNetCalories.frame                        = CGRectMake(150, 0, 70, 27);
                
                lblStaticDailyTotals.frame                  = CGRectMake(0, 240, SCREEN_WIDTH, 35);
                lblFatPercent.frame                         = CGRectMake(30, 290, 80, 20);
                lblProtinPercent.frame                      = CGRectMake((SCREEN_WIDTH/2) - 40, 290, 80, 20);
                lblCarbsPercent.frame                       = CGRectMake(SCREEN_WIDTH - 110, 290, 80, 20);
                fat_circular.frame                          = CGRectMake(40, 320, 60, 60);
                protein_Circular.frame                      = CGRectMake((SCREEN_WIDTH/2) - 30, 320, 60, 60);
                _proteinSmallCircleImg.frame                = CGRectMake((SCREEN_WIDTH/2) - 30, 320, 60, 60);
                carbs_circular.frame                        = CGRectMake(SCREEN_WIDTH - 100, 320, 60, 60);
                _fatSmallCircleImg.frame                    = CGRectMake(40, 320, 60, 60);
                _carbSmallCircleImg.frame                   = CGRectMake(SCREEN_WIDTH - 100, 320, 60, 60);
                lblStaticGoalsSummary.frame                 = CGRectMake(0, 430, SCREEN_WIDTH, 35);
                _startGoalView.frame                        = CGRectMake(0, 480, SCREEN_WIDTH, 50);
                progressbar.frame                           = CGRectMake(30, 580, SCREEN_WIDTH - 60, 23);
                _progressBarImg.frame                       = CGRectMake(30, 580, SCREEN_WIDTH - 60, 23);
                lblWeight.frame                             = CGRectMake(30, 612, SCREEN_WIDTH - 60, 20);
                _fatBMIview.frame                           = CGRectMake(0, 653, SCREEN_WIDTH, 65);
                break;
                
            case 1792:
                printf("iPhone XR");
                lblStaticRecomCalories.frame                = CGRectMake(0, 0, SCREEN_WIDTH, 35);
                vwPadding.frame                             = CGRectMake(SCREEN_WIDTH - 138, 61, 128, 128);
                _remainingCalories_Circular_Progress.frame  = CGRectMake(SCREEN_WIDTH - 130, 65, 120, 120);
                _bigCircleImg.frame                         = CGRectMake(SCREEN_WIDTH - 130, 65, 120, 120);
                viewGoal.frame                              = CGRectMake(20, 65, 300, 27);
                viewFood.frame                              = CGRectMake(20, 93, 300, 27);
                viewExercise.frame                          = CGRectMake(20, 121, 300, 27);
                viewNet.frame                               = CGRectMake(20, 149, 300, 27);
                
                staticGoalLbl.frame                         = CGRectMake(60, 0, 70, 27);
                staticFoodLbl.frame                         = CGRectMake(60, 0, 70, 27);
                staticExerciseLbl.frame                     = CGRectMake(60, 0, 70, 27);
                staticNetLbl.frame                          = CGRectMake(60, 0, 70, 27);
                
                lblGoal.frame                               = CGRectMake(150, 0, 70, 27);
                lblfoodCalories.frame                       = CGRectMake(150, 0, 70, 27);
                lblExerciseCalories.frame                   = CGRectMake(150, 0, 70, 27);
                lblNetCalories.frame                        = CGRectMake(150, 0, 70, 27);
                
                lblStaticDailyTotals.frame                  = CGRectMake(0, 240, SCREEN_WIDTH, 35);
                lblFatPercent.frame                         = CGRectMake(30, 290, 80, 20);
                lblProtinPercent.frame                      = CGRectMake((SCREEN_WIDTH/2) - 40, 290, 80, 20);
                lblCarbsPercent.frame                       = CGRectMake(SCREEN_WIDTH - 110, 290, 80, 20);
                fat_circular.frame                          = CGRectMake(40, 320, 60, 60);
                protein_Circular.frame                      = CGRectMake((SCREEN_WIDTH/2) - 30, 320, 60, 60);
                _proteinSmallCircleImg.frame                = CGRectMake((SCREEN_WIDTH/2) - 30, 320, 60, 60);
                carbs_circular.frame                        = CGRectMake(SCREEN_WIDTH - 100, 320, 60, 60);
                _fatSmallCircleImg.frame                    = CGRectMake(40, 320, 60, 60);
                _carbSmallCircleImg.frame                   = CGRectMake(SCREEN_WIDTH - 100, 320, 60, 60);
                lblStaticGoalsSummary.frame                 = CGRectMake(0, 430, SCREEN_WIDTH, 35);
                _startGoalView.frame                        = CGRectMake(0, 480, SCREEN_WIDTH, 50);
                progressbar.frame                           = CGRectMake(30, 580, SCREEN_WIDTH - 60, 23);
                _progressBarImg.frame                       = CGRectMake(30, 580, SCREEN_WIDTH - 60, 23);
                lblWeight.frame                             = CGRectMake(30, 612, SCREEN_WIDTH - 60, 20);
                _fatBMIview.frame                           = CGRectMake(0, 653, SCREEN_WIDTH, 65);
                break;
                
            default:
                printf("Unknown");
                break;
        }
    }
}

//- (IBAction)crashButtonTapped:(id)sender {
//    [[Crashlytics sharedInstance] crash]; //TEST CRASH BUTTOM
//}



-(IBAction)showSettings:(id)sender {
        AppSettings *appVC = [[AppSettings alloc]initWithNibName:@"AppSettings" bundle:nil];
        appVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:appVC animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //HHT change 2018 to solve barbutton issue
    UIBarButtonItem *mailButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Mail" style:UIBarButtonItemStylePlain target:self action:@selector(mailAction:)];
    self.navigationItem.leftBarButtonItem = mailButtonItem;
    [self.view addSubview:numberBadge];
    mailButtonItem.tintColor=[UIColor whiteColor];
    [mailButtonItem release];
    //[numberBadge release];
    
    [fat_circular setValue:0];
    [protein_Circular setValue:0];
    [carbs_circular setValue:0];
    [self.remainingCalories_Circular_Progress setValue:0];
    [progressbar setProgress:0.0f animated:NO];
    
    self.navigationController.navigationBar.layer.zPosition = -1;
    [self reloadMessages];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBadge) name:UpdatingMessageNotification object:nil];
    
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.layer.zPosition = 0;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

-(void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ReloadData" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LaunchDietWizard" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UserLoginFinished" object:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadData];
}

- (void)initProgressBar
{
    [progressbar setProgress:0.0f animated:YES];
    progressbar.type = YLProgressBarTypeFlat;
    
    //HHT change 2018
    progressbar.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeNone;
    
    progressbar.behavior = YLProgressBarBehaviorIndeterminate;
    progressbar.stripesOrientation       = YLProgressBarStripesOrientationLeft;
    progressbar.indicatorTextLabel.font  = [UIFont fontWithName:@"Arial-BoldMT" size:17];
    progressbar.progressStretch = NO;
    //HHT version 3.0 dynamic color changes
    progressbar.progressTintColor = AccentColor //RGB(2, 97, 152, 1);
    progressbar.trackTintColor = [UIColor lightGrayColor];
    //progressbar.progressTintColor = ProgressColor //RGB(2, 97, 152, 1);
    progressbar.cornerRadius = 5;
    progressbar.hideGloss = false;
    progressbar.stripesColor = [UIColor clearColor];
    
    //HHT change 2018
    progressbar.uniformTintColor = YES;
}

- (void)updateBadge {
    numberBadge.value = [[DietmasterEngine instance] countOfUnreadingMessages];
    [UIApplication sharedApplication].applicationIconBadgeNumber = numberBadge.value;
}

- (void)reloadMessages {
    numberBadge.value = [[DietmasterEngine instance] countOfUnreadingMessages];
    [[DietmasterEngine instance] synchMessagesWithCompletion:^(BOOL success, NSString *errorString) {
        if (success) {
            [self updateBadge];
        }
    }];
}

- (void)userLoginFinished:(NSString *)statusMessage {
    //HHT change call function after 1.0 delay to solve login issue
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self reloadMessages];
    });
}

-(void)getBMR{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    
    NSInteger bmrValue = [dietmasterEngine getBMR];
    num_BMR = bmrValue;
    lbl_CaloriesRecommended.text = [NSString stringWithFormat:@"%i", bmrValue];
    
    [self updateCalorieTotal];
}

-(IBAction) showGroceryList:(id) sender {
    FoodsList *flController = [[FoodsList alloc] initWithNibName:@"FoodsList" bundle:nil];
    [self.navigationController pushViewController:flController animated:YES];
    [flController release];
    flController=nil;
}

-(IBAction)showManageFoods:(id) sender {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [_imghomescreenbg release];
    [_imgtop1 release];
    [_imgtop2 release];
    [_imgtop3 release];
    [_imgtop4 release];
    [_imglinetop release];
    [_remainingCalories_Circular_Progress release];
    [fat_circular release];
    [protein_Circular release];
    [carbs_circular release];
    [YLProgressBar release];
    [lblGoal release];
    [lblfoodCalories release];
    [lblExerciseCalories release];
    [lblNetCalories release];
    [lblFatPercent release];
    [lblProtinPercent release];
    [lblCarbsPercent release];
    [lblStart_lbs release];
    [lblGoal_lbs release];
    [lblWeightStatus release];
    [lblWeight release];
    [lblBodyFat release];
    [lblCurrentBMI release];
    [lblActualFat release];
    [lblActualProtein release];
    [lblActualCarbs release];
    [lblCaloriesRemainingValue release];
    [vwPadding release];
    [scrollViewMain release];
    [viewGoal release];
    [viewFood release];
    [viewExercise release];
    [viewNet release];
    [super dealloc];
    
    [lbl_CaloriesLogged release];
    [lbl_CaloriesRecommended release];
    [lbl_GoalWeight release];
    [lbl_CurrentWeight release];
    [lbl_CalorieDifference release];
    
    [goalCalorieLabel release];
    [caloriesLoggedLabel release];
    [exerciseCaloriesLoggedLabel release];
    [netCalorieLabel release];
    
    [totalFatLabel release];
    [totalCarbsLabel release];
    [totalProteinLabel release];
}

#pragma mark - WorkOutList

- (void)getWorkoutListFailed:(NSString *)failedMessage {
    
}

- (void)getWorkoutListFinished:(NSDictionary *)responseDict {
    MyMovesWebServices * soapWebService = [[MyMovesWebServices alloc] init];
    
    if (responseDict != (id)[NSNull null])
    {
        [soapWebService saveMovesTagsCategoriesToDb:responseDict];
    }
}

#pragma mark - Help and Support Methods
- (void)mailAction:(id)sender {
    MessageViewController *vc = [[MessageViewController alloc] initWithNibName:@"MessageView" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

-(IBAction)showActionSheet:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *alertTitle = [NSString stringWithFormat:@"%@ Help & Support", [prefs valueForKey:@"companyname_dietmastergo"]];
    
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:alertTitle delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Send an Email", nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:self.tabBarController.view];
    [popupQuery release];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self emailUs:nil];
    }
    else if (buttonIndex == 2) {
    }
}

-(void)emailUs:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSString *finalPath = [path stringByAppendingPathComponent:PLIST_NAME];
        NSDictionary *appDefaults = [[[NSDictionary alloc] initWithContentsOfFile:finalPath] autorelease];
        
        MFMailComposeViewController *mailComposer = [[[MFMailComposeViewController alloc] init] autorelease];
        [mailComposer setSubject:[NSString stringWithFormat:@"%@ App Help & Support", [appDefaults valueForKey:@"app_name_short"]]];
        NSString *emailTo = [[[NSString alloc] initWithFormat:@""] autorelease];
        [mailComposer setMessageBody:emailTo isHTML:NO];
        NSString *emailTo1 = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"LoginEmail"]];
        NSArray *toArray = [NSArray arrayWithObjects:emailTo1, nil];
        [mailComposer setToRecipients:toArray];
        mailComposer.mailComposeDelegate = self;
        [self presentViewController:mailComposer animated:YES completion:nil];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:APP_NAME message:@"There are no Mail accounts configured. You can add or create a Mail account in Settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
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
    [alert release];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark DATA LOADING METHODS
-(void)reloadData {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([prefs valueForKey:@"userid_dietmastergo"] > 0) {
        [self performSelectorOnMainThread:@selector(showLoading) withObject:nil waitUntilDone:NO];
        [self performSelector:@selector(loadData) withObject:nil afterDelay:0.25];
        [self performSelector:@selector(loadExerciseData) withObject:nil afterDelay:0.15];
    }
}

-(void)loadData {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
        
    }
    
    NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    NSDate* date_homeDate = [NSDate date];
    NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
    [dateFormat setTimeZone:systemTimeZone];
    NSString *date_Today = [dateFormat stringFromDate:date_homeDate];
    
    num_totalCalories = 0;
    totalFat = 0.0;
    totalCarbs = 0.0;
    totalProtein = 0.0;
    double difference = 0.0;
    
    NSString *query = [NSString stringWithFormat: @"SELECT Food_Log.MealID, Food_Log.MealDate, Food_Log_Items.MealCode, Food_Log_Items.FoodID, Food_Log_Items.MeasureID, Food_Log_Items.NumberOfServings, Food.FoodKey, Food.Name, Food.Calories, Food.Fat, Food.Carbohydrates, Food.Protein, FoodMeasure.GramWeight, Food.ServingSize FROM Food_Log INNER JOIN Food_Log_Items ON Food_Log.MealID = Food_Log_Items.MealID INNER JOIN Food ON Food.FoodKey = Food_Log_Items.FoodID INNER JOIN FoodMeasure ON FoodMeasure.FoodID = Food.FoodKey WHERE (Food_Log.MealDate BETWEEN DATETIME('%@ 00:00:00') AND DATETIME('%@ 23:59:59')) AND Food_Log_Items.MeasureID = FoodMeasure.MeasureID ORDER BY Food_Log_Items.MealCode ASC", date_Today, date_Today];
    
    FMResultSet *rs = [db executeQuery:query];
    while ([rs next]) {
        
        int fatGrams = [rs doubleForColumn:@"Fat"];
        int totalFatCalories = [rs doubleForColumn:@"NumberOfServings"] * ((fatGrams * 9.0) * ([rs doubleForColumn:@"GramWeight"] / 100) / [rs doubleForColumn:@"ServingSize"]);
        totalFat = totalFat + totalFatCalories;
        
        int carbGrams = [rs doubleForColumn:@"Carbohydrates"];
        int totalCarbCalories = [rs doubleForColumn:@"NumberOfServings"] * ((carbGrams * 4.0) * ([rs doubleForColumn:@"GramWeight"] / 100) / [rs doubleForColumn:@"ServingSize"]);
        totalCarbs = totalCarbs + totalCarbCalories;
        
        int proteinGrams = [rs doubleForColumn:@"Protein"];
        int totalProteinCalories = [rs doubleForColumn:@"NumberOfServings"] * ((proteinGrams * 4.0) * ([rs doubleForColumn:@"GramWeight"] / 100) / [rs doubleForColumn:@"ServingSize"]);
        totalProtein = totalProtein + totalProteinCalories;
        
        int totalCalories = [rs doubleForColumn:@"NumberOfServings"] * (([rs doubleForColumn:@"Calories"] * ([rs doubleForColumn:@"GramWeight"] / 100)) / [rs doubleForColumn:@"ServingSize"]);
        
        num_totalCalories = num_totalCalories + totalCalories;
    }


    [rs close];
    
    //HHT apple watch (gender added)
    NSString *getGoalSQL = @"SELECT weight_goal, Goals ,Height, gender FROM User";
    
    int intGoalWeight = 0;
    int intWeightGoal = 0;
    int gender = -1;
    
    rs = [db executeQuery:getGoalSQL];
    while ([rs next]) {
        gender = [rs doubleForColumn:@"Gender"];
        intGoalWeight = [rs intForColumn:@"Goals"];
        intWeightGoal = [rs intForColumn:@"weight_goal"];
        currentHeight = [rs doubleForColumn:@"Height"];
    }
    
    dietmasterEngine.userHeight = [NSNumber numberWithDouble:currentHeight];
    dietmasterEngine.userGender = gender;
    
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"isKgs"] boolValue]) {
        lblGoal_lbs.text = [NSString stringWithFormat:@"%d lbs",intWeightGoal];
    }
    else {
        lblGoal_lbs.text = [NSString stringWithFormat:@"%d Kgs",intWeightGoal];
        
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d.00",intWeightGoal] forKey:@"GoalWeight"];
    
    if (intGoalWeight == 0) {
        lbl_GoalWeight.text = [NSString stringWithFormat:@"%@", @"Weight Loss"];
        lblWeightStatus.text = [NSString stringWithFormat:@"%@", @"Lost: "];
        
        //HHT 23-11
        strWeightStatus = @"Lost: ";
    }
    else if (intGoalWeight == 1) {
        lbl_GoalWeight.text = [NSString stringWithFormat:@"%@", @"Maintain Weight"];
        lblWeightStatus.text = [NSString stringWithFormat:@"%@", @"Maintained: "];
        
        //HHT 23-11
        strWeightStatus = @"Maintained: ";
    }
    else if (intGoalWeight == 2) {
        lbl_GoalWeight.text = [NSString stringWithFormat:@"%@", @"Weight Gain"];
        lblWeightStatus.text = [NSString stringWithFormat:@"%@", @"Gained: "];
        
        //HHT 23-11
        strWeightStatus = @"Gained: ";
    }
    else {
        
        if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"isKgs"] boolValue]) {
            lbl_GoalWeight.text = [NSString stringWithFormat:@"%i lbs.", intGoalWeight];
            
            lblWeightStatus.text = [NSString stringWithFormat:@"%i lbs.", intGoalWeight];
            
            lblCurrentBMI.hidden = lblBodyFat.hidden = currentBMILabel.hidden = percentBodyFatLabel.hidden = NO;
        }
        else{
            
            lbl_GoalWeight.text = [NSString stringWithFormat:@"%i Kgs", intGoalWeight];
            
            lblWeightStatus.text = [NSString stringWithFormat:@"%i Kgs", intGoalWeight];
            
            lblCurrentBMI.hidden = lblBodyFat.hidden = currentBMILabel.hidden = percentBodyFatLabel.hidden = YES;
        }
    }
    
    [rs close];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setTimeZone:systemTimeZone];
    [dateFormatter setLenient:YES];
    NSString *StrCurrentDate = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *getWeightSQL = [NSString stringWithFormat:@"SELECT weight FROM weightlog where logtime in (select logtime from weightlog WHERE logtime = '%@') AND deleted = 1", StrCurrentDate];
    
    rs = [db executeQuery:getWeightSQL];
    while ([rs next]) {
        currentWeight = [rs doubleForColumn:@"weight"];
    }
    
    if (currentWeight == 0) {
        NSString *getWeightSQL = @"SELECT weight FROM weightlog where logtime in (select max(logtime) from weightlog WHERE deleted = 1) AND deleted = 1";
        rs = [db executeQuery:getWeightSQL];
        while ([rs next]) {
            currentWeight = [rs doubleForColumn:@"weight"];
        }
    }
    
    NSString *getStartWeight = @"SELECT weight FROM weightlog where logtime in (select min(logtime) from weightlog WHERE deleted = 1) AND deleted = 1";
    rs = [db executeQuery:getStartWeight];
    while ([rs next]) {
        startWeight = [rs doubleForColumn:@"weight"];
    }
    
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"isKgs"] boolValue]) {
        lblStart_lbs.text = [NSString stringWithFormat:@"%.1f lbs", startWeight];
    }
    else {
        lblStart_lbs.text = [NSString stringWithFormat:@"%.1f Kgs", startWeight];
    }
    
    //HHT new change
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"isKgs"] boolValue]) {
        lbl_CurrentWeight.text = [NSString stringWithFormat:@"%.1f lbs.", currentWeight];
        
        //lblWeight.text = [NSString stringWithFormat:@"%@ %.1f lbs",strWeightStatus,currentWeight-startWeight];
        //HHT change 2018
        lblProgressBarCurrentWeight.text = [NSString stringWithFormat:@"%.1f lbs.", currentWeight];
        
        if (startWeight < intWeightGoal) {
            lblWeight.text = [NSString stringWithFormat:@"%@ %.1f lbs",strWeightStatus,currentWeight-startWeight];
        }
        else if (startWeight > intWeightGoal) {
            lblWeight.text = [NSString stringWithFormat:@"%@ %.1f lbs",strWeightStatus,startWeight - currentWeight];
        }
        else if (startWeight == intWeightGoal) {
            lblWeight.text = [NSString stringWithFormat:@"%@ %.1f lbs",strWeightStatus,startWeight - 0];
        }
    }
    else {
        lbl_CurrentWeight.text = [NSString stringWithFormat:@"%.1f Kgs", currentWeight];
        
        //HHT change 2018
        lblProgressBarCurrentWeight.text = [NSString stringWithFormat:@"%.1f Kgs", currentWeight];
        
        if (startWeight < intWeightGoal) {
            lblWeight.text = [NSString stringWithFormat:@"%@ %.1f Kgs",strWeightStatus,currentWeight-startWeight];
        }
        else if (startWeight > intWeightGoal) {
            lblWeight.text = [NSString stringWithFormat:@"%@ %.1f Kgs",strWeightStatus,startWeight - currentWeight];
        }
        else if (startWeight == intWeightGoal) {
            lblWeight.text = [NSString stringWithFormat:@"%@ %.1f Kgs",strWeightStatus,startWeight - 0];
        }
        
        //lblWeight.text = [NSString stringWithFormat:@"%@ %.1f Kgs",strWeightStatus,currentWeight-startWeight];
    }
    
    double progressValue = 0.0;
    
    if (startWeight < intWeightGoal) {
        //weight gain
        difference = (int) (intWeightGoal - startWeight);
    } else if (startWeight > intWeightGoal) {
        //weight loss
        difference = (int) (startWeight - intWeightGoal);
    } else if (startWeight == intWeightGoal) {
        difference = (int) (startWeight - 0);
    }
    
    progressValue = ((startWeight - currentWeight) / difference);

    [progressbar setProgress:fabs(progressValue) animated:YES];
    progressbar.progressTintColor = AccentColor
    
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"isKgs"] boolValue]) {
        progressbar.indicatorTextLabel.text = [NSString stringWithFormat:@"%.1f lbs",currentWeight];
    }
    else {
        progressbar.indicatorTextLabel.text = [NSString stringWithFormat:@"%.1f Kgs",currentWeight];
    }
    
    dietmasterEngine.currentWeight = [NSNumber numberWithDouble:currentWeight];
    [rs close];
    
    [self performSelector:@selector(getBMR) withObject:nil afterDelay:0.25];
    
    double netCalories = num_BMR - num_totalCalories;
    
    lbl_CalorieDifference.text = [NSString stringWithFormat:@"%.0f", netCalories];
    lblGoal.text = [NSString stringWithFormat:@"%.0f", netCalories];
    [self updateCalorieTotal];
    [self calculateBMI];
    
    NSString *getBodyFatSQL = @"SELECT bodyfat FROM weightlog where logtime in (select max(logtime) from weightlog WHERE deleted = 1)";
    CGFloat bodyFat = 0.0;
    rs = [db executeQuery:getBodyFatSQL];
    while ([rs next]) {
        
        bodyFat = [rs doubleForColumn:@"bodyfat"];
    }
    percentBodyFatLabel.text = [NSString stringWithFormat:@"%.1f%%", bodyFat];
    lblBody_Fat.text = [NSString stringWithFormat:@"%.1f%%", bodyFat];
    [rs close];
    [self performSelectorOnMainThread:@selector(hideLoading) withObject:nil waitUntilDone:NO];
}

-(void)caloriesRemainUpdate
{
    NSString *remainingCalorieCount;
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    double calRecommended = [dietmasterEngine getBMR];
    
    if (num_totalCaloriesBurned == 0)
    {
        lblCaloriesRemainingValue.text=[NSString stringWithFormat:@"%.f",[lbl_CaloriesRecommended.text doubleValue] - num_totalCalories];
    }
    else
    {
        remainingCalorieCount=[NSString stringWithFormat:@"%.0f",calRecommended + num_totalCaloriesBurned];
        lblCaloriesRemainingValue.text=[NSString stringWithFormat:@"%.f",[remainingCalorieCount doubleValue] - num_totalCalories];
    }
   
}
-(void)loadExerciseData {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
        
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate* sourceDate = [NSDate date];
    NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
    [dateFormat setTimeZone:systemTimeZone];
    NSString *date_string = [dateFormat stringFromDate:sourceDate];
    NSDate *date_homeDate = [dateFormat dateFromString:date_string];
    
    [dateFormatter setTimeZone:systemTimeZone];
    NSString *date_Today        = [dateFormatter stringFromDate:date_homeDate];
    
    NSString *query;
    
    query = [NSString stringWithFormat:@"SELECT Exercise_Log.Exercise_Log_ID, Exercise_Log.ExerciseID, Exercise_Log.Exercise_Time_Minutes, Exercise_Log.Log_Date, Exercises.ActivityName, Exercises.CaloriesPerHour FROM Exercise_Log INNER JOIN Exercises ON Exercise_Log.ExerciseID = Exercises.ExerciseID WHERE (Exercise_Log.Log_Date BETWEEN DATETIME('%@ 00:00:00') AND DATETIME('%@ 23:59:59')) ORDER BY Log_Date", date_Today, date_Today];
    
    num_totalCaloriesBurned = 0;
    
    FMResultSet *rs = [db executeQuery:query];
    while ([rs next]) {
        
        NSNumber *exerciseTimeMinutes = [NSNumber numberWithInt:[rs intForColumn:@"Exercise_Time_Minutes"]];
        NSNumber *caloriesPerHour = [NSNumber numberWithDouble:[rs doubleForColumn:@"CaloriesPerHour"]];
        
        int minutesExercised = [exerciseTimeMinutes intValue];
        
        double totalCaloriesBurned = ([caloriesPerHour floatValue] / 60) * [dietmasterEngine.currentWeight floatValue] * minutesExercised;
        
        int exerciseID = [rs intForColumn:@"ExerciseID"];
        
        if (exerciseID == 259) {
            
        }
        //HHT apple watch 274 for step count
        else if (exerciseID == 274 || exerciseID == 276) {
            
        }
        //HHT apple watch (272) calories apple watch
        else if (exerciseID == 257 || exerciseID == 267 || exerciseID == 272 || exerciseID == 275) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CalorieTrackingDevice"]) {
                num_totalCaloriesBurned = num_totalCaloriesBurned + minutesExercised;
            }
        }
        else {
            //HHT change 28-11
            //YES means add LoggedExeTracking and no means not add
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"LoggedExeTracking"] == YES) {
                num_totalCaloriesBurned = num_totalCaloriesBurned + totalCaloriesBurned;
            }
            else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"LoggedExeTracking"] == NO){
                
            }
        }
    }
    
    [rs close];
    
    [dateFormatter release];
    
    [self updateCalorieTotal];
    [self calculateBMI];
}

-(void)updateCalorieTotal {
    
    double netCalories = num_totalCalories - num_totalCaloriesBurned;
    CGFloat caloriesREmaining = (num_BMR - (num_totalCaloriesBurned * -1)) - num_totalCalories;
    
    //HHT Change 2018 (exercise / 2 )
    //double netCalories = num_totalCalories - (num_totalCaloriesBurned/2);
    //CGFloat caloriesREmaining = (num_BMR - ((num_totalCaloriesBurned/2) * -1)) - num_totalCalories;
    
    lbl_CalorieDifference.text = [NSString stringWithFormat:@"%.0f", caloriesREmaining];
    [self.remainingCalories_Circular_Progress setMaxValue:num_BMR];
    
    //HHT change start
    if (caloriesREmaining < 0) {
//        lblCaloriesRemainingValue.text = [NSString stringWithFormat:@"%.0f", caloriesREmaining/2];
        [self.remainingCalories_Circular_Progress setValue:0];
    }
    else {
//        lblCaloriesRemainingValue.text = [NSString stringWithFormat:@"%.0f", caloriesREmaining/2];
        [self.remainingCalories_Circular_Progress setValue:caloriesREmaining];
    }
    //HHT change end
    
    //50% HHT Change 2018 (exercise / 2 )
    AppDel.caloriesremaning=[[NSString stringWithFormat:@"%.0f", caloriesREmaining] doubleValue];
    [self caloriesRemainUpdate];
    
    goalCalorieLabel.text = [NSString stringWithFormat:@"%i", num_BMR];
    lblGoal.text = [NSString stringWithFormat:@"%i", num_BMR];
    
    caloriesLoggedLabel.text = [NSString stringWithFormat:@"+%.0f", num_totalCalories];
    lblfoodCalories.text = [NSString stringWithFormat:@"+%.0f", num_totalCalories];
    
    exerciseCaloriesLoggedLabel.text = [NSString stringWithFormat:@"-%.0f", num_totalCaloriesBurned];
    
    //50% HHT Change 2018 (exercise / 2 )
    lblExerciseCalories.text = [NSString stringWithFormat:@"-%.0f", num_totalCaloriesBurned];

    netCalorieLabel.text = [NSString stringWithFormat:@"%.0f", netCalories];
//    lblNetCalories.text = [NSString stringWithFormat:@"%.0f", num_totalCalories - (num_totalCaloriesBurned/2)];
    lblNetCalories.text = [NSString stringWithFormat:@"%.0f", num_totalCalories - (num_totalCaloriesBurned)];

    double totalPercentage = totalFat + totalProtein + totalCarbs;
    if (totalFat)
    {
        totalFatLabel.text = [NSString stringWithFormat:@"%.1f%%", ((totalFat / totalPercentage) * 100)];
        lblFatPercent.text = [NSString stringWithFormat:@"Fat %.1f%%", ((totalFat / totalPercentage) * 100)];
    }
    
    //HHT new change
    else {
        lblFatPercent.text = [NSString stringWithFormat:@"Fat 0%%"];
    }
    
    if (totalProtein){
        totalProteinLabel.text = [NSString stringWithFormat:@"%.1f%%", ((totalProtein / totalPercentage) * 100)];
        lblProtinPercent.text = [NSString stringWithFormat:@"Protein %.1f%%", ((totalProtein / totalPercentage) * 100)];
    }
    //HHT new change
    else {
        lblProtinPercent.text = [NSString stringWithFormat:@"Protein 0%%"];
    }
    
    if (totalCarbs){
        totalCarbsLabel.text = [NSString stringWithFormat:@"%.1f%%", ((totalCarbs / totalPercentage) * 100)];
        lblCarbsPercent.text = [NSString stringWithFormat:@"Carbs %.1f%%", ((totalCarbs / totalPercentage) * 100)];
    }
    //HHT new change
    else {
        lblCarbsPercent.text = [NSString stringWithFormat:@"Carbs 0%%"];
    }
    
    CGFloat carbGramActual = totalCarbs / 4;
    CGFloat proteinGramActual = totalProtein / 4;
    CGFloat fatGramActual = totalFat / 9;
    
    //HHT cange start
    CGFloat fatGramActualPrecent = ((totalFat / totalPercentage) * 100);
    CGFloat proteinGramActualPrecent = ((totalProtein / totalPercentage) * 100);
    CGFloat carbsGramActualPercent = ((totalCarbs / totalPercentage) * 100);
    //HHT cange end
    
    actualCarbGramsLabel.text = [NSString stringWithFormat:@"%.1fg", carbGramActual];
    actualProteinGramsLabel.text = [NSString stringWithFormat:@"%.1fg", proteinGramActual];
    actualFatGramsLabel.text = [NSString stringWithFormat:@"%.1fg", fatGramActual];
    
    //new design v3.0 (HHT change 2018) circular lable value
    lblactualCarbGramsLabel.text = [NSString stringWithFormat:@"%.1fg", carbGramActual];
    lblactualProteinGramsLabel.text = [NSString stringWithFormat:@"%.1fg", proteinGramActual];
    lblactualFatGramsLabel.text = [NSString stringWithFormat:@"%.1fg", fatGramActual];
    
    if(isnan(fatGramActualPrecent)) {
        [fat_circular setValue:0];//HHT cange
    }
    else {
        [fat_circular setValue:fatGramActualPrecent];//HHT cange
    }
    
    [fat_circular setUnitString:@"g"];
    [fat_circular setMaxValue:100];//HHT cange
    
    if(isnan(proteinGramActualPrecent)) {
        [protein_Circular setValue:0];//HHT cange
    }
    else {
        [protein_Circular setValue:proteinGramActualPrecent];//HHT cange
    }
    [protein_Circular setUnitString:@"g"];
    [protein_Circular setMaxValue:100];//HHT cange
    
    if(isnan(carbsGramActualPercent)) {
        [carbs_circular setValue:0]; //HHT cange
    }
    else {
        [carbs_circular setValue:carbsGramActualPercent]; //HHT cange
    }
    [carbs_circular setUnitString:@"g"];
    [carbs_circular setMaxValue:100]; //HHT cange
}

-(void)animateCircularProgressbar
{
    [UIView animateWithDuration:1.f animations:^{
        
        [fat_circular setValue:totalFat / 9];
        [fat_circular setUnitString:@"%"];
        [fat_circular setMaxValue:totalFat];
        
        [protein_Circular setValue:totalProtein / 4];
        [protein_Circular setUnitString:@"%"];
        [protein_Circular setMaxValue:totalProtein];
        
        [carbs_circular setValue:totalCarbs / 4];
        [carbs_circular setUnitString:@"%"];
        [carbs_circular setMaxValue:totalCarbs];
        
    }];
}
-(void)calculateBMI {
    double bodyMassIndex = currentWeight / (currentHeight * currentHeight) * 703;
    currentBMILabel.text = [NSString stringWithFormat:@"%.1f", bodyMassIndex];
    lblCurrent_BMI.text = [NSString stringWithFormat:@"%.1f", bodyMassIndex];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods
-(void)showLoading {
    [HUD hide:YES afterDelay:0.0];
    HUD = [[MBProgressHUD showHUDAddedTo:self.view animated:YES] retain];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 6.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^ {
        [self showLoading1];
        [self loadData];
    });
}

-(void)hideLoading {
    [HUD hide:YES afterDelay:0.5];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    [HUD removeFromSuperview];
    [HUD release];
    HUD = nil;
}

-(void)showLoading1 {
    [HUD hide:YES afterDelay:0.0];
    HUD = [[MBProgressHUD showHUDAddedTo:self.view animated:YES] retain];
}

- (void)showCompleted {
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
    HUD.mode = MBProgressHUDModeCustomView;
    
    HUD.delegate = nil;
    HUD.labelText = @"Completed";
    
    [HUD show:YES];
    [HUD hide:YES afterDelay:1.0];
}

@end

