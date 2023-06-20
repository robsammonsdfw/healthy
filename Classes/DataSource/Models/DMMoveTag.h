//
//  DMMoveTag.h
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/17/23.
//

#import <Foundation/Foundation.h>
@protocol DMPickerViewDataSource;

NS_ASSUME_NONNULL_BEGIN

@interface DMMoveTag : NSObject <DMPickerViewDataSource>
@property (nonatomic, strong, readonly) NSNumber *tagId;
@property (nonatomic, copy, readonly) NSString *name;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

/// Returns the Food object as a dictionary with the keys that match database and webservice fields.
- (NSDictionary *)dictionaryRepresentation;

/// Returns a SQL statement string to replace into the database.
- (NSString *)replaceIntoSQLString;

@end

NS_ASSUME_NONNULL_END
