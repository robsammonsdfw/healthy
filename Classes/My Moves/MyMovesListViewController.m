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
}
@property (nonatomic, strong) MyMovesWebServices *soapWebService;
@property (nonatomic, strong) NSArray *tagsArr;
@property (nonatomic, strong) NSArray *BodyPartDataArr;
@end

@implementation MyMovesListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableData = [[NSMutableArray alloc]init];
    _originalDataListArr = [[NSMutableArray alloc]init];
    _workOutListArr = [[NSMutableArray alloc]init];
    _BodyPartDataArr = @[];
    _categoryFilteredListArr = [[NSMutableArray alloc]init];
    _tagsArr = @[];
    _filteredTableArr = [[NSMutableArray alloc]init];
    
    searchBar.delegate = self;
    
    picker = [[PickerViewController alloc]initWithNibName:@"PickerViewController" bundle:nil];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar setTranslucent:NO];
    
    dispatch_async(dispatch_get_main_queue(), ^{ [self loadTable]; });
}

- (void)loadTable {
    self.soapWebService = [[MyMovesWebServices alloc] init];
    NSDictionary *wsWorkInfoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    @"WorkoutOffline", @"RequestType",nil];
    
    if(_isExchange)
    {
        [DMActivityIndicator showActivityIndicator];
        NSMutableArray * tempArr = [[NSMutableArray alloc]initWithArray:[self.soapWebService loadFilteredListOfTitleToDb]];
        NSMutableArray * tempArr1 = [[NSMutableArray alloc]initWithArray:[self.soapWebService loadListOfTitleToDb]];
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
            _BodyPartDataArr = [self.soapWebService loadListOfBodyPart];
            _categoryFilteredListArr = [[NSMutableArray alloc]initWithArray:[_tableData filteredArrayUsingPredicate:categoryPredicate]];
            _tagsArr = [self.soapWebService loadListOfTags];
            dispatch_async(dispatch_get_main_queue(), ^{
                [DMActivityIndicator hideActivityIndicator];

                NSSortDescriptor *sortDescriptor;
                sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"WorkoutName"
                                                             ascending:YES];
                _tableData = [[_tableData sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
                
                [tblView reloadData];
            });
        }
        else
        {
            [self.soapWebService callGetWebservice:wsWorkInfoDict];
        }
    }
    else
    {
        [DMActivityIndicator hideActivityIndicator];
        [self.bodyPartBtn setUserInteractionEnabled:YES];
        [self.bodypartTxtFld setUserInteractionEnabled:YES];
        [self.filter1 setUserInteractionEnabled:YES];
        [self.filterOneBtn setUserInteractionEnabled:YES];
        
        self.soapWebService.WSWorkoutListDelegate = self;
  
        NSOperationQueue *operationQueue = [NSOperationQueue new];
        NSBlockOperation *blockCompletionOperation = [NSBlockOperation blockOperationWithBlock:^{
            DMLog(@"The block operation ended, Do something such as show a successmessage etc");
            //This the completion block operation
        }];
        NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
            [DMActivityIndicator showActivityIndicator];
            if ([[self.soapWebService loadListOfTitleToDb] count] != 0) {
                _tableData = [[NSMutableArray alloc]initWithArray:[self.soapWebService loadFilteredListOfTitleToDb]];
                _workOutListArr = [[NSMutableArray alloc]initWithArray:[self.soapWebService loadFilteredListOfTitleToDb]];
                _originalDataListArr = [[NSMutableArray alloc]initWithArray:[self.soapWebService loadListOfTitleToDb]];
                _BodyPartDataArr = [self.soapWebService loadListOfBodyPart];
                _categoryFilteredListArr = [[NSMutableArray alloc]initWithArray:[self.soapWebService loadListOfTitleToDb]];
                _tagsArr = [self.soapWebService loadListOfTags];
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
                [self.soapWebService callGetWebservice:wsWorkInfoDict];
            }
        }];
        [blockCompletionOperation addDependency:blockOperation];
        [operationQueue addOperation:blockCompletionOperation];
        [operationQueue addOperation:blockOperation];
    }
}

