//
//  MyMovesViewController.m
//  MyMoves
//
//  Created by Samson  on 14/01/19.
//

#import "MyMovesViewController.h"

#import <HealthKit/HealthKit.h>
#import "FSCalendar/FSCalendar.h"
#import "StepData.h"
#import "MyMovesTableViewCell.h"
#import "MyMovesDetailsViewController.h"
#import "MyMovesListViewController.h"
#import "MyMovesWebServices.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "MyMovesListTableViewCell.h"
#import "NSArray+HOF.h"
#import "NSArray+HOFC.h"
#import "MessageViewController.h"
#import "DietMasterGoViewController.h"

@interface MyMovesViewController ()<FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance, WSGetUserWorkoutplanOffline, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) int userId;
@property (nonatomic) BOOL isLoading;

@property (nonatomic, strong) MyMovesWebServices *soapWebService;

/// Table view that shows the moves.
@property (nonatomic, strong) IBOutlet UITableView *movesTblView;

/// View that encapsulates the dayToolBar and date header.
@property (nonatomic, strong) IBOutlet UIView *dayToggleView;
@property (nonatomic, strong) IBOutlet UIToolbar *dayToolBar;
/// Displays the currently selected date.
@property (nonatomic, strong) IBOutlet UILabel *lblDateHeader;
/// Button to expand or hide the calendar day view.
@property (nonatomic, strong) IBOutlet UIButton *expandBtn;

/// View that encloses the calendar.
@property (nonatomic, strong) IBOutlet UIView *calendarView;
@property (nonatomic, strong) FSCalendar *calendar;

@property (nonatomic) int currentSection;
@property (nonatomic, strong) NSMutableArray *selectedExercisesArr;
@property (nonatomic, strong) NSMutableArray *prevDataArr;

@property (nonatomic,retain) HKHealthStore *healthStore;
@property (nonatomic, strong) StepData *sd;
@property (nonatomic, strong) NSDate *date_currentDate;

@property (nonatomic, strong) IBOutlet UILabel *displayedMonthLbl;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *proportionalHeightCalConst;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) NSMutableArray<NSString *> *datesWithInfo;
@property (nonatomic, strong) NSMutableArray *datesExerciseCompletd;
@property (nonatomic, strong) NSMutableArray *exerciseData;
@property (nonatomic, strong) NSMutableArray *userPlanListData;
@property (nonatomic, strong) NSMutableArray *userPlanDateListData;
@property (nonatomic, strong) NSMutableArray *userPlanMoveListData;
@property (nonatomic, strong) NSMutableArray *userPlanMoveSetListData;
@property (nonatomic, strong) NSMutableArray *loadMoveDetails;
@property (nonatomic, strong) NSMutableArray *deletedPlanArr;
@property (nonatomic, strong) NSMutableArray *deletedPlanDateArr;
@property (nonatomic, strong) NSMutableArray *deletedMoveArr;
@property (nonatomic, strong) NSMutableArray *deletedMoveSetArr;
@property (nonatomic, strong) NSMutableArray *listViewItem;
@property (nonatomic, strong) NSMutableArray *tblData;
@property (nonatomic, strong) NSMutableArray *sectionTitleDataMovesTblView;
@property (nonatomic, strong) NSDate *prevDate;
@property (nonatomic, strong) NSMutableArray *sectionTitle;

@end

@implementation MyMovesViewController

