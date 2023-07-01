//
//  FoodCategoryPicker.m
//  DietMasterGo
//
//  Created by DietMaster on 12/6/11.
//  Copyright 2011 Lifestyles Technologies, Inc. All rights reserved.
//

#import "FoodCategoryPicker.h"
#import "DietmasterEngine.h"

@implementation FoodCategoryPicker

@synthesize mainDelegate;
@synthesize arry3,str_categoryName,num_categoryID,pickerRow3,categoryIDs, selectedCategoryID,delegate;

- (instancetype)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setTranslucent:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    DietmasterEngine *dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [DMDatabaseUtilities database];
    if (![db open]) {
        DMLog(@"Could not open db.");
    }

    NSString *query = @"SELECT CategoryID, Name FROM FoodCategory ORDER BY CategoryID";
    arry3 = [[NSMutableArray alloc] init];
    categoryIDs = [[NSMutableArray alloc] init];
    
    FMResultSet *rs = [db executeQuery:query];
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        str_categoryName = dict[@"Name"];
        num_categoryID = dict[@"CategoryID"];
        [arry3 addObject:str_categoryName];
        [categoryIDs addObject:num_categoryID];
    }
    
    selectedCategoryID = dietmasterEngine.selectedCategoryID;
    
    for (int i = 0; i <[categoryIDs count]; i++) {
        NSString *string = [[categoryIDs objectAtIndex:i] stringValue];
        if ([string isEqualToString:[selectedCategoryID stringValue]]){
            self.pickerRow3 = [NSNumber numberWithInt:i];
            break;
        }
    }
    
    [pickerView selectRow:[self.pickerRow3 intValue] inComponent:0 animated:YES];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [arry3 count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [arry3  objectAtIndex:row];
}

- (IBAction) sendNewDate:(id) sender {
    [delegate didChooseCategory:[categoryIDs objectAtIndex:[pickerView selectedRowInComponent:0]] withName:[arry3 objectAtIndex:[pickerView selectedRowInComponent:0]]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelSaveCategory:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
