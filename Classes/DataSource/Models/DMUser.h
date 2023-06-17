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

@property (nonatomic, strong, readonly) NSNumber *userId;
@property (nonatomic, strong, readonly) NSString *userName;
@property (nonatomic, strong, readonly) NSString *email1;
@property (nonatomic, strong, readonly) NSString *email2;

@property (nonatomic, strong, readonly) NSNumber *companyId;
@property (nonatomic, strong, readonly) NSString *companyName;
@property (nonatomic, strong, readonly) NSString *mobileGraphicImageName;

@property (nonatomic, strong, readonly) NSString *firstName;
@property (nonatomic, strong, readonly) NSString *lastName;

@property (nonatomic, strong, readonly, nullable) NSDate *birthDate;
@property (nonatomic, strong, readonly) NSNumber *gender;
@property (nonatomic, strong, readonly) NSNumber *height;
@property (nonatomic, strong, readonly) NSNumber *lactating;

@property (nonatomic, strong, readonly) NSNumber *profession;

@property (nonatomic, strong, readonly) NSNumber *bodyType;
@property (nonatomic, strong, readonly) NSNumber *userBMR;
@property (nonatomic, strong, readonly) NSNumber *proteinRequirements;

@property (nonatomic, strong, readonly) NSNumber *goals;
@property (nonatomic, strong, readonly, nullable) NSDate *goalStartDate;
@property (nonatomic, strong, readonly) NSNumber *weightGoal;
@property (nonatomic, strong, readonly) NSNumber *goalRate;

@property (nonatomic, strong, readonly) NSNumber *carbRatio;
@property (nonatomic, strong, readonly) NSNumber *proteinRatio;
@property (nonatomic, strong, readonly) NSNumber *fatRatio;

@property (nonatomic, strong, readonly) NSString *hostName;

/// Designated initializer.
- (instancetype)initWithDictionary:(NSDictionary *)userDict NS_DESIGNATED_INITIALIZER;

/// User's birthdate as a string.
- (NSString *)birthDateString;

/// User's goal start date as a string.
- (NSString *)goalStartDateString;

@end

NS_ASSUME_NONNULL_END
