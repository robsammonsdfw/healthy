//
//  TDDatePickerController.m
//
//  Created by Nathan  Reed on 30/09/10.
//  Copyright 2010 Nathan Reed. All rights reserved.
//

#import "TDDatePickerController.h"


@implementation TDDatePickerController
@synthesize datePicker, delegate;

-(void)viewDidLoad {
    [super viewDidLoad];

    NSDate* sourceDate = [NSDate date];
    NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
    [dateFormat setTimeZone:systemTimeZone];
    NSString *date_string = [dateFormat stringFromDate:sourceDate];
    NSDate *date_Now = [dateFormat dateFromString:date_string];
    
	datePicker.date = date_Now;

	datePicker.backgroundColor=[UIColor lightGrayColor];
	// we need to set the subview dimensions or it will not always render correctly
	// http://stackoverflow.com/questions/1088163
	for (UIView* subview in datePicker.subviews) {
		//subview.frame = datePicker.bounds;
	}
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.frame = CGRectMake(0, 0, 320, SCREEN_HEIGHT);
}

//// Override to allow orientations other than the default portrait orientation.
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    // Return YES for supported orientations
//    return YES;
//}



#pragma mark -
#pragma mark Actions

-(IBAction)saveDateEdit:(id)sender {
	if([self.delegate respondsToSelector:@selector(datePickerSetDate:)]) {
		[self.delegate datePickerSetDate:self];
	}
}

-(IBAction)clearDateEdit:(id)sender {
	if([self.delegate respondsToSelector:@selector(datePickerClearDate:)]) {
		[self.delegate datePickerClearDate:self];
	}
}

-(IBAction)cancelDateEdit:(id)sender {
	if([self.delegate respondsToSelector:@selector(datePickerCancel:)]) {
		[self.delegate datePickerCancel:self];
	} else {
		// just dismiss the view automatically?
	}
}

#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//- (void)viewDidUnload {
//    [super viewDidUnload];
//
//	self.datePicker = nil;
//	self.delegate = nil;
//
//}

- (void)dealloc {
	self.datePicker = nil;
	self.delegate = nil;

    [super dealloc];
}


@end


