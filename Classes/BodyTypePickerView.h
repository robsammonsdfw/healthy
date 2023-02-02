//
//  BodyTypePickerView.h
//  DietMasterGo
//
//  Created by DietMaster on 11/4/11.
//  Copyright 2011 Lifestyles Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "viewData.h"

@class AppDelegate;

@interface BodyTypePickerView : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>  {

	IBOutlet UIPickerView *bodyTypePicker;
	NSArray *bodyTypePickerData;
	NSString *dbPath;
	NSString *sourceName;
	
	sqlite3 *database;
	viewData *apassedData;
}

-(id) initWithText:(NSString *)text passedData:(viewData *)somePassedData;

@property (nonatomic,retain) AppDelegate *mainDelegate;
@property (nonatomic,retain) UIPickerView *bodyTypePicker;
@property (nonatomic,retain) NSArray *bodyTypePickerData;
@property (nonatomic,retain) viewData *apassedData;
@property (nonatomic,retain) NSString *sourceName;

-(IBAction)saveBodyType:(id)sender;

@end
