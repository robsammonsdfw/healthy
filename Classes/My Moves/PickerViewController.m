//
//  PickerViewController.m
//  MyMoves
//
//  Created by Samson  on 01/02/19.
//

#import "PickerViewController.h"
#import "MyMovesWebServices.h"
#import "DMMoveTag.h"
#import "DMMoveCategory.h"

@interface PickerViewController () <UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) IBOutlet UIPickerView *picker;
@property (nonatomic, strong) MyMovesWebServices *soapWebService;
@end

@implementation PickerViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _dataType = DMPickerDataTypeUnknown;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.soapWebService = [[MyMovesWebServices alloc] init];
    
    _picker.delegate = self;
    _picker.dataSource = self;
    
    if (self.dataType == DMPickerDataTypeUnknown) {
        if (([self.soapWebService loadFirstHeaderTable].count != 0) || ([self.soapWebService loadSecondHeaderTable].count) != 0)
        {
            if((self.pickerData[0][@"Unit1ID"] == nil) || (self.pickerData[0][@"Unit2ID"] == nil))
            {
                if([self.pickerData[0]valueForKey:
                    @"WorkoutCategoryName"] != (id)[NSNull null])
                {
                    [_selectedBodyPartDel getSelectedBodyPart:self.pickerData[0]];
                    
                }
            }
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.dataType == DMPickerDataTypeUnknown) {
        if (([self.soapWebService loadFirstHeaderTable].count != 0) || ([self.soapWebService loadSecondHeaderTable].count) != 0)
        {
            if((self.pickerData[0][@"Unit1ID"] != nil) || (self.pickerData[0][@"Unit2ID"] != nil))
            {
                if([self.pickerData[0]valueForKey: @"Tags"] != (id)[NSNull null])
                {
                    [_selectedBodyPartDel getSelectedTagId:self.pickerData[0]];
                }
            }
            else
            {
                if([[self.pickerData objectAtIndex:0]valueForKey: @"Unit1ID"] != nil)
                {
                    [_repsWeightDel getReps:[[self.pickerData objectAtIndex:0]valueForKey: @"Unit1ID"]];
                }
                else if([[self.pickerData objectAtIndex:0]valueForKey: @"Unit2ID"] != nil)
                {
                    [_repsWeightDel getWeight:[[self.pickerData objectAtIndex:0]valueForKey: @"Unit2ID"]];
                }
            }
        }
    }

    [_picker reloadAllComponents];
}

