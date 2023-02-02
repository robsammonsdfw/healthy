

#import "ProfileAlertVCViewController.h"
#import "ProfileContactVC.h"

@interface ProfileAlertVCViewController ()

@end

@implementation ProfileAlertVCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor=[UIColor blackColor];
    [self.navigationController navigationBar].translucent=NO;
    
//    UINavigationBar.appearance().barTintColor=UIColor(red: (44.0)/255.0, green: (190.0)/255.0, blue: (106.0)/255.0, alpha:1)
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.title=@"Profile Creation";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationItem.hidesBackButton = YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnYesClicked:(id)sender {
    ProfileContactVC *contactVC = [[ProfileContactVC alloc] initWithNibName:@"ProfileContactVC" bundle:nil];
//    ProfileVC *desVc= [[ProfileVC alloc] initWithNibName:@"ProfileVC" bundle:nil];
    [self.navigationController pushViewController:contactVC animated:YES];
}
- (IBAction)btnNoClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
