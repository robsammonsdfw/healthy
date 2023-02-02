//
//  PopUpView.m
//  MyMoves
//
//  Created by CIPL0688 on 11/25/19.
//

#import "PopUpView.h"
#import "MyGoalViewController.h"

@interface PopUpView ()

@property (retain, nonatomic) IBOutlet UIStackView *homeStack;
@property (retain, nonatomic) IBOutlet UIStackView *weightStack;
@property (retain, nonatomic) IBOutlet UIStackView *journalStack;
@property (retain, nonatomic) IBOutlet UIStackView *plannedStack;
@property (retain, nonatomic) IBOutlet UIStackView *settingsStack;

@property (retain, nonatomic) IBOutlet UIView *homeSelectedVw;
@property (retain, nonatomic) IBOutlet UIView *weightSelectedVw;
@property (retain, nonatomic) IBOutlet UIView *jousnalSelectedVw;
@property (retain, nonatomic) IBOutlet UIView *plannedSelecetdVw;
@property (retain, nonatomic) IBOutlet UIView *settingsSelectedVw;

@property (retain, nonatomic) IBOutlet UIImageView *homeImgVw;
@property (retain, nonatomic) IBOutlet UIImageView *weightImgVw;
@property (retain, nonatomic) IBOutlet UIImageView *journalImgVw;
@property (retain, nonatomic) IBOutlet UIImageView *plannedImgVw;
@property (retain, nonatomic) IBOutlet UIImageView *settingsImgVw;
@property (retain, nonatomic) IBOutlet UIImageView *myMovesImgVw;

@property (retain, nonatomic) IBOutlet UILabel *homeLbl;
@property (retain, nonatomic) IBOutlet UILabel *weightLbl;
@property (retain, nonatomic) IBOutlet UILabel *journalLbl;
@property (retain, nonatomic) IBOutlet UILabel *plannedLbl;
@property (retain, nonatomic) IBOutlet UILabel *settingsLbl;
@property (retain, nonatomic) IBOutlet UILabel *myMovesLbl;

@property (retain, nonatomic) IBOutlet UIStackView *mmStackVw;

@property (retain, nonatomic) IBOutlet UIButton *mmBtn;
@property (retain, nonatomic) IBOutlet UIView *myMovesSelectedVw;

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


- (void)dealloc {
    [_popUpView release];
    [_homeStack release];
    [_weightStack release];
    [_journalStack release];
    [_plannedStack release];
    [_settingsStack release];
    [_homeSelectedVw release];
    [_weightSelectedVw release];
    [_weightSelectedVw release];
    [_jousnalSelectedVw release];
    [_plannedSelecetdVw release];
    [_settingsSelectedVw release];
    [_homeImgVw release];
    [_weightImgVw release];
    [_journalImgVw release];
    [_plannedImgVw release];
    [_settingsImgVw release];
    [_homeLbl release];
    [_weightLbl release];
    [_journalLbl release];
    [_plannedLbl release];
    [_settingsLbl release];
    [_mmStackVw release];
    [_myMovesImgVw release];
    [_myMovesLbl release];
    [_mmBtn release];
    [_myMovesSelectedVw release];
    [super dealloc];
}
@end

