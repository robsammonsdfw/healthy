//
//  MyMovesViewController.m
//  MyMoves
//
//  Created by Samson  on 14/01/19.
//

#import "MyMovesViewController.h"
#import "AppSettings.h"
#import "MyMovesTableViewCell.h"
#import "MyMovesDetailsViewController.h"
#import "MyMovesListViewController.h"
#import "MyMovesWebServices.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "Reachability.h"
#import "MyMovesListTableViewCell.h"
#import "NSArray+HOF.h"
#import "NSArray+HOFC.h"
#import "MessageViewController.h"
#import "PopUpView.h"
#import "DietMasterGoViewController.h"


//#import "RSDFDatePickerView.h"

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

#import <HealthKit/HealthKit.h>
@interface MyMovesViewController ()<FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance,WSWorkoutList,WSCategoryList,WSGetUserWorkoutplanOffline,UITextViewDelegate,UITableViewDelegate,UITableViewDataSource,loadDataToMovesTbl,GotoViewControllerDelegate>
{
    CGFloat animatedDistance;
    MyMovesWebServices *soapWebService;
    int userId;
    bool isLoading;
}
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDateFormatter *monthFormat;

@property (strong, nonatomic) NSMutableArray<NSString *> *datesWithInfo;
@property (strong, nonatomic) NSMutableArray *datesExerciseCompletd;
@property (strong, nonatomic) NSArray *DatesWithEvents;
@property (strong, nonatomic) NSMutableArray *exerciseData;
@property (strong, nonatomic) NSMutableArray *userPlanListData;
@property (strong, nonatomic) NSMutableArray *userPlanDateListData;
@property (strong, nonatomic) NSMutableArray *userPlanMoveListData;
@property (strong, nonatomic) NSMutableArray *userPlanMoveSetListData;
@property (strong, nonatomic) NSMutableArray *loadMoveDetails;
@property (strong, nonatomic) NSMutableArray *deletedPlanArr;
@property (strong, nonatomic) NSMutableArray *deletedPlanDateArr;
@property (strong, nonatomic) NSMutableArray *deletedMoveArr;
@property (strong, nonatomic) NSMutableArray *deletedMoveSetArr;
@property (strong, nonatomic) NSMutableArray *deletedArr;

@property (strong, nonatomic) NSMutableArray *loadMoveName;

@property (strong, nonatomic) NSMutableArray *exerciseDataWithoutDuplicate;
@property (strong, nonatomic) NSMutableArray *listViewItem;
@property (strong, nonatomic) NSMutableArray *tblData;
@property (strong, nonatomic) NSMutableArray *sectionTitleDataMovesTblView;
@property (strong, nonatomic) NSMutableArray *templatesList1;
@property (strong, nonatomic) NSMutableArray *templatesList2;

@property (strong, retain) NSDate *prevDate;
@property (strong, nonatomic) NSMutableArray *sectionCount;
@property (strong, nonatomic) NSMutableArray *sectionTitle;
@property (strong, nonatomic) NSMutableArray *datesTitleArr;
@property (strong, nonatomic) NSMutableArray *fullDBData;
@property (strong, nonatomic) NSMutableArray *fullDateListData;
@property (strong, nonatomic) NSMutableArray *fullPlanListData;
@property (nonatomic, strong) NSString *statusSs;


@end
@implementation MyMovesViewController

