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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setTranslucent:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    DietmasterEngine *dietEngine = [DietmasterEngine sharedInstance];
    dbPath	= [dietEngine databasePath];
    
    if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
        NSString *query = @"SELECT CategoryID, Name FROM FoodCategory ORDER BY CategoryID";
        
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) ==SQLITE_OK) {
            arry3 = [[NSMutableArray alloc] init];
            categoryIDs = [[NSMutableArray alloc] init];
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                char *Name			= (char *) sqlite3_column_text(statement, 1);
                str_categoryName	= [[NSString alloc] initWithUTF8String:Name];
                num_categoryID		= [NSNumber numberWithInt:sqlite3_column_int(statement, 0)];
                
                [arry3 addObject:str_categoryName];
                [categoryIDs addObject:num_categoryID];
                
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(database);
    }
    
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
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
