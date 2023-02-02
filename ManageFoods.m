#import "ManageFoods.h"
#import <QuartzCore/QuartzCore.h>
#import "DietMasterGoViewController.h"
#import "DietMasterGoAppDelegate.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "DietmasterEngine.h"
#import "DetailViewController.h"

@implementation ManageFoods

@synthesize mainDelegate, scrollView, intFoodID, intCategoryID, strCategoryName, intMeasureID, strMeasureName;
@synthesize selectedFoodDict;
@synthesize barcodeScannerVC;
@synthesize scannerDict, scanned_UPCA, scanned_factualID, scannerButton;

static const int NUMBER_OF_TEXTFIELDS = 28;
CGPoint svos;

#pragma mark VIEW LIFECYCLE

-(void)viewDidLoad {
    [super viewDidLoad];
    
    mainDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    CGRect scrollViewFrame = scrollView.frame;
    self.view.frame = CGRectMake(0, applicationFrame.origin.y+64, self.view.frame.size.width, applicationFrame.size.height);
    scrollView.frame = CGRectMake(0, applicationFrame.origin.y+64, self.view.frame.size.width, applicationFrame.size.height);
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, scrollViewFrame.size.height)];
    
    selectMeasureButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    selectCategoryButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    intCategoryID = [NSNumber numberWithInt:0];
    intMeasureID = [NSNumber numberWithInt:0];
    
    if (!selectedFoodDict) {
        selectedFoodDict = [[NSMutableDictionary alloc] init];
    }
    
    reloadData = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(barcodeWasScanned:) name:@"BarcodeScanned" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(factualAPISuccess:) name:@"FactualAPISuccess" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(factualAPIDidFail:) name:@"FactualAPIDidFail" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(foodWasSavedToCloud:) name:@"FoodWasSavedToCloud" object:nil];
    
    barcodeScannerVC = nil;
    scannerDict = nil;
    scanned_UPCA = nil;
    scanned_UPCA = [[NSString alloc] initWithString:@"empty"];
    scanned_factualID = nil;
    scanned_factualID = [[NSString alloc] initWithString:@"empty"];
    
    scannerButton.layer.cornerRadius = 22.0;
    scannerButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    scannerButton.layer.borderWidth = 1.0;
    scannerButton.backgroundColor = [UIColor grayColor];
    scannerButton.frame = CGRectMake(20,  SCREEN_HEIGHT-180,
                                     scannerButton.frame.size.width, scannerButton.frame.size.height);
    scannerButton.alpha = 0.80;
    
    helperBubbleWasShown = NO;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedScrollView:)];
    tapGesture.numberOfTapsRequired = 1.0;
    tapGesture.numberOfTouchesRequired = 1.0;
    [scrollView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStylePlain
                                   target: self action: @selector(customBackAction:)];
    
    [self.navigationItem setLeftBarButtonItem: backButton];
    [backButton release];
    
    isSaved = YES;
    _savedFoodID = 0;
    _saveToLog = NO;
    
    [self.navigationController.navigationBar setTranslucent:NO];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:PLIST_NAME];
    NSDictionary *appDefaults = [[[NSDictionary alloc] initWithContentsOfFile:finalPath] autorelease];
    
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
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    if([dietmasterEngine.taskMode isEqualToString:@"View"]) {
        [self.navigationItem setTitle:@"Update Food"];
    }
    else {
        [self.navigationItem setTitle:@"Add New Food"];
    }
    
    UIImage* image3 = [UIImage imageNamed:@"menuscan.png"];
    UIButton *urButton = [UIButton buttonWithType:UIButtonTypeCustom];
    urButton.frame = CGRectMake(0, 0, 30, 30);
    [urButton setBackgroundImage:image3 forState:UIControlStateNormal];
    [urButton addTarget:self action:@selector(showActionSheet:)
       forControlEvents:UIControlEventTouchUpInside];
    urButton.clipsToBounds = YES;
    urButton.layer.cornerRadius =3;
    urButton.layer.borderColor=[UIColor blackColor].CGColor;
    urButton.layer.borderWidth=0.8f;
    UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithCustomView:urButton];
    self.navigationItem.rightBarButtonItem=doneButton;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    
    if([dietmasterEngine.taskMode isEqualToString:@"View"] && reloadData == YES) {
        [self showLoading];
        [self performSelector:@selector(loadData) withObject:nil afterDelay:0.15];
    }
    
    if (!helperBubbleWasShown && ![dietmasterEngine.taskMode isEqualToString:@"View"]) {
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calloutbubble"]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame = CGRectMake(self.view.frame.size.width-204, 0, 204, 113);
        imageView.alpha = 0.0;
        imageView.tag = 5566;
        imageView.userInteractionEnabled = YES;
        imageView.exclusiveTouch = YES;
        [self.view addSubview:imageView];
        [imageView release];
        
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
                                                  helperBubbleWasShown = YES;
                                              }];
                         }];
    }
}

//-(void)viewDidUnload {
//    [super viewDidUnload];
//    selectedFoodDict = nil;
//    scannerButton = nil;
//    barcodeScannerVC = nil;
//    scanned_factualID = nil;
//    scanned_UPCA = nil;
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}

