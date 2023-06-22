#import "DietMasterGoViewController.h"
#import "DietMasterGoAppDelegate.h"
#import "GroceryListViewController.h"
#import "FoodsList.h"
#import "DietmasterEngine.h"
#import "MessageViewController.h"
#import "MKNumberBadgeView.h"
#import <Crashlytics/Crashlytics.h>
#import "MyLogViewController.h"
#import "MyGoalViewController.h"
#import "MealPlanViewController.h"
#import "MCNewCustomLayeredView+MCCustomLayeredViewSubclass.h"
#import "MyMovesWebServices.h"
#import "MyMovesViewController.h"
#import "NSString+Encode.h"

@interface DietMasterGoViewController() <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CPTPieChartDelegate, UIPopoverPresentationControllerDelegate> {
    MKNumberBadgeView *numberBadge;
    UIBarButtonItem* rightButton;
    CGFloat sliceValuesSum;
    CGFloat angle;
    MyMovesWebServices *soapWebService;
}

@property (nonatomic, strong) NSMutableArray *values;
@property (nonatomic, strong) NSMutableArray *cpf_Values;
@property (nonatomic, strong) NSMutableArray *labels;
@property (nonatomic, strong) NSMutableArray *colors;
@property (nonatomic, strong) NSMutableArray *sugarArray;
@property (nonatomic, strong) NSMutableArray *individualSugarValues;
@property (nonatomic, strong) NSMutableAttributedString *cpfValueStr;
@property (nonatomic) BOOL inserting;
@end

@implementation DietMasterGoViewController

@synthesize date_currentDate,num_BMR,carbs_circular,fat_circular,protein_Circular,progressbar;

- (instancetype)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString: _cpfLbl.attributedText];
    [text addAttribute:NSForegroundColorAttributeName value:UIColorFromHex(0xC15F6E) range:NSMakeRange(0, 1)];
    [text addAttribute:NSForegroundColorAttributeName value:UIColorFromHex(0x64BB60) range:NSMakeRange(4, 1)];
    [text addAttribute:NSForegroundColorAttributeName value:UIColorFromHex(0x0095B8) range:NSMakeRange(8, 1)];
    [_cpfLbl setAttributedText: text];

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

    numberBadge = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(self.sendMsgBtnOutlet.frame.origin.x + 20, self.sendMsgBtnOutlet.frame.origin.y - 10, 20, 20)];
    numberBadge.backgroundColor = [UIColor clearColor];
    numberBadge.shadow = NO;
    numberBadge.font = [UIFont systemFontOfSize:12];
    numberBadge.hideWhenZero = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    self.hidesBottomBarWhenPushed = true;
    
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
}

