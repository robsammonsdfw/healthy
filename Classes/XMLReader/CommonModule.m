
#import "CommonModule.h"
#import "NetConnection.h"
#import <QuartzCore/QuartzCore.h>

@implementation CommonModule

#pragma mark -
#pragma mark Activity Indicator
#pragma mark 

+(void)showActivityIndicator:(BOOL)showhide:(UIActivityIndicatorView*)objactindicator:(UIView*)currView
{
//	UIView *view = [[UIView alloc]init];
//	view.frame = CGRectMake(50, 200, 220, 100);
//	view.backgroundColor = [UIColor darkGrayColor];
//	view.layer.cornerRadius = 10;
//	view.layer.masksToBounds = YES;
	//[currView addSubview:view];
	[currView addSubview:objactindicator];
	
//	UILabel *label = [[UILabel alloc]init];
//	label.frame = CGRectMake(5, 50, 220, 50);
//	label.backgroundColor = [UIColor clearColor];
//	label.textColor = [UIColor whiteColor];
//	label.textAlignment = UITextAlignmentCenter;
//	label.text = strName;
//	[view addSubview:label];
	
	if(showhide)
	{
		[objactindicator startAnimating];
	}
	else
	{
		[objactindicator stopAnimating];
	}
	objactindicator.hidden = !showhide;
	currView.userInteractionEnabled = !showhide;
	

}

+(void)showActivityIndicator:(BOOL)showhide:(UIActivityIndicatorView*)objactindicator:(UIView*)currView:(UIView*)loadingView
{
	if(showhide)
		[objactindicator startAnimating];
	else
		[objactindicator stopAnimating];	
	objactindicator.hidden = !showhide;
	loadingView.hidden = !showhide;
	currView.userInteractionEnabled = !showhide;
}


#pragma mark -
#pragma mark UIAlertView
#pragma mark 

+(void)showAlert:(NSString*)title:(NSString*)message
{
	UIAlertView *alert=[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

+(void)showAlert:(NSString*)title:(NSString*)message:(id)delegate
{
	UIAlertView *alert=[[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}


+(void)showOkCancelAlert:(NSString*)strtitle:(NSString*)strmessage:(NSString*)strfirstTitle:(NSString*)strsecondTitle:(id)delegate
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strtitle message:strmessage delegate:delegate cancelButtonTitle:strfirstTitle otherButtonTitles:strsecondTitle,nil];
	[alert show];
	[alert release];
}


+(BOOL)isiPad
{
	if([[[UIDevice currentDevice] model] isEqualToString:@"iPad"] || [[[UIDevice currentDevice] model] isEqualToString:@"iPad Simulator"])
		return YES;
	return NO;
}


#pragma mark 
#pragma mark Rechability 
#pragma mark 

+ (BOOL)isNetworkReachable 
{
	[[NetConnection sharedReachability] setHostName:@"www.google.com"];
	NetworkStatus remoteHostStatus = [[NetConnection sharedReachability] internetConnectionStatus];
	
	if (remoteHostStatus == NotReachable)
		return NO;
	else if (remoteHostStatus == ReachableViaCarrierDataNetwork || remoteHostStatus == ReachableViaWiFiNetwork)
		return YES;
	return NO;
} 

#pragma mark -
#pragma mark CMLParsing

+(NSMutableArray *) grabRSSFeed:(NSString *)blogAddress:(NSString*)parameter {
	
    // Initialize the blogEntries MutableArray that we declared in the header
    NSMutableArray *blogEntries = [[[NSMutableArray alloc] init] autorelease];	
	
    // Convert the supplied URL string into a usable URL object
    //NSURL *url = [NSURL URLWithString: blogAddress];
    NSString *str =[NSString stringWithFormat:@"%@",blogAddress];
	
    // Create a new rssParser object based on the TouchXML "CXMLDocument" class, this is the  
    // object that actually grabs and processes the RSS data
    //CXMLDocument *rssParser = [[[CXMLDocument alloc] initWithContentsOfURL:url options:0 error:nil] autorelease];
    CXMLDocument *rssParser = [[[CXMLDocument alloc] initWithXMLString:str options:0 error:nil] autorelease];
	
    // Create a new Array object to be used with the looping of the results from the rssParser
    NSArray *resultNodes = NULL;
    	
    // Set the resultNodes Array to contain an object for every instance of an  node in our RSS feed
    resultNodes = [rssParser nodesForXPath:parameter error:nil];
	// Loop through the resultNodes to access each items actual data
    for (CXMLElement *resultElement in resultNodes) {
		
        // Create a temporary MutableDictionary to store the items fields in, which will eventually end up in blogEntries
        NSMutableDictionary *blogItem = [[[NSMutableDictionary alloc] init] autorelease] ;
		
        // Create a counter variable as type "int"
        int counter;
		
        // Loop through the children of the current  node
        for(counter = 0; counter < [resultElement childCount]; counter++) {
            
            if ([[resultElement childAtIndex:counter] stringValue]  == 0) {
                // Add each field to the blogItem Dictionary with the node name as key and node value as the value
                [blogItem setObject:@"" forKey:[[resultElement childAtIndex:counter] name]];
            }
            else {
                // Add each field to the blogItem Dictionary with the node name as key and node value as the value
                [blogItem setObject:[[resultElement childAtIndex:counter] stringValue] forKey:[[resultElement childAtIndex:counter] name]];
            }
			

        }
		
        // Add the blogItem to the global blogEntries Array so that the view can access it.
        [blogEntries addObject:[blogItem copy]];
    }
	return blogEntries;
}
@end
