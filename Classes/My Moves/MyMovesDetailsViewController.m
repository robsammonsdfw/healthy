//
//  MyMovesDetailsViewController.m
//  MyMoves
//
//  Created by Samson  on 14/01/19.
//

#import "MyMovesDetailsViewController.h"
#import "MyMovesDetailCollectionViewCell.h"
#import "CustomImageFlowLayout.h"
#import "MyMovesDetailHeaderCollectionReusableView.h"
#import "MyMovesDetailFooterCollectionReusableView.h"
#import "MyMovesWebServices.h"
#import "TimerViewController.h"
#import "PickerViewController.h"
#import "MyMovesVideoPlayerViewController.h"

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

@interface MyMovesDetailsViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource,UIAlertViewDelegate,UITextFieldDelegate,exchangeDelegate,changedRepsAndWeightDelegate>
{
    CGFloat animatedDistance;
    MyMovesWebServices *soapWebService;
    BOOL addSet;
    UIAlertView *alertViewToSetDelete;
    NSString *repsTxt;
    NSString *weightTxt;
    IBOutlet UIImageView *thumbNailImgV;
}
@property (strong, nonatomic) NSMutableArray<NSDictionary *> *exerciseSetArr;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeightCons;
@property (retain, nonatomic) IBOutlet UIImageView *deleteImgB;

@property (strong, nonatomic) NSMutableArray *userPlanMoveSetListData;
@property (strong, nonatomic) NSMutableArray *userPlanSetListArr;

@end