@synthesize sd,arrData,healthStore,date_currentDate,calendar,prevDate;
- (void)viewDidLoad {
    [super viewDidLoad];
     
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"changeDesign"]  isEqual: @"NewDesign"])
    {
        self.showPopUpVw.hidden = false;
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"isNewDesign"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        self.showPopUpVw.hidden = true;
    }
    
    [self.navigationController setNavigationBarHidden:NO];

    self.navigationItem.hidesBackButton = YES;

    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"switch"]  isEqual: @"MyMoves"])
    {
        commentsTxtView.hidden = YES;
        _userCommentsLbl.hidden = YES;
        _sendMessageBtn.backgroundColor = PrimaryDarkColor;
        _lineView.backgroundColor = PrimaryDarkColor;
        _sendMessageBtn.layer.cornerRadius = 5.0;
        [_sendMessageBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        
        _dayToggleView.backgroundColor = AccentColor;
        _dayToolBar.barTintColor = AccentColor;
        UIImage *btnImage = [[UIImage imageNamed:@"log_up_arrow.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [expandBtn setImage:btnImage forState:UIControlStateNormal];
        expandBtn.tintColor = AccentColor
        
        _exerciseDataWithoutDuplicate = [[NSMutableArray alloc]init];
        _exerciseData = [[NSMutableArray alloc]init];
        _userPlanListData = [[NSMutableArray alloc]init];
        _userPlanDateListData = [[NSMutableArray alloc]init];
        _userPlanMoveListData = [[NSMutableArray alloc]init];
        _userPlanMoveSetListData = [[NSMutableArray alloc]init];
        _loadMoveDetails = [[NSMutableArray alloc]init];
        _listViewItem = [[NSMutableArray alloc]init];
        _sectionCount = [[NSMutableArray alloc]init];
        _sectionTitle = [[NSMutableArray alloc]init];
        _fullDBData   = [[NSMutableArray alloc]init];
        _loadMoveName = [[NSMutableArray alloc]init];
        _fullDateListData = [[NSMutableArray alloc]init];
        _fullPlanListData = [[NSMutableArray alloc]init];
        _deletedPlanArr = [[NSMutableArray alloc]init];
        _deletedPlanDateArr = [[NSMutableArray alloc]init];
        _deletedMoveArr = [[NSMutableArray alloc]init];
        _deletedMoveSetArr = [[NSMutableArray alloc]init];
        _deletedArr = [[NSMutableArray alloc]init];
        _tblData = [[NSMutableArray alloc]init];
        prevDate = [[NSDate alloc]init];
        prevDataArr = [[NSMutableArray alloc]init];
        
        movesTblView.delegate = self;
        movesTblView.dataSource = self;
        
        listViewMoves.delegate = self;
        listViewMoves.dataSource = self;
        listViewMoves.tableFooterView = nil;
        listViewMoves.sectionFooterHeight = 0;
        
        self.datesExerciseCompletd = [[NSMutableArray alloc]init];
        self.datesWithInfo = [[NSMutableArray alloc]init];
        
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateFormat = @"yyyy/MM/dd";
        
        self.monthFormat = [[[NSDateFormatter alloc] init] retain];
        
        //        calendar = [[[FSCalendar alloc] initWithFrame:CGRectMake(_calendarView.bounds.origin.x, _calendarView.bounds.origin.y, _calendarView.bounds.size.width - 60, _calendarView.bounds.size.height - 50)]retain];
        calendar = [[[FSCalendar alloc] initWithFrame:CGRectMake(_calendarView.bounds.origin.x, _calendarView.bounds.origin.y + 15, SCREEN_WIDTH, _calendarView.bounds.size.height - 50)]retain];
        calendar.dataSource = self;
        calendar.delegate = self;
        calendar.scrollDirection = FSCalendarScrollDirectionVertical;
        calendar.backgroundColor = [UIColor whiteColor];
        calendar.scope = FSCalendarScopeMonth;
        calendar.appearance.subtitlePlaceholderColor = [UIColor darkTextColor];
        calendar.appearance.subtitleDefaultColor = [UIColor yellowColor];
        calendar.appearance.subtitleWeekendColor = [UIColor redColor];
        
        [calendar.calendarHeaderView setHidden:YES];
        calendar.headerHeight = 0;
        [calendar selectDate:[NSDate date]];
        
        [_calendarView addSubview:calendar];
        
        selectedExercisesArr = [[NSMutableArray alloc]init];
        arrData = [NSMutableArray new];
        healthStore = [[HKHealthStore alloc] init];
        sd = [[StepData alloc]init];
        
        //    self.datesWithInfo = @[@"2019/01/04",
        //                            @"2019/01/08",
        //                            @"2019/01/12",
        //                            @"2019/01/25",
        //                            @"2019/01/10",
        //                            @"2019/01/28"];
        //
        //    self.datesExerciseCompletd = @[@"2019/01/05",
        //                              @"2019/01/09",
        //                              @"2019/01/13",
        //                              @"2019/01/26",
        //                              @"2019/01/11",
        //                              @"2019/01/29"];
        
        //set title
        self.navigationItem.title=@"My Moves";
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        
        //set right navigation bar
        UIImage *btnImage1 = [[UIImage imageNamed:@"set32.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn1.bounds = CGRectMake( 0, 0, btnImage1.size.width, btnImage1.size.height );
        btn1.tintColor = [UIColor whiteColor];
        [btn1 addTarget:self action:@selector(showSettings:) forControlEvents:UIControlEventTouchDown];
        [btn1 setImage:btnImage1 forState:UIControlStateNormal];
        
        UIImage *listImg = [[UIImage imageNamed:@"viewlist.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        listCalendarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        listCalendarBtn.bounds = CGRectMake( 0, 0, listImg.size.width, listImg.size.height );
        listCalendarBtn.tintColor = [UIColor whiteColor];
        [listCalendarBtn addTarget:self action:@selector(tabBarAction:) forControlEvents:UIControlEventTouchDown];
        [listCalendarBtn setImage:listImg forState:UIControlStateNormal];
        listCalendarBtn.tag = 0;
        
        listCalendarBarBtn = [[UIBarButtonItem alloc] initWithCustomView:listCalendarBtn];
        
        UIImage *calendarViewImg = [[UIImage imageNamed:@"calendarview.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        calendarViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        calendarViewBtn.bounds = CGRectMake( 0, 0, calendarViewImg.size.width, calendarViewImg.size.height );
        calendarViewBtn.tintColor = [UIColor whiteColor];
        [calendarViewBtn addTarget:self action:@selector(tabBarAction:) forControlEvents:UIControlEventTouchDown];
        [calendarViewBtn setImage:calendarViewImg forState:UIControlStateNormal];
        calendarViewBtn.tag = 1;
        
        CalendarBarBtn = [[UIBarButtonItem alloc] initWithCustomView:calendarViewBtn];
        
        [self tabBarAction:calendarViewBtn];
        self.navigationItem.leftBarButtonItems = [[NSArray alloc]initWithObjects:listCalendarBarBtn,nil];
        
        UIBarButtonItem * settingsBtn = [[UIBarButtonItem alloc] initWithCustomView:btn1];
        DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
        dietmasterEngine.taskMode = @"View";
        self.navigationItem.rightBarButtonItem = settingsBtn;
        
        //set date in current date variable
        NSDate* sourceDate = [NSDate date];
        NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
        [dateFormat setTimeZone:systemTimeZone];
        
        self.date_currentDate = sourceDate;
        
        // call functin to set date label
        [self setDateLbl:sourceDate];

        
        //set textView border color
        commentsTxtView.layer.borderColor = [UIColor grayColor].CGColor;
        commentsTxtView.layer.borderWidth = 1.0;
        commentsTxtView.layer.cornerRadius = 5.0;
        
        soapWebService = [[MyMovesWebServices alloc] init];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            userId = [[prefs valueForKey:@"userid_dietmastergo"] integerValue];
        
        if IS_IPHONE_X_XR_XS
        {
            if ([_workoutClickedFromHome isEqual: @"clicked"])
            {
                [self.calendarView setHidden:YES];
                self.proportionalHeightCalConst.constant = 0;
            }
            else
            {
                self.proportionalHeightCalConst.constant = self.view.frame.size.height /4;
                [self.calendarView setHidden:NO];
            }
        }
        else
        {
            if ([_workoutClickedFromHome isEqual: @"clicked"])
            {
                [self.calendarView setHidden:YES];
                self.proportionalHeightCalConst.constant = 0;
            }
            else
            {
                self.proportionalHeightCalConst.constant = self.view.frame.size.height /3;
                [self.calendarView setHidden:NO];
            }
        }
    }
    else
    {
        AppSettings*appSettings = [[AppSettings alloc] initWithNibName: @"AppSettings" bundle: nil];
        appSettings.title = @"Settings";
        self.navigationItem.title = @"Settings";
        [self.navigationController setViewControllers:@[appSettings] animated:NO];
        [appSettings release];
        [soapWebService offlineSyncApi];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    DietmasterEngine *engine = [DietmasterEngine instance];
    commentsTxtView.hidden = YES;
    _userCommentsLbl.hidden = YES;

    if IS_IPHONE_X_XR_XS
    {
        if ([_workoutClickedFromHome isEqual: @"clicked"])
        {
            [self.calendarView setHidden:YES];
            self.proportionalHeightCalConst.constant = 0;
        }
        else
        {
            self.proportionalHeightCalConst.constant = self.view.frame.size.height /4;
            [self.calendarView setHidden:NO];
        }
    }
    else
    {
        if ([_workoutClickedFromHome isEqual: @"clicked"])
        {
            [self.calendarView setHidden:YES];
            self.proportionalHeightCalConst.constant = 0;
        }
        else
        {
            self.proportionalHeightCalConst.constant = self.view.frame.size.height /3;
            [self.calendarView setHidden:NO];
        }
    }

    
    if (Reachability.reachabilityForInternetConnection) {
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"No Internet Connection"
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        [alert show];
    }
    
    soapWebService = [[MyMovesWebServices alloc] init];

//    [self loadCalendarOnMonthChange:self.date_currentDate];
    
//    [self loadCircleInCalendar:_exerciseData];

    
    
    if (engine.sendAllServerData == true)
    {
        soapWebService.WSGetUserWorkoutplanOfflineDelegate = self;
    }
    [soapWebService offlineSyncApi];
    [self loadTableData:self.date_currentDate];

}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.isMovingFromParentViewController) {
        [[self navigationController] setNavigationBarHidden:YES animated:YES];
    }
}


-(void)loadEventCalendar:(NSMutableArray*)datesArr
{
//    while(isLoading) {
//        NSLog(@"Oh shit i think i broke it...");
//    }
    prevDataArr = [[NSMutableArray alloc]initWithArray:datesArr];
    
    self.datesExerciseCompletd = [[NSMutableArray alloc]init];
    self.datesWithInfo = [[NSMutableArray alloc]init];
    
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    NSBlockOperation *blockCompletionOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"The block operation ended, Do something such as show a successmessage etc");
        //This the completion block operation
    }];
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        //This is the worker block operation
        isLoading = YES;
        for (int i = 0 ;i < datesArr.count;i++)
        {
            NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]retain];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
            
            NSDateFormatter *myFormat = [[NSDateFormatter alloc] init];
            [myFormat setDateFormat:@"yyyy-mm-dd hh:mm:ss Z"];
            
            if ([datesArr[i][@"PlanDate"] containsString:@"T"])
            {
                NSArray *planDateArr = [datesArr[i][@"PlanDate"] componentsSeparatedByString:@"T"];
                NSString *dateString = [NSString stringWithFormat:@"%@T00:00:00",[planDateArr objectAtIndex:0]];
                NSDate *dateFormate = [[dateFormatter dateFromString:dateString] retain];
                [dateFormatter setDateFormat:@"yyyy/MM/dd"];
                [self.datesWithInfo addObject:[dateFormatter stringFromDate:dateFormate]];
            }
            else
            {
                NSArray *planDateArr = [datesArr[i][@"PlanDate"] componentsSeparatedByString:@" "];
                NSString *dateString = [NSString stringWithFormat:@"%@T00:00:00",[planDateArr objectAtIndex:0]];

                NSDate *dateFormate = [[dateFormatter dateFromString:dateString] retain];
                [myFormat setDateFormat:@"yyyy/MM/dd"];
                [self.datesWithInfo addObject:[myFormat stringFromDate:dateFormate]];
            }
        }

        [self.datesExerciseCompletd addObjectsFromArray:datesArr];
        isLoading = NO;
        sleep(2);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.calendar reloadData];
            [self hideLoading];
        });
        
    }];
    [blockCompletionOperation addDependency:blockOperation];
    [operationQueue addOperation:blockCompletionOperation];
    [operationQueue addOperation:blockOperation];
}
- (IBAction)tabBarAction:(UIButton*)sender {
    [self setMonthLbl:self.date_currentDate];
    
    if (self.proportionalHeightCalConst.constant == 0) {
        [self expandButtonAction:expandBtn];
    }
    
    if(sender.tag == 0)
    {
        [listView setHidden:NO];
        [self loadListTable];
        self.navigationItem.leftBarButtonItems = [[NSArray alloc]initWithObjects:CalendarBarBtn,nil];
        _sendMsgStackVw.hidden = YES;
    }
    else
    {
        self.navigationItem.leftBarButtonItems = [[NSArray alloc]initWithObjects:listCalendarBarBtn,nil];
        [listView setHidden:YES];
        _sendMsgStackVw.hidden = NO;
    }
}

