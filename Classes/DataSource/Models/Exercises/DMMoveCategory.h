//
//  DMMoveCategory.h
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/17/23.
//

#import <Foundation/Foundation.h>
@protocol DMPickerViewDataSource;

NS_ASSUME_NONNULL_BEGIN

/// A category ("bodypart") for an exercise.
/// NOTE: The table "MoveCategories" is hard coded.
@interface DMMoveCategory : NSObject <DMPickerViewDataSource>
@property (nonatomic, strong, readonly) NSNumber *categoryId;
@property (nonatomic, copy, readonly) NSString *name;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

/// Returns the object as a dictionary with the keys that match database and webservice fields.
- (NSDictionary *)dictionaryRepresentation;

@end

NS_ASSUME_NONNULL_END
