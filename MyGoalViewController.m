//
//  MyGoalViewController.m
//  DietMasterGo
//
//  Created by Andrew Moffitt on 11/23/10.
//  Copyright 2010 AE Studios. All rights reserved.
//
@import SafariServices;
#import "MyGoalViewController.h"
#import "DetailViewController.h"
#import "RecordWeightView.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "MyMovesViewController.h"

@interface MyGoalViewController() <SFSafariViewControllerDelegate>
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation MyGoalViewController

@synthesize	segmentedControl;
@synthesize scatterPlot = _scatterPlot;

#pragma mark VIEW LIFECYCLE

- (instancetype)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"My Goal";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [btn1 addTarget:self action:@selector(goToSafetyGuidelines:) forControlEvents:UIControlEventTouchDown];
    btn1.tintColor = UIColor.whiteColor;
    
    UIBarButtonItem * infoButton = [[UIBarButtonItem alloc] initWithCustomView:btn1];
    self.navigationItem.leftBarButtonItem = infoButton;

    _imgbg.backgroundColor=[UIColor whiteColor];
    
    noDataLabel.textColor = PrimaryDarkColor;
    segmentedControl.backgroundColor = PrimaryFontColor;
    _goalWeightLbl.textColor = PrimaryFontColor;
    _WeightLbl.textColor = PrimaryFontColor;
    
    _imgtop.backgroundColor = PrimaryColor
    self.btnrecordyourweight.backgroundColor = PrimaryDarkColor;
    _btnrecordyourweight.layer.cornerRadius = 5;
    
    segmentedControl.backgroundColor = PrimaryDarkColor
    segmentedControl.tintColor = AccentColor
    
    UIColor *tintColor = [segmentedControl tintColor];
    UIImage *tintColorImage = [DMGUtilities imageWithColor:tintColor];
    // Must set the background image for normal to something (even clear) else the rest won't work
    [segmentedControl setBackgroundImage:[DMGUtilities imageWithColor:segmentedControl.backgroundColor ? segmentedControl.backgroundColor : [UIColor clearColor]] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [segmentedControl setBackgroundImage:tintColorImage forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [segmentedControl setBackgroundImage:[DMGUtilities imageWithColor:[tintColor colorWithAlphaComponent:0.2]] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [segmentedControl setBackgroundImage:tintColorImage forState:UIControlStateSelected|UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName: tintColor, NSFontAttributeName: [UIFont systemFontOfSize:13]} forState:UIControlStateNormal];
    [segmentedControl setDividerImage:tintColorImage forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    segmentedControl.layer.borderWidth = 1;
    segmentedControl.layer.borderColor = [tintColor CGColor];
    
    self.scatterPlot = nil;
    self.scatterPlot = [[TUTSimpleScatterPlot alloc] initWithHostingView:_graphHostingView];
    [self getDataForDays:30];
    
    NSString *accountCode = [DMGUtilities configValueForKey:@"account_code"];
    UIImageView *backgroundImage = (UIImageView *)[self.view viewWithTag:501];
    if ([accountCode isEqualToString:@"ezdietplanner"]) {
        backgroundImage.image = [UIImage imageNamed:@"Weight_Chart"];
    }
    if ([accountCode isEqualToString:@"gymmatrix"]) {
        for (id view in self.view.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)view;
                label.textColor = [UIColor whiteColor];
                label.shadowColor = [UIColor darkGrayColor];
            }
        }
    }
    
    _goalWeightLbl.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"GoalWeight"];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                break;
                
            case 1334:
                printf("iPhone 6/6S/7/8");
                break;
                
            case 1920:
                printf("iPhone 6+/6S+/7+/8+");
                break;
                
            case 2436:
                printf("iPhone X, XS");
                segmentedControl.frame = CGRectMake(60, 150, 240, 30);
                noDataLabel.frame = CGRectMake(0, 250, SCREEN_WIDTH, 30);
                _graphHostingView.frame = CGRectMake(0, 180, SCREEN_WIDTH, SCREEN_HEIGHT - 250);
                break;
                
            case 2688:
                printf("iPhone XS Max");
                segmentedControl.frame = CGRectMake(80, 150, 240, 30);
                noDataLabel.frame = CGRectMake(0, 250, SCREEN_WIDTH, 30);
                _graphHostingView.frame = CGRectMake(0, 180, SCREEN_WIDTH, SCREEN_HEIGHT - 250);
                
                break;
                
            case 1792:
                printf("iPhone XR");
                segmentedControl.frame = CGRectMake(80, 150, 240, 30);
                noDataLabel.frame = CGRectMake(0, 250, SCREEN_WIDTH, 30);
                _graphHostingView.frame = CGRectMake(0, 180, SCREEN_WIDTH, SCREEN_HEIGHT - 250);
                
                break;
                
            default:
                printf("Unknown");
                break;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController) {
        [[self navigationController] setNavigationBarHidden:YES animated:YES];
        self.scatterPlot = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    DMUser *currentUser = [[DMAuthManager sharedInstance] loggedInUser];
    UIFont * font = [UIFont fontWithName:@"Helvetica-Bold" size:22];
    lbl_weightGoal.font = font;
    if (currentUser.weightGoalType <= DMUserWeightGoalTypeGain) {
        lbl_weightGoal.text = [currentUser weightGoalTypeAsString];
    } else {
        lbl_weightGoal.text = [currentUser weightGoalLocalizedString];
    }
    
    if (self.scatterPlot) {
        [self changeGraphTime:nil];
    }
    
}

