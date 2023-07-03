//
//  witStepData.h
//  WalkItOut
//
//  Created by Matthew Faluotico on 12/12/13.
//  Copyright (c) 2013 Matthew Faluotico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMConstants.h"

/**
 *  Handles step data calculations and interaction with Apple Health.
 */
@interface StepData : NSObject

/// Conversions for steps.
- (double)stepsToMilesForSteps:(NSInteger)steps;
- (double)stepsToCaloriesForSteps:(NSInteger)steps;
- (double)stepsPerMileForSteps:(NSInteger)steps;

/// Checks for authorization to read Step Data. The block will return a True/False
/// status if authorization is granted or not.
- (void)checkHealthKitAuthorizationWithCompletionBlock:(completionBlockWithStatus)completionBlock;

@end
