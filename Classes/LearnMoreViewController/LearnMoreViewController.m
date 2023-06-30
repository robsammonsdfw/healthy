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

- (instancetype)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    return self;
}

#pragma mark - Actions

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
}

- (void)loadWebView {
    NSString* escapedUrlString = [learnMoreTitle stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    if ([learnMoreTitle isEqualToString:@"privacypolicy"] || [learnMoreTitle isEqualToString:@"termsofservice"]) {
        NSString *appNameShort = [DMGUtilities configValueForKey:@"app_name_short"];
        NSString *supportEmail = [DMGUtilities configValueForKey:@"support_email"];
        
        NSString *htmlFile = [[NSBundle mainBundle] pathForResource:escapedUrlString ofType:@"html"];
        NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSASCIIStringEncoding error:nil];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"#APPNAME#" withString:appNameShort];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"#SUPPORTEMAIL#" withString:supportEmail];
        
        [_webView loadHTMLString:htmlString baseURL:nil];
    }
}

- (IBAction)cancelLearnMore:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
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