-(void)dealloc {
    [super dealloc];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [selectCategoryButton release];
    [selectMeasureButton release];
    
    [keyboardToolBar release];
    [closeDoneButton release];
    
    barcodeScannerVC = nil;
    [barcodeScannerVC release];
    
    scanned_UPCA = nil;
    scanned_factualID = nil;
    scannerButton = nil;
    
    selectedFoodDict = nil;
    scannerButton = nil;
    barcodeScannerVC = nil;
    scanned_factualID = nil;
    scanned_UPCA = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark BACK METHODS
-(void)customBackAction:(id)sender {
    if (!isSaved) {
        UIAlertView *alert;
        NSString *errorMessageString = @"This Food has not been saved. Are you sure you wish to exit?";
        alert = [[UIAlertView alloc] initWithTitle:@"Wait a second!" message:errorMessageString delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [alert addButtonWithTitle:@"Yes, Exit"];
        [alert addButtonWithTitle:@"No, Stay"];
        [alert setTag:770088];
        [alert show];
        [alert release];
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

#pragma mark GET MEASURE / CATEGORY ACTIONS
- (IBAction) getCategory:(id) sender {
    FoodCategoryPicker *gcControl = [[FoodCategoryPicker alloc] initWithNibName:@"FoodCategoryPicker" bundle:nil];
    gcControl.delegate = self;
    [self presentViewController:gcControl animated:YES completion:nil];
    [gcControl release];
}

- (IBAction) getMeasure:(id) sender {
    MeasurePicker *mpControl = [[MeasurePicker alloc] initWithNibName:@"MeasurePicker" bundle:nil];
    mpControl.delegate = self;
    [self presentViewController:mpControl animated:YES completion:nil];
    [mpControl release];
}

-(void)didChooseCategory:(NSString *)chosenID withName:(NSString *)chosenName {
    reloadData = NO;
    
    intCategoryID = [NSNumber numberWithInt:[chosenID intValue]];
    self.strCategoryName = chosenName;
    [selectCategoryButton setTitle: self.strCategoryName forState: UIControlStateNormal];
    [selectCategoryButton setTitle: self.strCategoryName forState: UIControlStateHighlighted];
    [selectCategoryButton setTitle: self.strCategoryName forState: UIControlStateSelected];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    dietmasterEngine.selectedCategoryID = intCategoryID;
    
    isSaved = NO;
}

-(void)didChooseMeasure:(NSString *)chosenMID withName:(NSString *)chosenMName {
    reloadData = NO;
    
    intMeasureID = [NSNumber numberWithInt:[chosenMID intValue]];
    self.strMeasureName = chosenMName;
    [selectMeasureButton setTitle: self.strMeasureName forState: UIControlStateNormal];
    [selectMeasureButton setTitle: self.strMeasureName forState: UIControlStateHighlighted];
    [selectMeasureButton setTitle: self.strMeasureName forState: UIControlStateSelected];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
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
    scanned_UPCA = [[NSString alloc] initWithString:@"empty"];
    scanned_factualID = nil;
    scanned_factualID = [[NSString alloc] initWithString:@"empty"];
}

-(void)loadData {
    reloadData = YES;
    if (selectedFoodDict) {
        [selectedFoodDict removeAllObjects];
    }
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
        
    }
    int foodID = [[dietmasterEngine.foodSelectedDict valueForKey:@"FoodKey"] intValue];
    
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
        
        [selectedFoodDict setDictionary:dict];
        [dict release];
        
    }
    
    NSString *query2 = [NSString stringWithFormat: @"SELECT m.MeasureID, m.Description, fm.GramWeight FROM Measure m INNER JOIN FoodMeasure fm ON fm.MeasureID = m.MeasureID WHERE fm.FoodID = %i ORDER BY m.Description", foodID];
    
    rs = [db executeQuery:query2];
    while ([rs next]) {
        
        NSString *measureDesc = [[rs stringForColumn:@"Description"] stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                                                             withString:[[[rs stringForColumn:@"Description"]  substringToIndex:1] capitalizedString]];
        
        [selectedFoodDict setValue:[NSNumber numberWithInt:[rs intForColumn:@"MeasureID"]] forKey:@"MeasureID"];
        [selectedFoodDict setValue:[NSNumber numberWithDouble:[rs doubleForColumn:@"GramWeight"]] forKey:@"GramWeight"];
        [selectedFoodDict setValue:measureDesc forKey:@"Measure_Description"];
        
    }
    
    NSString *query3 = [NSString stringWithFormat: @"SELECT CategoryID, Name FROM FoodCategory WHERE CategoryID = %i", [[selectedFoodDict valueForKey:@"CategoryID"] intValue]];
    
    rs = [db executeQuery:query3];
    while ([rs next]) {
        
        
        [selectedFoodDict setValue:[rs stringForColumn:@"Name"] forKey:@"Category_Description"];
        
    }
    [rs close];
    
    txtfieldFoodName.text = [selectedFoodDict valueForKey:@"Name"];
    txtfieldCalories.text = [NSString stringWithFormat:@"%.2f",[[selectedFoodDict valueForKey:@"Calories"] doubleValue]];
    txtfieldTotalFat.text = [NSString stringWithFormat:@"%.2f",[[selectedFoodDict valueForKey:@"Fat"] doubleValue]];
    txtfieldSatFat.text = [NSString stringWithFormat:@"%.2f",[[selectedFoodDict valueForKey:@"SaturatedFat"] doubleValue]];
    txtfieldSodium.text = [NSString stringWithFormat:@"%.2f",[[selectedFoodDict valueForKey:@"Sodium"] doubleValue]];
    txtfieldCarbs.text = [NSString stringWithFormat:@"%.2f",[[selectedFoodDict valueForKey:@"Carbohydrates"] doubleValue]];
    txtfieldCholesterol.text = [NSString stringWithFormat:@"%.2f",[[selectedFoodDict valueForKey:@"Cholesterol"] doubleValue]];
    txtfieldProtein.text = [NSString stringWithFormat:@"%.2f",[[selectedFoodDict valueForKey:@"Protein"] doubleValue]];
    txtfieldFiber.text = [NSString stringWithFormat:@"%.2f",[[selectedFoodDict valueForKey:@"Fiber"] doubleValue]];
    txtfieldSugars.text = [NSString stringWithFormat:@"%.2f",[[selectedFoodDict valueForKey:@"Sugars"] doubleValue]];
    txtfieldPot.text = [NSString stringWithFormat:@"%.2f",[[selectedFoodDict valueForKey:@"Pot"] doubleValue]];
    txtfieldVitA.text = [NSString stringWithFormat:@"%.2f",[[selectedFoodDict valueForKey:@"A"] doubleValue]];
    txtfieldThiamin.text = [NSString stringWithFormat:@"%.2f",[[selectedFoodDict valueForKey:@"Thi"] doubleValue]];
    txtfieldRib.text = [NSString stringWithFormat:@"%.2f",[[selectedFoodDict valueForKey:@"Rib"] doubleValue]];
    txtfieldNiacin.text = [NSString stringWithFormat:@"%.2f",[[selectedFoodDict valueForKey:@"Nia"] doubleValue]];
    txtfieldVitB6.text = [NSString stringWithFormat:@"%.2f",[[selectedFoodDict valueForKey:@"B6"] doubleValue]];
    txtfieldVitB12.text = [NSString stringWithFormat:@"%.2f",[[selectedFoodDict valueForKey:@"B12"] doubleValue]];
    txtfieldFolicAcid.text = [NSString stringWithFormat:@"%.2f",[[selectedFoodDict valueForKey:@"Fol"] doubleValue]];
    txtfieldVitC.text = [NSString stringWithFormat:@"%.2f",[[selectedFoodDict valueForKey:@"C"] doubleValue]];
    txtfieldCalcium.text = [NSString stringWithFormat:@"%.2f",[[selectedFoodDict valueForKey:@"Calc"] doubleValue]];
    txtfieldIron.text = [NSString stringWithFormat:@"%.2f",[[selectedFoodDict valueForKey:@"Iron"] doubleValue]];
    txtfieldMag.text = [NSString stringWithFormat:@"%.2f",[[selectedFoodDict valueForKey:@"Mag"] doubleValue]];
    txtfieldZinc.text = [NSString stringWithFormat:@"%.2f",[[selectedFoodDict valueForKey:@"Zn"] doubleValue]];
    txtfieldFolate.text = [NSString stringWithFormat:@"%.2f",[[selectedFoodDict valueForKey:@"Folate"] doubleValue]];
    txtfieldServingSize.text = [NSString stringWithFormat:@"%.2f",[[selectedFoodDict valueForKey:@"ServingSize"] doubleValue]];
    txtfieldTransFat.text = [NSString stringWithFormat:@"%.2f",[[selectedFoodDict valueForKey:@"Transfat"] doubleValue]];
    txtfieldVitE.text = [NSString stringWithFormat:@"%.2f",[[selectedFoodDict valueForKey:@"E"] doubleValue]];
    txtfieldVitD.text = [NSString stringWithFormat:@"%.2f",[[selectedFoodDict valueForKey:@"D"] doubleValue]];
    
    if ([selectedFoodDict valueForKey:@"Category_Description"] == nil) {
        [selectCategoryButton setTitle:@"Select Category" forState: UIControlStateNormal];
        [selectCategoryButton setTitle:@"Select Category" forState: UIControlStateHighlighted];
        [selectCategoryButton setTitle:@"Select Category" forState: UIControlStateSelected];
    }
    else {
        [selectCategoryButton setTitle: [selectedFoodDict valueForKey:@"Category_Description"] forState: UIControlStateNormal];
        [selectCategoryButton setTitle: [selectedFoodDict valueForKey:@"Category_Description"] forState: UIControlStateHighlighted];
        [selectCategoryButton setTitle: [selectedFoodDict valueForKey:@"Category_Description"] forState: UIControlStateSelected];
    }
    [selectMeasureButton setTitle: [selectedFoodDict valueForKey:@"Measure_Description"] forState: UIControlStateNormal];
    [selectMeasureButton setTitle: [selectedFoodDict valueForKey:@"Measure_Description"] forState: UIControlStateHighlighted];
    [selectMeasureButton setTitle: [selectedFoodDict valueForKey:@"Measure_Description"] forState: UIControlStateSelected];
    
    if ([selectedFoodDict valueForKey:@"CategoryID"] == nil) {
        intCategoryID = [NSNumber numberWithInt:0];
    }
    else {
        intCategoryID = [selectedFoodDict valueForKey:@"CategoryID"];
    }
    intMeasureID = [selectedFoodDict valueForKey:@"MeasureID"];
    scanned_UPCA = nil;
    scanned_UPCA = [[NSString alloc] initWithString:@"empty"];
    scanned_factualID = nil;
    scanned_factualID = [[NSString alloc] initWithString:@"empty"];
    
    dietmasterEngine.selectedMeasureID = intMeasureID;
    dietmasterEngine.selectedCategoryID = intCategoryID;
    
    [self hideLoading];
}

-(void) recordFood:(id) sender {
    for (int i=1; i<= NUMBER_OF_TEXTFIELDS; i++)
    {
        UITextField *textField = (UITextField*)[self.view viewWithTag:i];
        
        if ([textField isFirstResponder]) {
            [textField resignFirstResponder];
        }
    }
    
    if (([txtfieldFoodName.text length] > 0 || [txtfieldCalories.text length] > 0 || [txtfieldCarbs.text length] > 0 || [txtfieldProtein.text length] > 0 || [txtfieldTotalFat.text length] > 0 || [intMeasureID intValue] > 0) && [intCategoryID intValue] == 0) {
        
        UIAlertView *alert;
        alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Category is Required.\nPlease try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert setTag:88];
        [alert show];
        [alert release];
        return;
    }
    
    if ([txtfieldFoodName.text length] == 0 || [txtfieldCalories.text length] == 0 || [txtfieldCarbs.text length] == 0 || [txtfieldProtein.text length] == 0 || [txtfieldTotalFat.text length] == 0 || [intMeasureID intValue] == 0 || [intCategoryID intValue] == 0) {
        
        UIAlertView *alert;
        alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Food Name, Measure, Category, Calories, Fat, Carbs & Protein are Required.\nPlease try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert setTag:88];
        [alert show];
        [alert release];
        return;
    }
    else {
        DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
        
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
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        int userID = [[prefs valueForKey:@"userid_dietmastergo"] intValue];
        int companyID = [[prefs valueForKey:@"companyid_dietmastergo"] intValue];
        
        
        NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO Food"
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
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
        
        NSString *insertFMSQL = [NSString stringWithFormat: @"INSERT INTO FoodMeasure (FoodID, MeasureID, GramWeight) VALUES (%i, %i, 100)", minFoodID,[intMeasureID intValue]];
        
        [db beginTransaction];
        
        [db executeUpdate:insertFMSQL];
        
        if ([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
        
        [self performSelectorOnMainThread:@selector(showCompleted) withObject:nil waitUntilDone:NO];
        isSaved = YES;
        
        _savedFoodID = minFoodID;
        
        [dietmasterEngine saveFood:minFoodID];
        
        if (_saveToLog) {
            [self performSelectorOnMainThread:@selector(showLoading) withObject:nil waitUntilDone:NO];
        }
        else {
            [self clearEnteredData];
        }
        
        ScannedFoodis = NO;
    }
}

-(void)updateFood:(id)sender {
    
    for (int i=1; i<= NUMBER_OF_TEXTFIELDS; i++) {
        UITextField *textField = (UITextField*)[self.view viewWithTag:i];
        
        if ([textField isFirstResponder]) {
            [textField resignFirstResponder];
        }
    }
    
    if (([txtfieldFoodName.text length] > 0 || [txtfieldCalories.text length] > 0 || [txtfieldCarbs.text length] > 0 || [txtfieldProtein.text length] > 0 || [txtfieldTotalFat.text length] > 0 || [intMeasureID intValue] > 0) && [intCategoryID intValue] == 0) {
        
        UIAlertView *alert;
        alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Category is Required.\nPlease try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert setTag:88];
        [alert show];
        [alert release];
        return;
    }
    
    if ([txtfieldFoodName.text length] == 0 || [txtfieldCalories.text length] == 0 || [txtfieldCarbs.text length] == 0 || [txtfieldProtein.text length] == 0 || [txtfieldTotalFat.text length] == 0 || [intMeasureID intValue] == 0 || [intCategoryID intValue] == 0) {
        
        UIAlertView *alert;
        alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Food Name, Measure, Category, Calories, Fat, Carbs & Protein are Required.\nPlease try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert setTag:88];
        [alert show];
        [alert release];
        return;
    }
    else {
        DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
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
        
        minFoodID = [[selectedFoodDict valueForKey:@"FoodKey"] intValue];
        
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
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
        
        NSString *updateFMSQL = [NSString stringWithFormat: @"UPDATE FoodMeasure SET "
                                 "MeasureID = %i, "
                                 "GramWeight = %i "
                                 "WHERE FoodID = %i ",
                                 [intMeasureID intValue], 100, minFoodID];
        
        [db beginTransaction];
        
        [db executeUpdate:updateFMSQL];
        
        if ([db hadError]) {
            NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];
        
        [self performSelectorOnMainThread:@selector(showCompleted) withObject:nil waitUntilDone:NO];
        isSaved = YES;
        
        _savedFoodID = minFoodID;
        
        [dietmasterEngine saveFood:minFoodID];
        
        if (_saveToLog) {
            [self performSelectorOnMainThread:@selector(showLoading) withObject:nil waitUntilDone:NO];
        }
        else {
            [self performSelector:@selector(loadData) withObject:nil afterDelay:0.15];
        }
    }
}

