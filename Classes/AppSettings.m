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

@end

@implementation AppSettings

- (instancetype)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
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
#pragma mark - User Actions

- (IBAction)forceUPDBSync:(id)sender {
    [DMActivityIndicator showActivityIndicator];
    [DMMyLogDataProvider uploadDatabaseWithCompletionBlock:^(BOOL completed, NSError *error) {
        [DMActivityIndicator hideActivityIndicator];
    }];
}

#pragma mark - Switch Actions

- (IBAction)useCalorieTrackingDeviceSwitched:(UISwitch *)sender {
    DMUser *currentUser = [[DMAuthManager sharedInstance] loggedInUser];
    currentUser.useCalorieTrackingDevice = sender.isOn;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:nil];
}

- (IBAction)useExerciseCaloriesSwitched:(UISwitch *)sender {
    DMUser *currentUser = [[DMAuthManager sharedInstance] loggedInUser];
    currentUser.useBurnedCalories = sender.isOn;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:nil];
}

- (IBAction)enableAppleHealthSyncSwitched:(UISwitch *)sender {
    DMUser *currentUser = [[DMAuthManager sharedInstance] loggedInUser];
    currentUser.enableAppleHealthSync = sender.isOn;
    if (currentUser.enableAppleHealthSync) {
        [self checkAppleHealth];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:nil];
}

#pragma mark - Apple Health

- (void)checkAppleHealth {
    StepData *stepData = [[StepData alloc] init];
    __weak typeof(self) weakSelf = self;
    [stepData checkHealthKitAuthorizationWithCompletionBlock:^(BOOL authorized, NSError *error) {
        if (error) {
            DMUser *currentUser = [[DMAuthManager sharedInstance] loggedInUser];
            currentUser.enableAppleHealthSync = NO;
            [weakSelf.appleHealthSwitch setOn:NO];
            [DMGUtilities showAlertWithTitle:@"Error" message:error.localizedDescription inViewController:nil];
            return;
        }
        
        DMUser *currentUser = [[DMAuthManager sharedInstance] loggedInUser];
        currentUser.enableAppleHealthSync = authorized;
        [weakSelf.appleHealthSwitch setOn:authorized];
    }];
}

@end
