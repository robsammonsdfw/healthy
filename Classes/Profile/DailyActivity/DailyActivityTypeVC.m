

#import "DailyActivityTypeVC.h"
#import "UserGoalVC.h"

@interface DailyActivityTypeVC ()
{
    NSUserDefaults *Defaults;
}
@property (nonatomic, strong) IBOutlet UIButton *btnJobType1;
@property (nonatomic, strong) IBOutlet UIButton *btnJobType2;
@property (nonatomic, strong) IBOutlet UIButton *btnJobType3;
@property (nonatomic, strong) IBOutlet UIButton *btnJobType4;
@property (nonatomic, strong) IBOutlet UIButton *btnJobType5;
@property (nonatomic, strong) IBOutlet UIButton *btnJobType6;
@property (nonatomic, strong) IBOutlet UIButton *btnJobType7;
@end

@implementation DailyActivityTypeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    Defaults =[NSUserDefaults standardUserDefaults];
    [_userInfoDict setObject:@"0" forKey:@"Profession"];
    [self.btnJobType1 setSelected:YES];
    [self.btnJobType5 setSelected:YES];
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationItem.hidesBackButton = YES;
    
    
    
    self.title=@"Create Profile";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationItem.hidesBackButton = YES;
    
    if([_userInfoDict objectForKey:@"Profession"] != nil)
    {
        if ([[_userInfoDict objectForKey:@"Profession"] isEqualToString:@"0"]) {
            [self.btnJobType1 setSelected:YES];
        }
        else if ([[_userInfoDict objectForKey:@"Profession"] isEqualToString:@"1"])
        {
            [self.btnJobType2 setSelected:YES];
        }else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"Profession"] isEqualToString:@"2"])
        {
            [self.btnJobType3 setSelected:YES];
        }
        else if ([[_userInfoDict objectForKey:@"Profession"] isEqualToString:@"3"])
        {
            [self.btnJobType4 setSelected:YES];
        }
    }
    
    if([_userInfoDict objectForKey:@"BodyType"] != nil)
    {
        if ([[_userInfoDict objectForKey:@"BodyType"] isEqualToString:@"0"]) {
            [self.btnJobType5 setSelected:YES];
        }
        else if ([[_userInfoDict objectForKey:@"BodyType"] isEqualToString:@"1"])
        {
            [self.btnJobType6 setSelected:YES];
        }else if ([[_userInfoDict objectForKey:@"BodyType"] isEqualToString:@"2"])
        {
            [self.btnJobType7 setSelected:YES];
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - btn Action Method -
- (IBAction)btnPreviousClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnNextClicked:(id)sender {
    if (self.btnJobType1.selected == YES)
    {
      [_userInfoDict setObject:@"0" forKey:@"Profession"];
    }
    else if (self.btnJobType2.selected == YES)
    {
        [_userInfoDict setObject:@"1" forKey:@"Profession"];
    }
    else if (self.btnJobType3.selected == YES)
    {
       [_userInfoDict setObject:@"2" forKey:@"Profession"];
    }
    else if (self.btnJobType4.selected == YES)
    {
        [_userInfoDict setObject:@"3" forKey:@"Profession"];
    }
    
    if (self.btnJobType5.selected == YES) {
        [_userInfoDict setObject:@"0" forKey:@"BodyType"];
    } else if (self.btnJobType6.selected == YES) {
        [_userInfoDict setObject:@"1" forKey:@"BodyType"];
    } else if (self.btnJobType7.selected == YES) {
        [_userInfoDict setObject:@"2" forKey:@"BodyType"];
    }
    
    UserGoalVC  *desVc= [[UserGoalVC alloc] initWithNibName:@"UserGoalVC" bundle:nil];
    desVc.userInfoDict = _userInfoDict;
    [self.navigationController pushViewController:desVc animated:YES];
}

- (IBAction)btnJobType:(id)sender {
    UIButton *btn =(UIButton*)sender;
    if (btn.tag == 13)
    {
        [self.btnJobType1 setSelected:YES];
        [self.btnJobType2 setSelected:NO];
        [self.btnJobType3 setSelected:NO];
        [self.btnJobType4 setSelected:NO];
    }
    else if (btn.tag == 14)
    {
        [self.btnJobType1 setSelected:NO];
        [self.btnJobType2 setSelected:YES];
        [self.btnJobType3 setSelected:NO];
        [self.btnJobType4 setSelected:NO];
    }
    else if (btn.tag == 15)
    {
        [self.btnJobType1 setSelected:NO];
        [self.btnJobType2 setSelected:NO];
        [self.btnJobType3 setSelected:YES];
        [self.btnJobType4 setSelected:NO];
    }
    else if (btn.tag == 16)
    {
        [self.btnJobType1 setSelected:NO];
        [self.btnJobType2 setSelected:NO];
        [self.btnJobType3 setSelected:NO];
        [self.btnJobType4 setSelected:YES];
    }
    //body type
    else if (btn.tag == 17)
    {
        [self.btnJobType5 setSelected:YES];
        [self.btnJobType6 setSelected:NO];
        [self.btnJobType7 setSelected:NO];
    }
    else if (btn.tag == 18)
    {
        [self.btnJobType5 setSelected:NO];
        [self.btnJobType6 setSelected:YES];
        [self.btnJobType7 setSelected:NO];
    }
    else if (btn.tag == 19)
    {
        [self.btnJobType5 setSelected:NO];
        [self.btnJobType6 setSelected:NO];
        [self.btnJobType7 setSelected:YES];
    }
}

@end
