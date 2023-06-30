#import "ManageFoods.h"
#import <QuartzCore/QuartzCore.h>
#import "DietMasterGoViewController.h"
#import "DietMasterGoAppDelegate.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "DietmasterEngine.h"
#import "DetailViewController.h"
#import "DietMasterGoPlus-Swift.h"

@interface ManageFoods()
/// Barcode Scanner.
@property (nonatomic, strong) BarCodeScanner *barcodeScanner;
/// Determines if a user saw the scanner helper popup. Backed by
/// NSUserDefaults value, so only shown once per user login.
@property (nonatomic) BOOL helperBubbleWasShown;
/// The food that is being displayed to the user.
@property (nonatomic, strong) NSMutableDictionary *foodDict;
@property (nonatomic, strong) DMFood *food;
@end

@implementation ManageFoods

@synthesize scrollView, intFoodID, intCategoryID, strCategoryName, intMeasureID, strMeasureName;
@synthesize scannerDict, scanned_UPCA, scanned_factualID, scannerButton;

static const int NUMBER_OF_TEXTFIELDS = 28;
CGPoint svos;

#pragma mark VIEW LIFECYCLE

- (instancetype)initWithFood:(NSDictionary *)foodDict {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        _foodDict = [foodDict mutableCopy];
        [self loadFood];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    CGRect scrollViewFrame = scrollView.frame;
    self.view.frame = CGRectMake(0, applicationFrame.origin.y+64, self.view.frame.size.width, applicationFrame.size.height);
    scrollView.frame = CGRectMake(0, applicationFrame.origin.y+64, self.view.frame.size.width, applicationFrame.size.height);
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, scrollViewFrame.size.height)];
    
    selectMeasureButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    selectCategoryButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    intCategoryID = [NSNumber numberWithInt:0];
    intMeasureID = [NSNumber numberWithInt:0];
    
    reloadData = YES;
        
    scannerDict = nil;
    scanned_UPCA = @"empty";
    scanned_factualID = @"empty";
    
    scannerButton.layer.cornerRadius = 22.0;
    scannerButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    scannerButton.layer.borderWidth = 1.0;
    scannerButton.backgroundColor = [UIColor grayColor];
    scannerButton.frame = CGRectMake(20,  SCREEN_HEIGHT-180,
                                     scannerButton.frame.size.width, scannerButton.frame.size.height);
    scannerButton.alpha = 0.80;
        
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedScrollView:)];
    tapGesture.numberOfTapsRequired = 1.0;
    tapGesture.numberOfTouchesRequired = 1.0;
    [scrollView addGestureRecognizer:tapGesture];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStylePlain
                                   target: self action: @selector(customBackAction:)];
    [self.navigationItem setLeftBarButtonItem: backButton];
    
    isSaved = YES;
    _savedFoodID = 0;
    
    [self.navigationController.navigationBar setTranslucent:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:PLIST_NAME];
    NSDictionary *appDefaults = [[NSDictionary alloc] initWithContentsOfFile:finalPath];
    
    UIImageView *backgroundImage = (UIImageView *)[self.view viewWithTag:501];
    if ([[appDefaults valueForKey:@"account_code"] isEqualToString:@"ezdietplanner"]) {
        backgroundImage.image = [UIImage imageNamed:@"Custom_Foods_Editor"];
        for (id view in scrollView.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)view;
                label.textColor = [UIColor blackColor];
            }
        }
    }
    
    if (self.foodDict) {
        [self.navigationItem setTitle:@"Update Food"];
    } else {
        [self.navigationItem setTitle:@"Add New Food"];
    }
    
    UIBarButtonItem *rightButton =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                      target:self
                                                      action:@selector(showActionSheet:)];
    rightButton.style = UIBarButtonItemStylePlain;
    rightButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    if (self.foodDict) {
        [self loadData];
    }
    
    if (!self.helperBubbleWasShown && ![dietmasterEngine.taskMode isEqualToString:@"View"]) {
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calloutbubble"]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame = CGRectMake(self.view.frame.size.width-204, 0, 204, 113);
        imageView.alpha = 0.0;
        imageView.tag = 5566;
        imageView.userInteractionEnabled = YES;
        imageView.exclusiveTouch = YES;
        [self.view addSubview:imageView];
        
        [UIView animateWithDuration: 0.5f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations: ^{
                             imageView.alpha = 1.0;
                         } completion: ^ (BOOL finished) {
                             [UIView animateWithDuration: 0.5f
                                                   delay:3.0
                                                 options:UIViewAnimationOptionCurveEaseInOut
                                              animations: ^{
                                                  imageView.alpha = 0.0;
                                              }
                                              completion: ^ (BOOL finished) {
                                                  [imageView removeFromSuperview];
                                                  self.helperBubbleWasShown = YES;
                                              }];
                         }];
    }
}

#pragma mark - Setter/Getter

- (void)loadFood {
    DMDatabaseProvider *provider = [[DMDatabaseProvider alloc] init];
    self.food = [provider getFoodForFoodKey:self.foodDict[@"FoodKey"]];
}

- (BOOL)helperBubbleWasShown {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"HelperBubbleWasShown"];
}

- (void)setHelperBubbleWasShown:(BOOL)helperBubbleWasShown {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:helperBubbleWasShown forKey:@"HelperBubbleWasShown"];
    [defaults synchronize];
}

#pragma mark - BACK METHODS
-(void)customBackAction:(id)sender {
    if (!isSaved) {
        NSString *errorMessageString = @"This Food has not been saved. Are you sure you wish to exit?";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Wait a second!" message:errorMessageString preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Yes, Exit" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"No, Stay" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }]];
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITextField Delegate Methods
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag > 1)
        textField.keyboardType = UIKeyboardTypeDecimalPad;
    
    return YES;
}

-(void) textFieldDidBeginEditing:(UITextField *)textField {
    svos = scrollView.contentOffset;
    CGPoint pt;
    CGRect rc = [textField bounds];
    rc = [textField convertRect:rc toView:scrollView];
    pt = rc.origin;
    pt.x = 0;
    pt.y -= 70;
    [scrollView setContentOffset:pt animated:YES];
    
    [textField setInputAccessoryView:keyboardToolBar];
    [closeDoneButton setStyle:UIBarButtonItemStylePlain];
    
    for (int i=1; i<= NUMBER_OF_TEXTFIELDS; i++) {
        if (i == textField.tag) {
            if (i==NUMBER_OF_TEXTFIELDS) {
                svos.x = 0;
                svos.y = 0;
                [closeDoneButton setStyle:UIBarButtonItemStyleDone];
            }
        }
    }
}

