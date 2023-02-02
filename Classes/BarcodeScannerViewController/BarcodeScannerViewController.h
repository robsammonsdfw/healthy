//
//  BarcodeScannerViewController.h
//  DietMasterGo
//
//  Created by Henry T Kirk on 4/12/13.
//
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "ZXingObjC.h"
#import "zbar.h"
#import "ZBarReaderViewController.h"

@interface BarcodeScannerViewController : UIViewController <ZXCaptureDelegate, UIGestureRecognizerDelegate,ZBarReaderDelegate> {
    
    int resultCount;
    
}

@property (nonatomic, retain) ZXCapture* capture;
@property (nonatomic, assign) IBOutlet UILabel* decodedLabel;
@property (nonatomic, assign) IBOutlet UILabel* noteLabel;
@property (nonatomic, assign) IBOutlet UILabel* tapLabel;
@property (nonatomic, assign) IBOutlet UIActivityIndicatorView *spinner;

- (NSString*)displayForResult:(ZXResult*)result;
- (IBAction)dismissOverlayView:(id)sender;
- (void) dismissFocusRect;
- (void)focusAtPoint:(id) sender;

@end
