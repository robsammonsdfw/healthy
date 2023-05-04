#import "DietMasterGoViewController.h"
#import "DietMasterGoAppDelegate.h"
#import "GroceryListViewController.h"
#import "FoodsList.h"
#import "DietmasterEngine.h"
#import "MessageViewController.h"
#import "MKNumberBadgeView.h"
#import "AppSettings.h"
#import <Crashlytics/Crashlytics.h>
#import "MyLogViewController.h"
#import "MyGoalViewController.h"
#import "MealPlanViewController.h"
#import "PopUpView.h"
#import "MCNewCustomLayeredView+MCCustomLayeredViewSubclass.h"
#import "MyMovesWebServices.h"
#import "MyMovesViewController.h"

static inline UIColor *GetRandomUIColor()
{
    CGFloat r = arc4random() % 255;
    CGFloat g = arc4random() % 255;
    CGFloat b = arc4random() % 255;
    return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f];
}


@interface DietMasterGoViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,CPTPieChartDelegate,GotoViewControllerDelegate,UIPopoverPresentationControllerDelegate> {
    MKNumberBadgeView *numberBadge;
    UIBarButtonItem* rightButton;
    CGFloat sliceValuesSum;
    CGFloat angle;
    MyMovesWebServices *soapWebService;
}

@property (strong, nonatomic) NSMutableArray *values;
@property (strong, nonatomic) NSMutableArray *cpf_Values;
@property (strong, nonatomic) NSMutableArray *labels;
@property (strong, nonatomic) NSMutableArray *colors;
@property (strong, nonatomic) NSMutableArray *sugarArray;
@property (strong, nonatomic) NSMutableArray *individualSugarValues;
@property (strong, nonatomic) NSMutableAttributedString *cpfValueStr;
@property (nonatomic) BOOL inserting;



@end

@implementation DietMasterGoViewController
@synthesize date_currentDate,num_BMR,carbs_circular,fat_circular,protein_Circular,progressbar;

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//
//    }
//    return self;
//}
//
//-(id)init {
//    self = [super initWithNibName:@"DietMasterGoViewController" bundle:nil];
//    if (self) {
//    }
//    return self;
//}

- (void)viewDidLoad{
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
//
//    UIBezierPath *maskPath = [UIBezierPath
//        bezierPathWithRoundedRect:self.headerBlueVw.bounds
//        byRoundingCorners:(UIRectCornerAllCorners)
//        cornerRadii:CGSizeMake(20, 20)
//    ];
//
//    CAShapeLayer *maskLayer = [CAShapeLayer layer];
//
//    maskLayer.frame = self.view.bounds;
//    maskLayer.path = maskPath.CGPath;
//
//    self.headerBlueVw.layer.mask = maskLayer;
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString: _cpfLbl.attributedText];

    [text addAttribute:NSForegroundColorAttributeName value:UIColorFromHex(0xC15F6E) range:NSMakeRange(0, 1)];
    [text addAttribute:NSForegroundColorAttributeName value:UIColorFromHex(0x64BB60) range:NSMakeRange(4, 1)];
    [text addAttribute:NSForegroundColorAttributeName value:UIColorFromHex(0x0095B8) range:NSMakeRange(8, 1)];

    [_cpfLbl setAttributedText: text];

    if (IS_IPHONE_5)
    {
        CGRect frame = _showPopUpVw.frame;
        frame.size = CGSizeMake(60, 80);
        _showPopUpVw.frame = frame;
    }
    
    [self setShadowForViews];
    [self setColorsForViews];
    [self changeImageColors];
    [self plusBtnColor];
    
    _circleHomeView.layer.cornerRadius = 35;
    _circleHomeView.layer.masksToBounds = YES;
    
    _hideShowStack.hidden = true;
    _secondHideShowStackVw.hidden = true;
    
    status = @"first";
    leftStatus = @"new";
    weightStatus = @"up";

    [UIView animateWithDuration:0.25 animations:^{
        _hideShowConstant.constant = 0;
        _secondHideShowConstant.constant = 0;
        _weightHideShowHeightConst.constant = 0;

        _expandViewHeightConst.constant = 125;
        _seperateLineVw.hidden = true;
        _secondExpandViewHeightConst.constant = 125;
        _weightSeperatorLbl.text = @"";
        _thirdExpVwHeightConst.constant = 115;
    }];
    
    //    _calPullDwnBtn.imageEdgeInsets = UIEdgeInsetsMake(25, 0, 0, 0);
    //    _macrosPullDwnBtn.imageEdgeInsets = UIEdgeInsetsMake(35, 0, 0, 0);
    
    NSString *stepsCount = [NSString stringWithFormat:@"%ld",(long)[[NSUserDefaults standardUserDefaults] integerForKey:@"minutesExercised"]];
    
    if ([stepsCount containsString:@"(null)"])
    {
        lblStepsCount.text = @"0";
    }
    else
    {
        lblStepsCount.text = stepsCount;
    }
    
    NSDictionary* userDefaultsValuesDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSNumber numberWithBool:YES], @"LoggedExeTracking",
                                            nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsValuesDict];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"ReloadData" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoginFinished:) name:@"UserLoginFinished" object:nil];
      
    