#pragma mark ALERT VIEW DELEGATE
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 90099) {
        if (buttonIndex == 0) {
            scanned_UPCA = nil;
            scanned_UPCA = [[NSString alloc] initWithString:@"empty"];
            scanned_factualID = nil;
            scanned_factualID = [[NSString alloc] initWithString:@"empty"];
            isSaved = YES;
        }
        else if (buttonIndex == 1) {
            
        }
    }
    
    if (alertView.tag == 770088) {
        if (buttonIndex == 0) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if (buttonIndex == 1) {
            
        }
    }
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods
-(void)showLoading {
    HUD = [[MBProgressHUD showHUDAddedTo:self.view animated:YES] retain];
}

-(void)hideLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        [HUD hide:YES afterDelay:0.5];
    });
}

-(void)hudWasHidden:(MBProgressHUD *)hud {
    [HUD removeFromSuperview];
    [HUD release];
    HUD = nil;
}

-(void)showCompleted {
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.delegate = nil;
    HUD.labelText = @"Completed";
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [HUD show:YES];
        [HUD hide:YES afterDelay:2.25];
    });
}

#pragma mark BARCODE SCANNER METHODS
-(void) readerControllerDidFailToRead: (ZBarReaderController*) reader withRetry: (BOOL) retry {
    [reader dismissViewControllerAnimated:YES completion:nil];
}