-(void)loadListTable
{
    [_sectionCount removeAllObjects];
    [_sectionTitle removeAllObjects];
    currentSection = 1200;
    
    _fullDBData         = [soapWebService loadUserPlanListFromDb];
    _fullPlanListData   = [soapWebService loadUserPlanListFromDb];
    _fullDateListData   = [soapWebService loadUserPlanDateListFromDb];

    NSMutableArray *arrayWithCustomDateTitle = [[NSMutableArray alloc]init];
    NSMutableArray *arrayWithSameDate = [[NSMutableArray alloc]init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    
    NSString *filter = @"%K CONTAINS %@";
    NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:filter,@"LastUpdated",[dateFormatter stringFromDate:self.date_currentDate]];
//    _exerciseData = [[soapWebService loadExerciseFromDb] filteredArrayUsingPredicate:categoryPredicate];
    
    NSString *dateOneStr = @"-01";
    NSString *monthYearStr = [dateFormatter stringFromDate:self.date_currentDate];
    NSString *dateStr = [monthYearStr stringByAppendingString:dateOneStr];
    NSString *generatedDate = [dateStr stringByAppendingString:@"T00:00:00"];

    // Convert string to date object
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate *dateOfFirstDayMonth = [dateFormat dateFromString:generatedDate];
    
    _listViewItem = [[NSMutableArray alloc]init];
    
    if ([[dateFormatter stringFromDate:calendar.selectedDate]isEqualToString:[dateFormatter stringFromDate:self.date_currentDate]]) {
        _exerciseDataWithoutDuplicate = [[NSMutableArray alloc]init];

    }
    else
    {
    }
    
    for (int i = 0; i <=31; i++) {
        NSDateComponents *components = [[NSDateComponents alloc] init];
        NSCalendar *cal = [NSCalendar currentCalendar];
        [components setDay:i];
        NSDate *date_Tomorrow = [cal dateByAddingComponents:components toDate:dateOfFirstDayMonth options:0];
        
        NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
        [monthFormatter setDateFormat:@"yyyy-MM"];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
        NSString *dateString = [formatter stringFromDate:date_Tomorrow];
        
        NSArray *arr1 = [dateString componentsSeparatedByString:@"T"];
        dateString = [NSString stringWithFormat:@"%@T00:00:00",[arr1 objectAtIndex:0]];
        
        NSDate * dat = [[NSDate alloc]init];
        dat = [formatter dateFromString:dateString];
        
        //            if ([[monthFormatter stringFromDate:self.date_currentDate]isEqualToString:[monthFormatter stringFromDate:dat]]) {
        
        NSMutableArray * arr = [[NSMutableArray alloc]init];

        if ([[dateFormatter stringFromDate:calendar.selectedDate]isEqualToString:[dateFormatter stringFromDate:self.date_currentDate]]) {
            
//            if (_fullDateListData.count != 0){
//                arr = [[NSMutableArray alloc]initWithArray:[_fullDBData filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(PlanDate contains[c] %@)", dateString]]];
//            }
//
//            NSMutableArray *rowListArr = [[NSMutableArray alloc] init];
//            for (int j=0; j<[_userPlanListData count]; j++)
//            {
//                NSPredicate *categoryPredicates = [NSPredicate predicateWithFormat:filter,@"ParentUniqueID",_fullPlanListData[j][@"UniqueID"]];
//                NSArray * tempArrs = [[NSArray alloc]initWithArray:[_userPlanDateListData filteredArrayUsingPredicate:categoryPredicates]];
//                [rowListArr addObjectsFromArray:tempArrs];
//            }
            
//            if ([_fullDBData count] == 0) {
//                arr = [[NSMutableArray alloc]initWithArray:[_fullDBData filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(LastUpdated contains[c] %@)", dateString]]];
//            }
//            else
//            {
//                arr = [[NSMutableArray alloc]initWithArray:[_fullDBData filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(LastUpdated contains[c] %@)", dateString]]];
//            }
            
            
            
            
            _templatesList1 = [[NSMutableArray alloc]init];
            _templatesList2 = [[NSMutableArray alloc]init];
            for (int i =0 ; i<[_userPlanListData count]; i++) {
                [_templatesList1 addObject:_userPlanListData[i][@"PlanName"]];
            }
            
            for (int i =0 ; i<[_templatesList1 count]; i++) {
                if ([_templatesList2 containsObject:(_templatesList1[i])]) {
                    
                }
                else
                {
                    [_templatesList2 addObject:_templatesList1[i]];
                    [_exerciseDataWithoutDuplicate addObject:_userPlanListData[i]];
                }
            }
            
            NSLog(@"%@",_exerciseDataWithoutDuplicate);
            
        }
        else
        {
            
        }
        
        if ([[monthFormatter stringFromDate:self.date_currentDate]isEqualToString:[monthFormatter stringFromDate:date_Tomorrow]]) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSDateFormatter *customFormatter = [[NSDateFormatter alloc] init];

//            [dateFormatter setDateFormat:@"dd MMMM yyyy"];
            [dateFormatter setDateFormat:@"EEEE, d LLLL yyyy"];
            [customFormatter setDateFormat:@"EEEE, d LLLL"];

            [arrayWithCustomDateTitle addObject:[customFormatter stringFromDate:date_Tomorrow]];
            [arrayWithSameDate addObject:[dateFormatter stringFromDate:date_Tomorrow]];
            [_sectionCount addObject:[dateFormatter stringFromDate:date_Tomorrow]];
            
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
            
            NSString *filter = @"%K == %@";
            NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:filter,@"PlanDate",[dateFormatter stringFromDate:date_Tomorrow]];
//
            NSMutableArray *listArr = [[NSMutableArray alloc]initWithArray:[_userPlanDateListData filteredArrayUsingPredicate:categoryPredicate]];
            
            
            
            [_listViewItem addObjectsFromArray:listArr];
          
//            }
        }
        else
        {

        }
    }
    [self loadRowDataDateArr:_sectionTitle];
    /*
    for(NSDictionary *dictionary in _exerciseData)
    {
        NSString *dateStr = [dictionary objectForKey:@"WorkoutDate"];;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        NSDate *date = [dateFormatter dateFromString:dateStr];
        [dateFormatter setDateFormat:@"dd MMMM yyyy"];
        
        [arrayWithSameDate addObject: [dateFormatter stringFromDate:date] ];
        [_sectionCount addObject:dateStr];
    }
    
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:arrayWithSameDate];
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:nil ascending:NO];
    _sectionTitle = [[[orderedSet array] sortedArrayUsingDescriptors:@[sd]] mutableCopy];

    _sectionTitle = [[[orderedSet array] sortedArrayUsingDescriptors:@[sd]] mutableCopy];

    NSOrderedSet *orderedSetSection = [NSOrderedSet orderedSetWithArray:_sectionCount];
    _sectionCount = [[[orderedSetSection array] sortedArrayUsingDescriptors:@[sd]] mutableCopy];
    _sectionCount = [[orderedSet array] mutableCopy];
     */
    _datesTitleArr = [[NSMutableArray alloc]initWithArray:arrayWithCustomDateTitle];
    _sectionTitle = [[NSMutableArray alloc]initWithArray:arrayWithSameDate];
    _sectionCount = [[NSMutableArray alloc]initWithArray:arrayWithSameDate];
    
    [listViewMoves reloadData];
}
-(void)loadCircleInCalendar:(NSMutableArray*)datesArr
{

        prevDataArr = [[NSMutableArray alloc]initWithArray:datesArr];
        
    
        self.datesExerciseCompletd = [[NSMutableArray alloc]init];
        self.datesWithInfo = [[NSMutableArray alloc]init];
        
        NSOperationQueue *operationQueue = [NSOperationQueue new];
        NSBlockOperation *blockCompletionOperation = [NSBlockOperation blockOperationWithBlock:^{
            NSLog(@"The block operation ended, Do something such as show a successmessage etc");
            //This the completion block operation
        }];
        NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
            //This is the worker block operation
            
            for (int i = 0 ;i < datesArr.count;i++)
            {
                NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]retain];
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
                NSArray *arr = [datesArr[i][@"WorkoutDate"] componentsSeparatedByString:@"T"];
                NSString *dateString = [NSString stringWithFormat:@"%@T00:00:00",[arr objectAtIndex:0]];
                NSDate *date = [[dateFormatter dateFromString:dateString] retain];
                [dateFormatter setDateFormat:@"yyyy/MM/dd"];
                [self.datesWithInfo addObject:[dateFormatter stringFromDate:date]];
            }
            
            NSString * completedExerciseStr = @"true";
            
            NSPredicate *completedExercisePredicate = [NSPredicate predicateWithFormat:@"SELF.WorkingStatus IN %@", completedExerciseStr];
            
            NSMutableArray *completedExerciseArr = [[NSMutableArray alloc]initWithArray:[datesArr filteredArrayUsingPredicate:completedExercisePredicate]];
            
            NSMutableArray *completedExerciseArrDates = [[NSMutableArray alloc]init];
            
            for (int i = 0 ;i < completedExerciseArr.count;i++)
            {
                NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]retain];
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
                NSArray *arr = [completedExerciseArr[i][@"WorkoutDate"] componentsSeparatedByString:@"T"];
                NSString *dateString = [NSString stringWithFormat:@"%@T00:00:00",[arr objectAtIndex:0]];                NSDate *date = [[dateFormatter dateFromString:dateString]retain];
                [dateFormatter setDateFormat:@"yyyy/MM/dd"];
                [completedExerciseArrDates addObject:[dateFormatter stringFromDate:date]];
            }
            
            NSString * str = @"false";
            
            NSPredicate *incompletedExercisePredicate = [NSPredicate predicateWithFormat:@"SELF.WorkingStatus IN %@", str];
            
            NSMutableArray *incompletedExerciseArr = [[NSMutableArray alloc]initWithArray:[datesArr filteredArrayUsingPredicate:incompletedExercisePredicate]];
            
            NSMutableArray *incompletedExerciseArrDates = [[NSMutableArray alloc]init];
            
            for (int i = 0 ;i < incompletedExerciseArr.count;i++)
            {
                NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]retain];
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
                NSArray *arr = [incompletedExerciseArr[i][@"WorkoutDate"] componentsSeparatedByString:@"T"];
                NSString *dateString = [NSString stringWithFormat:@"%@T00:00:00",[arr objectAtIndex:0]];
                NSDate *date = [[dateFormatter dateFromString:dateString]retain];
                [dateFormatter setDateFormat:@"yyyy/MM/dd"];
                [incompletedExerciseArrDates addObject:[dateFormatter stringFromDate:date]];
            }
            
            if (incompletedExerciseArr != nil && ([incompletedExerciseArr count] != 0))
            {
                NSMutableSet* firstArraySet = [[[NSMutableSet alloc] initWithArray:completedExerciseArrDates]mutableCopy];
                NSMutableSet* secondArraySet = [[[NSMutableSet alloc] initWithArray:incompletedExerciseArrDates]mutableCopy];
                
                [firstArraySet minusSet: secondArraySet];
                
                NSArray *array = [[firstArraySet allObjects] retain];
                
                [self.datesExerciseCompletd addObjectsFromArray:array];
            }
            else
            {
                NSMutableSet* firstArraySet = [[NSMutableSet alloc] initWithArray:completedExerciseArrDates];
                [firstArraySet unionSet:firstArraySet];
                
                NSArray *array = [firstArraySet allObjects];
                self.datesExerciseCompletd = [[NSMutableArray alloc]initWithArray:array];
            }
            
            NSMutableSet* removeDuplicateSet = [[NSMutableSet alloc] initWithArray:self.datesExerciseCompletd];
            
            self.datesExerciseCompletd = [[NSMutableArray alloc]initWithArray:[removeDuplicateSet allObjects]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.calendar reloadData];
                [self hideLoading];
            });
            
        }];
        [blockCompletionOperation addDependency:blockOperation];
        [operationQueue addOperation:blockCompletionOperation];
        [operationQueue addOperation:blockOperation];
        

    
}
-(void)showLoading {
    [HUD hide:YES afterDelay:0.0];
    HUD = [[MBProgressHUD showHUDAddedTo:self.view animated:YES] retain];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 6.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^ {
//        [self showLoading1];
    });
}

