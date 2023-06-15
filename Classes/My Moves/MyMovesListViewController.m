//
//  MyMovesListViewController.m
//  MyMoves
//
//  Created by Sathis Kumar on 24/01/19.
//

#import "MyMovesListViewController.h"
#import "PickerViewController.h"
#import "Reachability.h"
#import "MyMovesDetailsViewController.h"
#import "MBProgressHUD.h"

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

@interface MyMovesListViewController ()<WSWorkoutList,WSCategoryList,UITableViewDelegate,UITableViewDataSource,SelectedBodyPartDelegate,UISearchBarDelegate>
{
    IBOutlet UITextField *templateNameTxtFld;
    MyMovesWebServices *soapWebService;
}
@end

@implementation MyMovesListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableData = [[NSMutableArray alloc]init];
    _originalDataListArr = [[NSMutableArray alloc]init];
    _workOutListArr = [[NSMutableArray alloc]init];
    _BodyPartDataArr = [[NSMutableArray alloc]init];
    _categoryFilteredListArr = [[NSMutableArray alloc]init];
    _tagsArr = [[NSMutableArray alloc]init];
    _filteredTableArr = [[NSMutableArray alloc]init];
    
    searchBar.delegate = self;
    
    picker = [[PickerViewController alloc]initWithNibName:@"PickerViewController" bundle:nil];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar setTranslucent:NO];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{ [self loadTable]; });
//    [self loadTable];
    
    
    
    
    
}
- (void)loadTable
{
    soapWebService = [[MyMovesWebServices alloc] init];
    NSDictionary *wsWorkInfoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    @"WorkoutOffline", @"RequestType",nil];
    
    if(_isExchange)
    {        [self showLoading];
        NSMutableArray * tempArr = [[NSMutableArray alloc]initWithArray:[soapWebService loadFilteredListOfTitleToDb]];
        NSMutableArray * tempArr1 = [[NSMutableArray alloc]initWithArray:[soapWebService loadListOfTitleToDb]];
        if ([tempArr count] != 0) {
            NSString *filter = @"%K == %@";
            
            NSPredicate *categoryPredicate = [[NSPredicate alloc]init];
            if ([_moveDetailDictToDelete[@"WorkoutCategoryID"] length] != 0) {
                categoryPredicate = [NSPredicate predicateWithFormat:filter,@"WorkoutCategoryID",_moveDetailDictToDelete[@"WorkoutCategoryID"]];
            }
            else
            {
                categoryPredicate = [NSPredicate predicateWithFormat:filter,@"WorkoutCategoryID",_moveDetailDictToDelete[@"CategoryID"]];
            }
            self.bodypartTxtFld.text = _moveDetailDictToDelete[@"CategoryName"];
            [self.bodyPartBtn setUserInteractionEnabled:NO];
            [self.bodypartTxtFld setUserInteractionEnabled:NO];
            [self.filter1 setUserInteractionEnabled:NO];
            [self.filterOneBtn setUserInteractionEnabled:NO];
            
            _tableData = [[NSMutableArray alloc]initWithArray:[tempArr filteredArrayUsingPredicate:categoryPredicate]];
            
            _originalDataListArr = [[NSMutableArray alloc]initWithArray:[tempArr1 filteredArrayUsingPredicate:categoryPredicate]];
            _workOutListArr = [[NSMutableArray alloc]initWithArray:[_tableData filteredArrayUsingPredicate:categoryPredicate]];
            _BodyPartDataArr = [[NSMutableArray alloc]initWithArray:[soapWebService loadListOfBodyPart]];
            _categoryFilteredListArr = [[NSMutableArray alloc]initWithArray:[_tableData filteredArrayUsingPredicate:categoryPredicate]];
            _tagsArr = [[NSMutableArray alloc]initWithArray:[soapWebService loadListOfTags]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideLoading];
                
                
                NSSortDescriptor *sortDescriptor;
                sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"WorkoutName"
                                                             ascending:YES];
                _tableData = [[_tableData sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
                
                
                [tblView reloadData];
            });
        }
        else
        {
            [soapWebService callGetWebservice:wsWorkInfoDict];
        }
    }
    else
    {
        [self hideLoading];
        [self.bodyPartBtn setUserInteractionEnabled:YES];
        [self.bodypartTxtFld setUserInteractionEnabled:YES];
        [self.filter1 setUserInteractionEnabled:YES];
        [self.filterOneBtn setUserInteractionEnabled:YES];
        
        soapWebService.WSWorkoutListDelegate = self;
  
        NSOperationQueue *operationQueue = [NSOperationQueue new];
        NSBlockOperation *blockCompletionOperation = [NSBlockOperation blockOperationWithBlock:^{
            DMLog(@"The block operation ended, Do something such as show a successmessage etc");
            //This the completion block operation
        }];
        NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
            //        _tableData = [[NSMutableArray alloc]init];
            [self showLoading];
            if ([[soapWebService loadListOfTitleToDb] count] != 0) {
                _tableData = [[NSMutableArray alloc]initWithArray:[soapWebService loadFilteredListOfTitleToDb]];
                _workOutListArr = [[NSMutableArray alloc]initWithArray:[soapWebService loadFilteredListOfTitleToDb]];
                _originalDataListArr = [[NSMutableArray alloc]initWithArray:[soapWebService loadListOfTitleToDb]];
                _BodyPartDataArr = [[NSMutableArray alloc]initWithArray:[soapWebService loadListOfBodyPart]];
                _categoryFilteredListArr = [[NSMutableArray alloc]initWithArray:[soapWebService loadListOfTitleToDb]];
                _tagsArr = [[NSMutableArray alloc]initWithArray:[soapWebService loadListOfTags]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSSortDescriptor *sortDescriptor;
                    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"WorkoutName"
                                                                 ascending:YES];
                    _tableData = [[_tableData sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
                    [tblView reloadData];
                });
            }
            else
            {
                [soapWebService callGetWebservice:wsWorkInfoDict];
            }
        }];
        [blockCompletionOperation addDependency:blockOperation];
        [operationQueue addOperation:blockCompletionOperation];
        [operationQueue addOperation:blockOperation];
    }
}

