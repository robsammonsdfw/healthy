

#import "OtherHealthServiceVC.h"
#import "ProfileContactVC.h"
#import "DietMasterGoViewController.h"
#import "LoginViewController.h"

@interface OtherHealthServiceVC ()

@end

@implementation OtherHealthServiceVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationItem.hidesBackButton = YES;
    self.title=@"FitKloud";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationItem.hidesBackButton = YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnYesClicked:(id)sender {
    ProfileContactVC  *desVc= [[ProfileContactVC alloc] initWithNibName:@"ProfileContactVC" bundle:nil];
    [self.navigationController pushViewController:desVc animated:YES];
}

- (IBAction)btnNoClicked:(id)sender {
    [[NSUserDefaults standardUserDefaults]setObject:@"False" forKey:@"Reserved"];
    if(AppDel.loginViewController){
        [AppDel.loginViewController syncUserInfo:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        AppDel.loginViewController = [[LoginViewController alloc] init];
        [AppDel.loginViewController syncUserInfo:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
@end
