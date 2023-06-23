#import "DietMasterGoViewController.h"

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "DietmasterEngine.h"
#import "MCPieChartView.h"
#import "MCSliceLayer.h"
#import "MBCircularProgressBarView.h"
#import "GroceryListViewController.h"
#import "FoodsList.h"
#import "MessageViewController.h"
#import "MKNumberBadgeView.h"
#import "MyLogViewController.h"
#import "MyGoalViewController.h"
#import "MealPlanViewController.h"
#import "MCNewCustomLayeredView+MCCustomLayeredViewSubclass.h"
#import "MyMovesWebServices.h"
#import "MyMovesViewController.h"
#import "NSString+Encode.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

@interface DietMasterGoViewController() <MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, MCPieChartViewDataSource, MCPieChartViewDelegate>

@property (nonatomic, strong) MyMovesWebServices *soapWebService;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
/// The view that's within the scrollView.
@property (nonatomic, strong) IBOutlet UIView *entireView;

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
@property (nonatomic, strong) IBOutlet UIButton *sendMsgBtnOutlet;
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

@property (nonatomic, strong) NSDate *date_currentDate;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic) int num_BMR;
@property (nonatomic, strong) NSMutableArray *values;
@property (nonatomic, strong) NSMutableArray *cpf_Values;
@property (nonatomic, strong) NSMutableArray *colors;

@property (nonatomic) double num_Calories;
@property (nonatomic) double num_totalCalories;
@property (nonatomic) double num_totalCaloriesBurned;
@property (nonatomic) double num_totalCaloriesBurnedTracked;
@property (nonatomic) double num_totalCaloriesRemaining;

@property (nonatomic) double actualCarb;
@property (nonatomic) double recCarb;
@property (nonatomic) double ansactualCarb;

@property (nonatomic) double recprofitn;
@property (nonatomic) double actual;
@property (nonatomic) double ansis;

@property (nonatomic) double recFat;
@property (nonatomic) double actualfat;
@property (nonatomic) double actans;

@property (nonatomic) double totalSugar;
@property (nonatomic) double totalSugarValue;
@property (nonatomic) double totalFat;
@property (nonatomic) double totalProtein;
@property (nonatomic) double totalCarbs;
@property (nonatomic) double currentWeight;
@property (nonatomic) double startWeight;
@property (nonatomic) double currentHeight;
    
@property (nonatomic, strong) NSString *strWeightStatus;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *leftStatus;
@property (nonatomic, strong) NSString *weightStatus;

@end

@implementation DietMasterGoViewController

- (instancetype)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString: self.cpfLbl.attributedText];
    [text addAttribute:NSForegroundColorAttributeName value:UIColorFromHex(0xC15F6E) range:NSMakeRange(0, 1)];
    [text addAttribute:NSForegroundColorAttributeName value:UIColorFromHex(0x64BB60) range:NSMakeRange(4, 1)];
    [text addAttribute:NSForegroundColorAttributeName value:UIColorFromHex(0x0095B8) range:NSMakeRange(8, 1)];
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

    [UIView animateWithDuration:0.25 animations:^{
        self.hideShowConstant.constant = 0;
        self.secondHideShowConstant.constant = 0;
        self.weightHideShowHeightConst.constant = 0;

        self.expandViewHeightConst.constant = 125;
        self.secondExpandViewHeightConst.constant = 125;
        self.weightSeperatorLbl.text = @"";
        self.thirdExpVwHeightConst.constant = 115;
    }];
    
    NSDictionary* userDefaultsValuesDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSNumber numberWithBool:YES], @"LoggedExeTracking",
                                            nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsValuesDict];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"ReloadData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoginFinished:) name:@"UserLoginFinished" object:nil];
      
    
    self.values = [[NSMutableArray alloc] init];
    self.cpf_Values = [[NSMutableArray alloc] init];

    self.remaining_Pie.dataSource = self;
    self.remaining_Pie.delegate = self;
    self.remaining_Pie.animationDuration = 0.5;
    
    self.cpf_Pie.dataSource = self;
    self.cpf_Pie.delegate = self;
    self.cpf_Pie.animationDuration = 0.5;
    self.cpf_Pie.internalRadius = 28;
    self.cpf_Pie.sliceColor = UIColor.lightGrayColor;
    self.cpf_Pie.borderPercentage = 0.5;

    self.numberBadge = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(self.sendMsgBtnOutlet.frame.origin.x + 20, self.sendMsgBtnOutlet.frame.origin.y - 10, 20, 20)];
    self.numberBadge.backgroundColor = [UIColor clearColor];
    self.numberBadge.shadow = NO;
    self.numberBadge.font = [UIFont systemFontOfSize:12];
    self.numberBadge.hideWhenZero = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIEdgeInsets layoutGuide = self.view.safeAreaInsets;
    self.scrollView.contentOffset = CGPointMake(0, layoutGuide.top - layoutGuide.bottom);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    self.hidesBottomBarWhenPushed = true;
    
    //NSInteger minutesExercised = [DataProvider sharedInstance].minutesExercisedToday;
    self.lblStepsCount.text = [NSString stringWithFormat:@"%li", 999];
    
    [self.sendMsgBtnOutlet addSubview:self.numberBadge];
    [self reloadMessages];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBadge) name:UpdatingMessageNotification object:nil];
    
    [self.values addObject:[NSNumber numberWithInt:0]];
    [self.values addObject:[NSNumber numberWithInt:0]];
    
    [self.cpf_Values addObject:[NSNumber numberWithDouble:0]];
    [self.cpf_Values addObject:[NSNumber numberWithDouble:0]];
    [self.cpf_Values addObject:[NSNumber numberWithDouble:0]];
    
    if (![[[NSUserDefaults standardUserDefaults] stringForKey:@"switch"] isEqual:@"MyMoves"])
    {
        self.workoutView.hidden = YES;
        self.scheduledView.hidden = YES;
    }
    
    [self reloadData];
}

