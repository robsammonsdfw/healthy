//
//  DMFood.m
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/15/23.
//

#import "DMFood.h"

@interface DMFood()
@property (nonatomic, strong, readwrite) NSNumber *foodPK;
@property (nonatomic, strong, readwrite) NSNumber *foodKey;
@property (nonatomic, strong, readwrite) NSNumber *foodId;
@property (nonatomic, strong, readwrite) NSNumber *userId;
@property (nonatomic, strong, readwrite) NSNumber *companyId;
@property (nonatomic, strong, readwrite) NSNumber *measureId;
@property (nonatomic, strong, readwrite) NSNumber *recipeId;
@property (nonatomic, strong, readwrite) NSNumber *regionCode;
@property (nonatomic, strong, readwrite) NSNumber *parentGroupID;

@property (nonatomic, strong, readwrite) NSNumber *servingSize;
@property (nonatomic, strong, readwrite) NSNumber *frequency;
@property (nonatomic, strong, readwrite) NSNumber *gramWeight;

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
@property (nonatomic, strong, readwrite) NSNumber *alcohol;

@property (nonatomic, strong, readwrite) NSNumber *scannedFood;

@property (nonatomic, strong, readwrite) NSNumber *categoryId;
@property (nonatomic, strong, readwrite) NSString *barcodeUPCA;
@property (nonatomic, strong, readwrite) NSString *factualId;
@property (nonatomic, strong, readwrite) NSString *foodTags;
@property (nonatomic, strong, readwrite) NSString *foodURL;

@property (nonatomic, strong, readwrite) NSString *lastUpdateDateString;

@end

@implementation DMFood