#pragma mark BUTTON ACTIONS

-(IBAction)changeGraphTime:(id) sender {
    _graphHostingView.hidden = YES;
    
    int selectedIndex = segmentedControl.selectedSegmentIndex;
    
    UIFont *Boldfont = [UIFont systemFontOfSize:13.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:Boldfont,UITextAttributeFont,[UIColor whiteColor],UITextAttributeTextColor,nil];
    [segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [segmentedControl setTitleTextAttributes:attributes forState:UIControlStateSelected];
    self.segmentedControl.layer.borderWidth = 0.0;
    segmentedControl.layer.cornerRadius = 8.0;
    
    if (selectedIndex == 0) {
        [self getDataForDays:30];
    }
    else if (selectedIndex == 1) {
        [self getDataForDays:60];
    }
    else if (selectedIndex == 2) {
        [self getDataForDays:90];
    }

    [self.scatterPlot reloadGraphView];
    [self.scatterPlot.graph reloadData];
    _graphHostingView.hidden = NO;
}

-(IBAction)showRecordWeightView:(id) sender {
    RecordWeightView *dvController = [[RecordWeightView alloc] initWithNibName:@"RecordWeightView" bundle:nil];
    [self.navigationController pushViewController:dvController animated:YES];
    dvController = nil;
}

-(void)getDataForDays:(int)days {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
       
    }

    NSDate* sourceDate = [NSDate date];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
    [self.dateFormatter setTimeZone:systemTimeZone];
    NSString *date_string = [self.dateFormatter stringFromDate:sourceDate];
    NSDate *currDate = [self.dateFormatter dateFromString:date_string];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:-days];
    
    NSDate *startDate = [calendar dateByAddingComponents:components toDate:currDate options:0];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setTimeZone:systemTimeZone];
    [dateFormatter setLenient:YES];
    
    NSString *startDateString = [dateFormatter stringFromDate:startDate];
    NSString *endDateString = [dateFormatter stringFromDate:currDate];

    NSString *countQuery = [NSString stringWithFormat:@"SELECT count(*) as row_count FROM weightlog WHERE deleted = 1 AND (logtime BETWEEN DATETIME('%@') AND DATETIME('%@')) AND logtime LIMIT %i",startDateString, endDateString, days];
    
    NSString *dbQuery = [NSString stringWithFormat:@"SELECT * FROM weightlog WHERE deleted = 1 AND (logtime BETWEEN DATETIME('%@') AND DATETIME('%@')) AND logtime ORDER by logtime DESC LIMIT %i", startDateString, endDateString, days];
    
    NSMutableArray *data = [NSMutableArray array];
    
    int numberOfDays=days;
    
    int maxCountStep = 0;
    if (days == 30) {
        maxCountStep = 5;
    }
    else if (days == 60) {
        maxCountStep = 8;
    }
    else if (days == 90) {
        maxCountStep = 10;
    }
    
    NSDate *tempDate = [startDate copy];
    for (int i=0; i < numberOfDays; i++) {
        tempDate = [tempDate dateByAddingTimeInterval:(60*60*24)];
        
        [self.dateFormatter setDateFormat:@"MMM dd"];
        [self.dateFormatter setLenient:YES];
        
        NSString *dateString = [self.dateFormatter stringFromDate:tempDate];
        tempDate = [self.dateFormatter dateFromString:dateString];
    }
    
    NSMutableArray *pointsData = [NSMutableArray array];
    
    FMResultSet *rs2 = [db executeQuery:dbQuery];
    FMResultSet *rs3 = [db executeQuery:countQuery];
    
    int counter = 0;
    int maxCounter = 0;
    
    int rowCount = 0;
    if ([rs3 next]) {
        rowCount =  [rs3 intForColumn:@"row_count"];
        
        if (rowCount < 1) {
            noDataLabel.hidden = NO;
        }
        else {
            noDataLabel.hidden = YES;
        }
        
        if (rowCount < 30) {

        }
    }
    
    int reverseCounter = 0;
    for (int j=0; j<days; j++) {
        
        if (maxCounter >= days)
            break;
        
        reverseCounter++;
        maxCounter = maxCounter + maxCountStep;
    }
    
    counter = reverseCounter - 1;
    maxCounter = 0;
    
    if (counter >= rowCount) {
        counter = rowCount - 1;
    }
    
    while ([rs2 next]) {
        if (maxCounter >= days)
            break;
        
        NSMutableDictionary* dates = [[NSMutableDictionary alloc] init];
        NSString *weightLogged  = [rs2 stringForColumn:@"weight"];

        NSString *dateLogged  = [rs2 stringForColumn:@"logtime"];
        
        [self.dateFormatter setLenient:YES];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *dateToConvert = [self.dateFormatter dateFromString:dateLogged];
        [self.dateFormatter setDateFormat:@"MMM dd"];
        NSString *dateString = [self.dateFormatter stringFromDate:dateToConvert];
    
        [dates setValue:[NSValue valueWithCGPoint:CGPointMake(counter, [weightLogged intValue])] forKey:@"point"];
        [dates setValue:dateString forKey:@"date"];
        
        [pointsData addObject:[NSValue valueWithCGPoint:CGPointMake(counter, [weightLogged intValue])]];
        [data addObject:dates];
        
        counter--;
        maxCounter = maxCounter + maxCountStep;
    }
    [rs2 close];
    
    NSMutableArray *reversedPointsDataArray = [[[pointsData reverseObjectEnumerator] allObjects] mutableCopy];
    NSMutableArray *reversedDataArray = [[[data reverseObjectEnumerator] allObjects] mutableCopy];

    [self.scatterPlot setGraphData:reversedPointsDataArray];
    [self.scatterPlot setGraphDataValues:reversedDataArray];
    [self.scatterPlot initialisePlot];
}

- (void)dismissRecordWeight {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(float)getGoalWeightFromDB {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
        DMLog(@"Could not open db.");
    }
    
    float goalWeight = 0;
    FMResultSet *rs = [db executeQuery:@"SELECT weight_goal FROM user"];
    while ([rs next]) {
        goalWeight  = [rs intForColumn:@"weight_goal"];
    }
    [rs close];
    return goalWeight;
}

- (IBAction)goToSafetyGuidelines:(id)sender {
    SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://advancedwebservicegroup.com/AWSGDocuments/GuidelinesAndSafety.html"]];
    [self presentViewController:sfvc animated:YES completion:nil];
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [self dismissViewControllerAnimated:true completion:nil];
}


@end
