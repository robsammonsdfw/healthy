#import "AppSettings.h"

#import "DietmasterEngine.h"

/// Enables user to select options such as enabling Apple Health sync.
@interface AppSettings ()

/// If the user wants to sync with Apple Health or not.
@property (nonatomic, strong) IBOutlet UISwitch *appleHealthSwitch;
/// If the user wants to add tracked calories (e.g. Apple Watch) into
/// their calorie intake budget.
@property (nonatomic, strong) IBOutlet UISwitch *addTrackedCaloriesSwitch;
/// If the user wants to add exercise calories into their calorie intake
/// budget for the day.
@property (nonatomic, strong) IBOutlet UISwitch *addExerciseCaloriesSwitch;

@property (nonatomic, strong) IBOutlet UILabel *trackingTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *exerciseTitleLabel;

@end

@implementation AppSettings

- (instancetype)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Optional Settings";
    self.navigationItem.title = @"Optional Settings";
    
    self.appleHealthSwitch.onTintColor = AppConfiguration.switchOnColor;
    self.addTrackedCaloriesSwitch.onTintColor = AppConfiguration.switchOnColor;
    self.addExerciseCaloriesSwitch.onTintColor = AppConfiguration.switchOnColor;
    
    self.trackingTitleLabel.backgroundColor = AppConfiguration.footerColor;
    self.exerciseTitleLabel.backgroundColor = AppConfiguration.footerColor;
    self.trackingTitleLabel.textColor = AppConfiguration.footerTextColor;
    self.exerciseTitleLabel.textColor = AppConfiguration.footerTextColor;

    pageSize = 1000;
    pageNumberCounter = 1;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    DMUser *currentUser = [[DMAuthManager sharedInstance] loggedInUser];
    [self.addTrackedCaloriesSwitch setOn:currentUser.useCalorieTrackingDevice];
    [self.addExerciseCaloriesSwitch setOn:currentUser.useBurnedCalories];
    [self.appleHealthSwitch setOn:currentUser.enableAppleHealthSync];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self checkAppleHealth];
}

#pragma mark - Switch Actions

- (IBAction)useCalorieTrackingDeviceSwitched:(UISwitch *)sender {
    DMUser *currentUser = [[DMAuthManager sharedInstance] loggedInUser];
    currentUser.useCalorieTrackingDevice = sender.isOn;
    [[NSNotificationCenter defaultCenter] postNotificationName:DMReloadDataNotification object:nil];
}

- (IBAction)useExerciseCaloriesSwitched:(UISwitch *)sender {
    DMUser *currentUser = [[DMAuthManager sharedInstance] loggedInUser];
    currentUser.useBurnedCalories = sender.isOn;
    [[NSNotificationCenter defaultCenter] postNotificationName:DMReloadDataNotification object:nil];
}

- (IBAction)enableAppleHealthSyncSwitched:(UISwitch *)sender {
    DMUser *currentUser = [[DMAuthManager sharedInstance] loggedInUser];
    currentUser.enableAppleHealthSync = sender.isOn;
    if (currentUser.enableAppleHealthSync) {
        [self checkAppleHealth];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:DMReloadDataNotification object:nil];
}

#pragma mark - Apple Health

- (void)checkAppleHealth {
    StepData *stepData = [[StepData alloc] init];
    [stepData checkHealthKitAuthorizationWithCompletionBlock:^(BOOL authorized, NSError *error) {
        if (error) {
            DMUser *currentUser = [[DMAuthManager sharedInstance] loggedInUser];
            currentUser.enableAppleHealthSync = NO;
            [self.appleHealthSwitch setOn:NO];
            [DMGUtilities showAlertWithTitle:@"Error" message:error.localizedDescription inViewController:nil];
            return;
        }
        
        DMUser *currentUser = [[DMAuthManager sharedInstance] loggedInUser];
        currentUser.enableAppleHealthSync = authorized;
        [self.appleHealthSwitch setOn:authorized];
    }];
}

@end
