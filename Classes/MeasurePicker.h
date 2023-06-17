//
//  MeasurePicker.h
//  DietMasterGo
//
//  Created by DietMaster on 12/9/11.
//  Copyright 2011 Lifestyles Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@protocol MeasurePickerDelegate <NSObject>
-(void)didChooseMeasure:(NSString *)chosenMID withName:(NSString *)chosenMName;
@end

@class AppDelegate;

@interface MeasurePicker : UIViewController {
	AppDelegate *mainDelegate;
	sqlite3 *database;
	NSString *dbPath;
	IBOutlet UIPickerView *pickerView;
    NSNumber *pickerRow3;
	NSMutableArray *arry3;
	NSMutableArray *measureIDs;
	NSNumber *selectedMeasureID;
    NSArray *arrayWithoutDuplicates;
    NSMutableArray *rowListArr;

}

-(IBAction) sendMeasure:(id) sender;
-(IBAction)cancelSaveMeasure:(id)sender;

@property (nonatomic, strong) AppDelegate *mainDelegate;
@property (nonatomic, strong) NSNumber *pickerRow3;
@property (nonatomic, strong) NSMutableArray *arry3;
@property (nonatomic, strong) NSMutableArray *measureIDs;
@property (nonatomic, strong) NSNumber *selectedMeasureID;
@property (nonatomic, weak) id<MeasurePickerDelegate> delegate;

-(NSMutableArray *) filterObjectsByKeys:(NSString *) key array:(NSMutableArray *)array;

@end
