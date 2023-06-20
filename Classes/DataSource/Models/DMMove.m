//
//  DMMove.m
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/17/23.
//

#import "DMMove.h"

@interface DMMove()
@property (nonatomic, strong, readwrite) NSNumber *moveId;
@property (nonatomic, strong, readwrite) NSNumber *companyId;
@property (nonatomic, strong, readwrite) NSString *name;
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
        // See note in -dictionaryRepresentation why this looks at two sets of keys.
        _moveId = dictionary[@"MoveID"] ?: dictionary[@"moveID"];
        _companyId = dictionary[@"CompanyID"] ?: dictionary[@"companyID"];
        
        NSString *name = dictionary[@"MoveName"] ?: dictionary[@"moveName"];
        name = [name stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
        name = [name stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _name = name;
        
        _videoUrl = dictionary[@"VideoLink"] ?: dictionary[@"videoLink"];

        NSString *notes = dictionary[@"Notes"] ?: dictionary[@"notes"];
        notes = [notes stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
        notes = [notes stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        notes = [notes stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _notes = notes;
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          self.moveId, @"MoveID",
                          self.companyId, @"CompanyID",
                          self.name, @"MoveName",
                          self.videoUrl, @"VideoLink",
                          self.notes, @"Notes",
                          // Due to the awesome data design by the overseas vendor, the local database uses capital, while
                          // the web API uses lowercase, thus to make this support both use cases we output both sets:
                          self.moveId, @"moveID",
                          self.companyId, @"companyID",
                          self.name, @"moveName",
                          self.videoUrl, @"videoLink",
                          self.notes, @"notes",
                          nil];
    return dict;
}

- (NSString *)replaceIntoSQLString {
    NSString *sqlString = [NSString stringWithFormat:@"REPLACE INTO MoveDetailsTable "
                            "(MoveID, CompanyID, MoveName, VideoLink, Notes) VALUES (\"%d\", \"%d\", \"%@\", \"%@\", '%@')",
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
