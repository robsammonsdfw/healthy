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
    
- (id) init {
    self = [super init];
    
    if (self) {
        
        DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
        
        self.weight = [dietmasterEngine.currentWeight doubleValue];
        
        //DMLog(@"%ld",(long)self.weight);
        
        //double height = [dietmasterEngine.userHeight doubleValue];
        //int inch = 12;
        //double sum = height * inch;
        
        self.heightInches = [dietmasterEngine.userHeight doubleValue];
        //DMLog(@"%ld",(long)self.heightInches);
    }
    
    return self;
}
    
-(double) stepsToCalories: (NSInteger) steps{
    return [self stepsToMiles: steps] * ([self weight] * 0.57);
}
    
- (double) stepsToMiles: (NSInteger) steps {
    return steps / [self stepsPerMile: steps];
}
    
- (double) stepsPerMile: (NSInteger ) steps {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    
    int userGender = dietmasterEngine.userGender;
    
    if (userGender == 0){
        return MILES_INCHES / (0.413 * [self heightInches]);
    }
    else if (userGender == 1){
        return MILES_INCHES / (0.415 * [self heightInches]);
    }
    
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Male"]) // male
//    return MILES_INCHES / (0.415 * [self heightInches]);
//    else  // Female
//    return MILES_INCHES / (0.413 * [self heightInches]);
}
    
    @end
