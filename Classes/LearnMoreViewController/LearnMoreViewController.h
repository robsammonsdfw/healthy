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
    NSString *learnMoreTitle;
    IBOutlet UINavigationBar *myNavBar;
}

@property (nonatomic,copy) NSString *learnMoreTitle;
@property (nonatomic,retain) IBOutlet UINavigationBar *myNavBar;
@property (nonatomic, strong) IBOutlet WKWebView *webView;

@end