#pragma mark TEXTFIELD ACCESSORY METHODS
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

-(BOOL)textFieldShouldReturn:(UITextField*)textField {
    NSInteger nextTag = textField.tag + 1;
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        [nextResponder becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
        [scrollView setContentOffset:svos animated:YES];
    }
    return NO;
}

#pragma mark - GET MEASURE / CATEGORY ACTIONS

- (IBAction)getCategory:(id)sender {
    FoodCategoryPicker *gcControl = [[FoodCategoryPicker alloc] init];
    gcControl.modalPresentationStyle = UIModalPresentationPageSheet;
    gcControl.sheetPresentationController.detents = @[[UISheetPresentationControllerDetent mediumDetent]];
    gcControl.delegate = self;
    [self presentViewController:gcControl animated:YES completion:nil];
}

- (IBAction)getMeasure:(id)sender {
    MeasurePicker *mpControl = [[MeasurePicker alloc] init];
    mpControl.modalPresentationStyle = UIModalPresentationPageSheet;
    mpControl.sheetPresentationController.detents = @[[UISheetPresentationControllerDetent mediumDetent]];
    mpControl.delegate = self;
    [self presentViewController:mpControl animated:YES completion:nil];
}

- (void)didChooseCategory:(NSString *)chosenID withName:(NSString *)chosenName {
    reloadData = NO;
    
    intCategoryID = [NSNumber numberWithInt:[chosenID intValue]];
    self.strCategoryName = chosenName;
    [selectCategoryButton setTitle: self.strCategoryName forState: UIControlStateNormal];
    [selectCategoryButton setTitle: self.strCategoryName forState: UIControlStateHighlighted];
    [selectCategoryButton setTitle: self.strCategoryName forState: UIControlStateSelected];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    dietmasterEngine.selectedCategoryID = intCategoryID;
    
    isSaved = NO;
}

- (void)didChooseMeasure:(NSString *)chosenMID withName:(NSString *)chosenMName {
    reloadData = NO;
    
    intMeasureID = [NSNumber numberWithInt:[chosenMID intValue]];
    self.strMeasureName = chosenMName;
    [selectMeasureButton setTitle: self.strMeasureName forState: UIControlStateNormal];
    [selectMeasureButton setTitle: self.strMeasureName forState: UIControlStateHighlighted];
    [selectMeasureButton setTitle: self.strMeasureName forState: UIControlStateSelected];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    dietmasterEngine.selectedMeasureID = intMeasureID;
    
    isSaved = NO;
}

#pragma mark DATA METHODS
-(void)clearEnteredData {
    for (int i=1; i<= NUMBER_OF_TEXTFIELDS; i++) {
        UITextField *textField = (UITextField*)[self.view viewWithTag:i];
        [textField setText:@""];
    }
    
    [scrollView setContentOffset:CGPointMake(0, 0)];
    
    [selectCategoryButton setTitle: @"Select Category" forState: UIControlStateNormal];
    [selectCategoryButton setTitle: @"Select Category" forState: UIControlStateHighlighted];
    [selectCategoryButton setTitle: @"Select Category" forState: UIControlStateSelected];
    [selectMeasureButton setTitle: @"Select Measure" forState: UIControlStateNormal];
    [selectMeasureButton setTitle: @"Select Measure" forState: UIControlStateHighlighted];
    [selectMeasureButton setTitle: @"Select Measure" forState: UIControlStateSelected];
    
    intMeasureID = [NSNumber numberWithInt:0];
    intCategoryID = [NSNumber numberWithInt:0];
    scanned_UPCA = nil;
    scanned_UPCA = @"empty";
    scanned_factualID = nil;
    scanned_factualID = @"empty";
}

