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
#import "MyMovesVideoPlayerViewController.h"
#import "DMMovePickerRow.h"
#import "MyMovesListViewController.h"

#import "DMMoveRoutine.h"
#import "DMMove.h"

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

@interface MyMovesDetailsViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate> {
    CGFloat animatedDistance;
}

@property (nonatomic, strong) MyMovesWebServices *soapWebService;

/// Name of the exercise.
@property (nonatomic, strong) IBOutlet UILabel *exerciseNameLbl;
@property (nonatomic, strong) IBOutlet UITextView *exerciseNotesTxtView;

/// Shows the sets and other details.
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *collectionViewHeightCons;

/// For video viewing.
@property (nonatomic, strong) IBOutlet UIView *thumbNailView;
@property (nonatomic, strong) IBOutlet UIImageView *thumbNailImgV;
@property (nonatomic, strong) IBOutlet UIButton *playVideoBtn;

/// Picker for selecting different options.
@property (nonatomic, strong) DMPickerViewController *pickerView;

/// Names of the items in the headers, e.g. "Pounds, Reps, Miles".
@property (nonatomic, strong) NSArray<DMMovePickerRow *> *headerNameArray;

@end

/// Identifiers (Note: must match value in Nib file.)
static NSString *MyMovesDetailCellIdentifier = @"MyMovesDetailCollectionViewCell";
static NSString *MyMovesDetailHeaderIdentifier = @"MyMovesDetailHeaderCollectionReusableView";
static NSString *MyMovesDetailFooterIdentifier = @"MyMovesDetailFooterCollectionReusableView";

@implementation MyMovesDetailsViewController

- (instancetype)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        _soapWebService = [[MyMovesWebServices alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"Move Details";
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

    UIBarButtonItem *rightButton =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                      target:self
                                                      action:@selector(showDeleteExerciseConfirmation)];
    rightButton.style = UIBarButtonItemStylePlain;
    rightButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = rightButton;

    self.collectionView.collectionViewLayout = [[CustomImageFlowLayout alloc] init];
    [self.collectionView registerNib:[UINib nibWithNibName:@"MyMovesDetailCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:MyMovesDetailCellIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:@"MyMovesDetailHeaderCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:MyMovesDetailHeaderIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:@"MyMovesDetailFooterCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:MyMovesDetailFooterIdentifier];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;

    DMMove *move = self.routine.move;
    [self updateMoveView:move];
    [self loadHeaderNameArray];
    
    // Show the video thumbnails.
    if ([move.videoUrl containsString:@"you"]) {
        [self extractYoutubeIdFromLink:move.videoUrl];
        NSString *idOfUrlLink = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/0.jpg",[self extractYoutubeIdFromLink:move.videoUrl]];
        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: idOfUrlLink]];
        self.thumbNailImgV.image = [UIImage imageWithData: imageData];
    }
    else if ([move.videoUrl containsString:@"vimeo"]) {
        NSString *videoId = [[move.videoUrl componentsSeparatedByString:@".com/"] objectAtIndex:1];
        NSArray *words = [videoId componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *nospacestring = [words componentsJoinedByString:@""];
        [self loadVimeoThumbNail:nospacestring];
    } else {
        [self.thumbNailImgV setHidden:YES];
        [_playVideoBtn setHidden:YES];
        [_thumbNailView setHidden:YES];
    }
}

/// Sets the move data onto the view.
- (void)updateMoveView:(DMMove *)move {
    self.exerciseNotesTxtView.text = move.notes;
    self.exerciseNameLbl.text = move.name;
}

#pragma mark - Helpers

/// Extracts the YouTube ID from a provided URL.
- (NSString *)extractYoutubeIdFromLink:(NSString *)link {
    NSString *regexString = @"((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)";
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *array = [regExp matchesInString:link options:0 range:NSMakeRange(0,link.length)];
    if (array.count > 0) {
        NSTextCheckingResult *result = array.firstObject;
        return [link substringWithRange:result.range];
    }
    return nil;
}

/// Fetches the thumbnail for the videoID provided for Vimeo.
- (void)loadVimeoThumbNail:(NSString *)videoId {
    NSString *reformatedVideoId = [videoId stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"video/"]];
    NSString *oembed = [NSString stringWithFormat:@"https://vimeo.com/api/oembed.json?url=https://vimeo.com/%@", reformatedVideoId];
    NSURL *url = [NSURL URLWithString:oembed];
    [[NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *err;
        NSDictionary *thumbnailArr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
        
        NSMutableString *thumbNail = [NSMutableString string];
        thumbNail = thumbnailArr[@"thumbnail_url"];

        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: thumbNail]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.thumbNailImgV.image = [UIImage imageWithData: imageData];
        });
    }] resume];
}

