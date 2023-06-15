//
//  DMUser.m
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/15/23.
//

#import "DMUser.h"

@interface DMUser()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation DMUser

- (instancetype)init {
    return [self initWithDictionary:@{}];
}

- (instancetype)initWithDictionary:(NSDictionary *)userDict {
    self = [super init];
    if (self) {
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

@end
