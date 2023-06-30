//
//  DMUser.m
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/15/23.
//

#import "DMUser.h"

/**
 Example output:
 {
     CompanyID = 3271;
     CompanyName = "DietMaster Pro Software";
     DateFormat = 0;
     Email = "henrytkirk@gmail.com";
     Email1 = "js@dietmastersoftware.com";
     Email2 = "";
     EnergyUnit = 0;
     ExpirationDate = "";
     FirstName = Henry;
     GeneralUnits = 0;
     HostName = "dietmastersoftware.dmwebpro.com";
     LastName = Kirk;
     Message = "Login Successful!";
     MobileGraphic = "";
     PassThruKey = "p54118!";
     Password = captkirk;
     Reserved = False;
     Status = True;
     SubscriptionEndDate = "1/20/2099 12:00:00 AM";
     Token = DIWR26Q5;
     UniqueURL = "";
     UserID = 532749;
     Username = henryt;
 }
 */
@interface DMUser()
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;
@property (nonatomic, strong) NSMassFormatter *massFormatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong, readwrite) NSNumber *userId;
@property (nonatomic, strong, readwrite) NSString *userName;
@property (nonatomic, strong, readwrite) NSString *authToken;
@property (nonatomic, strong, readwrite) NSString *email1;
@property (nonatomic, strong, readwrite) NSString *email2;

@property (nonatomic, strong, readwrite) NSNumber *companyId;
@property (nonatomic, strong, readwrite) NSString *companyName;
@property (nonatomic, strong, readwrite) NSString *mobileGraphicImageName;

@property (nonatomic, strong, readwrite) NSString *firstName;
@property (nonatomic, strong, readwrite) NSString *lastName;

@property (nonatomic, strong, readwrite, nullable) NSDate *birthDate;
@property (nonatomic, strong, readwrite) NSNumber *gender;
@property (nonatomic, strong, readwrite) NSNumber *height;
@property (nonatomic, strong, readwrite) NSNumber *lactating;

@property (nonatomic, strong, readwrite) NSNumber *profession;

@property (nonatomic, strong, readwrite) NSNumber *bodyType;
@property (nonatomic, strong, readwrite) NSNumber *userBMR;
@property (nonatomic, strong, readwrite) NSNumber *proteinRequirements;

@property (nonatomic, strong, readwrite) NSNumber *goals;
@property (nonatomic, strong, readwrite, nullable) NSDate *goalStartDate;
@property (nonatomic, strong, readwrite) NSNumber *weightGoal;
@property (nonatomic, strong, readwrite) NSNumber *goalRate;

@property (nonatomic, strong, readwrite) NSNumber *carbRatio;
@property (nonatomic, strong, readwrite) NSNumber *proteinRatio;
@property (nonatomic, strong, readwrite) NSNumber *fatRatio;

@property (nonatomic, strong, readwrite) NSString *hostName;
@end