@implementation MyMovesDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _userPlanMoveSetListData = [[NSMutableArray alloc]init];
    _userPlanSetListArr = [[NSMutableArray alloc]init];
    self.exchangeImgView.hidden = YES;
    self.exchangeBtnOutlet.userInteractionEnabled = NO; // disable exchange by sathish
    _moveNameView.backgroundColor = PrimaryDarkColor;
    self.exerciseSetArr = [[NSMutableArray alloc]init];
    
    soapWebService = [[MyMovesWebServices alloc] init];
    
    _deleteImgB.tintColor = [UIColor lightGrayColor];
    //set title
    self.navigationItem.title=@"My Moves Details";
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    //set right navigation bar //timer
    // UIImage *btnImage1 = [[UIImage imageNamed:@"stopwatch.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    // UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    // btn1.bounds = CGRectMake( 0, 0, btnImage1.size.width, btnImage1.size.height );
    // btn1.tintColor = [UIColor whiteColor];
    // [btn1 addTarget:self action:@selector(showTimer:) forControlEvents:UIControlEventTouchDown];
    // [btn1 setImage:btnImage1 forState:UIControlStateNormal];
    //
    // UIBarButtonItem * settingsBtn = [[UIBarButtonItem alloc] initWithCustomView:btn1];
    // DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    // dietmasterEngine.taskMode = @"View";
    // self.navigationItem.rightBarButtonItem = settingsBtn;
    
    //set textView border color
    _exerciseNotesTxtView.layer.borderColor = [UIColor grayColor].CGColor;
    _exerciseNotesTxtView.layer.borderWidth = 1.0;
    _exerciseNotesTxtView.layer.cornerRadius = 10.0;
    
    _collectionView.collectionViewLayout = [[CustomImageFlowLayout alloc] init];
    
    [_collectionView registerNib:[UINib nibWithNibName:@"MyMovesDetailCollectionViewCell" bundle:NSBundle.mainBundle] forCellWithReuseIdentifier:@"MyMovesDetailCollectionViewCell"];
    
    [_collectionView registerNib:[UINib nibWithNibName:@"MyMovesDetailHeaderCollectionReusableView" bundle:NSBundle.mainBundle] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MyMovesDetailHeaderCollectionReusableView"];
    
    [_collectionView registerNib:[UINib nibWithNibName:@"MyMovesDetailFooterCollectionReusableView" bundle:NSBundle.mainBundle] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"MyMovesDetailFooterCollectionReusableView"];

    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    alertViewToSetDelete = [[UIAlertView alloc] initWithTitle:@"Delete Set"
                                                      message:@"Are you sure, you want to delete"
                                                     delegate:self
                                            cancelButtonTitle:@"Yes"
                                            otherButtonTitles:@"No", nil];
    
    [self setData:_moveDetailDict];
    [self loadSetValues];
    
    if ([_moveDetailDict[@"VideoLink"] containsString:@"you"])
    {
        [_noVideoMsgLbl setHidden:YES];
        [self extractYoutubeIdFromLink:_moveDetailDict[@"VideoLink"]];
        NSString *idOfUrlLink = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/0.jpg",[self extractYoutubeIdFromLink:_moveDetailDict[@"VideoLink"]]];
        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: idOfUrlLink]];
        thumbNailImgV.image = [UIImage imageWithData: imageData];
    }
    else if ([_moveDetailDict[@"Link"] containsString:@"you"])
    {
        [_noVideoMsgLbl setHidden:YES];
        [self extractYoutubeIdFromLink:_moveDetailDict[@"Link"]];
        NSString *idOfUrlLink = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/0.jpg",[self extractYoutubeIdFromLink:_moveDetailDict[@"Link"]]];
        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: idOfUrlLink]];
        thumbNailImgV.image = [UIImage imageWithData: imageData];
    }
    else if ([_moveDetailDict[@"VideoLink"] containsString:@"vimeo"])
    {
        [_noVideoMsgLbl setHidden:YES];
        NSString *videoId = [[_moveDetailDict[@"VideoLink"] componentsSeparatedByString:@".com/"] objectAtIndex:1];
        NSArray* words = [videoId componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString* nospacestring = [words componentsJoinedByString:@""];
        [self loadVimeoThumbNail:nospacestring];
    }
    else if ([_moveDetailDict[@"Link"] containsString:@"vimeo"])
    {
        [_noVideoMsgLbl setHidden:YES];
        NSString *videoId = [[_moveDetailDict[@"Link"] componentsSeparatedByString:@".com/"] objectAtIndex:1];
        NSArray* words = [videoId componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString* nospacestring = [words componentsJoinedByString:@""];
        [self loadVimeoThumbNail:nospacestring];
    }
    else
    {
        [thumbNailImgV setHidden:YES];
        [_playVideoBtn setHidden:YES];
        [_playImg setHidden:YES];
        [_thumbNailView setHidden:YES];
    }
}
-(NSString *)extractYoutubeIdFromLink:(NSString *)link {
    NSString *regexString = @"((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)";
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *array = [regExp matchesInString:link options:0 range:NSMakeRange(0,link.length)];
    if (array.count > 0) {
        NSTextCheckingResult *result = array.firstObject;
        return [link substringWithRange:result.range];
    }
    return nil;
}

-(void)loadVimeoThumbNail:(NSString *)videoId
{
    NSString *reformatedVideoId = [videoId stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"video/"]];
    NSString *oembed = [NSString stringWithFormat:@"https://vimeo.com/api/oembed.json?url=https://vimeo.com/%@", reformatedVideoId];
    NSURL *url = [NSURL URLWithString:oembed];
    [[NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *err;
        NSDictionary *thumbnailArr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
        
        NSMutableString *thumbNail = NSMutableString.new;
        thumbNail = thumbnailArr[@"thumbnail_url"];
        NSLog(@"%@", thumbNail);
                
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: thumbNail]];
            dispatch_async(dispatch_get_main_queue(), ^{
                thumbNailImgV.image = [UIImage imageWithData: imageData];
            });
        });
    }] resume];

}

