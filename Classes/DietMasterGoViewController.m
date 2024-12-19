#import "DietMasterGoViewController.h"

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "DietmasterEngine.h"
#import "MCPieChartView.h"
#import "MCSliceLayer.h"
#import "GroceryListViewController.h"
#import "FoodsList.h"
#import "MessageViewController.h"
#import "MKNumberBadgeView.h"
#import "MyLogViewController.h"
#import "MyGoalViewController.h"
#import "MealPlanViewController.h"
#import "MCNewCustomLayeredView+MCCustomLayeredViewSubclass.h"
#import "MyMovesDataProvider.h"
#import "MyMovesViewController.h"
#import "NSString+Encode.h"
#import "FMDatabase.h"
#import "DMMyLogDataProvider.h"

@interface DietMasterGoViewController() <MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, MCPieChartViewDataSource, MCPieChartViewDelegate>

@property (nonatomic, strong) MyMovesDataProvider *soapWebService;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
/// The view that's within the scrollView. A.K.A MainView
@property (nonatomic, strong) IBOutlet UIView *entireView;
/// Should be 1000 for Standard, 1100 for MyMoves.
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *entireViewHeightConstraint;
@property (nonatomic) CGFloat entireViewDefaultHeight;

@property (nonatomic, strong) MKNumberBadgeView *numberBadge;
@property (nonatomic, strong) IBOutlet UIView *circleHomeView;
@property (nonatomic, strong) IBOutlet MCPieChartView *remaining_Pie;
@property (nonatomic, strong) IBOutlet MCPieChartView *cpf_Pie;
@property (nonatomic, strong) IBOutlet UILabel *cpfLbl;
@property (nonatomic, strong) IBOutlet UIStackView *hideShowStack;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *hideShowConstant;
@property (nonatomic, strong) IBOutlet UIView *firstExpandVw;
@property (nonatomic, strong) IBOutlet UIView *consumedView;
@property (nonatomic, strong) IBOutlet UIView *sugarView;
@property (nonatomic, strong) IBOutlet UIView *plannedView;
@property (nonatomic, strong) IBOutlet UIView *weightView;
@property (nonatomic, strong) IBOutlet UIView *stepsView;
@property (nonatomic, strong) IBOutlet UIView *burnedView;
@property (nonatomic, strong) IBOutlet UIView *workoutView;
@property (nonatomic, strong) IBOutlet UIView *scheduledView;

/// Body Scanning
@property (nonatomic, strong) IBOutlet UIView *bodyScanView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *bodyScanningTopConstraint;
@property (nonatomic, strong) IBOutlet UIButton *bodyScanningPlusBtn;
@property (nonatomic, strong) IBOutlet UIImageView *bodyScanImage;

@property (nonatomic, strong) IBOutlet UIImageView *suagrGraphImageVw;
@property (nonatomic, strong) IBOutlet UILabel *c_PercentageLbl;
@property (nonatomic, strong) IBOutlet UILabel *p_PercentageLbl;
@property (nonatomic, strong) IBOutlet UILabel *f_PercentageLbl;
@property (nonatomic, strong) IBOutlet UIView *headerBlueVw;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *expandViewHeightConst;
@property (nonatomic, strong) IBOutlet UILabel *seperateLineLbl;
@property (nonatomic, strong) IBOutlet UIStackView *headerStackVw;
@property (nonatomic, strong) IBOutlet UIStackView *leftStackVw;
@property (nonatomic, strong) IBOutlet UIStackView *rightStackVw;
@property (nonatomic, strong) IBOutlet UIView *midLineVw;
@property (nonatomic, strong) IBOutlet UIView *secondExpandVw;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *secondExpandViewHeightConst;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *secondHideShowConstant;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *thirdExpVwHeightConst;
@property (nonatomic, strong) IBOutlet UIStackView *secondHideShowStackVw;
@property (nonatomic, strong) IBOutlet UIButton *consumedPlusBtn;
@property (nonatomic, strong) IBOutlet UIButton *plannedArroewBtn;
@property (nonatomic, strong) IBOutlet UIButton *weightPlusBtn;
@property (nonatomic, strong) IBOutlet UIButton *burnedPlusBtn;
@property (nonatomic, strong) IBOutlet UIButton *calPullDwnBtn;
@property (nonatomic, strong) IBOutlet UIButton *macrosPullDwnBtn;
@property (nonatomic, strong) IBOutlet UILabel *nameLbl;
@property (nonatomic, strong) IBOutlet UIButton *weightPullDwnBtn;
@property (nonatomic, strong) IBOutlet UIStackView *weightHideShowStack;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *weightHideShowHeightConst;
@property (nonatomic, strong) IBOutlet UILabel *weightSeperatorLbl;