- (void)loadData {
    if (!self.foodDict) {
        return;
    }
    [DMActivityIndicator showActivityIndicator];

    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
        
    }
    int foodID = [[self.foodDict valueForKey:@"FoodKey"] intValue];
    
    // First Query
    NSString *query = [NSString stringWithFormat:@"SELECT FoodKey,FoodID,Name,CategoryID, Calories, Fat, "
                       "Sodium, Carbohydrates, SaturatedFat, Cholesterol,Protein, "
                       "Fiber,Sugars, Pot,A, "
                       "Thi, Rib,Nia, B6, "
                       "B12,Fol,C, Calc, "
                       "Iron,Mag,Zn,ServingSize, "
                       "Transfat, E, D,Folate, "
                       "Frequency, UserID, CompanyID, UPCA, FactualID FROM Food WHERE FoodKey = %i", foodID];
    
    // Query Database
    FMResultSet *rs = [db executeQuery:query];
    while ([rs next]) {
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithInt:[rs intForColumn:@"FoodKey"]], @"FoodKey",
                              [NSNumber numberWithInt:[rs intForColumn:@"FoodID"]], @"FoodID",
                              [rs stringForColumn:@"Name"], @"Name",
                              [NSNumber numberWithInt:[rs intForColumn:@"CategoryID"]], @"CategoryID",
                              [NSNumber numberWithInt:[rs intForColumn:@"Calories"]], @"Calories",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Fat"]], @"Fat",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Sodium"]], @"Sodium",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Carbohydrates"]], @"Carbohydrates",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"SaturatedFat"]], @"SaturatedFat",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Cholesterol"]], @"Cholesterol",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Protein"]], @"Protein",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Fiber"]], @"Fiber",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Sugars"]], @"Sugars",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Pot"]], @"Pot",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"A"]], @"A",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Thi"]], @"Thi",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Rib"]], @"Rib",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Nia"]], @"Nia",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"B6"]], @"B6",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"B12"]], @"B12",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Fol"]], @"Fol",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"C"]], @"C",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Calc"]], @"Calc",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Iron"]], @"Iron",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Mag"]], @"Mag",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Zn"]], @"Zn",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"ServingSize"]], @"ServingSize",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Transfat"]], @"Transfat",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"E"]], @"E",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"D"]], @"D",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Folate"]], @"Folate",
                              [NSNumber numberWithDouble:[rs doubleForColumn:@"Frequency"]], @"Frequency",
                              [NSNumber numberWithInt:[rs doubleForColumn:@"UserID"]], @"UserID",
                              [NSNumber numberWithInt:[rs doubleForColumn:@"CompanyID"]], @"CompanyID",
                              [rs stringForColumn:@"UPCA"], @"UPCA",
                              [rs stringForColumn:@"FactualID"], @"FactualID",
                              nil];
        
        self.foodDict = [dict mutableCopy];
    }
    
    NSString *query2 = [NSString stringWithFormat: @"SELECT m.MeasureID, m.Description, fm.GramWeight FROM Measure m INNER JOIN FoodMeasure fm ON fm.MeasureID = m.MeasureID WHERE fm.FoodID = %i ORDER BY m.Description", foodID];
    
    rs = [db executeQuery:query2];
    while ([rs next]) {
        NSString *measureDesc =
            [[rs stringForColumn:@"Description"] stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                                         withString:[[[rs stringForColumn:@"Description"]  substringToIndex:1] capitalizedString]];
        
        [self.foodDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"MeasureID"]] forKey:@"MeasureID"];
        [self.foodDict setValue:[NSNumber numberWithDouble:[rs doubleForColumn:@"GramWeight"]] forKey:@"GramWeight"];
        [self.foodDict setValue:measureDesc forKey:@"Measure_Description"];
    }
    
    NSString *query3 = [NSString stringWithFormat: @"SELECT CategoryID, Name FROM FoodCategory WHERE CategoryID = %i", [[self.foodDict valueForKey:@"CategoryID"] intValue]];
    
    rs = [db executeQuery:query3];
    while ([rs next]) {
        [self.foodDict setValue:[rs stringForColumn:@"Name"] forKey:@"Category_Description"];
    }
    [rs close];
    
    txtfieldFoodName.text = [self.foodDict valueForKey:@"Name"];
    txtfieldCalories.text = [NSString stringWithFormat:@"%.2f",[[self.foodDict valueForKey:@"Calories"] doubleValue]];
    txtfieldTotalFat.text = [NSString stringWithFormat:@"%.2f",[[self.foodDict valueForKey:@"Fat"] doubleValue]];
    txtfieldSatFat.text = [NSString stringWithFormat:@"%.2f",[[self.foodDict valueForKey:@"SaturatedFat"] doubleValue]];
    txtfieldSodium.text = [NSString stringWithFormat:@"%.2f",[[self.foodDict valueForKey:@"Sodium"] doubleValue]];
    txtfieldCarbs.text = [NSString stringWithFormat:@"%.2f",[[self.foodDict valueForKey:@"Carbohydrates"] doubleValue]];
    txtfieldCholesterol.text = [NSString stringWithFormat:@"%.2f",[[self.foodDict valueForKey:@"Cholesterol"] doubleValue]];
    txtfieldProtein.text = [NSString stringWithFormat:@"%.2f",[[self.foodDict valueForKey:@"Protein"] doubleValue]];
    txtfieldFiber.text = [NSString stringWithFormat:@"%.2f",[[self.foodDict valueForKey:@"Fiber"] doubleValue]];
    txtfieldSugars.text = [NSString stringWithFormat:@"%.2f",[[self.foodDict valueForKey:@"Sugars"] doubleValue]];
    txtfieldPot.text = [NSString stringWithFormat:@"%.2f",[[self.foodDict valueForKey:@"Pot"] doubleValue]];
    txtfieldVitA.text = [NSString stringWithFormat:@"%.2f",[[self.foodDict valueForKey:@"A"] doubleValue]];
    txtfieldThiamin.text = [NSString stringWithFormat:@"%.2f",[[self.foodDict valueForKey:@"Thi"] doubleValue]];
    txtfieldRib.text = [NSString stringWithFormat:@"%.2f",[[self.foodDict valueForKey:@"Rib"] doubleValue]];
    txtfieldNiacin.text = [NSString stringWithFormat:@"%.2f",[[self.foodDict valueForKey:@"Nia"] doubleValue]];
    txtfieldVitB6.text = [NSString stringWithFormat:@"%.2f",[[self.foodDict valueForKey:@"B6"] doubleValue]];
    txtfieldVitB12.text = [NSString stringWithFormat:@"%.2f",[[self.foodDict valueForKey:@"B12"] doubleValue]];
    txtfieldFolicAcid.text = [NSString stringWithFormat:@"%.2f",[[self.foodDict valueForKey:@"Fol"] doubleValue]];
    txtfieldVitC.text = [NSString stringWithFormat:@"%.2f",[[self.foodDict valueForKey:@"C"] doubleValue]];
    txtfieldCalcium.text = [NSString stringWithFormat:@"%.2f",[[self.foodDict valueForKey:@"Calc"] doubleValue]];
    txtfieldIron.text = [NSString stringWithFormat:@"%.2f",[[self.foodDict valueForKey:@"Iron"] doubleValue]];
    txtfieldMag.text = [NSString stringWithFormat:@"%.2f",[[self.foodDict valueForKey:@"Mag"] doubleValue]];
    txtfieldZinc.text = [NSString stringWithFormat:@"%.2f",[[self.foodDict valueForKey:@"Zn"] doubleValue]];
    txtfieldFolate.text = [NSString stringWithFormat:@"%.2f",[[self.foodDict valueForKey:@"Folate"] doubleValue]];
    txtfieldServingSize.text = [NSString stringWithFormat:@"%.2f",[[self.foodDict valueForKey:@"ServingSize"] doubleValue]];
    txtfieldTransFat.text = [NSString stringWithFormat:@"%.2f",[[self.foodDict valueForKey:@"Transfat"] doubleValue]];
    txtfieldVitE.text = [NSString stringWithFormat:@"%.2f",[[self.foodDict valueForKey:@"E"] doubleValue]];
    txtfieldVitD.text = [NSString stringWithFormat:@"%.2f",[[self.foodDict valueForKey:@"D"] doubleValue]];
    
    if ([self.foodDict valueForKey:@"Category_Description"] == nil) {
        [selectCategoryButton setTitle:@"Select Category" forState: UIControlStateNormal];
        [selectCategoryButton setTitle:@"Select Category" forState: UIControlStateHighlighted];
        [selectCategoryButton setTitle:@"Select Category" forState: UIControlStateSelected];
    }
    else {
        [selectCategoryButton setTitle: [self.foodDict valueForKey:@"Category_Description"] forState: UIControlStateNormal];
        [selectCategoryButton setTitle: [self.foodDict valueForKey:@"Category_Description"] forState: UIControlStateHighlighted];
        [selectCategoryButton setTitle: [self.foodDict valueForKey:@"Category_Description"] forState: UIControlStateSelected];
    }
    [selectMeasureButton setTitle: [self.foodDict valueForKey:@"Measure_Description"] forState: UIControlStateNormal];
    [selectMeasureButton setTitle: [self.foodDict valueForKey:@"Measure_Description"] forState: UIControlStateHighlighted];
    [selectMeasureButton setTitle: [self.foodDict valueForKey:@"Measure_Description"] forState: UIControlStateSelected];
    
    if ([self.foodDict valueForKey:@"CategoryID"] == nil) {
        intCategoryID = [NSNumber numberWithInt:0];
    }
    else {
        intCategoryID = [self.foodDict valueForKey:@"CategoryID"];
    }
    intMeasureID = [self.foodDict valueForKey:@"MeasureID"];
    scanned_UPCA = nil;
    scanned_UPCA = @"empty";
    scanned_factualID = nil;
    scanned_factualID = @"empty";
    
    dietmasterEngine.selectedMeasureID = intMeasureID;
    dietmasterEngine.selectedCategoryID = intCategoryID;
}