//    UIImage *image = [[UIImage imageNamed:@"up_arrow_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    [_plannedArroewBtn setImage:image forState:UIControlStateNormal];
//    _plannedArroewBtn.tintColor = PrimaryDarkColor;
    
    self.values = [[NSMutableArray alloc] init];
    self.cpf_Values = [[NSMutableArray alloc] init];
    self.sugarArray = [[NSMutableArray alloc] init];
    self.individualSugarValues = [[NSMutableArray alloc] init];

    
    self.remaining_Pie.dataSource = self;
    self.remaining_Pie.delegate = self;
    self.remaining_Pie.animationDuration = 0.5;
    
    self.cpf_Pie.dataSource = self;
    self.cpf_Pie.delegate = self;
    self.cpf_Pie.animationDuration = 0.5;
    self.cpf_Pie.internalRadius = 28;
    self.cpf_Pie.sliceColor = UIColor.lightGrayColor;
    self.cpf_Pie.borderPercentage = 0.5;
//        self.cpf_Pie.sliceColor = [MCUtil flatWetAsphaltColor];
//        self.cpf_Pie.borderColor = UIColor.redColor;
//        self.cpf_Pie.selectedSliceColor = [MCUtil flatSunFlowerColor];
//        self.cpf_Pie.textColor = [MCUtil flatSunFlowerColor];
//        self.cpf_Pie.selectedTextColor = [MCUtil flatWetAsphaltColor];
    numberBadge = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(self.sendMsgBtnOutlet.frame.origin.x + 20, self.sendMsgBtnOutlet.frame.origin.y - 10, 20, 20)];
    numberBadge.font = [UIFont systemFontOfSize:12];
    numberBadge.hideWhenZero = YES;
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.showPopUpVw.hidden = false; 
    
//    self.entireView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background"]];
    
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    self.hidesBottomBarWhenPushed = true;
    self.tabBarController.tabBar.frame = CGRectMake(self.tabBarController.tabBar.frame.origin.x, self.tabBarController.tabBar.frame.origin.y, self.tabBarController.tabBar.frame.size.width, 0);
    
    NSString *stepsCount = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"minutesExercised"]];
    
    if ([stepsCount containsString:@"(null)"])
    {
        lblStepsCount.text = @"0";
    }
    else
    {
        lblStepsCount.text = stepsCount;
    }
    
    [self.sendMsgBtnOutlet addSubview:numberBadge];
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
}
    
