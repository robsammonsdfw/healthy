//
//  BaseViewController.m
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 7/5/23.
//

#import "BaseViewController.h"

@interface BaseViewController ()
@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:AppConfiguration.headerTextColor];

    self.navigationController.navigationBar.prefersLargeTitles = NO;
    
    NSDictionary *textColor = @{NSForegroundColorAttributeName : AppConfiguration.headerTextColor};
    
    UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
    appearance.backgroundColor = AppConfiguration.headerColor;
    appearance.titleTextAttributes = textColor;
    appearance.largeTitleTextAttributes = textColor;
    
    self.navigationController.navigationBar.barTintColor = AppConfiguration.headerColor;
    self.navigationController.navigationBar.tintColor = AppConfiguration.headerTextColor;
    self.navigationController.navigationBar.standardAppearance = appearance;
    self.navigationController.navigationBar.compactAppearance = appearance;
    self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    self.navigationController.navigationBar.compactScrollEdgeAppearance = appearance;
}

@end
