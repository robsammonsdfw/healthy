//
//  DMMoveSet.m
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/24/23.
//

#import "DMMoveSet.h"

@interface DMMoveSet()
@property (nonatomic, strong, readwrite) NSNumber *setId;
@property (nonatomic, strong, readwrite) NSNumber *routineId;
@property (nonatomic, strong, readwrite) NSNumber *dayId;
@property (nonatomic, strong, readwrite) NSNumber *setNumber;
@property (nonatomic, strong, readwrite) NSNumber *unitOneId;
@property (nonatomic, strong, readwrite) NSNumber *unitOneValue;
@property (nonatomic, strong, readwrite) NSNumber *unitTwoId;
@property (nonatomic, strong, readwrite) NSNumber *unitTwoValue;
@end

@implementation DMMoveSet

+ (instancetype)setWithDefaultValues {
    DMMoveSet *set = [[DMMoveSet alloc] init];
    set.setId = @0;
    set.routineId = @0;
    set.dayId = @0;
    set.setNumber = @0;
    set.unitOneId = @0;
    set.unitOneValue = @0;
    set.unitTwoId = @0;
    set.unitTwoValue = @0;
    return set;
}

- (instancetype)init {
    return [self initWithDictionary:@{}];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _setId = ValidNSNumber(dictionary[@"SetID"]);
        _routineId = ValidNSNumber(dictionary[@"UserPlanMoveID"]);
        _dayId = ValidNSNumber(dictionary[@"UserPlanDateID"]);

        _setNumber = ValidNSNumber(dictionary[@"SetNumber"]);
        
        _unitOneId = ValidNSNumber(dictionary[@"Unit1ID"]);
        _unitOneValue = ValidNSNumber(dictionary[@"Unit1Value"]);
        _unitTwoId = ValidNSNumber(dictionary[@"Unit2ID"]);
        _unitTwoValue = ValidNSNumber(dictionary[@"Unit2Value"]);
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          self.setId, @"SetID",
                          self.routineId, @"UserPlanMoveID",
                          self.dayId, @"UserPlanDateID",
                          self.setNumber, @"SetNumber",
                          self.unitOneId, @"Unit1ID",
                          self.unitOneValue, @"Unit1Value",
                          self.unitTwoId, @"Unit2ID",
                          self.unitTwoValue, @"Unit2Value",
                          nil];
    return dict;
}

- (NSString *)description {
    NSString *base = [super description];
    return [NSString stringWithFormat:@"%@: %@", base, [self listPropertiesAsString]];
}

@end