- (void)recordFoodAndSaveToLog:(BOOL)saveToLog {
    for (int i=1; i<= NUMBER_OF_TEXTFIELDS; i++) {
        UITextField *textField = (UITextField*)[self.view viewWithTag:i];
        if ([textField isFirstResponder]) {
            [textField resignFirstResponder];
        }
    }
    
    if (([txtfieldFoodName.text length] > 0 || [txtfieldCalories.text length] > 0 || [txtfieldCarbs.text length] > 0 || [txtfieldProtein.text length] > 0 || [txtfieldTotalFat.text length] > 0 || [intMeasureID intValue] > 0) && [intCategoryID intValue] == 0) {
        [DMGUtilities showAlertWithTitle:@"Error" message:@"Category is Required. Please try again." inViewController:nil];
        return;
    }
    
    if ([txtfieldFoodName.text length] == 0 || [txtfieldCalories.text length] == 0 || [txtfieldCarbs.text length] == 0 || [txtfieldProtein.text length] == 0 || [txtfieldTotalFat.text length] == 0 || [intMeasureID intValue] == 0 || [intCategoryID intValue] == 0) {
        
        [DMGUtilities showAlertWithTitle:@"Error" message:@"Food Name, Measure, Category, Calories, Fat, Carbs & Protein are Required. Please try again." inViewController:nil];

        return;
    }
    else {
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
        if (![db open]) {
            
        }
        
        int minFoodID = 0;
        
        NSString *foodName        = txtfieldFoodName.text;
        NSNumber *calories        = [NSNumber numberWithDouble: [txtfieldCalories.text doubleValue]];
        NSNumber *fat            = [NSNumber numberWithDouble: [txtfieldTotalFat.text doubleValue]];
        NSNumber *satFat        = [NSNumber numberWithDouble: [txtfieldSatFat.text doubleValue]];
        NSNumber *sodium        = [NSNumber numberWithDouble: [txtfieldSodium.text doubleValue]];
        NSNumber *carbs            = [NSNumber numberWithDouble: [txtfieldCarbs.text doubleValue]];
        NSNumber *cholesterol    = [NSNumber numberWithDouble: [txtfieldCholesterol.text doubleValue]];
        NSNumber *protein        = [NSNumber numberWithDouble: [txtfieldProtein.text doubleValue]];
        NSNumber *fiber            = [NSNumber numberWithDouble: [txtfieldFiber.text doubleValue]];
        NSNumber *sugars        = [NSNumber numberWithDouble: [txtfieldSugars.text doubleValue]];
        NSNumber *pot            = [NSNumber numberWithDouble: [txtfieldPot.text doubleValue]];
        NSNumber *vitA            = [NSNumber numberWithDouble: [txtfieldVitA.text doubleValue]];
        NSNumber *thiamin        = [NSNumber numberWithDouble: [txtfieldThiamin.text doubleValue]];
        NSNumber *riboflavin    = [NSNumber numberWithDouble: [txtfieldRib.text doubleValue]];
        NSNumber *niacin        = [NSNumber numberWithDouble: [txtfieldNiacin.text doubleValue]];
        NSNumber *vitB6            = [NSNumber numberWithDouble: [txtfieldVitB6.text doubleValue]];
        NSNumber *vitB12        = [NSNumber numberWithDouble: [txtfieldVitB12.text doubleValue]];
        NSNumber *folicAcid        = [NSNumber numberWithDouble: [txtfieldFolicAcid.text doubleValue]];
        NSNumber *vitC            = [NSNumber numberWithDouble: [txtfieldVitC.text doubleValue]];
        NSNumber *calcium        = [NSNumber numberWithDouble: [txtfieldCalcium.text doubleValue]];
        NSNumber *iron            = [NSNumber numberWithDouble: [txtfieldIron.text doubleValue]];
        NSNumber *magnesium        = [NSNumber numberWithDouble: [txtfieldMag.text doubleValue]];
        NSNumber *zinc            = [NSNumber numberWithDouble: [txtfieldZinc.text doubleValue]];
        NSNumber *folate        = [NSNumber numberWithDouble: [txtfieldFolate.text doubleValue]];
        NSNumber *servingSize    = [NSNumber numberWithDouble: [txtfieldServingSize.text doubleValue]];
        NSNumber *transFat        = [NSNumber numberWithDouble: [txtfieldTransFat.text doubleValue]];
        NSNumber *vitE            = [NSNumber numberWithDouble: [txtfieldVitE.text doubleValue]];
        NSNumber *vitD            = [NSNumber numberWithDouble: [txtfieldVitD.text doubleValue]];
        
        foodName = [foodName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        
        int minIDvalue;
        NSString *idQuery = @"SELECT MIN(FoodKey) as FoodKey FROM Food";
        FMResultSet *rsID = [db executeQuery:idQuery];
        while ([rsID next]) {
            minIDvalue = [rsID intForColumn:@"FoodKey"];
        }
        [rsID close];
        minIDvalue = minIDvalue - 1;
        if (minIDvalue >=0) {
            int maxValue = minIDvalue;
            for (int i=0; i<maxValue; i++) {
                if (minIDvalue < 0){
                    break;
                }
                minIDvalue--;
            }
        }
        minFoodID = minIDvalue;
        
        if (servingSize==0) {
            servingSize = @1;
        }
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        NSDate *currentDate = [NSDate date];
        NSString *LastUpdated = [formatter stringFromDate:currentDate];
        
        DMAuthManager *authManager = [DMAuthManager sharedInstance];
        DMUser *currentUser = [authManager loggedInUser];
        int userID = currentUser.userId.intValue;
        int companyID = currentUser.companyId.intValue;
        
        NSString *insertSQL = [NSString stringWithFormat: @"REPLACE INTO Food"
         "(ScannedFood, FoodKey, "
          "FoodID, CategoryID, "
          "CompanyID, UserID, "
          "Name, Calories, "
          "Fat, Sodium, "
          "Carbohydrates, SaturatedFat, "
          "Cholesterol, Protein, "
          "Fiber, Sugars, "
          "Pot, A, "
          "Thi, Rib, "
          "Nia, B6, "
          "B12, Fol, "
          "C, Calc, "
          "Iron, Mag, "
          "Zn, ServingSize, "
          "Frequency, Folate, "
          "Transfat, E, "
          "D, UPCA, "
          "FactualID, LastUpdateDate)"
          "VALUES"
          "(%d, %i, "
          "%i, %i, "
          "%i, %i, "
          "\"%@\", %f, " //Name, Calories
          "%f, %f, "
          "%f, %f, "
          "%f, %f, "
          "%f, %f, "
          "%f, %f, " //Pot, A
          "%f, %f, "
          "%f, %f, "
          "%f, %f, "
          "%f, %f, "
          "%f, %f, "
          "%f, %f, "
          "%i, %f, " //frequency, folate
          "%f, %f, "
          "%f, '%@', "
          "'%@' , '%@') ",
          ScannedFoodis,
          minFoodID,
          -100,
          [intCategoryID intValue],
         
          companyID,
          userID,
          foodName,
         
          [calories doubleValue],
          [fat doubleValue],
          [sodium doubleValue],
          [carbs doubleValue],
          [satFat doubleValue],
          [cholesterol doubleValue],
          [protein doubleValue],
          [fiber doubleValue],
          [sugars doubleValue],
          [pot doubleValue],
          [vitA doubleValue],
          [thiamin doubleValue],
          [riboflavin doubleValue],
          [niacin doubleValue],
          [vitB6 doubleValue],
          [vitB12 doubleValue],
          [folicAcid doubleValue],
          [vitC doubleValue],
          [calcium doubleValue],
          [iron doubleValue],
          [magnesium doubleValue],
          [zinc doubleValue],
          [servingSize doubleValue],
          1,
          [folate doubleValue],
          [transFat doubleValue],
          [vitE doubleValue],
          [vitD doubleValue],
          scanned_UPCA,
          scanned_factualID,
          LastUpdated];
        
        [db beginTransaction];
        [db executeUpdate:insertSQL];
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        
        NSString *insertFMSQL = [NSString stringWithFormat: @"REPLACE INTO FoodMeasure (FoodID, MeasureID, GramWeight) VALUES (%i, %i, 100)", minFoodID,[intMeasureID intValue]];
        [db executeUpdate:insertFMSQL];
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
        
        [DMActivityIndicator showCompletedIndicator];
        isSaved = YES;
        
        _savedFoodID = minFoodID;
        
        // Save to log AND cloud.
        [self saveFoodWithKey:@(minFoodID) saveToLog:saveToLog];

        ScannedFoodis = NO;
    }
}

- (void)updateFoodAndSaveToLog:(BOOL)saveToLog {
    for (int i=1; i<= NUMBER_OF_TEXTFIELDS; i++) {
        UITextField *textField = (UITextField*)[self.view viewWithTag:i];
        
        if ([textField isFirstResponder]) {
            [textField resignFirstResponder];
        }
    }
    
    if (([txtfieldFoodName.text length] > 0 || [txtfieldCalories.text length] > 0 || [txtfieldCarbs.text length] > 0 || [txtfieldProtein.text length] > 0 || [txtfieldTotalFat.text length] > 0 || [intMeasureID intValue] > 0) && [intCategoryID intValue] == 0) {
        
        [DMGUtilities showAlertWithTitle:@"Error" message:@"Category is Required. Please try again." inViewController:nil];

        return;
    }
    
    if ([txtfieldFoodName.text length] == 0 || [txtfieldCalories.text length] == 0 || [txtfieldCarbs.text length] == 0 || [txtfieldProtein.text length] == 0 || [txtfieldTotalFat.text length] == 0 || [intMeasureID intValue] == 0 || [intCategoryID intValue] == 0) {
        
        [DMGUtilities showAlertWithTitle:@"Error" message:@"Food Name, Measure, Category, Calories, Fat, Carbs & Protein are Required. Please try again." inViewController:nil];

        return;
    }
    else {
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
        if (![db open]) {
            
        }
        
        int minFoodID = 0;
        
        NSString *foodName        = txtfieldFoodName.text;
        NSNumber *calories        = [NSNumber numberWithDouble: [txtfieldCalories.text doubleValue]];
        NSNumber *fat            = [NSNumber numberWithDouble: [txtfieldTotalFat.text doubleValue]];
        NSNumber *satFat        = [NSNumber numberWithDouble: [txtfieldSatFat.text doubleValue]];
        NSNumber *sodium        = [NSNumber numberWithDouble: [txtfieldSodium.text doubleValue]];
        NSNumber *carbs            = [NSNumber numberWithDouble: [txtfieldCarbs.text doubleValue]];
        NSNumber *cholesterol    = [NSNumber numberWithDouble: [txtfieldCholesterol.text doubleValue]];
        NSNumber *protein        = [NSNumber numberWithDouble: [txtfieldProtein.text doubleValue]];
        NSNumber *fiber            = [NSNumber numberWithDouble: [txtfieldFiber.text doubleValue]];
        NSNumber *sugars        = [NSNumber numberWithDouble: [txtfieldSugars.text doubleValue]];
        NSNumber *pot            = [NSNumber numberWithDouble: [txtfieldPot.text doubleValue]];
        NSNumber *vitA            = [NSNumber numberWithDouble: [txtfieldVitA.text doubleValue]];
        NSNumber *thiamin        = [NSNumber numberWithDouble: [txtfieldThiamin.text doubleValue]];
        NSNumber *riboflavin    = [NSNumber numberWithDouble: [txtfieldRib.text doubleValue]];
        NSNumber *niacin        = [NSNumber numberWithDouble: [txtfieldNiacin.text doubleValue]];
        NSNumber *vitB6            = [NSNumber numberWithDouble: [txtfieldVitB6.text doubleValue]];
        NSNumber *vitB12        = [NSNumber numberWithDouble: [txtfieldVitB12.text doubleValue]];
        NSNumber *folicAcid        = [NSNumber numberWithDouble: [txtfieldFolicAcid.text doubleValue]];
        NSNumber *vitC            = [NSNumber numberWithDouble: [txtfieldVitC.text doubleValue]];
        NSNumber *calcium        = [NSNumber numberWithDouble: [txtfieldCalcium.text doubleValue]];
        NSNumber *iron            = [NSNumber numberWithDouble: [txtfieldIron.text doubleValue]];
        NSNumber *magnesium        = [NSNumber numberWithDouble: [txtfieldMag.text doubleValue]];
        NSNumber *zinc            = [NSNumber numberWithDouble: [txtfieldZinc.text doubleValue]];
        NSNumber *folate        = [NSNumber numberWithDouble: [txtfieldFolate.text doubleValue]];
        NSNumber *servingSize    = [NSNumber numberWithDouble: [txtfieldServingSize.text doubleValue]];
        NSNumber *transFat        = [NSNumber numberWithDouble: [txtfieldTransFat.text doubleValue]];
        NSNumber *vitE            = [NSNumber numberWithDouble: [txtfieldVitE.text doubleValue]];
        NSNumber *vitD            = [NSNumber numberWithDouble: [txtfieldVitD.text doubleValue]];
        
        minFoodID = [[self.foodDict valueForKey:@"FoodKey"] intValue];
        
        NSString *updateSQL = [NSString stringWithFormat:@"UPDATE Food SET "
                               "Name = '%@', "
                               "CategoryID = %i, "
                               "Calories = %.2f, "
                               "Fat = %.2f, "
                               "Sodium = %.2f, "
                               "Carbohydrates = %.2f, "
                               "SaturatedFat = %.2f, "
                               "Cholesterol = %.2f, "
                               "Protein = %.2f, "
                               "Fiber = %.2f, "
                               "Sugars = %.2f, "
                               "Pot = %.2f, "
                               "A = %.2f, "
                               "Thi = %.2f, "
                               "Rib = %.2f, "
                               "Nia = %.2f, "
                               "B6 = %.2f, "
                               "B12 = %.2f, "
                               "Fol = %.2f, "
                               "C = %.2f, "
                               "Calc = %.2f, "
                               "Iron = %.2f, "
                               "Mag = %.2f, "
                               "Zn = %.2f, "
                               "ServingSize = %.2f, "
                               "Transfat = %.2f, "
                               "E = %.2f, "
                               "D = %.2f, "
                               "Folate = %.2f, "
                               "Frequency = %i, "
                               "UserID = %i, "
                               "CompanyID = %i "
                               "WHERE FoodKey = %i",
                               foodName, [intCategoryID intValue], [calories doubleValue], [fat doubleValue],
                               [sodium doubleValue],[carbs doubleValue], [satFat doubleValue],[cholesterol doubleValue], [protein doubleValue],
                               [fiber doubleValue],[sugars doubleValue], [pot doubleValue],[vitA doubleValue],
                               [thiamin doubleValue],[riboflavin doubleValue], [niacin doubleValue],[vitB6 doubleValue],
                               [vitB12 doubleValue], [folicAcid doubleValue], [vitC doubleValue],[calcium doubleValue],
                               [iron doubleValue], [magnesium doubleValue], [zinc doubleValue],  [servingSize doubleValue],
                               [transFat doubleValue], [vitE doubleValue], [vitD doubleValue],[folate doubleValue],
                               -100,100,100, minFoodID];
        
        [db beginTransaction];
        [db executeUpdate:updateSQL];
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        
        NSString *updateFMSQL = [NSString stringWithFormat: @"UPDATE FoodMeasure SET "
                                 "MeasureID = %i, "
                                 "GramWeight = %i "
                                 "WHERE FoodID = %i ",
                                 [intMeasureID intValue], 100, minFoodID];
        
        [db executeUpdate:updateFMSQL];
        if ([db hadError]) {
            DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
        
        isSaved = YES;
        _savedFoodID = minFoodID;
        
        [self saveFoodWithKey:@(minFoodID) saveToLog:saveToLog];
    }
}

/// Saves the Food for the key provided to the server.
/// NOTE: The key is likely temporary (-100 value), so don't rely on it for future operations.
- (void)saveFoodWithKey:(NSNumber *)key saveToLog:(BOOL)saveToLog {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    [dietmasterEngine saveFoodForKey:key withCompletionBlock:^(NSObject *object, NSError *error) {
        [DMActivityIndicator hideActivityIndicator];
        if (error) {
            [DMGUtilities showAlertWithTitle:@"Error" message:error.localizedDescription inViewController:nil];
            DietmasterEngine *dietmasterEngine = [DietmasterEngine sharedInstance];
            dietmasterEngine.taskMode = @"View";
            [self loadData];
            return;
        }
        [DMActivityIndicator showCompletedIndicator];
        NSArray *results = (NSArray *)object;
        NSDictionary *foodValues = [results firstObject];
        if (saveToLog) {
            DietmasterEngine *dietmasterEngine = [DietmasterEngine sharedInstance];
            if (dietmasterEngine.isMealPlanItem) {
                dietmasterEngine.taskMode = @"AddMealPlanItem";
            } else {
                dietmasterEngine.taskMode = @"Save";
            }
            DMDatabaseProvider *provider = [[DMDatabaseProvider alloc] init];
            DMFood *food = [provider getFoodForFoodKey:foodValues[@"FoodID"]];
            DetailViewController *dvController = [[DetailViewController alloc] initWithFood:[food dictionaryRepresentation]];
            [self.navigationController pushViewController:dvController animated:YES];
            [self clearEnteredData];
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:nil];
    }];
}

#pragma mark BARCODE SCANNER METHODS

- (IBAction)loadBarcodeScanner:(id)sender {
    self.barcodeScanner = [[BarCodeScanner alloc] init];
    __weak typeof(self) weakSelf = self;
    self.barcodeScanner.didScanUPCCodeCallback = ^(NSDictionary *object) {
        [weakSelf barcodeWasScanned:object];
    };
    self.barcodeScanner.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:self.barcodeScanner animated:YES completion:Nil];
}

- (void)barcodeWasScanned:(NSDictionary *)upcDict {
    [DMActivityIndicator showActivityIndicator];
    [self.barcodeScanner dismissViewControllerAnimated:YES completion:nil];
    __weak typeof(self) weakSelf = self;
    [self fetchDataFromNutritionixForUPC:[upcDict valueForKey:@"UPC"] withCompletionBlock:^(NSObject *object, NSError *error) {
        [DMActivityIndicator hideActivityIndicator];
        if (error) {
            [DMGUtilities showAlertWithTitle:@"Error" message:error.localizedDescription inViewController:nil];
            return;
        }
        NSDictionary *jsonDict = (NSDictionary *)object;
        if ([[jsonDict valueForKey:@"message"] isEqualToString:@"resource not found"]) {
            [weakSelf showUPCNotFoundConfirmation];
        } else {
            [DMGUtilities showAlertWithTitle:@"Success" message:@"Nutritional information found! Please confirm values then select Category." inViewController:nil];
            NSMutableArray *foods = [jsonDict valueForKey:@"foods"];
            [weakSelf nutritionixAPISuccess:foods.firstObject];
        }
    }];
}

- (void)fetchDataFromNutritionixForUPC:(NSString *)upcCode withCompletionBlock:(completionBlockWithObject)completionBlock {
    NSString *urlString = [NSString stringWithFormat:@"https://trackapi.nutritionix.com/v2/search/item?upc=%@", upcCode];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:0
                                                       timeoutInterval:120];
    [request setValue:@"7a144547" forHTTPHeaderField:@"x-app-id"];
    [request setValue:@"c02e7975164bf7207601b2712ec56137" forHTTPHeaderField:@"x-app-key"];
    [request setHTTPMethod:@"GET"];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            id results = nil; // Should this be nil or empty?
            @try {
                NSError *jsonError = nil;
                if (data) {
                    results = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                }
                // Handle error.
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completionBlock) {
                            completionBlock(nil, error);
                        }
                    });
                    return;
                }
                if (!data) {
                    NSError *error = [DMGUtilities errorWithMessage:@"Error: No data returned." code:777];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completionBlock) {
                            completionBlock(nil, error);
                        }
                    });
                    return;
                }
            } @catch (NSException *exception) {
                DM_LOG(@"Fetch UPC JSON Exception: %@", exception);
                NSError *error = [DMGUtilities errorWithMessage:exception.reason code:999];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completionBlock) {
                        completionBlock(nil, error);
                    }
                });
                return;
            }
        
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(results, nil);
                }
            });
      }] resume];
}