-(void) imagePickerController: (UIImagePickerController*) reader didFinishPickingMediaWithInfo: (NSDictionary*) info {
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        break;
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [reader dismissViewControllerAnimated:YES completion:nil];
    
    //HHT to solve the issue after scan it will redirect to 0 index. we set this to 2. new (AppDel.selectedIndex)
    [self.tabBarController setSelectedIndex:AppDel.selectedIndex];
    
    upcDict = [[NSDictionary alloc] initWithObjectsAndKeys: [NSString stringWithFormat:@"%@",symbol.data], @"UPC", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BarcodeScanned" object:nil userInfo:upcDict];
    [upcDict release];
}

-(IBAction)loadBarcodeScanner:(id)sender {
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    ZBarImageScanner *scanner = reader.scanner;
    [scanner setSymbology: nil config: ZBAR_CFG_ENABLE to: 0];
    [scanner setSymbology: ZBAR_EAN13 config: ZBAR_CFG_ENABLE to:1];
    [scanner setSymbology: ZBAR_UPCA config: ZBAR_CFG_ENABLE to:1];
    [scanner setSymbology: ZBAR_CODE128 config: ZBAR_CFG_ENABLE to:1];
    
    [AppDel.window.rootViewController presentViewController:reader animated:YES completion:Nil];
}

-(void)barcodeWasScanned:(NSNotification *)notification {
    barcodeScannerVC = nil;
    NSDictionary *upcDict2 = [notification userInfo];
    
    [self performSelectorOnMainThread:@selector(showLoading) withObject:nil waitUntilDone:NO];
    
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^ {
    //        scanned_UPCA = nil;
    //        scanned_UPCA = [[NSString alloc] initWithString:[upcDict2 valueForKey:@"UPC"]];
    //        scanned_factualID = nil;
    //        scanned_factualID = [[NSString alloc] initWithString:@"empty"];
    //
    //        DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    //        [dietmasterEngine searchFactualDatabase:[upcDict2 valueForKey:@"UPC"]];
    //    });
    
    //URL
    //[upcDict2 valueForKey:@"UPC"]
    NSString *strURL = [NSString stringWithFormat:@"https://trackapi.nutritionix.com/v2/search/item?upc=%@",[upcDict2 valueForKey:@"UPC"]];
    NSLog(@"%@",strURL);
    
    [self getApiCall:nil urlStr:strURL response:nil];
}

//HHT change 2018 Barcode scan
-(void)getApiCall:(NSMutableDictionary *)dic urlStr:(NSString *)urlStr response:(NSMutableArray *)response{
    NSURL * serviceUrl = [NSURL URLWithString:urlStr];
    NSLog(@"REquest URL >> %@",serviceUrl);
    
    //Header
    NSMutableURLRequest * serviceRequest = [NSMutableURLRequest requestWithURL:serviceUrl];
    [serviceRequest setValue:@"7a144547" forHTTPHeaderField:@"x-app-id"];
    [serviceRequest setValue:@"c02e7975164bf7207601b2712ec56137" forHTTPHeaderField:@"x-app-key"];
    
    [serviceRequest setHTTPMethod:@"GET"];
    
    NSURLResponse *serviceResponse;
    NSError *serviceError;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:serviceRequest returningResponse:&serviceResponse error:&serviceError];
    
    if (responseData) {
        [self parsePostApiData:responseData responseP:response];
    }
    else{
        
    }
}

//HHT change 2018 Barcode scan
-(void)parsePostApiData:(NSData *)response responseP:(NSMutableArray *)responseP{
    
    [self performSelectorOnMainThread:@selector(hideLoading) withObject:nil waitUntilDone:NO];
    
    id jsonObject = Nil;
    NSString *charlieSendString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSLog(@"ResponseString %@",charlieSendString);
    if (response==nil) {
        NSLog(@"No internet connection.");
    }
    else{
        NSError *error = Nil;
        jsonObject =[NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        
        if ([jsonObject isKindOfClass:[NSArray class]]) {
            NSLog(@"Probably An Array");
        }
        else
        {
            NSLog(@"Probably A Dictionary");
            
            NSDictionary *jsonDictionary=(NSDictionary *)jsonObject;
            
            NSLog(@"jsonDictionary %@",[jsonDictionary description]);
            
            //Error handling
            if ([[jsonDictionary valueForKey:@"message"] isEqualToString:@"resource not found"]) {
                UIAlertView *alert;
                NSString *errorMessageString = @"Nutritional information for the UPC scanned was not found. Would you like to add it?";
                alert = [[UIAlertView alloc] initWithTitle:@"Not Found" message:errorMessageString delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
                [alert addButtonWithTitle:@"No"];
                [alert addButtonWithTitle:@"Yes"];
                [alert setTag:90099];
                [alert show];
                [alert release];
            }
            else {
                [responseP addObject:jsonDictionary];
                NSMutableArray *arr = [jsonDictionary valueForKey:@"foods"];
                
                if (arr.count > 0){
                    NSLog(@"%@",[arr objectAtIndex:0]);
                    [self nutritionixAPISuccess:[arr objectAtIndex:0]];
                }
            }
        }
    }
}

#pragma mark - Nutritionix -
//HHT change 2018 barcode scan
-(void)nutritionixAPISuccess:(NSMutableDictionary *)dict {
    NSLog(@"%@",dict);
    
    scannerDict = nil;
    scannerDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
    
    //save found dict start
    NSDictionary *scannerDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 dict, @"scannerDict",
                                 @"SAVE", @"action",
                                 nil];
    SaveUPCDataWebService *webservice = [[SaveUPCDataWebService alloc] init];
    webservice.delegate = self;
//    [webservice callWebservice:scannerDict];
    [webservice release];
    [dict release];
    
    //save found dict end
    
    scanned_factualID = nil;
    scanned_factualID = [[NSString alloc] initWithString:[dict valueForKey:@"nix_item_id"]];
    
    //OLD
    
    //    NSString *servingSizeFull = [dict valueForKey:@"serving_size"];
    //    NSArray *servingSizeArray = [servingSizeFull componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //    NSString *servingMeasure = nil;
    //
    //    if ([servingSizeArray count] > 0) {
    //        NSString *serving_size = [servingSizeArray objectAtIndex:0];
    //        if (serving_size != nil && ![serving_size isEqualToString:@""]) {
    //            txtfieldServingSize.text = [NSString stringWithFormat:@"%.2f",[serving_size doubleValue]];
    //        }
    //        else {
    //            txtfieldServingSize.text = [NSString stringWithFormat:@"%i",1];
    //        }
    //        if ([servingSizeArray count] > 1) {
    //            servingMeasure = [servingSizeArray objectAtIndex:1];
    //        }
    //    }
    //    else {
    //        txtfieldServingSize.text = [NSString stringWithFormat:@"%i",1];
    //    }
    
    //NEW
    //NSString *servingMeasure = nil;
    
    NSString *serving_size = [dict valueForKey:@"serving_qty"];
    txtfieldServingSize.text = [NSString stringWithFormat:@"%.2f",[serving_size doubleValue]];
    
    //NSDictionary *dictTemp = [self findMeasureId:@"slice"];
    NSDictionary *dictTemp = [self findMeasureId:[dict valueForKey:@"serving_unit"]];
    
    NSLog(@"dictTemp for Query:: %@",dictTemp);
    
    if ([dictTemp count] == 0) {
        intMeasureID = [NSNumber numberWithInt:3];
        self.strMeasureName = @"each";
        [selectMeasureButton setTitle: self.strMeasureName forState: UIControlStateNormal];
        [selectMeasureButton setTitle: self.strMeasureName forState: UIControlStateHighlighted];
        [selectMeasureButton setTitle: self.strMeasureName forState: UIControlStateSelected];
        DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
        dietmasterEngine.selectedMeasureID = intMeasureID;
    }
    else {
        NSLog(@"dictTemp after reault :: %@",dictTemp);
        NSString *measureValue = [dictTemp valueForKey:@"MeasureID"];
        intMeasureID = [NSNumber numberWithInt:[measureValue intValue]];
        self.strMeasureName = [dictTemp valueForKey:@"Description"];
        
        [selectMeasureButton setTitle: self.strMeasureName forState: UIControlStateNormal];
        [selectMeasureButton setTitle: self.strMeasureName forState: UIControlStateHighlighted];
        [selectMeasureButton setTitle: self.strMeasureName forState: UIControlStateSelected];
        
        DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
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
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Nutritional information found! Please confirm values then select Category." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert setTag:123456];
    [alert show];
    [alert release];
    
    ScannedFoodis=YES;
    
}

-(NSDictionary *)findMeasureId:(NSString *)serving_unit {
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
        
    }
    
    // First Query
    
    NSString *query = [NSString stringWithFormat:@"SELECT MeasureID,Description FROM Measure WHERE Description = '%@'", serving_unit];
    
    // Query Database
    FMResultSet *rs = [db executeQuery:query];
    
    NSDictionary *dict = [[NSDictionary alloc] init];
    
    while ([rs next]) {
        dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                [rs stringForColumn:@"Description"], @"Description",
                [NSNumber numberWithInt:[rs intForColumn:@"MeasureID"]],@"MeasureID",
                nil];
    }
    
    return dict;
}

#pragma mark SAVE UPC DATA DELEGATES
-(void)saveUPCDataWSFinished:(NSMutableDictionary *)responseDict {
    
}

-(void)saveUPCDataWSFailed:(NSString *)failedMessage {
    NSLog(@"saveUPCDataWSFailed");
}

#pragma mark ACTIONSHEET METHODS
-(IBAction)showActionSheet:(id)sender {
    [self.view endEditing:YES];
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:5566];
    if (imageView != nil) {
        [UIView animateWithDuration: 0.25f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations: ^{
            imageView.alpha = 0.0;
        } completion: ^ (BOOL finished) {
            [imageView removeFromSuperview];
            helperBubbleWasShown = YES;
        }];
    }
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    
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
    UIActionSheet *popupQuery;
    if([dietmasterEngine.taskMode isEqualToString:@"View"]) {
        popupQuery = [[UIActionSheet alloc] initWithTitle:alertTitle delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:actionButtonName, saveToLogName, nil];
    }
    else {
        popupQuery = [[UIActionSheet alloc] initWithTitle:alertTitle delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Scan UPC Barcode", actionButtonName, saveToLogName, nil];
        NSString *ver = [[UIDevice currentDevice]systemVersion];
        if ([ver integerValue] >= 8) {
        }
        else {
            UIImage *barCodeImage = [UIImage imageNamed:@"195-barcode.png"];
            [[[popupQuery valueForKey:@"_buttons"] objectAtIndex:0] setImage:barCodeImage forState:UIControlStateNormal];
            [[[popupQuery valueForKey:@"_buttons"] objectAtIndex:0] setImage:barCodeImage forState:UIControlStateHighlighted];
            [[[popupQuery valueForKey:@"_buttons"] objectAtIndex:0] setImage:barCodeImage forState:UIControlStateSelected];
        }
    }
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:self.tabBarController.view];
    [popupQuery release];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    if([dietmasterEngine.taskMode isEqualToString:@"View"]) {
        //HHT
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            return;
        }
        
        if (buttonIndex == 0) {
            if ([txtfieldServingSize.text doubleValue]<=0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_NAME message:@"Serving Size must be a number greater than 0." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
                [alert show];
                return;
            }
            _saveToLog = NO;
            [self performSelector:@selector(updateFood:) withObject:nil afterDelay:0.5];
        }
        else if (buttonIndex == 1) {
            _saveToLog = YES;
            [self performSelector:@selector(updateFood:) withObject:nil afterDelay:0.5];
        }
        else if (buttonIndex == 2) {
            
        }
    }
    else {
        //HHT
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            return;
        }
        
        if (buttonIndex == 0) {
            [self performSelector:@selector(loadBarcodeScanner:) withObject:nil afterDelay:0.5];
        }
        else if (buttonIndex == 1) {
            // do something
            if ([txtfieldServingSize.text doubleValue]<=0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_NAME message:@"Serving Size must be a number greater than 0." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
                [alert show];
                return;
            }
            
            _saveToLog = NO;
            [self performSelector:@selector(recordFood:) withObject:nil afterDelay:0.5];
        }
        else if (buttonIndex == 2) {
            //HHT (uncomment this code)
            //save and add to log
            _saveToLog = YES;
            [self performSelector:@selector(recordFood:) withObject:nil afterDelay:0.5];
        }
        else if (buttonIndex == 3) {
            // cancel
        }
    }
}