/// Loads the values that are displayed to the user.
- (void)loadHeaderNameArray {
    // NOTE: I think this should be updated from the server, but all of the names are null,
    // despite double checking the server data. Thus, we'll just load the default values for now.
    // TODO: Validate that the server should return values.
    NSArray *defaultHeaders = @[@"None", @"Feet", @"Kilograms", @"Kilometers", @"KilometerPerHour",@"Meters", @"Miles", @"MilesPerHour", @"Minutes", @"Pounds", @"Repetitions", @"RestSeconds", @"Seconds", @"Yards"];

    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSInteger i = 0; i < defaultHeaders.count; i++) {
        NSString *name = defaultHeaders[i];
        DMMovePickerRow *row = [DMMovePickerRow newWithName:name rowId:@(i)];
        [tempArray addObject:row];
    }
    self.headerNameArray = [tempArray copy];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.routine.sets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MyMovesDetailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MyMovesDetailCellIdentifier
                                                                                      forIndexPath:indexPath];
    
    cell.setNoLbl.text = [NSString stringWithFormat:@"%ld", indexPath.row + 1];
    
    DMMoveSet *set = [self.routine.sets copy][indexPath.row];
    cell.repsTxtFld.text = set.unitOneValue.stringValue;
    cell.weightTxtFld.text = set.unitTwoValue.stringValue;
        
    // Set the tags so we can retrieve the row the user selected later.
    cell.repsTxtFld.tag = indexPath.row;
    cell.weightTxtFld.tag = indexPath.row;
    cell.deleteBtn.tag = indexPath.row;
    
    cell.repsTxtFld.delegate = self;
    cell.weightTxtFld.delegate = self;
    
    cell.deleteBtn.tag = indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(deleteSetBtnAction:) forControlEvents:UIControlEventTouchDown];
    [cell.repsTxtFld addTarget:self action:@selector(repsEditAction:) forControlEvents:UIControlEventEditingChanged];
    [cell.weightTxtFld addTarget:self action:@selector(weightEditAction:) forControlEvents:UIControlEventEditingChanged];
    
    cell.deleteImgV.tintColor = [UIColor lightGrayColor];
    
    cell.editRepsImgView.image = [cell.editRepsImgView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell.editRepsImgView setTintColor:[UIColor lightGrayColor]];
    
    cell.editWeightImgView.image = [cell.editWeightImgView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell.editWeightImgView setTintColor:[UIColor lightGrayColor]];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    MyMovesDetailHeaderCollectionReusableView *header = nil;
    MyMovesDetailFooterCollectionReusableView *footer = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        // Header that lets you choose the type of reps or weight.
        header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                    withReuseIdentifier:MyMovesDetailHeaderIdentifier
                                                           forIndexPath:indexPath];
        
        [header.repsHeadBtn addTarget:self action:@selector(repsHeadAction:) forControlEvents:UIControlEventAllEvents];
        [header.weightHeadBtn addTarget:self action:@selector(weightHeadAction:) forControlEvents:UIControlEventAllEvents];
        
        // Set the tags so we know which button row was tapped.
        header.repsHeadBtn.tag = indexPath.row;
        header.weightHeadBtn.tag = indexPath.row;
        
        NSInteger unitOneId = 0;
        NSInteger unitTwoId = 0;
        if (self.routine.sets.count) {
            DMMoveSet *set = [self.routine.sets copy][indexPath.row];
            unitOneId = set.unitOneId.integerValue;
            unitTwoId = set.unitTwoId.integerValue;
        }
        DMMovePickerRow *rowOne = self.headerNameArray[unitOneId];
        DMMovePickerRow *rowTwo = self.headerNameArray[unitTwoId];
        header.repsLbl.text = rowOne.name;
        header.weightLbl.text = rowTwo.name;

        return header;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        // View that lets you add sets.
        footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                    withReuseIdentifier:MyMovesDetailFooterIdentifier
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

#pragma mark - Actions

- (IBAction)showVideoInBrowserAction:(id)sender {
    MyMovesVideoPlayerViewController *moveDetailVc = [[MyMovesVideoPlayerViewController alloc] init];
    moveDetailVc.videoUrlStr = self.routine.move.videoUrl;
    [self.navigationController pushViewController:moveDetailVc animated:YES];
}

- (IBAction)addSet:(UIButton*)sender {
    DMMoveSet *set = [DMMoveSet setWithDefaultValues];
    [self.soapWebService addMoveSet:set toRoutine:self.routine];
    // Reload our routine.
    self.routine = [self.soapWebService getUserPlanRoutineForRoutineId:self.routine.routineId];
    [self.view layoutIfNeeded];
    [self.collectionView reloadData];
}

