//
//  DMMovePickerRow.h
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/23/23.
//

#import <Foundation/Foundation.h>
#import "DMPickerViewDataSource.h"

NS_ASSUME_NONNULL_BEGIN

/// Object that conforms to the DMMovePickerDataSource
/// Used to show options on the detail page.
@interface DMMovePickerRow : NSObject <DMPickerViewDataSource>
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSNumber *rowId;
+ (instancetype)newWithName:(NSString *)name rowId:(NSNumber *)rowId;
@end

NS_ASSUME_NONNULL_END