#pragma mark - FACTUAL API METHOD DELEGATES -
//-(void)factualAPISuccess:(NSNotification *)notification {
//    [self performSelectorOnMainThread:@selector(hideLoading) withObject:nil waitUntilDone:NO];
//
//    FactualQueryResult *queryResult = [[notification userInfo] valueForKey:@"FactualQueryResult"];
//    int rowCount = [[[notification userInfo] valueForKey:@"ResultCount"] intValue];
//
//    if (rowCount <= 0) {
//        scanned_factualID = nil;
//        scanned_factualID = [[NSString alloc] initWithString:@"empty"];
//
//        UIAlertView *alert;
//        NSString *errorMessageString = @"Nutritional information for the UPC scanned was not found. Would you like to add it?";
//        alert = [[UIAlertView alloc] initWithTitle:@"Not Found" message:errorMessageString delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
//        [alert addButtonWithTitle:@"No"];
//        [alert addButtonWithTitle:@"Yes"];
//        [alert setTag:90099];
//        [alert show];
//        [alert release];
//    }
//
//    if (rowCount > 0) {
//        isSaved = NO;
//
//        FactualRow* row = [queryResult.rows objectAtIndex:0];
//        scannerDict = nil;
//        scannerDict = [[NSMutableDictionary alloc] initWithDictionary:row.namesAndValues];
//
//        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
//                              scannerDict, @"scannerDict",
//                              @"SAVE", @"action",
//                              nil];
//        SaveUPCDataWebService *webservice = [[SaveUPCDataWebService alloc] init];
//        webservice.delegate = self;
//        [webservice callWebservice:dict];
//        [webservice release];
//        [dict release];
//
//        //HHT change 2018 barcode scan
//        scanned_factualID = nil;
//        scanned_factualID = [[NSString alloc] initWithString:[row valueForName:@"nix_item_id"]];
//
//        NSString *servingSizeFull = [row valueForName:@"serving_size"];
//        NSArray *servingSizeArray = [servingSizeFull componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//        NSString *servingMeasure = nil;
//
//        if ([servingSizeArray count] > 0) {
//            NSString *serving_size = [servingSizeArray objectAtIndex:0];
//            if (serving_size != nil && ![serving_size isEqualToString:@""]) {
//                txtfieldServingSize.text = [NSString stringWithFormat:@"%.2f",[serving_size doubleValue]];
//            }
//            else {
//                txtfieldServingSize.text = [NSString stringWithFormat:@"%i",1];
//            }
//            if ([servingSizeArray count] > 1) {
//                servingMeasure = [servingSizeArray objectAtIndex:1];
//            }
//        }
//        else {
//            txtfieldServingSize.text = [NSString stringWithFormat:@"%i",1];
//        }
//
//        if (servingMeasure != nil) {
//            if ([servingMeasure isEqualToString:@"oz"]) {
//
//                intMeasureID = [NSNumber numberWithInt:2];
//                self.strMeasureName = @"ounce(s)";
//            }
//            else if ([servingMeasure isEqualToString:@"ea"]) {
//                intMeasureID = [NSNumber numberWithInt:3];
//                self.strMeasureName = @"each";
//            }
//            else if ([servingMeasure isEqualToString:@"tablespoon"]) {
//                intMeasureID = [NSNumber numberWithInt:7];
//                self.strMeasureName = @"tablespoon";
//            }
//            else if ([servingMeasure isEqualToString:@"teaspoon"]) {
//                intMeasureID = [NSNumber numberWithInt:6];
//                self.strMeasureName = @"teaspoon";
//            }
//            else if ([servingMeasure isEqualToString:@"cup"]) {
//                intMeasureID = [NSNumber numberWithInt:4];
//                self.strMeasureName = @"cup";
//            }
//            else if ([servingMeasure isEqualToString:@"g"]) {
//                intMeasureID = [NSNumber numberWithInt:9];
//                self.strMeasureName = @"gram(s)";
//            }
//            else if ([servingMeasure isEqualToString:@"pack"]) {
//                intMeasureID = [NSNumber numberWithInt:21];
//                self.strMeasureName = @"pack";
//            }
//            else if ([servingMeasure isEqualToString:@"packet"]) {
//                intMeasureID = [NSNumber numberWithInt:36];
//                self.strMeasureName = @"packet";
//            }
//            else if ([servingMeasure isEqualToString:@"slice"]) {
//                intMeasureID = [NSNumber numberWithInt:22];
//                self.strMeasureName = @"slice";
//            }
//            else if ([servingMeasure isEqualToString:@"capsule"]) {
//                intMeasureID = [NSNumber numberWithInt:35];
//                self.strMeasureName = @"capsule";
//            }
//            else if ([servingMeasure isEqualToString:@"bag"]) {
//                intMeasureID = [NSNumber numberWithInt:29];
//                self.strMeasureName = @"bag";
//            }
//            else {
//                intMeasureID = [NSNumber numberWithInt:3];
//                self.strMeasureName = @"each";
//            }
//
//            [selectMeasureButton setTitle: self.strMeasureName forState: UIControlStateNormal];
//            [selectMeasureButton setTitle: self.strMeasureName forState: UIControlStateHighlighted];
//            [selectMeasureButton setTitle: self.strMeasureName forState: UIControlStateSelected];
//
//            DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
//            dietmasterEngine.selectedMeasureID = intMeasureID;
//        }
//        else {
//            intMeasureID = [NSNumber numberWithInt:3];
//            self.strMeasureName = @"each";
//            [selectMeasureButton setTitle: self.strMeasureName forState: UIControlStateNormal];
//            [selectMeasureButton setTitle: self.strMeasureName forState: UIControlStateHighlighted];
//            [selectMeasureButton setTitle: self.strMeasureName forState: UIControlStateSelected];
//            DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
//            dietmasterEngine.selectedMeasureID = intMeasureID;
//        }
//
//
//        txtfieldFoodName.text = [NSString stringWithFormat:@"%@ %@",
//                                 [row valueForName:@"brand_name"], [row valueForName:@"food_name"]];
//
//        if ([row valueForName:@"nf_calories"] != [NSNull null]) {
//            txtfieldCalories.text = [NSString stringWithFormat:@"%.2f",[[scannerDict valueForKey:@"nf_calories"] doubleValue]];
//        }
//
//        if ([row valueForName:@"nf_total_fat"] != [NSNull null]) {
//            txtfieldTotalFat.text = [NSString stringWithFormat:@"%.2f",[[row valueForName:@"nf_total_fat"] doubleValue]];
//        }
//
//        if ([row valueForName:@"nf_saturated_fat"] != [NSNull null]) {
//            txtfieldSatFat.text = [NSString stringWithFormat:@"%.2f",[[row valueForName:@"nf_saturated_fat"] doubleValue]];
//        }
//
//        if ([row valueForName:@"nf_sodium"] != [NSNull null]) {
//            txtfieldSodium.text = [NSString stringWithFormat:@"%.2f",[[row valueForName:@"nf_sodium"] doubleValue]];
//        }
//
//        if ([row valueForName:@"nf_total_carbohydrate"] != [NSNull null]) {
//            txtfieldCarbs.text = [NSString stringWithFormat:@"%.2f",[[row valueForName:@"nf_total_carbohydrate"] doubleValue]];
//        }
//
//        if ([row valueForName:@"nf_cholesterol"] != [NSNull null]) {
//            txtfieldCholesterol.text = [NSString stringWithFormat:@"%.2f",[[row valueForName:@"nf_cholesterol"] doubleValue]];
//        }
//
//        if ([row valueForName:@"nf_protein"]  != [NSNull null]) {
//            txtfieldProtein.text = [NSString stringWithFormat:@"%.2f",[[row valueForName:@"nf_protein"] doubleValue]];
//        }
//
//        if ([row valueForName:@"nf_dietary_fiber"] != [NSNull null]) {
//            txtfieldFiber.text = [NSString stringWithFormat:@"%.2f",[[row valueForName:@"nf_dietary_fiber"] doubleValue]];
//        }
//
//        if ([row valueForName:@"nf_sugars"] != [NSNull null]) {
//            txtfieldSugars.text = [NSString stringWithFormat:@"%.2f",[[row valueForName:@"nf_sugars"] doubleValue]];
//        }
//
//        //not found
//        if ([row valueForName:@"trans_fat"] != [NSNull null]) {
//            txtfieldTransFat.text = [NSString stringWithFormat:@"%.2f",[[row valueForName:@"trans_fat"] doubleValue]];
//        }
//
//        if ([row valueForName:@"nf_potassium"] != [NSNull null]) {
//            txtfieldPot.text = [NSString stringWithFormat:@"%.2f",[[row valueForName:@"nf_potassium"] doubleValue]];
//        }
//
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Nutritional information found! Please confirm values then select Category." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//        [alert setTag:123456];
//        [alert show];
//        [alert release];
//
//        ScannedFoodis=YES;
//    }
//}
//
//-(void)factualAPIDidFail:(NSNotification *)notification {
//    NSString *failMessage = [[notification userInfo] valueForKey:@"ErrorDescription"];
//    [self performSelectorOnMainThread:@selector(hideLoading) withObject:nil waitUntilDone:NO];
//
//    scannerDict = nil;
//    scanned_UPCA = nil;
//    scanned_UPCA = [[NSString alloc] initWithString:@"empty"];
//    scanned_factualID = nil;
//    scanned_factualID = [[NSString alloc] initWithString:@"empty"];
//
//    txtfieldFoodName.text = @"";
//
//    NSLog(@"factualAPIDidFail, desc: %@", failMessage);
//
//    UIAlertView *alert;
//    alert = [[UIAlertView alloc] initWithTitle:@"Oh no!" message:@"An error occured while looking up Food data. Please check your internet connection and try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//    [alert setTag:90099];
//    [alert show];
//    [alert release];
//
//    isSaved = YES;
//
//}

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
                         helperBubbleWasShown = YES;
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
                         helperBubbleWasShown = YES;
                     }];
    
}

