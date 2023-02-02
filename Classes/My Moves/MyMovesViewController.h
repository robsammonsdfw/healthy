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
    MBProgressHUD *HUD;
    UIBarButtonItem * CalendarBarBtn;

    IBOutlet UIButton *expandBtn;
    int currentSection;
}
@property (retain, nonatomic) IBOutlet UIView *showPopUpVw;

@property (retain, nonatomic) IBOutlet NSLayoutConstraint *proportionalHeightCalConst;
@property(nonatomic,retain) HKHealthStore *healthStore;
@property(nonatomic, strong) NSMutableArray *arrData;
@property(nonatomic, strong) StepData * sd;
@property(nonatomic, strong) NSDate *date_currentDate;
@property (retain, nonatomic) IBOutlet UIView *dayToggleView;
@property (retain, nonatomic) IBOutlet UIToolbar *dayToolBar;

@property(nonatomic, strong)  FSCalendar *calendar;
@property (retain, nonatomic) IBOutlet UIView *calendarView;
@property (retain, nonatomic) IBOutlet UILabel *userCommentsLbl;
@property (retain, nonatomic) IBOutlet UILabel *displayedMonthLbl;


-(IBAction) shownextDate:(id) sender;
-(IBAction)showprevDate:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *sendMessageBtn;
@property (retain, nonatomic) IBOutlet UIView *lineView;
@property (retain, nonatomic) IBOutlet UIStackView *sendMsgStackVw;
@property (nonatomic, assign) NSString *workoutClickedFromHome;


@end
