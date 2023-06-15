

#import "UserGoalVC.h"
#import "UserMealType.h"
#import "SBPickerSelector.h"

@interface UserGoalVC ()<UITextFieldDelegate,SBPickerSelectorDelegate>
{
    SBPickerSelector *picker;
}
@property (retain, nonatomic) IBOutlet UIButton *btnLoseWeight;
@property (retain, nonatomic) IBOutlet UIButton *btnMainWeight;
@property (retain, nonatomic) IBOutlet UIButton *btnGainWeight;

@end

@implementation UserGoalVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.btnLoseWeight setSelected:YES];
    
    if ([_userInfoDict valueForKey:@"WeightGoals"] == nil) {
        [_userInfoDict setObject:@"0" forKey:@"WeightGoals"];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(dismissKeyboard)];

    [self.view addGestureRecognizer:tap];
    
    picker = [[SBPickerSelector picker] retain];
    
    self.txtGoalRate.text = @"1.00";
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
//    [IQKeyboardManager sharedManager].shouldShowToolbarPlaceholder=NO;
    self.title=@"Set Goals";
   
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationItem.hidesBackButton = YES;
   
    if([_userInfoDict objectForKey:@"WeightGoals"] != nil)
    {
        if ([[_userInfoDict objectForKey:@"WeightGoals"] isEqualToString:@"0"])
        {
            [self.btnLoseWeight setSelected:YES];
        }
        else if ([[_userInfoDict objectForKey:@"WeightGoals"] isEqualToString:@"1"])
        {
            [self.btnMainWeight setSelected:YES];
        }
        else if ([[_userInfoDict objectForKey:@"WeightGoals"] isEqualToString:@"2"])
        {
            [self.btnGainWeight setSelected:YES];
        }
    }
    if([_userInfoDict objectForKey:@"goalWeight"] != nil)
    {
        if([[_userInfoDict objectForKey:@"goalWeight"] isEqualToString:@"0"])
        {
            self.txtGoalWeight.text=@"";
        }
        else{
            self.txtGoalWeight.text=[_userInfoDict objectForKey:@"goalWeight"];
        }
    }
    
    if ([_userInfoDict objectForKey:@"goalRate"] != nil) {
        self.txtGoalRate.text = [_userInfoDict objectForKey:@"goalRate"];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard {
    [_txtGoalWeight resignFirstResponder];
    [_txtGoalRate resignFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Btn Action Method -
- (IBAction)btnNextClicked:(id)sender {
    if ([self Validation])
    {
        UserMealType  *desVc= [[UserMealType alloc] initWithNibName:@"UserMealType" bundle:nil];
        desVc.userInfoDict = _userInfoDict;
        [self.navigationController pushViewController:desVc animated:YES];
    }
}

- (IBAction)btnPreviousClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)btnGoalWeightClicked:(id)sender {
    UIButton *btn =(UIButton*)sender;
    if (btn.tag == 17)
    {
        [self.btnLoseWeight setSelected:YES];
        [self.btnMainWeight setSelected:NO];
        [self.btnGainWeight setSelected:NO];
    }
    else if (btn.tag == 18)
    {
        [self.btnLoseWeight setSelected:NO];
        [self.btnMainWeight setSelected:YES];
        [self.btnGainWeight setSelected:NO];
    }
    else if (btn.tag == 19)
    {
        [self.btnLoseWeight setSelected:NO];
        [self.btnMainWeight setSelected:NO];
        [self.btnGainWeight setSelected:YES];
    }
}
#pragma mark - Validation method -
-(BOOL)Validation
{
    //if MAINTAIN, GOAL RATE NOT REQUIRED
    float goalWeight =[self.txtGoalWeight.text floatValue];
    
    NSString *goalRate = self.txtGoalRate.text;
    if ([goalRate isEqualToString:@""] || goalRate == nil) {
        goalRate = self.btnMainWeight.selected == YES ? @"0" : @"1";
    }
    
    if (self.btnLoseWeight.selected == YES)
    {
        if (self.txtGoalWeight.text.length > 0)
        {
            if([[NSUserDefaults standardUserDefaults] objectForKey:@"GeneralUnits"] != nil)
            {
                if([[[NSUserDefaults standardUserDefaults] objectForKey:@"GeneralUnits"] isEqualToString:@"0"])
                {
                    if (goalWeight <1.00 || goalWeight >990.00)
                    {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Create Profile" message:@"Please enter goalWeight between 1 & 990" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alert show];
                        return NO;
                    }
                    else{
                        [_userInfoDict setObject:@"0" forKey:@"WeightGoals"];
                        [_userInfoDict setObject:self.txtGoalWeight.text forKey:@"goalWeight"];
                        [_userInfoDict setObject:goalRate forKey:@"goalRate"];
                        return YES;
                    }
                }
                else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"GeneralUnits"] isEqualToString:@"1"])
                {
                    if (goalWeight <1.00 || goalWeight >450.00)
                    {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please enter goalWeight between 1 & 450" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alert show];
                        return NO;
                    }
                    else{
                        [_userInfoDict setObject:@"0" forKey:@"WeightGoals"];
                        [_userInfoDict setObject:self.txtGoalWeight.text forKey:@"goalWeight"];
                        [_userInfoDict setObject:goalRate forKey:@"goalRate"];
                        return YES;
                    }
                }
            } else {
                if (goalWeight <1.00 || goalWeight >450.00)
                {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please enter goalWeight between 1 & 450" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    return NO;
                }
                else{
                    [_userInfoDict setObject:@"0" forKey:@"WeightGoals"];
                    [_userInfoDict setObject:self.txtGoalWeight.text forKey:@"goalWeight"];
                    [_userInfoDict setObject:goalRate forKey:@"goalRate"];
                    return YES;
                }
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Goal Weight" message:@"Please enter Goal Weight" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return NO;
        }
    }
    else if (self.btnMainWeight.selected == YES)
    {
        if (self.txtGoalWeight.text.length > 0)
        {
            if([[NSUserDefaults standardUserDefaults] objectForKey:@"GeneralUnits"] != nil)
            {
                if([[[NSUserDefaults standardUserDefaults] objectForKey:@"GeneralUnits"] isEqualToString:@"0"])
                {
                    if (goalWeight <1.00 || goalWeight >990.00)
                    {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please enter goalWeight between 1 & 990" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alert show];
                        return NO;
                    }
                    else{
                        [_userInfoDict setObject:@"1" forKey:@"WeightGoals"];
                        [_userInfoDict setObject:self.txtGoalWeight.text forKey:@"goalWeight"];
                        [_userInfoDict setObject:goalRate forKey:@"goalRate"];
                        return YES;
                    }
                }
                else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"GeneralUnits"] isEqualToString:@"1"])
                {
                    if (goalWeight <1.00 || goalWeight >450.00)
                    {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please enter goalWeight between 1 & 450" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alert show];
                        return NO;
                    }
                    else{
                        [_userInfoDict setObject:@"1" forKey:@"WeightGoals"];
                        [_userInfoDict setObject:self.txtGoalWeight.text forKey:@"goalWeight"];
                        [_userInfoDict setObject:goalRate forKey:@"goalRate"];
                        return YES;
                    }
                }
            } else {
                if (goalWeight <1.00 || goalWeight >990.00)
                {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Goal weight" message:@"Please enter a weight between 1 & 990" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    return NO;
                }
                else{
                    [_userInfoDict setObject:@"1" forKey:@"WeightGoals"];
                    [_userInfoDict setObject:self.txtGoalWeight.text forKey:@"goalWeight"];
                    [_userInfoDict setObject:goalRate forKey:@"goalRate"];
                    return YES;
                }
            }
            [_userInfoDict setObject:goalRate forKey:@"goalRate"];