- (IBAction)dismissOnTap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)okButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSArray *LoadSetsHeader = @[@"None", @"Feet", @"Kilograms", @"Kilometers", @"KilometerPerHour",@"Meters", @"Miles", @"MilesPerHour", @"Minutes", @"Pounds", @"Repetitions", @"RestSeconds", @"Seconds", @"Yards"];
    
    if (self.dataType == DMPickerDataTypeMoveTags || self.dataType == DMPickerDataTypeMoveCategories) {
        return self.pickerData.count;
    }
    
    if (([self.soapWebService loadFirstHeaderTable].count != 0) || ([self.soapWebService loadSecondHeaderTable].count) != 0) {
        if(([[self.pickerData objectAtIndex:component]valueForKey: @"Unit1ID"] != nil) || ([[self.pickerData objectAtIndex:component]valueForKey: @"Unit2ID"] != nil)) {
            return [LoadSetsHeader count];
        }
        else if ([[self.pickerData objectAtIndex:component]valueForKey: @"WorkoutCategoryName"] != nil) {
            return [self.pickerData count];
        }
        else if ([[self.pickerData objectAtIndex:component]valueForKey: @"Tags"] != nil) {
            _data = [self.soapWebService filterObjectsByKeys:@"Tags" array:self.pickerData];
            return [_data count];
        }
    }
    else if ([[self.pickerData objectAtIndex:component]valueForKey: @"WorkoutCategoryName"] != nil) {
        return [self.pickerData count];
    }
    else if ([[self.pickerData objectAtIndex:component]valueForKey: @"Tags"] != nil) {
        _data = [self.soapWebService filterObjectsByKeys:@"Tags" array:self.pickerData];
        return [_data count];
    } else {
        return [LoadSetsHeader count];
    }
    
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSArray *LoadSetsHeader = @[@"None", @"Feet", @"Kilograms", @"Kilometers", @"KilometerPerHour",@"Meters", @"Miles", @"MilesPerHour", @"Minutes", @"Pounds", @"Repetitions", @"RestSeconds", @"Seconds", @"Yards"];
    
    if (self.dataType == DMPickerDataTypeMoveTags) {
        DMMoveTag *tag = self.pickerData[row];
        return tag.name;
    }
    
    if (self.dataType == DMPickerDataTypeMoveCategories) {
        DMMoveCategory *category = self.pickerData[row];
        return category.name;
    }
    
    if (([self.soapWebService loadFirstHeaderTable].count != 0) || ([self.soapWebService loadSecondHeaderTable].count) != 0)
    {
        if(([[self.pickerData objectAtIndex:component]valueForKey: @"Unit1ID"] != nil) || ([[self.pickerData objectAtIndex:component]valueForKey: @"Unit2ID"] != nil))
        {
            return  [LoadSetsHeader objectAtIndex:row];
        }
        else
        {
            if([[self.pickerData objectAtIndex:row]valueForKey: @"WorkoutCategoryName"] != nil)
            {
                return [[self.pickerData objectAtIndex:row]valueForKey: @"WorkoutCategoryName"];
            }
            else if([[self.pickerData objectAtIndex:row]valueForKey: @"Tags"] != nil)
            {
                _data = [self.soapWebService filterObjectsByKeys:@"Tags" array:self.pickerData];
                return [[_data objectAtIndex:row]valueForKey: @"Tags"];
            }
        }
    }
    else
    {
        if([[self.pickerData objectAtIndex:row]valueForKey: @"WorkoutCategoryName"] != nil)
        {
            return [[self.pickerData objectAtIndex:row]valueForKey: @"WorkoutCategoryName"];
        }
        else if([[self.pickerData objectAtIndex:row]valueForKey: @"Tags"] != nil)
        {
            _data = [self.soapWebService filterObjectsByKeys:@"Tags" array:self.pickerData];
            return [[_data objectAtIndex:row]valueForKey: @"Tags"];
        }
        else
        {
            return [LoadSetsHeader objectAtIndex:row];
        }
    }
    
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSArray *LoadSetsHeader = @[@"None", @"Feet", @"Kilograms", @"Kilometers", @"KilometerPerHour",@"Meters", @"Miles", @"MilesPerHour", @"Minutes", @"Pounds", @"Repetitions", @"RestSeconds", @"Seconds", @"Yards"];
    
    if (self.dataType == DMPickerDataTypeMoveTags) {
        DMMoveTag *tag = self.pickerData[row];
        if ([self.selectedBodyPartDel respondsToSelector:@selector(getSelectedTagId:)]) {
            //[self.selectedBodyPartDel getSelectedTagId:tag.tagId];
        }
        return;
    }
    
    if (self.dataType == DMPickerDataTypeMoveCategories) {
        DMMoveCategory *category = self.pickerData[row];
        if ([self.selectedBodyPartDel respondsToSelector:@selector(getSelectedBodyPart:)]) {
            //[self.selectedBodyPartDel getSelectedBodyPart:category.categoryId];
        }
        return;
    }
    
    if (([self.soapWebService loadFirstHeaderTable].count != 0) || ([self.soapWebService loadSecondHeaderTable].count) != 0)
    {
        if(self.pickerData[0][@"Unit1ID"] != nil)
        {
            [_repsWeightDel getReps:LoadSetsHeader[row]];
            [self.soapWebService updateFirstHeaderValue:row ParentUniqueID:_parentUniqueId];
            
        }
        else if(self.pickerData[0][@"Unit2ID"] != nil)
        {
            [_repsWeightDel getWeight:LoadSetsHeader[row]];
            [self.soapWebService updateSecondHeaderValue:row ParentUniqueID:_parentUniqueId];
        }
        else if([[self.pickerData objectAtIndex:row]valueForKey: @"WorkoutCategoryName"] != nil)
        {
            [_selectedBodyPartDel getSelectedBodyPart:[self.pickerData objectAtIndex:row]];
        }
        else if([[self.pickerData objectAtIndex:row]valueForKey: @"Tags"] != nil)
        {
            _data = [self.soapWebService filterObjectsByKeys:@"Tags" array:self.pickerData];

            [_selectedBodyPartDel getSelectedTagId:[_data objectAtIndex:row]];
        }
    }
    else
    {
        if([[self.pickerData objectAtIndex:row]valueForKey: @"WorkoutCategoryName"] != nil)
        {
            [_selectedBodyPartDel getSelectedBodyPart:[self.pickerData objectAtIndex:row]];
        }
        else if([[self.pickerData objectAtIndex:row]valueForKey: @"Tags"] != nil)
        {
            _data = [self.soapWebService filterObjectsByKeys:@"Tags" array:self.pickerData];
            [_selectedBodyPartDel getSelectedTagId:[_data objectAtIndex:row]];
        }
        else if (_secondColumn == YES)
        {
            [_repsWeightDel getReps:LoadSetsHeader[row]];
            [self.soapWebService updateFirstHeaderValue:row ParentUniqueID:_parentUniqueId];
        }
        else if (_secondColumn == NO)
        {
            [_repsWeightDel getWeight:LoadSetsHeader[row]];
            [self.soapWebService updateSecondHeaderValue:row ParentUniqueID:_parentUniqueId];
            
        }
    }
}

- (void)getCategoryListFailed:(NSString *)failedMessage {
    
}

- (void)getCategoryListFinished:(NSDictionary *)responseArray {
    self.pickerData = [responseArray[@"CategoryList"] copy];
    [_picker reloadAllComponents];
}

@end