- (NSInteger)numberOfSlicesInPieChartView:(MCPieChartView *)pieChartView {
    if (pieChartView == _remaining_Pie)
    {
        return self.values.count;
    }
    else if (pieChartView == _cpf_Pie)
    {
        return self.cpf_Values.count;
    }
    
    return 0;
}

- (UIImage*)pieChartView:(MCPieChartView *)pieChartView imageForSliceAtIndex:(NSInteger)index
{
    return nil;
}

- (UIColor *)pieChartView:(MCPieChartView *)pieChartView colorForSliceAtIndex:(NSInteger)index
{
    if (pieChartView == _remaining_Pie)
    {
        if (index == 0)
        {
            return AccentColor
        }
        else
        {
            return UIColorFromHex(0xE8E8E8);
        }
    }
    else if (pieChartView == _cpf_Pie)
    {
        if (index == 0)
        {
            return UIColorFromHex(0x0095B8);
        }
        else if(index == 1)
        {
            return UIColorFromHex(0x64BB60);
        }
        else if(index == 2)
        {
            return UIColorFromHex(0xC15F6E);
        }
        else
        {
            return UIColorFromHex(0xE8E8E8);
        }
    }
    
    return [UIColor whiteColor];
}

- (UIColor*)pieChartView:(MCPieChartView *)pieChartView colorForTextAtIndex:(NSInteger)index
{
    return [UIColor clearColor];
}

- (CGFloat)pieChartView:(MCPieChartView *)pieChartView valueForSliceAtIndex:(NSInteger)index {
    if (pieChartView == _remaining_Pie)
    {
        return [[self.values objectAtIndex:index] floatValue];
    }
    else if (pieChartView == _cpf_Pie)
    {
        return [[self.cpf_Values objectAtIndex:index] floatValue];
    }
    
    return 0;
}

-(void)buttonStyle:(UIButton *)sender imageToSet:(UIImage *)image {
    UIColor *borderColor = PrimaryDarkColor
    sender.layer.cornerRadius = 15.0f;
    sender.layer.borderColor = borderColor.CGColor;
    sender.layer.borderWidth = 1.0f;
    sender.clipsToBounds = YES;
    
    [sender setImage:image forState:UIControlStateNormal];
    sender.tintColor = PrimaryDarkColor;
}

