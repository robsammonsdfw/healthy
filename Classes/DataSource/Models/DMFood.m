//
//  DMFood.m
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/15/23.
//

#import "DMFood.h"

@interface DMFood()
@property (nonatomic, strong, readwrite) NSNumber *foodKey;
@property (nonatomic, strong, readwrite) NSNumber *foodId;
@property (nonatomic, strong, readwrite) NSNumber *userId;
@property (nonatomic, strong, readwrite) NSNumber *companyId;
@property (nonatomic, strong, readwrite) NSNumber *measureId;
@property (nonatomic, strong, readwrite) NSNumber *servingSize;
@property (nonatomic, strong, readwrite) NSNumber *frequency;

@property (nonatomic, strong, readwrite) NSString *name;

@property (nonatomic, strong, readwrite) NSNumber *calories;
@property (nonatomic, strong, readwrite) NSNumber *fat;
@property (nonatomic, strong, readwrite) NSNumber *transFat;
@property (nonatomic, strong, readwrite) NSNumber *sodium;
@property (nonatomic, strong, readwrite) NSNumber *carbohydrates;
@property (nonatomic, strong, readwrite) NSNumber *saturatedFat;
@property (nonatomic, strong, readwrite) NSNumber *cholesterol;
@property (nonatomic, strong, readwrite) NSNumber *protein;
@property (nonatomic, strong, readwrite) NSNumber *fiber;
@property (nonatomic, strong, readwrite) NSNumber *sugars;

@property (nonatomic, strong, readwrite) NSNumber *e;
@property (nonatomic, strong, readwrite) NSNumber *d;
@property (nonatomic, strong, readwrite) NSNumber *folate;
@property (nonatomic, strong, readwrite) NSNumber *pot;
@property (nonatomic, strong, readwrite) NSNumber *a;
@property (nonatomic, strong, readwrite) NSNumber *thi;
@property (nonatomic, strong, readwrite) NSNumber *rib;
@property (nonatomic, strong, readwrite) NSNumber *nia;
@property (nonatomic, strong, readwrite) NSNumber *b6;
@property (nonatomic, strong, readwrite) NSNumber *b12;
@property (nonatomic, strong, readwrite) NSNumber *fol;
@property (nonatomic, strong, readwrite) NSNumber *c;
@property (nonatomic, strong, readwrite) NSNumber *calc;
@property (nonatomic, strong, readwrite) NSNumber *iron;
@property (nonatomic, strong, readwrite) NSNumber *mag;
@property (nonatomic, strong, readwrite) NSNumber *zn;

@property (nonatomic, strong, readwrite) NSNumber *categoryId;
@property (nonatomic, strong, readwrite) NSString *barcodeUPCA;
@property (nonatomic, strong, readwrite) NSString *factualId;
@property (nonatomic, strong, readwrite) NSString *scannedFood;
@end

@implementation DMFood

- (instancetype)init {
    return [self initWithDictionary:@{}];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _foodKey = ValidNSNumber(dictionary[@"foodKey"]);
        _foodId = ValidNSNumber(dictionary[@"foodId"]);
        
        _userId = ValidNSNumber(dictionary[@"userId"]);
        _companyId = ValidNSNumber(dictionary[@"companyId"]);
        
        _scannedFood = ValidString(dictionary[@"ScannedFood"]);
        _factualId = ValidString(dictionary[@"FactualID"]);
        _barcodeUPCA = ValidString(dictionary[@"UPCA"]);
        _categoryId = ValidNSNumber(dictionary[@"CategoryID"]);
        _measureId = ValidNSNumber(dictionary[@"measureId"]);
        
        _servingSize = ValidNSNumber(dictionary[@"servingSize"]);
        _frequency = ValidNSNumber(dictionary[@"frequency"]);
        _name = ValidString(dictionary[@"name"]);
        
        _calories = ValidNSNumber(dictionary[@"calories"]);
        _fat = ValidNSNumber(dictionary[@"fat"]);
        _transFat = ValidNSNumber(dictionary[@"transFat"]);
        _sodium = ValidNSNumber(dictionary[@"sodium"]);
        _carbohydrates = ValidNSNumber(dictionary[@"carbohydrates"]);
        _saturatedFat = ValidNSNumber(dictionary[@"saturatedFat"]);
        _cholesterol = ValidNSNumber(dictionary[@"cholesterol"]);
        _protein = ValidNSNumber(dictionary[@"protein"]);
        _fiber = ValidNSNumber(dictionary[@"fiber"]);
        _sugars = ValidNSNumber(dictionary[@"sugars"]);

        _e = ValidNSNumber(dictionary[@"e"]);
        _d = ValidNSNumber(dictionary[@"d"]);
        _folate = ValidNSNumber(dictionary[@"folate"]);
        _pot = ValidNSNumber(dictionary[@"pot"]);
        _a = ValidNSNumber(dictionary[@"a"]);
        _thi = ValidNSNumber(dictionary[@"thi"]);
        _rib = ValidNSNumber(dictionary[@"rib"]);
        _nia = ValidNSNumber(dictionary[@"nia"]);
        _b6 = ValidNSNumber(dictionary[@"b6"]);
        _b12 = ValidNSNumber(dictionary[@"b12"]);
        _fol = ValidNSNumber(dictionary[@"fol"]);
        _c = ValidNSNumber(dictionary[@"c"]);
        _calc = ValidNSNumber(dictionary[@"calc"]);
        _iron = ValidNSNumber(dictionary[@"iron"]);
        _mag = ValidNSNumber(dictionary[@"mag"]);
        _zn = ValidNSNumber(dictionary[@"zn"]);
    }
    return self;
}

#pragma mark - Equality

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[DMFood class]]) {
        return NO;
    }
    
    return [self isEqualToFood:object];
}

- (BOOL)isEqualToFood:(DMFood *)food {

    if (![self.foodId isEqualToNumber:food.foodId]) {
        return NO;
    }

    return YES;
}

- (NSUInteger)hash {
    return [self.foodId hash];
}

@end
