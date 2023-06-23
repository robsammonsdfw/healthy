//
//  DMMovePickerRow.m
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/23/23.
//

#import "DMMovePickerRow.h"

@implementation DMMovePickerRow
+ (instancetype)newWithName:(NSString *)name rowId:(NSNumber *)rowId {
    DMMovePickerRow *object = [[DMMovePickerRow alloc] init];
    object.name = name;
    object.rowId = rowId;
    return object;
}
@end
