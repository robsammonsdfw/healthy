//
//  DMUser.h
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/15/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// The goal of the user for their weight, e.g. "Weight Loss".
typedef NS_ENUM(NSUInteger, DMUserWeightGoalType) {
    DMUserWeightGoalTypeLoss = 0,
    DMUserWeightGoalTypeMaintain,
    DMUserWeightGoalTypeGain
};

/// Represents a "User" of DMG.
@interface DMUser : NSObject <NSSecureCoding>

@property (nonatomic, strong, readonly) NSNumber *userId;
@property (nonatomic, strong, readonly) NSString *userName;
@property (nonatomic, strong, readonly) NSString *authToken;
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

/// NOTE: The ratios need to be divided by 100.
@property (nonatomic, strong, readonly) NSNumber *carbRatio;
@property (nonatomic, strong, readonly) NSNumber *proteinRatio;
@property (nonatomic, strong, readonly) NSNumber *fatRatio;

@property (nonatomic, strong, readonly) NSString *hostName;

@property (nonatomic, readonly) DMUserWeightGoalType weightGoalType;

/// If true, add tracked calories into burned total to be included in net calculation.
@property (nonatomic) BOOL useCalorieTrackingDevice;
/// If burned calories from exercise should be added into the total calories
/// allowed for a day. (aka If I burn 100 calories running, I can eat 100 calories more.)
@property (nonatomic) BOOL useBurnedCalories;
/// If the user wishes to sync with Apple Health.
@property (nonatomic) BOOL enableAppleHealthSync;

/// Designated initializer.
- (instancetype)initWithDictionary:(NSDictionary *)userDict updateDetails:(BOOL)updateDetails NS_DESIGNATED_INITIALIZER;

/// User's birthdate as a string.
- (NSString *)birthDateString;

/// User's goal start date as a string.
- (NSString *)goalStartDateString;

/// Returns a localized string (kg or lbs) of the user's weight goal.
- (NSString *)weightGoalLocalizedString;

/// Returns the user's weight goal type as a string.
/// NOTE: This will return a past tense string, e.g. "Lost" or "Gained".
- (NSString *)weightGoalTypeAsString;

/// Updates the users details:
/// WeightGoal, Height, Goals, BirthDate, Profession, BodyType, etc.
- (void)updateUserDetails:(NSDictionary *)userDict;

@end

NS_ASSUME_NONNULL_END