- (instancetype)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     
    // Put chat button on Right upper nav.
    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRight setFrame:CGRectMake(0, 0, 28, 28)];
    UIImage *image = [UIImage imageNamed:@"ionic-ios-chatbubbles"];
    image = [image imageWithTintColor:[UIColor whiteColor] renderingMode:UIImageRenderingModeAlwaysTemplate];
    [btnRight setImage:image forState:UIControlStateNormal];
    [btnRight setBackgroundColor:[UIColor clearColor]];
    [btnRight addTarget:self action:@selector(sendMsgBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [btnRight setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *barBtnRight = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    self.navigationItem.rightBarButtonItem = barBtnRight;

    [self.navigationController setNavigationBarHidden:NO];
    self.navigationItem.hidesBackButton = YES;

    _dayToggleView.backgroundColor = AccentColor;
    _dayToolBar.barTintColor = AccentColor;
    UIImage *btnImage = [[UIImage imageNamed:@"log_up_arrow"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.expandBtn setImage:btnImage forState:UIControlStateNormal];
    self.expandBtn.tintColor = AccentColor
    
    _exerciseData = [[NSMutableArray alloc]init];
    _userPlanListData = [[NSMutableArray alloc]init];
    _userPlanDateListData = [[NSMutableArray alloc]init];
    _userPlanMoveListData = [[NSMutableArray alloc]init];
    _userPlanMoveSetListData = [[NSMutableArray alloc]init];
    _loadMoveDetails = [[NSMutableArray alloc]init];
    _listViewItem = [[NSMutableArray alloc]init];
    _sectionTitle = [[NSMutableArray alloc]init];
    _deletedPlanArr = [[NSMutableArray alloc]init];
    _deletedPlanDateArr = [[NSMutableArray alloc]init];
    _deletedMoveArr = [[NSMutableArray alloc]init];
    _deletedMoveSetArr = [[NSMutableArray alloc]init];
    _tblData = [[NSMutableArray alloc]init];
    self.prevDate = [[NSDate alloc]init];
    self.prevDataArr = [[NSMutableArray alloc]init];
    
    self.movesTblView.delegate = self;
    self.movesTblView.dataSource = self;
    
    self.datesExerciseCompletd = [[NSMutableArray alloc]init];
    self.datesWithInfo = [[NSMutableArray alloc]init];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"yyyy/MM/dd";
        
    self.calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(_calendarView.bounds.origin.x, _calendarView.bounds.origin.y + 15, SCREEN_WIDTH, _calendarView.bounds.size.height - 50)];
    self.calendar.dataSource = self;
    self.calendar.delegate = self;
    self.calendar.scrollDirection = FSCalendarScrollDirectionVertical;
    self.calendar.backgroundColor = [UIColor whiteColor];
    self.calendar.scope = FSCalendarScopeMonth;
    self.calendar.appearance.subtitlePlaceholderColor = [UIColor darkTextColor];
    self.calendar.appearance.subtitleDefaultColor = [UIColor yellowColor];
    self.calendar.appearance.subtitleWeekendColor = [UIColor redColor];
    
    [self.calendar.calendarHeaderView setHidden:YES];
    self.calendar.headerHeight = 0;
    [self.calendar selectDate:[NSDate date]];
    
    [self.calendarView addSubview:self.calendar];
    
    self.selectedExercisesArr = [[NSMutableArray alloc]init];
    self.arrData = [NSMutableArray new];
    self.healthStore = [[HKHealthStore alloc] init];
    self.sd = [[StepData alloc]init];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"My Moves";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};

    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    dietmasterEngine.taskMode = @"View";
    
    //set date in current date variable
    NSDate* sourceDate = [NSDate date];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
    [self.dateFormatter setTimeZone:systemTimeZone];
    self.date_currentDate = sourceDate;
    [self setDateLbl:sourceDate];
    
    self.soapWebService = [[MyMovesWebServices alloc] init];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.userId = [[prefs valueForKey:@"userid_dietmastergo"] intValue];
    
    if IS_IPHONE_X_XR_XS {
        self.proportionalHeightCalConst.constant = self.view.frame.size.height /4;
        [self.calendarView setHidden:NO];
    } else {
        self.proportionalHeightCalConst.constant = self.view.frame.size.height /3;
        [self.calendarView setHidden:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    DietmasterEngine *engine = [DietmasterEngine sharedInstance];

    if IS_IPHONE_X_XR_XS {
        self.proportionalHeightCalConst.constant = self.view.frame.size.height /4;
        [self.calendarView setHidden:NO];
    } else {
        self.proportionalHeightCalConst.constant = self.view.frame.size.height /3;
        [self.calendarView setHidden:NO];
    }

    self.soapWebService = [[MyMovesWebServices alloc] init];
    if (engine.sendAllServerData == true) {
        self.soapWebService.WSGetUserWorkoutplanOfflineDelegate = self;
    }
    [self.soapWebService offlineSyncApi];
    [self loadTableData:self.date_currentDate];

    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"My Moves";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController) {
        [[self navigationController] setNavigationBarHidden:YES animated:YES];
    }
}

-(void)loadEventCalendar:(NSMutableArray*)datesArr {
    if (!datesArr.count) {
        [self.calendar reloadData];
        return;
    }
    
    [DMActivityIndicator showActivityIndicator];

    self.prevDataArr = [[NSMutableArray alloc] initWithArray:datesArr];
    self.datesExerciseCompletd = [[NSMutableArray alloc] init];
    self.datesWithInfo = [[NSMutableArray alloc] init];
    
    //This is the worker block operation
    self.isLoading = YES;
    for (NSDictionary *dict in datesArr)
    {
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];

        NSArray *planDateArr = nil;
        if ([dict[@"PlanDate"] containsString:@"T"]) {
            planDateArr = [dict[@"PlanDate"] componentsSeparatedByString:@"T"];
        } else {
            planDateArr = [dict[@"PlanDate"] componentsSeparatedByString:@" "];
        }
        NSString *dateString = [NSString stringWithFormat:@"%@T00:00:00",planDateArr.firstObject];
        NSDate *dateFormate = [self.dateFormatter dateFromString:dateString];
        [self.dateFormatter setDateFormat:@"yyyy/MM/dd"];
        [self.datesWithInfo addObject:[self.dateFormatter stringFromDate:dateFormate]];
    }

    [self.datesExerciseCompletd addObjectsFromArray:datesArr];
    self.isLoading = NO;
    [self.calendar reloadData];
    [DMActivityIndicator hideActivityIndicator];
}

- (void)loadCircleInCalendar:(NSMutableArray*)datesArr {
    [DMActivityIndicator showActivityIndicator];

    self.prevDataArr = [[NSMutableArray alloc] initWithArray:datesArr];
    
    self.datesExerciseCompletd = [[NSMutableArray alloc]init];
    self.datesWithInfo = [[NSMutableArray alloc]init];
    
    for (int i = 0 ;i < datesArr.count;i++)
    {
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        NSArray *arr = [datesArr[i][@"WorkoutDate"] componentsSeparatedByString:@"T"];
        NSString *dateString = [NSString stringWithFormat:@"%@T00:00:00",[arr objectAtIndex:0]];
        NSDate *date = [self.dateFormatter dateFromString:dateString];
        [self.dateFormatter setDateFormat:@"yyyy/MM/dd"];
        [self.datesWithInfo addObject:[self.dateFormatter stringFromDate:date]];
    }
    
    NSString * completedExerciseStr = @"true";
    
    NSPredicate *completedExercisePredicate = [NSPredicate predicateWithFormat:@"SELF.WorkingStatus IN %@", completedExerciseStr];
    
    NSMutableArray *completedExerciseArr = [[NSMutableArray alloc]initWithArray:[datesArr filteredArrayUsingPredicate:completedExercisePredicate]];
    
    NSMutableArray *completedExerciseArrDates = [[NSMutableArray alloc]init];
    
    for (int i = 0 ;i < completedExerciseArr.count;i++) {
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        NSArray *arr = [completedExerciseArr[i][@"WorkoutDate"] componentsSeparatedByString:@"T"];
        NSString *dateString = [NSString stringWithFormat:@"%@T00:00:00",[arr objectAtIndex:0]];
        NSDate *date = [self.dateFormatter dateFromString:dateString];
        [self.dateFormatter setDateFormat:@"yyyy/MM/dd"];
        [completedExerciseArrDates addObject:[self.dateFormatter stringFromDate:date]];
    }
    
    NSString * str = @"false";
    
    NSPredicate *incompletedExercisePredicate = [NSPredicate predicateWithFormat:@"SELF.WorkingStatus IN %@", str];
    
    NSMutableArray *incompletedExerciseArr = [[NSMutableArray alloc]initWithArray:[datesArr filteredArrayUsingPredicate:incompletedExercisePredicate]];
    
    NSMutableArray *incompletedExerciseArrDates = [[NSMutableArray alloc]init];
    
    for (int i = 0 ;i < incompletedExerciseArr.count;i++) {
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        NSArray *arr = [incompletedExerciseArr[i][@"WorkoutDate"] componentsSeparatedByString:@"T"];
        NSString *dateString = [NSString stringWithFormat:@"%@T00:00:00",[arr objectAtIndex:0]];
        NSDate *date = [self.dateFormatter dateFromString:dateString];
        [self.dateFormatter setDateFormat:@"yyyy/MM/dd"];
        [incompletedExerciseArrDates addObject:[self.dateFormatter stringFromDate:date]];
    }
    
    if (incompletedExerciseArr != nil && ([incompletedExerciseArr count] != 0)) {
        NSMutableSet* firstArraySet = [[[NSMutableSet alloc] initWithArray:completedExerciseArrDates]mutableCopy];
        NSMutableSet* secondArraySet = [[[NSMutableSet alloc] initWithArray:incompletedExerciseArrDates]mutableCopy];
        
        [firstArraySet minusSet: secondArraySet];
        
        NSArray *array = [firstArraySet allObjects];
        
        [self.datesExerciseCompletd addObjectsFromArray:array];
    } else {
        NSMutableSet* firstArraySet = [[NSMutableSet alloc] initWithArray:completedExerciseArrDates];
        [firstArraySet unionSet:firstArraySet];
        
        NSArray *array = [firstArraySet allObjects];
        self.datesExerciseCompletd = [[NSMutableArray alloc]initWithArray:array];
    }
    
    NSMutableSet* removeDuplicateSet = [[NSMutableSet alloc] initWithArray:self.datesExerciseCompletd];
    
    self.datesExerciseCompletd = [[NSMutableArray alloc]initWithArray:[removeDuplicateSet allObjects]];
    
    [self.calendar reloadData];
    [DMActivityIndicator hideActivityIndicator];
}

- (void)setDateLbl:(NSDate*)dateToSet {
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
    [self.dateFormatter setTimeZone:systemTimeZone];
    
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"isddmm"] boolValue]) {
        [self.dateFormatter setDateFormat:@"MMMM d, yyyy"];
        [self.dateFormatter setTimeZone:systemTimeZone];
    }
    else{
        [self.dateFormatter setDateFormat:@"d MMMM, yyyy"];
        [self.dateFormatter setTimeZone:systemTimeZone];
    }
    
    NSString *date_Display = [self.dateFormatter stringFromDate:dateToSet];
    self.lblDateHeader.text = date_Display;
        
    [self loadTableData:dateToSet];

    [self.dateFormatter setDateFormat:@"MMMM"];
    self.displayedMonthLbl.text = [self.dateFormatter stringFromDate:dateToSet];
}

