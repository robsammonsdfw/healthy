//
//  BarcodeScannerViewController.m
//  DietMasterGo
//
//  Created by Henry T Kirk on 4/12/13.
//
//

#import "BarcodeScannerViewController.h"

@interface BarcodeScannerViewController ()
{
    
}
@property(nonatomic,retain)IBOutlet UIView *mainvw;

@end

@implementation BarcodeScannerViewController

@synthesize capture,mainvw;
@synthesize decodedLabel;
@synthesize noteLabel;
@synthesize tapLabel;
@synthesize spinner;

- (id)init
{
    self = [super initWithNibName:@"BarcodeScannerViewController" bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    resultCount = 0;
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        self.capture = nil;
        self.capture = [[ZXCapture alloc] init];
        self.capture.delegate = self;
        self.capture.rotation = 90.0f;
        // Use the back camera
        self.capture.camera = self.capture.back;
        self.capture.layer.frame = self.view.bounds;
        [self.view.layer insertSublayer:self.capture.layer atIndex:0];
        [self.view setNeedsDisplay];
        
        
//        ZBarReaderViewController *reader = [ZBarReaderViewController new];
//        reader.readerDelegate = self;
//        reader.supportedOrientationsMask = ZBarOrientationMaskAll;
//        
//        ZBarImageScanner *scanner = reader.scanner;
//        // TODO: (optional) additional reader configuration here
//        
//        // EXAMPLE: disable rarely used I2/5 to improve performance
//        [scanner setSymbology: ZBAR_I25
//                       config: ZBAR_CFG_ENABLE
//                           to: 0];
//        
//        // present and release the controller
//        [self.view addSubview:reader.view];
        

    });
    
    
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^
    //                   {
    //                                         });
    //
//    double delayInSeconds = 1.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
//                   {
    
                      // [spinner stopAnimating];
                       self.view.backgroundColor = [UIColor clearColor];
                       
                       
                  // });
    

}

//-(void)viewDidUnload {
//    [super viewDidUnload];
//
//    self.capture = nil;
//    decodedLabel = nil;
//    noteLabel = nil;
//    tapLabel = nil;
//    spinner = nil;
//
//}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [spinner startAnimating];
    
    self.noteLabel.layer.cornerRadius = 8.0;
    self.noteLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.noteLabel.layer.borderWidth = 1.0;

    self.tapLabel.layer.cornerRadius = 8.0;
    self.tapLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.tapLabel.layer.borderWidth = 1.0;
    
    UITapGestureRecognizer* tapScanner = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusAtPoint:)];
    tapScanner.numberOfTapsRequired = 1;
    tapScanner.numberOfTapsRequired = 1;
    [tapScanner setCancelsTouchesInView:NO];
    [self.mainvw addGestureRecognizer:tapScanner];
    [tapScanner release];
    
    
    
}

//-(void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    
//    self.capture = nil;
//    self.capture = [[ZXCapture alloc] init];
//    self.capture.delegate = self;
//    self.capture.rotation = 90.0f;
//    // Use the back camera
//    self.capture.camera = self.capture.back;
//    self.capture.layer.frame = self.view.bounds;
//    [self.view.layer insertSublayer:self.capture.layer atIndex:0];
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^
//       {
//           [spinner stopAnimating];
//           self.view.backgroundColor = [UIColor clearColor];
//       });
//
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    /*
    [capture release];
    [decodedLabel release];
    [noteLabel release];
    [tapLabel release];
    [spinner release];
    */
    self.capture = nil;
    decodedLabel = nil;
    noteLabel = nil;
    tapLabel = nil;
    spinner = nil;

    [super dealloc];
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
//    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
//}

#pragma mark - Private Methods

