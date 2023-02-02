//
//  LeanMoreViewController.h
//  
//
//  Created by Henry T Kirk on 5/11/11.
//  Copyright 2011 Henry T Kirk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface LearnMoreViewController : UIViewController <UINavigationBarDelegate> {
	UIActivityIndicatorView *activityIndicator;
    NSString *learnMoreTitle;
    IBOutlet UINavigationBar *myNavBar;
}

@property (nonatomic,copy) NSString *learnMoreTitle;
@property (nonatomic,retain) IBOutlet UINavigationBar *myNavBar;
@property (retain, nonatomic) IBOutlet WKWebView *webView;

-(IBAction)cancelLearnMore:(id)sender;
-(void)loadWebView;
-(IBAction)forwardWebView;
-(IBAction)backWebView;
-(IBAction)stopWebView;
-(IBAction)refreshWebView;
-(IBAction)myBackAction:(id)sender;

@end

