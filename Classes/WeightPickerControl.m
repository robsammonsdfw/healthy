//
//  WeightPickerControl.m
//  DietMasterGo
//
//  Created by DietMaster on 10/14/11.
//  Copyright 2011 Lifestyles Technologies, Inc. All rights reserved.
//

#import "WeightPickerControl.h"

@interface WeightPickerControl ()

@property(nonatomic,retain) UIPickerView *pickerView;
@property(nonatomic,retain) NSMutableArray *arrWeightWhole;
@property(nonatomic,retain) NSMutableArray *arrWeightFraction;

@end

@implementation WeightPickerControl


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSMutableArray *arrWhole=[[NSMutableArray alloc] init];
	NSMutableArray *arrFraction=[[NSMutableArray alloc] init];
	
	
	for (int i = 0; i <=500; i++) {
		//NSNumber *number = [NSNumber numberWithInt:i];
		[arrWhole addObject:[NSNumber numberWithInt:i]];
	}
								 
								 
	for (int f = .1 ; f<=.9; f+=.1)
	{
		NSNumber *fraction = [NSNumber numberWithFloat:f];
		[arrFraction addObject:fraction];
	}
	self.arrWeightWhole = arrWhole;
	self.arrWeightFraction = arrFraction;
	
	[arrWhole release];
	[arrFraction release];
    [super viewDidLoad];
}

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return 2;
}

@end
