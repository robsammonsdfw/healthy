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
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong, readwrite) NSNumber *userId;
@property (nonatomic, strong, readwrite) NSString *userName;
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

- (instancetype)init {
    return [self initWithDictionary:@{}];
}

- (instancetype)initWithDictionary:(NSDictionary *)userDict {
    self = [super init];
    if (self) {
        _userId = ValidNSNumber(userDict[@"UserID"]);
        _userName = ValidString(userDict[@"Username"]);
        _email1 = ValidString(userDict[@"Email1"]);
        _email2 = ValidString(userDict[@"Email2"]);

        _companyId = ValidNSNumber(userDict[@"CompanyID"]);
        _companyName = ValidString(userDict[@"CompanyName"]);
        _mobileGraphicImageName = ValidString(userDict[@"MobileGraphic"]);
        
        _firstName = ValidString(userDict[@"FirstName"]);
        _lastName = ValidString(userDict[@"LastName"]);

        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

        if (userDict[@"BirthDate"]) {
            _birthDate = [_dateFormatter dateFromString:userDict[@"BirthDate"]];
        }
        if (userDict[@"GoalStartDate"]) {
            _goalStartDate = [_dateFormatter dateFromString:userDict[@"GoalStartDate"]];
        }
        
        _weightGoal = ValidNSNumber(userDict[@"WeightGoal"]);
        _height = ValidNSNumber(userDict[@"Height"]);
        _goals = ValidNSNumber(userDict[@"Goals"]);
        _profession = ValidNSNumber(userDict[@"Profession"]);
        _bodyType = ValidNSNumber(userDict[@"BodyType"]);
        _proteinRequirements = ValidNSNumber(userDict[@"ProteinRequirements"]);
        _gender = ValidNSNumber(userDict[@"Gender"]);
        _lactating = ValidNSNumber(userDict[@"Lactation"]);
        _goalRate = ValidNSNumber(userDict[@"GoalRate"]);
        _userBMR = ValidNSNumber(userDict[@"BMR"]);
        
        _carbRatio = ValidNSNumber(userDict[@"CarbRatio"]);
        _proteinRatio = ValidNSNumber(userDict[@"ProteinRatio"]);
        _fatRatio = ValidNSNumber(userDict[@"FatRatio"]);
        
        _hostName = ValidString(userDict[@"HostName"]);
        
    }
    return self;
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

- (NSString *)description {
    NSString *base = [super description];
    return [NSString stringWithFormat:@"%@: %@", base, [self listPropertiesAsString]];
}

@end
