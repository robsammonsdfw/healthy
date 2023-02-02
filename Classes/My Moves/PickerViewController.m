//
//  PickerViewController.m
//  MyMoves
//
//  Created by Samson  on 01/02/19.
//

#import "PickerViewController.h"
#import "MyMovesWebServices.h"

@interface PickerViewController ()<UIPickerViewDelegate,UIPickerViewDataSource,WSCategoryList>
{
    MyMovesWebServices *soapWebService;
}
@property (strong, nonatomic) IBOutlet UIPickerView *picker;

@end

@implementation PickerViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    soapWebService = [[MyMovesWebServices alloc] init];
    
    _picker.delegate = self;
    _picker.dataSource = self;
    
    
    if (([soapWebService loadFirstHeaderTable].count != 0) || ([soapWebService loadSecondHeaderTable].count) != 0)
    {
        if((_pickerData[0][@"Unit1ID"] == nil) || (_pickerData[0][@"Unit2ID"] == nil))
        {
            if([_pickerData[0]valueForKey:
                @"WorkoutCategoryName"] != (id)[NSNull null])
            {
                [_selectedBodyPartDel getSelectedBodyPart:_pickerData[0]];
                
            }
        }
    }
    else
    {
        
    }
    
    
    
}
- (void)viewWillAppear:(BOOL)animated
{
    if (([soapWebService loadFirstHeaderTable].count != 0) || ([soapWebService loadSecondHeaderTable].count) != 0)
    {
        if((_pickerData[0][@"Unit1ID"] != nil) || (_pickerData[0][@"Unit2ID"] != nil))
        {
            if([_pickerData[0]valueForKey: @"Tags"] != (id)[NSNull null])
            {
                [_selectedBodyPartDel getSelectedTagId:_pickerData[0]];
            }
        }
        else
        {
            if([[_pickerData objectAtIndex:0]valueForKey: @"Unit1ID"] != nil)
            {
                [_repsWeightDel getReps:[[_pickerData objectAtIndex:0]valueForKey: @"Unit1ID"]];
            }
            else if([[_pickerData objectAtIndex:0]valueForKey: @"Unit2ID"] != nil)
            {
                [_repsWeightDel getWeight:[[_pickerData objectAtIndex:0]valueForKey: @"Unit2ID"]];
            }
        }
    }
    else
    {
        
    }
    [_picker reloadAllComponents];
}
- (IBAction)dismissOnTap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)okButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)dealloc {
    [_picker release];
    [_pickerData release];
    [super dealloc];
}

- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSArray *LoadSetsHeader = @[@"None", @"Feet", @"Kilograms", @"Kilometers", @"KilometerPerHour",@"Meters", @"Miles", @"MilesPerHour", @"Minutes", @"Pounds", @"Repetitions", @"RestSeconds", @"Seconds", @"Yards"];
    