-(void)plusBtnColor {
    [self buttonStyle:_consumedPlusBtn imageToSet:[[UIImage imageNamed:@"Icon feather-plus"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self buttonStyle:_weightPlusBtn imageToSet:[[UIImage imageNamed:@"Icon feather-plus"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self buttonStyle:_plannedArroewBtn imageToSet:[[UIImage imageNamed:@"up_arrow_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self buttonStyle:_gotoWorkout imageToSet:[[UIImage imageNamed:@"up_arrow_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self buttonStyle:_gotoScheduled imageToSet:[[UIImage imageNamed:@"up_arrow_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self buttonStyle:_burnedPlusBtn imageToSet:[[UIImage imageNamed:@"Icon feather-plus"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
}

-(void)shadowView:(UIView *)selectedView {
    selectedView.layer.shadowColor = UIColorFromHex(0xd7d7d7).CGColor;
    selectedView.layer.shadowOffset = CGSizeMake(8, 3);
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
}

-(void)setColorsForViews {
    _firstExpandVw.backgroundColor  = PrimaryDarkColor
    _secondExpandVw.backgroundColor = PrimaryDarkColor
    _consumedView.backgroundColor   = PrimaryDarkColor
    _sugarView.backgroundColor      = PrimaryDarkColor
    _plannedView.backgroundColor    = PrimaryDarkColor
    _weightView.backgroundColor     = PrimaryDarkColor
    _stepsView.backgroundColor      = PrimaryDarkColor
    _burnedView.backgroundColor     = PrimaryDarkColor
    _workoutView.backgroundColor    = PrimaryDarkColor
    _scheduledView.backgroundColor  = PrimaryDarkColor
    _headerBlueVw.backgroundColor = PrimaryColor
    _scrollView.backgroundColor = PrimaryColor
}

-(void)iconsColor:(UIImageView *)image {
    UIColor *accentColor = PrimaryColor
    image.image = [image.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [image setTintColor:accentColor];
}

-(void)changeImageColors {
    [self iconsColor:_homeImage];
    [self iconsColor:_consumedImage];
    [self iconsColor:_suagrGraphImageVw];
    [self iconsColor:_plannedImage];
    [self iconsColor:_weightImage];
    [self iconsColor:_stepsImage];
    [self iconsColor:_burnedImage];
    [self iconsColor:_workoutImage];
    [self iconsColor:_scheduledImage];
}

#pragma mark Message Actions

- (IBAction)sendMessageBtn:(id)sender {
    MessageViewController *vc = [[MessageViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)sendMailBtn:(id)sender {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:PLIST_NAME];
    NSDictionary *appDefaults = [[NSDictionary alloc] initWithContentsOfFile:finalPath];
    NSString *subjectString = [NSString stringWithFormat:@"%@ App Help & Support", [appDefaults valueForKey:@"app_name_short"]];
    NSString *emailTo = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"LoginEmail"]];

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
                [DMGUtilities showAlertWithTitle:APP_NAME message:@"There are no Mail accounts configured. You can add or create a Mail account in Settings." inViewController:nil];
            }
        }];
    }
}

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
    vc.workoutClickedFromHome = @"clicked";
    [self.navigationController pushViewController:vc animated:false];
}

- (IBAction)gotoScheduledBtn:(id)sender {
    MyMovesViewController *vc = [[MyMovesViewController alloc] init];
    vc.title = @"MyMovesViewController";
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:false] ;
}

- (IBAction)expandBtnAvtion:(id)sender {
    _hideShowStack.hidden = false;
    
    if([self.status isEqualToString:@"first"])
    {
        [UIView transitionWithView:_firstExpandVw duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.hideShowConstant.constant = 130;
            self.expandViewHeightConst.constant = 262;
        } completion:nil];
        
        self.status = @"next";
    }
    else if ([self.status isEqualToString:@"next"])
    {
        [UIView transitionWithView:_firstExpandVw duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.hideShowConstant.constant = 0;
            self.expandViewHeightConst.constant = 125;
            self.hideShowStack.hidden = true;
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
        } completion:NULL];
        
        self.leftStatus = @"old";
    }
    else if ([self.leftStatus isEqualToString:@"old"])
    {
        [UIView transitionWithView:_secondExpandVw duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.secondHideShowConstant.constant = 0;
            self.secondHideShowStackVw.hidden = true;
            self.secondExpandViewHeightConst.constant = 125;
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
        } completion:NULL];
        self.weightSeperatorLbl.text = @"- - - - - - - - - - - - - - - - -";
        self.weightStatus = @"down";
    }
    else if ([self.weightStatus isEqualToString:@"down"])
    {
        [UIView transitionWithView:self.weightView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.thirdExpVwHeightConst.constant = 115;
            self.weightHideShowHeightConst.constant = 0;
            
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

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.values removeAllObjects];
}

- (void)updateBadge {
    self.numberBadge.value = [[DietmasterEngine sharedInstance] unreadMessageCount];
    [UIApplication sharedApplication].applicationIconBadgeNumber = self.numberBadge.value;
}

- (void)reloadMessages {
    self.numberBadge.value = [[DietmasterEngine sharedInstance] unreadMessageCount];
    
    DataFetcher *fetcher = [[DataFetcher alloc] init];
    [fetcher getMessagesWithCompletion:^(NSArray<DMMessage *> *messages, NSError *error) {
        if (!error) {
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

- (void)getBMR {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    NSInteger bmrValue = [dietmasterEngine getBMR];
    self.num_BMR = (int)bmrValue;
    
    [self updateCalorieTotal];
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
}

#pragma mark DATA LOADING METHODS
-(void)reloadData {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([prefs valueForKey:@"userid_dietmastergo"] > 0) {
        [self performSelector:@selector(loadData) withObject:nil afterDelay:0.25];
        [self performSelector:@selector(loadExerciseData) withObject:nil afterDelay:0.15];
    }
    NSString *firstName = [prefs valueForKey:@"FirstName_dietmastergo"];
    NSString *name = [NSString stringWithFormat: @"Hi, %@!",firstName];
    self.nameLbl.text = name;
}

-(void)loadData {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
        
    }
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    NSDate* date_homeDate = [NSDate date];
    NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
    [dateFormat setTimeZone:systemTimeZone];
    NSString *date_Today = [dateFormat stringFromDate:date_homeDate];
    
    self.num_totalCalories = 0;
    self.totalFat = 0.0;
    self.totalCarbs = 0.0;
    self.totalProtein = 0.0;
    double difference = 0.0;
        
    NSString *query = [NSString stringWithFormat: @"SELECT Food_Log.MealID, Food_Log.MealDate, Food_Log_Items.MealCode, Food_Log_Items.FoodID, Food_Log_Items.MeasureID, Food_Log_Items.NumberOfServings, Food.FoodKey, Food.Name, Food.Calories, Food.Fat, Food.Carbohydrates, Food.Protein,Food.Sugars, FoodMeasure.GramWeight, Food.ServingSize FROM Food_Log INNER JOIN Food_Log_Items ON Food_Log.MealID = Food_Log_Items.MealID INNER JOIN Food ON Food.FoodKey = Food_Log_Items.FoodID INNER JOIN FoodMeasure ON FoodMeasure.FoodID = Food.FoodKey WHERE (Food_Log.MealDate BETWEEN DATETIME('%@ 00:00:00') AND DATETIME('%@ 23:59:59')) AND Food_Log_Items.MeasureID = FoodMeasure.MeasureID ORDER BY Food_Log_Items.MealCode ASC", date_Today, date_Today];

    FMResultSet *rs = [db executeQuery:query];
    self.totalSugarValue = 0;
    double totalSugarCalories = 0;
    while ([rs next]) {
        int fatGrams = [rs doubleForColumn:@"Fat"];
        double sugar = [rs doubleForColumn:@"Sugars"];
        double sugarValue = sugar * [rs doubleForColumn:@"NumberOfServings"] * ([rs doubleForColumn:@"GramWeight"] / 100 / [rs doubleForColumn:@"ServingSize"]);
        totalSugarCalories += (sugarValue * 3.8);
        self.totalSugarValue += sugarValue;
        
        int totalFatCalories = [rs doubleForColumn:@"NumberOfServings"] * ((fatGrams * 9.0) * ([rs doubleForColumn:@"GramWeight"] / 100) / [rs doubleForColumn:@"ServingSize"]);
        self.totalFat = self.totalFat + totalFatCalories;
        
        int carbGrams = [rs doubleForColumn:@"Carbohydrates"];
        int totalCarbCalories = [rs doubleForColumn:@"NumberOfServings"] * ((carbGrams * 4.0) * ([rs doubleForColumn:@"GramWeight"] / 100) / [rs doubleForColumn:@"ServingSize"]);
        self.totalCarbs = self.totalCarbs + totalCarbCalories;
        
        int proteinGrams = [rs doubleForColumn:@"Protein"];
        
        int totalProteinCalories = [rs doubleForColumn:@"NumberOfServings"] * ((proteinGrams * 4.0) * ([rs doubleForColumn:@"GramWeight"] / 100) / [rs doubleForColumn:@"ServingSize"]);
        self.totalProtein = self.totalProtein + totalProteinCalories;
        
        int totalCalories = [rs doubleForColumn:@"NumberOfServings"] * (([rs doubleForColumn:@"Calories"] * ([rs doubleForColumn:@"GramWeight"] / 100)) / [rs doubleForColumn:@"ServingSize"]);
        
        self.num_totalCalories += totalCalories;
    }
   
    NSString *sugarStr = [NSString stringWithFormat:@"%.1f", self.totalSugarValue];
    self.lblSugar.text = [NSString stringWithFormat:@"%@g",sugarStr];
    
    if (totalSugarCalories / self.num_totalCalories > .1) //if sugar radio is > 10%
    {
        _suagrGraphImageVw.image = [_suagrGraphImageVw.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_suagrGraphImageVw setTintColor:[UIColor redColor]];
    }
    else
    {
        UIColor *accentColor = PrimaryColor
        _suagrGraphImageVw.image = [_suagrGraphImageVw.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_suagrGraphImageVw setTintColor:accentColor];
    }
    
    [rs close];
    
    NSString *getGoalSQL = @"SELECT weight_goal, Goals ,Height, gender, GoalStartDate FROM User";
    
    int intGoalWeight = 0;
    int intWeightGoal = 0;
    int gender = -1;
    NSString *goalStartDate;
    
    rs = [db executeQuery:getGoalSQL];
    while ([rs next]) {
        gender = [rs doubleForColumn:@"Gender"];
        intGoalWeight = [rs intForColumn:@"Goals"];
        intWeightGoal = [rs intForColumn:@"weight_goal"];
        self.currentHeight = [rs doubleForColumn:@"Height"];
        goalStartDate = [[rs stringForColumn:@"GoalStartDate"] componentsSeparatedByString:@" "][0];
    }
    
    dietmasterEngine.userHeight = [NSNumber numberWithDouble:self.currentHeight];
    dietmasterEngine.userGender = gender;
    
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"isKgs"] boolValue]) {
        self.lblGoal_lbs.text = [NSString stringWithFormat:@"%.1d lbs",intWeightGoal];
        self.lblToGo_lbs.text = [NSString stringWithFormat:@"%g lbs",(self.currentWeight - intWeightGoal)];
    }
    else {
        self.lblGoal_lbs.text = [NSString stringWithFormat:@"%d Kgs",intWeightGoal];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d.00",intWeightGoal] forKey:@"GoalWeight"];
    
    if (intGoalWeight == 0) {
        self.strWeightStatus = @"Lost: ";
    }
    else if (intGoalWeight == 1) {
        self.strWeightStatus = @"Maintained: ";
    }
    else if (intGoalWeight == 2) {
        self.strWeightStatus = @"Gained: ";
    }
    else {
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
        self.currentWeight = [rs doubleForColumn:@"weight"];
    }
    
    if (self.currentWeight == 0) {
        NSString *getWeightSQL = @"SELECT weight FROM weightlog where logtime in (select max(logtime) from weightlog WHERE deleted = 1) AND deleted = 1";
        rs = [db executeQuery:getWeightSQL];
        while ([rs next]) {
            self.currentWeight = [rs doubleForColumn:@"weight"];
        }
    }
    
    NSString *getStartWeight = [NSString stringWithFormat:@"SELECT weight FROM weightlog where logtime like '%%%@%%' AND deleted = 1", goalStartDate];
    rs = [db executeQuery:getStartWeight];
    while ([rs next]) {
        self.startWeight = [rs doubleForColumn:@"weight"];
    }
    
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"isKgs"] boolValue]) {
        self.lblStart_lbs.text = [NSString stringWithFormat:@"%g lbs", self.startWeight];
    }
    else {
        self.lblStart_lbs.text = [NSString stringWithFormat:@"%g Kgs", self.startWeight];
    }
    
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"isKgs"] boolValue]) {
        self.lblProgressBarCurrentWeight.text = [NSString stringWithFormat:@"%g lbs.", self.currentWeight];
    }
    else {
        self.lblProgressBarCurrentWeight.text = [NSString stringWithFormat:@"%g Kgs", self.currentWeight];
    }
    
    double progressValue = 0.0;
    
    if (self.startWeight < intWeightGoal) {
        //weight gain
        difference = (int) (intWeightGoal - self.startWeight);
    } else if (self.startWeight > intWeightGoal) {
        //weight loss
        difference = (int) (self.startWeight - intWeightGoal);
    } else if (self.startWeight == intWeightGoal) {
        difference = (int) (self.startWeight - 0);
    }
    
    progressValue = ((self.startWeight - self.currentWeight) / difference);
    
    dietmasterEngine.currentWeight = [NSNumber numberWithDouble:self.currentWeight];
    
    [self performSelector:@selector(getBMR) withObject:nil afterDelay:0.25];
    
    double netCalories = self.num_BMR - self.num_totalCalories;
    
    self.lblGoal.text = [NSString stringWithFormat:@"%.0f", netCalories];
    [self updateCalorieTotal];
    [self calculateBMI];
    
    NSString *getBodyFatSQL = @"SELECT bodyfat FROM weightlog where logtime in (select max(logtime) from weightlog WHERE deleted = 1)";
    CGFloat bodyFat = 0.0;
    rs = [db executeQuery:getBodyFatSQL];
    while ([rs next]) {
        bodyFat = [rs doubleForColumn:@"bodyfat"];
    }
    self.lblBody_Fat.text = [NSString stringWithFormat:@"Body Fat: %.1f%%", bodyFat];
    [rs close];
    [DMActivityIndicator hideActivityIndicator];
}

