//
//  BodyTypePickerView.m
//  DietMasterGo
//
//  Created by DietMaster on 11/4/11.
//  Copyright 2011 Lifestyles Technologies, Inc. All rights reserved.
//

#import "BodyTypePickerView.h"
#import "DietMasterGoAppDelegate.h"
#import "DietMasterGoViewController.h"


@implementation BodyTypePickerView

@synthesize mainDelegate,sourceName,apassedData;
@synthesize bodyTypePicker, bodyTypePickerData;

-(id)initWithText:(NSString *)passedText passedData:(viewData *)dataParameter
{
	//NSLog(@"In RecordWeightView before conditional check");
	if (self = [self initWithNibName:@"BodyTypePickerView" bundle:nil]) {
		self.apassedData = dataParameter;
		self.sourceName= [apassedData fromView];
		// NSLog(@"In BodyTypePickerView- initWithText = %@", self.apassedData.fromView);
	}
	return self;
}
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
 NSArray *tempArray = [[NSArray alloc] initWithObjects:@"I find it hard to lose weight",@"I can adjust my habits",@"I lose weight very easily", nil];
 self.bodyTypePickerData = tempArray;
 [tempArray release];
 
 
 mainDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
 dbPath	= [mainDelegate getDBPath];
	
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
 [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}
-(IBAction)saveBodyType:(id)sender {
	
	NSInteger bodyTypeRow = [bodyTypePicker	selectedRowInComponent:0];
	
	
	UIAlertView *view;
	
	//NSNumber *newWeight = [NSNumber numberWithInt:[txtfieldWeight.text intValue]];
	
	// Log
	// NSLog(@"Row selected: %i", bodyTypeRow);
	
	// Check for value
	if (bodyTypeRow < 0) {
		
		view = [[UIAlertView alloc]
				initWithTitle: @"Input Error"
				message: @"Please Select a Activity Level"
				delegate: self
				cancelButtonTitle: @"OK"
				otherButtonTitles: nil];
		[view show];
		[view autorelease];
		
	} else {
		
		dbPath	= [mainDelegate getDBPath];
		
		//NSLog(@"DBPATH : %@", dbPath);
		sqlite3_stmt *statement;
		//NSNumber *newWeight = [NSNumber numberWithFloat:[txtfieldWeight.text doubleValue]];
		
		NSString *updateSQL = [NSString stringWithFormat: @"UPDATE user SET BodyType = %i", bodyTypeRow];
		
		// NSLog(@"SQL: %@", updateSQL);
		
		const char *update_stmt = [updateSQL UTF8String];
		
		if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
			
			if(sqlite3_prepare_v2(database, update_stmt, -1, &statement, NULL) != SQLITE_OK) {
				// NSLog(@"Error preparing statement");
			} else {
				
				if (sqlite3_step(statement) == SQLITE_DONE)	{
					
					// Return to Next Screen
					
					/*
					// NSLog(@"Goto Main Screen");
					DietMasterGoViewController *dvController = [[DietMasterGoViewController alloc] initWithNibName:@"DietMasterGoViewController" bundle:nil];
					[self.navigationController pushViewController:dvController animated:YES];
					[dvController release];
					dvController = nil;
					[mainDelegate dismissModalViewControllerAnimated:YES];
					 */
					
					apassedData.fromView = @"BodyTypePicker";
					apassedData.toView= @"DietMasterGoViewController";
					DietMasterGoViewController *mainGo = [[DietMasterGoViewController alloc] initWithText:@"FromDietWizard" passedData:apassedData];
					[self.navigationController pushViewController:mainGo animated:YES];
					//[mainGo dismissModalViewControllerAnimated:YES];
					//[self presentModalViewController:mainGo animated:YES];
					

					[mainGo release];
					mainGo =nil;
					
				} else {
					NSAssert1(0, @"Error while updating data. '%s'", sqlite3_errmsg(database));
				}
			}
			
		}
		
		
		
	}
}

#pragma mark -
#pragma mark Picker Data Source Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [bodyTypePickerData count];
}
#pragma mark Picker Delegate Methods
- (NSString *)pickerView:
(UIPickerView *)pickerView titleForRow:
(NSInteger)row forComponent:(NSInteger)component
{
	return [bodyTypePickerData objectAtIndex:row];
}
@end
