

#import "UserMealType.h"
#import "OtherHealthServiceVC.h"
#import <CommonCrypto/CommonDigest.h>
#import "MBProgressHUD.h"
#import "XMLReader.h"
#import "SBPickerSelector.h"
#import "DietMasterGoAppDelegate.h"
#import "DietMasterGoViewController.h"

@interface UserMealType ()<NSURLConnectionDelegate,UITextFieldDelegate,SBPickerSelectorDelegate>
{
    SBPickerSelector *picker;
    
    NSMutableData *webData;
    NSMutableArray *soapResult;
    NSArray *pickerData;
    NSString *MealTypeID;
}
@property (nonatomic, strong) IBOutlet UIButton *btnYes;
@property (nonatomic, strong) IBOutlet UIButton *btnNo;

@end

@implementation UserMealType
@synthesize xmlParser;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.btnNo setSelected:YES];
    picker = [SBPickerSelector picker];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self getMealType];
    self.title = @"Meal Type";
    [self.navigationItem setTitle:@"Meal Type"];

    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationItem.hidesBackButton = YES;
    
    self.txtMealType.layer.borderWidth=2.0;
    self.txtMealType.layer.borderColor= [UIColor colorWithRed:48.0/255.0 green:197.0/255.0 blue:255.0/255.0 alpha:1].CGColor;
    self.txtMealType.layer.cornerRadius=4;
    self.txtMealType.clipsToBounds=YES;
    
    UILabel * leftView = [[UILabel alloc] initWithFrame:CGRectMake(10,0,7,26)];
    leftView.backgroundColor = [UIColor clearColor];
    
    self.txtMealType.leftView = leftView;
    self.txtMealType.leftViewMode = UITextFieldViewModeAlways;
}

#pragma mark - btn Action -
- (IBAction)btnPreviousClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnNextClicked:(id)sender {
    if (self.txtMealType.text.length == 0)
    {
        [DMGUtilities showAlertWithTitle:@"Error" message:@"Please Select Meal type." inViewController:nil];
    }
    else{
        [self ProfileCompletion];
    }
}

- (IBAction)btnMedicalConditionClicked:(id)sender {
    UIButton *btn =(UIButton*)sender;
    if (btn.tag == 20)
    {
        [self.btnYes setSelected:YES];
        [self.btnNo setSelected:NO];
        //reword the message. if they click YES to health condition, show the message, but allow them to continue.
        [DMGUtilities showAlertWithTitle:@"Notice" message:@"This program or products are not intended to replace the expert advice of a medical practitioner and are not designed to treat diseases of any kind. Users of this program or products assume all risk. The publishers of this application, its owners, distributors, licensors and any related parties, assume no liability or risk of any kind." inViewController:nil];
    } else if (btn.tag == 21)
    {
        [self.btnYes setSelected:NO];
        [self.btnNo setSelected:YES];
    }
}
#pragma mark - hasKey Generation method -
-(NSString *)hashKeyCalculation
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *userName = [defaults objectForKey:@"username_dietmastergo"];
    NSString *password = [defaults objectForKey:@"Password"];
    NSString *passThruKey = [defaults objectForKey:@"PassThruKey"];
    NSString *concatStr=[NSString stringWithFormat:@"%@%@%@",userName,password,passThruKey];
    
    const char * pointer = [concatStr UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(pointer, (CC_LONG)strlen(pointer), md5Buffer);
    
    NSMutableString * string = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++){
        [string appendFormat:@"%02x",md5Buffer[i]];
    }
    
    return string;
}