- (void)loadSetValues
{
    [_userPlanSetListArr removeAllObjects];
    _userPlanMoveSetListData = [[[NSMutableArray alloc]initWithArray:[soapWebService loadUserPlanMoveSetListFromDb]] retain];
    NSArray *LoadSetsHeader = @[@"None", @"Feet", @"Kilograms", @"Kilometers", @"KilometerPerHour",@"Meters", @"Miles", @"MilesPerHour", @"Minutes", @"Pounds", @"Repetitions", @"RestSeconds", @"Seconds", @"Yards"];
   
    NSMutableSet* removeDuplicateSetInSection = [[NSMutableSet alloc] initWithArray:_userPlanMoveSetListData];
    _userPlanMoveSetListData = [[NSMutableArray alloc]initWithArray:[removeDuplicateSetInSection allObjects]];
    
    if (_moveListDict != NULL)
    {
        NSMutableArray *moveDetailArr = [NSMutableArray arrayWithObject:_moveListDict];
        for (int i =0 ; i<[moveDetailArr count]; i++)
        {
            NSMutableArray * tempArr = [[NSMutableArray alloc]initWithArray:[_userPlanMoveSetListData filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(ParentUniqueID MATCHES[c] %@)", moveDetailArr[i][@"UniqueID"]]]];
            [_userPlanSetListArr addObjectsFromArray:tempArr];
        }
    }
    
    if (_addMovesArray != NULL)
    {
//        NSMutableArray *addedMoveList = [NSMutableArray arrayWithObject:_addMovesArray];
        for (int i =0 ; i<[_addMovesArray count]; i++)
        {
            NSMutableArray * predicatedArr = [[NSMutableArray alloc]initWithArray:[_userPlanMoveSetListData filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(ParentUniqueID MATCHES[c] %@)", _addMovesArray[i][@"UniqueID"]]]];
            [_userPlanSetListArr addObjectsFromArray:predicatedArr];
        }
    }

    
    if ([_userPlanSetListArr count] != 0)
    {
        NSInteger unit1Id = [_userPlanSetListArr[0][@"Unit1ID"]integerValue];
        NSInteger unit2Id = [_userPlanSetListArr[0][@"Unit2ID"]integerValue];
        
        repsTxt = LoadSetsHeader[unit1Id];
        weightTxt = LoadSetsHeader[unit2Id];
    }
    else
    {
        repsTxt = LoadSetsHeader[0];
        weightTxt = LoadSetsHeader[0];
    }
    
    if ([_userPlanSetListArr count] > 2)
    {
        _collectionViewHeightCons.constant = ([_userPlanSetListArr count] * 40) + 45;
    }
    else
    {
        _collectionViewHeightCons.constant = (2 * 30) + 45;
    }
    [_collectionView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
}

-(void)setData:(NSDictionary*)dict
{
    if ([dict objectForKey:@"MoveName"])
    {
        _exerciseNotesTxtView.text = dict[@"Notes"];
        if ([dict[@"MoveName"] containsString:@"("]) {
            NSArray *arr1 = [dict[@"MoveName"] componentsSeparatedByString:@"("];
            _exerciseNameLbl.text = [NSString stringWithFormat:@"%@",[arr1 objectAtIndex:0]];
        }
        else
        {
            _exerciseNameLbl.text = dict[@"MoveName"];
        }
    }
    else
    {
        _exerciseNotesTxtView.text = dict[@"Notes"];
        if ([dict[@"WorkoutName"] containsString:@"("]) {
            NSArray *arr1 = [dict[@"WorkoutName"] componentsSeparatedByString:@"("];
            _exerciseNameLbl.text = [NSString stringWithFormat:@"%@",[arr1 objectAtIndex:0]];
        }
        else
        {
            _exerciseNameLbl.text = dict[@"WorkoutName"];
        }
    }
}

- (IBAction)exchangeBtnAction:(id)sender {
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Exchange My Moves"
                                 message:@"Are you sure you want to exchange?"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Yes"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    
                                    
                                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                                    
                                    MyMovesListViewController *moveListVc = [[MyMovesListViewController alloc]initWithNibName:@"MyMovesListViewController" bundle:nil];
                                    
                                    int UserID = [[prefs valueForKey:@"userid_dietmastergo"] integerValue];
                                    
                                    moveListVc.selectedDate = self.currentDate;
                                    moveListVc.userId = UserID;
                                    moveListVc.isExchange = "YES";
                                    moveListVc.moveDetailDictToDelete = _moveDetailDict;
                                    moveListVc.exchangeDel = self;
                                    
                                    [self.navigationController pushViewController:moveListVc animated:YES];
                                    //        }
                                    
                                }];
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"No"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   //Handle no, thanks button
                               }];

    [alert addAction:noButton];
    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];

    
}

-(IBAction)showTimer:(id)sender {
    
    TimerViewController *moveDetailVc = [[TimerViewController alloc]initWithNibName:@"TimerViewController" bundle:nil];
    moveDetailVc.moveDetailDict = _moveDetailDict;
    
    if ([_moveDetailDict[@"CurrentDuration"] isEqualToString:@""])
    {
        moveDetailVc.currentTimeInSeconds = 0;
    }
    else
    {
        moveDetailVc.currentTimeInSeconds = [_moveDetailDict[@"CurrentDuration"] integerValue];
    }
    [self.navigationController pushViewController:moveDetailVc animated:YES];
}

