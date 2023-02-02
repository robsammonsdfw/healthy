//
//  TextfieldsWithKeyboardAppDelegate.h
//  TextfieldsWithKeyboard
//
//  Created by Dirk de Kok on 8/13/09.
//  Copyright 2009 D17 software services. Use at your own will.
//  http://www.d17.nl
//

#import <UIKit/UIKit.h>

@class TextfieldsWithKeyboardViewController;

@interface TextfieldsWithKeyboardAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TextfieldsWithKeyboardViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TextfieldsWithKeyboardViewController *viewController;

@end