@implementation DMUser

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.userId forKey:@"userId"];
    [encoder encodeObject:self.userName forKey:@"userName"];
    [encoder encodeObject:self.authToken forKey:@"authToken"];
    [encoder encodeObject:self.email1 forKey:@"email1"];
    [encoder encodeObject:self.email2 forKey:@"email2"];

    [encoder encodeObject:self.companyId forKey:@"companyId"];
    [encoder encodeObject:self.companyName forKey:@"companyName"];
    [encoder encodeObject:self.mobileGraphicImageName forKey:@"mobileGraphicImageName"];

    [encoder encodeObject:self.firstName forKey:@"firstName"];
    [encoder encodeObject:self.lastName forKey:@"lastName"];

    [encoder encodeObject:self.birthDate forKey:@"birthDate"];
    [encoder encodeObject:self.gender forKey:@"gender"];
    [encoder encodeObject:self.height forKey:@"height"];
    [encoder encodeObject:self.lactating forKey:@"lactating"];

    [encoder encodeObject:self.profession forKey:@"profession"];

    [encoder encodeObject:self.bodyType forKey:@"bodyType"];
    [encoder encodeObject:self.userBMR forKey:@"userBMR"];
    [encoder encodeObject:self.proteinRequirements forKey:@"proteinRequirements"];

    [encoder encodeObject:self.goals forKey:@"goals"];
    [encoder encodeObject:self.goalStartDate forKey:@"goalStartDate"];
    [encoder encodeObject:self.weightGoal forKey:@"weightGoal"];
    [encoder encodeObject:self.goalRate forKey:@"goalRate"];

    [encoder encodeObject:self.carbRatio forKey:@"carbRatio"];
    [encoder encodeObject:self.proteinRatio forKey:@"proteinRatio"];
    [encoder encodeObject:self.fatRatio forKey:@"fatRatio"];

    [encoder encodeObject:self.hostName forKey:@"hostName"];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if (self) {
        _userId = [decoder decodeObjectForKey:@"userId"];
        _userName = [decoder decodeObjectForKey:@"userName"];
        _authToken = [decoder decodeObjectForKey:@"authToken"];
        _email1 = [decoder decodeObjectForKey:@"email1"];
        _email2 = [decoder decodeObjectForKey:@"email2"];

        _companyId = [decoder decodeObjectForKey:@"companyId"];
        _companyName = [decoder decodeObjectForKey:@"companyName"];
        _mobileGraphicImageName = [decoder decodeObjectForKey:@"mobileGraphicImageName"];

        _firstName = [decoder decodeObjectForKey:@"firstName"];
        _lastName = [decoder decodeObjectForKey:@"lastName"];

        _birthDate = [decoder decodeObjectForKey:@"birthDate"];
        _gender = [decoder decodeObjectForKey:@"gender"];
        _height = [decoder decodeObjectForKey:@"height"];
        _lactating = [decoder decodeObjectForKey:@"lactating"];

        _profession = [decoder decodeObjectForKey:@"profession"];

        _bodyType = [decoder decodeObjectForKey:@"bodyType"];
        _userBMR = [decoder decodeObjectForKey:@"userBMR"];
        _proteinRequirements = [decoder decodeObjectForKey:@"proteinRequirements"];

        _goals = [decoder decodeObjectForKey:@"goals"];
        _goalStartDate = [decoder decodeObjectForKey:@"goalStartDate"];
        _weightGoal = [decoder decodeObjectForKey:@"weightGoal"];
        _goalRate = [decoder decodeObjectForKey:@"goalRate"];

        _carbRatio = [decoder decodeObjectForKey:@"carbRatio"];
        _proteinRatio = [decoder decodeObjectForKey:@"proteinRatio"];
        _fatRatio = [decoder decodeObjectForKey:@"fatRatio"];

        _hostName = [decoder decodeObjectForKey:@"hostName"];
    }
    return self;
}

- (instancetype)init {
    return [self initWithDictionary:@{}];
}

- (instancetype)initWithDictionary:(NSDictionary *)userDict {
    self = [super init];
    if (self) {
        _userId = ValidNSNumber(userDict[@"UserID"]);
        _userName = ValidString(userDict[@"Username"]);
        _authToken = ValidString(userDict[@"Token"]);
        _email1 = ValidString(userDict[@"Email1"]);
        _email2 = ValidString(userDict[@"Email2"]);

        _companyId = ValidNSNumber(userDict[@"CompanyID"]);
        _companyName = ValidString(userDict[@"CompanyName"]);
        _mobileGraphicImageName = ValidString(userDict[@"MobileGraphic"]);
        
        _firstName = ValidString(userDict[@"FirstName"]);
        _lastName = ValidString(userDict[@"LastName"]);

        _carbRatio = ValidNSNumber(userDict[@"CarbRatio"]);
        _proteinRatio = ValidNSNumber(userDict[@"ProteinRatio"]);
        _fatRatio = ValidNSNumber(userDict[@"FatRatio"]);
        
        _hostName = ValidString(userDict[@"HostName"]);

        // Formatters.
        _massFormatter = [[NSMassFormatter alloc] init];
        _numberFormatter = [[NSNumberFormatter alloc] init];
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

        [self updateUserDetails:userDict];
    }
    return self;
}

