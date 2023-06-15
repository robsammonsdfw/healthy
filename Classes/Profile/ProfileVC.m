

#import "ProfileVC.h"
#import "DailyActivityTypeVC.h"
#import "TDDatePickerController.h"


@interface ProfileVC ()<UITextFieldDelegate>
{
    int flag;
    MBProgressHUD *HUD;
    NSString *dateFromateType;
    
    //HHT change check BD validation
    NSDate *selectedBDate;
    NSDate *currentDate;
    
}
@end

@implementation ProfileVC

#pragma mark - ViewLifeCycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    flag=0;
    [self.btnMale setSelected:YES];
    // Do any additional setup after loading the view from its nib.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(dismissKeyboard)];

    [self.view addGestureRecognizer:tap];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [HUD removeFromSuperview];

//    [IQKeyboardManager sharedManager].shouldShowToolbarPlaceholder=NO;
    
    self.title=@"Profile";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationItem.hidesBackButton = YES;
    
    self.txtBirthDate.layer.borderWidth=2.0;
    self.txtBirthDate.layer.borderColor=[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0].CGColor;
    self.txtBirthDate.layer.cornerRadius=4;
    self.txtBirthDate.clipsToBounds=YES;
    
    self.txtHeight.layer.borderWidth=2.0;
    self.txtHeight.layer.borderColor=[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0].CGColor;
    self.txtHeight.layer.cornerRadius=4;
    self.txtHeight.clipsToBounds=YES;
    
    self.txtWeight.layer.borderWidth=2.0;
    self.txtWeight.layer.borderColor=[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0].CGColor;
    self.txtWeight.layer.cornerRadius=4;
    self.txtWeight.clipsToBounds=YES;
    
    
    NSString *fmt = [NSDateFormatter dateFormatFromTemplate:@"dd MM YYYY" options:0 locale:[NSLocale currentLocale]];
    self.txtBirthDate.placeholder=fmt;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"GeneralUnits"] != nil)
    {
        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"GeneralUnits"] isEqualToString:@"0"])
        {
            self.txtWeight.placeholder=@"Pounds";
        }
        else{
            self.txtWeight.placeholder=@"Kgs";
        }
    }
    if([_userInfoDict objectForKey:@"BirthDate"] != nil)
    {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"DateFormat"]!= nil)
        {
            dateFromateType=[[NSUserDefaults standardUserDefaults] objectForKey:@"DateFormat"];
            if ([dateFromateType isEqualToString:@"0"])
            {
                [dateFormat setDateFormat:@"MM/dd/yyyy"];
            }else{
                [dateFormat setDateFormat:@"dd/MM/yyyy"];
            }
        } else {
            [dateFormat setDateFormat:@"dd/MM/yyyy"];
        }
        
        NSDate *BDate = [dateFormat dateFromString:[_userInfoDict objectForKey:@"BirthDate"]];
        
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        NSString *dateString = [dateFormatter stringFromDate:BDate];
        self.txtBirthDate.text=dateString;
    }
    if ([_userInfoDict objectForKey:@"gender"] != nil)
    {
        if ([[_userInfoDict objectForKey:@"gender"] isEqualToString:@"1"])
        {
            [self.btnMale setSelected:YES];
        }
        else if ([[_userInfoDict objectForKey:@"gender"] isEqualToString:@"0"])
        {
            [self.btnFemale setSelected:NO];
        }
    }
    if ([_userInfoDict objectForKey:@"userHeight"] != nil) {
        self.txtHeight.text=[_userInfoDict objectForKey:@"userHeight"];
    }
    if ([_userInfoDict objectForKey:@"userWeight"] != nil) {
        self.txtWeight.text=[_userInfoDict objectForKey:@"userWeight"];
    }
    if ([_userInfoDict objectForKey:@"Lactating"] != nil) {
        if ([[_userInfoDict objectForKey:@"Lactating"] isEqualToString:@"0"])
        {
            [self.btnLactating setImage:[UIImage imageNamed:@"radio_btn.png"] forState:UIControlStateNormal];
        }
        else{
            [self.btnLactating setImage:[UIImage imageNamed:@"radio_btn_act.png"] forState:UIControlStateNormal];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)dismissKeyboard {
    [_txtHeight resignFirstResponder];
    [_txtWeight resignFirstResponder];
    [_txtBirthDate resignFirstResponder];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    [HUD removeFromSuperview];
    [HUD release];
    HUD = nil;
}

#pragma mark - button Action -
- (IBAction)btnGenderClicked:(id)sender {
    UIButton *btn=(UIButton*)sender;
    if (btn.tag == 10)
    {
        [self.btnMale setSelected:YES];
        [self.btnFemale setSelected:NO];
    }
    else if(btn.tag == 11)
    {
        [self.btnMale setSelected:NO];
        [self.btnFemale setSelected:YES];
    }
}

- (IBAction)btnPreviousClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnNextClicked:(id)sender {
    if ([self validation])
    {
        DailyActivityTypeVC *desVc= [[DailyActivityTypeVC alloc] initWithNibName:@"DailyActivityTypeVC" bundle:nil];
        desVc.userInfoDict = _userInfoDict;
        [self.navigationController pushViewController:desVc animated:YES];
    }
}

- (IBAction)btnFemaleType:(id)sender {
    UIButton *btn =(UIButton*)sender;
    if (flag == 0)
    {
        flag=1;
        [btn setImage:[UIImage imageNamed:@"radio_btn_act.png"] forState:UIControlStateNormal];
    }
    else if (flag ==1){
        flag=0;
        [btn setImage:[UIImage imageNamed:@"radio_btn.png"] forState:UIControlStateNormal];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.txtBirthDate) {
        NSDate *eventDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        
        
        UIDatePicker *datePicker = [[UIDatePicker alloc]init];
        [datePicker setDate:[NSDate date]];
        datePicker.frame = CGRectMake(0, 0, 320, SCREEN_HEIGHT/3);
        datePicker.datePickerMode = UIDatePickerModeDate;
        [datePicker addTarget:self action:@selector(dateTextField:) forControlEvents:UIControlEventValueChanged];
        [self.txtBirthDate setInputView:datePicker];
        
        NSString *dateString = [dateFormatter stringFromDate:eventDate];
        self.txtBirthDate.text = [NSString stringWithFormat:@"%@",dateString];
    }
}

//HHT change check BD validation
-(void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.txtBirthDate){
        UIDatePicker *picker = (UIDatePicker*)self.txtBirthDate.inputView;

        selectedBDate = picker.date;
        currentDate = [NSDate date];

        NSComparisonResult result;

        result = [currentDate compare:selectedBDate]; // comparing two dates

        if(result==NSOrderedAscending) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Create Profile" message:@"Birthdate must not be greater than current date!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        else if(result==NSOrderedDescending){
            DMLog(@"newDate is less");
        }
        else {
            DMLog(@"Both dates are same");
        }
    }
}

