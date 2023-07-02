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
#import "MyMovesDataProvider.h"
#import "MyMovesViewController.h"
#import "NSString+Encode.h"
#import "FMDatabase.h"
#import "DMMyLogDataProvider.h"

@interface DietMasterGoViewController() <MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, MCPieChartViewDataSource, MCPieChartViewDelegate>

@property (nonatomic, strong) MyMovesDataProvider *soapWebService;

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"ReloadData" object:nil];
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

    self.nameLbl.textColor = [UIColor blackColor];
    // Adjust button colors.
    UIImage *chatImage = self.sendMsgButton.imageView.image;
    chatImage = [chatImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.sendMsgButton setImage:chatImage forState:UIControlStateNormal];
    UIImage *emailImage = self.sendMailButton.imageView.image;
    emailImage = [emailImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.sendMailButton setImage:emailImage forState:UIControlStateNormal];
    [self.sendMsgButton setTintColor:[UIColor blackColor]];
    [self.sendMailButton setTintColor:[UIColor blackColor]];

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
    self.remaining_Pie.animationDuration = 0.5;
    
    self.cpf_Pie.dataSource = self;
    self.cpf_Pie.delegate = self;
    self.cpf_Pie.animationDuration = 0.5;
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
    
    int stepsTaken = (int)[[DayDataProvider sharedInstance] getStepsTakenWithDate:nil];
    self.lblStepsCount.text = [NSString stringWithFormat:@"%i", stepsTaken];
    
    [self reloadMessages];
    
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
    if (pieChartView == _remaining_Pie)
    {
        if (index == 0)
        {
            return [UIColor blackColor]; // Used up fill.
        }
        else
        {
            return UIColorFromHex(0x64BB60); // Green remaining fill.
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

- (UIColor*)pieChartView:(MCPieChartView *)pieChartView colorForTextAtIndex:(NSInteger)index {
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

- (void)buttonStyle:(UIButton *)sender imageToSet:(UIImage *)image {
    UIColor *borderColor = PrimaryDarkColor
    sender.layer.cornerRadius = 15.0f;
    sender.layer.borderColor = borderColor.CGColor;
    sender.layer.borderWidth = 1.0f;
    sender.clipsToBounds = YES;
    
    [sender setImage:image forState:UIControlStateNormal];
    sender.tintColor = PrimaryDarkColor;
}

- (void)plusBtnColor {
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
    DMAuthManager *authManager = [DMAuthManager sharedInstance];
    DMUser *currentUser = [authManager loggedInUser];

    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:PLIST_NAME];
    NSDictionary *appDefaults = [[NSDictionary alloc] initWithContentsOfFile:finalPath];
    NSString *subjectString = [NSString stringWithFormat:@"%@ App Help & Support", [appDefaults valueForKey:@"app_name_short"]];
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

    double totalCalories = [dayProvider getTotalCaloriesWithDate:nil].doubleValue;
    double sugarGrams = [dayProvider getTotalSugarGramsWithDate:nil].doubleValue;
    double sugarCalories = [dayProvider getTotalSugarCaloriesWithDate:nil].doubleValue;

    NSString *sugarStr = [NSString stringWithFormat:@"%.1f", sugarGrams];
    self.lblSugar.text = [NSString stringWithFormat:@"%@g",sugarStr];
    
    // If sugar radio is > 10%, color it red.
    if ((sugarCalories / totalCalories) > .1) {
        _suagrGraphImageVw.image = [_suagrGraphImageVw.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_suagrGraphImageVw setTintColor:[UIColor redColor]];
    } else {
        UIColor *accentColor = PrimaryColor
        _suagrGraphImageVw.image = [_suagrGraphImageVw.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_suagrGraphImageVw setTintColor:accentColor];
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
    DMUser *currentUser = [[DMAuthManager sharedInstance] loggedInUser];
    double totalCalories = [dayProvider getTotalCaloriesWithDate:nil].doubleValue;
    double caloriesRemaining = [dayProvider getTotalCaloriesRemainingWithDate:nil].doubleValue;
    double exerciseCalories = [dayProvider getCaloriesBurnedViaExerciseWithDate:nil];
    int userBMR = dayProvider.getCurrentBMR.intValue;

    [self.values removeAllObjects];
    if (caloriesRemaining <= 0) {
        [self.values addObject:[NSNumber numberWithInt:1]];
    } else {
        [self.values addObject:[NSNumber numberWithInt:(userBMR - caloriesRemaining)]];
        [self.values addObject:[NSNumber numberWithInt:caloriesRemaining]];
    }
    [_remaining_Pie reloadData];

    self.lblGoal.text = [NSString stringWithFormat:@"%i", userBMR];
    self.lblfoodCalories.text = [NSString stringWithFormat:@"+%.0f", totalCalories];
    self.lblConsumed.text = [NSString stringWithFormat:@"%.0f", totalCalories];
    self.lblExerciseCalories.text = [NSString stringWithFormat:@"-%.0f", exerciseCalories];
    self.lblBurned.text = [NSString stringWithFormat:@"%.0f", exerciseCalories];
    self.lblNetCalories.text = [NSString stringWithFormat:@"%.0f", caloriesRemaining];
    
    // Get total calories consumed.
    double fatCalories = [dayProvider getTotalFatCaloriesWithDate:nil].doubleValue;
    double proteinCalories = [dayProvider getTotalProteinCaloriesWithDate:nil].doubleValue;
    double carbCalories = [dayProvider getTotalCarbCaloriesWithDate:nil].doubleValue;
    double totalPercentage = fatCalories + proteinCalories + carbCalories;
    
    // Get grams consumed.
    CGFloat carbGramsActual = carbCalories / 4;
    CGFloat proteinGramsActual = proteinCalories / 4;
    CGFloat fatGramsActual = fatCalories / 9;

    // Percentages.
    CGFloat fatGramActualPrecent = ((fatCalories / totalPercentage) * 100);
    CGFloat proteinGramActualPrecent = ((proteinCalories / totalPercentage) * 100);
    CGFloat carbsGramActualPercent = ((carbCalories / totalPercentage) * 100);
  
    if (carbsGramActualPercent <= 0 || isnan(carbsGramActualPercent)) {
        carbsGramActualPercent = 0.0;
        self.c_PercentageLbl.text = @"0";
    } else {
        self.c_PercentageLbl.text = [@(round(carbsGramActualPercent)) stringValue];
    }
    
    if (proteinGramActualPrecent <= 0 || isnan(proteinGramActualPrecent)) {
        proteinGramActualPrecent = 0.0;
        self.p_PercentageLbl.text = @"/0/";
    } else {
        self.p_PercentageLbl.text = [NSString stringWithFormat: @"/%@/", @(round(proteinGramActualPrecent))];
    }

    if (fatGramActualPrecent <= 0 || isnan(fatGramActualPrecent)) {
        fatGramActualPrecent = 0.0;
        self.f_PercentageLbl.text = @"0";
    } else {
        self.f_PercentageLbl.text = [@(round(fatGramActualPrecent)) stringValue];
    }
        
    [self.cpf_Values removeAllObjects];
    [self.cpf_Values addObject:[NSNumber numberWithFloat:round(fatGramActualPrecent)]];
    [self.cpf_Values addObject:[NSNumber numberWithFloat:round(proteinGramActualPrecent)]];
    [self.cpf_Values addObject:[NSNumber numberWithFloat:round(carbsGramActualPercent)]];
    [self.cpf_Values addObject:[NSNumber numberWithFloat:100 - round(carbsGramActualPercent + proteinGramActualPrecent + fatGramActualPrecent)]];
    [self.cpf_Pie reloadData];

    // Display the consumed grams for the day.
    self.actualCarbLabel.text = [NSString stringWithFormat:@"%.1f",carbGramsActual];
    self.actualProtLabel.text = [NSString stringWithFormat:@"%.1f",proteinGramsActual];
    self.actualFatLabel.text = [NSString stringWithFormat:@"%.1f",fatGramsActual];
    
    // Note, ACTUAL here means "Recommended" for the labels below.
    // The variable names are incorrect.
    CGFloat bmrValue = [dayProvider getCurrentBMR].floatValue;
    CGFloat carbGramsRecommended = (currentUser.carbRatio.floatValue / 100) * bmrValue / 4;
    CGFloat proteinGramsRecommended = (currentUser.proteinRatio.floatValue / 100) * bmrValue / 4;
    CGFloat fatGramsRecommended = (currentUser.fatRatio.floatValue / 100) * bmrValue / 9;
    
    self.actualCarbGramsLabel.text = [NSString stringWithFormat:@"%.1f", carbGramsRecommended];
    self.actualProteinGramsLabel.text = [NSString stringWithFormat:@"%.1f", proteinGramsRecommended];
    self.actualFatGramsLabel.text = [NSString stringWithFormat:@"%.1f", fatGramsRecommended];
}

@end
