//
//  DMMealPlanItem.m
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 7/1/23.
//

#import "DMMealPlanItem.h"

@interface DMMealPlanItem()
@property (nonatomic, strong, readwrite) NSNumber *foodId;
@property (nonatomic, strong, readwrite) NSNumber *foodURL;
@property (nonatomic, readwrite) DMLogMealCode mealCode;
@property (nonatomic, strong, readwrite) NSNumber *measureId;
@property (nonatomic, strong, readwrite) NSNumber *numberOfServings;
@property (nonatomic, strong, readwrite) NSNumber *recipeId;
@end

@implementation DMMealPlanItem

- (instancetype)init {
    return [self initWithDictionary:@{}];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictonary {
    self = [super init];
    if (self) {
        _foodId = dictonary[@"FoodID"];
        _foodURL = dictonary[@"FoodURL"];
        _mealCode = [dictonary[@"MealCode"] intValue];
        _measureId = dictonary[@"MeasureID"];
        _numberOfServings = dictonary[@"NumberOfServings"];
        _recipeId = dictonary[@"RecipeID"];
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    return @{ @"FoodID" : self.foodId,
              @"FoodURL" : self.foodURL,
              @"MealCode" : @(self.mealCode),
              @"MeasureID" : self.measureId,
              @"NumberOfServings" : self.numberOfServings,
              @"RecipeID" : self.recipeId
    };
}

- (NSString *)description {
    NSString *base = [super description];
    return [NSString stringWithFormat:@"%@: %@", base, [self listPropertiesAsString]];
}

@end