- (void)updateUserDetails:(NSDictionary *)userDict {
    if (!userDict) {
        return;
    }
    _weightGoal = ValidNSNumber(userDict[@"WeightGoal"]);
    _height = ValidNSNumber(userDict[@"Height"]);

    _goals = ValidNSNumber(userDict[@"Goals"]);

    if (userDict[@"BirthDate"]) {
        _birthDate = [_dateFormatter dateFromString:userDict[@"BirthDate"]];
    }
    if (userDict[@"GoalStartDate"]) {
        _goalStartDate = [_dateFormatter dateFromString:userDict[@"GoalStartDate"]];
    }

    _profession = ValidNSNumber(userDict[@"Profession"]);
    _bodyType = ValidNSNumber(userDict[@"BodyType"]);
    _proteinRequirements = ValidNSNumber(userDict[@"ProteinRequirements"]);
    _gender = ValidNSNumber(userDict[@"Gender"]);
    _lactating = ValidNSNumber(userDict[@"Lactation"]);
    _goalRate = ValidNSNumber(userDict[@"GoalRate"]);
    _userBMR = ValidNSNumber(userDict[@"BMR"]);
}

- (NSString *)birthDateString {
    if (!self.birthDate) {
        return @"";
    }
    return [self.dateFormatter stringFromDate:self.birthDate];
}

- (NSString *)goalStartDateString {
    if (!self.goalStartDate) {
        return @"";
    }
    return [self.dateFormatter stringFromDate:self.goalStartDate];
}

- (DMUserWeightGoalType)weightGoalType {
    return (DMUserWeightGoalType)self.goals;
}

- (NSString *)weightGoalLocalizedString {
    [self.massFormatter setForPersonMassUse:YES];
    NSMassFormatterUnit unit = NSMassFormatterUnitPound;
    if (self.numberFormatter.locale.usesMetricSystem) {
        unit = NSMassFormatterUnitKilogram;
    }
    return [self.massFormatter stringFromValue:self.weightGoal.doubleValue
                                          unit:unit];
}

- (NSString *)weightGoalTypeAsString {
    switch (self.weightGoalType) {
        case DMUserWeightGoalTypeLoss:
            return @"Lost";
        case DMUserWeightGoalTypeMaintain:
            return @"Maintained";
        case DMUserWeightGoalTypeGain:
            return @"Gained";
    }
    return @"";
}

static NSString *UseCalorieTrackingDeviceKey = @"CalorieTrackingDevice";
- (BOOL)useCalorieTrackingDevice {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:UseCalorieTrackingDeviceKey];
}

- (void)setUseCalorieTrackingDevice:(BOOL)useCalorieTrackingDevice {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:useCalorieTrackingDevice forKey:UseCalorieTrackingDeviceKey];
}

static NSString *UseBurnedCaloriesKey = @"LoggedExeTracking";
- (BOOL)useBurnedCalories {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:UseBurnedCaloriesKey];
}

- (void)setUseBurnedCalories:(BOOL)useBurnedCalories {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:useBurnedCalories forKey:UseBurnedCaloriesKey];
}

static NSString *AppleHealthTrackingKey = @"LoggedAppleWatchTracking";
- (BOOL)enableAppleHealthSync {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:AppleHealthTrackingKey];
}

- (void)setEnableAppleHealthSync:(BOOL)enableAppleHealthSync {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:enableAppleHealthSync forKey:AppleHealthTrackingKey];
}

- (NSString *)description {
    NSString *base = [super description];
    return [NSString stringWithFormat:@"%@: %@", base, [self listPropertiesAsString]];
}

@end