-(void)showLoading1 {
    [HUD hide:YES afterDelay:0.0];
    HUD = [[MBProgressHUD showHUDAddedTo:self.view animated:YES] retain];
}
-(void)hideLoading {
    [HUD hide:YES afterDelay:0.5];
}
-(void)setMonthLbl:(NSDate*)dateToSet
{
    NSDateFormatter *setDisplayCalendarMonth = [[[NSDateFormatter alloc] init] autorelease];

    [setDisplayCalendarMonth setDateFormat:@"MMMM YYYY"];
    listCurrentMonthLbl.text = [setDisplayCalendarMonth stringFromDate:dateToSet];
}

-(void)setDateLbl:(NSDate*)dateToSet
{
    NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
    [dateFormat setTimeZone:systemTimeZone];
    
    // set date label
    NSDateFormatter *dateFormat_display = [[NSDateFormatter alloc] init];
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"isddmm"] boolValue]) {
        [dateFormat_display setDateFormat:@"MMMM d, yyyy"];
        [dateFormat_display setTimeZone:systemTimeZone];
    }
    else{
        [dateFormat_display setDateFormat:@"d MMMM, yyyy"];
        [dateFormat_display setTimeZone:systemTimeZone];
    }
    
    NSString *date_Display        = [dateFormat_display stringFromDate:dateToSet];

    lblDateHeader.text = date_Display;
    
  
    //Load Calendar Data
//    [self loadCalendarOnMonthChange:dateToSet];
    
    //api call to load table data
    [self loadTableData:dateToSet];

    NSDateFormatter *setDisplayCalendarMonth = [[[NSDateFormatter alloc] init] autorelease];
    [setDisplayCalendarMonth setDateFormat:@"MMMM"];

    _displayedMonthLbl.text = [setDisplayCalendarMonth stringFromDate:dateToSet];
    
}
//new API
-(void)loadCalendarOnMonthChange:(NSDate*)dateToSet
{
    NSDateFormatter *setDisplayCalendarMonth = [[[NSDateFormatter alloc] init] autorelease];
    [setDisplayCalendarMonth setDateFormat:@"MMMM"];
    
    _displayedMonthLbl.text = [setDisplayCalendarMonth stringFromDate:dateToSet];
    
    [_monthFormat setDateFormat:@"MM"];
    
    //Month change api call & check
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    
    NSString *filter = @"%K CONTAINS %@";
    NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:filter,@"LastUpdated",[dateFormatter stringFromDate:dateToSet]];
    NSMutableArray * tempExDb = [[NSMutableArray alloc]init];
    tempExDb = [soapWebService loadUserPlanListFromDb];
    tempExDb = [soapWebService loadUserPlanDateListFromDb];
//    [self showLoading];
   
//    if ([[tempExDb filteredArrayUsingPredicate:categoryPredicate] count] == 0) {
//        //API Call
//        MyMovesWebServices *soapWebService = [[MyMovesWebServices alloc] init];
//        soapWebService.WSGetUserWorkoutplanOfflineDelegate = self;
////        [soapWebService offlineSyncApi];
//
//        [self performSelector:@selector(hideLoading) withObject:nil afterDelay:10.0];
//    }
//    else
//    {
    _exerciseData = [[tempExDb filteredArrayUsingPredicate:categoryPredicate]retain];
    
    if ([[self.dateFormatter stringFromDate:[NSDate date]] isEqualToString:[self.dateFormatter stringFromDate:self.date_currentDate]]) {
//        [self loadTableData:dateToSet];
    }
    
    if (self.date_currentDate == calendar.currentPage) {
//        [self loadTableData:dateToSet];
    }
    else
    {
//        [self loadTableData:dateToSet];
    }
    [self performSelector:@selector(hideLoading) withObject:nil afterDelay:10.0];
//    }
    
    /*
    [soapWebService offlineSyncApi];
    
    if(prevDate != nil)
    {
        if (([[_monthFormat stringFromDate:prevDate] compare:[_monthFormat stringFromDate:dateToSet]] == NSOrderedSame) && dateToSet != nil)
        {
            
        }
        else
        {   //New Month changed
            prevDate = dateToSet;
            
            NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
            [dateFormat setDateFormat:@"yyyy-MM-dd"];
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            
            //        NSDictionary *wsWorkInfoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
            //                                        [prefs valueForKey:@"userid_dietmastergo"], @"UserID",[dateFormat stringFromDate:dateToSet], @"WorkoutDate",nil];
            
            NSDictionary *wsWorkInfoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                            @"10", @"UserID",[dateFormat stringFromDate:dateToSet], @"WorkoutDate",nil];
            
            MyMovesWebServices *soapWebService = [[MyMovesWebServices alloc] init];
            soapWebService.WSGetUserWorkoutplanOfflineDelegate = self;
            [soapWebService GetUserWorkoutplanOffline:wsWorkInfoDict];
            
            [soapWebService release];
        }
    }*/
    
}