- (void)showDeleteSetConfirmationForSet:(DMMoveSet *)moveSet {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Set"
                                                                   message:@"Are you sure you wish to delete?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.soapWebService deleteMoveSet:moveSet];
        // Reload our routine.
        self.routine = [self.soapWebService getUserPlanRoutineForRoutineId:self.routine.routineId];
        [weakSelf.view layoutIfNeeded];
        [weakSelf.collectionView reloadData];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"No"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showDeleteExerciseConfirmation {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Exercise"
                                                                   message:@"Are you sure, you want to delete this exercise?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self.soapWebService deleteMoveRoutine:self.routine];
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"No"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)deleteSetBtnAction:(UIButton *)sender {
    if (!sender) {
        return;
    }
    // Need to get the ID of the set to delete.
    DMMoveSet *set = [self.routine.sets copy][sender.tag];
    [self showDeleteSetConfirmationForSet:set];
}

/// First Header column.
- (IBAction)repsHeadAction:(UIButton *)sender {
    self.pickerView = [[DMPickerViewController alloc] init];
    [self.pickerView setDataSourceWithDataArray:self.headerNameArray showNoneRow:NO];
    __weak typeof(self) weakSelf = self;
    __block NSInteger selectedRow = sender.tag;
    self.pickerView.didSelectOptionCallback = ^(id<DMPickerViewDataSource> object, NSInteger row) {
        DMMoveSet *set = [weakSelf.routine.sets copy][selectedRow];
        [weakSelf.soapWebService setFirstUnitId:@(row) forMoveSet:set];
        [weakSelf.collectionView reloadData];
    };

    if (self.routine.sets.count == 0) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Please Add Set!" message:@"Please add sets to select sets method." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self.pickerView presentPickerIn:self];
    }
}

/// Second Header column.
- (IBAction)weightHeadAction:(UIButton *)sender {
    [self.pickerView setDataSourceWithDataArray:self.headerNameArray showNoneRow:NO];
    __weak typeof(self) weakSelf = self;
    __block NSInteger selectedRow = sender.tag;
    self.pickerView.didSelectOptionCallback = ^(id<DMPickerViewDataSource> object, NSInteger row) {
        DMMoveSet *set = [weakSelf.routine.sets copy][selectedRow];
        [weakSelf.soapWebService setSecondUnitId:@(row) forMoveSet:set];
        [weakSelf.collectionView reloadData];
    };

    if (self.routine.sets.count == 0) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Please Add Set!" message:@"Please add sets to select sets method." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self.pickerView presentPickerIn:self];
    }
}

- (IBAction)repsEditAction:(UITextField *)sender {
    if (!sender) {
        return;
    }
    NSNumber *unit1Value = @0;
    if ([sender.text length] != 0) {
        unit1Value = @([sender.text integerValue]);
    }
    NSInteger row = sender.tag;
    if (row > self.routine.sets.count - 1) {
        return;
    }
    DMMoveSet *set = [self.routine.sets copy][row];
    [self.soapWebService setFirstUnitValue:unit1Value forMoveSet:set];
}

- (IBAction)weightEditAction:(UITextField *)sender {
    if (!sender) {
        return;
    }
    NSNumber *unit2Value = @0;
    if ([sender.text length] != 0) {
        unit2Value = @([sender.text integerValue]);
    }
    NSInteger row = sender.tag;
    if (row > self.routine.sets.count - 1) {
        return;
    }
    DMMoveSet *set = [self.routine.sets copy][row];
    [self.soapWebService setSecondUnitValue:unit2Value forMoveSet:set];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    // Update: I don't see a note below.
    if(range.length + range.location > textField.text.length) {
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
    
    [UIView animateWithDuration:KEYBOARD_ANIMATION_DURATION animations:^{
        [self.view setFrame:viewFrame];
    }];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView animateWithDuration:KEYBOARD_ANIMATION_DURATION animations:^{
        [self.view setFrame:viewFrame];
    }];
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
    
    [UIView animateWithDuration:KEYBOARD_ANIMATION_DURATION animations:^{
        [self.view setFrame:viewFrame];
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView animateWithDuration:KEYBOARD_ANIMATION_DURATION animations:^{
        [self.view setFrame:viewFrame];
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - MyMovesListViewDelegate

- (void)userDidSelectOption:(NSDictionary *)dict {
   // [self setData:dict];
    //self.workoutMethodID = [dict[@"WorkoutUserDateID"]intValue];
    //self.moveDetailDict = dict;
    //[self loadSets];
#warning THE ABOVE METHOD ISNT FOUND...WHY?
}

@end