- (void)showUPCNotFoundConfirmation {
    NSString *errorMessageString = @"Nutritional information for the UPC scanned was not found. Would you like to add it?";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Not Found"
                                                                   message:errorMessageString
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"No"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
        scanned_UPCA = nil;
        scanned_UPCA = [[NSString alloc] initWithString:@"empty"];
        scanned_factualID = nil;
        scanned_factualID = [[NSString alloc] initWithString:@"empty"];
        isSaved = YES;
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Nutritionix

- (void)nutritionixAPISuccess:(NSDictionary *)dict {
    scannerDict = [dict mutableCopy];
    scanned_factualID = [[NSString alloc] initWithString:[dict valueForKey:@"nix_item_id"]];
    
    NSString *serving_size = [dict valueForKey:@"serving_qty"];
    txtfieldServingSize.text = [NSString stringWithFormat:@"%.2f",[serving_size doubleValue]];
    NSDictionary *dictTemp = [self findMeasureId:[dict valueForKey:@"serving_unit"]];
        
    if (!dictTemp) {
        intMeasureID = [NSNumber numberWithInt:3];
        self.strMeasureName = @"each";
        [selectMeasureButton setTitle: self.strMeasureName forState: UIControlStateNormal];
        [selectMeasureButton setTitle: self.strMeasureName forState: UIControlStateHighlighted];
        [selectMeasureButton setTitle: self.strMeasureName forState: UIControlStateSelected];
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        dietmasterEngine.selectedMeasureID = intMeasureID;
    } else {
        NSString *measureValue = [dictTemp valueForKey:@"MeasureID"];
        intMeasureID = [NSNumber numberWithInt:[measureValue intValue]];
        self.strMeasureName = [dictTemp valueForKey:@"Description"];
        
        [selectMeasureButton setTitle: self.strMeasureName forState: UIControlStateNormal];
        [selectMeasureButton setTitle: self.strMeasureName forState: UIControlStateHighlighted];
        [selectMeasureButton setTitle: self.strMeasureName forState: UIControlStateSelected];
        
        DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
        dietmasterEngine.selectedMeasureID = intMeasureID;
    }
    
    txtfieldFoodName.text = [NSString stringWithFormat:@"%@ %@",
                             [dict valueForKey:@"brand_name"], [dict valueForKey:@"food_name"]];
    
    if ([dict valueForKey:@"nf_calories"] != [NSNull null]) {
        txtfieldCalories.text = [NSString stringWithFormat:@"%.2f",[[dict valueForKey:@"nf_calories"] doubleValue]];
    }
    
    if ([dict valueForKey:@"nf_total_fat"] != [NSNull null]) {
        txtfieldTotalFat.text = [NSString stringWithFormat:@"%.2f",[[dict valueForKey:@"nf_total_fat"] doubleValue]];
    }
    
    if ([dict valueForKey:@"nf_saturated_fat"] != [NSNull null]) {
        txtfieldSatFat.text = [NSString stringWithFormat:@"%.2f",[[dict valueForKey:@"nf_saturated_fat"] doubleValue]];
    }
    
    if ([dict valueForKey:@"nf_sodium"] != [NSNull null]) {
        txtfieldSodium.text = [NSString stringWithFormat:@"%.2f",[[dict valueForKey:@"nf_sodium"] doubleValue]];
    }
    
    if ([dict valueForKey:@"nf_total_carbohydrate"] != [NSNull null]) {
        txtfieldCarbs.text = [NSString stringWithFormat:@"%.2f",[[dict valueForKey:@"nf_total_carbohydrate"] doubleValue]];
    }
    
    if ([dict valueForKey:@"nf_cholesterol"] != [NSNull null]) {
        txtfieldCholesterol.text = [NSString stringWithFormat:@"%.2f",[[dict valueForKey:@"nf_cholesterol"] doubleValue]];
    }
    
    if ([dict valueForKey:@"nf_protein"]  != [NSNull null]) {
        txtfieldProtein.text = [NSString stringWithFormat:@"%.2f",[[dict valueForKey:@"nf_protein"] doubleValue]];
    }
    
    if ([dict valueForKey:@"nf_dietary_fiber"] != [NSNull null]) {
        txtfieldFiber.text = [NSString stringWithFormat:@"%.2f",[[dict valueForKey:@"nf_dietary_fiber"] doubleValue]];
    }
    
    if ([dict valueForKey:@"nf_sugars"] != [NSNull null]) {
        txtfieldSugars.text = [NSString stringWithFormat:@"%.2f",[[dict valueForKey:@"nf_sugars"] doubleValue]];
    }
    
    //not found in API response
    if ([dict valueForKey:@"trans_fat"] != [NSNull null] && [dict valueForKey:@"trans_fat"] != nil)  {
        txtfieldTransFat.text = [NSString stringWithFormat:@"%.2f",[[dict valueForKey:@"trans_fat"] doubleValue]];
    }
    
    if ([dict valueForKey:@"nf_potassium"] != [NSNull null]) {
        txtfieldPot.text = [NSString stringWithFormat:@"%.2f",[[dict valueForKey:@"nf_potassium"] doubleValue]];
    }
    
    ScannedFoodis=YES;
}

- (NSDictionary *)findMeasureId:(NSString *)serving_unit {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    
    NSString *query = [NSString stringWithFormat:@"SELECT MeasureID, Description FROM Measure WHERE Description = '%@'", serving_unit];
    FMResultSet *rs = [db executeQuery:query];
    NSDictionary *dict = nil;
    while ([rs next]) {
        dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                    [rs stringForColumn:@"Description"], @"Description",
                    [NSNumber numberWithInt:[rs intForColumn:@"MeasureID"]],@"MeasureID",
                    nil];
    }
    
    return dict;
}