//new API
-(void)loadCalendarOnMonthChange:(NSDate*)dateToSet {
    [self.dateFormatter setDateFormat:@"MMMM"];
    _displayedMonthLbl.text = [self.dateFormatter stringFromDate:dateToSet];
    
    [self.dateFormatter setDateFormat:@"yyyy-MM"];
    
    NSString *filter = @"%K CONTAINS %@";
    NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:filter,@"LastUpdated", [self.dateFormatter stringFromDate:dateToSet]];
    NSMutableArray * tempExDb = [[NSMutableArray alloc]init];
    tempExDb = [self.soapWebService loadUserPlanListFromDb];
    tempExDb = [self.soapWebService loadUserPlanDateListFromDb];

    _exerciseData = [[tempExDb filteredArrayUsingPredicate:categoryPredicate] mutableCopy];
    
    [DMActivityIndicator hideActivityIndicator];
}

- (void)loadTableData:(NSDate *)dateToSet {
    _userPlanListData        = [[NSMutableArray alloc] initWithArray:[self.soapWebService loadUserPlanListFromDb]];
    _userPlanDateListData    = [[NSMutableArray alloc] initWithArray:[self.soapWebService loadUserPlanDateListFromDb]];
    _userPlanMoveListData    = [[NSMutableArray alloc] initWithArray:[self.soapWebService loadUserPlanMoveListFromDb]];
    _userPlanMoveSetListData = [[NSMutableArray alloc] initWithArray:[self.soapWebService loadUserPlanMoveSetListFromDb]];
    
    _loadMoveDetails         = [[NSMutableArray alloc] initWithArray:[self.soapWebService loadListOfMovesFromDb]];
   
    _deletedPlanArr     = [[NSMutableArray alloc] initWithArray:[self.soapWebService MobileUserPlanList]];
    _deletedPlanDateArr = [[NSMutableArray alloc] initWithArray:[self.soapWebService MobileUserPlanDateList]];
    _deletedMoveArr     = [[NSMutableArray alloc] initWithArray:[self.soapWebService MobileUserPlanMoveList]];
    _deletedMoveSetArr  = [[NSMutableArray alloc] initWithArray:[self.soapWebService MobileUserPlanMoveSetList]];

    self.dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
    NSString *dateString = [self.dateFormatter stringFromDate:dateToSet];

    NSArray *arr = [dateString componentsSeparatedByString:@"T"];
    dateString = [NSString stringWithFormat:@"%@T00:00:00",[arr objectAtIndex:0]];
    
    if ([_userPlanDateListData count] != 0) {
        _tblData = [[NSMutableArray alloc] initWithArray:[_userPlanDateListData filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(PlanDate contains[c] %@)", dateString]]];
        [self.movesTblView reloadData];
        [self loadSectionsForMovesTbl];
    }
 
    if ([_deletedPlanArr count] != 0) {
        for (int i=0; i<_deletedPlanArr.count; i++) {
            NSString *deletedUniqID = _deletedPlanArr[i][@"UniqueID"];
            
            NSString *filter = @"%K == %@";
            NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:filter,@"ParentUniqueID",_deletedPlanArr[i][@"UniqueID"]];
            NSArray * tempArr = [[NSArray alloc]initWithArray:[_userPlanDateListData filteredArrayUsingPredicate:categoryPredicate]];
            for (int j=0; j<tempArr.count; j++)
            {
                NSString *deletedUniqID = tempArr[i][@"UniqueID"];
                
                NSString *filter = @"%K == %@";
                NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:filter,@"ParentUniqueID",tempArr[i][@"UniqueID"]];
                NSArray * tempArray = [[NSArray alloc]initWithArray:[_userPlanMoveListData filteredArrayUsingPredicate:categoryPredicate]];
                for (int k=0; k<tempArray.count; k++)
                {
                    NSString *deletedUniqID = tempArray[i][@"UniqueID"];
                    
                    NSString *filter = @"%K == %@";
                    NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:filter,@"ParentUniqueID",tempArray[i][@"UniqueID"]];
                    NSArray * delArr = [[NSArray alloc]initWithArray:[_userPlanMoveSetListData filteredArrayUsingPredicate:categoryPredicate]];
                    for (int l=0; l<delArr.count; l++)
                    {
                        NSString *deletedUniqID = delArr[i][@"UniqueID"];
                        [self.soapWebService clearedDataFromWeb:deletedUniqID];
                    }
                    [self.soapWebService clearedDataFromWeb:deletedUniqID];
                }
                [self.soapWebService clearedDataFromWeb:deletedUniqID];
            }
            [self.soapWebService clearedDataFromWeb:deletedUniqID];
            [self loadSectionsForMovesTbl];
        }
    }
    
    [self loadEventCalendar:[self.soapWebService loadUserPlanDateListFromDb]];

    if ([_deletedPlanDateArr count] != 0)
    {
        for (int l=0; l<_deletedPlanDateArr.count; l++)
        {
            NSString *deletedUniqID = _deletedPlanDateArr[l][@"UniqueID"];
            [self.soapWebService clearedDataFromWeb:deletedUniqID];
        }
        [self loadSectionsForMovesTbl];
    }
    if ([_deletedMoveArr count] != 0)
    {
        for (int l=0; l<_deletedMoveArr.count; l++)
        {
            NSString *deletedUniqID = _deletedMoveArr[l][@"UniqueID"];
            [self.soapWebService clearedDataFromWeb:deletedUniqID];
        }
        [self loadSectionsForMovesTbl];
    }
    if ([_deletedMoveSetArr count] != 0)
    {
        for (int l=0; l<_deletedMoveSetArr.count; l++)
        {
            NSString *deletedUniqID = _deletedMoveSetArr[l][@"UniqueID"];
            [self.soapWebService clearedDataFromWeb:deletedUniqID];
        }
        [self loadSectionsForMovesTbl];
    }
}

