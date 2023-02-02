//
//  viewData.m
//  DietMasterGo
//
//  Created by DietMaster on 10/17/11.
//  Copyright 2011 Lifestyles Technologies, Inc. All rights reserved.
//

#import "viewData.h"


@implementation viewData

@synthesize fromView, toView, gender,lactation,weight, height;
@synthesize birthDate, goalRate, goalDirection,activity,goalWeight, BMR;

-(id)initWithName:(NSString *)aFromName toViewName:(NSString *)aToViewName; {
	self.fromView = aFromName;
	self.toView = aToViewName;
	return self;
}



@end