- (IBAction)bodyPartAction:(id)sender {
    if ([_BodyPartDataArr count]!=0) {
        picker.modalPresentationStyle = UIModalPresentationOverFullScreen;
        picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        picker.selectedBodyPartDel = self;
        picker.pickerData = _BodyPartDataArr;
        picker.dataType = DMPickerDataTypeMoveCategories;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (IBAction)filterOne:(id)sender {
    picker.modalPresentationStyle = UIModalPresentationOverFullScreen;
    picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    picker.selectedBodyPartDel = self;
    picker.pickerData = _tagsArr;
    picker.dataType = DMPickerDataTypeMoveTags;
    [self presentViewController:picker animated:YES completion:nil];
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

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
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
        //_tagsArr = [[NSMutableArray alloc]initWithArray:responseDict[@"ListOfTags"]];
    }
    
    [DMActivityIndicator hideActivityIndicator];
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"WorkoutName"
                                                 ascending:YES];
    _tableData = [[_tableData sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
    [tblView reloadData];
}

// UniqueID
-(NSString *)randomStringWithLength:(int)digit {
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
    [DMActivityIndicator hideActivityIndicator];
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
   
    if (_isExchange) {
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
                                        //                                            [self.soapWebService saveDeletedExerciseToDb:[self.moveDetailDictToDelete[@"WorkoutTemplateId"] intValue] UserId:_userId];
                                        [self.soapWebService saveDeletedExerciseToDb:[self.moveDetailDictToDelete[@"WorkoutTemplateId"] intValue] UserId:_userId WorkoutUserDateID:[self.moveDetailDictToDelete[@"WorkoutUserDateID"] intValue]];
                                        
                                        
                                        DMLog(@"%@",self.moveDetailDictToDelete);
                                        //                                            [self.soapWebService deleteWorkoutFromDb:[self.moveDetailDictToDelete[@"WorkoutTemplateId"] intValue]];
                                        
                                        [self.soapWebService deleteWorkoutFromDb:[self.moveDetailDictToDelete[@"WorkoutUserDateID"] intValue]];
                                        
                                        //                                            [self.soapWebService addExerciseToDb:_tableData[indexPath.row] workoutDate:_selectedDate userId:_userId categoryName:_bodypartTxtFld.text CategoryID:[_moveDetailDictToDelete[@"CategoryID"]integerValue] tagsName:self.filter1.text TagsId:_tagsId templateName:@"Custom Plan"];
                                        
                                        [self.soapWebService addExerciseToDb:_tableData[indexPath.row] workoutDate:_selectedDate userId:_userId categoryName:_bodypartTxtFld.text CategoryID:[_moveDetailDictToDelete[@"CategoryID"]integerValue] tagsName:self.filter1.text TagsId:_tagsId templateName: _moveDetailDictToDelete[@"TemplateName"] WorkoutDateID:[_moveDetailDictToDelete[@"WorkoutUserDateID"]integerValue]];
                                        
                                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
                                        
                                        NSArray *exerciseArray = [self.soapWebService loadExerciseFromDb];
                                        NSArray *filteredExerciseArray = [exerciseArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(WorkoutDate contains[c] %@)", [formatter stringFromDate:_selectedDate]]];
                                        NSMutableArray * tempArr = [filteredExerciseArray mutableCopy];
                                        
                                        DMLog(@"%@",tempArr[[tempArr count] - 1]);
                                        [self.exchangeDel passDataOnExchange:tempArr[[tempArr count] - 1]];
                                        
                                        moveDetailVc.workoutMethodID = [tempArr[[tempArr count] - 1][@"WorkoutUserDateID"]intValue];
                                        
                                        moveDetailVc.currentDate = self.selectedDate;
                                        NSString *dateString = [formatter stringFromDate:self.selectedDate];
                                        [self.soapWebService updateWorkoutToDb:dateString];
                                        
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
                                            
                                            [self.soapWebService saveDeletedExerciseToDb:[self.moveDetailDictToDelete[@"WorkoutTemplateId"] intValue] UserId:_userId WorkoutUserDateID:[self.moveDetailDictToDelete[@"WorkoutUserDateID"] intValue]];
                                            DMLog(@"%@",self.moveDetailDictToDelete);
                                            
                                            [self.soapWebService deleteWorkoutFromDb:[self.moveDetailDictToDelete[@"WorkoutUserDateID"] intValue]];
                                            
                                            
                                            [self.soapWebService addExerciseToDb:_tableData[indexPath.row] workoutDate:_selectedDate userId:_userId categoryName:_bodypartTxtFld.text CategoryID:[_moveDetailDictToDelete[@"CategoryID"]integerValue] tagsName:self.filter1.text TagsId:_tagsId templateName: _moveDetailDictToDelete[@"TemplateName"] WorkoutDateID:[_moveDetailDictToDelete[@"WorkoutUserDateID"]integerValue]];
                                            
                                            
                                            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                            formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
                                            
                                            NSMutableArray * tempArr = [[NSMutableArray alloc]initWithArray:[[self.soapWebService loadExerciseFromDb] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(WorkoutDate contains[c] %@)", [formatter stringFromDate:_selectedDate]]]];
                                            
                                            DMLog(@"%@",tempArr[[tempArr count] - 1]);
                                            [self.exchangeDel passDataOnExchange:tempArr[[tempArr count] - 1]];
                                          
                                            moveDetailVc.workoutMethodID = [tempArr[[tempArr count] - 1][@"WorkoutUserDateID"]intValue];
                                            
                                            moveDetailVc.currentDate = self.selectedDate;
                                            NSString *dateString = [formatter stringFromDate:self.selectedDate];
                                            [self.soapWebService updateWorkoutToDb:dateString];

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
                                            [self.soapWebService addMovesToDb:_tableData[indexPath.row] SelectedDate:_selectedDate planName:planNameStr categoryName:tempArr[0][@"WorkoutCategoryName"] CategoryID:_categoryID tagsName:self.filter1.text TagsId:_tagsId status:@"New" PlanNameUnique:planNameUniqueID DateListUnique:planDateListUniqueID MoveNameUnique:moveNameUniqueID];
//                                        }
//                                        else
//                                        {
//                                            // [self.soapWebService addExerciseToDb:_tableData[indexPath.row] workoutDate:_selectedDate userId:_userId categoryName:tempArr[0][@"WorkoutCategoryName"] CategoryID:_categoryID tagsName:self.filter1.text TagsId:_tagsId templateName:@"Custom Plan" WorkoutDateID: workoutTempId];
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

                                            [self.soapWebService addMovesToDb:_tableData[indexPath.row] SelectedDate:_selectedDate planName:planNameStr categoryName:tempArr[0][@"WorkoutCategoryName"] CategoryID:_categoryID tagsName:self.filter1.text TagsId:_tagsId status:@"New" PlanNameUnique:planNameUniqueID DateListUnique:planDateListUniqueID MoveNameUnique:moveNameUniqueID];
                                            
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
                                            [self.soapWebService updateWorkoutToDb:dateString];
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
    
    _tableData = [self.soapWebService loadCategoryFilteredListOfTitleToDb:[dict[@"WorkoutCategoryID"]intValue]];
    
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