-(void)showLoading {
    dispatch_async(dispatch_get_main_queue(), ^{  [HUD hide:YES afterDelay:0.0];
       HUD = [[MBProgressHUD showHUDAddedTo:self.view animated:YES] retain]; });

//    [HUD hide:YES afterDelay:0.0];
//    HUD = [[MBProgressHUD showHUDAddedTo:self.view animated:YES] retain];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 6.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^ {
        //        [self showLoading1];
    });
}
-(void)hideLoading {
        dispatch_async(dispatch_get_main_queue(), ^{
    [HUD hide:YES afterDelay:0.5];
        });
}
- (void)viewWillAppear:(BOOL)animated
{
    //    [self loadTable];
    //    NSOperationQueue *operationQueue = [NSOperationQueue new];
    //    NSBlockOperation *blockCompletionOperation = [NSBlockOperation blockOperationWithBlock:^{
    //        DMLog(@"The block operation ended, Do something such as show a successmessage etc");
    //        //This the completion block operation
    //    }];
    //    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
    ////        _tableData = [[NSMutableArray alloc]init];
    //        _workOutListArr = [[NSMutableArray alloc]initWithArray:[soapWebService loadListOfTitleToDb]];
    //        _BodyPartDataArr = [[NSMutableArray alloc]initWithArray:[soapWebService loadListOfBodyPart]];
    //        _categoryFilteredListArr = [[NSMutableArray alloc]initWithArray:[soapWebService loadListOfTitleToDb]];
    //        _tagsArr = [[NSMutableArray alloc]initWithArray:[soapWebService loadListOfTags]];
    //
    //    }];
    //    [blockCompletionOperation addDependency:blockOperation];
    //    [operationQueue addOperation:blockCompletionOperation];
    //    [operationQueue addOperation:blockOperation];
    
    //        [_workOutListArr addObjectsFromArray:[soapWebService loadListOfTitleToDb]];
    //        [_categoryFilteredListArr addObjectsFromArray:[soapWebService loadListOfTitleToDb]];
    //        [_BodyPartDataArr addObjectsFromArray:[soapWebService loadListOfBodyPart]];
    //        [_tagsArr addObjectsFromArray:[soapWebService loadListOfTags]];
    
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)dealloc {
    [tblView release];
    [_filterOneBtn release];
    [_bodyPartBtn release];
    [templateNameTxtFld release];
    [searchBar release];
    [super dealloc];
}
- (IBAction)bodyPartAction:(id)sender {
    
    if ([_BodyPartDataArr count]!=0) {
        picker.modalPresentationStyle = UIModalPresentationOverFullScreen;
        picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        picker.selectedBodyPartDel = self;
        picker.pickerData = _BodyPartDataArr;
        [self presentViewController:picker animated:YES completion:nil];
    }
    else
    {
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
        //                                                        message:@"Sorry No Moves available in this category"
        //                                                       delegate:self
        //                                              cancelButtonTitle:@"Ok"
        //                                              otherButtonTitles:@"No", nil];
        //        [alert show];
    }
}
- (IBAction)filterOne:(id)sender {
    
    //    if ([self.bodypartTxtFld.text length]!=0) {
    //    if ([_categoryFilteredListArr count]!=0) {
    //        picker.modalPresentationStyle = UIModalPresentationOverFullScreen;
    //        picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    //        picker.selectedBodyPartDel = self;
    //        picker.pickerData = _tagsArr;
    //        [self presentViewController:picker animated:YES completion:nil];
    //    }
    //    else
    //    {
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
    //                                                        message:@"Sorry No Moves available in this category"
    //                                                       delegate:self
    //                                              cancelButtonTitle:@"Ok"
    //                                              otherButtonTitles:nil];
    //        [alert show];
    //    }
    //    }
    //    else
    //    {
    picker.modalPresentationStyle = UIModalPresentationOverFullScreen;
    picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    picker.selectedBodyPartDel = self;
    picker.pickerData = _tagsArr;
    [self presentViewController:picker animated:YES completion:nil];
    //    }
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([searchText length] > 0)
    {
        if ([_filteredTableArr count] == 0) {
            _tableData = [[NSArray alloc]initWithArray:[_workOutListArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(WorkoutName contains[c] %@)", searchText]]];
        }
        else
        {
            _tableData = [[NSArray alloc]initWithArray:[_filteredTableArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(WorkoutName contains[c] %@)", searchText]]];
        }
    }
    else
    {
        _tableData = [[NSArray alloc]initWithArray:_workOutListArr];
        [searchBar endEditing:YES];
    }
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"WorkoutName"
                                                                   ascending:YES];
    _tableData = [[_tableData sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
    
    
    [tblView reloadData];
}
- (IBAction)searchTxtFldEditingAction:(UITextField*)sender {
    if ([sender.text length] > 0)
    {
        if ([_filteredTableArr count] == 0) {
            _tableData = [[NSArray alloc]initWithArray:[_workOutListArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(WorkoutName contains[c] %@)", self.searchtxtfld.text]]];
        }
        else
        {
            _tableData = [[NSArray alloc]initWithArray:[_filteredTableArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(WorkoutName contains[c] %@)", self.searchtxtfld.text]]];
        }
    }
    else
    {
        _tableData = [[NSArray alloc]initWithArray:_workOutListArr];
    }
    
    [tblView reloadData];
}

#pragma mark TEXTFIELD DELEGATE
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    
    if ([_searchtxtfld isFirstResponder] && [touch view] != _searchtxtfld) {
        [_searchtxtfld resignFirstResponder];
    }
    
    if ([_bodypartTxtFld isFirstResponder] && [touch view] != _bodypartTxtFld) {
        [_bodypartTxtFld resignFirstResponder];
    }
    
    if ([_filter1 isFirstResponder] && [touch view] != _filter1) {
        [_filter1 resignFirstResponder];
    }
    
    if ([_filter2 isFirstResponder] && [touch view] != _filter2) {
        [_filter2 resignFirstResponder];
    }
    if ([templateNameTxtFld isFirstResponder] && [touch view] != templateNameTxtFld) {
        [templateNameTxtFld resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGRect textFieldRect =
    [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect =
    [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0) {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0) {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown) {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}
#pragma mark TEXTFIELD ACCESSORY METHODS
/*
 -(IBAction)dismissKeyboard:(id)sender {
 for (int i=1; i<= NUMBER_OF_TEXTFIELDS; i++) {
 UITextField *textField = (UITextField*)[self.view viewWithTag:i];
 
 if ([textField isFirstResponder]) {
 [textField resignFirstResponder];
 [scrollView setContentOffset:svos animated:YES];
 }
 }
 }
 
 -(IBAction)nextTextField:(id)sender {
 for (int i=1; i<= NUMBER_OF_TEXTFIELDS; i++) {
 UITextField *textField = (UITextField*)[self.view viewWithTag:i];
 
 if ([textField isFirstResponder] && i!=NUMBER_OF_TEXTFIELDS) {
 UITextField *textField2 = (UITextField*)[self.view viewWithTag:i+1];
 [textField2 becomeFirstResponder];
 if (i+1 ==NUMBER_OF_TEXTFIELDS) {
 [closeDoneButton setTitle:@"Done"];
 [closeDoneButton setStyle:UIBarButtonItemStyleDone];
 }
 else {
 [closeDoneButton setTitle:@"Close"];
 [closeDoneButton setStyle:UIBarButtonItemStylePlain];
 }
 break;
 }
 }
 }
 
 -(IBAction)previousTextField:(id)sender {
 for (int i=1; i<= NUMBER_OF_TEXTFIELDS; i++) {
 UITextField *textField = (UITextField*)[self.view viewWithTag:i];
 if ([textField isFirstResponder] && i != 1) {
 UITextField *textField2 = (UITextField*)[self.view viewWithTag:i-1];
 
 [textField2 becomeFirstResponder];
 [closeDoneButton setTitle:@"Close"];
 [closeDoneButton setStyle:UIBarButtonItemStylePlain];
 break;
 }
 }
 }
 */
-(BOOL)textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - WorkOutList

- (void)getWorkoutListFailed:(NSString *)failedMessage {
    
}

- (void)getWorkoutListFinished:(NSDictionary *)responseDict {
    
    if([NSNull null] != [responseDict objectForKey:@"ListOfTitle"]) {
        _tableData = [[[NSMutableArray alloc]initWithArray:responseDict[@"ListOfTitle"]] mutableCopy];
        _workOutListArr = [[NSMutableArray alloc]initWithArray:responseDict[@"ListOfTitle"]];
        _categoryFilteredListArr = [[NSMutableArray alloc]initWithArray:responseDict[@"ListOfTitle"]];
        
    }
    
    if([NSNull null] != [responseDict objectForKey:@"ListOfBodyPart"]) {
        _BodyPartDataArr = [[NSMutableArray alloc]initWithArray:responseDict[@"ListOfBodyPart"]];
    }
    
    if([NSNull null] != [responseDict objectForKey:@"ListOfTags"]) {
        _tagsArr = [[NSMutableArray alloc]initWithArray:responseDict[@"ListOfTags"]];
    }
    
    [self hideLoading];
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"WorkoutName"
                                                 ascending:YES];
    _tableData = [[_tableData sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
    [tblView reloadData];
}
/*
 #pragma mark - CategoryList
 
 - (void)getCategoryListFailed:(NSString *)failedMessage {
 
 }
 
 - (void)getCategoryListFinished:(NSDictionary *)responseArray {
 [_BodyPartDataArr addObjectsFromArray:responseArray[@"CategoryList"]];
 }
 */

//UniquiID
-(NSString *) randomStringWithLength:(int)digit {
    NSString *alphaNumaricStr = @"abcdefghijklmnopqrstuvwxyz0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: digit];
    
    for (int i=0; i<digit; i++) {
        [randomString appendFormat: @"%C", [alphaNumaricStr characterAtIndex: arc4random_uniform([alphaNumaricStr length])]];
    }
    DMLog(@"S-%@",randomString);
    
    return randomString;
}
#pragma mark - TableView Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"searchTable";
    [self hideLoading];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [[_tableData objectAtIndex:indexPath.row] valueForKey:@"WorkoutName"];
    cell.textLabel.numberOfLines = 6;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tableData count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"LLLL d, yyyy"];
    
    NSString * msgInfo = [NSString stringWithFormat:@"New Move will be added to %@",[dateFormatter stringFromDate:_selectedDate]];
   
    NSString * msgInfoForExchange = [NSString stringWithFormat:@"Exchange move on %@",[dateFormatter stringFromDate:_selectedDate]];
    /*
     if([templateNameTxtFld.text length] == 0)
     {
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
     message:@"Please Enter Template Name"
     delegate:self
     cancelButtonTitle:@"Ok"
     otherButtonTitles:nil];
     [alert show];
     }
     else if ([_bodypartTxtFld.text length] == 0)
     {
     UIAlertController * alert = [UIAlertController
     alertControllerWithTitle:@"Add My Moves"
     message:msgInfo
     preferredStyle:UIAlertControllerStyleAlert];
     
     //Add Buttons
     
     UIAlertAction* yesButton = [UIAlertAction
     actionWithTitle:@"Ok"
     style:UIAlertActionStyleDefault
     handler:^(UIAlertAction * action) {
     //Handle your yes please button action here
     
     MyMovesDetailsViewController *moveDetailVc = [[MyMovesDetailsViewController alloc]initWithNibName:@"MyMovesDetailsViewController" bundle:nil];
     moveDetailVc.moveDetailDict = self.tableData[indexPath.row];
     
     NSString *filter = @"%K == %@";
     NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:filter,@"WorkoutCategoryID",_tableData[indexPath.row][@"WorkoutCategoryID"]];
     
     NSMutableArray * tempArr = [[NSMutableArray alloc]initWithArray:[_BodyPartDataArr filteredArrayUsingPredicate:categoryPredicate]];
     
     NSString *tagFilter = @"%K == %@ && %K == %@";
     NSPredicate *tagPredicate = [NSPredicate predicateWithFormat:tagFilter,@"WorkoutTagsID",_tableData[indexPath.row][@"WorkoutTagsID"],@"WorkoutCategoryID",_tableData[indexPath.row][@"WorkoutCategoryID"]];
     
     NSMutableArray * tempTagArr = [[NSMutableArray alloc]initWithArray:[_tagsArr filteredArrayUsingPredicate:tagPredicate]];
     
     
     [soapWebService addExerciseToDb:_tableData[indexPath.row] workoutDate:_selectedDate userId:_userId categoryName:tempArr[0][@"WorkoutCategoryName"] CategoryID:[_tableData[indexPath.row][@"WorkoutCategoryID"]integerValue] tagsName:tempTagArr[0][@"Tags"] TagsId:[_tableData[indexPath.row][@"WorkoutTagsID"]integerValue] templateName:templateNameTxtFld.text];
     moveDetailVc.workoutMethodID = [self.tableData[indexPath.row][@"WorkoutTemplateId"]intValue];
     [self.navigationController popViewControllerAnimated:YES];
     }];
     
     UIAlertAction* noButton = [UIAlertAction
     actionWithTitle:@"Cancel"
     style:UIAlertActionStyleDefault
     handler:^(UIAlertAction * action) {
     //Handle no, thanks button
     }];
     
     //Add your buttons to alert controller
     
     [alert addAction:yesButton];
     [alert addAction:noButton];
     
     [self presentViewController:alert animated:YES completion:nil];
     
     }
     else
     { */
    if(_isExchange)
    {
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Exchange My Moves"
                                     message:msgInfoForExchange
                                     preferredStyle:UIAlertControllerStyleAlert];
        //Add Buttons
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Exchange"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        
                                        MyMovesDetailsViewController *moveDetailVc = [[MyMovesDetailsViewController alloc]initWithNibName:@"MyMovesDetailsViewController" bundle:nil];
                                        //                                            [soapWebService saveDeletedExerciseToDb:[self.moveDetailDictToDelete[@"WorkoutTemplateId"] intValue] UserId:_userId];
                                        [soapWebService saveDeletedExerciseToDb:[self.moveDetailDictToDelete[@"WorkoutTemplateId"] intValue] UserId:_userId WorkoutUserDateID:[self.moveDetailDictToDelete[@"WorkoutUserDateID"] intValue]];
                                        
                                        
                                        DMLog(@"%@",self.moveDetailDictToDelete);
                                        //                                            [soapWebService deleteWorkoutFromDb:[self.moveDetailDictToDelete[@"WorkoutTemplateId"] intValue]];
                                        
                                        [soapWebService deleteWorkoutFromDb:[self.moveDetailDictToDelete[@"WorkoutUserDateID"] intValue]];
                                        
                                        //                                            [soapWebService addExerciseToDb:_tableData[indexPath.row] workoutDate:_selectedDate userId:_userId categoryName:_bodypartTxtFld.text CategoryID:[_moveDetailDictToDelete[@"CategoryID"]integerValue] tagsName:self.filter1.text TagsId:_tagsId templateName:@"Custom Plan"];
                                        
                                        [soapWebService addExerciseToDb:_tableData[indexPath.row] workoutDate:_selectedDate userId:_userId categoryName:_bodypartTxtFld.text CategoryID:[_moveDetailDictToDelete[@"CategoryID"]integerValue] tagsName:self.filter1.text TagsId:_tagsId templateName: _moveDetailDictToDelete[@"TemplateName"] WorkoutDateID:[_moveDetailDictToDelete[@"WorkoutUserDateID"]integerValue]];
                                        
                                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
                                        
                                        NSMutableArray * tempArr = [[NSMutableArray alloc]initWithArray:[[soapWebService loadExerciseFromDb] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(WorkoutDate contains[c] %@)", [formatter stringFromDate:_selectedDate]]]];
                                        
                                        DMLog(@"%@",tempArr[[tempArr count] - 1]);
                                        [self.exchangeDel passDataOnExchange:tempArr[[tempArr count] - 1]];
                                        
                                        moveDetailVc.workoutMethodID = [tempArr[[tempArr count] - 1][@"WorkoutUserDateID"]intValue];
                                        
                                        moveDetailVc.currentDate = self.selectedDate;
                                        NSString *dateString = [formatter stringFromDate:self.selectedDate];
                                        [soapWebService updateWorkoutToDb:dateString];
                                        
                                        MyMovesViewController *mymoveVc = [[MyMovesViewController alloc]initWithNibName:@"MyMovesViewController" bundle:nil];
                                        
                                        [[self navigationController] pushViewController:mymoveVc animated:YES];
                                        //                                            [[self navigationController] popToViewController:mymoveVc animated:YES];
                                    }];
        
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       //Handle no, thanks button
                                   }];
        
        UIAlertAction* addEditButton = [UIAlertAction
                                        actionWithTitle:@"Exchange & Edit"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            
                                            MyMovesDetailsViewController *moveDetailVc = [[MyMovesDetailsViewController alloc]initWithNibName:@"MyMovesDetailsViewController" bundle:nil];
                                            
                                            [soapWebService saveDeletedExerciseToDb:[self.moveDetailDictToDelete[@"WorkoutTemplateId"] intValue] UserId:_userId WorkoutUserDateID:[self.moveDetailDictToDelete[@"WorkoutUserDateID"] intValue]];
                                            DMLog(@"%@",self.moveDetailDictToDelete);
                                            
                                            [soapWebService deleteWorkoutFromDb:[self.moveDetailDictToDelete[@"WorkoutUserDateID"] intValue]];
                                            
                                            
                                            [soapWebService addExerciseToDb:_tableData[indexPath.row] workoutDate:_selectedDate userId:_userId categoryName:_bodypartTxtFld.text CategoryID:[_moveDetailDictToDelete[@"CategoryID"]integerValue] tagsName:self.filter1.text TagsId:_tagsId templateName: _moveDetailDictToDelete[@"TemplateName"] WorkoutDateID:[_moveDetailDictToDelete[@"WorkoutUserDateID"]integerValue]];
                                            
                                            
                                            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                            formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
                                            
                                            NSMutableArray * tempArr = [[NSMutableArray alloc]initWithArray:[[soapWebService loadExerciseFromDb] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(WorkoutDate contains[c] %@)", [formatter stringFromDate:_selectedDate]]]];
                                            
                                            DMLog(@"%@",tempArr[[tempArr count] - 1]);
                                            [self.exchangeDel passDataOnExchange:tempArr[[tempArr count] - 1]];
                                          
                                            moveDetailVc.workoutMethodID = [tempArr[[tempArr count] - 1][@"WorkoutUserDateID"]intValue];
                                            
                                            moveDetailVc.currentDate = self.selectedDate;
                                            NSString *dateString = [formatter stringFromDate:self.selectedDate];
                                            [soapWebService updateWorkoutToDb:dateString];

                                            [self.navigationController popViewControllerAnimated:YES];
                                        }];
        
        
        //Add your buttons to alert controller
        
        [alert addAction:yesButton];
        [alert addAction:addEditButton];
        [alert addAction:noButton];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Add My Moves"
                                     message:msgInfo
                                     preferredStyle:UIAlertControllerStyleAlert];
        //Add Buttons
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Add"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                        MyMovesDetailsViewController *moveDetailVc = [[MyMovesDetailsViewController alloc]initWithNibName:@"MyMovesDetailsViewController" bundle:nil];
                                        moveDetailVc.moveDetailDict = self.tableData[indexPath.row];
                                        
                                        NSString *filter = @"%K == %@";
                                        NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:filter,@"WorkoutCategoryID",_tableData[indexPath.row][@"WorkoutCategoryID"]];
                                        
                                        NSMutableArray * tempArr = [[NSMutableArray alloc]initWithArray:[_BodyPartDataArr filteredArrayUsingPredicate:categoryPredicate]];
                                        
                                        _categoryID = [_tableData[indexPath.row][@"WorkoutCategoryID"]integerValue];
                                        _tagsId = [_tableData[indexPath.row][@"WorkoutTagsID"]integerValue];
                                        
                                        
                                        NSString *alphaNumaricStr = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
                                        NSMutableString *planNameUniqueID = [NSMutableString stringWithCapacity: 10];
                                        NSMutableString *planDateListUniqueID = [NSMutableString stringWithCapacity: 10];
                                        NSMutableString *moveNameUniqueID = [NSMutableString stringWithCapacity: 10];

                                        for (long i=0; i<10; i++) {
                                            [planNameUniqueID appendFormat: @"%C", [alphaNumaricStr characterAtIndex: arc4random_uniform([alphaNumaricStr length])]];
                                        }
                                        
                                        for (long i=0; i<10; i++) {
                                            [planDateListUniqueID appendFormat: @"%C", [alphaNumaricStr characterAtIndex: arc4random_uniform([alphaNumaricStr length])]];
                                        }
                                        
                                        for (long i=0; i<10; i++) {
                                            [moveNameUniqueID appendFormat: @"%C", [alphaNumaricStr characterAtIndex: arc4random_uniform([alphaNumaricStr length])]];
                                        }
                                        
                                        planNameUniqueID      = [@"M-" stringByAppendingString:planNameUniqueID];
                                        planDateListUniqueID  = [@"M-" stringByAppendingString:planDateListUniqueID];
                                        moveNameUniqueID      = [@"M-" stringByAppendingString:moveNameUniqueID];

                                        
                                        moveDetailVc.parentUniqueID = moveNameUniqueID;
                                        
                                        // NSString *planNameStr = [NSString stringWithFormat:@"Custom Plan (%ld)", _newCount + 1];
                                        NSString *planNameStr = @"Custom Plan";

//                                        if (_bodypartTxtFld.text.length == 0) {
                                            [soapWebService addMovesToDb:_tableData[indexPath.row] SelectedDate:_selectedDate planName:planNameStr categoryName:tempArr[0][@"WorkoutCategoryName"] CategoryID:_categoryID tagsName:self.filter1.text TagsId:_tagsId status:@"New" PlanNameUnique:planNameUniqueID DateListUnique:planDateListUniqueID MoveNameUnique:moveNameUniqueID];
//                                        }
//                                        else
//                                        {
//                                            // [soapWebService addExerciseToDb:_tableData[indexPath.row] workoutDate:_selectedDate userId:_userId categoryName:tempArr[0][@"WorkoutCategoryName"] CategoryID:_categoryID tagsName:self.filter1.text TagsId:_tagsId templateName:@"Custom Plan" WorkoutDateID: workoutTempId];
//                                        }
                                        
                                        
                                        moveDetailVc.workoutMethodID = [self.tableData[indexPath.row][@"WorkoutUserDateID"]intValue];
                                        [_passDataDel passDataOnAdd];
                                        
                                        [self.navigationController popViewControllerAnimated:YES];
                                    }];
        
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       //Handle no, thanks button
                                   }];
        
        UIAlertAction* addEditButton = [UIAlertAction
                                        actionWithTitle:@"Add & Edit"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            
                                            NSString *filter = @"%K == %@";
                                            NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:filter,@"WorkoutCategoryID",_tableData[indexPath.row][@"WorkoutCategoryID"]];
                                            
                                            NSMutableArray * tempArr = [[NSMutableArray alloc]initWithArray:[_BodyPartDataArr filteredArrayUsingPredicate:categoryPredicate]];
                                            
                                            NSString *alphaNumaricStr = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
                                            NSMutableString *planNameUniqueID = [NSMutableString stringWithCapacity: 10];
                                            NSMutableString *planDateListUniqueID = [NSMutableString stringWithCapacity: 10];
                                            NSMutableString *moveNameUniqueID = [NSMutableString stringWithCapacity: 10];
                                            
                                            for (long i=0; i<10; i++) {
                                                [planNameUniqueID appendFormat: @"%C", [alphaNumaricStr characterAtIndex: arc4random_uniform([alphaNumaricStr length])]];
                                            }
                                            
                                            for (long i=0; i<10; i++) {
                                                [planDateListUniqueID appendFormat: @"%C", [alphaNumaricStr characterAtIndex: arc4random_uniform([alphaNumaricStr length])]];
                                            }
                                            
                                            for (long i=0; i<10; i++) {
                                                [moveNameUniqueID appendFormat: @"%C", [alphaNumaricStr characterAtIndex: arc4random_uniform([alphaNumaricStr length])]];
                                            }
                                            
                                            planNameUniqueID        = [@"M-" stringByAppendingString:planNameUniqueID];
                                            planDateListUniqueID    = [@"M-" stringByAppendingString:planDateListUniqueID];
                                            moveNameUniqueID        = [@"M-" stringByAppendingString:moveNameUniqueID];
                                            
                                            //  NSString *planNameStr = [NSString stringWithFormat:@"Custom Plan (%ld)", _newCount + 1];
                                            NSString *planNameStr = @"Custom Plan";

                                            [soapWebService addMovesToDb:_tableData[indexPath.row] SelectedDate:_selectedDate planName:planNameStr categoryName:tempArr[0][@"WorkoutCategoryName"] CategoryID:_categoryID tagsName:self.filter1.text TagsId:_tagsId status:@"New" PlanNameUnique:planNameUniqueID DateListUnique:planDateListUniqueID MoveNameUnique:moveNameUniqueID];
                                            
                                            MyMovesDetailsViewController *moveDetailVc = [[MyMovesDetailsViewController alloc]initWithNibName:@"MyMovesDetailsViewController" bundle:nil];
                                            
                                            moveDetailVc.moveDetailDict = _tableData[indexPath.row];
                                            moveDetailVc.parentUniqueID = moveNameUniqueID;
                
                                            NSMutableArray *addMovesArr = [[NSMutableArray alloc]init];
                                            NSMutableDictionary *dict = NSMutableDictionary.new;

                                            [dict setObject: moveNameUniqueID  forKey: @"UniqueID"];
                                            [dict setObject: planDateListUniqueID  forKey: @"ParentUniqueID"];

                                            [addMovesArr addObject:dict];
                                            moveDetailVc.addMovesArray = addMovesArr;
                                            
                                            moveDetailVc.currentDate = self.selectedDate;
                                            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                            formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
                                            NSString *dateString = [formatter stringFromDate:self.selectedDate];
                                            [soapWebService updateWorkoutToDb:dateString];
                                            [_passDataDel passDataOnAdd];
                                            
                                            [self.navigationController pushViewController:moveDetailVc animated:YES];
                                            
                                        }];
        
        
        //Add your buttons to alert controller
        
        [alert addAction:yesButton];
        [alert addAction:addEditButton];
        [alert addAction:noButton];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    //    }
}





#pragma mark - SelectedBodyPart Delegate

- (void)getSelectedBodyPart:(nonnull NSDictionary *)dict {
    _bodypartTxtFld.text = dict[@"WorkoutCategoryName"];
    
    NSString *filter = @"%K == %@";
    NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:filter,@"WorkoutCategoryID",dict[@"WorkoutCategoryID"]];
    
    _categoryFilteredListArr = [[NSMutableArray alloc]initWithArray:[_originalDataListArr filteredArrayUsingPredicate:categoryPredicate]];
    
    NSSet * removeDup = [[NSMutableSet alloc] initWithArray:_categoryFilteredListArr];
    
    _categoryFilteredListArr = [[NSMutableArray alloc]initWithArray:[removeDup allObjects]];
    _filter1.text = @"";
    
    _tableData = [soapWebService loadCategoryFilteredListOfTitleToDb:[dict[@"WorkoutCategoryID"]intValue]];
    
    if (dict[@"WorkoutCategoryID"] != nil) {
        _categoryID = [dict[@"WorkoutCategoryID"] integerValue];
    }
    else
    {
        _categoryID = [dict[@"CategoryID"] integerValue];
    }
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"WorkoutName"
                                                 ascending:YES];
    _tableData = [[_tableData sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [tblView reloadData];
    });
    
}

