//
//  DietmasterEngine.m
//  DietMasterGo
//
//  Created by Henry Kirk on 2/4/12.
//  Copyright (c) 2012 Henry T Kirk. All rights reserved.
//

#import "DietmasterEngine.h"
@import Firebase;
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "NSData+Blocks.h"
#import "UIDevice+machine.h"
#import "DietMasterGoAppDelegate.h"
#import "NSString+ConvertToDate.h"
#import "MBProgressHUD.h"
#import "NSNull+NullCategoryExtension.h"

#import "DMMyLogDataProvider.h"

#import "DMUser.h"
#import "DMMessage.h"
#import "DMFood.h"
#import "DMWeightLogEntry.h"

#import "DietMasterGoPlus-Swift.h"
#import "DMUser.h"

#define D_MINUTE	60
#define D_HOUR		3600
#define D_DAY		86400
#define D_WEEK		604800
#define D_YEAR		31556926

@interface DietmasterEngine ()
@property (nonatomic, strong) NSDateFormatter *dateformatter;
@property (nonatomic, strong, readwrite) FMDatabase *database;
@end

@implementation DietmasterEngine

@synthesize exerciseSelectedDict, taskMode, dateSelected, dateSelectedFormatted;
@synthesize selectedMealID, selectedMeasureID, selectedCategoryID;
@synthesize mealPlanArray, isMealPlanItem, mealPlanItemToExchangeDict, indexOfItemToExchange, selectedMealPlanID, didInsertNewFood;

+ (instancetype)sharedInstance {
    static DietmasterEngine *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DietmasterEngine alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _dateformatter = [[NSDateFormatter alloc] init];
        exerciseSelectedDict = [[NSMutableDictionary alloc] init];
        
        mealPlanArray = [[NSMutableArray alloc] init];
        
        dateSelected = [[NSDate alloc] init];
        
        [_dateformatter setDateStyle:NSDateFormatterLongStyle];
        dateSelectedFormatted = [_dateformatter stringFromDate:dateSelected];
        
        isMealPlanItem = NO;
        mealPlanItemToExchangeDict = [[NSMutableDictionary alloc] init];
        didInsertNewFood = NO;
    }
    return self;
}

#pragma mark - Splash Image

- (void)downloadFileIfUpdated {
    NSString *pngFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"SplashImage.png"];
    NSString *pngFilePath2x = [NSTemporaryDirectory() stringByAppendingPathComponent:@"SplashImage@2x.png"];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    DMAuthManager *authManager = [DMAuthManager sharedInstance];
    DMUser *currentUser = [authManager loggedInUser];
    NSString *urlString = [NSString stringWithFormat:@"http://www.dmwebpro.com/CustomMobileGraphics/%@",
                           currentUser.mobileGraphicImageName];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSString *cachedPath = pngFilePath;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL downloadFromServer = NO;
    NSString *lastModifiedString = nil;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"HEAD"];
    NSHTTPURLResponse *response;
    NSError *error = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: &error];
    if ([response respondsToSelector:@selector(allHeaderFields)]) {
        lastModifiedString = [[response allHeaderFields] objectForKey:@"Last-Modified"];
    }
    
    if (error) {
        [prefs setValue:[NSDate date] forKey:@"lastmodified_splash"];
        [prefs synchronize];
        return;
    }
    
    NSDate *lastModifiedServer = nil;
    @try {
        self.dateformatter.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";
        self.dateformatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        self.dateformatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        lastModifiedServer = [self.dateformatter dateFromString:lastModifiedString];
    }
    @catch (NSException * e) {
        DMLog(@"Error parsing last modified date: %@ - %@", lastModifiedString, [e description]);
    }
    
    if (!lastModifiedServer) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *logoFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"SplashImage.png"];
        NSString *logoFilePath2x = [NSTemporaryDirectory() stringByAppendingPathComponent:@"SplashImage@2x.png"];
        if([[NSFileManager defaultManager] fileExistsAtPath: logoFilePath])
        {
            [fileManager removeItemAtPath:logoFilePath error:NULL];
            [fileManager removeItemAtPath:logoFilePath2x error:NULL];
        }
        
        [prefs setValue:[NSDate date] forKey:@"lastmodified_splash"];
        return;
    }
    
    NSDate *lastModifiedLocal = nil;
    if ([fileManager fileExistsAtPath:cachedPath]) {
        NSError *error = nil;
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:cachedPath error:&error];
        if (error) {
            DMLog(@"Error reading file attributes for: %@ - %@", cachedPath, [error localizedDescription]);
        }
        lastModifiedLocal = [fileAttributes fileModificationDate];
    }
    
    if (!lastModifiedLocal) {
        downloadFromServer = YES;
    }
    if ([lastModifiedLocal laterDate:lastModifiedServer] == lastModifiedServer) {
        downloadFromServer = YES;
    }
    
    if (downloadFromServer) {
        
        [NSData dataWithContentsOfURL:url completionBlock:^(NSData *data, NSError *error) {
            if(!error) {
                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                    if (data) {
                        UIImage *image = [[UIImage alloc] initWithData:data];
                        UIImage* stdImage = [self imageWithImage:image scaledToSize:CGSizeMake(320, SCREEN_HEIGHT)];
                        UIImage* stdImage2x = [self imageWithImage:image scaledToSize:CGSizeMake(640, SCREEN_HEIGHT*2)];
                        NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(stdImage)];
                        NSData *data2 = [NSData dataWithData:UIImagePNGRepresentation(stdImage2x)];
                        
                        [data1 writeToFile:pngFilePath atomically:YES];
                        [data2 writeToFile:pngFilePath2x atomically:YES];
                        
                        if (lastModifiedServer) {
                            NSDictionary *fileAttributes = [NSDictionary dictionaryWithObject:lastModifiedServer forKey:NSFileModificationDate];
                            NSError *error = nil;
                            if ([fileManager setAttributes:fileAttributes ofItemAtPath:cachedPath error:&error]) {
                                
                            }
                            if (error) {
                                DMLog(@"Error setting file attributes for: %@ - %@", cachedPath, [error localizedDescription]);
                            }
                        }
                    }
                });
            }
            else {
                DMLog(@"error %@", error);
            }
        }];
    }
    
    [prefs setValue:[NSDate date] forKey:@"lastmodified_splash"];
    [prefs synchronize];
}

- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark Food Plan Methods



#pragma mark Date Helpers

- (NSInteger)hoursAfterDate:(NSDate *)aDate {
    NSTimeInterval ti = [[NSDate date] timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_HOUR);
}
- (NSInteger)minutesAfterDate:(NSDate *)aDate {
    NSTimeInterval ti = [[NSDate date] timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_MINUTE);
}

#pragma mark - Notification Handlers

- (void)userLoginStateDidChangeNotification:(NSNotification *)notification {
    if ([NSThread isMainThread]) {
        DMAuthManager *authManager = [DMAuthManager sharedInstance];
        DMUser *currentUser = [authManager loggedInUser];
        if (currentUser.mobileGraphicImageName > 0) {
            [self performSelectorInBackground:@selector(downloadFileIfUpdated) withObject:nil];
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self userLoginStateDidChangeNotification:notification];
        });
    }
}

@end