- (NSString*)displayForResult:(ZXResult*)result {
    NSString *formatString;
    switch (result.barcodeFormat) {
        case kBarcodeFormatAztec:
            formatString = @"Aztec";
            break;
            
        case kBarcodeFormatCodabar:
            formatString = @"CODABAR";
            break;
            
        case kBarcodeFormatCode39:
            formatString = @"Code 39";
            break;
            
        case kBarcodeFormatCode93:
            formatString = @"Code 93";
            break;
            
        case kBarcodeFormatCode128:
            formatString = @"Code 128";
            break;
            
        case kBarcodeFormatDataMatrix:
            formatString = @"Data Matrix";
            break;
            
        case kBarcodeFormatEan8:
            formatString = @"EAN-8";
            break;
            
        case kBarcodeFormatEan13:
            formatString = @"EAN-13";
            break;
            
        case kBarcodeFormatITF:
            formatString = @"ITF";
            break;
            
        case kBarcodeFormatPDF417:
            formatString = @"PDF417";
            break;
            
        case kBarcodeFormatQRCode:
            formatString = @"QR Code";
            break;
            
        case kBarcodeFormatRSS14:
            formatString = @"RSS 14";
            break;
            
        case kBarcodeFormatRSSExpanded:
            formatString = @"RSS Expanded";
            break;
            
        case kBarcodeFormatUPCA:
            formatString = @"UPCA";
            break;
            
        case kBarcodeFormatUPCE:
            formatString = @"UPCE";
            break;
            
        case kBarcodeFormatUPCEANExtension:
            formatString = @"UPC/EAN extension";
            break;
            
        default:
            formatString = @"Unknown";
            break;
    }
    
    return [NSString stringWithFormat:@"Scanned!\n\nFormat: %@\n\nContents:\n%@", formatString, result.text];
}

#pragma mark - ZXCaptureDelegate Methods

- (void)captureResult:(ZXCapture*)capture result:(ZXResult*)result {
    
    if (result) {
        
        resultCount++;
        if (resultCount > 1) {
            return;
        }
        
        AppDel.isFromBarcode = YES;
        [self.capture stop];

        // Vibrate
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        NSDictionary *upcDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 result.text, @"UPC",
                                 nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BarcodeScanned" object:nil
                                                          userInfo:upcDict];

        [upcDict release];
        //[self dismissOverlayView:nil];
        
        [self.capture.layer removeFromSuperlayer];
        [self.capture stop];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } else {
        
        resultCount = 0;
        
        // error occurred. try again!
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"An error occurred while scanning. Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert setTag:90099];
        [alert show];
        [alert release];
        

    }
}

- (void)captureSize:(ZXCapture*)capture width:(NSNumber*)width height:(NSNumber*)height {
    
}


- (IBAction)dismissOverlayView:(id)sender {
    
    UIView *blackView = [[UIView alloc] initWithFrame:self.view.frame];
    blackView.backgroundColor = [UIColor blackColor];
    blackView.alpha = 0.0;
    [self.view addSubview:blackView];
    [self.view sendSubviewToBack:blackView];
    blackView.alpha = 1.0;
    [self.capture.layer removeFromSuperlayer];
    [self.capture stop];
    [self dismissViewControllerAnimated:YES completion:nil];

}

#pragma mark TAP TO FOCUS

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    return YES; // handle the touch
}

- (void)focusAtPoint:(id) sender {
    
    CGPoint touchPoint = [(UITapGestureRecognizer*)sender locationInView:self.view];
    
    // check if tapped bottom bar
    if (CGRectContainsPoint(CGRectMake(0, SCREEN_HEIGHT-44, 320, 44), touchPoint)) {
        return;
    }
    
    double focus_x = touchPoint.x/self.view.frame.size.width;
    double focus_y = (touchPoint.y+66)/self.view.frame.size.height;
    NSError *error;
    NSArray *devices = [AVCaptureDevice devices];
    for (AVCaptureDevice *device in devices){
        if ([device hasMediaType:AVMediaTypeVideo]) {
            if ([device position] == AVCaptureDevicePositionBack) {
                CGPoint point = CGPointMake(focus_y, 1-focus_x);
                if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus] && [device lockForConfiguration:&error]){
                    [device setFocusPointOfInterest:point];
                    CGRect rect = CGRectMake(touchPoint.x-30, touchPoint.y-30, 60, 60);
                    UIView *focusRect = [[UIView alloc] initWithFrame:rect];
                    focusRect.layer.borderColor = [UIColor whiteColor].CGColor;
                    focusRect.layer.borderWidth = 2;
                    focusRect.tag = 99;
                    [self.view addSubview:focusRect];
                    [NSTimer scheduledTimerWithTimeInterval: 1
                                                     target: self
                                                   selector: @selector(dismissFocusRect)
                                                   userInfo: nil
                                                    repeats: NO];
                    [device setFocusMode:AVCaptureFocusModeAutoFocus];
                    [device unlockForConfiguration];
                    [focusRect release];
                }
            }
        }
    }
}

- (void) dismissFocusRect {
    for (UIView *subView in self.view.subviews)
    {
        if (subView.tag == 99)
        {
            [subView removeFromSuperview];
        }
    }
}

@end