- (void)getSelectedTagId:(NSDictionary *)dict
{
    _filter1.text = dict[@"Tags"];
    
    NSString *filter = @"%K == %@ && %K == %d";
    
    NSPredicate *categoryPredicate = [[NSPredicate alloc]init];
    
    if (_isExchange) {
        categoryPredicate = [NSPredicate predicateWithFormat:filter,@"WorkoutTagsID",dict[@"WorkoutTagsID"],@"WorkoutCategoryID",dict[@"WorkoutCategoryID"]];
    }
    else
    {
        
        if ([self.bodypartTxtFld.text length] == 0) {
            NSString *onlyTagsFilter = @"%K == %@";
            if ([dict[@"TagsId"] length] != 0) {
                categoryPredicate = [NSPredicate predicateWithFormat:onlyTagsFilter,@"WorkoutTagsID",dict[@"TagsId"]];
                
            }
            else
            {
                categoryPredicate = [NSPredicate predicateWithFormat:onlyTagsFilter,@"WorkoutTagsID",dict[@"WorkoutTagsID"]];
                
            }
        }
        else
        {
            if ([dict[@"TagsId"] length] != 0) {
                categoryPredicate = [NSPredicate predicateWithFormat:filter,@"WorkoutTagsID",dict[@"TagsId"],@"CategoryID",_categoryID];
                
            }
            else
            {
                categoryPredicate = [NSPredicate predicateWithFormat:filter,@"WorkoutTagsID",dict[@"WorkoutTagsID"],@"WorkoutCategoryID",_categoryID];
                
            }
        }
    }
    NSSet * removeDup = [[NSSet alloc]init];
    
    removeDup = [[NSMutableSet alloc] initWithArray:[_originalDataListArr filteredArrayUsingPredicate:categoryPredicate]];
    NSMutableSet *movesList = [[NSMutableSet alloc] init];
    
    NSString *tempNameString = [[NSString alloc] init];
    for (id key in removeDup) {
        NSString *workoutName = [key valueForKey:@"WorkoutName"];
        if (![tempNameString isEqualToString:workoutName]) {
            tempNameString = workoutName;
            [movesList addObject:key];
        }
    }
    //    if ([_categoryFilteredListArr count] != 0) {
    //         removeDup = [[NSMutableSet alloc] initWithArray:[_categoryFilteredListArr filteredArrayUsingPredicate:categoryPredicate]];
    //    }
    //    else
    //    {
    //    }
    
    _tableData = [[[NSMutableArray alloc]initWithArray:[movesList allObjects]]mutableCopy];
    _filteredTableArr = [[[NSMutableArray alloc]initWithArray:[movesList allObjects]]mutableCopy];
    
    if (dict[@"WorkoutCategoryID"] != nil) {
        _tagsId = [dict[@"WorkoutTagsID"] integerValue];
    }
    else
    {
        _tagsId = [dict[@"TagsId"] integerValue];
    }
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"WorkoutName"
                                                 ascending:YES];
    _tableData = [[_tableData sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [tblView reloadData];
    });
}

@end
