//
//  MyMovesVideoPlayerViewController.m
//  MyMoves
//
//  Created by CIPL0688 on 9/27/19.
//

#import "MyMovesVideoPlayerViewController.h"
#import <WebKit/WebKit.h>

@interface MyMovesVideoPlayerViewController ()
@property (nonatomic, strong) IBOutlet WKWebView *webVw;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activitySpinner;

@end

@implementation MyMovesVideoPlayerViewController

- (instancetype)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [_activitySpinner startAnimating];
    NSArray* words = [_videoUrlStr componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* nospacestring = [words componentsJoinedByString:@""];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:[NSURL URLWithString:nospacestring]];
    [_webVw loadRequest:nsrequest];
    [self.view addSubview:_webVw];
}

@end