#warning TODO: This is unused?
- (void)caloriesRemainUpdate {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    double calRecommended = [dietmasterEngine getBMR];
    NSString *remainingCalorieCount = [NSString stringWithFormat:@"%.0f",calRecommended + self.num_totalCaloriesBurned];
}

-(void)loadExerciseData {
    DietmasterEngine *dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
        return;
    }
    BOOL combineTrackingCalories = [[NSUserDefaults standardUserDefaults] boolForKey:@"CalorieTrackingDevice"];
    NSDate* sourceDate = [NSDate date];

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
    [dateFormat setTimeZone:systemTimeZone];
    NSString *date_Today = [dateFormat stringFromDate:sourceDate];
    
    NSString *query = [NSString stringWithFormat:@"SELECT Exercise_Log.Exercise_Log_ID, Exercise_Log.ExerciseID, Exercise_Log.Exercise_Time_Minutes, Exercise_Log.Log_Date, Exercises.ActivityName, Exercises.CaloriesPerHour FROM Exercise_Log INNER JOIN Exercises ON Exercise_Log.ExerciseID = Exercises.ExerciseID WHERE (Exercise_Log.Log_Date BETWEEN DATETIME('%@ 00:00:00') AND DATETIME('%@ 23:59:59')) ORDER BY Log_Date", date_Today, date_Today];
    
    self.num_totalCaloriesBurned = 0;
    self.num_totalCaloriesBurnedTracked = 0;
    
    FMResultSet *rs = [db executeQuery:query];
    
    while ([rs next]) {
        NSNumber *exerciseTimeMinutes = [NSNumber numberWithInt:[rs intForColumn:@"Exercise_Time_Minutes"]];
        NSNumber *caloriesPerHour = [NSNumber numberWithDouble:[rs doubleForColumn:@"CaloriesPerHour"]];
        
        int minutesExercised = [exerciseTimeMinutes intValue];
        double totalCaloriesBurned = ([caloriesPerHour floatValue] / 60) * [dietmasterEngine.currentWeight floatValue] * minutesExercised;
        int exerciseID = [rs intForColumn:@"ExerciseID"];
        
        // Apple watch 274 for step count
        // Apple watch (272) calories apple watch
        if (exerciseID == 257 || exerciseID == 267 || exerciseID == 272 || exerciseID == 275) {
            self.num_totalCaloriesBurnedTracked += minutesExercised;
            if (combineTrackingCalories) {
                self.num_totalCaloriesBurned += minutesExercised;
            }
        } else {
            self.num_totalCaloriesBurned += totalCaloriesBurned;
        }
    }
    
    [rs close];
    
    [self updateCalorieTotal];
    [self calculateBMI];
}

