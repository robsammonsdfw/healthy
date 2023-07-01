//
//  DMDatabaseUtilities.h
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 7/1/23.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

NS_ASSUME_NONNULL_BEGIN

/// Utilities for interacting with the SQLite database.
@interface DMDatabaseUtilities : NSObject

/// Returns a new instance of the database.
+ (FMDatabase *)database;

/// Gets the max value for the column provided in the table name.
/// Used to help get ID values since most tables aren't auto incremented.
+ (NSNumber *)getMaxValueForColumn:(NSString *)columnName inTable:(NSString *)tableName;

@end

NS_ASSUME_NONNULL_END