//    return LoadSetsHeader.count;
    if (([soapWebService loadFirstHeaderTable].count != 0) || ([soapWebService loadSecondHeaderTable].count) != 0)
    {
        if(([[_pickerData objectAtIndex:component]valueForKey: @"Unit1ID"] != nil) || ([[_pickerData objectAtIndex:component]valueForKey: @"Unit2ID"] != nil))
        {
            return [LoadSetsHeader count];
        }
        else if ([[_pickerData objectAtIndex:component]valueForKey: @"WorkoutCategoryName"] != nil)
        {
            return [_pickerData count];
        }
        else if ([[_pickerData objectAtIndex:component]valueForKey: @"Tags"] != nil)
        {
            _data = [soapWebService filterObjectsByKeys:@"Tags" array:_pickerData];
            return [_data count];
        }
    }
    else if ([[_pickerData objectAtIndex:component]valueForKey: @"WorkoutCategoryName"] != nil)
    {
        return [_pickerData count];
    }
    else if ([[_pickerData objectAtIndex:component]valueForKey: @"Tags"] != nil)
    {
        _data = [soapWebService filterObjectsByKeys:@"Tags" array:_pickerData];
        return [_data count];
    }
    else
    {
        return [LoadSetsHeader count];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSArray *LoadSetsHeader = @[@"None", @"Feet", @"Kilograms", @"Kilometers", @"KilometerPerHour",@"Meters", @"Miles", @"MilesPerHour", @"Minutes", @"Pounds", @"Repetitions", @"RestSeconds", @"Seconds", @"Yards"];
    
    
    if (([soapWebService loadFirstHeaderTable].count != 0) || ([soapWebService loadSecondHeaderTable].count) != 0)
    {
        if(([[_pickerData objectAtIndex:component]valueForKey: @"Unit1ID"] != nil) || ([[_pickerData objectAtIndex:component]valueForKey: @"Unit2ID"] != nil))
        {
            return  [LoadSetsHeader objectAtIndex:row];
        }
        else
        {
            if([[_pickerData objectAtIndex:row]valueForKey: @"WorkoutCategoryName"] != nil)
            {
                return [[_pickerData objectAtIndex:row]valueForKey: @"WorkoutCategoryName"];
            }
            else if([[_pickerData objectAtIndex:row]valueForKey: @"Tags"] != nil)
            {
                _data = [soapWebService filterObjectsByKeys:@"Tags" array:_pickerData];
                return [[_data objectAtIndex:row]valueForKey: @"Tags"];
            }
        }
    }
    else
    {
        if([[_pickerData objectAtIndex:row]valueForKey: @"WorkoutCategoryName"] != nil)
        {
            return [[_pickerData objectAtIndex:row]valueForKey: @"WorkoutCategoryName"];
        }
        else if([[_pickerData objectAtIndex:row]valueForKey: @"Tags"] != nil)
        {
            _data = [soapWebService filterObjectsByKeys:@"Tags" array:_pickerData];
            return [[_data objectAtIndex:row]valueForKey: @"Tags"];
        }
        else
        {
            return [LoadSetsHeader objectAtIndex:row];
        }
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSArray *LoadSetsHeader = @[@"None", @"Feet", @"Kilograms", @"Kilometers", @"KilometerPerHour",@"Meters", @"Miles", @"MilesPerHour", @"Minutes", @"Pounds", @"Repetitions", @"RestSeconds", @"Seconds", @"Yards"];
    
    if (([soapWebService loadFirstHeaderTable].count != 0) || ([soapWebService loadSecondHeaderTable].count) != 0)
    {
        if(_pickerData[0][@"Unit1ID"] != nil)
        {
            [_repsWeightDel getReps:LoadSetsHeader[row]];
            [soapWebService updateFirstHeaderValue:row ParentUniqueID:_parentUniqueId];
            
        }
        else if(_pickerData[0][@"Unit2ID"] != nil)
        {
            [_repsWeightDel getWeight:LoadSetsHeader[row]];
            [soapWebService updateSecondHeaderValue:row ParentUniqueID:_parentUniqueId];
        }
        else if([[_pickerData objectAtIndex:row]valueForKey: @"WorkoutCategoryName"] != nil)
        {
            [_selectedBodyPartDel getSelectedBodyPart:[_pickerData objectAtIndex:row]];
        }
        else if([[_pickerData objectAtIndex:row]valueForKey: @"Tags"] != nil)
        {
            _data = [soapWebService filterObjectsByKeys:@"Tags" array:_pickerData];

            [_selectedBodyPartDel getSelectedTagId:[_data objectAtIndex:row]];
        }
    }
    else
    {
        if([[_pickerData objectAtIndex:row]valueForKey: @"WorkoutCategoryName"] != nil)
        {
            [_selectedBodyPartDel getSelectedBodyPart:[_pickerData objectAtIndex:row]];
        }
        else if([[_pickerData objectAtIndex:row]valueForKey: @"Tags"] != nil)
        {
            _data = [soapWebService filterObjectsByKeys:@"Tags" array:_pickerData];
            [_selectedBodyPartDel getSelectedTagId:[_data objectAtIndex:row]];
        }
        else if (_secondColumn == YES)
        {
            [_repsWeightDel getReps:LoadSetsHeader[row]];
            [soapWebService updateFirstHeaderValue:row ParentUniqueID:_parentUniqueId];
        }
        else if (_secondColumn == NO)
        {
            [_repsWeightDel getWeight:LoadSetsHeader[row]];
            [soapWebService updateSecondHeaderValue:row ParentUniqueID:_parentUniqueId];
            
        }
    }
    
    
//    {
//
//        if(_pickerData[0][@"Unit1ID"] != nil)
//        {
//            [_repsWeightDel getReps:LoadSetsHeader[row]];
//            [soapWebService updateFirstHeaderValue:row ParentUniqueID:_parentUniqueId];
//
//        }
//        else if(_pickerData[0][@"Unit2ID"] != nil)
//        {
//            [_repsWeightDel getWeight:LoadSetsHeader[row]];
//            [soapWebService updateSecondHeaderValue:row ParentUniqueID:_parentUniqueId];
//        }
//        else
//        {
//            if([[_pickerData objectAtIndex:row]valueForKey: @"WorkoutCategoryName"] != nil)
//            {
//                [_selectedBodyPartDel getSelectedBodyPart:[_pickerData objectAtIndex:row]];
//            }
//            else if([[_pickerData objectAtIndex:row]valueForKey: @"Tags"] != nil)
//            {
//                [_selectedBodyPartDel getSelectedTagId:[_pickerData objectAtIndex:row]];
//            }
//        }
//    }
//    else
//    {
//        [_repsWeightDel getWeight:LoadSetsHeader[row]];
//    }

}

- (void)getCategoryListFailed:(NSString *)failedMessage {
    
}

- (void)getCategoryListFinished:(NSDictionary *)responseArray {
    [_pickerData addObjectsFromArray:responseArray[@"CategoryList"]];
    [_picker reloadAllComponents];
}

@end
