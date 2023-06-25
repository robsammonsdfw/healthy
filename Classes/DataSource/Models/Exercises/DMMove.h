//
//  DMMove.h
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/17/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Represents a "Move" aka exercise/workout in DMG.
@interface DMMove : NSObject
@property (nonatomic, strong, readonly) NSNumber *moveId;
@property (nonatomic, strong, readonly) NSNumber *companyId;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *videoUrl;
@property (nonatomic, strong, readonly) NSString *notes;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

/// Returns the object as a dictionary with the keys that match database and webservice fields.
- (NSDictionary *)dictionaryRepresentation;

/// Returns a SQL statement string to replace into the database.
- (NSString *)replaceIntoSQLString;

@end

NS_ASSUME_NONNULL_END
