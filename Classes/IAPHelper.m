//
//  IAPHelper.m
//  DietMaster Go ND
//
//  Created by CIPL0688 on 13/03/20.
//
@import SafariServices;
#import "IAPHelper.h"
#import "ProfileAlertVCViewController.h"
#import "InAppPurchaseViewController.h"
@import StoreKit;
NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";

@interface IAPHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver, SFSafariViewControllerDelegate>
//- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
//- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
//- (void)buyProduct:(SKProduct *)product;
//- (BOOL)productPurchased:(NSString *)productIdentifier;
@end
@implementation IAPHelper
{
    // You create an instance variable to store the SKProductsRequest you will issue to retrieve a list of products, while it is active.
    SKProductsRequest *_productsRequest;
    // You also keep track of the completion handler for the outstanding products request, ...
    RequestProductsCompletionHandler _completionHandler;
    // ... the list of product identifiers passed in, ...
    NSSet *_productIdentifiers;
    // ... and the list of product identifiers that have been previously purchased.
    NSMutableSet * _purchasedProductIdentifiers;
}



- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers
{
    self = [super init];
    if (self) {
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        // Check for previously purchased products
        _purchasedProductIdentifiers = [[NSMutableSet alloc]init];
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [_purchasedProductIdentifiers addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
            } else {
                NSLog(@"Not purchased: %@", productIdentifier);
            }
        }
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler
{
    // a copy of the completion handler block inside the instance variable
    _completionHandler = [completionHandler copy];
    // Create a new instance of SKProductsRequest, which is the Apple-written class that contains the code to pull the info from iTunes Connect
    if ([SKPaymentQueue canMakePayments])
    {
        NSSet *productIdentifiers = [NSSet setWithObjects:
                                     Bronze30DayPID,
                                     Silver30DayPID,
                                     Gold30DayPID,
                                     Bronze90DayPID,
                                     Silver90DayPID,
                                     Gold90DayPID,
                                     nil];
        _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
        _productsRequest.delegate = self;
        [_productsRequest start];
    } else {
        NSLog(@"IN APP PURCHASE DID NOT WORK");
    }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"Loaded products...");
    _productsRequest = nil;
    NSArray * skProducts = response.products;
    for (SKProduct * skProduct in skProducts) {
        NSLog(@"Found product: %@ \n Product: %@ \n Price: %0.2f", skProduct.productIdentifier, skProduct.localizedTitle, skProduct.price.floatValue);
    }
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Failed to load list of products."
                                                      message:nil
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
    NSLog(@"Failed to load list of products.");
    _productsRequest = nil;
    _completionHandler(NO, nil);
    _completionHandler = nil;
}

- (BOOL)productPurchased:(NSString *)productIdentifier
{
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}
 
- (void)buyProduct:(SKProduct *)product
{
    NSLog(@"Buying %@...", product.productIdentifier);
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
            break;
        }
    };
}

// called when the transaction was successful
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"completeTransaction...");
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    [[SKPaymentQueue defaultQueue] startDownloads:transaction.downloads];
//    [self showSuccessfullyPurchaseAlert];

    
    BOOL hasPurchasedProduct = [[NSUserDefaults standardUserDefaults] boolForKey: transaction.payment.productIdentifier];
    if (hasPurchasedProduct)
    {
        NSLog(@"PRODUCT PURCHASED ALREADY");
        return;
    }
    
    [_purchasedProductIdentifiers addObject:transaction.payment.productIdentifier];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:transaction.payment.productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];

//    [[NSUserDefaults standardUserDefaults] setObject: transaction.payment.productIdentifier  forKey:@"ProductPurchasedAlready"];

    ProfileAlertVCViewController *desVc= [[ProfileAlertVCViewController alloc] initWithNibName:@"ProfileAlertVCViewController" bundle:nil];
    desVc.hidesBottomBarWhenPushed = YES;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:desVc];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:desVc];
    
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    [_inAppPurchaseViewController dismissViewControllerAnimated:YES completion:^{
        [topController presentViewController:nav animated:YES completion:nil];
    }];
//    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Purchased successfully!"
//                                                      message:@"Thank you for your purchase. Please complete your profile now."
//                                                     delegate:self
//                                            cancelButtonTitle:@"Complete Profile Setup"
//                                            otherButtonTitles:nil];
//    [message show];
}

- (void)restoreCompletedTransactions {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}
 
// called when a transaction has been restored and successfully completed
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"restoreTransaction...");
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Restored successfully!"
                                                      message:@"Enjoy!"
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
 
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}
 
// called when a transaction has failed
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"failedTransaction...");
    if (transaction.error.code != 0) { //this will be 0 for interrupted purchases
        if (transaction.error.code != SKErrorPaymentCancelled) {
            NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                              message:transaction.error.localizedDescription
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [message show];
        }
        else{
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Cancelled"
                                                              message:@"Oops!, You have cancelled this purchase."
                                                             delegate:nil
                                                    cancelButtonTitle:@"Dismiss"
                                                    otherButtonTitles:nil];
            [message show];
        }

    }

    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    NSLog(@"provideContentForProductIdentifier");
//    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:_purchasedProductIdentifiers];
//    NSArray *arrayWithoutDuplicates = [orderedSet array];
//    [_purchasedProductIdentifiers addObject:arrayWithoutDuplicates];
    

//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
//    ProfileAlertVCViewController *desVc= [[ProfileAlertVCViewController alloc] initWithNibName:@"ProfileAlertVCViewController" bundle:nil];
//    desVc.hidesBottomBarWhenPushed = YES;
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:desVc];
//    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
//
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:desVc];
//
//    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
//
//    [topController presentViewController:nav animated:YES completion:nil];

//    NSArray *products = [_purchasedProductIdentifiers allObjects];
//    NSString *productIdentifier = [products objectAtIndex:(products.count - 1)];
//
//    NSString *productWebAddress = nil;
//    if ([productIdentifier isEqualToString:Bronze30DayPID]) {
//        productWebAddress = Bronze30DayWebaddress;
//    } else if ([productIdentifier isEqualToString:Silver30DayPID]) {
//        productWebAddress = Silver30DayWebaddress;
//    } else if ([productIdentifier isEqualToString:Gold30DayPID]) {
//        productWebAddress = Gold30DayWebaddress;
//    } else if ([productIdentifier isEqualToString:Bronze90DayPID]) {
//        productWebAddress = Bronze90DayWebaddress;
//    } else if ([productIdentifier isEqualToString:Silver90DayPID]) {
//        productWebAddress = Silver90DayWebaddress;
//    } else if ([productIdentifier isEqualToString:Gold90DayPID]) {
//        productWebAddress = Gold90DayWebaddress;
//    } else {
//        NSLog(@"NO PRODUCT IDENTIFIER FOUND TO CREATE ACCOUNT");
//    }
//
//    SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:productWebAddress]];
//    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
//    [topController presentViewController:sfvc animated:YES completion:nil];
}

//- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
//    [self dismissViewControllerAnimated:true completion:nil];
//}

@end

