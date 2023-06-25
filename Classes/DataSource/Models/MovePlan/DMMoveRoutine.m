//
//  DMMoveRoutine.m
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/24/23.
//

#import "DMMoveRoutine.h"

@interface DMMoveRoutine()
@property (nonatomic, strong, readwrite) NSNumber *routineId;
@property (nonatomic, strong, readwrite) NSNumber *moveId;
@property (nonatomic, strong, readwrite) NSNumber *dayId;
@property (nonatomic, strong, readwrite) NSArray<DMMoveSet *> *sets;
@property (nonatomic, strong, readwrite) DMMove *move;
@end

@implementation DMMoveRoutine

- (instancetype)init {
    return [self initWithDictionary:@{}];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _routineId = ValidNSNumber(dictionary[@"UserPlanMoveID"]);
        _moveId = ValidNSNumber(dictionary[@"MoveID"]);
        _dayId = ValidNSNumber(dictionary[@"UserPlanDateID"]);
        _isCompleted = ValidNSNumber(dictionary[@"isCheckBoxClicked"]);
        _sets = @[];
    }
    return self;
}

- (void)setRoutineSets:(NSArray<DMMoveSet *> *)sets {
    NSMutableArray *results = [NSMutableArray array];
    for (DMMoveSet *set in sets) {
        if ([set.routineId isEqual:self.routineId]) {
            [results addObject:set];
        }
    }
    self.sets = [results copy];
}

- (void)setMove:(DMMove *)move {
    _move = move;
}

- (NSDictionary *)dictionaryRepresentation {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          self.routineId, @"UserPlanMoveID",
                          self.dayId, @"UserPlanDateID",
                          self.moveId, @"MoveID",
                          self.isCompleted, @"isCheckBoxClicked",
                          nil];
    return dict;
}

- (NSString *)description {
    NSString *base = [super description];
    return [NSString stringWithFormat:@"%@: %@", base, [self listPropertiesAsString]];
}


@end