//            [Defaults setObject:self.txtGoalWeight.text forKey:@"goalWeight"];
        }
        else{
            [_userInfoDict setObject:@"0" forKey:@"goalWeight"];
            [_userInfoDict setObject:goalRate forKey:@"goalRate"];
        }
    }
    else if (self.btnGainWeight.selected == YES)
    {
        if(self.txtGoalWeight.text.length > 0)
        {
            
            if([[NSUserDefaults standardUserDefaults] objectForKey:@"GeneralUnits"] != nil)
            {
                if([[[NSUserDefaults standardUserDefaults] objectForKey:@"GeneralUnits"] isEqualToString:@"0"])
                {
                    if (goalWeight <1.00 || goalWeight >990.00)
                    {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please enter goalWeight between 1 & 990" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alert show];
                        return NO;
                    }
                    else{
                        [_userInfoDict setObject:@"2" forKey:@"WeightGoals"];
                        [_userInfoDict setObject:self.txtGoalWeight.text forKey:@"goalWeight"];
                        [_userInfoDict setObject:goalRate forKey:@"goalRate"];
                        return YES;
                    }
                }
                else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"GeneralUnits"] isEqualToString:@"1"])
                {
                    if (goalWeight <1.00 || goalWeight >450.00)
                    {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please enter goalWeight between 1 & 450" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alert show];
                        return NO;
                    }
                    else{
                        [_userInfoDict setObject:@"2" forKey:@"WeightGoals"];
                        [_userInfoDict setObject:self.txtGoalWeight.text forKey:@"goalWeight"];
                        [_userInfoDict setObject:goalRate forKey:@"goalRate"];
                        return YES;
                    }
                }
            } else {
                if (goalWeight <1.00 || goalWeight >990.00)
                {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Goal weight" message:@"Please enter weight between 1 & 990" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    return NO;
                }
                else{
                    [_userInfoDict setObject:@"2" forKey:@"WeightGoals"];
                    [_userInfoDict setObject:self.txtGoalWeight.text forKey:@"goalWeight"];
                    [_userInfoDict setObject:goalRate forKey:@"goalRate"];
                    return YES;
                }
            }
//            [Defaults setObject:self.txtGoalWeight.text forKey:@"goalWeight"];
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please enter Goal Weight" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return NO;
        }
    }
    [_userInfoDict setObject:goalRate forKey:@"goalRate"];
    return  YES;
}

#pragma mark - textFiled Delegate method -
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.txtGoalRate resignFirstResponder];
    if (textField == self.txtGoalRate)
    {
        NSArray *arr = @[@".25", @".50", @".75", @"1.00", @"1.25", @"1.50", @"1.75", @"2.00"];
        
        if (arr.count >0)
        {
            picker.pickerData = arr ;
            picker.pickerType = SBPickerSelectorTypeText;
            picker.delegate = self;
            picker.doneButtonTitle = @"Done";
            picker.cancelButtonTitle = @"Cancel";
            [picker showPickerOver:self];
        }
    }
}

#pragma mark - Picker -
-(void)pickerSelector:(SBPickerSelector *)selector selectedValue:(NSString *)value index:(NSInteger)idx {
    DMLog(@"%@",value);
    self.txtGoalRate.text=value;
}

-(void)pickerSelector:(SBPickerSelector *)selector cancelPicker:(BOOL)cancel {
    DMLog(@"Picker canceled ...");
}



- (void)dealloc {
    [_btnLoseWeight release];
    [_btnMainWeight release];
    [_btnGainWeight release];
    [_txtGoalWeight release];
    [super dealloc];
}
@end
