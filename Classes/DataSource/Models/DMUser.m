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
        
        _weightGoal = ObjectOrNSNumber(userDict[@"WeightGoal"]);
        _height = ObjectOrNSNumber(userDict[@"Height"]);
        _goals = ObjectOrNSNumber(userDict[@"Goals"]);
        _profession = ObjectOrNSNumber(userDict[@"Profession"]);
        _bodyType = ObjectOrNSNumber(userDict[@"BodyType"]);
        _proteinRequirements = ObjectOrNSNumber(userDict[@"ProteinRequirements"]);
        _gender = ObjectOrNSNumber(userDict[@"Gender"]);
        _lactating = ObjectOrNSNumber(userDict[@"Lactation"]);
        _goalRate = ObjectOrNSNumber(userDict[@"GoalRate"]);
        _userBMR = ObjectOrNSNumber(userDict[@"BMR"]);
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
