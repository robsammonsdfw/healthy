//
//  LeanMoreViewController.m
//  
//
//  Created by Henry T Kirk on 5/11/11.
//  Copyright 2011 Henry T Kirk. All rights reserved.
//

#import "LearnMoreViewController.h"

@implementation LearnMoreViewController

@synthesize myWebView, learnMoreTitle, myNavBar;

-(id)init
{
	// cal the superclass initializer
	self = [super initWithNibName:@"LearnMoreViewController" bundle:nil];
	
    return self;
}

-(id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
	return [self init];
}

- (void)dealloc
{
    [super dealloc];

}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Action Methods

- (IBAction)myBackAction:(id)sender {
    
    if ([learnMoreTitle isEqualToString:@"termsofservice"] || [learnMoreTitle isEqualToString:@"privacypolicy"]) {
        
        [self dismissModalViewControllerAnimated:YES];    
        
    } else {
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!myWebView) {
        // Let navBar tell us what height it would prefer at the current orientation
        // Resize navBar
        myWebView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];        
	}
}

- (void)loadWebView {
    	   
    NSString* escapedUrlString = [learnMoreTitle stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        
    myWebView.scalesPageToFit = YES;
	myWebView.delegate = self;
    
    
    if ([learnMoreTitle isEqualToString:@"privacypolicy"] || [learnMoreTitle isEqualToString:@"termsofservice"]) {
        
        // get our defaults
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSString *finalPath = [path stringByAppendingPathComponent:@"AppDefaults.plist"];
        NSDictionary *appDefaults = [[[NSDictionary alloc] initWithContentsOfFile:finalPath] autorelease];
        
        NSString *htmlFile = [[NSBundle mainBundle] pathForResource:escapedUrlString ofType:@"html"];
        NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSASCIIStringEncoding error:nil];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"#APPNAME#" withString:[appDefaults valueForKey:@"app_name_long"]];
        [myWebView loadHTMLString:htmlString baseURL:nil];
        
    } else if ([learnMoreTitle isEqualToString:@"mwlbooklet"]) {
        
        NSURL *websiteUrl = [NSURL URLWithString:@"http://www.Lifestylestech.com/TampaRejuv/mwl_manual_june_2013_mobile.pdf"];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
        [myWebView loadRequest:urlRequest];
        
    } else if ([learnMoreTitle isEqualToString:@"hcgbooklet"]) {
        
        NSURL *websiteUrl = [NSURL URLWithString:@"http://www.Lifestylestech.com/TampaRejuv/hcg_manual_june_2013_mobile.pdf"];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
        [myWebView loadRequest:urlRequest];
        
    }
    
	activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	activityIndicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
	activityIndicator.center = self.view.center;
	[self.view addSubview: activityIndicator];
}

-(IBAction)cancelLearnMore:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated 
{
    
    [super viewWillAppear:animated];
    
    if ([learnMoreTitle isEqualToString:@"privacypolicy"]) {
        
        myNavBar.topItem.title = @"Privacy Policy";
        myNavBar.hidden = NO;
        
        
    } else if ([learnMoreTitle isEqualToString:@"termsofservice"]) {
        
        myNavBar.topItem.title = @"Terms of Service";
        myNavBar.hidden = NO;
        
    }
    
    if ([learnMoreTitle isEqualToString:@"termsofservice"] || [learnMoreTitle isEqualToString:@"privacypolicy"]) {
        
        // fix to accomodate the navigation bar height
        myWebView.frame = CGRectMake(0, myNavBar.frame.size.height, myWebView.frame.size.width,  self.view.frame.size.height - myNavBar.frame.size.height - myNavBar.frame.size.height);
        
    }  else if ([learnMoreTitle isEqualToString:@"mwlbooklet"]) {
        
        myNavBar.topItem.title = @"MWL Booklet";
        myNavBar.hidden = NO;
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        
    } else if ([learnMoreTitle isEqualToString:@"hcgbooklet"]) {
        
        myNavBar.topItem.title = @"HCG Booklet";
        myNavBar.hidden = NO;
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        
    } else {
        
        [[self navigationItem] setTitle:learnMoreTitle];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        
    }
    
    [self loadWebView];
    

}
-(void)viewWillDisappear:(BOOL)animated 
{
    [super viewWillDisappear:animated];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

#pragma mark WEBVIEW Methods


-(IBAction)forwardWebView
{
    [myWebView stopLoading];
    [myWebView goForward];
}
-(IBAction)backWebView
{
    [myWebView stopLoading];
    [myWebView goBack];
}
-(IBAction)stopWebView
{
    [myWebView stopLoading];
}
-(IBAction)refreshWebView 
{
    [myWebView stopLoading];
    [myWebView reload];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	// starting the load, show the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	// finished loading, hide the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[activityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	// load error, hide the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	// report the error inside the webview
	NSString* errorString = [NSString stringWithFormat:
							 @"<html><font size=+6 color='red'>Oops! An Error!</font><br><font size=+5 color='red'>An error occurred. Please tap reload and try again or tap the back button and try later.</font></html>"];
	[myWebView loadHTMLString:errorString baseURL:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    myWebView.delegate = nil;
    activityIndicator = nil;
    myWebView = nil;
    learnMoreTitle = nil;
    myNavBar = nil;
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

@end