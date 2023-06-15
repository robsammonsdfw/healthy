//
//  DMFood.h
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/15/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Represents a food item in the database.
@interface DMFood : NSObject

@property (nonatomic, strong, readonly) NSNumber *foodKey;
@property (nonatomic, strong, readonly) NSNumber *foodId;
@property (nonatomic, strong, readonly) NSNumber *userId;
@property (nonatomic, strong, readonly) NSNumber *companyId;
@property (nonatomic, strong, readonly) NSNumber *measureId;
@property (nonatomic, strong, readonly) NSNumber *servingSize;
@property (nonatomic, strong, readonly) NSNumber *frequency;

@property (nonatomic, strong, readonly) NSString *name;

@property (nonatomic, strong, readonly) NSNumber *calories;
@property (nonatomic, strong, readonly) NSNumber *fat;
@property (nonatomic, strong, readonly) NSNumber *transFat;
@property (nonatomic, strong, readonly) NSNumber *sodium;
@property (nonatomic, strong, readonly) NSNumber *carbohydrates;
@property (nonatomic, strong, readonly) NSNumber *saturatedFat;
@property (nonatomic, strong, readonly) NSNumber *cholesterol;
@property (nonatomic, strong, readonly) NSNumber *protein;
@property (nonatomic, strong, readonly) NSNumber *fiber;
@property (nonatomic, strong, readonly) NSNumber *sugars;

@property (nonatomic, strong, readonly) NSNumber *e;
@property (nonatomic, strong, readonly) NSNumber *d;
@property (nonatomic, strong, readonly) NSNumber *folate;
@property (nonatomic, strong, readonly) NSNumber *pot;
@property (nonatomic, strong, readonly) NSNumber *a;
@property (nonatomic, strong, readonly) NSNumber *thi;
@property (nonatomic, strong, readonly) NSNumber *rib;
@property (nonatomic, strong, readonly) NSNumber *nia;
@property (nonatomic, strong, readonly) NSNumber *b6;
@property (nonatomic, strong, readonly) NSNumber *b12;
@property (nonatomic, strong, readonly) NSNumber *fol;
@property (nonatomic, strong, readonly) NSNumber *c;
@property (nonatomic, strong, readonly) NSNumber *calc;
@property (nonatomic, strong, readonly) NSNumber *iron;
@property (nonatomic, strong, readonly) NSNumber *mag;
@property (nonatomic, strong, readonly) NSNumber *zn;

@property (nonatomic, strong, readonly) NSNumber *categoryId;
@property (nonatomic, strong, readonly) NSString *barcodeUPCA;
@property (nonatomic, strong, readonly) NSString *factualId;
@property (nonatomic, strong, readonly) NSString *scannedFood;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
