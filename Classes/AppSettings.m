#import "AppSettings.h"

#import <HealthKit/HealthKit.h>
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

@property (nonatomic,retain) HKHealthStore *healthStore;

@end

@implementation AppSettings

- (instancetype)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        _healthStore = [[HKHealthStore alloc] init];
    }
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
    
    [self checkForPremission];
}

#pragma mark - User Actions

- (IBAction)forceUPDBSync:(id)sender {
    [DMActivityIndicator showActivityIndicator];
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    [dietmasterEngine uploadDatabaseWithCompletionBlock:^(BOOL completed, NSError *error) {
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
        [self askForPermission];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadData" object:nil];
}

#pragma mark - Apple Health

- (void)checkForPremission {
    DMUser *currentUser = [[DMAuthManager sharedInstance] loggedInUser];
    
    HKAuthorizationStatus permissionStatus = [self.healthStore authorizationStatusForType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]];
    if (permissionStatus == HKAuthorizationStatusSharingAuthorized) {
        currentUser.enableAppleHealthSync = YES;
        [self.appleHealthSwitch setOn:currentUser.enableAppleHealthSync];
    }
    else if (permissionStatus == HKAuthorizationStatusSharingDenied) {
        DMLog(@"** HKHealthStore HKAuthorizationStatusSharingDenied **");
        currentUser.enableAppleHealthSync = NO;
        [self.appleHealthSwitch setOn:currentUser.enableAppleHealthSync];
    }
}

- (void)askForPermission {
    DMUser *currentUser = [[DMAuthManager sharedInstance] loggedInUser];
    
    //check HKHealthStore available or not
    if ([HKHealthStore isHealthDataAvailable] == NO) {
        DMLog(@"** HKHealthStore NotAvailable **");
        currentUser.enableAppleHealthSync = NO;
        [self.appleHealthSwitch setOn:currentUser.enableAppleHealthSync];
        return;
    }
    
    NSArray *shareTypes = @[[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]];
    NSArray *readTypes = @[[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]];
    
    HKAuthorizationStatus permissionStatus = [self.healthStore authorizationStatusForType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]];
    
    if (permissionStatus == HKAuthorizationStatusSharingAuthorized) {
        DMLog(@"HKAuthorizationStatusSharingAuthorized");
        currentUser.enableAppleHealthSync = YES;
    } else {
        [self.healthStore requestAuthorizationToShareTypes:[NSSet setWithArray:shareTypes] readTypes:[NSSet setWithArray:readTypes] completion:^(BOOL success, NSError * _Nullable error) {
            currentUser.enableAppleHealthSync = success;
            if (error) {
                [DMGUtilities showAlertWithTitle:@"Error" message:error.localizedDescription inViewController:nil];
                return;
            }
        }];
    }
}

@end
