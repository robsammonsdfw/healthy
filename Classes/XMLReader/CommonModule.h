
#import <Foundation/Foundation.h>
#import "ASIHTTPRequestDelegate.h"
#import "TouchXML.h"

@interface CommonModule : NSObject 
{
    id <ASIHTTPRequestDelegate> delegate;
}

+(void)showActivityIndicator:(BOOL)showhide:(UIActivityIndicatorView*)objactindicator:(UIView*)currView;
+(void)showActivityIndicator:(BOOL)showhide:(UIActivityIndicatorView*)objactindicator:(UIView*)currView:(UIView*)loadingView;
+(void)showAlert:(NSString*)title:(NSString*)message;
+(void)showAlert:(NSString*)title:(NSString*)message:(id)delegate;
+(void)showOkCancelAlert:(NSString*)strtitle:(NSString*)strmessage:(NSString*)strfirstTitle:(NSString*)strsecondTitle:(id)delegate;
+(BOOL)isiPad;
+ (BOOL)isNetworkReachable;
+(NSMutableArray *) grabRSSFeed:(NSString *)blogAddress:(NSString*)parameter;
//+(NSString *)ASIHTTPParsingGET:(NSURL *)url param1:(NSString *)param1 param2:(NSString *)param2;
//+(NSString *)ASIHTTPParsingPOST:(NSURL *)url param1:(NSString *)param1 param2:(NSString *)param2 param3:(NSString *)param3 param4:(NSString *)param4 param5:(NSString *)param5;
@end