#pragma mark ACTIONSHEET METHODS

- (IBAction)showActionSheet:(id)sender {
    [self.view endEditing:YES];
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:5566];
    if (imageView != nil) {
        [UIView animateWithDuration: 0.25f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations: ^{
            imageView.alpha = 0.0;
        } completion: ^ (BOOL finished) {
            [imageView removeFromSuperview];
            self.helperBubbleWasShown = YES;
        }];
    }
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    NSString *actionButtonName = nil;
    NSString *saveToLogName = nil;
    
    if([dietmasterEngine.taskMode isEqualToString:@"View"]) {
        actionButtonName = @"Update";
        saveToLogName = @"Update & Add to Log";
    }
    else {
        actionButtonName = @"Save";
        saveToLogName = @"Save & Add to Log";
    }
    
    if (self.hideAddToLog) {
        saveToLogName = nil;
    }
    
    NSString *alertTitle = @"Select Action";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle message:@"" preferredStyle:UIAlertControllerStyleActionSheet];

    if([dietmasterEngine.taskMode isEqualToString:@"View"]) {
        [alert addAction:[UIAlertAction actionWithTitle:actionButtonName style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if ([self->txtfieldServingSize.text doubleValue]<=0) {
                [self alertServingSizeInvalid];
                return;
            }
            [self updateFoodAndSaveToLog:NO];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:saveToLogName style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self updateFoodAndSaveToLog:YES];
        }]];
    }
    else {
        [alert addAction:[UIAlertAction actionWithTitle:@"Scan Barcode" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self loadBarcodeScanner:nil];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:actionButtonName style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if ([self->txtfieldServingSize.text doubleValue]<=0) {
                [self alertServingSizeInvalid];
                return;
            }
            [self recordFoodAndSaveToLog:NO];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:saveToLogName style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self recordFoodAndSaveToLog:YES];
        }]];
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

/// Shows an alert to the user that serving size is invalid.
- (void)alertServingSizeInvalid {
    [DMGUtilities showAlertWithTitle:APP_NAME
                             message:@"Serving Size must be a number greater than 0."
                    inViewController:nil];
}

#pragma mark - SCROLL VIEW DELEGATES -
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:5566];
    if (imageView == nil) {
        return;
    }
    
    [UIView animateWithDuration: 0.25f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         imageView.alpha = 0.0;
                     }
                     completion: ^ (BOOL finished) {
                         [imageView removeFromSuperview];
                         self.helperBubbleWasShown = YES;
                     }];
    
}

#pragma mark TAP GESTURE DELEGATES
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

-(void)tappedScrollView:(id)sender {
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:5566];
    if (imageView == nil) {
        return;
    }
    
    [UIView animateWithDuration: 0.5f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         imageView.alpha = 0.0;
                     }
                     completion: ^ (BOOL finished) {
                         [imageView removeFromSuperview];
                         self.helperBubbleWasShown = YES;
                     }];
    
}

#pragma mark Save To Log Methods

- (void)foodWasSavedToCloud:(NSNotification *)notification {
}

@end

