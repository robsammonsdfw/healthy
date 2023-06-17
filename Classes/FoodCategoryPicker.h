//
//  FoodCategoryPicker.h
//  DietMasterGo
//
//  Created by DietMaster on 12/6/11.
//  Copyright 2011 Lifestyles Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@protocol FoodCategoryDelegate <NSObject>
-(void)didChooseCategory:(NSString *)chosenID withName:(NSString *)chosenName;
@end

@class AppDelegate;

@interface FoodCategoryPicker : UIViewController {
	AppDelegate *mainDelegate;
	sqlite3 *database;
	NSString *dbPath;
	IBOutlet UIPickerView *pickerView;
	NSString *str_categoryName;
	NSNumber *num_categoryID;
	NSNumber *pickerRow3;
	NSMutableArray *arry3;
	NSMutableArray *categoryIDs;
	NSNumber *selectedCategoryID;
}

-(IBAction) sendNewDate:(id) sender;
-(IBAction)cancelSaveCategory:(id)sender;

@property (nonatomic, strong) AppDelegate *mainDelegate;
@property (nonatomic, strong) NSString *str_categoryName;
@property (nonatomic, strong) NSNumber *num_categoryID;
@property (nonatomic, strong) NSNumber *pickerRow3;
@property (nonatomic, strong) NSMutableArray *arry3;
@property (nonatomic, strong) NSMutableArray *categoryIDs;
@property (nonatomic, strong) NSNumber *selectedCategoryID;
@property (nonatomic, weak) id<FoodCategoryDelegate> delegate;



@end