-(void)plusButtonImageColor
{
    UIImage *image = [[UIImage imageNamed:@"up_arrow_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_plannedArroewBtn setImage:image forState:UIControlStateNormal];
    _plannedArroewBtn.tintColor = PrimaryDarkColor;

}

-(void)ButtonStyle:(UIButton *)sender imageToSet:(UIImage *)image
{
    UIColor *borderColor = PrimaryDarkColor
    sender.layer.cornerRadius = 15.0f;
    sender.layer.borderColor = borderColor.CGColor;
    sender.layer.borderWidth = 1.0f;
    sender.clipsToBounds = YES;
    
    [sender setImage:image forState:UIControlStateNormal];
    sender.tintColor = PrimaryDarkColor;

}

-(void)plusBtnColor
{
    [self ButtonStyle:_consumedPlusBtn imageToSet:[[UIImage imageNamed:@"Icon feather-plus"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self ButtonStyle:_weightPlusBtn imageToSet:[[UIImage imageNamed:@"Icon feather-plus"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self ButtonStyle:_plannedArroewBtn imageToSet:[[UIImage imageNamed:@"up_arrow_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self ButtonStyle:_gotoWorkout imageToSet:[[UIImage imageNamed:@"up_arrow_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self ButtonStyle:_gotoScheduled imageToSet:[[UIImage imageNamed:@"up_arrow_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self ButtonStyle:_burnedPlusBtn imageToSet:[[UIImage imageNamed:@"Icon feather-plus"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
}

-(void)shadowView:(UIView *)selectedView
{
    selectedView.layer.shadowColor = UIColorFromHex(0xd7d7d7).CGColor;
    selectedView.layer.shadowOffset = CGSizeMake(8, 3);
    selectedView.layer.shadowOpacity = 1;
    selectedView.layer.shadowRadius = 2;
    selectedView.layer.masksToBounds = NO;
    
}
-(void)setShadowForViews
{
    [self shadowView:_firstExpandVw];
    [self shadowView:_secondExpandVw];
    [self shadowView:_consumedView];
    [self shadowView:_sugarView];
    [self shadowView:_plannedView];
    [self shadowView:_weightView];
    [self shadowView:_stepsView];
    [self shadowView:_burnedView];
    [self shadowView:_workoutView];
    [self shadowView:_scheduledView];
}

-(void)setColorsForViews
{
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

-(void)iconsColor:(UIImageView *)image
{
    UIColor *accentColor = PrimaryColor

    image.image = [image.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [image setTintColor:accentColor];

}

-(void)changeImageColors
{
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



- (IBAction)sendMessageBtn:(id)sender {
    MessageViewController *vc = [[MessageViewController alloc] initWithNibName:@"MessageView" bundle:nil];
//    self.hidesBottomBarWhenPushed = false;
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}
- (IBAction)sendMailBtn:(id)sender {
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

- (IBAction)addFoodBtn:(id)sender {
    MyLogViewController *vc = [[MyLogViewController alloc] initWithNibName:@"MyLogViewController" bundle:nil];
    vc.title = @"My Log";
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)addWeightBtn:(id)sender {
    MyGoalViewController *vc = [[MyGoalViewController alloc] initWithNibName:@"MyGoalViewController" bundle:nil];
    vc.title = @"My Goal";
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];

}
- (IBAction)addExerciseBtn:(id)sender {
    MyLogViewController *vc = [[MyLogViewController alloc] initWithNibName:@"MyLogViewController" bundle:nil];
    vc.title = @"My Log";
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)goToMyMealsBtn:(id)sender {
    MealPlanViewController *vc = [[MealPlanViewController alloc] initWithNibName:@"MealPlanViewController" bundle:nil];
    vc.title = @"My Meals";
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];

}
- (IBAction)gotoWorkoutBtn:(id)sender {
    MyMovesViewController *vc = [[MyMovesViewController alloc] initWithNibName:@"MyMovesViewController" bundle:nil];
    vc.workoutClickedFromHome = @"clicked";
    [self.navigationController pushViewController:vc animated:false];
}
- (IBAction)gotoScheduledBtn:(id)sender {
    MyMovesViewController *vc = [[MyMovesViewController alloc] initWithNibName:@"MyMovesViewController" bundle:nil];
    vc.title = @"MyMovesViewController";
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:false] ;
}

- (IBAction)popUpBtnAction:(id)sender {
    PopUpView* popUpView = [[PopUpView alloc]initWithNibName:@"PopUpView" bundle:nil];
    popUpView.modalPresentationStyle = UIModalPresentationOverFullScreen;
    popUpView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    popUpView.gotoDelegate = self;
    _showPopUpVw.hidden = true;
    popUpView.vc = @"DietMasterGoViewController"; 
    [self presentViewController:popUpView animated:YES completion:nil];
}

- (IBAction)expandBtnAvtion:(id)sender {
    
    /*    CGRect contentRect = CGRectMake(0, 0, self.entireView.frame.size.width, self.entireView.frame.size.height);
     
     for (UIView *view in self.scrollView.subviews) {
     contentRect = CGRectUnion(contentRect, view.frame);
     }
     self.scrollView.contentSize = contentRect.size;*/
    
    
    //    [self rotateButtonImage:sender];
    _hideShowStack.hidden = false;
    //    _secondHideShowStackVw.hidden = true;
    //    _secondHideShowConstant.constant = 0;
    //    _secondExpandViewHeightConst.constant = 125;
    //
    //    _weightHideShowStack.hidden = true;
    //    _weightHideShowHeightConst.constant = 0;
    //    _thirdExpVwHeightConst.constant = 115;
    
    if([status isEqualToString:@"first"])
    {
        [UIView transitionWithView:_firstExpandVw duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            _hideShowConstant.constant = 130;
            //            _calPullDwnBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 25, 0);
            _expandViewHeightConst.constant = 262;
        }
                        completion:NULL];
        
        status = @"next";
    }
    else if ([status isEqualToString:@"next"])
    {
        [UIView transitionWithView:_firstExpandVw duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            _hideShowConstant.constant = 0;
            //            _calPullDwnBtn.imageEdgeInsets = UIEdgeInsetsMake(25, 0, 0, 0);
            _expandViewHeightConst.constant = 125;
            _hideShowStack.hidden = true;
        } completion:NULL];
        
        
        status = @"first";
    }
    //    leftStatus = @"new";
    //    weightStatus = @"up";
}

- (IBAction)leftExpandBtnAction:(id)sender{
    /* CGRect contentRect = CGRectMake(0, 0, self.entireView.frame.size.width, self.entireView.frame.size.height);
     
     for (UIView *view in self.scrollView.subviews) {
     contentRect = CGRectUnion(contentRect, view.frame);
     }
     self.scrollView.contentSize = contentRect.size;*/
    
    //    _hideShowStack.hidden = true;
    //    _hideShowConstant.constant = 0;
    //    _expandViewHeightConst.constant = 125;
    _secondHideShowStackVw.hidden = false;
    //    _seperateLineVw.hidden = true;
    //
    //    _weightHideShowStack.hidden = true;
    //    _weightHideShowHeightConst.constant = 0;
    //    _thirdExpVwHeightConst.constant = 115;
    //
    _seperateLineLbl.hidden = FALSE;
    _headerStackVw.hidden = FALSE;
    _leftStackVw.hidden = FALSE;
    _rightStackVw.hidden = FALSE;
    _midLineVw.hidden = FALSE;
    
    //    [self rotateButtonImage:sender];
    if([leftStatus isEqualToString:@"new"])
    {
        [UIView transitionWithView:_secondExpandVw duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            //               _macrosPullDwnBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 35, 0);
            _secondHideShowConstant.constant = 173;
            _secondExpandViewHeightConst.constant = 262;
        } completion:NULL];
        
        leftStatus = @"old";
    }
    else if ([leftStatus isEqualToString:@"old"])
    {
        [UIView transitionWithView:_secondExpandVw duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            _secondHideShowConstant.constant = 0;
            _secondHideShowStackVw.hidden = true;
            _secondExpandViewHeightConst.constant = 125;
        } completion:NULL];
        leftStatus = @"new";
    }
    //    status = @"first";
    //    weightStatus = @"up";
}

- (IBAction)weightExpBtnAction:(id)sender {
    /* CGRect contentRect = CGRectMake(0, 0, self.entireView.frame.size.width, self.entireView.frame.size.height);
     
     for (UIView *view in self.scrollView.subviews) {
     contentRect = CGRectUnion(contentRect, view.frame);
     }
     self.scrollView.contentSize = contentRect.size;
     */
    //    _hideShowStack.hidden = true;
    //    _hideShowConstant.constant = 0;
    //    _expandViewHeightConst.constant = 125;
    //    _seperateLineVw.hidden = true;
    //
    //    _secondHideShowStackVw.hidden = true;
    //    _secondHideShowConstant.constant = 0;
    //    _secondExpandViewHeightConst.constant = 125;
    //
    _weightHideShowStack.hidden = false;
    _seperateLineLbl.hidden = FALSE;
    _headerStackVw.hidden = FALSE;
    _leftStackVw.hidden = FALSE;
    _rightStackVw.hidden = FALSE;
    _midLineVw.hidden = FALSE;
    
    //    [self rotateButtonImage:sender];
    if([weightStatus isEqualToString:@"up"])
    {
        [UIView transitionWithView:_weightView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            //               _macrosPullDwnBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 35, 0);
            _weightHideShowHeightConst.constant = 115;
            _thirdExpVwHeightConst.constant = 250;
        } completion:NULL];
        _weightSeperatorLbl.text = @"- - - - - - - - - - - - - - - - -";
        weightStatus = @"down";
    }
    else if ([weightStatus isEqualToString:@"down"])
    {
        [UIView transitionWithView:_weightView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            _thirdExpVwHeightConst.constant = 115;
            _weightHideShowHeightConst.constant = 0;
            
        } completion:NULL];
        _weightSeperatorLbl.text = @"";
        weightStatus = @"up";
    }
    //    status = @"first";
    //    leftStatus = @"new";
}


-(void)rotateButtonImage:(UIButton *)button
{
    [UIView animateWithDuration:0.2 animations:^{
        if (CGAffineTransformEqualToTransform(button.transform, CGAffineTransformIdentity)) {
            button.transform = CGAffineTransformMakeRotation(M_PI * 0.999);
        } else {
            button.transform = CGAffineTransformIdentity;
        }
    }];
}


-(IBAction)showSettings:(id)sender {
        AppSettings *appVC = [[AppSettings alloc]initWithNibName:@"AppSettings" bundle:nil];
        appVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:appVC animated:YES];
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//
//    //HHT change 2018 to solve barbutton issue
//    UIBarButtonItem *mailButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Mail" style:UIBarButtonItemStylePlain target:self action:@selector(mailAction:)];
//    self.navigationItem.leftBarButtonItem = mailButtonItem;
//    [self.view addSubview:numberBadge];
//    mailButtonItem.tintColor=[UIColor whiteColor];
//    [mailButtonItem release];
//    //[numberBadge release];
//
//    [fat_circular setValue:0];
//    [protein_Circular setValue:0];
//    [carbs_circular setValue:0];
//    [self.remainingCalories_Circular_Progress setValue:0];
//    [progressbar setProgress:0.0f animated:NO];
//
//    self.navigationController.navigationBar.layer.zPosition = -1;
//    [self reloadMessages];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBadge) name:UpdatingMessageNotification object:nil];
//
//    [self.navigationController setNavigationBarHidden:NO];
//}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.layer.zPosition = 0;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.values removeAllObjects];
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
    lbl_CaloriesRecommended.text = [NSString stringWithFormat:@"%li", (long)bmrValue];
    
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
    [_circleHomeView release];
    [_entireView release];
    [_hideShowStack release];
    [_hideShowConstant release];
    [_firstExpandVw release];
    [_expandViewHeightConst release];
    [_rightExpBtnAction release];
    [_seperateLineLbl release];
    [_headerStackVw release];
    [_leftStackVw release];
    [_rightStackVw release];
    [_midLineVw release];
    [_secondExpandVw release];
    [_secondExpandViewHeightConst release];
    [_secondHideShowConstant release];
    [_secondHideShowStackVw release];
    [_consumedPlusBtn release];
    [_plannedArroewBtn release];
    [_weightPlusBtn release];
    [_burnedPlusBtn release];
    [_calPullDwnBtn release];
    [_macrosPullDwnBtn release];
    [lblConsumed release];
    [lblBurned release];
    [lblSugar release];
    [lblStepsCount release];
    [_remaining_Pie release];
    [_cpf_Pie release];
    [_consumedView release];
    [_sugarView release];
    [_plannedView release];
    [_weightView release];
    [_stepsView release];
    [_burnedView release];
    [_workoutView release];
    [_scheduledView release];
    [_seperateLineVw release];
    [_cpf_PercentageLbl release];
    [_c_PercentageLbl release];
    [_p_PercentageLbl release];
    [_f_PercentageLbl release];
    [_headerBlueVw release];
    [_cornerRadiImgVw release];
    [_suagrGraphImageVw release];
    [_sendMsgBtnOutlet release];
    [_nameLbl release];
    [_popUpBtn release];
    [_showPopUpVw release];
    [_thirdExpVwHeightConst release];
    [_weightPullDwnBtn release];
    [_weightHideShowStack release];
    [_weightHideShowHeightConst release];
    [_weightSeperatorLbl release];
    [lblToGo_lbs release];
    [_thirtyConst release];
    [_eightyConst release];
    [_scrollView release];
    [_homeImage release];
    [_consumedImage release];
    [_plannedImage release];
    [_weightImage release];
    [_stepsImage release];
    [_burnedImage release];
    [_workoutImage release];
    [_scheduledImage release];
    [_cpfLbl release];
    [_gotoWorkout release];
    [_gotoScheduled release];
    [lblCurrent_BMI release];
    [lblBody_Fat release];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
//        [self performSelectorOnMainThread:@selector(showLoading) withObject:nil waitUntilDone:NO];
        [self performSelector:@selector(loadData) withObject:nil afterDelay:0.25];
        [self performSelector:@selector(loadExerciseData) withObject:nil afterDelay:0.15];
    }
    NSString *firstName = [prefs valueForKey:@"FirstName_dietmastergo"];
//    NSString *lastName = [prefs valueForKey:@"LastName_dietmastergo"];
    NSString *name = [NSString stringWithFormat: @"Hi, %@!",firstName];
    self.nameLbl.text = name;
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
    
//    NSString *query = [NSString stringWithFormat: @"SELECT Food_Log.MealID, Food_Log.MealDate, Food_Log_Items.MealCode, Food_Log_Items.FoodID, Food_Log_Items.MeasureID, Food_Log_Items.NumberOfServings, Food.FoodKey, Food.Name, Food.Calories, Food.Fat, Food.Carbohydrates, Food.Protein, FoodMeasure.GramWeight, Food.ServingSize FROM Food_Log INNER JOIN Food_Log_Items ON Food_Log.MealID = Food_Log_Items.MealID INNER JOIN Food ON Food.FoodKey = Food_Log_Items.FoodID INNER JOIN FoodMeasure ON FoodMeasure.FoodID = Food.FoodKey WHERE (Food_Log.MealDate BETWEEN DATETIME('%@ 00:00:00') AND DATETIME('%@ 23:59:59')) AND Food_Log_Items.MeasureID = FoodMeasure.MeasureID ORDER BY Food_Log_Items.MealCode ASC", date_Today, date_Today];
    
    NSString *query = [NSString stringWithFormat: @"SELECT Food_Log.MealID, Food_Log.MealDate, Food_Log_Items.MealCode, Food_Log_Items.FoodID, Food_Log_Items.MeasureID, Food_Log_Items.NumberOfServings, Food.FoodKey, Food.Name, Food.Calories, Food.Fat, Food.Carbohydrates, Food.Protein,Food.Sugars, FoodMeasure.GramWeight, Food.ServingSize FROM Food_Log INNER JOIN Food_Log_Items ON Food_Log.MealID = Food_Log_Items.MealID INNER JOIN Food ON Food.FoodKey = Food_Log_Items.FoodID INNER JOIN FoodMeasure ON FoodMeasure.FoodID = Food.FoodKey WHERE (Food_Log.MealDate BETWEEN DATETIME('%@ 00:00:00') AND DATETIME('%@ 23:59:59')) AND Food_Log_Items.MeasureID = FoodMeasure.MeasureID ORDER BY Food_Log_Items.MealCode ASC", date_Today, date_Today];

    
    FMResultSet *rs = [db executeQuery:query];
    totalSugarValue = 0;
    double totalSugarCalories = 0;
    while ([rs next]) {
        int fatGrams = [rs doubleForColumn:@"Fat"];
        double sugar = [rs doubleForColumn:@"Sugars"];
        double sugarValue = sugar * [rs doubleForColumn:@"NumberOfServings"] * ([rs doubleForColumn:@"GramWeight"] / 100 / [rs doubleForColumn:@"ServingSize"]);
        totalSugarCalories += (sugarValue * 3.8);
        totalSugarValue += sugarValue;
        
        int totalFatCalories = [rs doubleForColumn:@"NumberOfServings"] * ((fatGrams * 9.0) * ([rs doubleForColumn:@"GramWeight"] / 100) / [rs doubleForColumn:@"ServingSize"]);
        totalFat = totalFat + totalFatCalories;
        
        int carbGrams = [rs doubleForColumn:@"Carbohydrates"];
        int totalCarbCalories = [rs doubleForColumn:@"NumberOfServings"] * ((carbGrams * 4.0) * ([rs doubleForColumn:@"GramWeight"] / 100) / [rs doubleForColumn:@"ServingSize"]);
        totalCarbs = totalCarbs + totalCarbCalories;
        
        int proteinGrams = [rs doubleForColumn:@"Protein"];
        
        int totalProteinCalories = [rs doubleForColumn:@"NumberOfServings"] * ((proteinGrams * 4.0) * ([rs doubleForColumn:@"GramWeight"] / 100) / [rs doubleForColumn:@"ServingSize"]);
        totalProtein = totalProtein + totalProteinCalories;
        
        int totalCalories = [rs doubleForColumn:@"NumberOfServings"] * (([rs doubleForColumn:@"Calories"] * ([rs doubleForColumn:@"GramWeight"] / 100)) / [rs doubleForColumn:@"ServingSize"]);
        
        num_totalCalories += totalCalories;
    }
   
    NSString *sugarStr = [NSString stringWithFormat:@"%.1f",totalSugarValue];
    lblSugar.text = [NSString stringWithFormat:@"%@g",sugarStr];
    
    if (totalSugarCalories / num_totalCalories > .1) //if sugar radio is > 10%
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
    
    //HHT apple watch (gender added)
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
        currentHeight = [rs doubleForColumn:@"Height"];
        goalStartDate = [[rs stringForColumn:@"GoalStartDate"] componentsSeparatedByString:@" "][0];
    }
    
    dietmasterEngine.userHeight = [NSNumber numberWithDouble:currentHeight];
    dietmasterEngine.userGender = gender;
    
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"isKgs"] boolValue]) {
        lblGoal_lbs.text = [NSString stringWithFormat:@"%.1d lbs",intWeightGoal];
        lblToGo_lbs.text = [NSString stringWithFormat:@"%g lbs",(currentWeight - intWeightGoal)];
        
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
    
    NSString *getStartWeight = [NSString stringWithFormat:@"SELECT weight FROM weightlog where logtime like '%%%@%%' AND deleted = 1", goalStartDate];
    rs = [db executeQuery:getStartWeight];
    while ([rs next]) {
        startWeight = [rs doubleForColumn:@"weight"];
    }
    
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"isKgs"] boolValue]) {
        lblStart_lbs.text = [NSString stringWithFormat:@"%g lbs", startWeight];
    }
    else {
        lblStart_lbs.text = [NSString stringWithFormat:@"%g Kgs", startWeight];
    }
    
    //HHT new change
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"isKgs"] boolValue]) {
        lbl_CurrentWeight.text = [NSString stringWithFormat:@"%g lbs.", currentWeight];
        
        //lblWeight.text = [NSString stringWithFormat:@"%@ %.1f lbs",strWeightStatus,currentWeight-startWeight];
        //HHT change 2018
        lblProgressBarCurrentWeight.text = [NSString stringWithFormat:@"%g lbs.", currentWeight];
        
        if (startWeight < intWeightGoal) {
            lblWeight.text = [NSString stringWithFormat:@"%@ %g lbs",strWeightStatus,currentWeight-startWeight];
        }
        else if (startWeight > intWeightGoal) {
            lblWeight.text = [NSString stringWithFormat:@"%@ %g lbs",strWeightStatus,startWeight - currentWeight];
        }
        else if (startWeight == intWeightGoal) {
            lblWeight.text = [NSString stringWithFormat:@"%@ %g lbs",strWeightStatus,startWeight - 0];
        }
    }
    else {
        lbl_CurrentWeight.text = [NSString stringWithFormat:@"%g Kgs", currentWeight];
        
        //HHT change 2018
        lblProgressBarCurrentWeight.text = [NSString stringWithFormat:@"%g Kgs", currentWeight];
        
        if (startWeight < intWeightGoal) {
            lblWeight.text = [NSString stringWithFormat:@"%@ %g Kgs",strWeightStatus,currentWeight-startWeight];
        }
        else if (startWeight > intWeightGoal) {
            lblWeight.text = [NSString stringWithFormat:@"%@ %g Kgs",strWeightStatus,startWeight - currentWeight];
        }
        else if (startWeight == intWeightGoal) {
            lblWeight.text = [NSString stringWithFormat:@"%@ %g Kgs",strWeightStatus,startWeight - 0];
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
        progressbar.indicatorTextLabel.text = [NSString stringWithFormat:@"%g lbs",currentWeight];
    }
    else {
        progressbar.indicatorTextLabel.text = [NSString stringWithFormat:@"%g Kgs",currentWeight];
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
    lblBody_Fat.text = [NSString stringWithFormat:@"Body Fat: %.1f%%", bodyFat];
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
//        num_totalCaloriesRemaining = [lbl_CaloriesRecommended.text doubleValue] - num_totalCalories;
    }
    else
    {
        remainingCalorieCount=[NSString stringWithFormat:@"%.0f",calRecommended + num_totalCaloriesBurned];
        lblCaloriesRemainingValue.text=[NSString stringWithFormat:@"%.f",[remainingCalorieCount doubleValue] - num_totalCalories];
//        num_totalCaloriesRemaining = [remainingCalorieCount doubleValue] - num_totalCalories;
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
            
//            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"LoggedExeTracking"] == YES) {
                num_totalCaloriesBurned = num_totalCaloriesBurned + totalCaloriesBurned;
//            }
//            else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"LoggedExeTracking"] == NO){
//
//            }
        }
    }
    
    [rs close];
    
    [dateFormatter release];
    
    [self updateCalorieTotal];
    [self calculateBMI];
}