- (instancetype)init {
    return [self initWithDictionary:@{}];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _foodPK = ValidNSNumber(dictionary[@"FoodPK"]);
        _foodKey = ValidNSNumber(dictionary[@"FoodKey"]);
        _foodId = ValidNSNumber(dictionary[@"FoodID"]);
        _userId = ValidNSNumber(dictionary[@"UserID"]);
        _companyId = ValidNSNumber(dictionary[@"CompanyID"]);
        _scannedFood = ValidNSNumber(dictionary[@"ScannedFood"]);
        _factualId = ValidString(dictionary[@"FactualID"]);
        _barcodeUPCA = ValidString(dictionary[@"UPCA"]);
        _categoryId = ValidNSNumber(dictionary[@"CategoryID"]);
        _recipeId = ValidNSNumber(dictionary[@"RecipeID"]);
        _regionCode = ValidNSNumber(dictionary[@"RegionCode"]);
        _parentGroupID = ValidNSNumber(dictionary[@"ParentGroupID"]);
        
        _measureId = ValidNSNumber(dictionary[@"MeasureID"]);
        if ([_measureId isEqual:@0]) {
            _measureId = @1;
        }
        _servingSize = ValidNSNumber(dictionary[@"ServingSize"]);
        if ([_servingSize isEqual:@0]) {
            _servingSize = @1;
        }
        _gramWeight = ValidNSNumber(dictionary[@"GramWeight"]);
        if ([_gramWeight isEqual:@0]) {
            _gramWeight = @1; // Also saw value at 100.
        }
        
        _frequency = ValidNSNumber(dictionary[@"Frequency"]);

        _name = ValidString(dictionary[@"Name"]);
        _name = [_name stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        _name =  [_name stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        _name = [_name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        _calories = ValidNSNumber(dictionary[@"Calories"]);
        _fat = ValidNSNumber(dictionary[@"Fat"]);
        _transFat = ValidNSNumber(dictionary[@"TransFat"]);
        _sodium = ValidNSNumber(dictionary[@"Sodium"]);
        _carbohydrates = ValidNSNumber(dictionary[@"Carbohydrates"]);
        _saturatedFat = ValidNSNumber(dictionary[@"SaturatedFat"]);
        _cholesterol = ValidNSNumber(dictionary[@"Cholesterol"]);
        _protein = ValidNSNumber(dictionary[@"Protein"]);
        _fiber = ValidNSNumber(dictionary[@"Fiber"]);
        _sugars = ValidNSNumber(dictionary[@"Sugars"]);

        _e = ValidNSNumber(dictionary[@"E"]);
        _d = ValidNSNumber(dictionary[@"D"]);
        _folate = ValidNSNumber(dictionary[@"Folate"]);
        _pot = ValidNSNumber(dictionary[@"Pot"]);
        _a = ValidNSNumber(dictionary[@"A"]);
        _thi = ValidNSNumber(dictionary[@"Thi"]);
        _rib = ValidNSNumber(dictionary[@"Rib"]);
        _nia = ValidNSNumber(dictionary[@"Nia"]);
        _b6 = ValidNSNumber(dictionary[@"B6"]);
        _b12 = ValidNSNumber(dictionary[@"B12"]);
        _fol = ValidNSNumber(dictionary[@"Fol"]);
        _c = ValidNSNumber(dictionary[@"C"]);
        _calc = ValidNSNumber(dictionary[@"Calc"]);
        _iron = ValidNSNumber(dictionary[@"Iron"]);
        _mag = ValidNSNumber(dictionary[@"Mag"]);
        _zn = ValidNSNumber(dictionary[@"Zn"]);
        _alcohol = ValidNSNumber(dictionary[@"Alcohol"]);

        NSString *foodTags = ValidString(dictionary[@"FoodTags"]);
        if (foodTags.length) {
            foodTags = [foodTags stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            foodTags = [foodTags stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            foodTags = [foodTags stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
        _foodTags = foodTags;
        
        _foodURL = ValidString(dictionary[@"FoodURL"]);
        _lastUpdateDateString = ValidString(dictionary[@"LastUpdateDate"]);
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          self.foodKey, @"FoodKey",
                          self.foodId, @"FoodID",
                          self.name, @"Name",
                          self.categoryId, @"CategoryID",
                          self.calories, @"Calories",
                          self.fat, @"Fat",
                          self.sodium, @"Sodium",
                          self.carbohydrates, @"Carbohydrates",
                          self.saturatedFat, @"SaturatedFat",
                          self.cholesterol, @"Cholesterol",
                          self.protein, @"Protein",
                          self.fiber, @"Fiber",
                          self.sugars, @"Sugars",
                          self.pot, @"Pot",
                          self.a, @"A",
                          self.thi, @"Thi",
                          self.rib, @"Rib",
                          self.nia, @"Nia",
                          self.b6, @"B6",
                          self.b12, @"B12",
                          self.fol, @"Fol",
                          self.c, @"C",
                          self.calc, @"Calc",
                          self.iron, @"Iron",
                          self.mag, @"Mag",
                          self.zn, @"Zn",
                          self.servingSize, @"ServingSize",
                          self.transFat, @"Transfat",
                          self.e, @"E",
                          self.d, @"D",
                          self.folate, @"Folate",
                          self.frequency, @"Frequency",
                          self.userId, @"UserID",
                          self.companyId, @"CompanyID",
                          self.barcodeUPCA, @"UPCA",
                          self.factualId, @"FactualID",
                          self.measureId, @"MeasureID",
                          self.scannedFood, @"ScannedFood", nil];
    return dict;
}

- (NSString *)replaceIntoSQLString {
    NSString *sqlString = [NSString stringWithFormat:@"REPLACE INTO Food "
                            "(ScannedFood, "
                            "FoodPK, FoodKey, "
                            "FoodID, CategoryID, "
                            "CompanyID, UserID, "
                            "Name, Calories, "
                            "Fat, Sodium, "
                            "Carbohydrates, SaturatedFat, "
                            "Cholesterol, Protein, "
                            "Fiber, Sugars, "
                            "Pot, A, "
                            "Thi, Rib, "
                            "Nia, B6, "
                            "B12, Fol, "
                            "C, Calc, "
                            "Iron, Mag, "
                            "Zn, ServingSize, "
                            "FoodTags, Frequency, "
                            "Alcohol, Folate, "
                            "Transfat, E, "
                            "D, UPCA, "
                            "FactualID, ParentGroupID,"
                            "RegionCode, LastUpdateDate,"
                            "RecipeID, FoodURL)"
                            "VALUES"
                            "(%d, "
                            "%i, %i, "
                            "%i, %i, "
                            "%i, %i, "
                            "\"%@\", %f, " //Name, Calories
                            "%f, %f, "
                            "%f, %f, "
                            "%f, %f, "
                            "%f, %f, "
                            "%f, %f, " //Pot, A
                            "%f, %f, "
                            "%f, %f, "
                            "%f, %f, "
                            "%f, %f, "
                            "%f, %f, "
                            "%f, %f, "
                            "\"%@\", %i, " //FoodTags, Frequency
                            "%f, %f, "
                            "%f, %f, "
                            "%f, \"%@\", "
                            "%i , %i, "
                            "%i, \"%@\", "
                            "%i, \"%@\") ",
                           self.scannedFood.boolValue,

                           self.foodPK.intValue,
                           self.foodKey.intValue,

                           self.foodId.intValue,
                           self.categoryId.intValue,

                           self.companyId.intValue,
                           self.userId.intValue,
                           self.name,

                           self.calories.doubleValue,
                           self.fat.doubleValue,
                           self.sodium.doubleValue,
                           self.carbohydrates.doubleValue,
                           self.saturatedFat.doubleValue,
                           self.cholesterol.doubleValue,
                           self.protein.doubleValue,
                           self.fiber.doubleValue,
                           self.sugars.doubleValue,
                           self.pot.doubleValue,
                           self.a.doubleValue,
                           self.thi.doubleValue,
                           self.rib.doubleValue,
                           self.nia.doubleValue,
                           self.b6.doubleValue,
                           self.b12.doubleValue,
                           self.fol.doubleValue,
                           self.c.doubleValue,
                           self.calc.doubleValue,
                           self.iron.doubleValue,
                           self.mag.doubleValue,
                           self.zn.doubleValue,
                           self.servingSize.doubleValue,
                           self.foodTags,
                           self.frequency.intValue,
                           self.alcohol.doubleValue,
                           self.folate.doubleValue,
                           self.transFat.doubleValue,
                           self.e.doubleValue,
                           self.d.doubleValue,
                           self.barcodeUPCA,
                           self.factualId.intValue,
                           self.parentGroupID.intValue,
                           self.regionCode.intValue,
                           self.lastUpdateDateString,
                           self.recipeId.intValue,
                           self.foodURL];
    return sqlString;
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
