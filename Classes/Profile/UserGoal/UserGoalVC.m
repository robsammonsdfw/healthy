

#import "UserGoalVC.h"
#import "UserMealType.h"
#import "SBPickerSelector.h"

@interface UserGoalVC ()<UITextFieldDelegate,SBPickerSelectorDelegate>
{
    SBPickerSelector *picker;
}
@property (nonatomic, strong) IBOutlet UIButton *btnLoseWeight;
@property (nonatomic, strong) IBOutlet UIButton *btnMainWeight;
@property (nonatomic, strong) IBOutlet UIButton *btnGainWeight;

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
    
    picker = [SBPickerSelector picker];
    
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

-(void)dismissKeyboard {
    [_txtGoalWeight resignFirstResponder];
    [_txtGoalRate resignFirstResponder];
}

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
                        [DMGUtilities showAlertWithTitle:@"Create Profile" message:@"Please enter goalWeight between 1 & 990." inViewController:nil];
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
                        [DMGUtilities showAlertWithTitle:@"Create Profile" message:@"Please enter goalWeight between 1 & 450." inViewController:nil];
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
                    [DMGUtilities showAlertWithTitle:@"Error" message:@"Please enter goalWeight between 1 & 450." inViewController:nil];
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
            [DMGUtilities showAlertWithTitle:@"Goal Weight" message:@"Please enter a Goal Weight." inViewController:nil];
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
                        [DMGUtilities showAlertWithTitle:@"Error" message:@"Please enter a GoalWeight between 1 & 990." inViewController:nil];
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
                        [DMGUtilities showAlertWithTitle:@"Error" message:@"Please enter a GoalWeight between 1 & 450." inViewController:nil];
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
                    [DMGUtilities showAlertWithTitle:@"Goal weight" message:@"Please enter a GoalWeight between 1 & 990." inViewController:nil];
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
                        [DMGUtilities showAlertWithTitle:@"Error" message:@"Please enter a GoalWeight between 1 & 990." inViewController:nil];
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
                        [DMGUtilities showAlertWithTitle:@"Error" message:@"Please enter a GoalWeight between 1 & 450." inViewController:nil];
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
                    [DMGUtilities showAlertWithTitle:@"Goal Weight" message:@"Please enter a GoalWeight between 1 & 990." inViewController:nil];
                    return NO;
                }
                else{
                    [_userInfoDict setObject:@"2" forKey:@"WeightGoals"];
                    [_userInfoDict setObject:self.txtGoalWeight.text forKey:@"goalWeight"];
                    [_userInfoDict setObject:goalRate forKey:@"goalRate"];
                    return YES;
                }
            }
        }else{
            [DMGUtilities showAlertWithTitle:@"Error" message:@"Please enter a GoalWeight." inViewController:nil];
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

@end
