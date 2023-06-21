//
//  LeanMoreViewController.m
//
//
//  Created by Henry T Kirk on 5/11/11.
//  Copyright 2011 Henry T Kirk. All rights reserved.
//

#import "LearnMoreViewController.h"
#import <WebKit/WebKit.h>

@implementation LearnMoreViewController

@synthesize learnMoreTitle, myNavBar;

-(id)init {
    self = [super initWithNibName:@"LearnMoreViewController" bundle:nil];
    return self;
}

-(id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle {
    return [self init];
}

#pragma mark - Action Methods
- (IBAction)myBackAction:(id)sender {
    if ([learnMoreTitle isEqualToString:@"termsofservice"] || [learnMoreTitle isEqualToString:@"privacypolicy"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
        
    if ([learnMoreTitle isEqualToString:@"privacypolicy"]) {
        myNavBar.topItem.title = @"Privacy Policy";
        myNavBar.hidden = NO;
    }
    else if ([learnMoreTitle isEqualToString:@"termsofservice"]) {
        myNavBar.topItem.title = @"Terms of Service";
        myNavBar.hidden = NO;
    }
    else if ([learnMoreTitle isEqualToString:@"mwlbooklet"]) {
        myNavBar.topItem.title = @"MWL Booklet";
        myNavBar.hidden = NO;
    }
    else if ([learnMoreTitle isEqualToString:@"hcgbooklet"]) {
        myNavBar.topItem.title = @"HCG Booklet";
        myNavBar.hidden = NO;
    }
}

- (void)loadWebView {
    NSString* escapedUrlString = [learnMoreTitle stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    if ([learnMoreTitle isEqualToString:@"privacypolicy"] || [learnMoreTitle isEqualToString:@"termsofservice"]) {
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSString *finalPath = [path stringByAppendingPathComponent:PLIST_NAME];
        NSDictionary *appDefaults = [[NSDictionary alloc] initWithContentsOfFile:finalPath];
        
        NSString *htmlFile = [[NSBundle mainBundle] pathForResource:escapedUrlString ofType:@"html"];
        NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSASCIIStringEncoding error:nil];
        
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"#APPNAME#" withString:[appDefaults valueForKey:@"app_name_short"]];
        
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"#SUPPORTEMAIL#" withString:[appDefaults valueForKey:@"support_email"]];
        
        [_webView loadHTMLString:htmlString baseURL:nil];
    }
    else if ([learnMoreTitle isEqualToString:@"mwlbooklet"]) {
        
//        NSURL *websiteUrl = [NSURL URLWithString:@"http://www.Lifestylestech.com/TampaRejuv/mwl_manual_june_2013_mobile.pdf"];
//        NSURLRequest *request = [NSURLRequest requestWithURL:websiteUrl];
//
//        _webView = [[WKWebView alloc] initWithFrame:self.view.frame];
//        [_webView loadRequest:request];
//        _webView.frame = CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
//        [self.view addSubview:_webView];

        
        
        NSURL *websiteUrl = [NSURL URLWithString:@"http://www.Lifestylestech.com/TampaRejuv/mwl_manual_june_2013_mobile.pdf"];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
        [_webView loadRequest:urlRequest];
    }
    else if ([learnMoreTitle isEqualToString:@"hcgbooklet"]) {
        
//        NSURL *websiteUrl = [NSURL URLWithString:@"http://www.Lifestylestech.com/TampaRejuv/hcg_manual_june_2013_mobile.pdf"];
//        NSURLRequest *request = [NSURLRequest requestWithURL:websiteUrl];
//
//        _webView = [[WKWebView alloc] initWithFrame:self.view.frame];
//        [_webView loadRequest:request];
//        _webView.frame = CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
//        [self.view addSubview:_webView];
        
        
        NSURL *websiteUrl = [NSURL URLWithString:@"http://www.Lifestylestech.com/TampaRejuv/hcg_manual_june_2013_mobile.pdf"];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
        [_webView loadRequest:urlRequest];
        
    }
    
    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    activityIndicator.center = self.view.center;
    [self.view addSubview: activityIndicator];
}

-(IBAction)cancelLearnMore:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([learnMoreTitle isEqualToString:@"termsofservice"] || [learnMoreTitle isEqualToString:@"privacypolicy"]) {        
        myNavBar.hidden = NO;
    }
    else {
        [[self navigationItem] setTitle:learnMoreTitle];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    
    [self loadWebView];
}

@end
