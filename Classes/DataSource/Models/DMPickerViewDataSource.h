//
//  DMPickerViewDataSource.h
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/24/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Protocol for working the DMPickerViewController.
/// The picker can only display an item that conforms to this.
@protocol DMPickerViewDataSource <NSObject>
@property (nonatomic, readonly) NSString *name;
@end

NS_ASSUME_NONNULL_END
