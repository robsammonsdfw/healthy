//
//  witStepData.m
//  WalkItOut
//
//  Created by Matthew Faluotico on 12/12/13.
//  Copyright (c) 2013 Matthew Faluotico. All rights reserved.
//

#import "StepData.h"

#define MILES_INCHES 63360

@implementation StepData
    
- (instancetype)init {
    self = [super init];
    return self;
}
    
- (double)stepsToCalories:(NSInteger)steps {
    DayDataProvider *dayProvider = [DayDataProvider sharedInstance];
    return [self stepsToMiles: steps] * ([dayProvider getCurrentWeight].doubleValue * 0.57);
}
    
- (double)stepsToMiles:(NSInteger)steps {
    return steps / [self stepsPerMile: steps];
}
    
- (double)stepsPerMile:(NSInteger)steps {
    DMUser* currentUser = [[DMAuthManager sharedInstance] loggedInUser];
    
    int userGender = currentUser.gender.intValue;
    
    if (userGender == 0){
        return MILES_INCHES / (0.413 * currentUser.height.doubleValue);
    } else if (userGender == 1){
        return MILES_INCHES / (0.415 * currentUser.height.doubleValue);
    }

    return 0.0;
}
    
@end
