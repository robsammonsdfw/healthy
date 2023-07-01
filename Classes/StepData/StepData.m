//
//  witStepData.m
//  WalkItOut
//
//  Created by Matthew Faluotico on 12/12/13.
//  Copyright (c) 2013 Matthew Faluotico. All rights reserved.
//

#import "StepData.h"
#import <HealthKit/HealthKit.h>

#define MILES_INCHES 63360

@interface StepData()
@property (nonatomic, strong) HKHealthStore *healthStore;
@end

@implementation StepData
    
- (instancetype)init {
    self = [super init];
    if (self) {
        _healthStore = [[HKHealthStore alloc] init];
    }
    return self;
}
    
- (double)stepsToCaloriesForSteps:(NSInteger)steps {
    DayDataProvider *dayProvider = [DayDataProvider sharedInstance];
    return [self stepsToMilesForSteps: steps] * ([dayProvider getCurrentWeight].doubleValue * 0.57);
}
    
- (double)stepsToMilesForSteps:(NSInteger)steps {
    return steps / [self stepsPerMileForSteps: steps];
}
    
- (double)stepsPerMileForSteps:(NSInteger)steps {
    DMUser* currentUser = [[DMAuthManager sharedInstance] loggedInUser];
    
    int userGender = currentUser.gender.intValue;
    
    if (userGender == 0){
        return MILES_INCHES / (0.413 * currentUser.height.doubleValue);
    } else if (userGender == 1){
        return MILES_INCHES / (0.415 * currentUser.height.doubleValue);
    }

    return 0.0;
}

#pragma mark - Apple Health
    
- (void)checkHealthKitAuthorizationWithCompletionBlock:(completionBlockWithStatus)completionBlock {
    if ([HKHealthStore isHealthDataAvailable] == NO) {
        if (completionBlock) {
            NSError *error = [DMGUtilities errorWithMessage:@"Apple Health data not available." code:777];
            completionBlock(NO, error);
        }
        return;
    }

    HKObjectType *type = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    [self.healthStore getRequestStatusForAuthorizationToShareTypes:[NSSet setWithObject:type]
                                                         readTypes:[NSSet setWithObject:type]
                                                        completion:^(HKAuthorizationRequestStatus requestStatus, NSError *error) {
        if (requestStatus == HKAuthorizationRequestStatusShouldRequest) {
            [self requestPermissionWithCompletionBlock:completionBlock];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(requestStatus == HKAuthorizationRequestStatusUnnecessary, error);
                }
            });
        }
    }];
}

- (void)requestPermissionWithCompletionBlock:(completionBlockWithStatus)completionBlock {
    HKObjectType *type = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    [self.healthStore requestAuthorizationToShareTypes:[NSSet setWithObject:type]
                                             readTypes:[NSSet setWithObject:type]
                                            completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(success, error);
            }
        });
    }];
}

@end
