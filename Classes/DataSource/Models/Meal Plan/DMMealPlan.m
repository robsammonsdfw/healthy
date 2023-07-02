//
//  DMMealPlan.m
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 7/1/23.
//

#import "DMMealPlan.h"
#import "DMMealPlanItem.h"

@interface DMMealPlan()
@property (nonatomic, strong, readwrite) NSNumber *mealId;
@property (nonatomic, strong, readwrite) NSNumber *mealTypeId;
@property (nonatomic, strong, readwrite) NSString *mealName;

@property (nonatomic, strong) NSDictionary *mealNotesDict;
@property (nonatomic, strong) NSArray *mealItemsArray;

@end

@implementation DMMealPlan

- (instancetype)init {
    return [self initWithDictionary:@{}];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictonary {
    self = [super init];
    if (self) {
        _mealId = dictonary[@"MealID"];
        _mealTypeId = dictonary[@"MealTypeID"];
        _mealName = dictonary[@"MealName"];
        
        _mealNotesDict = dictonary[@"MealNotes"];
        _mealItemsArray = dictonary[@"MealItems"];
    }
    return self;
}

- (NSArray<DMMealPlanItem *> *)getMealItemsForMealCode:(DMLogMealCode)mealCode {
    NSMutableArray *results = [NSMutableArray array];
    for (NSDictionary *mealItem in [self.mealItemsArray copy]) {
        if ([mealItem[@"MealCode"] intValue] == mealCode) {
            DMMealPlanItem *item = [[DMMealPlanItem alloc] initWithDictionary:mealItem];
            [results addObject:item];
        }
    }
    return [results copy];
}

- (NSArray<DMMealPlanItem *> *)getAllMealItems {
    NSMutableArray *results = [NSMutableArray array];
    for (NSDictionary *mealItem in [self.mealItemsArray copy]) {
        DMMealPlanItem *item = [[DMMealPlanItem alloc] initWithDictionary:mealItem];
        [results addObject:item];
    }
    return [results copy];
}

- (NSString *)getMealNoteForMealCode:(DMLogMealCode)mealCode {
    for (NSDictionary *noteDict in [self.mealNotesDict copy]) {
        if ([noteDict[@"MealCode"] intValue] == mealCode) {
            return [noteDict[@"MealNote"] copy];
        }
    }
    return nil;
}

- (void)removeMealPlanItem:(DMMealPlanItem *)mealPlanItem inMealCode:(DMLogMealCode)mealCode {
    NSMutableArray *results = [NSMutableArray array];
    for (NSDictionary *mealItem in [self.mealItemsArray copy]) {
        // Look for the exact item.
        if ([mealItem[@"MealCode"] intValue] == mealCode &&
            [mealItem[@"FoodID"] isEqual:mealPlanItem.foodId] &&
            [mealItem[@"NumberOfServings"] isEqual:mealPlanItem.numberOfServings] &&
            [mealItem[@"MeasureID"] isEqual:mealPlanItem.measureId]) {
            continue; // Skip.
        }
        [results addObject:mealItem];
    }
    // Replace.
    self.mealItemsArray = [results copy];
}

- (NSString *)description {
    NSString *base = [super description];
    return [NSString stringWithFormat:@"%@: %@", base, [self listPropertiesAsString]];
}

@end
