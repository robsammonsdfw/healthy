//
//  DMMoveDay.m
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/24/23.
//

#import "DMMoveDay.h"

@interface DMMoveDay()
@property (nonatomic, strong, readwrite) NSNumber *dayId;
@property (nonatomic, strong, readwrite) NSNumber *planId;
@property (nonatomic, copy, readwrite) NSString *planDate;
@property (nonatomic, strong, readwrite) NSArray<DMMoveRoutine *> *routines;
@end

@implementation DMMoveDay

- (instancetype)init {
    return [self initWithDictionary:@{}];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _dayId = ValidNSNumber(dictionary[@"UserPlanDateID"]);
        _planId = ValidNSNumber(dictionary[@"PlanID"]);
        _planDate = ValidString(dictionary[@"PlanDate"]);
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          self.dayId, @"UserPlanDateID",
                          self.planId, @"PlanID",
                          self.planDate, @"PlanDate",
                          nil];
    return dict;
}

- (void)setDayRoutines:(NSArray<DMMoveRoutine *> *)routines {
    NSMutableArray *results = [NSMutableArray array];
    for (DMMoveRoutine *routine in routines) {
        if ([routine.dayId isEqual:self.dayId]) {
            [results addObject:routine];
        }
    }
    self.routines = [results copy];
}

- (NSString *)description {
    NSString *base = [super description];
    return [NSString stringWithFormat:@"%@: %@", base, [self listPropertiesAsString]];
}


@end
