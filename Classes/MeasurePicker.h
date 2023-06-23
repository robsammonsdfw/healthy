//
//  MeasurePicker.h
//  DietMasterGo
//
//  Created by DietMaster on 12/9/11.
//  Copyright 2011 Lifestyles Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MeasurePickerDelegate <NSObject>
- (void)didChooseMeasure:(NSString *)chosenMID withName:(NSString *)chosenMName;
@end

@interface MeasurePicker : UIViewController {
	IBOutlet UIPickerView *pickerView;
    NSNumber *pickerRow3;
	NSMutableArray *arry3;
	NSMutableArray *measureIDs;
	NSNumber *selectedMeasureID;
    NSArray *arrayWithoutDuplicates;
    NSMutableArray *rowListArr;
}

@property (nonatomic, strong) NSNumber *pickerRow3;
@property (nonatomic, strong) NSMutableArray *arry3;
@property (nonatomic, strong) NSMutableArray *measureIDs;
@property (nonatomic, strong) NSNumber *selectedMeasureID;
@property (nonatomic, weak) id<MeasurePickerDelegate> delegate;

@end
