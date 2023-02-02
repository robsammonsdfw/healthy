//
//  TextfieldsWithKeyboardAppDelegate.m
//  TextfieldsWithKeyboard
//
//  Created by Dirk de Kok on 8/13/09.
//  Copyright 2009 D17 software services. Use at your own will.
//  http://www.d17.nl
//

#import "TextfieldsWithKeyboardAppDelegate.h"
#import "TextfieldsWithKeyboardViewController.h"

@implementation TextfieldsWithKeyboardAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