@property (nonatomic, strong) IBOutlet UIImageView *homeImage;
@property (nonatomic, strong) IBOutlet UIImageView *consumedImage;
@property (nonatomic, strong) IBOutlet UIImageView *plannedImage;
@property (nonatomic, strong) IBOutlet UIImageView *weightImage;
@property (nonatomic, strong) IBOutlet UIImageView *stepsImage;
@property (nonatomic, strong) IBOutlet UIImageView *burnedImage;
@property (nonatomic, strong) IBOutlet UIImageView *workoutImage;
@property (nonatomic, strong) IBOutlet UIImageView *scheduledImage;
@property (nonatomic, strong) IBOutlet UIButton *gotoWorkout;
@property (nonatomic, strong) IBOutlet UIButton *gotoScheduled;

@property (nonatomic, strong) IBOutlet UILabel *actualFatGramsLabel;
@property (nonatomic, strong) IBOutlet UILabel *actualCarbGramsLabel;
@property (nonatomic, strong) IBOutlet UILabel *actualProteinGramsLabel;

@property (nonatomic, strong) IBOutlet UILabel *actualCarbLabel;
@property (nonatomic, strong) IBOutlet UILabel *actualProtLabel;
@property (nonatomic, strong) IBOutlet UILabel *actualFatLabel;

@property (nonatomic, strong) IBOutlet UILabel *lblGoal;
@property (nonatomic, strong) IBOutlet UILabel *lblfoodCalories;
@property (nonatomic, strong) IBOutlet UILabel *lblExerciseCalories;
@property (nonatomic, strong) IBOutlet UILabel *lblNetCalories;
@property (nonatomic, strong) IBOutlet UILabel *lblStart_lbs;
@property (nonatomic, strong) IBOutlet UILabel *lblGoal_lbs;
@property (nonatomic, strong) IBOutlet UILabel *lblToGo_lbs;
@property (nonatomic, strong) IBOutlet UILabel *lblBody_Fat;
@property (nonatomic, strong) IBOutlet UILabel *lblCurrent_BMI;
@property (nonatomic, strong) IBOutlet UILabel *lblSugar;

@property (nonatomic, strong) IBOutlet UILabel *lblConsumed;
@property (nonatomic, strong) IBOutlet UILabel *lblBurned;
@property (nonatomic, strong) IBOutlet UILabel *lblStepsCount;
@property (nonatomic, strong) IBOutlet UILabel *lblProgressBarCurrentWeight;

@property (nonatomic, strong) IBOutlet UIButton *sendMsgButton;
@property (nonatomic, strong) IBOutlet UIButton *sendMailButton;

@property (nonatomic, strong) NSDate *date_currentDate;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSMutableArray *values;
@property (nonatomic, strong) NSMutableArray *cpf_Values;
@property (nonatomic, strong) NSMutableArray *colors;

@property (nonatomic) double recprofitn;
@property (nonatomic) double actual;
@property (nonatomic) double ansis;

@property (nonatomic) double recFat;
@property (nonatomic) double actualfat;
@property (nonatomic) double actans;
    
@property (nonatomic, strong) NSString *strWeightStatus;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *leftStatus;
@property (nonatomic, strong) NSString *weightStatus;

@end

@implementation DietMasterGoViewController