/*
-(void)loadCalendarOnMonthChange:(NSDate*)dateToSet
{
    NSDateFormatter *setDisplayCalendarMonth = [[[NSDateFormatter alloc] init] autorelease];
    [setDisplayCalendarMonth setDateFormat:@"MMMM"];
    
    _displayedMonthLbl.text = [setDisplayCalendarMonth stringFromDate:dateToSet];
    
    [_monthFormat setDateFormat:@"MM"];
    
    //Month change api call & check
   
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    
   /* NSString *filter = @"%K CONTAINS %@";
    NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:filter,@"WorkoutDate",[dateFormatter stringFromDate:dateToSet]];
    NSMutableArray * tempExDb = [[NSMutableArray alloc]init];
    tempExDb = [soapWebService loadExerciseFromDb];
    [self showLoading];
    if ([[tempExDb filteredArrayUsingPredicate:categoryPredicate] count] == 0) {

        NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
                NSDictionary *wsWorkInfoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                [prefs valueForKey:@"userid_dietmastergo"], @"UserID",[dateFormat stringFromDate:dateToSet], @"WorkoutDate",nil];
        */

//        MyMovesWebServices *soapWebService = [[MyMovesWebServices alloc] init];
//        soapWebService.WSGetUserWorkoutplanOfflineDelegate = self;
//        [soapWebService offlineSyncApi];
//
//        [self performSelector:@selector(hideLoading) withObject:nil afterDelay:10.0];
    /*
//        [_tblData removeAllObjects];
    }
    else
    {
//        [_tblData removeAllObjects];

        _exerciseData = [[tempExDb filteredArrayUsingPredicate:categoryPredicate]retain];
        
//        _fullDBData = [soapWebService loadExerciseFromDb];

//        [self loadCircleInCalendar:_exerciseData];
        
        if ([[self.dateFormatter stringFromDate:[NSDate date]] isEqualToString:[self.dateFormatter stringFromDate:self.date_currentDate]]) {
            [self loadTableData:dateToSet];
        }
        
        if (self.date_currentDate == calendar.currentPage) {
            [self loadTableData:dateToSet];
        }
        else
        {
            [self loadTableData:dateToSet];
        }
    }
//    [self loadListTable];
    
//    if ([[_monthFormat stringFromDate:prevDate] isEqualToString:[_monthFormat stringFromDate:dateToSet]])
    
    /*
    [soapWebService offlineSyncApi];

    if(prevDate != nil)
    {
    if (([[_monthFormat stringFromDate:prevDate] compare:[_monthFormat stringFromDate:dateToSet]] == NSOrderedSame) && dateToSet != nil)
    {
        
    }
    else
    {   //New Month changed
        prevDate = dateToSet;
        
        NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
//        NSDictionary *wsWorkInfoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
//                                        [prefs valueForKey:@"userid_dietmastergo"], @"UserID",[dateFormat stringFromDate:dateToSet], @"WorkoutDate",nil];

        NSDictionary *wsWorkInfoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        @"10", @"UserID",[dateFormat stringFromDate:dateToSet], @"WorkoutDate",nil];
        
        MyMovesWebServices *soapWebService = [[MyMovesWebServices alloc] init];
        soapWebService.WSGetUserWorkoutplanOfflineDelegate = self;
        [soapWebService GetUserWorkoutplanOffline:wsWorkInfoDict];
        
        [soapWebService release];
    }
    }

}
*/


-(void)loadTableData:(NSDate*)dateToSet
{
    [_userCommentsLbl setHidden:YES];

    _userPlanListData        = [[[NSMutableArray alloc]initWithArray:[soapWebService loadUserPlanListFromDb]] retain];
    _userPlanDateListData    = [[[NSMutableArray alloc]initWithArray:[soapWebService loadUserPlanDateListFromDb]] retain];
    _userPlanMoveListData    = [[[NSMutableArray alloc]initWithArray:[soapWebService loadUserPlanMoveListFromDb]] retain];
    _userPlanMoveSetListData = [[[NSMutableArray alloc]initWithArray:[soapWebService loadUserPlanMoveSetListFromDb]] retain];
    
    _loadMoveDetails         = [[[NSMutableArray alloc]initWithArray:[soapWebService loadListOfMovesFromDb]] retain];
   
    _deletedPlanArr     = [[[NSMutableArray alloc]initWithArray:[soapWebService MobileUserPlanList]] retain];
    _deletedPlanDateArr = [[[NSMutableArray alloc]initWithArray:[soapWebService MobileUserPlanDateList]] retain];
    _deletedMoveArr     = [[[NSMutableArray alloc]initWithArray:[soapWebService MobileUserPlanMoveList]] retain];
    _deletedMoveSetArr  = [[[NSMutableArray alloc]initWithArray:[soapWebService MobileUserPlanMoveSetList]] retain];


    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
    NSString *dateString = [formatter stringFromDate:dateToSet];

    NSArray *arr = [dateString componentsSeparatedByString:@"T"];
    dateString = [NSString stringWithFormat:@"%@T00:00:00",[arr objectAtIndex:0]];
    
    if ([_userPlanDateListData count] != 0)
    {
        _tblData = [[NSMutableArray alloc]initWithArray:[_userPlanDateListData filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(PlanDate contains[c] %@)", dateString]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [movesTblView reloadData];
        });
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
                        [soapWebService clearedDataFromWeb:deletedUniqID];
                    }
                    [soapWebService clearedDataFromWeb:deletedUniqID];
                }
                [soapWebService clearedDataFromWeb:deletedUniqID];
            }
            [soapWebService clearedDataFromWeb:deletedUniqID];
            [self loadSectionsForMovesTbl];
        }
    }
    [self loadEventCalendar:[soapWebService loadUserPlanDateListFromDb]];

    if ([_deletedPlanDateArr count] != 0)
    {
        for (int l=0; l<_deletedPlanDateArr.count; l++)
        {
            NSString *deletedUniqID = _deletedPlanDateArr[l][@"UniqueID"];
            [soapWebService clearedDataFromWeb:deletedUniqID];
        }
        [self loadSectionsForMovesTbl];
    }
    if ([_deletedMoveArr count] != 0)
    {
        for (int l=0; l<_deletedMoveArr.count; l++)
        {
            NSString *deletedUniqID = _deletedMoveArr[l][@"UniqueID"];
            [soapWebService clearedDataFromWeb:deletedUniqID];
        }
        [self loadSectionsForMovesTbl];
    }
    if ([_deletedMoveSetArr count] != 0)
    {
        for (int l=0; l<_deletedMoveSetArr.count; l++)
        {
            NSString *deletedUniqID = _deletedMoveSetArr[l][@"UniqueID"];
            [soapWebService clearedDataFromWeb:deletedUniqID];
        }
        [self loadSectionsForMovesTbl];
    }
}


-(IBAction)showSettings:(id)sender {
    
    AppSettings *appVC = [[AppSettings alloc]initWithNibName:@"AppSettings" bundle:nil];
    appVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:appVC animated:YES];

}
-(void)apiCallOnMonthChangeFromList
{
    NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    NSDictionary *wsWorkInfoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [prefs valueForKey:@"userid_dietmastergo"], @"UserID",[dateFormat stringFromDate:self.date_currentDate], @"WorkoutDate",nil];
    
    MyMovesWebServices *soapWebService = [[MyMovesWebServices alloc] init];
    soapWebService.WSGetUserWorkoutplanOfflineDelegate = self;
    [soapWebService GetUserWorkoutplanOffline:wsWorkInfoDict];
    
}
- (IBAction)previousMonthAction:(id)sender {
    
//        [self showLoading];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        NSCalendar *cal = [NSCalendar currentCalendar];
        [components setMonth:-1];
        NSDate *date_Yesterday = [cal dateByAddingComponents:components toDate:self.date_currentDate options:0];
        
        self.date_currentDate = date_Yesterday;
        [self setMonthLbl:date_Yesterday];
        
        [calendar selectDate:date_Yesterday];
        
        //HHT temp (IMP line)
        DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
        dietmasterEngine.dateSelected = date_Yesterday;
        
        HKAuthorizationStatus permissionStatus = [self.healthStore authorizationStatusForType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]];
        
        if (permissionStatus == HKAuthorizationStatusSharingAuthorized) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"LoggedAppleWatchTracking"] == YES){
                //    [self readData];
            }
            else {
                NSLog(@"** Auto update apple watch sync is off **");
            }
        }
        else if (permissionStatus == HKAuthorizationStatusSharingDenied) {
            NSLog(@"** HKHealthStore HKAuthorizationStatusSharingDenied **");
        }
        
        //HHT temp change
        //    [self performSelector:@selector(updateData:) withObject:date_Yesterday afterDelay:0.25];
        [components release];

    [self loadCalendarOnMonthChange:self.date_currentDate];
    [self loadTableData:self.date_currentDate];
//    [self setDateLbl:self.date_currentDate];
    [self tabBarAction:listCalendarBtn];
    
