//
//  DMMoveCategory.m
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/17/23.
//

#import "DMMoveCategory.h"

@interface DMMoveCategory()
@property (nonatomic, strong, readwrite) NSNumber *categoryId;
@property (nonatomic, strong, readwrite) NSString *name;
@end

@implementation DMMoveCategory

- (instancetype)init {
    return [self initWithDictionary:@{}];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _categoryId = dictionary[@"categoryID"];
        
        NSString *name = dictionary[@"CategoryName"];
        name = [name stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
        name = [name stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _name = name;
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          self.categoryId, @"categoryID",
                          self.name, @"CategoryName",
                          nil];
    return dict;
}

- (NSString *)description {
    NSString *base = [super description];
    return [NSString stringWithFormat:@"%@: %@", base, [self listPropertiesAsString]];
}

@end
