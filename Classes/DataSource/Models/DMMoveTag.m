//
//  DMMoveTag.m
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/17/23.
//

#import "DMMoveTag.h"

@interface DMMoveTag()
@property (nonatomic, strong, readwrite) NSNumber *tagId;
@property (nonatomic, strong, readwrite) NSString *name;
@end

@implementation DMMoveTag

- (instancetype)init {
    return [self initWithDictionary:@{}];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _tagId = dictionary[@"TagID"];
        
        NSString *name = dictionary[@"TagName"];
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
                            "(TagID, TagName) VALUES (\"%d\", \"%@\")",
                           self.tagId.intValue,
                           self.name ];
    return sqlString;
}

@end