-(void)dateTextField:(id)sender {
    UIDatePicker *picker = (UIDatePicker*)self.txtBirthDate.inputView;
    //[picker setMaximumDate:[NSDate date]];
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    
    NSDate *eventDate = picker.date;
    
    //HHT change check BD validation
    selectedBDate = eventDate;
    currentDate = [NSDate date];
    
    NSComparisonResult result;
    
    result = [currentDate compare:selectedBDate]; // comparing two dates
    
    if(result==NSOrderedAscending) {
        DMLog(@"newDate is in the future");
        return;
    }
    else if(result==NSOrderedDescending){
        DMLog(@"newDate is less");
    }
    else {
        DMLog(@"Both dates are same");
    }
    
    NSString *dateString = [dateFormatter stringFromDate:eventDate];
    self.txtBirthDate.text = [NSString stringWithFormat:@"%@",dateString];
}

#pragma mark - ValiDation Function Reema -
-(BOOL)validation
{
    if (self.btnMale.selected == YES)
    {
        [_userInfoDict setObject:@"0" forKey:@"gender"];
    }
    else if (self.btnFemale.selected == YES)
    {
        [_userInfoDict setObject:@"1" forKey:@"gender"];
    }
    if (self.txtBirthDate.text.length == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please Select Date" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else{
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        
        NSDate *BDate = [dateFormatter dateFromString:_txtBirthDate.text];
        DMLog(@"date selected  : %@", [BDate descriptionWithLocale:[NSLocale currentLocale]]);
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"DateFormat"]!= nil)
        {
            dateFromateType=[[NSUserDefaults standardUserDefaults] objectForKey:@"DateFormat"];
            if ([dateFromateType isEqualToString:@"0"])
            {
                [dateFormat setDateFormat:@"MM/dd/yyyy"];
            }
            else{
                
                [dateFormat setDateFormat:@"dd/MM/yyyy"];
            }
        } else {
            [dateFormat setDateFormat:@"dd/MM/yyyy"];
        }
        NSString *dateString = [dateFormat stringFromDate:BDate];
        DMLog(@"Date in String is---:%@",dateString);
        
        [_userInfoDict setObject:dateString forKey:@"BirthDate"];
    }
    float weight =[self.txtWeight.text floatValue];
    NSString *GeneralUnits;
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"GeneralUnits"]!= nil)
    {
        GeneralUnits=[[NSUserDefaults standardUserDefaults] objectForKey:@"GeneralUnits"];
        if ([GeneralUnits isEqualToString:@"0"])
        {
            if (weight <1.00 || weight >990.00)
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Create Profile" message:@"Please enter Weight between 1 & 990" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                return NO;
            }
            else{
                [_userInfoDict setObject:self.txtWeight.text forKey:@"userWeight"];
                [_userInfoDict setObject:[@(flag) stringValue] forKey:@"Lactating"];
                //                return YES;
            }
        }
        else if([GeneralUnits isEqualToString:@"1"])
        {
            if (weight <1.00 || weight >450.00)
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Create Profile" message:@"Please enter Weight between 1 & 450" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                return NO;
            }
            else{
                [_userInfoDict setObject:self.txtWeight.text forKey:@"userWeight"];
                [_userInfoDict setObject:[@(flag) stringValue] forKey:@"Lactating"];
                //                return YES;
            }
        }
    }
    else {
        if (weight <1.00 || weight >990.00)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please enter Weight between 1 & 990" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return NO;
        }
        else{
            [_userInfoDict setObject:self.txtWeight.text forKey:@"userWeight"];
            [_userInfoDict setObject:[@(flag) stringValue] forKey:@"Lactating"];
            //                return YES;
        }
    }
    float height = [self.txtHeight.text floatValue];
    if (height < 12.00 || height > 119.00)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please enter Height between 12 & 119 inches" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else{
        [_userInfoDict setObject:self.txtHeight.text forKey:@"userHeight"];
    }
    return YES;
}
#pragma mark - ToolBar method -
-(void)doneClicked:(id)sender
{
    UITextField *textField =(UITextField *)sender;
    if (textField == self.txtHeight)
    {
        DMLog(@"height textField");
    }
    else if (textField == self.txtWeight)
    {
        DMLog(@"Weight textField");
    }
    [self.view endEditing:YES];
}

- (void)dealloc {
    [_txtBirthDate release];
    [_txtWeight release];
    [_txtHeight release];
    [_btnMale release];
    [_btnFemale release];
    [_txtHeight release];
    [_btnLactating release];
    [super dealloc];
}

@end