-(void)updateCalorieTotal {
    bool useCaloriesBurned = [[NSUserDefaults standardUserDefaults] boolForKey:@"LoggedExeTracking"] == YES;
    double netCalories = 0;
    CGFloat caloriesREmaining = 0;
    if (useCaloriesBurned) {
        netCalories = num_BMR - num_totalCalories + num_totalCaloriesBurned;
        caloriesREmaining = (num_BMR - (num_totalCaloriesBurned * -1)) - num_totalCalories;
        num_totalCaloriesRemaining = num_BMR - (num_totalCaloriesBurned * -1) - num_totalCalories;
    } else {
        netCalories = num_BMR - num_totalCalories;
        caloriesREmaining = num_BMR - num_totalCalories;
        num_totalCaloriesRemaining = num_BMR - num_totalCalories;
    }
    
    //HHT Change 2018 (exercise / 2 )
    //double netCalories = num_totalCalories - (num_totalCaloriesBurned/2);
    //CGFloat caloriesREmaining = (num_BMR - ((num_totalCaloriesBurned/2) * -1)) - num_totalCalories;
    
    lbl_CalorieDifference.text = [NSString stringWithFormat:@"%.0f", caloriesREmaining];
    [self.remainingCalories_Circular_Progress setMaxValue:num_BMR];
    
    //HHT change start
    if (caloriesREmaining < 0) {
//        lblCaloriesRemainingValue.text = [NSString stringWithFormat:@"%.0f", caloriesREmaining/2];
        [self.remainingCalories_Circular_Progress setValue:1];
        [self.values removeAllObjects];
        [self.values addObject:[NSNumber numberWithInt:1]];
        [self.values addObject:[NSNumber numberWithInt:(num_BMR - 1)]];
        [_remaining_Pie reloadData];
    }
    else {
//        lblCaloriesRemainingValue.text = [NSString stringWithFormat:@"%.0f", caloriesREmaining/2];
        [self.remainingCalories_Circular_Progress setValue:caloriesREmaining];
        [self.values removeAllObjects];
        [self.values addObject:[NSNumber numberWithInt:caloriesREmaining]];
        [self.values addObject:[NSNumber numberWithInt:(num_BMR - caloriesREmaining)]];
        [_remaining_Pie reloadData];
    }
    //HHT change end
    
    //50% HHT Change 2018 (exercise / 2 )
    AppDel.caloriesremaning=[[NSString stringWithFormat:@"%.0f", caloriesREmaining] doubleValue];
    [self caloriesRemainUpdate];
    
    goalCalorieLabel.text = [NSString stringWithFormat:@"%i", num_BMR];
    lblGoal.text = [NSString stringWithFormat:@"%i", num_BMR];
    
    caloriesLoggedLabel.text = [NSString stringWithFormat:@"+%.0f", num_totalCalories];
    lblfoodCalories.text = [NSString stringWithFormat:@"+%.0f", num_totalCalories];
    lblConsumed.text = [NSString stringWithFormat:@"%.0f", num_totalCalories];

    exerciseCaloriesLoggedLabel.text = [NSString stringWithFormat:@"-%.0f", num_totalCaloriesBurned];
    
    //50% HHT Change 2018 (exercise / 2 )
    if (useCaloriesBurned) {
        lblExerciseCalories.text = [NSString stringWithFormat:@"-%.0f", num_totalCaloriesBurned];
    } else {
        lblExerciseCalories.text = @"-0";
    }
    lblBurned.text = [NSString stringWithFormat:@"%.0f", num_totalCaloriesBurned];
//    lblSugar.text = [NSString stringWithFormat:@"%.1f", totalSugar];

    netCalorieLabel.text = [NSString stringWithFormat:@"%.0f", netCalories];
//    lblNetCalories.text = [NSString stringWithFormat:@"%.0f", num_totalCalories - (num_totalCaloriesBurned/2)];
    lblNetCalories.text = [NSString stringWithFormat:@"%.0f", netCalories];    
    
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
  
    NSString* c_percentageStr =  [[NSNumber numberWithInt:carbsGramActualPercent] stringValue];
    NSString* p_percentageStr = [[NSNumber numberWithInt:proteinGramActualPrecent] stringValue];
    NSString* f_percentageStr = [[NSNumber numberWithInt:fatGramActualPrecent] stringValue];
    
  /*  NSString* c_percentageStr = [NSString stringWithFormat:@"%.1f", carbsGramActualPercent] ;
    NSString* p_percentageStr = [NSString stringWithFormat:@"%.1f", proteinGramActualPrecent];
    NSString* f_percentageStr = [NSString stringWithFormat:@"%.1f", fatGramActualPrecent];*/

    
    NSString *seperatorStrLeft = @"/";
    NSString *seperatorStrRight = @"/";
    NSString *p_Str = [NSString stringWithFormat: @"%@%@%@",seperatorStrLeft,p_percentageStr,seperatorStrRight];

    
    if (carbsGramActualPercent < 0 || isnan(carbsGramActualPercent)) {
        _c_PercentageLbl.text = @"0";
    } else {
        _c_PercentageLbl.text = c_percentageStr;
    }
    
    if (proteinGramActualPrecent < 0 || isnan(proteinGramActualPrecent)) {
        _p_PercentageLbl.text = @"/0/";
    } else {
        _p_PercentageLbl.text = p_Str;
    }


    if (fatGramActualPrecent < 0 || isnan(fatGramActualPrecent)) {
        _f_PercentageLbl.text = @"0";
    } else {
        _f_PercentageLbl.text = f_percentageStr;
    }


    //HHT cange end
        
    //new design v3.0 (HHT change 2018) circular lable value
    lblactualCarbGramsLabel.text = [NSString stringWithFormat:@"%.1fg", carbGramActual];
    lblactualProteinGramsLabel.text = [NSString stringWithFormat:@"%.1fg", proteinGramActual];
    lblactualFatGramsLabel.text = [NSString stringWithFormat:@"%.1fg", fatGramActual];
    
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
    [_cpf_Pie reloadData];

    
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
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    NSDictionary *ratioDict = [dietmasterEngine getUserRecommendedRatios];

    CGFloat carbRatioActual = totalCarbs / 4;
    CGFloat proteinRatioActual = totalProtein / 4;
    CGFloat fatRatioActual = totalFat / 9;
    
    /*
    actualCarbLabel.text = [NSString stringWithFormat:@"%.1f",carbRatioActual];
    actualCarb=carbRatioActual;
    ansactualCarb=recCarb-actualCarb;
    actualCarbLabel.text = [NSString stringWithFormat:@"%.1f",ansactualCarb];

    actualProtLabel.text = [NSString stringWithFormat:@"%.1f",proteinRatioActual];
    actual =carbGramActual;
    ansis =recprofitn-actual;
    actualProtLabel.text=[NSString stringWithFormat:@"%.1f",ansis];
    
    actualFatLabel.text = [NSString stringWithFormat:@"%.1f",fatRatioActual];
    actualfat=fatRatioActual;
    actans =recFat-actualfat;
    actualFatLabel.text =[NSString stringWithFormat:@"%.1f",actans];
    */
    
    if (([[NSUserDefaults standardUserDefaults] valueForKey:@"ansactualCarb"] == nil) || ([[NSUserDefaults standardUserDefaults] valueForKey:@"recprofitn"] == nil) || ([[NSUserDefaults standardUserDefaults] valueForKey:@"actans"] == nil))
    {
        actualCarbLabel.text = [NSString stringWithFormat:@"%.1f",carbRatioActual];
        actualProtLabel.text = [NSString stringWithFormat:@"%.1f",proteinRatioActual];
        actualFatLabel.text = [NSString stringWithFormat:@"%.1f",fatRatioActual];
    }
    else
    {
        actualCarbLabel.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"ansactualCarb"];
        actualProtLabel.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"recprofitn"];
        actualFatLabel.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"actans"];
    }
    
    CGFloat bmrValue = [dietmasterEngine getBMR];
    
    CGFloat carbRatioRecommended = [[ratioDict valueForKey:@"CarbRatio"] doubleValue] * bmrValue / 4;
    CGFloat proteinRatioRecommended = [[ratioDict valueForKey:@"ProteinRatio"] doubleValue] * bmrValue / 4;
    CGFloat fatRatioRecommended = [[ratioDict valueForKey:@"FatRatio"] doubleValue] * bmrValue / 9;
    
    actualCarbGramsLabel.text = [NSString stringWithFormat:@"%.1f", carbRatioRecommended];
    actualProteinGramsLabel.text = [NSString stringWithFormat:@"%.1f", proteinRatioRecommended];
    actualFatGramsLabel.text = [NSString stringWithFormat:@"%.1f", fatRatioRecommended];
    
    recCarbLabel.text = [NSString stringWithFormat:@"%.1f",carbRatioRecommended];
    recCarb=carbRatioRecommended;
    
    recProtLabel.text = [NSString stringWithFormat:@"%.1f",proteinRatioRecommended];
    recprofitn=proteinRatioRecommended;
    
    recFatLabel.text = [NSString stringWithFormat:@"%.1f",fatRatioRecommended];
    recFat=fatRatioRecommended;
    
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
    lblCurrent_BMI.text = [NSString stringWithFormat:@"BMI: %.1f", bodyMassIndex];
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

-(void)hideShowPopUpView
{
    self.showPopUpVw.hidden = false;
}

@end

