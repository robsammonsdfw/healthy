//
//  InAppPurchaseViewController.m
//  DietMaster Go ND
//
//  Created by CIPL0688 on 2/27/20.
//

#import "InAppPurchaseViewController.h"
#import "PlansTableViewCell.h"
#import "headerVw.h"
#import "MBProgressHUD.h"

#import "PurchaseIAPHelper.h"

#import "KeychainItemWrapper.h"
@import StoreKit;

//SKProductsRequestDelegate, SKPaymentTransactionObserver,
@interface InAppPurchaseViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *products;
@property (nonatomic, strong) NSNumberFormatter *priceFormatter;

//+ (InAppPurchaseViewController *)sharedInstance;
@end

@implementation InAppPurchaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [PurchaseIAPHelper sharedInstance].inAppPurchaseViewController = self;

    _statusStr = [[NSMutableString alloc] init];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    self.contentVw.layer.cornerRadius = 2.5f;
    self.contentVw.layer.borderWidth = 0.5f;
    self.contentVw.layer.borderColor = UIColor.lightGrayColor.CGColor;
    self.contentVw.clipsToBounds = true;
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"< Back" style:UIBarButtonItemStyleDone target:self action:@selector(backAction:)];
    newBackButton.tintColor = UIColor.whiteColor;
    self.navigationItem.leftBarButtonItem = newBackButton;
    self.navigationItem.title = @"Subscription";
}

- (void)closeModal {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Restore"
        style:UIBarButtonItemStylePlain
        target:self
        action:@selector(restoreTapped:)];
        self.priceFormatter = [[NSNumberFormatter alloc] init];
        [self.priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [self.priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    }
    return self;
}

- (void)restoreTapped:(id)sender {
    [[PurchaseIAPHelper sharedInstance] restoreCompletedTransactions];
}

- (void)viewWillAppear:(BOOL)animated{
    [self reload];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(productPurchased:)
                                                 name:IAPHelperProductPurchasedNotification
                                               object:nil];
    [super viewWillAppear:animated];
    
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(NSArray *)dayPlan
{
    _dayPlansArr = @[@"90 DAY PLANS",@"MONTHLY PLANS"];
    return _dayPlansArr;
}
//- (NSArray *)planName
//{
//    _planNameArr                = @[@"Bronze Plan",@"Silver Plan",@"Gold Plan"];
//    return _planNameArr;
//}
//
//- (NSArray *)threeMonthPlan
//{
//    _threeMonthsPlanPriceArr    = @[@"$35.95",@"$49.95",@"$64.95"];
//    return _threeMonthsPlanPriceArr;
//}
//
//- (NSArray *)oneMonth
//{
//    _oneMonthPlanPriceArr       = @[@"$4.95",@"$9.95",@"$14.95"];
//    return _oneMonthPlanPriceArr;
//}
- (NSArray *)planAccess
{
    _planAccessArr              = @[@"90 Day Access", @"Monthly Access"];
    return _planAccessArr;
}
//- (NSArray *)planDescription
//{
//    _descriptionArr             = @[@"Access 25 of our most popular meal plans exercise and food journal chat and  video support", @"Access 25 of our most popular meal plans and 14 to 21 day jump Start the talks meal plans exercise and food journal chat and video support", @"Access 25 of our most popular meal plan, our 14 to 21 day jump start the talks, energy, ketogenic and medically specialised plans. Exercise and food journal chat and video support"];
//    return _descriptionArr;
//}
- (void) backAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - TableView delegate & Data Source Methods :-)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    return 2;
    return [self dayPlan].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    DMLog(@"PRODUCT COUNT %i", [self.products count]);