#pragma mark - APi Call -
-(void)getMealType
{
    [DMActivityIndicator showProgressIndicator];
    
    //http://webservice.dmwebpro.com/DMGoWS.asmx?op=GetMealTypeOptions
    NSString *companyID= [[NSUserDefaults standardUserDefaults] objectForKey:@"companyid_dietmastergo"]; // @"3271";
    NSString *ParentGroupID=@"1";
    
    NSString *soapMessage =  [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                              "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                              "<soap:Body>"
                              "<GetMealTypeOptions xmlns=\"http://webservice.dmwebpro.com/\">"
                              "<CompanyID>%@</CompanyID>"
                              "<ParentGroupID>%@</ParentGroupID>"
                              "</GetMealTypeOptions>"
                              "</soap:Body>"
                              "</soap:Envelope>",companyID,ParentGroupID];
    
    //DMLog(@"%@",soapMessage);
    // [{"UserID":"110195","CompanyID":"1127"}]
    NSURL *url = [NSURL URLWithString:@"http://webservice.dmwebpro.com/DMGoWS.asmx?op=GetMealTypeOptions"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: @"http://webservice.dmwebpro.com/GetMealTypeOptions" forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
}

-(void)ProfileCompletion
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *companyID= [[NSUserDefaults standardUserDefaults] objectForKey:@"companyid_dietmastergo"]; // @"3271";
    NSString *passThruKey= [[NSUserDefaults standardUserDefaults] objectForKey:@"companyPassThru_dietmastergo"]; //p54118!
    
    
    NSString *userName = [_userInfoDict objectForKey:@"Username"];
    NSString *password = [_userInfoDict objectForKey:@"Password"];
    NSString *firstName =[_userInfoDict objectForKey:@"FirstName"];
    NSString *lastName =[_userInfoDict objectForKey:@"LastName"];
    NSString *Email=[_userInfoDict objectForKey:@"Email"];
//
    //format the birthday
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy"]; //yyyy-MM-dd
    NSDate *formattedDate = [dateFormat dateFromString:[_userInfoDict objectForKey:@"BirthDate"]];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString*birthDate = [dateFormat stringFromDate:formattedDate];
    
    [_userInfoDict setValue:MealTypeID forKey:@"MealTypeID"];
    int Gender=[[_userInfoDict objectForKey:@"gender"] intValue];
    int Height=[[_userInfoDict objectForKey:@"userHeight"] intValue];
    int Weight=[[_userInfoDict objectForKey:@"userWeight"] intValue];
    bool lactation=[[_userInfoDict objectForKey:@"Lactating"] intValue] == 0 ? NO : YES;
    int weigthGoal=[[_userInfoDict objectForKey:@"WeightGoals"] intValue];

    NSNumber *goalRate=[NSNumber numberWithFloat:[[_userInfoDict objectForKey:@"goalRate"] floatValue]];
    int bodyType=[[_userInfoDict objectForKey:@"BodyType"] intValue];
    int Profession=[[_userInfoDict objectForKey:@"Profession"] intValue];
    
    int goalWeight;
    if ([_userInfoDict objectForKey:@"goalWeight"] != nil)
    {
        goalWeight=[[_userInfoDict objectForKey:@"goalWeight"] intValue];
    }
    
    NSMutableDictionary *dictParameter = [NSMutableDictionary dictionary];
    //if any are null we need to set them to a value
    
    [dictParameter setObject:userName forKey:@"Username"];
    [dictParameter setObject:password forKey:@"Password"];
    [dictParameter setObject:firstName forKey:@"FirstName"];
    [dictParameter setObject:lastName forKey:@"LastName"];
    [dictParameter setObject:Email forKey:@"Email"];
    [dictParameter setObject:birthDate forKey:@"BirthDate"];
    [dictParameter setObject:[NSNumber numberWithInt:Gender] forKey:@"Gender"];
    [dictParameter setObject:[NSNumber numberWithInt:Height] forKey:@"Height"];
    [dictParameter setObject:[NSNumber numberWithInt:Weight] forKey:@"Weight"];
    [dictParameter setObject:[NSNumber numberWithInt:weigthGoal] forKey:@"WeightGoals"];
    [dictParameter setObject:[NSNumber numberWithInt:Profession] forKey:@"Profession"];
    [dictParameter setObject:[NSNumber numberWithBool:lactation] forKey:@"Lactation"];
    if ([_userInfoDict objectForKey:@"goalWeight"] != nil)
    {
        [dictParameter setObject:[NSNumber numberWithInt:goalWeight] forKey:@"GoalWeight"];
    }
    [dictParameter setObject:MealTypeID forKey:@"MealTypeID"];
    //bodyType 0/1/2
    [dictParameter setObject:[NSNumber numberWithInt:bodyType] forKey:@"BodyType"];
    //goalRate 0-2
    [dictParameter setObject:goalRate forKey:@"GoalRate"];
    [dictParameter setObject:companyID forKey:@"CompanyId"];
//    [dictParameter setObject:@"0" forKey:@"GeneralUnits"];
//    [dictParameter setObject:@"0" forKey:@"EnergyUnit"];
//    [dictParameter setObject:@"0" forKey:@"DateFormat"];

//    [dictParameter setObject:@"0" forKey:@"BMRCalcMethod"];
//    [dictParameter setObject:@"0" forKey:@"HideTemplates"];
//    [dictParameter setObject:@"0" forKey:@"HeartDisease"];
//    [dictParameter setObject:@"0" forKey:@"LiverDisease"];
//    [dictParameter setObject:@"0" forKey:@"PancreaticDisease"];
//    [dictParameter setObject:@"0" forKey:@"Anemia"];
//    [dictParameter setObject:@"0" forKey:@"KidneyDisease"];
//    [dictParameter setObject:@"0" forKey:@"Hypoglycemia"];
//    [dictParameter setObject:@"0" forKey:@"Diabetes"];
//    [dictParameter setObject:@"0" forKey:@"Hypertension"];
//    [dictParameter setObject:@"0" forKey:@"HistHeartDisease"];
//    [dictParameter setObject:@"0" forKey:@"HistBreastCancer"];
//    [dictParameter setObject:@"0" forKey:@"HistCancerOther"];
//    [dictParameter setObject:@"0" forKey:@"HistLiverDisease"];
//    [dictParameter setObject:@"0" forKey:@"HistStroke"];
//    [dictParameter setObject:@"0" forKey:@"HistOsteoporosis"];
//    [dictParameter setObject:@"0" forKey:@"HistHypoglycemia"];
//    [dictParameter setObject:@"0" forKey:@"HistDiabetes"];
//    [dictParameter setObject:@"0" forKey:@"HistHypertension"];
//    [dictParameter setObject:@"1" forKey:@"returnUserID"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictParameter
                                                       options:0
                                                         error:&error];
    
    if (!jsonData) {
        DMLog(@"Got an error: %@", error);
        return;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //DMLog(@"pass Parameter is--->:%@",jsonString);
    
    //create body for company login
    NSString *companyAuthBody = [NSString stringWithFormat:@"{\"companyId\": \"%@\",\"passThruKey\": \"%@\"}", companyID, passThruKey];
    
    [DMActivityIndicator showProgressIndicatorWithMessage:@"Creating your profile"];
    
    NSURL *companyLoginUrl = [NSURL URLWithString:@"https://api.dmwebpro.com/authentication/companylogin"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:companyLoginUrl];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[companyAuthBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"*/*" forHTTPHeaderField:@"Accept"];
    
    //LOGIN AS COMPANY
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *repsone, NSData *data, NSError *connectionError) {
        if (data.length > 0 && connectionError == nil) {
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            NSString *companyIdToken = [response objectForKey:@"authToken"];
            
            [DMActivityIndicator showProgressIndicatorWithMessage:@"Almost finished..."];

            //CREATE USER PROFILE
            NSURL *addUserProfileUrl = [NSURL URLWithString:@"https://api.dmwebpro.com/CompanyUser/adduserprofile"];
            NSMutableURLRequest *profileRequest = [NSMutableURLRequest requestWithURL:addUserProfileUrl];
            [profileRequest setHTTPMethod:@"POST"];
            [profileRequest setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
            [profileRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [profileRequest addValue:@"*/*" forHTTPHeaderField:@"Accept"];
            [profileRequest addValue:[NSString stringWithFormat:@"Bearer %@", companyIdToken] forHTTPHeaderField:@"Authorization"];

            [NSURLConnection sendAsynchronousRequest:profileRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *repsone, NSData *data, NSError *connectionError) {
                if (data.length > 0 && connectionError == nil) {
                    NSDictionary *profileResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                    if ([[profileResponse objectForKey:@"result"] isEqualToString:@"Failed"] || [[profileResponse objectForKey:@"status"] intValue] == 400) {
                        [DMActivityIndicator hideActivityIndicator];
                        
                        NSString *errorMessage = [profileResponse objectForKey:@"errorMessage"];
                        if (!errorMessage || [errorMessage isEqualToString:@""]) {
                            errorMessage = @"You have had one or more validation errors.";
                        }
                        
                        [DMGUtilities showAlertWithTitle:@"Error" message:errorMessage inViewController:nil];

                    } else {
                        [defaults setValue:[profileResponse objectForKey:@"mobileToken"] forKey:@"authkey_dietmastergo"];
                        [defaults setValue:[profileResponse objectForKey:@"userId"] forKey:@"userid_dietmastergo"];
                        [defaults synchronize];

                        [DMActivityIndicator showCompletedIndicator];
                        
                        [self dismissViewControllerAnimated:YES completion:^() {
                            DietMasterGoAppDelegate *appDelegate = (DietMasterGoAppDelegate *)[[UIApplication sharedApplication] delegate];
                            
                            [appDelegate loginFromUrl:[NSString stringWithFormat:@"%@:%@", [defaults objectForKey:@"authkey_dietmastergo"], [_userInfoDict objectForKey:@"Username"]]];
                        }];
                    }
                } else {
                    [DMActivityIndicator hideActivityIndicator];
                }
            }];
            
        } else {
            [DMActivityIndicator hideActivityIndicator];
        }
    }];
}