- (IBAction)showVideoInBrowserAction:(id)sender {
    MyMovesVideoPlayerViewController *moveDetailVc = [[MyMovesVideoPlayerViewController alloc]initWithNibName:@"MyMovesVideoPlayerViewController" bundle:nil]; //within the app
    if ([[_moveDetailDict allKeys] containsObject:@"VideoLink"]) ///To check whether the NSMutableDictionary contains key or kot. ***
    {
        moveDetailVc.videoUrlStr = _moveDetailDict[@"VideoLink"];
    }
    else
    {
        moveDetailVc.videoUrlStr = _moveDetailDict[@"Link"];
    }
    [self.navigationController pushViewController:moveDetailVc animated:YES];
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

- (void)dealloc {
    [_exerciseNotesTxtView release];
    [_collectionView release];
    [_exerciseNotesLbl release];
    [_exerciseNameLbl release];
    [_collectionViewHeightCons release];
    [_deleteImgB release];
    [_exchangeImgView release];
    [thumbNailImgV release];
    [_exchangeBtnOutlet release];
    [_moveNameView release];
    [_noVideoMsgLbl release];
    [_playVideoBtn release];
    [_playImg release];
    [_thumbNailView release];
    [super dealloc];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([_userPlanSetListArr count] != 0)
    {
        return [_userPlanSetListArr count];
    }
    else
    {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"MyMovesDetailCollectionViewCell";
    
    MyMovesDetailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.setNoLbl.text = [NSString stringWithFormat:@"%ld",indexPath.row + 1];
    
    if ([_userPlanSetListArr count] != 0)
    {
        cell.repsTxtFld.text = [NSString stringWithFormat:@"%@", _userPlanSetListArr[indexPath.row][@"Unit1Value"]];
        cell.weightTxtFld.text = [NSString stringWithFormat:@"%@", _userPlanSetListArr[indexPath.row][@"Unit2Value"]];
    }
    else
    {
        //        cell.repsTxtFld.text = [NSString stringWithFormat:@"%d", 0];
        //        cell.weightTxtFld.text = [NSString stringWithFormat:@"%d", 0];
    }
    
    
    cell.repsTxtFld.tag = indexPath.row;
    cell.weightTxtFld.tag = indexPath.row;
    cell.deleteBtn.tag = indexPath.row;
    
    cell.repsTxtFld.delegate = self;
    cell.weightTxtFld.delegate = self;
    
    [cell.deleteBtn addTarget:self action:@selector(deleteSetBtnAction:) forControlEvents:UIControlEventTouchDown];
    
    [cell.repsTxtFld addTarget:self action:@selector(repsEditAction:) forControlEvents:UIControlEventEditingChanged];
    [cell.weightTxtFld addTarget:self action:@selector(weightEditAction:) forControlEvents:UIControlEventEditingChanged];
    
    cell.deleteImgV.tintColor = [UIColor lightGrayColor];
    
    cell.editRepsImgView.image = [cell.editRepsImgView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell.editRepsImgView setTintColor:[UIColor lightGrayColor]];
    
    cell.editWeightImgView.image = [cell.editWeightImgView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell.editWeightImgView setTintColor:[UIColor lightGrayColor]];
    
    
    //    if ([_moveDetailDict[@"WorkingStatus"]isEqualToString:@"true"]) {
    //
    ////        [cell.deleteBtn setHidden:YES];
    ////        [cell.weightBtn setHidden:YES];
    ////        [cell.repsBtn setHidden:YES];
    ////
    ////        [cell.deleteImgV setHidden:YES];
    //        [cell.editRepsImgView setHidden:YES];
    //        [cell.editWeightImgView setHidden:YES];
    //
    //    }
    //    else
    //    {
    ////        [cell.deleteBtn setHidden:NO];
    ////        [cell.weightBtn setHidden:NO];
    ////        [cell.repsBtn setHidden:NO];
    ////
    ////        [cell.deleteImgV setHidden:NO];
    //        [cell.editRepsImgView setHidden:NO];
    //        [cell.editWeightImgView setHidden:NO];
    //    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    MyMovesDetailHeaderCollectionReusableView *header = nil;
    
    MyMovesDetailFooterCollectionReusableView *footer = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                    withReuseIdentifier:@"MyMovesDetailHeaderCollectionReusableView"
                                                           forIndexPath:indexPath];
        
        
        [header.repsHeadBtn addTarget:self action:@selector(repsHeadAction:) forControlEvents:UIControlEventAllEvents];
        
        [header.weightHeadBtn addTarget:self action:@selector(weightHeadAction:) forControlEvents:UIControlEventAllEvents];
        
        header.repsLbl.text = repsTxt;
        header.weightLbl.text = weightTxt;

        return header;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                    withReuseIdentifier:@"MyMovesDetailFooterCollectionReusableView"
                                                           forIndexPath:indexPath];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 0;
        [button addTarget:self action:@selector(addSet:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"" forState:UIControlStateNormal];
        button.frame = footer.bounds;
        [footer addSubview:button];
        
        return footer;
    }

    return nil;
}