- (IBAction)shownextDate:(id)sender {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    NSCalendar *cal = [NSCalendar currentCalendar];
    [components setDay:+1];
    NSDate *date_Tomorrow = [cal dateByAddingComponents:components toDate:self.date_currentDate options:0];
    
    self.date_currentDate = date_Tomorrow;
    
    [self setDateLbl:date_Tomorrow];
    [self.calendar selectDate:date_Tomorrow];

    //HHT temp (IMP line)
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    dietmasterEngine.dateSelected = date_Tomorrow;
    
    HKAuthorizationStatus permissionStatus = [self.healthStore authorizationStatusForType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]];
    
    if (permissionStatus == HKAuthorizationStatusSharingAuthorized) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"LoggedAppleWatchTracking"] == YES){
        //    [self readData];
        }
        else {
            DMLog(@"** Auto update apple watch sync is off **");
        }
    }
    else if (permissionStatus == HKAuthorizationStatusSharingDenied) {
        DMLog(@"** HKHealthStore HKAuthorizationStatusSharingDenied **");
    }
}

- (IBAction)showprevDate:(id)sender {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    NSCalendar *cal = [NSCalendar currentCalendar];
    [components setDay:-1];
    NSDate *date_Yesterday = [cal dateByAddingComponents:components toDate:self.date_currentDate options:0];
    
    self.date_currentDate = date_Yesterday;
    [self setDateLbl:date_Yesterday];

    [self.calendar selectDate:date_Yesterday];

    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    dietmasterEngine.dateSelected = date_Yesterday;
    
    HKAuthorizationStatus permissionStatus = [self.healthStore authorizationStatusForType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]];
    
    if (permissionStatus == HKAuthorizationStatusSharingAuthorized) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"LoggedAppleWatchTracking"] == YES){
        //    [self readData];
        }
        else {
            DMLog(@"** Auto update apple watch sync is off **");
        }
    }
    else if (permissionStatus == HKAuthorizationStatusSharingDenied) {
        DMLog(@"** HKHealthStore HKAuthorizationStatusSharingDenied **");
    }
}

