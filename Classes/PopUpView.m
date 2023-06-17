//
//  PopUpView.m
//  MyMoves
//
//  Created by CIPL0688 on 11/25/19.
//

#import "PopUpView.h"
#import "MyGoalViewController.h"

@interface PopUpView ()

@property (nonatomic, strong) IBOutlet UIStackView *homeStack;
@property (nonatomic, strong) IBOutlet UIStackView *weightStack;
@property (nonatomic, strong) IBOutlet UIStackView *journalStack;
@property (nonatomic, strong) IBOutlet UIStackView *plannedStack;
@property (nonatomic, strong) IBOutlet UIStackView *settingsStack;

@property (nonatomic, strong) IBOutlet UIView *homeSelectedVw;
@property (nonatomic, strong) IBOutlet UIView *weightSelectedVw;
@property (nonatomic, strong) IBOutlet UIView *jousnalSelectedVw;
@property (nonatomic, strong) IBOutlet UIView *plannedSelecetdVw;
@property (nonatomic, strong) IBOutlet UIView *settingsSelectedVw;

@property (nonatomic, strong) IBOutlet UIImageView *homeImgVw;
@property (nonatomic, strong) IBOutlet UIImageView *weightImgVw;
@property (nonatomic, strong) IBOutlet UIImageView *journalImgVw;
@property (nonatomic, strong) IBOutlet UIImageView *plannedImgVw;
@property (nonatomic, strong) IBOutlet UIImageView *settingsImgVw;
@property (nonatomic, strong) IBOutlet UIImageView *myMovesImgVw;

@property (nonatomic, strong) IBOutlet UILabel *homeLbl;
@property (nonatomic, strong) IBOutlet UILabel *weightLbl;
@property (nonatomic, strong) IBOutlet UILabel *journalLbl;
@property (nonatomic, strong) IBOutlet UILabel *plannedLbl;
@property (nonatomic, strong) IBOutlet UILabel *settingsLbl;
@property (nonatomic, strong) IBOutlet UILabel *myMovesLbl;

@property (nonatomic, strong) IBOutlet UIStackView *mmStackVw;

@property (nonatomic, strong) IBOutlet UIButton *mmBtn;
@property (nonatomic, strong) IBOutlet UIView *myMovesSelectedVw;

@end

@implementation PopUpView
{
    NSString *strWeightStatus;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.popUpView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.popUpView.layer.shadowOffset = CGSizeMake(0.0, 10.0); //Here your control your spread
    self.popUpView.layer.shadowOpacity = 0.5;
    self.popUpView.layer.shadowRadius = 5.0; //Here your control your blur

    [self imageColor:_homeImgVw];
    [self imageColor:_weightImgVw];
    [self imageColor:_journalImgVw];
    [self imageColor:_plannedImgVw];
    [self imageColor:_settingsImgVw];
    [self imageColor:_myMovesImgVw];

    if ([_vc isEqual: @"DietMasterGoViewController"])
    {
        [self ChangeClrForSelectedVw:_homeSelectedVw selectedImg:_homeImgVw selectedLbl:_homeLbl];
    }
    else if ([_vc isEqual: @"MyGoalViewController"])
    {
        [self ChangeClrForSelectedVw:_weightSelectedVw selectedImg:_weightImgVw selectedLbl:_weightLbl];
    }
    else if ([_vc isEqual: @"MyLogViewController"])
    {
        [self ChangeClrForSelectedVw:_jousnalSelectedVw selectedImg:_journalImgVw selectedLbl:_journalLbl];
    }
    else if ([_vc isEqual: @"MealPlanViewController"])
    {
        [self ChangeClrForSelectedVw:_plannedSelecetdVw selectedImg:_plannedImgVw selectedLbl:_plannedLbl];
    }
    else if ([_vc isEqual: @"AppSettings"])
    {
        [self ChangeClrForSelectedVw:_settingsSelectedVw selectedImg:_settingsImgVw selectedLbl:_settingsLbl];
    }
    else if ([_vc isEqual: @"MyMoves"])
    {
        [self ChangeClrForSelectedVw:_myMovesSelectedVw selectedImg:_myMovesImgVw selectedLbl:_myMovesLbl];
    }

    if (![[[NSUserDefaults standardUserDefaults] stringForKey:@"switch"]  isEqual: @"MyMoves"])
    {
        self.mmStackVw.hidden = YES;
        self.mmBtn.hidden = YES;
    }
    
}

- (IBAction)dismissOnTap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [_gotoDelegate hideShowPopUpView];
    }];
}

- (IBAction)dismissBtnAction:(id)sender {
    [self dismissViewControllerAnimated:false completion:^{
        [_gotoDelegate hideShowPopUpView];
    }];
}
- (IBAction)gotoHome:(id)sender {
    [self dismissViewControllerAnimated:false completion:^{
        [_gotoDelegate DietMasterGoViewController];
    }];
}
- (IBAction)myGoal:(id)sender {
    [self dismissViewControllerAnimated:false completion:^{
        [_gotoDelegate MyGoalViewController];
    }];
}

- (IBAction)gotoMyLog:(id)sender {
    [self dismissViewControllerAnimated:false completion:^{
        [_gotoDelegate MyLogViewController];
    }];
}
- (IBAction)gotoMyMeal:(id)sender {
    [self dismissViewControllerAnimated:false completion:^{
        [_gotoDelegate MealPlanViewController];
    }];
}
- (IBAction)gotoAppSett:(id)sender {
    [self dismissViewControllerAnimated:false completion:^{
        [_gotoDelegate AppSettings];
    }];
}
- (IBAction)gotoMyMove:(id)sender {
    [self dismissViewControllerAnimated:false completion:^{
        [_gotoDelegate MyMovesViewController];
    }];
}

-(void)imageColor:(UIImageView *)image
{
    image.image = [image.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [image setTintColor:[UIColor blackColor]];
}

-(void)ChangeClrForSelectedVw:(UIView *)view selectedImg:(UIImageView *)imageVw selectedLbl:(UILabel *)lbl
{
    view.backgroundColor = UIColorFromHex(0xE69800);
    
    imageVw.image = [imageVw.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [imageVw setTintColor:UIColorFromHex(0xE69800)];
    
    lbl.textColor = UIColorFromHex(0xE69800);
}

@end
