//
//  Log_Add.h
//  DietMasterGo
//
//  Created by Andrew Moffitt on 1/7/11.
//  Copyright 2011 AE Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DietmasterEngine.h"

@interface Log_Add : UIViewController {

	IBOutlet UITableView *tblLogAdd;
	
	NSDate *date_currentDate;
	NSNumber *int_mealID;
	
	NSArray *arryMeals;
	//NSArray *arryMeals_id;
	NSArray *arryExercise;
	
}

@property (nonatomic, retain) NSDate *date_currentDate;
@property (nonatomic, retain) NSNumber *int_mealID;

@end