- (void)loadSectionsForMovesTbl {
    _sectionTitleDataMovesTblView = [[NSMutableArray alloc]init];
    
    for (int i =0 ; i<[_tblData count]; i++)
    {
        NSMutableArray * tempArr = [[NSMutableArray alloc]initWithArray:[_userPlanListData filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(UniqueID MATCHES[c] %@)", _tblData[i][@"ParentUniqueID"]]]];
        if ([tempArr count] != 0)
        {
            [_sectionTitleDataMovesTblView addObjectsFromArray:tempArr];
        }
    }
    NSMutableSet* removeDuplicateSetInSection = [[NSMutableSet alloc] initWithArray:_sectionTitleDataMovesTblView];
    _sectionTitleDataMovesTblView = [[NSMutableArray alloc]initWithArray:[removeDuplicateSetInSection allObjects]];
     
    _sectionTitleDataMovesTblView = [[NSMutableArray alloc] initWithArray:[self.soapWebService filterObjectsByKeys:@"UniqueID" array:_sectionTitleDataMovesTblView]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([_sectionTitleDataMovesTblView count] == 0) {
        return 1;
    } else {
        return [_sectionTitleDataMovesTblView count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([_sectionTitleDataMovesTblView count] == 0) {
        return 0;
    } else {
        NSString *filter = @"%K == %@";
        NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:filter,@"ParentUniqueID",_sectionTitleDataMovesTblView[section][@"UniqueID"]];
        NSArray * tempArr = [[NSArray alloc]initWithArray:[_tblData filteredArrayUsingPredicate:categoryPredicate]];
        NSMutableArray *rowListArr = [[NSMutableArray alloc] init];
        for (int j=0; j<[tempArr count]; j++)
        {
            NSPredicate *categoryPredicates = [NSPredicate predicateWithFormat:filter,@"ParentUniqueID",tempArr[j][@"UniqueID"]];
            NSArray * tempArrs = [[NSArray alloc]initWithArray:[_userPlanMoveListData filteredArrayUsingPredicate:categoryPredicates]];
            [rowListArr addObjectsFromArray:tempArrs];
        }
        rowListArr = [[NSMutableArray alloc]initWithArray:[self.soapWebService filterObjectsByKeys:@"UniqueID" array:rowListArr]];

        return  [rowListArr count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MyMovesTableViewCell";
    NSArray *arrData = [[NSBundle mainBundle]loadNibNamed:@"MyMovesTableViewCell" owner:nil options:nil];
    MyMovesTableViewCell *cell = [[MyMovesTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell = [arrData objectAtIndex:0];
    cell.bgView.backgroundColor = PrimaryDarkColor;
    [cell.addMoveLbl setHidden:YES];
    cell.tempLblView.backgroundColor = PrimaryDarkColor;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    cell.checkBoxBtn.tag = indexPath.row;
    [cell.checkBoxBtn addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchUpInside];
    

    NSString *filter = @"%K == %@";
    NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:filter,@"ParentUniqueID",_sectionTitleDataMovesTblView[indexPath.section][@"UniqueID"]]; //new API
    NSArray * tempArr = [[NSArray alloc]initWithArray:[_tblData filteredArrayUsingPredicate:categoryPredicate]];
    NSMutableArray *rowListArr = [[NSMutableArray alloc] init];
    NSMutableArray *moveNameListArr = [[NSMutableArray alloc] init];

    for (int j=0; j<[tempArr count]; j++) {
        NSPredicate *categoryPredicates = [NSPredicate predicateWithFormat:filter,@"ParentUniqueID",tempArr[j][@"UniqueID"]]; //new API
        NSArray * tempArrs = [[NSArray alloc]initWithArray:[_userPlanMoveListData filteredArrayUsingPredicate:categoryPredicates]];
        [rowListArr addObjectsFromArray:tempArrs];
    }
    
    for (int i=0; i<[rowListArr count]; i++)
    {
        NSPredicate *moveNamePredicates = [NSPredicate predicateWithFormat:filter,@"MoveID",rowListArr[indexPath.row][@"MoveID"]]; //new API
        NSArray * tempArrs = [[NSArray alloc]initWithArray:[_loadMoveDetails filteredArrayUsingPredicate:moveNamePredicates]];
        [moveNameListArr addObjectsFromArray:tempArrs];
    }
    
    NSMutableArray *filteredArr = [self.soapWebService filterObjectsByKeys:@"MoveID" array:moveNameListArr];
    cell.templateNameLbl.text = _sectionTitleDataMovesTblView[indexPath.section][@"PlanName"];
    cell.templateNameLbl.backgroundColor = PrimaryDarkColor;
    if ([moveNameListArr count] == 0)
    {
        cell.exerciseNameLbl.text = @"Air Squart";
    }
    else
    {
        cell.exerciseNameLbl.text = [NSString stringWithFormat:@"%@",filteredArr[0][@"MoveName"]];
     
        if ([rowListArr[indexPath.row][@"isCheckBoxClicked"] isEqualToString:@"no"])
        {
            cell.checkBoxImgView.image = [UIImage imageNamed:@"check-box-empty"];
        }
        else
        {
            cell.checkBoxImgView.image = [UIImage imageNamed:@"checkmark-tick"];
        }
    }
    
    return cell;
}

#pragma mark TABLE VIEW METHODS

- (void)loadRowDataDateArr:(NSMutableArray*)arr {
    for (int i = 0; i < [arr count]; i++) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEEE, d LLLL yyyy"];
        NSString *sectionTitle = arr[i];
        NSDate *date = [dateFormatter dateFromString:sectionTitle];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        
        NSString *filter = @"%K == %@";
        NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:filter,@"PlanDate",[dateFormatter stringFromDate:date]];
        [_listViewItem addObject:[_userPlanDateListData filteredArrayUsingPredicate:categoryPredicate]];
        DMLog(@"%lu", (unsigned long)[_listViewItem count]);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    self.movesTblView.tableFooterView.backgroundColor = UIColor.grayColor;

    NSString *filter = @"%K == %@";
    NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:filter,@"ParentUniqueID",_sectionTitleDataMovesTblView[indexPath.section][@"UniqueID"]]; //new API
    NSArray * tempArr = [[NSArray alloc]initWithArray:[_tblData filteredArrayUsingPredicate:categoryPredicate]];
    NSMutableArray *rowListArr = [[NSMutableArray alloc] init];
    NSMutableArray *moveNameListArr = [[NSMutableArray alloc] init];

    for (int j=0; j<[tempArr count]; j++) {
        NSPredicate *categoryPredicates = [NSPredicate predicateWithFormat:filter,@"ParentUniqueID",tempArr[j][@"UniqueID"]]; //new API
        NSArray * tempArrs = [[NSArray alloc]initWithArray:[_userPlanMoveListData filteredArrayUsingPredicate:categoryPredicates]];
        [rowListArr addObjectsFromArray:tempArrs];
    }
    
    DMLog(@"%@", rowListArr[indexPath.row]);
    
    for (int i=0; i<[rowListArr count]; i++)
    {
        NSPredicate *moveNamePredicates = [NSPredicate predicateWithFormat:filter,@"MoveID",rowListArr[indexPath.row][@"MoveID"]]; //new API
        NSArray * tempArrs = [[NSArray alloc]initWithArray:[_loadMoveDetails filteredArrayUsingPredicate:moveNamePredicates]];
        [moveNameListArr addObjectsFromArray:tempArrs];
    }
            
    if ([moveNameListArr count] != 0)
    {
        MyMovesDetailsViewController *moveDetailVc = [[MyMovesDetailsViewController alloc]initWithNibName:@"MyMovesDetailsViewController" bundle:nil];
        moveDetailVc.moveDetailDict =  moveNameListArr[indexPath.row];
        moveDetailVc.moveListDict =  rowListArr[indexPath.row];
        moveDetailVc.parentUniqueID = rowListArr[indexPath.row][@"UniqueID"];
        moveDetailVc.currentDate = self.date_currentDate;
        moveDetailVc.moveSetListDict = _userPlanMoveSetListData;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
        [self.navigationController pushViewController:moveDetailVc animated:YES];
    }

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([_sectionTitleDataMovesTblView count] == 0) {
        return nil;
    } else {
        static NSString *CellIdentifier = @"MyMovesTableViewCell";

        NSArray *arrData = [[NSBundle mainBundle]loadNibNamed:@"MyMovesTableViewCell" owner:nil options:nil];

        MyMovesTableViewCell *cell = [[MyMovesTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell = [arrData objectAtIndex:0];

        UILabel * lbl = [[UILabel alloc]init];
        lbl.frame = CGRectMake(cell.contentView.frame.origin.x, cell.contentView.frame.origin.y, cell.contentView.frame.size.width, cell.contentView.frame.size.height);
        lbl.backgroundColor = PrimaryColor;
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.textColor = [UIColor whiteColor];
        lbl.text = _sectionTitleDataMovesTblView[section][@"PlanName"];
        return lbl;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    static NSString *CellIdentifier = @"MyMovesTableViewCell";
    
    NSArray *arrData = [[NSBundle mainBundle]loadNibNamed:@"MyMovesTableViewCell" owner:nil options:nil];
    
    MyMovesTableViewCell *cell = [[MyMovesTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell = [arrData objectAtIndex:0];
    [cell.checkBoxImgView setHidden:YES];

    cell.exerciseDescriptionLbl.text = @"";
    cell.exerciseNameLbl.text = @"";
    cell.templateNameLbl.text = @"";
    
    [cell.addMoveLbl setHidden:NO];
    
    cell.bgView.backgroundColor = PrimaryDarkColor;

    [cell.arrowImgV setHidden:NO];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

    [button addTarget:self action:@selector(addMove:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"" forState:UIControlStateNormal];
    button.frame = cell.contentView.bounds;

    [cell.contentView addSubview:button];
    
    return [cell contentView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView != self.movesTblView) {
        return 50;
    } else {
        if ([_sectionTitleDataMovesTblView count] == 0) {
            return 0;
        } else {
            return 30;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == [_sectionTitleDataMovesTblView count] - 1) {
        return 30;
    } else if ([_sectionTitleDataMovesTblView count] == 0) {
        return 30;
    } else {
        return 0;
    }
}

- (IBAction)didselectSection:(UIButton *)sender {
    if (self.currentSection == sender.tag) {
        self.currentSection = 1200;
    } else {
        self.currentSection = sender.tag;
        [self.dateFormatter setDateFormat:@"EEEE, d LLLL yyyy"];
        NSDate *date = [self.dateFormatter dateFromString:_sectionTitle[sender.tag]];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        
        NSString *filter = @"%K == %@";
        NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:filter,@"WorkoutDate", [self.dateFormatter stringFromDate:date]];
       
        _listViewItem = [[NSMutableArray alloc]initWithArray:[_exerciseData filteredArrayUsingPredicate:categoryPredicate]];
    }
}

/// Shows the my moves list view controller for a user to select an exercise.
- (IBAction)addMove:(UIButton *)sender {
    MyMovesListViewController *moveListVc = [[MyMovesListViewController alloc] initWithNibName:@"MyMovesListViewController" bundle:nil];
    NSString *statusValue = @"New";
    NSString *filter = @"%K == %@";
    NSPredicate *newPredicate = [NSPredicate predicateWithFormat:filter,@"Status",statusValue];
    NSArray * tempArr = [[NSMutableArray alloc]initWithArray:[_userPlanListData filteredArrayUsingPredicate:newPredicate]];
#warning TODO: Reconnect this??
    [self.navigationController pushViewController:moveListVc animated:YES];
}

-(IBAction)checkAction:(UIButton *)sender {
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.movesTblView]; // maintable --> replace your tableview name
    NSIndexPath *clickedButtonIndexPath = [self.movesTblView indexPathForRowAtPoint:touchPoint];
    
    NSString *filter = @"%K == %@";
    NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:filter,@"ParentUniqueID",_sectionTitleDataMovesTblView[clickedButtonIndexPath.section][@"UniqueID"]]; //new API
    NSArray * tempArr = [[NSArray alloc]initWithArray:[_tblData filteredArrayUsingPredicate:categoryPredicate]];
    NSMutableArray *rowListArr = [[NSMutableArray alloc] init];
    NSMutableArray *moveNameListArr = [[NSMutableArray alloc] init];
    
    for (int j=0; j<[tempArr count]; j++) {
        NSPredicate *categoryPredicates = [NSPredicate predicateWithFormat:filter,@"ParentUniqueID",tempArr[j][@"UniqueID"]]; //new API
        NSArray * tempArrs = [[NSArray alloc]initWithArray:[_userPlanMoveListData filteredArrayUsingPredicate:categoryPredicates]];
        [rowListArr addObjectsFromArray:tempArrs];
    }
    
    for (int i=0; i<[rowListArr count]; i++)
    {
        NSPredicate *moveNamePredicates = [NSPredicate predicateWithFormat:filter,@"MoveID",rowListArr[clickedButtonIndexPath.row][@"MoveID"]]; //new API
        NSArray * tempArrs = [[NSArray alloc]initWithArray:[_loadMoveDetails filteredArrayUsingPredicate:moveNamePredicates]];
        [moveNameListArr addObjectsFromArray:tempArrs];
    }
    
    
    if ([rowListArr[clickedButtonIndexPath.row][@"isCheckBoxClicked"] isEqualToString:@"no"])
    {
        [self.soapWebService updateCheckBoxStatusToDb:rowListArr[clickedButtonIndexPath.row][@"UniqueID"] checkBoxStatus:@"yes"];
    }
    else
    {
        [self.soapWebService updateCheckBoxStatusToDb:rowListArr[clickedButtonIndexPath.row][@"UniqueID"] checkBoxStatus:@"no"];
    }
    
    [self loadTableData:self.date_currentDate];
}

#pragma mark - <FSCalendarDelegate>

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
    return YES;
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
    if (monthPosition == FSCalendarMonthPositionNext || monthPosition == FSCalendarMonthPositionPrevious) {
        [calendar setCurrentPage:date animated:YES];
    }
    self.date_currentDate = calendar.selectedDate;
    [self setDateLbl:calendar.selectedDate];
}

- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar {
    // No-op.
}

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated {
    calendar.frame = (CGRect){calendar.frame.origin,bounds.size};
}

#pragma mark - <FSCalendarDelegateAppearance>

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillSelectionColorForDate:(NSDate *)date {
    return [UIColor blackColor];
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillDefaultColorForDate:(NSDate *)date {
    return [UIColor whiteColor];
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderDefaultColorForDate:(NSDate *)date {
    self.dateFormatter.dateFormat = @"yyyy/MM/dd";
    NSString *dateString = [self.dateFormatter stringFromDate:date];
    if ([[self.datesWithInfo copy] containsObject:dateString]) {
        return [UIColor greenColor];
    } else {
        return [UIColor whiteColor];
    }
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderSelectionColorForDate:(NSDate *)date {
    return [UIColor blackColor];
}

#pragma mark - <WSWorkoutplanOfflineListDelegate>

- (void)getUserWorkoutplanOfflineListFailed:(NSString *)failedMessage {
    [DMActivityIndicator hideActivityIndicator];
}

- (void)getUserWorkoutplanOfflineListFinished:(NSDictionary *)responseArray {
    [DMActivityIndicator hideActivityIndicator];

    _userPlanListData        = [[NSMutableArray alloc] initWithArray:[responseArray objectForKey:@"ServerUserPlanList"]];
    _userPlanDateListData    = [[NSMutableArray alloc] initWithArray:[responseArray objectForKey:@"ServerUserPlanDateList"]];
    _userPlanMoveListData    = [[NSMutableArray alloc] initWithArray:[responseArray objectForKey:@"ServerUserPlanMoveList"]];
    _userPlanMoveSetListData = [[NSMutableArray alloc] initWithArray:[responseArray objectForKey:@"ServerUserPlanMoveSetList"]];

    [self loadEventCalendar:[[NSMutableArray alloc] initWithArray:[responseArray objectForKey:@"ServerUserPlanDateList"]]];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.movesTblView reloadData];
        [DMActivityIndicator hideActivityIndicator];
    });
}

- (IBAction)expandButtonAction:(id)sender {
    
    if IS_IPHONE_X_XR_XS {
        [UIView animateWithDuration:0.3 animations:^{
            if (self.proportionalHeightCalConst.constant == self.view.frame.size.height /4) {
                self.proportionalHeightCalConst.constant = 0;
                [self.calendarView setHidden:YES];
            } else {
                self.proportionalHeightCalConst.constant = self.view.frame.size.height /4;
                [self.calendarView setHidden:NO];
            }
            [self.view layoutIfNeeded];
            [self.view layoutSubviews];
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            if (self.proportionalHeightCalConst.constant == self.view.frame.size.height /3) {
                self.proportionalHeightCalConst.constant = 0;
                [self.calendarView setHidden:YES];
            } else {
                self.proportionalHeightCalConst.constant = self.view.frame.size.height /3;
                [self.calendarView setHidden:NO];
            }
            [self.view layoutIfNeeded];
            [self.view layoutSubviews];
        }];
    }
}

- (void)passDataOnAdd {
    [self loadTableData:self.date_currentDate];
}

- (IBAction)sendMsgBtnAction:(id)sender {
    MessageViewController *vc = [[MessageViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
