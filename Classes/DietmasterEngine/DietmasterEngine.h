//
//  DietmasterEngine.h
//  DietMasterGo
//
//  Created by Henry Kirk on 2/4/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMDataFetcher.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "DMConstants.h"

@class DMMessage;
@class DMUser;

@interface DietmasterEngine : NSObject {
    
    NSMutableDictionary *exerciseSelectedDict;
    // For Food Log - "Edit" or "Save" functionality
    NSString *taskMode;
    
    NSDate *dateSelected;
    NSString *dateSelectedFormatted;
    
    NSNumber *selectedMealID; // selected ID of meal working on.
    NSNumber *selectedCategoryID; // for editing My Foods.
    NSNumber *selectedMeasureID; // for editing My Foods.
        
    // Meal Plan
    NSMutableArray *mealPlanArray;

    // For detail view
    BOOL isMealPlanItem;
    NSMutableDictionary *mealPlanItemToExchangeDict;
    int indexOfItemToExchange;
    int selectedMealPlanID;
    BOOL didInsertNewFood;
    // Grocery List
    NSMutableArray *groceryArray;
}

@property (nonatomic, strong) NSMutableDictionary *exerciseSelectedDict;

@property (nonatomic, strong) NSString *taskMode;
@property (nonatomic, strong) NSDate *dateSelected;
@property (nonatomic, strong) NSString *dateSelectedFormatted;
@property (nonatomic, strong) NSNumber *selectedMealID;

@property (nonatomic, strong) NSNumber *selectedCategoryID;
@property (nonatomic, strong) NSNumber *selectedMeasureID;

// Meal Plan
@property (nonatomic, strong) NSMutableArray *mealPlanArray;
@property (nonatomic) BOOL isMealPlanItem;
@property (nonatomic, strong) NSMutableDictionary *mealPlanItemToExchangeDict;
@property (nonatomic) int indexOfItemToExchange;
@property (nonatomic) int selectedMealPlanID;
@property (nonatomic) BOOL didInsertNewFood;

+ (instancetype)sharedInstance;

@end
