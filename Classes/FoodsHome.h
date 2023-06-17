//
//  FoodsHome.h
//  DietMasterGo
//
//  Created by Andrew Moffitt on 3/1/11.
//  Copyright 2011 AE Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DietmasterEngine.h"

@interface FoodsHome : UIViewController {
	IBOutlet UITableView *tblFoodsHome;

	NSDate *date_currentDate;
	NSNumber *int_mealID;
	
	NSArray *arrySearch;
	NSArray *arryOptions;
	NSArray *arrayFavoriteMeals;
}

@property (nonatomic, strong) NSDate *date_currentDate;
@property (nonatomic, strong) NSNumber *int_mealID;

@end
