//
//  DMDatabaseUtilities.m
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 7/1/23.
//

#import "DMDatabaseUtilities.h"

@interface DMDatabaseUtilities()
@end

@implementation DMDatabaseUtilities

+ (FMDatabase *)database {
    return [FMDatabase databaseWithPath:[self databasePath]];
}

+ (NSNumber *)getMaxValueForColumn:(NSString *)columnName inTable:(NSString *)tableName {
    if (!columnName.length || !tableName.length) {
        return nil;
    }
    FMDatabase* db = [self database];
    if (![db open]) {
        return  nil;
    }
    
    NSString *sqlString = [NSString stringWithFormat:@"SELECT MAX(%@) as MaxValue FROM %@", columnName, tableName];
    FMResultSet *rs = [db executeQuery:sqlString];

    NSNumber *maxValue = nil;
    while ([rs next]) {
        NSDictionary *resultDict = [rs resultDictionary];
        maxValue = resultDict[@"MaxValue"];
    }
    [rs close];
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        return nil;
    }
    
    return maxValue;
}

static NSString *DMDatabasePath = nil;
+ (NSString *)databasePath {
    if (DMDatabasePath) {
        return DMDatabasePath;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *fullPath = [path stringByAppendingPathComponent:@"DMGO_v3.9.2.sqlite"];
    //DMLog(@"%@",fullPath);
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL exists = [fm fileExistsAtPath:fullPath];
    if (!exists) {
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSString *pathForStartingDB = [path stringByAppendingPathComponent:@"DMGO_v3.9.2.sqlite"];
        [fm copyItemAtPath:pathForStartingDB toPath:fullPath error:nil];
    }
    
    NSLog(@"DB Path: %@", fullPath);
    DMDatabasePath = fullPath;
    return fullPath;
}

@end
