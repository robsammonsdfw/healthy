//
//  PurchaseIAPHelper.m
//  DietMaster Go ND
//
//  Created by CIPL0688 on 13/03/20.
//

#import "PurchaseIAPHelper.h"
#import "IAPHelper.h"
#import "KeychainItemWrapper.h"

@implementation PurchaseIAPHelper

+ (PurchaseIAPHelper *)sharedInstance {
    static PurchaseIAPHelper *sharedInstance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSSet *productIdentifiers = [NSSet setWithObjects:
                                     Bronze30DayPID,
                                     Silver30DayPID,
                                     Gold30DayPID,
                                     Bronze90DayPID,
                                     Silver90DayPID,
                                     Gold90DayPID,
                                     nil];
        
        //if product has been puchased, show afterInitialPurchase identifiers instead
        
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];

//        NSArray *productIdentifiers = [[NSArray alloc] initWithObjects:
                                       
//                                       Silver30DayPID,
//                                       Gold30DayPID,
//                                       nil];
        
//        NSArray *productIdentifiersafterPurchased = [[NSArray alloc] initWithObjects:
//                                       kBronze90DayPID,
////                                       kSilver90DayPID,
////                                       kGold90DayPID,
////                                       kBronze30DayPID,
////                                       kSilver30DayPID,
////                                       kGold30DayPID,
//                                       nil];
        
//        NSUserDefaults *identifier = [NSUserDefaults standardUserDefaults];
//        BOOL *purchased = [identifier boolForKey:@"ProductPurchased"];//[identifier valueForKey:@"ProductPurchased"];
//
//        BOOL *pur = [[NSUserDefaults standardUserDefaults] boolForKey:@"ProductPurchased"];
//        if(![[NSUserDefaults standardUserDefaults] boolForKey:@"ProductPurchased"]) {
//            sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
//
//        } else {
//             sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiersafterPurchased];
//        }
        
//         NSString *savedValue = [[NSUserDefaults standardUserDefaults] valueForKey:@"ProductPurchasedAlready"];
//        NSLog(@"%@",savedValue);
//        if ([savedValue  isEqual: @"ProductPurchasedAlready"]){
//                  sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiersafterPurchased];
//              }else{
//                   sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
//              }
        
//       KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"DIETMASTERGOPLUS" accessGroup:nil];
//
//         NSString *userID = [keychainItem objectForKey:kSecValueData];
//         NSString *pruchased = [keychainItem objectForKey:kSecAttrAccount];
//
//         NSLog(@"%@",pruchased);
//
//
//        if ([pruchased  isEqual: @"YES"]){
//            sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiersafterPurchased];
//        }else{
//            sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
//        }
    });
    return sharedInstance;
}

@end


/**       NSSet *productIdentifiers = [NSSet setWithObjects:
                                     Bronze90DayPID,
                                     Silver90DayPID,
                                     Gold90DayPID,
                                     Bronze30DayPID,
                                     Silver30DayPID,
                                     Gold30DayPID,
                                     nil];
*/
