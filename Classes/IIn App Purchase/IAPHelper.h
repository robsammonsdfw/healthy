//
//  IAPHelper.h
//  DietMaster Go ND
//
//  Created by CIPL0688 on 13/03/20.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "InAppPurchaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;
typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface IAPHelper : NSObject
- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;
@property (nonatomic, strong) InAppPurchaseViewController *inAppPurchaseViewController;
@end

NS_ASSUME_NONNULL_END