- (instancetype)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:DMReloadDataNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoginStateDidChangeNotification:) name:UserLoginStateDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBadge) name:UpdatingMessageNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad{
  [super viewDidLoad];
  [[self navigationController] setNavigationBarHidden:YES animated:YES];
  self.edgesForExtendedLayout = UIRectEdgeNone;

  NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString: self.cpfLbl.attributedText];
  [text addAttribute:NSForegroundColorAttributeName value:UIColorFromHexString(@"#C15F6E") range:NSMakeRange(0, 1)];
  [text addAttribute:NSForegroundColorAttributeName value:UIColorFromHexString(@"#64BB60") range:NSMakeRange(4, 1)];
  [text addAttribute:NSForegroundColorAttributeName value:UIColorFromHexString(@"#0095B8") range:NSMakeRange(8, 1)];
  [self.cpfLbl setAttributedText: text];

  [self setShadowForViews];
  [self setColorsForViews];
  [self changeImageColors];
  [self plusBtnColor];

  self.circleHomeView.layer.cornerRadius = 35;
  self.circleHomeView.layer.masksToBounds = YES;

  self.hideShowStack.hidden = true;
  self.secondHideShowStackVw.hidden = true;

  self.status = @"first";
  self.leftStatus = @"new";
  self.weightStatus = @"up";

  self.nameLbl.textColor = AppConfiguration.headerTextColor;
  // Adjust button colors.
  UIImage *chatImage = self.sendMsgButton.imageView.image;
  chatImage = [chatImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  [self.sendMsgButton setImage:chatImage forState:UIControlStateNormal];
  UIImage *emailImage = self.sendMailButton.imageView.image;
  emailImage = [emailImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  [self.sendMailButton setImage:emailImage forState:UIControlStateNormal];
  [self.sendMsgButton setTintColor:AppConfiguration.headerTextColor];
  [self.sendMailButton setTintColor:AppConfiguration.headerTextColor];

  [UIView animateWithDuration:0.25 animations:^{
    self.hideShowConstant.constant = 0;
    self.secondHideShowConstant.constant = 0;
    self.weightHideShowHeightConst.constant = 0;

    self.expandViewHeightConst.constant = 125;
    self.secondExpandViewHeightConst.constant = 125;
    self.weightSeperatorLbl.text = @"";
    self.thirdExpVwHeightConst.constant = 115;
  }];

  self.values = [[NSMutableArray alloc] init];
  self.cpf_Values = [[NSMutableArray alloc] init];

  self.remaining_Pie.dataSource = self;
  self.remaining_Pie.delegate = self;
  self.remaining_Pie.animationEnabled = YES;
  self.remaining_Pie.animationDuration = 0.5;

  self.cpf_Pie.dataSource = self;
  self.cpf_Pie.delegate = self;
  self.cpf_Pie.animationDuration = 0;
  self.cpf_Pie.animationEnabled = YES;
  self.cpf_Pie.internalRadius = 28;
  self.cpf_Pie.sliceColor = UIColor.lightGrayColor;
  self.cpf_Pie.borderPercentage = 0.5;

  self.numberBadge = [[MKNumberBadgeView alloc] init];
  self.numberBadge.translatesAutoresizingMaskIntoConstraints = NO;
  [self.sendMsgButton addSubview:self.numberBadge];
  [self.numberBadge.heightAnchor constraintEqualToConstant:20].active = YES;
  [self.numberBadge.widthAnchor constraintEqualToConstant:20].active = YES;
  [self.numberBadge.centerXAnchor constraintEqualToAnchor:self.sendMsgButton.trailingAnchor constant:-1].active = YES;
  [self.numberBadge.centerYAnchor constraintEqualToAnchor:self.sendMsgButton.topAnchor constant:1].active = YES;
  self.numberBadge.backgroundColor = [UIColor clearColor];
  self.numberBadge.shadow = NO;
  self.numberBadge.font = [UIFont systemFontOfSize:12];
  self.numberBadge.hideWhenZero = YES;

  self.scrollView.backgroundColor = AppConfiguration.headerColor;
  self.view.backgroundColor = AppConfiguration.headerColor;

  self.entireViewDefaultHeight = 850;
  self.entireViewHeightConstraint = [self.entireView.heightAnchor constraintEqualToConstant:self.entireViewDefaultHeight];
  if (AppConfiguration.enableMyMoves) {
    self.entireViewDefaultHeight = 950;
    self.entireViewHeightConstraint.constant = self.entireViewDefaultHeight;
  }
  [self.entireViewHeightConstraint setActive:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIEdgeInsets layoutGuide = self.view.safeAreaInsets;
    self.scrollView.contentOffset = CGPointMake(0, -layoutGuide.top);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    self.hidesBottomBarWhenPushed = true;
    
    int stepsTaken = (int)[[DayDataProvider sharedInstance] getStepsTakenWithDate:nil];
    self.lblStepsCount.text = [NSString stringWithFormat:@"%i", stepsTaken];
    
    [self reloadMessages];
    
    [self.values addObject:[NSNumber numberWithInt:0]];
    [self.values addObject:[NSNumber numberWithInt:0]];
    
    [self.cpf_Values addObject:[NSNumber numberWithDouble:0]];
    [self.cpf_Values addObject:[NSNumber numberWithDouble:0]];
    [self.cpf_Values addObject:[NSNumber numberWithDouble:0]];
    
    self.workoutView.hidden = !AppConfiguration.enableMyMoves;
    self.scheduledView.hidden = !AppConfiguration.enableMyMoves;

    // Body Scanning
    self.bodyScanView.hidden = !AppConfiguration.enableBodyScanning;
    UIView *bodyScanAnchorView = self.stepsView;
    if (AppConfiguration.enableMyMoves) {
      bodyScanAnchorView = self.workoutView;
    }
    self.bodyScanningTopConstraint = [self.bodyScanView.topAnchor constraintEqualToAnchor:bodyScanAnchorView.bottomAnchor constant:20];
    [self.bodyScanningTopConstraint setActive:YES];

    [self updateBadge];
    [self reloadData];
}

- (NSInteger)numberOfSlicesInPieChartView:(MCPieChartView *)pieChartView {
    if (pieChartView == _remaining_Pie) {
        return self.values.count;
    } else if (pieChartView == _cpf_Pie) {
        return self.cpf_Values.count;
    }
    return 0;
}

- (UIImage*)pieChartView:(MCPieChartView *)pieChartView imageForSliceAtIndex:(NSInteger)index {
    return nil;
}

- (UIColor *)pieChartView:(MCPieChartView *)pieChartView colorForSliceAtIndex:(NSInteger)index {
    if (pieChartView == _remaining_Pie) {
        if (index == 0) {
            return [UIColor blackColor]; // Used up fill.
        }
        return UIColorFromHexString(@"#64BB60"); // Green remaining fill.
    } else if (pieChartView == _cpf_Pie) {
        if (self.cpf_Values.count > 1) {
            if (index == 0) {
                return UIColorFromHexString(@"#0095B8");
            } else if(index == 1) {
                return UIColorFromHexString(@"#64BB60");
            } else if(index == 2) {
                return UIColorFromHexString(@"#C15F6E");
            } else {
                return UIColorFromHexString(@"#E8E8E8");
            }
        }
        return UIColorFromHexString(@"#E8E8E8");
    }
    
    return [UIColor whiteColor];
}

- (UIColor*)pieChartView:(MCPieChartView *)pieChartView colorForTextAtIndex:(NSInteger)index {
    return [UIColor clearColor];
}

- (CGFloat)pieChartView:(MCPieChartView *)pieChartView valueForSliceAtIndex:(NSInteger)index {
    if (pieChartView == _remaining_Pie) {
        return [[self.values copy][index] floatValue];
    } else if (pieChartView == _cpf_Pie) {
        return [[self.cpf_Values copy][index] floatValue];
    }
    
    return 0;
}

- (void)buttonStyle:(UIButton *)sender imageToSet:(UIImage *)image {
    UIColor *borderColor = [UIColor darkGrayColor];
    sender.layer.cornerRadius = 15.0f;
    sender.layer.borderColor = borderColor.CGColor;
    sender.layer.borderWidth = 1.0f;
    sender.clipsToBounds = YES;
    
    [sender setImage:image forState:UIControlStateNormal];
    sender.tintColor = [UIColor blackColor];
}

- (void)plusBtnColor {
    [self buttonStyle:_consumedPlusBtn imageToSet:[[UIImage imageNamed:@"Icon feather-plus"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self buttonStyle:_weightPlusBtn imageToSet:[[UIImage imageNamed:@"Icon feather-plus"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self buttonStyle:_plannedArroewBtn imageToSet:[[UIImage imageNamed:@"up_arrow_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self buttonStyle:_gotoWorkout imageToSet:[[UIImage imageNamed:@"up_arrow_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self buttonStyle:_gotoScheduled imageToSet:[[UIImage imageNamed:@"up_arrow_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self buttonStyle:_burnedPlusBtn imageToSet:[[UIImage imageNamed:@"Icon feather-plus"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self buttonStyle:_bodyScanningPlusBtn imageToSet:[[UIImage imageNamed:@"Icon feather-plus"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
}

- (void)shadowView:(UIView *)selectedView {
    selectedView.layer.shadowColor = UIColorFromHexString(@"#d7d7d7").CGColor;
    selectedView.layer.shadowOffset = CGSizeMake(4, 3);
    selectedView.layer.shadowOpacity = 1;
    selectedView.layer.shadowRadius = 2;
    selectedView.layer.masksToBounds = NO;
}

-(void)setShadowForViews {
    [self shadowView:self.firstExpandVw];
    [self shadowView:self.secondExpandVw];
    [self shadowView:self.consumedView];
    [self shadowView:self.sugarView];
    [self shadowView:self.plannedView];
    [self shadowView:self.weightView];
    [self shadowView:self.stepsView];
    [self shadowView:self.burnedView];
    [self shadowView:self.workoutView];
    [self shadowView:self.scheduledView];
    [self shadowView:self.bodyScanView];
}

- (void)setColorsForViews {
    _firstExpandVw.backgroundColor  = [UIColor lightGrayColor];
    _secondExpandVw.backgroundColor = [UIColor lightGrayColor];
    _consumedView.backgroundColor   = [UIColor lightGrayColor];
    _sugarView.backgroundColor      = [UIColor lightGrayColor];
    _plannedView.backgroundColor    = [UIColor lightGrayColor];
    _weightView.backgroundColor     = [UIColor lightGrayColor];
    _stepsView.backgroundColor      = [UIColor lightGrayColor];
    _burnedView.backgroundColor     = [UIColor lightGrayColor];
    _workoutView.backgroundColor    = [UIColor lightGrayColor];
    _scheduledView.backgroundColor  = [UIColor lightGrayColor];
    _bodyScanView.backgroundColor   = [UIColor lightGrayColor];
}

- (void)iconsColor:(UIImageView *)image {
    image.image = [image.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [image setTintColor:AppConfiguration.menuIconColor];
}

- (void)changeImageColors {
    [self iconsColor:self.homeImage];
    [self iconsColor:self.consumedImage];
    [self iconsColor:self.suagrGraphImageVw];
    [self iconsColor:self.plannedImage];
    [self iconsColor:self.weightImage];
    [self iconsColor:self.stepsImage];
    [self iconsColor:self.burnedImage];
    [self iconsColor:self.workoutImage];
    [self iconsColor:self.scheduledImage];
    [self iconsColor:self.bodyScanImage];
    self.headerBlueVw.backgroundColor = AppConfiguration.menuIconColor;
}

#pragma mark Message Actions

- (IBAction)sendMessageBtn:(id)sender {
    MessageViewController *vc = [[MessageViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)sendMailBtn:(id)sender {
    DMAuthManager *authManager = [DMAuthManager sharedInstance];
    DMUser *currentUser = [authManager loggedInUser];

    NSString *appName = AppConfiguration.appNameShort;
    NSString *subjectString = [NSString stringWithFormat:@"%@ App Help & Support", appName];
    NSString *emailTo = currentUser.email1;

    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        [mailComposer setSubject:subjectString];
        [mailComposer setMessageBody:@"" isHTML:NO];
        [mailComposer setToRecipients:@[emailTo]];
        mailComposer.mailComposeDelegate = self;
        [self presentViewController:mailComposer animated:YES completion:nil];
    }
    else {
        NSString *urlString = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@", emailTo, [subjectString encodeStringForURL], [@"" encodeStringForURL]];
        NSURL *mailToURL = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:mailToURL options:@{} completionHandler:^(BOOL success) {
            if (!success) {
                [DMGUtilities showAlertWithTitle:AppConfiguration.appNameShort message:@"There are no Mail accounts configured. You can add or create a Mail account in Settings." inViewController:nil];
            }
        }];
    }
}

#pragma mark Body Scanning Actions

- (IBAction)userTappedBodyScanButton:(id)sender {
  NSLog(@"Button tapped!!");
}


#pragma mark Menu Actions

- (IBAction)addFoodBtn:(id)sender {
    MyLogViewController *vc = [[MyLogViewController alloc] init];
    vc.title = @"My Log";
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)addWeightBtn:(id)sender {
    MyGoalViewController *vc = [[MyGoalViewController alloc] init];
    vc.title = @"My Goal";
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)addExerciseBtn:(id)sender {
    MyLogViewController *vc = [[MyLogViewController alloc] init];
    vc.title = @"My Log";
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)goToMyMealsBtn:(id)sender {
    MealPlanViewController *vc = [[MealPlanViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];

}

- (IBAction)gotoWorkoutBtn:(id)sender {
    MyMovesViewController *vc = [[MyMovesViewController alloc] init];
    [self.navigationController pushViewController:vc animated:NO];
}

- (IBAction)gotoScheduledBtn:(id)sender {
    MyMovesViewController *vc = [[MyMovesViewController alloc] init];
    vc.title = @"MyMovesViewController";
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:NO] ;
}

- (IBAction)expandBtnAvtion:(id)sender {
    _hideShowStack.hidden = NO;
    
    if([self.status isEqualToString:@"first"])
    {
        [UIView transitionWithView:_firstExpandVw duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.hideShowConstant.constant = 130;
            self.expandViewHeightConst.constant = 262;
            self.entireViewHeightConstraint.constant = self.entireViewHeightConstraint.constant + 125;
        } completion:nil];
        
        self.status = @"next";
    }
    else if ([self.status isEqualToString:@"next"])
    {
        [UIView transitionWithView:_firstExpandVw duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.hideShowConstant.constant = 0;
            self.expandViewHeightConst.constant = 125;
            self.hideShowStack.hidden = true;
          self.entireViewHeightConstraint.constant = MAX(self.entireViewHeightConstraint.constant - 125, self.entireViewDefaultHeight);
        } completion:NULL];
        
        self.status = @"first";
    }
}

- (IBAction)leftExpandBtnAction:(id)sender {
    self.secondHideShowStackVw.hidden = false;
    self.seperateLineLbl.hidden = FALSE;
    self.headerStackVw.hidden = FALSE;
    self.leftStackVw.hidden = FALSE;
    self.rightStackVw.hidden = FALSE;
    self.midLineVw.hidden = FALSE;

    if([self.leftStatus isEqualToString:@"new"])
    {
        [UIView transitionWithView:self.secondExpandVw duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.secondHideShowConstant.constant = 173;
            self.secondExpandViewHeightConst.constant = 262;
            self.entireViewHeightConstraint.constant = self.entireViewHeightConstraint.constant + 125;
        } completion:NULL];
        
        self.leftStatus = @"old";
    }
    else if ([self.leftStatus isEqualToString:@"old"])
    {
        [UIView transitionWithView:_secondExpandVw duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.secondHideShowConstant.constant = 0;
            self.secondHideShowStackVw.hidden = true;
            self.secondExpandViewHeightConst.constant = 125;
            self.entireViewHeightConstraint.constant = MAX(self.entireViewHeightConstraint.constant - 125, self.entireViewDefaultHeight);
        } completion:NULL];
        self.leftStatus = @"new";
    }
}

- (IBAction)weightExpBtnAction:(id)sender {
    self.weightHideShowStack.hidden = false;
    self.seperateLineLbl.hidden = FALSE;
    self.headerStackVw.hidden = FALSE;
    self.leftStackVw.hidden = FALSE;
    self.rightStackVw.hidden = FALSE;
    self.midLineVw.hidden = FALSE;
    
    if([self.weightStatus isEqualToString:@"up"])
    {
        [UIView transitionWithView:self.weightView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.weightHideShowHeightConst.constant = 115;
            self.thirdExpVwHeightConst.constant = 250;
            self.entireViewHeightConstraint.constant = self.entireViewHeightConstraint.constant + 125;
        } completion:NULL];
        self.weightSeperatorLbl.text = @"- - - - - - - - - - - - - - - - -";
        self.weightStatus = @"down";
    }
    else if ([self.weightStatus isEqualToString:@"down"])
    {
        [UIView transitionWithView:self.weightView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.thirdExpVwHeightConst.constant = 115;
            self.weightHideShowHeightConst.constant = 0;
            self.entireViewHeightConstraint.constant = MAX(self.entireViewHeightConstraint.constant - 125, self.entireViewDefaultHeight);
        } completion:NULL];
        self.weightSeperatorLbl.text = @"";
        self.weightStatus = @"up";
    }
}

-(void)rotateButtonImage:(UIButton *)button {
    [UIView animateWithDuration:0.2 animations:^{
        if (CGAffineTransformEqualToTransform(button.transform, CGAffineTransformIdentity)) {
            button.transform = CGAffineTransformMakeRotation(M_PI * 0.999);
        } else {
            button.transform = CGAffineTransformIdentity;
        }
    }];
}

- (void)updateBadge {
    if ([NSThread isMainThread]) {
        DMMessagesDataProvider *provider = [[DMMessagesDataProvider alloc] init];
        self.numberBadge.value = [provider unreadMessageCount];
        [UIApplication sharedApplication].applicationIconBadgeNumber = self.numberBadge.value;
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateBadge];
        });
    }
}

- (void)reloadMessages {
    DMMessagesDataProvider *provider = [[DMMessagesDataProvider alloc] init];
    self.numberBadge.value = [provider unreadMessageCount];
    
    UserDataFetcher *fetcher = [[UserDataFetcher alloc] init];
    [fetcher getMessagesWithCompletion:^(NSArray<DMMessage *> *messages, NSError *error) {
        if (!error) {
            [self updateBadge];
        }
    }];
}

- (void)userLoginStateDidChangeNotification:(NSNotification *)notification {
    if ([NSThread isMainThread]) {
        [self reloadMessages];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self userLoginStateDidChangeNotification:notification];
        });
    }
}