-(IBAction)addSet:(UIButton*)sender{
    
    
    NSMutableDictionary *setDict = [NSMutableDictionary dictionary];
    NSString *status = @"New";
    NSString *alphaNumaricStr = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *setUniqueID = [NSMutableString stringWithCapacity: 10];
    
    for (long i=0; i<10; i++) {
        [setUniqueID appendFormat: @"%C", [alphaNumaricStr characterAtIndex: arc4random_uniform([alphaNumaricStr length])]];
    }
    setUniqueID = [@"M-" stringByAppendingString:setUniqueID];
    
    if([_userPlanSetListArr count] != 0)
    {
        long setNumberCount = [_userPlanSetListArr count] + 1;
        long unit1id = [_userPlanSetListArr[0][@"Unit1ID"] integerValue];
        long unit2id = [_userPlanSetListArr[0][@"Unit2ID"] integerValue];

        [setDict setObject: [NSNumber numberWithLong:setNumberCount]  forKey: @"SetNumber"];
        [setDict setObject: [NSNumber numberWithLong:unit1id]  forKey: @"Unit1ID"];
        [setDict setObject: [NSNumber numberWithLong:unit2id]  forKey: @"Unit2ID"];
        [setDict setObject: [NSNumber numberWithInt:0]  forKey: @"Unit1Value"];
        [setDict setObject: [NSNumber numberWithInt:0]  forKey: @"Unit2Value"];
        [setDict setObject: status  forKey: @"Status"];
        [setDict setObject: setUniqueID forKey: @"UniqueID"];
        [setDict setObject: _parentUniqueID forKey: @"ParentUniqueID"];

    }
    else
    {
        [setDict setObject: [NSNumber numberWithInt:1]  forKey: @"SetNumber"];
        [setDict setObject: [NSNumber numberWithInt:0]  forKey: @"Unit1ID"];
        [setDict setObject: [NSNumber numberWithInt:0]  forKey: @"Unit2ID"];
        [setDict setObject: [NSNumber numberWithInt:0]  forKey: @"Unit1Value"];
        [setDict setObject: [NSNumber numberWithInt:0]  forKey: @"Unit2Value"];
        [setDict setObject: status  forKey: @"Status"];
        [setDict setObject: setUniqueID  forKey: @"UniqueID"];
        [setDict setObject: _parentUniqueID forKey: @"ParentUniqueID"];

    }
   
    [soapWebService mobilePlanMoveSetList:_parentUniqueID setDict:setDict];
    [_userPlanSetListArr addObject:setDict];
//    [self.collectionView reloadData];
    [self loadSetValues];
    _collectionViewHeightCons.constant = _collectionViewHeightCons.constant + 30;
    
    [self.view layoutIfNeeded];
}
- (IBAction)deleteBtnAction:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Exercise"
                                                    message:@"Are you sure, you want to delete this exercise"
                                                   delegate:self
                                          cancelButtonTitle:@"Yes"
                                          otherButtonTitles:@"No", nil];
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {

    if (alertView == alertViewToSetDelete)
    {
        if (buttonIndex == 0)
        {
            [soapWebService deleteSetFromDb:_deleteSetUniqueID];
            [soapWebService clearedDataFromWeb:_deleteSetUniqueID];
            [soapWebService clearTableDataS];
//            [soapWebService loadUserPlanMoveSetListFromDb];
            [self loadSetValues];
        }
    }
    else
    {
        if (buttonIndex == 0) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            int UserID = [[prefs valueForKey:@"userid_dietmastergo"] integerValue];
           
            [soapWebService saveDeletedExerciseToDb:[self.moveDetailDict[@"WorkoutTemplateId"] intValue] UserId:UserID WorkoutUserDateID:[self.moveDetailDict[@"WorkoutUserDateID"] intValue]];
            [soapWebService deleteWorkoutFromDb:[self.moveDetailDict[@"WorkoutUserDateID"] intValue]];
            
            [soapWebService deleteMoveFromDb:_moveListDict[@"UniqueID"]]; // send to server
            [soapWebService clearedDataFromWeb:_moveListDict[@"UniqueID"]];
            [_passDataDel passDataOnAdd];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
}

-(IBAction)weightEditAction:(UITextField*)sender{

    int unit2Value = 0;
    if ([sender.text length] != 0)
    {
        unit2Value = [sender.text integerValue];
    }
    [soapWebService updateSetInSecondColumn:unit2Value uniqueID:_userPlanSetListArr[sender.tag][@"UniqueID"]];
}

-(IBAction)deleteSetBtnAction:(UIButton*)sender{
    
    _deleteSetUniqueID = _userPlanSetListArr[sender.tag][@"UniqueID"];
    [alertViewToSetDelete show];
    
}
-(IBAction)repsHeadAction:(UIButton*)sender{
    PickerViewController* picker = [[PickerViewController alloc]initWithNibName:@"PickerViewController" bundle:nil];
    picker.modalPresentationStyle = UIModalPresentationOverFullScreen;
    picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    picker.repsWeightDel = self;
    if ([soapWebService loadFirstHeaderTable].count != 0)
    {
        picker.pickerData = [soapWebService loadFirstHeaderTable];
    }
    picker.pickerData = [soapWebService loadFirstHeaderTable];
    picker.parentUniqueId = _parentUniqueID;
    picker.secondColumn = YES;
    if (_userPlanSetListArr.count == 0)
    {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Please Add Set!" message:@"Please add sets to select sets method." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        [self presentViewController:picker animated:YES completion:nil];
    }
}

-(IBAction)weightHeadAction:(UIButton*)sender{
    PickerViewController* picker = [[PickerViewController alloc]initWithNibName:@"PickerViewController" bundle:nil];
    picker.modalPresentationStyle = UIModalPresentationOverFullScreen;
    picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    picker.repsWeightDel = self;
    if ([soapWebService loadSecondHeaderTable].count != 0)
    {
        picker.pickerData = [soapWebService loadSecondHeaderTable];
    }
    picker.parentUniqueId = _parentUniqueID;
    picker.secondColumn = NO;
    if (_userPlanSetListArr.count == 0)
    {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Please Add Set!" message:@"Please add sets to select sets method." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        [self presentViewController:picker animated:YES completion:nil];
    }}
- (void)getReps:(NSString *)str
{
    repsTxt = str;
    [_collectionView reloadData];
}
- (void)getWeight:(NSString *)str
{
    weightTxt = str;
    [_collectionView reloadData];
}
-(IBAction)repsEditAction:(UITextField*)sender{
    int unit1Value = 0;
    if ([sender.text length] != 0)
    {
        unit1Value = [sender.text integerValue];
    }
    [soapWebService updateSetInFirstColumn:unit1Value uniqueID:_userPlanSetListArr[sender.tag][@"UniqueID"]];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 4;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    
    if ([_exerciseNotesTxtView isFirstResponder] && [touch view] != _exerciseNotesTxtView) {
        [_exerciseNotesTxtView resignFirstResponder];
    }
    
    if([[touch view] isKindOfClass:[UITextField class]])
    {
        UITextField * txt = (UITextField*)([touch view]);
        [txt resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    CGRect textFieldRect =
    [self.view.window convertRect:textView.bounds fromView:textView];
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

- (void)textViewDidEndEditing:(UITextView *)textView{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
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
-(BOOL)textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)passDataOnExchange:(NSDictionary *)dict
{
    [self setData:dict];
    self.workoutMethodID = [dict[@"WorkoutUserDateID"]intValue];
    self.moveDetailDict = dict;
    [self loadSets];
}
@end
