//
//  MyMovesViewController.h
//  MyMoves
//
//  Created by Samson  on 14/01/19.
//

#import <UIKit/UIKit.h>
#import "FSCalendar/FSCalendar.h"

#import <HealthKit/HealthKit.h>
#import "StepData.h"
#import "MBProgressHUD.h"

@interface MyMovesViewController : UIViewController
{
    IBOutlet UILabel *lblDateHeader;
    IBOutlet UITextView *commentsTxtView;
    IBOutlet UITableView *movesTblView;
    NSMutableArray *selectedExercisesArr;
    NSMutableArray *prevDataArr;
    IBOutlet UITableView *listViewMoves;
    IBOutlet UIView *listView;
    IBOutlet UILabel *listCurrentMonthLbl;
    IBOutlet UIButton *listCalendarBtn ;
    UIBarButtonItem * listCalendarBarBtn;
    UIButton *calendarViewBtn;
    
    UIBarButtonItem * CalendarBarBtn;

    IBOutlet UIButton *expandBtn;
    int currentSection;
}

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *proportionalHeightCalConst;
@property (nonatomic,retain) HKHealthStore *healthStore;
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) StepData * sd;
@property (nonatomic, strong) NSDate *date_currentDate;
@property (nonatomic, strong) IBOutlet UIView *dayToggleView;
@property (nonatomic, strong) IBOutlet UIToolbar *dayToolBar;

@property (nonatomic, strong)  FSCalendar *calendar;
@property (nonatomic, strong) IBOutlet UIView *calendarView;
@property (nonatomic, strong) IBOutlet UILabel *userCommentsLbl;
@property (nonatomic, strong) IBOutlet UILabel *displayedMonthLbl;


-(IBAction) shownextDate:(id) sender;
-(IBAction)showprevDate:(id)sender;
@property (nonatomic, strong) IBOutlet UIButton *sendMessageBtn;
@property (nonatomic, strong) IBOutlet UIView *lineView;
@property (nonatomic, strong) IBOutlet UIStackView *sendMsgStackVw;
@property (nonatomic) NSString *workoutClickedFromHome;


@end