- (IBAction)showGroceryList:(id) sender {
    FoodsList *flController = [[FoodsList alloc] init];
    [self.navigationController pushViewController:flController animated:YES];
}

-(IBAction)showManageFoods:(id) sender {
    
}

#pragma mark - WorkOutList

- (void)getWorkoutListFailed:(NSString *)failedMessage {
}

- (void)getWorkoutListFinished:(NSDictionary *)responseDict {
}

#pragma mark - Help and Support Methods

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    
    NSString *title = nil;
    NSString *message = nil;
    switch (result) {
        case MFMailComposeResultCancelled:
            title = @"Cancelled";
            message = @"Email was cancelled.";
            break;
        case MFMailComposeResultSaved:
            title = @"Saved";
            message = @"Email was saved as a draft.";
            break;
        case MFMailComposeResultSent:
            title = @"Success!";
            message = @"Email was sent successfully.";
            break;
        case MFMailComposeResultFailed:
            title = @"Error";
            message = @"Email was not sent.";
            break;
        default:
            title = @"Error";
            message = @"Email was not sent.";
            break;
    }

    [DMGUtilities showAlertWithTitle:title message:message inViewController:nil];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)reloadData {
    if ([NSThread isMainThread]) {
        DMAuthManager *authManager = [DMAuthManager sharedInstance];
        DMUser *currentUser = [authManager loggedInUser];
        if (!currentUser) {
            self.nameLbl.text = @"";
            return;
        }
        NSString *name = [NSString stringWithFormat: @"Hi, %@!", currentUser.firstName];
        self.nameLbl.text = name;
        [self loadData];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData];
        });
    }
}

