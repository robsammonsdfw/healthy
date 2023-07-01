//
//  MeasurePicker.m
//  DietMasterGo
//
//  Created by DietMaster on 12/9/11.
//  Copyright 2011 Lifestyles Technologies, Inc. All rights reserved.
//

#import "MeasurePicker.h"
#import "DietmasterEngine.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"


@implementation MeasurePicker

@synthesize arry3,pickerRow3,measureIDs, selectedMeasureID,delegate;

- (instancetype)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    rowListArr = [[NSMutableArray alloc] init];
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
        
    }
    arry3 = [[NSMutableArray alloc] init];
    NSString *query = @"SELECT MeasureID, Description FROM Measure WHERE MeasureID < 10000  ORDER BY Description";
    FMResultSet *rs = [db executeQuery:query];
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        [arry3 addObject:dict];
        rowListArr = [[NSMutableArray alloc] initWithArray:[self filterObjectsByKeys:@"MeasureID" array:arry3]];
        arry3 = rowListArr;
    }

    selectedMeasureID = dietmasterEngine.selectedMeasureID;
    
    for (NSInteger i = 0; i <[measureIDs count]; i++) {
        NSString *string = [[measureIDs objectAtIndex:i] stringValue];
        if ([string isEqualToString:[selectedMeasureID stringValue]]){
            self.pickerRow3 = [NSNumber numberWithInteger:i];
            break;
        }
    }
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:arry3];
    arrayWithoutDuplicates = [orderedSet array];
    [pickerView selectRow:[self.pickerRow3 intValue] inComponent:0 animated:NO];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [arry3 count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:arry3];
    arrayWithoutDuplicates = [orderedSet array];
    
    return arry3[row][@"Description"];
}

- (IBAction)sendMeasure:(id) sender {
    if ([delegate respondsToSelector:@selector(didChooseMeasure:withName:)]) {
        [delegate didChooseMeasure:[arry3 objectAtIndex:[pickerView selectedRowInComponent:0]][@"MeasureID"]
                          withName:[arry3 objectAtIndex:[pickerView selectedRowInComponent:0]][@"Description"]];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelSaveMeasure:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSMutableArray *) filterObjectsByKeys:(NSString *) key array:(NSMutableArray *)array {
    NSMutableSet *tempValues = [[NSMutableSet alloc] init];
    NSMutableArray *ret = [NSMutableArray array];
    for(id obj in array) {
        if(! [tempValues containsObject:[obj valueForKey:key]]) {
            [tempValues addObject:[obj valueForKey:key]];
            [ret addObject:obj];
        }
    }
    return ret;
}
@end