//    [self loadCalendarOnMonthChange:self.date_currentDate];
//    [self apiCallOnMonthChangeFromList];
}
- (IBAction)nextMonthAction:(id)sender {
    
//        [self showLoading];

        NSDateComponents *components = [[NSDateComponents alloc] init];
        NSCalendar *cal = [NSCalendar currentCalendar];
        [components setMonth:+1];
        NSDate *date_Tomorrow = [cal dateByAddingComponents:components toDate:self.date_currentDate options:0];
        
        self.date_currentDate = date_Tomorrow;
        
        [self setMonthLbl:date_Tomorrow];
        [calendar selectDate:date_Tomorrow];
        
        //HHT temp (IMP line)
        DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
        dietmasterEngine.dateSelected = date_Tomorrow;
        
        HKAuthorizationStatus permissionStatus = [self.healthStore authorizationStatusForType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]];
        
        if (permissionStatus == HKAuthorizationStatusSharingAuthorized) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"LoggedAppleWatchTracking"] == YES){
                //    [self readData];
            }
            else {
                NSLog(@"** Auto update apple watch sync is off **");
            }
        }
        else if (permissionStatus == HKAuthorizationStatusSharingDenied) {
            NSLog(@"** HKHealthStore HKAuthorizationStatusSharingDenied **");
        }
        
        //    [self performSelectorOnMainThread:@selector(showLoading) withObject:nil waitUntilDone:NO];
        
        //HHT temp change
        //    [self performSelector:@selector(updateData:) withObject:date_Tomorrow afterDelay:0.25];
        [components release];

//    [self loadCalendarOnMonthChange:self.date_currentDate];
//    [self loadTableData:self.date_currentDate];
//    [self setDateLbl:self.date_currentDate];
    [self tabBarAction:listCalendarBtn];

//    [self loadListTable];
//    [self loadCalendarOnMonthChange:self.date_currentDate];
//    [self apiCallOnMonthChangeFromList];
}

-(IBAction)shownextDate:(id)sender {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    NSCalendar *cal = [NSCalendar currentCalendar];
    [components setDay:+1];
    NSDate *date_Tomorrow = [cal dateByAddingComponents:components toDate:self.date_currentDate options:0];
    
    self.date_currentDate = date_Tomorrow;
    
    [self setDateLbl:date_Tomorrow];
    [calendar selectDate:date_Tomorrow];

    //HHT temp (IMP line)
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    dietmasterEngine.dateSelected = date_Tomorrow;
    
    HKAuthorizationStatus permissionStatus = [self.healthStore authorizationStatusForType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]];
    
    if (permissionStatus == HKAuthorizationStatusSharingAuthorized) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"LoggedAppleWatchTracking"] == YES){
        //    [self readData];
        }
        else {
            NSLog(@"** Auto update apple watch sync is off **");
        }
    }
    else if (permissionStatus == HKAuthorizationStatusSharingDenied) {
        NSLog(@"** HKHealthStore HKAuthorizationStatusSharingDenied **");
    }
    
//    [self performSelectorOnMainThread:@selector(showLoading) withObject:nil waitUntilDone:NO];
    
    //HHT temp change
//    [self performSelector:@selector(updateData:) withObject:date_Tomorrow afterDelay:0.25];
    [components release];
}


-(IBAction)showprevDate:(id)sender {
//    [self performSelectorOnMainThread:@selector(showLoading) withObject:nil waitUntilDone:NO];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    NSCalendar *cal = [NSCalendar currentCalendar];
    [components setDay:-1];
    NSDate *date_Yesterday = [cal dateByAddingComponents:components toDate:self.date_currentDate options:0];
    
    self.date_currentDate = date_Yesterday;
    [self setDateLbl:date_Yesterday];

    [calendar selectDate:date_Yesterday];

    //HHT temp (IMP line)
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    dietmasterEngine.dateSelected = date_Yesterday;
    
    HKAuthorizationStatus permissionStatus = [self.healthStore authorizationStatusForType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]];
    
    if (permissionStatus == HKAuthorizationStatusSharingAuthorized) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"LoggedAppleWatchTracking"] == YES){
        //    [self readData];
        }
        else {
            NSLog(@"** Auto update apple watch sync is off **");
        }
    }
    else if (permissionStatus == HKAuthorizationStatusSharingDenied) {
        NSLog(@"** HKHealthStore HKAuthorizationStatusSharingDenied **");
    }
    
    //HHT temp change
//    [self performSelector:@selector(updateData:) withObject:date_Yesterday afterDelay:0.25];
    [components release];
}

-(void)loadSectionsForMovesTbl
{
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
     
    _sectionTitleDataMovesTblView = [[NSMutableArray alloc] initWithArray:[soapWebService filterObjectsByKeys:@"UniqueID" array:_sectionTitleDataMovesTblView]];

}