- (void)loadData {
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
        return;
    }
    
    DayDataProvider *dayProvider = [DayDataProvider sharedInstance];
    DMUser *currentUser = [[DMAuthManager sharedInstance] loggedInUser];

    double totalCalories = [dayProvider getTotalCaloriesConsumedWithDate:nil].doubleValue;
    double sugarGrams = [dayProvider getTotalSugarGramsWithDate:nil].doubleValue;
    double sugarCalories = [dayProvider getTotalSugarCaloriesWithDate:nil].doubleValue;

    self.lblSugar.text = [NSString stringWithFormat:@"%.fg",sugarGrams];
    
    // If sugar radio is > 10%, color it red.
    if ((sugarCalories / totalCalories) > .1) {
        _suagrGraphImageVw.image = [_suagrGraphImageVw.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_suagrGraphImageVw setTintColor:[UIColor redColor]];
    } else {
        _suagrGraphImageVw.image = [_suagrGraphImageVw.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_suagrGraphImageVw setTintColor:AppConfiguration.menuIconColor];
    }
            
    self.lblGoal_lbs.text = [currentUser weightGoalLocalizedString];
    self.lblToGo_lbs.text = [dayProvider getLocalizedRemainingWeightString];
    self.lblStart_lbs.text = [dayProvider getLocalizedStartingWeightString];
    self.lblProgressBarCurrentWeight.text = [dayProvider getLocalizedCurrentWeightString];
        
    double netCalories = [dayProvider getCurrentBMR].doubleValue - totalCalories;
    self.lblGoal.text = [NSString stringWithFormat:@"%.0f", netCalories];

    double bodyFatPercentage = [dayProvider getCurrentBodyFatPercentage].doubleValue;
    self.lblBody_Fat.text = [NSString stringWithFormat:@"Body Fat: %.1f%%", bodyFatPercentage];
    self.lblCurrent_BMI.text = [NSString stringWithFormat:@"BMI: %.1f", [dayProvider getCurrentBMI].doubleValue];

    [self updateCalorieTotal];
}

