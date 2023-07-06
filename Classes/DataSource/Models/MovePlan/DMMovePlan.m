//
//  DMMovePlan.m
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/23/23.
//

#import "DMMovePlan.h"

@interface DMMovePlan()
@property (nonatomic, strong, readwrite) NSNumber *planId;
@property (nonatomic, strong, readwrite) NSNumber *userId;
@property (nonatomic, copy, readwrite) NSString *planName;
@property (nonatomic, copy, readwrite) NSString *lastUpdated;
@property (nonatomic, copy, readwrite) NSString *notes;
@property (nonatomic, copy, readwrite) NSString *uniqueId;
@property (nonatomic, copy, readwrite) NSString *status;
@property (nonatomic, copy, readwrite) NSString *syncResult;
@property (nonatomic, strong, readwrite) NSArray<DMMoveDay *> *moveDays;
@end

@implementation DMMovePlan

+ (instancetype)customUserPlan {
    DMMovePlan *movePlan = [[DMMovePlan alloc] init];
    movePlan.planId = @(-100);
    movePlan.planName = @"My Custom Plan";
    movePlan.uniqueId = [NSUUID UUID].UUIDString;
    movePlan.status = @"New";
    
    return movePlan;
}

- (instancetype)init {
    return [self initWithDictionary:@{}];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _moveDays = @[];
        _planId = ValidNSNumber(dictionary[@"PlanID"]);
        _userId = ValidNSNumber(dictionary[@"UserID"]);
        _planName = ValidString(dictionary[@"PlanName"]);
        _lastUpdated = ValidString(dictionary[@"LastUpdated"]);
        _notes = ValidString(dictionary[@"Notes"]);
        _uniqueId = ValidString(dictionary[@"UniqueID"]);
        _status = ValidString(dictionary[@"Stats"]);
        _syncResult = ValidString(dictionary[@"SyncResult"]);
    }
    return self;
}

- (BOOL)isCustomUserPlan {
    // Custom plan has an ID of -100.
    return self.planId.integerValue == -100;
}

- (NSDictionary *)dictionaryRepresentation {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          self.planId, @"PlanID",
                          self.userId, @"UserID",
                          self.lastUpdated, @"LastUpdated",
                          self.status, @"Status",
                          self.syncResult, @"SyncResult",
                          self.planName, @"PlanName",
                          self.notes, @"Notes",
                          self.uniqueId, @"UniqueID",
                          nil];
    return dict;
}

- (NSString *)replaceIntoSQLString {
    NSString *sqlString = [NSString stringWithFormat:@"REPLACE INTO ServerUserPlanList "
                            "(PlanID, UserID, LastUpdated, Status, SyncResult, PlanName, Notes, UniqueID) "
                            "VALUES (%d, %d, \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")",
                           self.planId.intValue,
                           self.userId.intValue,
                           self.lastUpdated,
                           self.status,
                           self.syncResult,
                           self.planName,
                           self.notes,
                           self.uniqueId ];
    return sqlString;
}

- (void)setMovePlanDays:(NSArray<DMMoveDay *> *)moveDays {
    NSMutableArray *results = [NSMutableArray array];
    for (DMMoveDay *day in moveDays) {
        if ([day.planId isEqual:self.planId]) {
            [results addObject:day];
        }
    }
    self.moveDays = [results copy];
}

- (NSString *)description {
    NSString *base = [super description];
    return [NSString stringWithFormat:@"%@: %@", base, [self listPropertiesAsString]];
}

@end