-(void)updateCalorieTotal {
    bool useCaloriesBurned = [[NSUserDefaults standardUserDefaults] boolForKey:@"LoggedExeTracking"] == YES;
    bool useCaloriesBurnedTracked =[[NSUserDefaults standardUserDefaults] boolForKey:@"CalorieTrackingDevice"] == YES;    //if setting is not checked, add tracked callories into burned total to be included in net calculation
    double netCalories = 0;
    CGFloat caloriesREmaining = 0;

    if (useCaloriesBurned) {
        netCalories = self.num_BMR - self.num_totalCalories + self.num_totalCaloriesBurned;
        caloriesREmaining = (self.num_BMR - (self.num_totalCaloriesBurned * -1)) - self.num_totalCalories;
        self.num_totalCaloriesRemaining = self.num_BMR - (self.num_totalCaloriesBurned * -1) - self.num_totalCalories;
    } else {
        if (useCaloriesBurnedTracked) {
            netCalories = self.num_BMR - self.num_totalCalories + self.num_totalCaloriesBurnedTracked;
            caloriesREmaining = (self.num_BMR - (self.num_totalCaloriesBurnedTracked * -1)) - self.num_totalCalories;
            self.num_totalCaloriesRemaining = self.num_BMR - (self.num_totalCaloriesBurnedTracked * -1) - self.num_totalCalories;
        } else {
            netCalories = self.num_BMR - self.num_totalCalories;
            caloriesREmaining = self.num_BMR - self.num_totalCalories;
            self.num_totalCaloriesRemaining = self.num_BMR - self.num_totalCalories;
        }
    }

    if (caloriesREmaining < 0) {
        [self.values removeAllObjects];
        [self.values addObject:[NSNumber numberWithInt:1]];
        [self.values addObject:[NSNumber numberWithInt:(self.num_BMR - 1)]];
        [_remaining_Pie reloadData];
    }
    else {
        [self.values removeAllObjects];
        [self.values addObject:[NSNumber numberWithInt:caloriesREmaining]];
        [self.values addObject:[NSNumber numberWithInt:(self.num_BMR - caloriesREmaining)]];
        [_remaining_Pie reloadData];
    }
    
    AppDel.caloriesremaning = [[NSString stringWithFormat:@"%.0f", caloriesREmaining] doubleValue];
    [self caloriesRemainUpdate];
    
    self.lblGoal.text = [NSString stringWithFormat:@"%i", self.num_BMR];
    self.lblfoodCalories.text = [NSString stringWithFormat:@"+%.0f", self.num_totalCalories];
    self.lblConsumed.text = [NSString stringWithFormat:@"%.0f", self.num_totalCalories];
    
    if (useCaloriesBurned) {
        self.lblExerciseCalories.text = [NSString stringWithFormat:@"-%.0f", self.num_totalCaloriesBurned];
    } else {
        if (useCaloriesBurnedTracked) {
            self.lblExerciseCalories.text = [NSString stringWithFormat:@"-%.0f", self.num_totalCaloriesBurnedTracked];
        } else {
            self.lblExerciseCalories.text = @"-0";
        }
    }
    
    if (!useCaloriesBurnedTracked) {
        self.lblBurned.text = [NSString stringWithFormat:@"%.0f", self.num_totalCaloriesBurned + self.num_totalCaloriesBurnedTracked];
    } else {
        self.lblBurned.text = [NSString stringWithFormat:@"%.0f", self.num_totalCaloriesBurned];
    }

    self.lblNetCalories.text = [NSString stringWithFormat:@"%.0f", netCalories];
    
    double totalPercentage = self.totalFat + self.totalProtein + self.totalCarbs;
    
    CGFloat carbGramActual = self.totalCarbs / 4;
    CGFloat proteinGramActual = self.totalProtein / 4;
    CGFloat fatGramActual = self.totalFat / 9;
    
    //HHT cange start
    CGFloat fatGramActualPrecent = ((self.totalFat / totalPercentage) * 100);
    CGFloat proteinGramActualPrecent = ((self.totalProtein / totalPercentage) * 100);
    CGFloat carbsGramActualPercent = ((self.totalCarbs / totalPercentage) * 100);
  
    NSString* c_percentageStr =  [[NSNumber numberWithInt:carbsGramActualPercent] stringValue];
    NSString* p_percentageStr = [[NSNumber numberWithInt:proteinGramActualPrecent] stringValue];
    NSString* f_percentageStr = [[NSNumber numberWithInt:fatGramActualPrecent] stringValue];
    
    NSString *seperatorStrLeft = @"/";
    NSString *seperatorStrRight = @"/";
    NSString *p_Str = [NSString stringWithFormat: @"%@%@%@",seperatorStrLeft,p_percentageStr,seperatorStrRight];
    
    if (carbsGramActualPercent < 0 || isnan(carbsGramActualPercent)) {
        self.c_PercentageLbl.text = @"0";
    } else {
        self.c_PercentageLbl.text = c_percentageStr;
    }
    
    if (proteinGramActualPrecent < 0 || isnan(proteinGramActualPrecent)) {
        self.p_PercentageLbl.text = @"/0/";
    } else {
        self.p_PercentageLbl.text = p_Str;
    }

    if (fatGramActualPrecent < 0 || isnan(fatGramActualPrecent)) {
        self.f_PercentageLbl.text = @"0";
    } else {
        self.f_PercentageLbl.text = f_percentageStr;
    }
        
    [self.cpf_Values removeAllObjects];
    if isnan(carbsGramActualPercent)
    {
        if isnan(proteinGramActualPrecent)
        {
            if isnan(fatGramActualPrecent)
            {
                [self.cpf_Values addObject:[NSNumber numberWithFloat:0]];
                [self.cpf_Values addObject:[NSNumber numberWithFloat:0]];
                [self.cpf_Values addObject:[NSNumber numberWithFloat:0]];
                [self.cpf_Values addObject:[NSNumber numberWithFloat:100]];
            }
        }
    }
    else
    {
        if (fatGramActualPrecent < 0 && proteinGramActualPrecent < 0 && carbsGramActualPercent < 0) {
                   [self.cpf_Values addObject:[NSNumber numberWithFloat:0]];
                   [self.cpf_Values addObject:[NSNumber numberWithFloat:0]];
                   [self.cpf_Values addObject:[NSNumber numberWithFloat:0]];
                   [self.cpf_Values addObject:[NSNumber numberWithFloat:100]];

       } else {
            [self.cpf_Values addObject:[NSNumber numberWithFloat:fatGramActualPrecent]];
            [self.cpf_Values addObject:[NSNumber numberWithFloat:proteinGramActualPrecent]];
            [self.cpf_Values addObject:[NSNumber numberWithFloat:carbsGramActualPercent]];
            [self.cpf_Values addObject:[NSNumber numberWithFloat:100 - (carbsGramActualPercent + proteinGramActualPrecent + fatGramActualPrecent)]];
        }
    }
    [self.cpf_Pie reloadData];
        
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    NSDictionary *ratioDict = [dietmasterEngine getUserRecommendedRatios];

    CGFloat carbRatioActual = self.totalCarbs / 4;
    CGFloat proteinRatioActual = self.totalProtein / 4;
    CGFloat fatRatioActual = self.totalFat / 9;

    if (([[NSUserDefaults standardUserDefaults] valueForKey:@"ansactualCarb"] == nil) || ([[NSUserDefaults standardUserDefaults] valueForKey:@"recprofitn"] == nil) || ([[NSUserDefaults standardUserDefaults] valueForKey:@"actans"] == nil))
    {
        self.actualCarbLabel.text = [NSString stringWithFormat:@"%.1f",carbRatioActual];
        self.actualProtLabel.text = [NSString stringWithFormat:@"%.1f",proteinRatioActual];
        self.actualFatLabel.text = [NSString stringWithFormat:@"%.1f",fatRatioActual];
    }
    else
    {
        self.actualCarbLabel.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"ansactualCarb"];
        self.actualProtLabel.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"recprofitn"];
        self.actualFatLabel.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"actans"];
    }
    
    CGFloat bmrValue = [dietmasterEngine getBMR];
    
    CGFloat carbRatioRecommended = [[ratioDict valueForKey:@"CarbRatio"] doubleValue] * bmrValue / 4;
    CGFloat proteinRatioRecommended = [[ratioDict valueForKey:@"ProteinRatio"] doubleValue] * bmrValue / 4;
    CGFloat fatRatioRecommended = [[ratioDict valueForKey:@"FatRatio"] doubleValue] * bmrValue / 9;
    
    self.actualCarbGramsLabel.text = [NSString stringWithFormat:@"%.1f", carbRatioRecommended];
    self.actualProteinGramsLabel.text = [NSString stringWithFormat:@"%.1f", proteinRatioRecommended];
    self.actualFatGramsLabel.text = [NSString stringWithFormat:@"%.1f", fatRatioRecommended];
    
    self.recCarb=carbRatioRecommended;
    self.recprofitn=proteinRatioRecommended;
    self.recFat=fatRatioRecommended;
}

- (void)calculateBMI {
    double bodyMassIndex = self.currentWeight / (self.currentHeight * self.currentHeight) * 703;
    self.lblCurrent_BMI.text = [NSString stringWithFormat:@"BMI: %.1f", bodyMassIndex];
}

@end
