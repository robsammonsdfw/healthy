//
//  Common.h
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// UI Helpers

#define    IsPortrait               UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])
#define    IsLandscape              UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])

#define    WINDOW_WIDTH             [UIScreen mainScreen].applicationFrame.size.width    ///< i.e. for iPhone it is 320 for portrait and 300 for landscape orientation
#define    WINDOW_HEIGHT            [UIScreen mainScreen].applicationFrame.size.height   ///< i.e. for iPhone it is 460 for portrait and 480 for landscape orientation
#define    WINDOW_WIDTH_ORIENTED    (IsPortrait ? WINDOW_WIDTH : WINDOW_HEIGHT)          ///< i.e. 320 for portrait and 480 for landscape orientation
#define    WINDOW_HEIGHT_ORIENTED   (IsPortrait ? WINDOW_HEIGHT : WINDOW_WIDTH)          ///< i.e. 460 for portrait and 320 for landscape orientation

#define    SCREEN_WIDTH             [UIScreen mainScreen].bounds.size.width
#define    SCREEN_HEIGHT            [UIScreen mainScreen].bounds.size.height
#define    SCREEN_WIDTH_ORIENTED    (IsPortrait ? SCREEN_WIDTH : SCREEN_HEIGHT)
#define    SCREEN_HEIGHT_ORIENTED   (IsPortrait ? SCREEN_HEIGHT : SCREEN_WIDTH)

#define    NAVBAR_HEIGHT            (IsLandscape && IsIPhone ? 32. : 44.)
#define    TOOLBAR_HEIGHT           44.
#define    TABBAR_HEIGHT            49.

#define    KEYBOARD_SIZE_PORTRAIT   (IsIPhone ? CGSizeMake(320, 216) : CGSizeMake(768, 264))
#define    KEYBOARD_SIZE_LANDSCAPE  (IsIPhone ? CGSizeMake(480, 162) : CGSizeMake(1024, 352))
#define    KEYBOARD_SIZE            (IsPortrait ? KEYBOARD_SIZE_PORTRAIT : KEYBOARD_SIZE_LANDSCAPE)

#define    AUTORESIZE_CENTER        (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)
#define    AUTORESIZE_STRETCH       (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)

// Debug functions
#pragma mark - Debug functions

#define   SHOW_LOGS             YES
#define   SHOW_TEXTURES_LOGS    NO
#define   Log(format, ...)      if (SHOW_LOGS) DMLog(@"%s: %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:format, ## __VA_ARGS__]);
#define   TexLog(format, ...)   if (SHOW_LOGS && SHOW_TEXTURES_LOGS) DMLog(@"%s: %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:format, ## __VA_ARGS__]);
#define   Error(format, ...)    if (SHOW_LOGS) DMLog(@"ERROR: %@", [NSString stringWithFormat:format, ## __VA_ARGS__]);
#define   Mark                  if (SHOW_LOGS) DMLog(@"%s", __PRETTY_FUNCTION__);

// Default Paths
#pragma mark - Paths

#define   BundlePath                    [[NSBundle mainBundle] resourcePath]
#define   PathToResource(resourceName)  [BundlePath stringByAppendingPathComponent:resourceName]

#define   DocumentsPath                 [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define   LibraryPath                   [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define   SharedDataPath                DocumentsPath

#define   CriticalDataPath              criticalDataPath()
#define   OfflineDataPath               offlineDataPath()
#define   CachedDataPath                [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define   TemporaryDataPath             [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"]

// Misc
#pragma mark - Misc

#define   Localized(string)         NSLocalizedString(string, @"")

#define   CGRectGetCenter(rect)     CGPointMake(floorf(0.5 * rect.size.width), floorf(0.5 * rect.size.height))
#define   CGRectGetMidPoint(rect)   CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))

#define   CGAffineTransformGetScale(transform)        CGPointMake(sqrtf(transform.a * transform.a + transform.c * transform.c), sqrtf(transform.b * transform.b + transform.d * transform.d))
#define   CGAffineTransformGetRotateAngle(transform)  atan2f(transform.b, transform.a)

static UIColor *UIColorFromHex(int hexColor)
{
	UIColor* colorResult = [UIColor colorWithRed:(hexColor>>16&0xFF)/255. green:(hexColor>>8&0xFF)/255. blue:(hexColor>>0&0xFF)/255. alpha:1];
	return colorResult;
}

BOOL isIPad();
BOOL isRetina();

BOOL addSkipBackupAttributeToFile(NSString *filePath);

NSString *criticalDataPath();
NSString *offlineDataPath();

id loadNib(Class aClass, NSString *nibName, id owner);
id loadNibForCell(NSString *identifier, NSString *nibName, id owner);

CGSize CGSizeScaledToFitSize(CGSize size1, CGSize size2);
CGSize CGSizeScaledToFillSize(CGSize size1, CGSize size2);
CGRect CGRectWithSize(CGSize size);
CGRect CGRectFillRect(CGRect rect1, CGRect rect2);

CGRect CGRectExpandToLabel(UILabel *label);

void ShowAlert(NSString *title, NSString *message);

static UIEdgeInsets viewInsetsInSuperview(UIView *view) {
	UIEdgeInsets insets;
	insets.top = CGRectGetMinY(view.frame);
	insets.bottom = CGRectGetHeight(view.superview.bounds)-CGRectGetMaxY(view.frame);
	insets.left = CGRectGetMinX(view.frame);
	insets.right = CGRectGetWidth(view.superview.bounds)-CGRectGetMaxX(view.frame);
	return insets;
}


