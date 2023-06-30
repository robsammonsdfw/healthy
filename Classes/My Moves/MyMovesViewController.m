//
//  MyMovesViewController.m
//  MyMoves
//
//  Created by Samson  on 14/01/19.
//

#import "MyMovesViewController.h"

#import <HealthKit/HealthKit.h>
@import FSCalendar;
#import "StepData.h"
#import "MyMovesTableViewCell.h"
#import "MyMovesDetailsViewController.h"
#import "MyMovesListViewController.h"
#import "MyMovesDataProvider.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "MyMovesListTableViewCell.h"
#import "MessageViewController.h"
#import "DietMasterGoViewController.h"

#import "DMMovePlan.h"
#import "DMMoveDay.h"
#import "DMMoveRoutine.h"
#import "DMMoveSet.h"
#import "DMMove.h"

static NSString *CellIdentifier = @"MyMovesTableViewCell";
static NSString *EmptyCellIdentifier = @"EmptyCellIdentifier";

@interface MyMovesViewController ()<FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) MyMovesDataProvider *soapWebService;

/// Table view that shows the moves.
@property (nonatomic, strong) UITableView *tableView;
/// Toolbar with two buttons, left and right.
@property (nonatomic, strong) UIToolbar *dayToolBar;
/// Month which appears at bottom of calendar, above the expand button.
@property (nonatomic, strong) UILabel *displayedMonthLbl;
/// Displays the currently selected date in the toolbar.
@property (nonatomic, strong) UILabel *lblDateHeader;
/// Button to expand or hide the calendar day view.
@property (nonatomic, strong) UIButton *expandBtn;
/// View that encloses the calendar.
@property (nonatomic, strong) FSCalendar *calendarView;

/// The layout constraint that will be animated if the calendar is hidden.
@property (nonatomic, strong) NSLayoutConstraint *closedCalendarConstraint;

@property (nonatomic,retain) HKHealthStore *healthStore;
@property (nonatomic, strong) StepData *sd;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

/// The date the user has selected to view Plan data for.
@property (nonatomic, strong) NSDate *selectedDate;
/// The plan data associated with the date selected.
@property (nonatomic, strong) NSMutableArray<DMMoveDay *> *selectedUserPlanDays;
/// All user plan days data.
@property (nonatomic, strong) NSMutableArray<DMMoveDay *> *allUserPlanDays;

//@property (nonatomic, strong) NSMutableArray *selectedExercisesArr;
//@property (nonatomic, strong) NSMutableArray *prevDataArr;
//@property (nonatomic, strong) NSMutableArray *arrData;
//@property (nonatomic, strong) NSMutableArray<NSString *> *datesWithInfo;
//@property (nonatomic, strong) NSMutableArray *datesExerciseCompletd;
//@property (nonatomic, strong) NSMutableArray *exerciseData;
//@property (nonatomic, strong) NSMutableArray *userPlanListData;
//@property (nonatomic, strong) NSMutableArray *userPlanDateListData;
//@property (nonatomic, strong) NSMutableArray *userPlanMoveListData;
//@property (nonatomic, strong) NSMutableArray *userPlanMoveSetListData;
//@property (nonatomic, strong) NSMutableArray *loadMoveDetails;
//@property (nonatomic, strong) NSMutableArray *deletedPlanArr;
//@property (nonatomic, strong) NSMutableArray *deletedPlanDateArr;
//@property (nonatomic, strong) NSMutableArray *deletedMoveArr;
//@property (nonatomic, strong) NSMutableArray *deletedMoveSetArr;
//@property (nonatomic, strong) NSMutableArray *listViewItem;
//@property (nonatomic, strong) NSMutableArray *tblData;
//@property (nonatomic, strong) NSMutableArray *sectionTitleDataMovesTblView;
//@property (nonatomic, strong) NSMutableArray *sectionTitle;

@end

@implementation MyMovesViewController

#pragma mark - View Lifecycle

