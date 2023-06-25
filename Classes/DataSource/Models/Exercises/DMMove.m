//
//  DMMove.m
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/17/23.
//

#import "DMMove.h"
#import "DietMasterGoPlus-Swift.h"

@interface DMMove()
@property (nonatomic, strong, readwrite) NSNumber *moveId;
@property (nonatomic, strong, readwrite) NSNumber *companyId;
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSString *videoUrl;
@property (nonatomic, strong, readwrite) NSString *notes;
@end

@implementation DMMove

- (instancetype)init {
    return [self initWithDictionary:@{}];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _moveId = ValidNSNumber(dictionary[@"moveID"]);
        _companyId = ValidNSNumber(dictionary[@"companyID"]);
        
        NSString *name = ValidString(dictionary[@"moveName"]);
        name = [name stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
        name = [name stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        // Not sure if this is needed or not.
//        NSArray *nameSplit = [name componentsSeparatedByString:@"("];
//        if ([name containsString:@"("]) {
//            name = [NSString stringWithFormat:@"%@", nameSplit.firstObject];
//        }
        _name = name;

        _videoUrl = ValidString(dictionary[@"videoLink"]);

        NSString *notes = ValidString(dictionary[@"notes"]);
        notes = [notes stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
        notes = [notes stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        notes = [notes stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _notes = notes;
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          self.moveId, @"moveID",
                          self.companyId, @"companyID",
                          self.name, @"moveName",
                          self.videoUrl, @"videoLink",
                          self.notes, @"notes",
                          nil];
    return dict;
}

- (NSString *)replaceIntoSQLString {
    NSString *sqlString = [NSString stringWithFormat:@"REPLACE INTO MoveDetails "
                            "(moveID, companyID, moveName, videoLink, notes) VALUES (\"%d\", \"%d\", \"%@\", \"%@\", '%@')",
                           self.moveId.intValue,
                           self.companyId.intValue,
                           self.name,
                           self.videoUrl,
                           self.notes ];
    return sqlString;
}

- (NSString *)description {
    NSString *base = [super description];
    return [NSString stringWithFormat:@"%@: %@", base, [self listPropertiesAsString]];
}

@end
