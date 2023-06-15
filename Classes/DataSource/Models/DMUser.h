//
//  DMUser.h
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/15/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Represents a "User" of DMG.
@interface DMUser : NSObject

@property (nonatomic, strong, nullable) NSDate *birthDate;
@property (nonatomic, strong) NSNumber *gender;
@property (nonatomic, strong) NSNumber *height;
@property (nonatomic, strong) NSNumber *lactating;

@property (nonatomic, strong) NSNumber *profession;

@property (nonatomic, strong) NSNumber *bodyType;
@property (nonatomic, strong) NSNumber *userBMR;
@property (nonatomic, strong) NSNumber *proteinRequirements;

@property (nonatomic, strong) NSNumber *goals;
@property (nonatomic, strong, nullable) NSDate *goalStartDate;
@property (nonatomic, strong) NSNumber *weightGoal;
@property (nonatomic, strong) NSNumber *goalRate;

@property (nonatomic, strong) NSNumber *carbRatio;
@property (nonatomic, strong) NSNumber *proteinRatio;
@property (nonatomic, strong) NSNumber *fatRatio;

@property (nonatomic, strong) NSString *hostName;

/// Designated initializer.
- (instancetype)initWithDictionary:(NSDictionary *)userDict NS_DESIGNATED_INITIALIZER;

/// User's birthdate as a string.
- (NSString *)birthDateString;

/// User's goal start date as a string.
- (NSString *)goalStartDateString;

@end

NS_ASSUME_NONNULL_END
