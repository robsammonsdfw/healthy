//
//  DMMoveTag.m
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/17/23.
//

#import "DMMoveTag.h"

@interface DMMoveTag()
@property (nonatomic, strong, readwrite) NSNumber *tagId;
@property (nonatomic, copy, readwrite) NSString *name;
@end

@implementation DMMoveTag

- (instancetype)init {
    return [self initWithDictionary:@{}];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _tagId = dictionary[@"tagID"];
        
        NSString *name = dictionary[@"tag"];
        if (![name isEqualToString:@"(null)"]) {
            name = [name stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
            name = [name stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            _name = name;
        }
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          self.tagId, @"tagID",
                          self.name, @"tag",
                          nil];
    return dict;
}

- (NSString *)replaceIntoSQLString {
    NSString *sqlString = [NSString stringWithFormat:@"REPLACE INTO MoveTags "
                            "(tagID, tag) VALUES (\"%d\", \"%@\")",
                           self.tagId.intValue,
                           self.name ];
    return sqlString;
}

- (NSString *)description {
    NSString *base = [super description];
    return [NSString stringWithFormat:@"%@: %@", base, [self listPropertiesAsString]];
}

@end
