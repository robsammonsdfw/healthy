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
        _moveId = dictionary[@"moveID"];
        _companyId = dictionary[@"companyID"];
        
        NSString *name = dictionary[@"moveName"];
        name = [name stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
        name = [name stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        _name = name;
        
        _videoUrl = dictionary[@"videoLink"];

        NSString *notes = dictionary[@"notes"];
        notes = [notes stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
        notes = [notes stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
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
    NSString *sqlString = [NSString stringWithFormat:@"REPLACE INTO MoveDetailsTable "
                            "(MoveID, CompanyID, MoveName, VideoLink, Notes) VALUES (\"%d\", \"%d\", \"%@\", \"%@\", '%@')",
                           self.moveId.intValue,
                           self.companyId.intValue,
                           self.name,
                           self.videoUrl,
                           self.notes ];
    return sqlString;
}

@end