//    return [self planName].count;
    return [self.products count] / 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"PlansTableViewCell";
    NSArray *arrData = [[NSBundle mainBundle]loadNibNamed:@"PlansTableViewCell" owner:nil options:nil];
    PlansTableViewCell *cell = [[PlansTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    cell = [arrData objectAtIndex:0];
    int index = indexPath.row + indexPath.section * ([self.products count] / 2);
    
    SKProduct *product = self.products[index];
    
    cell.planNameLbl.text = product.localizedTitle;
    [self.priceFormatter setLocale:product.priceLocale];

    //    cell.detailTextLabel.text = [self.priceFormatter stringFromNumber:product.price];
    cell.accessDescriptionLbl.text = product.localizedDescription;
    cell.signUpBtn.tag = index;
    [cell.signUpBtn addTarget:self action:@selector(signUpBtnAction:) forControlEvents:UIControlEventTouchUpInside];

    cell.dayAccessLbl.text = [self planAccess][indexPath.section];
    
    DMLog(@"PRODUCT: %@", product);
    
    switch (indexPath.section){
        case 0:
            cell.priceLbl.text = [NSString stringWithFormat:@"$%@", [[product.price decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithString:@"20.04"]] stringValue]]; //20.04 is 19.99 + .05c
//            [[product.price decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithString:@"20.04"]] stringValue]]; //20.04 is 19.99 + .05c
            
//            cell.priceLbl.text = [self threeMonthPlan][indexPath.row];
            _statusStr = @"90 DAY PLANS";
//            [cell.signUpBtn addTarget:self action:@selector(signUpBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            cell.perMonthLbl.hidden = YES;
//            cell.planNameLbl.text = [self planName][indexPath.row];
            break;
        case 1:
            cell.priceLbl.text = [NSString stringWithFormat:@"$%@", [product.price stringValue]];
            cell.initialActFeeLbl.text = @"  ";
//            cell.dayAccessLbl.text = [self planAccess][1];
            _statusStr = @"MONTHLY PLANS";
//            [cell.signUpBtn addTarget:self action:@selector(signUpBtnActionForMonthlyPlan:) forControlEvents:UIControlEventTouchUpInside];
            cell.perMonthLbl.hidden = NO;
//            cell.planNameLbl.text = [self planName][indexPath.row];
            
            break;
        default:
            break;
    }
//    cell.signUpBtn.tag = indexPath.row;
//    cell.accessDescriptionLbl.text = [self planDescription][indexPath.row];
    return cell;
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *CellIdentifier = @"headerVw";
    NSArray *arrData = [[NSBundle mainBundle]loadNibNamed:@"headerVw" owner:nil options:nil];
    headerVw *cell = [[headerVw alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell = [arrData objectAtIndex:0];
    cell.accentClrVw.backgroundColor = [UIColor blackColor];
    cell.planLbl.text = [self dayPlan][section];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 350.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 70;
}

#pragma mark:- Sign Up Actions :-)
-(void)signUpBtnAction:(id)sender{
    UIButton *senderBtn = (UIButton *)sender;
    SKProduct *product = self.products[senderBtn.tag];
    
    DMLog(@"Buying %@", product.productIdentifier);
    [[PurchaseIAPHelper sharedInstance] buyProduct:product];
    
//    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    NSString *savedValue = [[NSUserDefaults standardUserDefaults] valueForKey:@"ProductPurchasedAlready"];
    DMLog(@"%@",savedValue);
    
    if ([savedValue  isEqual: @"ProductPurchasedAlready"]){
       DMLog(@" ProductPurchased");
    } else {
       DMLog(@"NOT ProductPurchased");
    }
    
    DMLog(@"Buying %@...", product.productIdentifier);
    [[PurchaseIAPHelper sharedInstance] buyProduct:product];
    
    
//    //KEY CHAIN
//   KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"DIETMASTERGOPLUS" accessGroup:nil];
//
//     NSString *userID = [keychainItem objectForKey:kSecValueData];
//     NSString *pruchased = [keychainItem objectForKey:kSecAttrAccount];
//
//     DMLog(@"%@",pruchased);
//    DMLog(@"%@",userID);
//
    
//
//    for (int i = 0; i < self.products.count; i++) {
//        product = self.products[i];
//        NSString *a = product.productIdentifier;
//        [arr addObject:a];
//    }
//    DMLog(@"%@",arr);
    
//    switch (senderBtn.tag) {
//        case 0:
//            AppDel.idStr = @"8";
////            product = self.products[0];
//            break;
//        case 1:
//            AppDel.idStr = @"9";
////            product = self.products[4];
//            break;
//        case 2:
//            AppDel.idStr = @"10";
////            product = self.products[2];
//            break;
//        default:
//            break;
//    }
}

//-(void)signUpBtnActionForMonthlyPlan:(UIButton *)sender{
//    //    NSString *savedValue = [[NSUserDefaults standardUserDefaults] valueForKey:@"ProductPurchasedAlready"];
//    //
//    //    if ([savedValue  isEqual: @"ProductPurchasedAlready"]){
//    //        DMLog(@" ProductPurchased");
//    //    }else{
//    //         DMLog(@"NOT ProductPurchased");
//    //    }
//
////
////    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"DIETMASTERGOPLUS" accessGroup:nil];
////
////    NSString *userID = [keychainItem objectForKey:kSecValueData];
////    NSString *pruchased = [keychainItem objectForKey:kSecAttrAccount];
////
////    DMLog(@"%@",pruchased);
//    SKProduct *product;
//    NSMutableArray *arr = [[NSMutableArray alloc] init];
//
//    for (int i = 0; i < self.products.count; i++) {
//        product = self.products[i];
//        NSString *a = product.productIdentifier;
//        [arr addObject:a];
//    }
//
//
//    switch (sender.tag) {
//        case 0:
//            AppDel.idStr = @"12";
//            product = self.products[1];
//            break;
//        case 1:
//            AppDel.idStr = @"13";
//            product = self.products[5];
//            break;
//        case 2:
//            AppDel.idStr = @"14";
//            product = self.products[3];
//            break;
//        default:
//            break;
//    }
//    DMLog(@"Buying %@...", product.productIdentifier);
//    [[PurchaseIAPHelper sharedInstance] buyProduct:product];
//
//}

#pragma mark - StoreKit
- (void)reload {
    self.products = nil;
    [self.tableView reloadData];
    [[PurchaseIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"price" ascending:NO];
            NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
            NSArray *sortedArray = [products sortedArrayUsingDescriptors:descriptors];
            self.products = sortedArray;
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
}

- (void)productPurchased:(NSNotification *)notification {
//    [self savePurchased];
    NSString * productIdentifier = notification.object;
    [self.products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            int halfProducts = [self.products count] / 2;
            int index = idx;
            int section = 0;
            if (idx >= halfProducts) {
                index = idx - halfProducts;
                section = 1;
            }
            [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:section]] withRowAnimation:UITableViewRowAnimationFade];
            *stop = YES;
        }
    }];
}

-(void)savePurchased{
    DMLog(@"I dont know why this is running....");
//    [[NSUserDefaults standardUserDefaults] setObject: @"ProductPurchasedAlready" forKey:@"ProductPurchasedAlready"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//
//    NSString *savedValue = [[NSUserDefaults standardUserDefaults] valueForKey:@"ProductPurchasedAlready"];
//    DMLog(@"%@",savedValue);
//    return savedValue;
    
    NSUUID *uuid = [NSUUID UUID];
    NSString *uuidString = uuid.UUIDString;
    
//    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"DIETMASTERGOPLUS" accessGroup:nil];
//        [keychainItem setObject: uuidString forKey:kSecValueData];
//        [keychainItem setObject:@"YES" forKey:kSecAttrAccount];
//
//
//        NSString *userID = [keychainItem objectForKey:kSecValueData];
//        NSString *pruchased = [keychainItem objectForKey:kSecAttrAccount];
        
//        DMLog(@"%@",pruchased);
    
}

@end
