//
//  PickerViewController.h
//  MyMoves
//
//  Created by Samson  on 01/02/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SelectedBodyPartDelegate;
@protocol changedRepsAndWeightDelegate;

/// The type of data being displayed in the picker.
typedef NS_ENUM(NSUInteger, DMPickerDataType) {
    DMPickerDataTypeUnknown = 0,
    DMPickerDataTypeMoveTags = 1,
    DMPickerDataTypeMoveCategories = 2
};

@interface PickerViewController : UIViewController

@property (nonatomic) DMPickerDataType dataType;

@property (nonatomic, weak) id<SelectedBodyPartDelegate> selectedBodyPartDel;
@property (nonatomic, weak) id<changedRepsAndWeightDelegate> repsWeightDel;
@property (nonatomic) NSString *parentUniqueId;

@property (nonatomic, strong) NSArray *pickerData;
@property (nonatomic, strong) NSArray *data;
@property (nonatomic) BOOL secondColumn;

@end
@protocol SelectedBodyPartDelegate <NSObject>
- (void)getSelectedBodyPart:(NSDictionary *)dict;
- (void)getSelectedTagId:(NSDictionary *)dict;
@end
@protocol changedRepsAndWeightDelegate <NSObject>
- (void)getReps:(NSString *)str;
- (void)getWeight:(NSString *)str;
@end

NS_ASSUME_NONNULL_END