- (IBAction)leftExpandBtnAction:(id)sender {
    _secondHideShowStackVw.hidden = false;
    _seperateLineLbl.hidden = FALSE;
    _headerStackVw.hidden = FALSE;
    _leftStackVw.hidden = FALSE;
    _rightStackVw.hidden = FALSE;
    _midLineVw.hidden = FALSE;
    
    if([leftStatus isEqualToString:@"new"])
    {
        [UIView transitionWithView:_secondExpandVw duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
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
}

- (IBAction)weightExpBtnAction:(id)sender {
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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.layer.zPosition = 0;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.values removeAllObjects];
}

- (void)initProgressBar {
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
    numberBadge.value = [[DietmasterEngine sharedInstance] countOfUnreadingMessages];
    [UIApplication sharedApplication].applicationIconBadgeNumber = numberBadge.value;
}

- (void)reloadMessages {
    numberBadge.value = [[DietmasterEngine sharedInstance] countOfUnreadingMessages];
    
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

-(void)getBMR{
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    NSInteger bmrValue = [dietmasterEngine getBMR];
    num_BMR = (int)bmrValue;
    lbl_CaloriesRecommended.text = [NSString stringWithFormat:@"%li", (long)bmrValue];
    
    [self updateCalorieTotal];
}

-(IBAction) showGroceryList:(id) sender {
    FoodsList *flController = [[FoodsList alloc] initWithNibName:@"FoodsList" bundle:nil];
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
    
    num_totalCalories = 0;
    totalFat = 0.0;
    totalCarbs = 0.0;
    totalProtein = 0.0;
    double difference = 0.0;
        
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
    [DMActivityIndicator hideActivityIndicator];
}

-(void)caloriesRemainUpdate
{
    NSString *remainingCalorieCount;
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
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
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
        
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate* sourceDate = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
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
    num_totalCaloriesBurnedTracked = 0;
    
    FMResultSet *rs = [db executeQuery:query];
    bool combineTrackingCalories =[[NSUserDefaults standardUserDefaults] boolForKey:@"CalorieTrackingDevice"] == YES;
    
    while ([rs next]) {
        
        NSNumber *exerciseTimeMinutes = [NSNumber numberWithInt:[rs intForColumn:@"Exercise_Time_Minutes"]];
        NSNumber *caloriesPerHour = [NSNumber numberWithDouble:[rs doubleForColumn:@"CaloriesPerHour"]];
        
        int minutesExercised = [exerciseTimeMinutes intValue];
        
        double totalCaloriesBurned = ([caloriesPerHour floatValue] / 60) * [dietmasterEngine.currentWeight floatValue] * minutesExercised;
        
        int exerciseID = [rs intForColumn:@"ExerciseID"];
        
        if (exerciseID == 259) {
            
        }
        else if (exerciseID == 274 || exerciseID == 276) {
            
        }
        //HHT apple watch 274 for step count
        //HHT apple watch (272) calories apple watch
        else if (exerciseID == 257 || exerciseID == 267 || exerciseID == 272 || exerciseID == 275) {
            num_totalCaloriesBurnedTracked += minutesExercised;
            if (combineTrackingCalories) {
                num_totalCaloriesBurned += minutesExercised;
            }
        }
        else {
            num_totalCaloriesBurned += totalCaloriesBurned;
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
        netCalories = num_BMR - num_totalCalories + num_totalCaloriesBurned;
        caloriesREmaining = (num_BMR - (num_totalCaloriesBurned * -1)) - num_totalCalories;
        num_totalCaloriesRemaining = num_BMR - (num_totalCaloriesBurned * -1) - num_totalCalories;
    } else {
        if (useCaloriesBurnedTracked) {
            netCalories = num_BMR - num_totalCalories + num_totalCaloriesBurnedTracked;
            caloriesREmaining = (num_BMR - (num_totalCaloriesBurnedTracked * -1)) - num_totalCalories;
            num_totalCaloriesRemaining = num_BMR - (num_totalCaloriesBurnedTracked * -1) - num_totalCalories;
        } else {
            netCalories = num_BMR - num_totalCalories;
            caloriesREmaining = num_BMR - num_totalCalories;
            num_totalCaloriesRemaining = num_BMR - num_totalCalories;
        }
    }
    
    //HHT Change 2018 (exercise / 2 )
    //double netCalories = num_totalCalories - (num_totalCaloriesBurned/2);
    //CGFloat caloriesREmaining = (num_BMR - ((num_totalCaloriesBurned/2) * -1)) - num_totalCalories;
    
    lbl_CalorieDifference.text = [NSString stringWithFormat:@"%.0f", caloriesREmaining];
    [self.remainingCalories_Circular_Progress setMaxValue:num_BMR];
    
    //HHT change start
    if (caloriesREmaining < 0) {
        [self.remainingCalories_Circular_Progress setValue:1];
        [self.values removeAllObjects];
        [self.values addObject:[NSNumber numberWithInt:1]];
        [self.values addObject:[NSNumber numberWithInt:(num_BMR - 1)]];
        [_remaining_Pie reloadData];
    }
    else {
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
        if (useCaloriesBurnedTracked) {
            lblExerciseCalories.text = [NSString stringWithFormat:@"-%.0f", num_totalCaloriesBurnedTracked];
        } else {
            lblExerciseCalories.text = @"-0";
        }
    }
    
    if (!useCaloriesBurnedTracked) {
        lblBurned.text = [NSString stringWithFormat:@"%.0f", num_totalCaloriesBurned + num_totalCaloriesBurnedTracked];
    } else {
        lblBurned.text = [NSString stringWithFormat:@"%.0f", num_totalCaloriesBurned];
    }
    //if false, include in Burned tile, but don't add to Recommended tile.
    
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
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
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

- (void)animateCircularProgressbar {
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

- (void)calculateBMI {
    double bodyMassIndex = currentWeight / (currentHeight * currentHeight) * 703;
    currentBMILabel.text = [NSString stringWithFormat:@"%.1f", bodyMassIndex];
    lblCurrent_BMI.text = [NSString stringWithFormat:@"BMI: %.1f", bodyMassIndex];
}

@end