- (instancetype)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy/MM/dd";
        _healthStore = [[HKHealthStore alloc] init];
        _sd = [[StepData alloc]init];
        _soapWebService = [[MyMovesDataProvider alloc] init];
        
        _allUserPlanDays = [NSMutableArray array];
        _selectedUserPlanDays = [NSMutableArray array];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.calendarView = [[FSCalendar alloc] initWithFrame:CGRectZero];
    self.calendarView.translatesAutoresizingMaskIntoConstraints = NO;
    self.calendarView.dataSource = self;
    self.calendarView.delegate = self;
    self.calendarView.scrollDirection = FSCalendarScrollDirectionVertical;
    self.calendarView.backgroundColor = [UIColor whiteColor];
    self.calendarView.scope = FSCalendarScopeMonth;
    self.calendarView.appearance.subtitlePlaceholderColor = [UIColor darkTextColor];
    self.calendarView.appearance.subtitleDefaultColor = [UIColor yellowColor];
    self.calendarView.appearance.subtitleWeekendColor = [UIColor redColor];
    [self.calendarView.calendarHeaderView setHidden:YES];
    self.calendarView.headerHeight = 0;
    self.calendarView.appearance.todayColor = [UIColor yellowColor];
    [self.view addSubview:self.calendarView];

    self.displayedMonthLbl = [[UILabel alloc] init];
    self.displayedMonthLbl.translatesAutoresizingMaskIntoConstraints = NO;
    self.displayedMonthLbl.font = [UIFont boldSystemFontOfSize:18];
    self.displayedMonthLbl.textColor = [UIColor blackColor];
    [self.view addSubview:self.displayedMonthLbl];

    self.expandBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.expandBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.expandBtn addTarget:self action:@selector(expandButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.expandBtn];

    self.dayToolBar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    self.dayToolBar.translatesAutoresizingMaskIntoConstraints = NO;
    // Setup the toolbar buttons.
    UIButton *btnLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLeft setFrame:CGRectMake(0, 0, 28, 28)];
    UIImage *image = [UIImage imageNamed:@"btn_Arrow-Left"];
    image = [image imageWithTintColor:[UIColor whiteColor] renderingMode:UIImageRenderingModeAlwaysTemplate];
    [btnLeft setImage:image forState:UIControlStateNormal];
    [btnLeft setBackgroundColor:[UIColor clearColor]];
    [btnLeft addTarget:self action:@selector(showPrevDate:) forControlEvents:UIControlEventTouchUpInside];
    [btnLeft setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *barBtnLeft = [[UIBarButtonItem alloc] initWithCustomView:btnLeft];
    // Empty space between.
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    // Right button.
    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRight setFrame:CGRectMake(0, 0, 28, 28)];
    image = [UIImage imageNamed:@"btn_Arrow-Right"];
    image = [image imageWithTintColor:[UIColor whiteColor] renderingMode:UIImageRenderingModeAlwaysTemplate];
    [btnRight setImage:image forState:UIControlStateNormal];
    [btnRight setBackgroundColor:[UIColor clearColor]];
    [btnRight addTarget:self action:@selector(showNextDate:) forControlEvents:UIControlEventTouchUpInside];
    [btnRight setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *barBtnRight = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    [self.dayToolBar setItems:@[barBtnLeft, spacer, barBtnRight]];
    [self.view addSubview:self.dayToolBar];

    self.lblDateHeader = [[UILabel alloc] init];
    self.lblDateHeader.translatesAutoresizingMaskIntoConstraints = NO;
    self.lblDateHeader.textColor = [UIColor whiteColor];
    self.lblDateHeader.font = [UIFont systemFontOfSize:18];
    self.lblDateHeader.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.lblDateHeader];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    self.tableView.estimatedRowHeight = 44;
    UINib *cellNib = [UINib nibWithNibName:@"MyMovesTableViewCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:CellIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:EmptyCellIdentifier];
    [self.view addSubview:self.tableView];

    // Constrain.
    [self.calendarView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:0].active = YES;
    [self.calendarView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:0].active = YES;
    [self.calendarView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:0].active = YES;
    [self.calendarView.heightAnchor constraintEqualToConstant:250].active = YES;
    
    [self.dayToolBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:0].active = YES;
    [self.dayToolBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:0].active = YES;
    [self.dayToolBar.topAnchor constraintEqualToAnchor:self.calendarView.bottomAnchor constant:0].active = YES;
    [self.dayToolBar.heightAnchor constraintEqualToConstant:44].active = YES;
    
    // For animating the calendar open or closed.
    self.closedCalendarConstraint = [self.dayToolBar.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:45];
    self.closedCalendarConstraint.active = NO; // Set to NO as default.
    
    [self.lblDateHeader.leadingAnchor constraintEqualToAnchor:self.dayToolBar.leadingAnchor constant:30].active = YES;
    [self.lblDateHeader.trailingAnchor constraintEqualToAnchor:self.dayToolBar.trailingAnchor constant:-30].active = YES;
    [self.lblDateHeader.topAnchor constraintEqualToAnchor:self.dayToolBar.topAnchor constant:8].active = YES;
    [self.lblDateHeader.bottomAnchor constraintEqualToAnchor:self.dayToolBar.bottomAnchor constant:-8].active = YES;
    
    [self.expandBtn.bottomAnchor constraintEqualToAnchor:self.dayToolBar.topAnchor constant:5].active = YES;
    [self.expandBtn.centerXAnchor constraintEqualToAnchor:self.dayToolBar.centerXAnchor constant:0].active = YES;

    [self.displayedMonthLbl.centerXAnchor constraintEqualToAnchor:self.expandBtn.centerXAnchor constant:0].active = YES;
    [self.displayedMonthLbl.bottomAnchor constraintEqualToAnchor:self.expandBtn.topAnchor constant:-3].active = YES;
    
    [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:0].active = YES;
    [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:0].active = YES;
    [self.tableView.topAnchor constraintEqualToAnchor:self.dayToolBar.bottomAnchor constant:0].active = YES;
    [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:0].active = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     
    // Put chat button on Right upper nav.
    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRight setFrame:CGRectMake(0, 0, 28, 28)];
    UIImage *image = [UIImage imageNamed:@"Icon ionic-ios-chatbubbles"];
    image = [image imageWithTintColor:[UIColor whiteColor]
                        renderingMode:UIImageRenderingModeAlwaysTemplate];
    [btnRight setImage:image forState:UIControlStateNormal];
    [btnRight setBackgroundColor:[UIColor clearColor]];
    [btnRight addTarget:self action:@selector(sendMsgBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [btnRight setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *barButtonRight = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    self.navigationItem.rightBarButtonItem = barButtonRight;

    // Add a button to the left to show or hide the calendar.
    UIButton *btnLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLeft setFrame:CGRectMake(0, 0, 24, 24)];
    image = [UIImage imageNamed:@"83-calendar"];
    image = [image imageWithTintColor:[UIColor whiteColor]
                        renderingMode:UIImageRenderingModeAlwaysTemplate];
    [btnLeft setImage:image forState:UIControlStateNormal];
    [btnLeft setBackgroundColor:[UIColor clearColor]];
    [btnLeft addTarget:self action:@selector(expandButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [btnLeft setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *barButtonLeft = [[UIBarButtonItem alloc] initWithCustomView:btnLeft];
    self.navigationItem.leftBarButtonItem = barButtonLeft;

    self.dayToolBar.barTintColor = AccentColor;
    UIImage *btnImage = [[UIImage imageNamed:@"log_up_arrow"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.expandBtn setImage:btnImage forState:UIControlStateNormal];
    self.expandBtn.tintColor = AccentColor
    
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"My Moves";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};

    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    dietmasterEngine.taskMode = @"View";
    
    // Default to today's date.
    NSDate *dateNow = [NSDate date];
    // Load default data.
    self.calendarView.today = dateNow;
    [self.allUserPlanDays addObjectsFromArray:[self.soapWebService getUserPlanDays]];
    [self.calendarView reloadData];
    [self loadMovePlanForDate:dateNow];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    __weak typeof(self) weakSelf = self;
    [self.soapWebService fetchAllUserPlanDataWithCompletionBlock:^(BOOL completed, NSError *error) {
        // Load local data.
        [weakSelf.allUserPlanDays addObjectsFromArray:[weakSelf.soapWebService getUserPlanDays]];
        [weakSelf loadMovePlanForDate:weakSelf.selectedDate];
    }];

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

/// Sets the UI to reflect the date the user selected.
- (void)setDateHeaderLabelForDate:(NSDate *)date {
    NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
    [self.dateFormatter setTimeZone:systemTimeZone];
    [self.dateFormatter setDateStyle:NSDateFormatterLongStyle];
    
    NSString *dateToDisplay = [self.dateFormatter stringFromDate:date];
    self.lblDateHeader.text = dateToDisplay;
    
    [self.dateFormatter setDateFormat:@"MMMM"];
    self.displayedMonthLbl.text = [self.dateFormatter stringFromDate:date];
}

- (void)loadCalendarOnMonthChange:(NSDate*)dateToSet {
    [self.dateFormatter setDateFormat:@"MMMM"];
    _displayedMonthLbl.text = [self.dateFormatter stringFromDate:dateToSet];
}

- (void)showNextDate:(id)sender {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    NSCalendar *cal = [NSCalendar currentCalendar];
    [components setDay:+1];
    NSDate *nextDate = [cal dateByAddingComponents:components toDate:self.selectedDate options:0];
    
    [self.calendarView selectDate:nextDate];
    [self loadMovePlanForDate:nextDate];

    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    dietmasterEngine.dateSelected = nextDate;
    
    HKAuthorizationStatus permissionStatus = [self.healthStore authorizationStatusForType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]];
    
    DMUser *currentUser = [[DMAuthManager sharedInstance] loggedInUser];
    if (permissionStatus == HKAuthorizationStatusSharingAuthorized) {
        if (currentUser.enableAppleHealthSync){
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

- (void)showPrevDate:(id)sender {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    NSCalendar *cal = [NSCalendar currentCalendar];
    [components setDay:-1];
    NSDate *prevDate = [cal dateByAddingComponents:components toDate:self.selectedDate options:0];
    
    [self.calendarView selectDate:prevDate];
    [self loadMovePlanForDate:prevDate];

    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    dietmasterEngine.dateSelected = prevDate;
    
    HKAuthorizationStatus permissionStatus = [self.healthStore authorizationStatusForType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]];
    
    DMUser *currentUser = [[DMAuthManager sharedInstance] loggedInUser];
    if (permissionStatus == HKAuthorizationStatusSharingAuthorized) {
        if (currentUser.enableAppleHealthSync){
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

#pragma mark - FSCalendarDelegateAppearance

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillSelectionColorForDate:(NSDate *)date {
    return [UIColor blackColor];
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillDefaultColorForDate:(NSDate *)date {
    return [UIColor whiteColor];
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderDefaultColorForDate:(NSDate *)date {
    // Define the color of the calendar outline (circle) when
    // the user has something on that date.
    unsigned int flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    __block NSCalendar *dateCalendar = [NSCalendar currentCalendar];

    NSDateComponents *calendarComponents = [dateCalendar components:flags fromDate:date];
    __block NSDate *calendarDateToCompare = [dateCalendar dateFromComponents:calendarComponents];

    [self.dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    BOOL foundDate = NO;
    for (DMMoveDay *day in [self.allUserPlanDays copy]) {
        NSDate *moveDate = [self.dateFormatter dateFromString:day.planDate];
        NSDateComponents* moveComponents = [dateCalendar components:flags fromDate:moveDate];
        NSDate *moveDateToCompare = [dateCalendar dateFromComponents:moveComponents];

        if ([moveDateToCompare isEqualToDate:calendarDateToCompare]) {
            foundDate = YES;
            break;
        }
    }

    if (foundDate) {
        return [UIColor greenColor];
    }
    return [UIColor whiteColor];
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderSelectionColorForDate:(NSDate *)date {
    return [UIColor blackColor];
}

#pragma mark - FSCalendarDelegate

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
    return YES;
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
    if (monthPosition == FSCalendarMonthPositionNext || monthPosition == FSCalendarMonthPositionPrevious) {
        [calendar setCurrentPage:date animated:YES];
    }
    self.selectedDate = date;
    [self loadMovePlanForDate:date];
}

- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar {
    self.selectedDate = calendar.currentPage;
    [self loadMovePlanForDate:calendar.currentPage];
}

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated {
    // No-Op.
}

#pragma mark - Plan Table

/// Sets the current date selected.
- (void)loadMovePlanForDate:(NSDate *)date {
    self.selectedDate = date;
    [self.selectedUserPlanDays removeAllObjects];
    if (date) {
        NSArray *planData = [self.soapWebService getUserPlanDaysForDate:date];
        if (planData.count) {
            [self.selectedUserPlanDays addObjectsFromArray:planData];
        }
    }
    [self setDateHeaderLabelForDate:date];
    [self.tableView reloadData];
}

#pragma mark - UITableView DataSource / Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return MAX(self.selectedUserPlanDays.count, 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.selectedUserPlanDays.count) {
        DMMoveDay *day = self.selectedUserPlanDays[section];
        return MAX(day.routines.count, 1);
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.selectedUserPlanDays.count) {
        // Show empty cell.
        UITableViewCell *emptyCell = [self getEmptyCellForTableView:tableView atIndexPath:indexPath];
        return emptyCell;
    }
    
    MyMovesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Hide "add moves" button.
    [cell.addMoveLbl setHidden:YES];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.arrowImgV.hidden = YES; // White arrow, hide in favor of default.
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    DMMoveDay *day = self.selectedUserPlanDays[indexPath.section];
    if (!day.routines.count) {
        UITableViewCell *emptyCell = [self getEmptyCellForTableView:tableView atIndexPath:indexPath];
        return emptyCell;
    }
    DMMoveRoutine *routine = day.routines[indexPath.row];
    
    cell.bgView.backgroundColor = [UIColor whiteColor];
    // Template name background color.
    cell.tempLblView.backgroundColor = PrimaryDarkColor;
    
    cell.templateNameLbl.text = @"";
    cell.templateNameLbl.backgroundColor = PrimaryDarkColor;
    
    if (routine.isCompleted.boolValue) {
        cell.checkBoxImgView.image = [UIImage imageNamed:@"checkmark-tick"];
    } else {
        cell.checkBoxImgView.image = [UIImage imageNamed:@"check-box-empty"];
    }
    [cell.checkBoxBtn addTarget:self action:@selector(setExerciseCompleted:) forControlEvents:UIControlEventTouchUpInside];

    cell.textLabel.textColor = [UIColor blackColor];
    cell.exerciseNameLbl.textColor = [UIColor blackColor];
    cell.exerciseNameLbl.text = routine.move.name;
    cell.exerciseNameLbl.numberOfLines = 0;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.selectedUserPlanDays.count) {
        return;
    }
    
    DMMoveDay *day = self.selectedUserPlanDays[indexPath.section];
    DMMoveRoutine *routine = day.routines[indexPath.row];
    MyMovesDetailsViewController *moveDetailVc = [[MyMovesDetailsViewController alloc] init];
    moveDetailVc.routine = routine;
    [self.navigationController pushViewController:moveDetailVc animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // Determine if empty.
    if (!self.selectedUserPlanDays.count) {
        return nil;
    }
    
    DMMoveDay *day = self.selectedUserPlanDays[section];
    DMMovePlan *plan = [self.soapWebService getUserMovePlanForPlanId:day.planId];
    if (!plan) {
        return nil;
    }

    static NSString *CellIdentifier = @"MyMovesTableViewCell";
    NSArray *arrData = [[NSBundle mainBundle] loadNibNamed:@"MyMovesTableViewCell" owner:nil options:nil];
    MyMovesTableViewCell *cell = [[MyMovesTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell = [arrData objectAtIndex:0];
    UILabel * lbl = [[UILabel alloc]init];
    lbl.frame = CGRectMake(cell.contentView.frame.origin.x, cell.contentView.frame.origin.y, cell.contentView.frame.size.width, cell.contentView.frame.size.height);
    lbl.backgroundColor = PrimaryColor;
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.textColor = [UIColor blackColor];
    lbl.text = plan.planName;
    return lbl;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    NSArray *arrData = [[NSBundle mainBundle]loadNibNamed:@"MyMovesTableViewCell" owner:nil options:nil];
    MyMovesTableViewCell *cell = [[MyMovesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell = [arrData objectAtIndex:0];
    [cell.checkBoxImgView setHidden:YES];

    cell.exerciseDescriptionLbl.text = @"";
    cell.exerciseNameLbl.text = @"";
    cell.templateNameLbl.text = @"";
    [cell.addMoveLbl setHidden:NO];
    cell.bgView.backgroundColor = PrimaryDarkColor;
    cell.textLabel.textColor = [UIColor whiteColor];
    
    [cell.arrowImgV setHidden:NO];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = section; // Set section so we know which plan we're adding to.
    [button addTarget:self action:@selector(addNewMove:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"" forState:UIControlStateNormal];
    button.frame = cell.contentView.bounds;
    [cell.contentView addSubview:button];
    cell.userInteractionEnabled = YES;
    
    return [cell contentView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (!self.selectedUserPlanDays.count) {
        return 0;
    }

    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 35;
}

/// Returns an empty cell.
- (UITableViewCell *)getEmptyCellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *emptyCell = [tableView dequeueReusableCellWithIdentifier:EmptyCellIdentifier forIndexPath:indexPath];
    emptyCell.textLabel.text = @"No moves found...";
    emptyCell.backgroundColor = [UIColor whiteColor];
    emptyCell.textLabel.textColor = [UIColor blackColor];
    emptyCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return emptyCell;
}

#pragma mark - User Actions

/// Shows the my moves list view controller for a user to select an exercise.
- (IBAction)addNewMove:(UIButton *)sender {
    MyMovesListViewController *moveListVc = [[MyMovesListViewController alloc] init];
    moveListVc.selectedDate = self.selectedDate;
    NSArray *planData = [self.soapWebService getUserPlanDaysForDate:self.selectedDate];
    if (!planData.count) {
        // Add a date to the plan.
        NSArray *movePlans = [self.soapWebService getUserMovePlans];
        if (!movePlans.count) {
            [DMGUtilities showAlertWithTitle:@"Error" message:@"There are no available plans to add a Move to." inViewController:nil];
            return; // No plans to add to!
        }
        DMMovePlan *plan = movePlans.firstObject;
        NSNumber *newDayId = [self.soapWebService addMoveDayToDate:self.selectedDate toMovePlan:plan];
        DMMoveDay *moveDay = [self.soapWebService getUserPlanDayForDayId:newDayId];
        moveListVc.moveDay = moveDay;
        [self loadMovePlanForDate:self.selectedDate];
    } else {
        NSUInteger section = [sender tag];
        moveListVc.moveDay = planData[section];
    }
    [self.navigationController pushViewController:moveListVc animated:YES];
}

- (void)setExerciseCompleted:(UIButton *)sender {
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchPoint];

    DMMoveDay *day = self.selectedUserPlanDays[indexPath.section];
    DMMoveRoutine *routine = day.routines[indexPath.row];
    routine.isCompleted = @(!routine.isCompleted.boolValue);
    
    // Update the cell if it's in view.
    if ([self.tableView.indexPathsForVisibleRows containsObject:indexPath]) {
        MyMovesTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (routine.isCompleted.boolValue) {
            cell.checkBoxImgView.image = [UIImage imageNamed:@"checkmark-tick"];
        } else {
            cell.checkBoxImgView.image = [UIImage imageNamed:@"check-box-empty"];
        }
    }

    // Save to the database.
    [self.soapWebService setMoveCompleted:routine.isCompleted forRoutine:routine];
}

#pragma mark - WSGetUserWorkoutPlansDelegate

// TODO: Make sure this is connected.
- (void)getUserWorkoutPlansFailed:(NSError *)error {
    [DMActivityIndicator hideActivityIndicator];
}

// TODO: Make sure this is connected.
- (void)getUserWorkoutPlansFinished:(NSDictionary *)responseArray {
    [DMActivityIndicator hideActivityIndicator];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.allUserPlanDays addObjectsFromArray:[self.soapWebService getUserPlanDays]];
        [self loadMovePlanForDate:self.selectedDate];
    });
}

- (void)expandButtonAction:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        self.calendarView.hidden = !self.calendarView.hidden;
        self.closedCalendarConstraint.active = self.calendarView.hidden;
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)sendMsgBtnAction:(id)sender {
    MessageViewController *viewController = [[MessageViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
