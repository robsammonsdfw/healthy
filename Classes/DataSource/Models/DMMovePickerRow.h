//
//  DMMovePickerRow.h
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/23/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Object that conforms to the DMMovePickerDataSource
/// Used to show options on the detail page.
@interface DMMovePickerRow : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSNumber *rowId;
+ (instancetype)newWithName:(NSString *)name rowId:(NSNumber *)rowId;
@end

NS_ASSUME_NONNULL_END