//new API
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == movesTblView)
    {
        if ([_sectionTitleDataMovesTblView count] == 0) {
            return 1;
        }
        else
        {
            return [_sectionTitleDataMovesTblView count];
        }
    }
    else
    {
            return [_sectionCount count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == movesTblView)
    {
        if ([_sectionTitleDataMovesTblView count] == 0) {
            return 0;
        }
        else
        {
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
            rowListArr = [[NSMutableArray alloc]initWithArray:[soapWebService filterObjectsByKeys:@"UniqueID" array:rowListArr]];

            return  [rowListArr count];
        }
    }
    else
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEEE, d LLLL yyyy"];
        NSDate *date = [dateFormatter dateFromString:_sectionTitle[section]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];

        NSString *dateStr = [dateFormatter stringFromDate:date];

        NSString *filter = @"%K == %@";
        NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:filter,@"PlanDate",dateStr];
        NSArray * tempArr = [[NSArray alloc]initWithArray:[_userPlanDateListData filteredArrayUsingPredicate:categoryPredicate]];
        NSMutableArray *rowListArr = [[NSMutableArray alloc] init];
        for (int j=0; j<[tempArr count]; j++)
        {
            NSPredicate *categoryPredicates = [NSPredicate predicateWithFormat:filter,@"UniqueID",tempArr[j][@"ParentUniqueID"]];
            NSArray * tempArrs = [[NSArray alloc]initWithArray:[_userPlanListData filteredArrayUsingPredicate:categoryPredicates]];
            [rowListArr addObjectsFromArray:tempArrs];
        }
        rowListArr = [[NSMutableArray alloc]initWithArray:[soapWebService filterObjectsByKeys:@"UniqueID" array:rowListArr]];

        return [rowListArr count];
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == movesTblView)
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
        
        NSMutableArray *filteredArr = [soapWebService filterObjectsByKeys:@"MoveID" array:moveNameListArr];
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
    else
    {
        static NSString *CellIdentifier = @"MyMovesListTableViewCell";

        NSArray *arrData = [[NSBundle mainBundle]loadNibNamed:@"MyMovesListTableViewCell" owner:nil options:nil];

        MyMovesListTableViewCell *cell = [[MyMovesListTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell = [arrData objectAtIndex:0];
        cell.bgView.backgroundColor = PrimaryDarkColor;

        cell.checkBoxImgView.tintColor = UIColor.lightGrayColor;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEEE, d LLLL yyyy"];
        NSDate *date = [dateFormatter dateFromString:_sectionTitle[indexPath.section]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        
        NSString *dateStr = [dateFormatter stringFromDate:date];
        
        NSString *filter = @"%K == %@";
        NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:filter,@"PlanDate",dateStr];
        NSArray * tempArr = [[NSArray alloc]initWithArray:[_userPlanDateListData filteredArrayUsingPredicate:categoryPredicate]];
        NSMutableArray *rowListArr = [[NSMutableArray alloc] init];
        for (int j=0; j<[tempArr count]; j++)
        {
            NSPredicate *categoryPredicates = [NSPredicate predicateWithFormat:filter,@"UniqueID",tempArr[j][@"ParentUniqueID"]];
            NSArray * tempArrs = [[NSArray alloc]initWithArray:[_userPlanListData filteredArrayUsingPredicate:categoryPredicates]];
            [rowListArr addObjectsFromArray:tempArrs];
        }
        rowListArr = [[NSMutableArray alloc]initWithArray:[soapWebService filterObjectsByKeys:@"UniqueID" array:rowListArr]];
        
        if(rowListArr.count != 0)
        {
            cell.templateNameLbl.text = rowListArr[indexPath.row][@"PlanName"];
        }
        
        return  cell;
    }
}

#pragma mark TABLE VIEW METHODS



-(void)loadRowDataDateArr:(NSMutableArray*)arr
{
    for (int i = 0; i <= [arr count]; i++) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEEE, d LLLL yyyy"];
        NSDate *date = [dateFormatter dateFromString:i];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        
        NSString *filter = @"%K == %@";
        NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:filter,@"PlanDate",[dateFormatter stringFromDate:date]];
        [_listViewItem addObject:[_userPlanDateListData filteredArrayUsingPredicate:categoryPredicate]];
        NSLog(@"%lu", (unsigned long)[_listViewItem count]);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (tableView ==  movesTblView)
    {
        movesTblView.tableFooterView.backgroundColor = UIColor.grayColor;

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
        
        NSLog(@"%@", rowListArr[indexPath.row]);
        
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
            moveDetailVc.passDataDel = self;
            moveDetailVc.parentUniqueID = rowListArr[indexPath.row][@"UniqueID"];
            moveDetailVc.currentDate = self.date_currentDate;
            moveDetailVc.moveSetListDict = _userPlanMoveSetListData;
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
            [self.navigationController pushViewController:moveDetailVc animated:YES];
        }
    }
    else
    {
        [self tabBarAction:calendarViewBtn];
        [self expandButtonAction:expandBtn];

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEEE, d LLLL yyyy"];
        NSString *dateStr = [_sectionTitle objectAtIndex:indexPath.section];
        NSDate *date = [dateFormatter dateFromString:dateStr];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        self.date_currentDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:date]];

        [calendar selectDate:self.date_currentDate];
        [listView setHidden:YES];
        [self setDateLbl:self.date_currentDate];
        [self loadTableData:self.date_currentDate];

    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(tableView == movesTblView)
    {
        if ([_sectionTitleDataMovesTblView count] == 0) {
            return nil;
        }
        else
        {
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
    else
    {
        static NSString *CellIdentifier = @"MyMovesListTableViewCell";

        NSArray *arrData = [[NSBundle mainBundle]loadNibNamed:@"MyMovesListTableViewCell" owner:nil options:nil];

        MyMovesListTableViewCell *cell = [[MyMovesListTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell = [arrData objectAtIndex:0];

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        [button addTarget:self
//                   action:@selector(didselectSection:)
//         forControlEvents:UIControlEventTouchUpInside];
//        button.frame = cell.contentView.bounds;
        button.frame = CGRectMake(cell.contentView.frame.origin.x, cell.contentView.frame.origin.y, cell.contentView.frame.size.width, cell.contentView.frame.size.height);

        [button setBackgroundColor:[UIColor whiteColor]];
        button.tag = section;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        NSString *myString = @"   ";
        NSString *dateLbl = [myString stringByAppendingString:[_datesTitleArr objectAtIndex:section]];
//        button.backgroundColor = PrimaryDarkColor;
        [button setTitle:dateLbl forState:UIControlStateNormal];

        return button;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(tableView == movesTblView)
    {
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
//        cell.bgView.backgroundColor = button.backgroundColor;
//        cell.bgView.alpha = button.alpha;

        [button addTarget:self action:@selector(addMove:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"" forState:UIControlStateNormal];
        button.frame = cell.contentView.bounds;

        [cell.contentView addSubview:button];
        
        return [cell contentView];
    }
    else
    {
        return nil;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == movesTblView)
    {
        return 30;
    }
    else
    {
        return 30;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView != movesTblView)
    {
        return 50;
    }
    else
    {
        if ([_sectionTitleDataMovesTblView count] == 0)
        {
            return 0;
        }
        else
        {
            return 30;
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(tableView == movesTblView)
    {
        if (section == [_sectionTitleDataMovesTblView count] - 1) {
            return 30;
        }
        else if ([_sectionTitleDataMovesTblView count] == 0)
        {
            return 30;
        }
        else
        {
            return 0;
        }
    }
    else
    {
        return 0;
    }
}
-(IBAction)didselectSection:(UIButton*)sender{
//    [_listViewItem removeAllObjects];

//    _listViewItem = [[NSMutableArray alloc]init];
    
    if(currentSection == sender.tag)
    {
        currentSection = 1200;
    }
    else
    {
        currentSection = sender.tag;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEEE, d LLLL yyyy"];
        NSDate *date = [dateFormatter dateFromString:_sectionTitle[sender.tag]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        
        NSString *filter = @"%K == %@";
        NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:filter,@"WorkoutDate",[dateFormatter stringFromDate:date]];
       
        _listViewItem = [[NSMutableArray alloc]initWithArray:[_exerciseData filteredArrayUsingPredicate:categoryPredicate]];
    }
    [listViewMoves reloadData];
}

-(IBAction)addMove:(UIButton*)sender{

    dispatch_async(dispatch_get_main_queue(), ^{
        MyMovesListViewController *moveListVc = [[MyMovesListViewController alloc]initWithNibName:@"MyMovesListViewController" bundle:nil];
        moveListVc.selectedDate = self.date_currentDate;
        moveListVc.userId = userId;
        moveListVc.passDataDel = self;
        NSString *statusValue = @"New";
        NSString *filter = @"%K == %@";
        NSPredicate *newPredicate = [NSPredicate predicateWithFormat:filter,@"Status",statusValue];
        NSArray * tempArr = [[NSMutableArray alloc]initWithArray:[_userPlanListData filteredArrayUsingPredicate:newPredicate]];
        moveListVc.newCount = [tempArr count];
//        sender.backgroundColor = UIColor.lightGrayColor;
        sender.alpha = 1;
        [self.navigationController pushViewController:moveListVc animated:YES];
    });
    
    [self randomStringWithLength:11];
}


-(NSString *) randomStringWithLength:(int)digit {
    NSString *alphaNumaricStr = @"abcdefghijklmnopqrstuvwxyz0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: digit];
    
    for (int i=0; i<digit; i++) {
        [randomString appendFormat: @"%C", [alphaNumaricStr characterAtIndex: arc4random_uniform([alphaNumaricStr length])]];
    }
    NSLog(@"S-%@",randomString);

    return randomString;
}

-(IBAction)checkAction:(UIButton*)sender{
    
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:movesTblView]; // maintable --> replace your tableview name
    NSIndexPath *clickedButtonIndexPath = [movesTblView indexPathForRowAtPoint:touchPoint];
    
    NSLog(@"index path.section ==%ld",(long)clickedButtonIndexPath.section);
    NSLog(@"index path.row ==%ld",(long)clickedButtonIndexPath.row);
    
//    NSString *filter = @"%K == %@";
//    NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:filter,@"PlanName",_sectionTitleDataMovesTblView[clickedButtonIndexPath.section]];
//    NSMutableArray * tempArr = [[NSMutableArray alloc]initWithArray:[_tblData filteredArrayUsingPredicate:categoryPredicate]];
    
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
        [soapWebService updateCheckBoxStatusToDb:rowListArr[clickedButtonIndexPath.row][@"UniqueID"] checkBoxStatus:@"yes"];
    }
    else
    {
        [soapWebService updateCheckBoxStatusToDb:rowListArr[clickedButtonIndexPath.row][@"UniqueID"] checkBoxStatus:@"no"];
    }
    
    [self loadTableData:self.date_currentDate];
//    _exerciseData = [[[NSMutableArray alloc]initWithArray:[soapWebService loadExerciseFromDb]]retain];
//    [self loadCircleInCalendar:_exerciseData];
}

/*
//HHT apple watch
- (void)readData {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    interval.day = 1;
    
    NSDateComponents *anchorComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                                     fromDate:[NSDate date]];
    anchorComponents.hour = 0;
    NSDate *anchorDate = [calendar dateFromComponents:anchorComponents];
    HKQuantityType *quantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    // Create the query
    HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType
                                                                           quantitySamplePredicate:nil
                                                                                           options:HKStatisticsOptionCumulativeSum
                                                                                        anchorDate:anchorDate
                                                                                intervalComponents:interval];
    
    query.initialResultsHandler = ^(HKStatisticsCollectionQuery* query, HKStatisticsCollection* results, NSError *error) {
        if (error) {
            // Perform proper error handling here
            NSLog(@"** An error occurred while calculating the statistics: %@ **",error.localizedDescription);
        }
        
        DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
        //NSDate *endDate = self.date_currentDate;
        
        NSDate *endDate = dietmasterEngine.dateSelected;
        NSDate *startDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:0 toDate:endDate options:0];
        
        [results enumerateStatisticsFromDate:startDate toDate:endDate withBlock:^(HKStatistics * _Nonnull result, BOOL * _Nonnull stop) {
            HKQuantity *quantity = result.sumQuantity;
            if (quantity) {
                //NSDate *date = result.endDate;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    stepCount = [quantity doubleValueForUnit:[HKUnit countUnit]];
                    [self stepCountSave];
                    
                    double caloriesBurned = [self.sd stepsToCalories:stepCount];
                    calories = caloriesBurned;
                    [self caloriesCount];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Data not available");
                    //[self performSelector:@selector(updateData:) withObject:self.date_currentDate afterDelay:0.25];
                    
                    [self performSelector:@selector(loadExerciseData:) withObject:self.date_currentDate afterDelay:1.0];
                    
                });
            }
            
            if(stop)
            {
                //HHT temp change
                //                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                //                     [self performSelector:@selector(updateData:) withObject:self.date_currentDate afterDelay:0.25];
                //                });
            }
        }];
    };
    
    [self.healthStore executeQuery:query];
}
*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [lblDateHeader release];
    [commentsTxtView release];
    [_userCommentsLbl release];
    [_displayedMonthLbl release];
    [listViewMoves release];
    [listView release];
    [listCurrentMonthLbl release];
    [_dayToggleView release];
    [_dayToolBar release];
    [_proportionalHeightCalConst release];
    [expandBtn release];
    [_sendMessageBtn release];
    [_lineView release];
    [_showPopUpVw release];
    [_sendMsgStackVw release];
    [super dealloc];
}

#pragma mark - <FSCalendarDelegate>

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    return YES;
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    if (monthPosition == FSCalendarMonthPositionNext || monthPosition == FSCalendarMonthPositionPrevious) {
        [calendar setCurrentPage:date animated:YES];
    }
    self.date_currentDate = calendar.selectedDate;
    [self setDateLbl:calendar.selectedDate];
}



- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar
{
//    [self showLoading];
    if (self.date_currentDate == calendar.currentPage) {
//        [self loadCalendarOnMonthChange:calendar.selectedDate];
    }
//    else if ([[self.dateFormatter stringFromDate:[NSDate date]] isEqualToString:[self.dateFormatter stringFromDate:self.date_currentDate]]) {
//        [self loadCalendarOnMonthChange:self.date_currentDate];
//    }
    else
    {
//        [self loadCalendarOnMonthChange:calendar.currentPage];
    }
    
    
    
}

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    calendar.frame = (CGRect){calendar.frame.origin,bounds.size};
}

#pragma mark - <FSCalendarDataSource>
/*
- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date
{
    if ([self.datesWithInfo containsObject:[self.dateFormatter stringFromDate:date]]) {
        if ([self.datesExerciseCompletd containsObject:[self.dateFormatter stringFromDate:date]])
        {
            return 0;
        }
        else
        {
            return 1;
        }
    }
    return 0;
}_satiz*/
//- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar
//{
//    return [self.dateFormatter dateFromString:@"1990/10/01"];
//}
//
//- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar
//{
//    return [self.dateFormatter dateFromString:@"2030/10/10"];
//}
#pragma mark - <FSCalendarDelegateAppearance>

//- (NSArray *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventDefaultColorsForDate:(NSDate *)date
//{
//        return @[[UIColor blackColor]];
//}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillSelectionColorForDate:(NSDate *)date
{
    return [UIColor blackColor];
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillDefaultColorForDate:(NSDate *)date
{
    return [UIColor whiteColor];
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderDefaultColorForDate:(NSDate *)date
{
//    if ([self.datesExerciseCompletd containsObject:[self.dateFormatter stringFromDate:date]])
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy/MM/dd";
    NSString *dateString = [dateFormatter stringFromDate:date];
    [dateFormatter release];
    
    while(isLoading) {
        NSLog(@"PREVENTING A CRASH HERE!");
        //containsObject below cannot run while loadEventCalendar block operation adds objs to datesWithInfo
        usleep(1000);
    }

    //lock it down while enumerating.
    isLoading = YES;
    if ([self.datesWithInfo containsObject:dateString])
    {
        isLoading = NO;
        return [UIColor greenColor];
    }
    else
    {
        isLoading=  NO;
        return [UIColor whiteColor];
    }
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderSelectionColorForDate:(NSDate *)date
{
    return [UIColor blackColor];
}

#pragma mark - <WSWorkoutplanOfflineListDelegate>

- (void)getUserWorkoutplanOfflineListFailed:(NSString *)failedMessage {
    [self hideLoading];
}

- (void)getUserWorkoutplanOfflineListFinished:(NSDictionary *)responseArray {
    [self hideLoading];

    _userPlanListData        = [[NSMutableArray alloc]initWithArray:[responseArray objectForKey:@"ServerUserPlanList"]];
    _userPlanDateListData    = [[NSMutableArray alloc]initWithArray:[responseArray objectForKey:@"ServerUserPlanDateList"]];
    _userPlanMoveListData    = [[NSMutableArray alloc]initWithArray:[responseArray objectForKey:@"ServerUserPlanMoveList"]];
    _userPlanMoveSetListData = [[NSMutableArray alloc]initWithArray:[responseArray objectForKey:@"ServerUserPlanMoveSetList"]];

       [self loadEventCalendar:[[NSMutableArray alloc]initWithArray:[responseArray objectForKey:@"ServerUserPlanDateList"]]];

    dispatch_async(dispatch_get_main_queue(), ^{
//        [self loadListTable];
        [movesTblView reloadData];
        [self hideLoading];
    });
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    
    if ([commentsTxtView isFirstResponder] && [touch view] != commentsTxtView) {
        [commentsTxtView resignFirstResponder];
    }
    
    [super touchesBegan:touches withEvent:event];
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    CGRect textFieldRect =
    [self.view.window convertRect:textView.bounds fromView:textView];
    CGRect viewRect =
    [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0) {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0) {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown) {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textViewDidChange:(UITextView *)textView
{
    if([commentsTxtView.text length] != 0)
    {
        [_userCommentsLbl setHidden:YES];
    }
    else
    {
//        [_userCommentsLbl setHidden:NO];
        [_userCommentsLbl setHidden:YES];

    }
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    //            commentsTxtView.text = [NSString stringWithFormat:@"%@",_tblData[0][@"Comments"]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
    NSString *dateString = [formatter stringFromDate:self.date_currentDate];
    
    [soapWebService updateUserCommentsToDb:dateString commentsToUpdate:commentsTxtView.text];
    
    
    if([commentsTxtView.text length] != 0)
    {
        [_userCommentsLbl setHidden:YES];
    }
    else
    {
//        [_userCommentsLbl setHidden:NO];
        [_userCommentsLbl setHidden:YES];

    }
    [UIView commitAnimations];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}
- (IBAction)expandButtonAction:(id)sender {
    
    if IS_IPHONE_X_XR_XS
    {
        [UIView animateWithDuration:0.3 animations:^{
            if (self.proportionalHeightCalConst.constant == self.view.frame.size.height /4) {
                self.proportionalHeightCalConst.constant = 0;
                [self.calendarView setHidden:YES];
            }
            else
            {
                self.proportionalHeightCalConst.constant = self.view.frame.size.height /4;
                [self.calendarView setHidden:NO];
            }
            [self.view layoutIfNeeded];
            [self.view layoutSubviews];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3 animations:^{
            if (self.proportionalHeightCalConst.constant == self.view.frame.size.height /3) {
                self.proportionalHeightCalConst.constant = 0;
                [self.calendarView setHidden:YES];
            }
            else
            {
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
//    [self loadCircleInCalendar:_exerciseData];
}
- (IBAction)sendMsgBtnAction:(id)sender {
    MessageViewController *vc = [[MessageViewController alloc] initWithNibName:@"MessageView" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}
- (IBAction)popUpBtn:(id)sender {
    PopUpView* popUpView = [[PopUpView alloc]initWithNibName:@"PopUpView" bundle:nil];
    popUpView.modalPresentationStyle = UIModalPresentationOverFullScreen;
    popUpView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    popUpView.gotoDelegate = self;
    _showPopUpVw.hidden = true;
    popUpView.vc = @"MyMoves";
    [self presentViewController:popUpView animated:YES completion:nil];

}

-(void)DietMasterGoViewController
{
    DietMasterGoViewController *vc = [[DietMasterGoViewController alloc] initWithNibName:@"DietMasterGoViewController" bundle:nil];
    vc.title = @"Today";
    vc.showPopUpVw.hidden = false;
    vc.navigationController.navigationItem.hidesBackButton = true;
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
    vc.title = @"My Goal";
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:false] ;
    [self RemovePreviousViewControllerFromStack];
}
-(void)AppSettings
{
    AppSettings *vc = [[AppSettings alloc] initWithNibName:@"AppSettings" bundle:nil];
    vc.title = @"My Goal";
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
        [navigationArray release];
    }
}


- (void)hideShowPopUpView
{
    self.showPopUpVw.hidden = false;
}

@end