#pragma mark Save To Log Methods
-(void)foodWasSavedToCloud:(NSNotification *)notification {
    [self performSelectorOnMainThread:@selector(hideLoading) withObject:nil waitUntilDone:NO];
    if (_saveToLog) {
        BOOL success = [[[notification userInfo] valueForKey:@"success"] boolValue];
        NSNumber *foodID = [[notification userInfo] valueForKey:@"FoodID"];
        
        if (success) {
            DietmasterEngine *dietmasterEngine = [DietmasterEngine instance];
            
            if (dietmasterEngine.isMealPlanItem)
            {
                dietmasterEngine.taskMode = @"AddMealPlanItem";
            }
            else
            {
                dietmasterEngine.taskMode = @"Save";
            }
            
            NSDictionary *tempFoodDict = [[NSDictionary alloc] initWithObjectsAndKeys:foodID, @"FoodID", intMeasureID, @"MeasureID", nil];
            NSDictionary *foodDict = [[NSDictionary alloc] initWithDictionary:
                                      [dietmasterEngine getFoodDetails:tempFoodDict]];
            [tempFoodDict release];
            [dietmasterEngine.foodSelectedDict setDictionary:foodDict];
            DetailViewController *dvController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
            dvController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:dvController animated:YES];
            [dvController release];
            [foodDict release];
            
            [self clearEnteredData];
        }
        else {
            DietmasterEngine *dietmasterEngine = [DietmasterEngine instance];
            dietmasterEngine.taskMode = @"View";
            
            NSDictionary *tempFoodDict = [[NSDictionary alloc] initWithObjectsAndKeys:@(_savedFoodID), @"FoodID", intMeasureID, @"MeasureID", nil];
            NSDictionary *foodDict = [[NSDictionary alloc] initWithDictionary:
                                      [dietmasterEngine getFoodDetails:tempFoodDict]];
            [tempFoodDict release];
            [dietmasterEngine.foodSelectedDict setDictionary:foodDict];
            
            UIAlertView *alert;
            alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"There was an error saving to log. Please check your internet connection and try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert setTag:88];
            [alert show];
            [alert release];
            
            [self performSelector:@selector(loadData) withObject:nil afterDelay:0.15];
        }
    }
}

@end