#pragma mark - textFiled Delegate method -
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.txtMealType resignFirstResponder];
    if (textField == self.txtMealType)
    {
        NSArray *arr = pickerData;
        
        if (arr.count >0)
        {
            picker.pickerData = arr ;
            picker.pickerType = SBPickerSelectorTypeText;
            picker.delegate = self;
            picker.doneButtonTitle = @"Done";
            picker.cancelButtonTitle = @"Cancel";
            [picker showPickerOver:self];
        }
        else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (arr.count > 0)
                {
                    picker.pickerData = arr ;
                    picker.pickerType = SBPickerSelectorTypeText;
                    picker.delegate = self;
                    picker.doneButtonTitle = @"Done";
                    picker.cancelButtonTitle = @"Cancel";
                    [picker showPickerOver:self];
                }
            });
        }
    }
}

#pragma mark - NSURLConnection delegate method -
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [webData setLength: 0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [webData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [DMActivityIndicator hideActivityIndicator];
    DMLog(@"Error: %@",[error description]);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [DMActivityIndicator hideActivityIndicator];

    NSString *theXML = [[NSString alloc] initWithBytes: [webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
    //DMLog(@"%@",theXML);
    
    NSError *error=nil;
    NSDictionary *xmlDict = [XMLReader dictionaryForXMLString:theXML error:&error];
    
    NSString *resultString = [[[[[xmlDict objectForKey:@"soap:Envelope"] objectForKey:@"soap:Body"] objectForKey:@"GetMealTypeOptionsResponse"] objectForKey:@"GetMealTypeOptionsResult"] objectForKey:@"text"];
    DMLog(@"%@", resultString);
    
    NSDictionary *jsonObject = @{};
    if (resultString.length) {
        jsonObject = [NSJSONSerialization JSONObjectWithData:[resultString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil][1];
    }
    
    soapResult = [jsonObject objectForKey:@"MealTypeCategories"];
    pickerData = [soapResult valueForKey:@"Description"];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
}

#pragma mark - Picker -
-(void)pickerSelector:(SBPickerSelector *)selector selectedValue:(NSString *)value index:(NSInteger)idx {
    MealTypeID = [[soapResult objectAtIndex:idx] objectForKey:@"MealTypeID"];
    self.txtMealType.text=value;
}

-(void)pickerSelector:(SBPickerSelector *)selector cancelPicker:(BOOL)cancel {
    DMLog(@"Picker canceled ...");
}

@end