- (void)updateCalorieTotal {
    DayDataProvider *dayProvider = [DayDataProvider sharedInstance];

    int caloriesRemaining = [dayProvider getTotalCaloriesRemainingWithDate:nil].intValue;
    int userBMR = dayProvider.getCurrentBMR.intValue;
    [self.values removeAllObjects];
    [self.values addObject:@(userBMR - caloriesRemaining)];
    [self.values addObject:@(caloriesRemaining)];
    [self.remaining_Pie reloadData];

    NSString *burnedCaloriesString = [dayProvider getCaloriesBurnedViaExerciseStringWithDate:nil];
    NSString *consumedString = [dayProvider getTotalCaloriesConsumedStringWithDate:nil];

    // Summary square.
    self.lblGoal.text = [dayProvider getCurrentBMRString];
    self.lblfoodCalories.text = [NSString stringWithFormat:@"+%@", consumedString];
    self.lblExerciseCalories.text = [NSString stringWithFormat:@"-%@", burnedCaloriesString];
    self.lblNetCalories.text = [dayProvider getTotalCaloriesRemainingStringWithDate:nil];
    
    // For the "MyLog" and "Burned" squares.
    self.lblConsumed.text = consumedString;
    self.lblBurned.text = burnedCaloriesString;

    // Now lay out the chart. We'll use whole numbers because I believe there's a bug
    // with the chart when you're using decimals.
    // Get total calories consumed.
    double totalPercentage = [dayProvider getTotalCaloriesConsumedWithDate:nil].doubleValue;
    NSMutableArray *cpfTempArray = [NSMutableArray array];
    if (totalPercentage <= 0) {
        [cpfTempArray addObject:@(100)];
        self.c_PercentageLbl.text = @"0";
        self.p_PercentageLbl.text = @"/0/";
        self.f_PercentageLbl.text = @"0";
    } else {
        double fatCalories = [dayProvider getTotalFatCaloriesWithDate:nil].doubleValue;
        double proteinCalories = [dayProvider getTotalProteinCaloriesWithDate:nil].doubleValue;
        double carbCalories = [dayProvider getTotalCarbCaloriesWithDate:nil].doubleValue;
        // Percentages.
        double fatGramActualPercent = roundf((fatCalories / totalPercentage) * 100);
        double proteinGramActualPercent = roundf((proteinCalories / totalPercentage) * 100);
        double carbsGramActualPercent = roundf((carbCalories / totalPercentage) * 100);
        // Check for invalid numbers.
        if (carbsGramActualPercent < 0 || isnan(carbsGramActualPercent)) {
            carbsGramActualPercent = 0;
            self.c_PercentageLbl.text = @"0";
        } else {
            self.c_PercentageLbl.text = [@(carbsGramActualPercent) stringValue];
        }
        if (proteinGramActualPercent < 0 || isnan(proteinGramActualPercent)) {
            proteinGramActualPercent = 0;
            self.p_PercentageLbl.text = @"/0/";
        } else {
            self.p_PercentageLbl.text = [NSString stringWithFormat: @"/%@/", @(proteinGramActualPercent)];
        }
        if (fatGramActualPercent < 0 || isnan(fatGramActualPercent)) {
            fatGramActualPercent = 0;
            self.f_PercentageLbl.text = @"0";
        } else {
            self.f_PercentageLbl.text = [@(fatGramActualPercent) stringValue];
        }
        [cpfTempArray addObject:@(fatGramActualPercent)];
        [cpfTempArray addObject:@(proteinGramActualPercent)];
        [cpfTempArray addObject:@(carbsGramActualPercent)];
    }

    [self.cpf_Values removeAllObjects];
    [self.cpf_Values addObjectsFromArray:cpfTempArray];
    [self.cpf_Pie reloadData];
    // Call reload again because there seems to be a bug in pie charts
    // with text in center.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.cpf_Pie reloadData];
    });

    // Display the consumed grams for the day.
    self.actualCarbLabel.text = [dayProvider getCarbGramsStringWithDate:[NSDate date]];
    self.actualProtLabel.text = [dayProvider getProteinGramsStringWithDate:[NSDate date]];
    self.actualFatLabel.text = [dayProvider getFatGramsStringWithDate:[NSDate date]];
    
    // Note, ACTUAL here means "Recommended" for the labels below.
    // The variable names are incorrect.
    self.actualCarbGramsLabel.text = [dayProvider getCarbGramsStringWithDate:nil];
    self.actualProteinGramsLabel.text = [dayProvider getProteinGramsStringWithDate:nil];
    self.actualFatGramsLabel.text = [dayProvider getFatGramsStringWithDate:nil];
}

@end
