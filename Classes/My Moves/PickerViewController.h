//
//  PickerViewController.h
//  MyMoves
//
//  Created by Samson  on 01/02/19.
//

#import <UIKit/UIKit.h>
#import "PickerViewController.h"

NS_ASSUME_NONNULL_BEGIN
@protocol SelectedBodyPartDelegate;
@protocol changedRepsAndWeightDelegate;

@interface PickerViewController : UIViewController{
    
}
@property(nonatomic,assign) id<SelectedBodyPartDelegate> selectedBodyPartDel;
@property(nonatomic,assign) id<changedRepsAndWeightDelegate> repsWeightDel;
@property (nonatomic, assign) NSString *parentUniqueId;


@property (strong, retain) NSArray *pickerData;
@property (strong, retain) NSArray *data;
@property (nonatomic, assign) BOOL secondColumn;

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
