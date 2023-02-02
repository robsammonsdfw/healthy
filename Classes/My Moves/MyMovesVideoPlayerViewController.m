//
//  MyMovesVideoPlayerViewController.m
//  MyMoves
//
//  Created by CIPL0688 on 9/27/19.
//

#import "MyMovesVideoPlayerViewController.h"

@interface MyMovesVideoPlayerViewController ()
@property (retain, nonatomic) IBOutlet WKWebView *webVw;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activitySpinner;

@end

@implementation MyMovesVideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [_activitySpinner startAnimating];
    NSArray* words = [_videoUrlStr componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* nospacestring = [words componentsJoinedByString:@""];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:[NSURL URLWithString:nospacestring]];
    [_webVw loadRequest:nsrequest];
    [self.view addSubview:_webVw];
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [_webVw release];
    [_activitySpinner release];
    [super dealloc];
}
@end
