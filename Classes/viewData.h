//
//  viewData.h
//  DietMasterGo
//
//  Created by DietMaster on 10/17/11.
//  Copyright 2011 Lifestyles Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface viewData : NSObject {
	NSString *fromView;
	NSString *toView;
	int gender;
	int lactation;
	int goalDirection;
	float goalRate;
	float height;
	float weight;
	float goalWeight;
	int activity;
	int BMR;
	NSDate *birthDate;
}

@property (nonatomic,retain) NSString *fromView;
@property (nonatomic,retain) NSString *toView;
@property (nonatomic) int gender;
@property (nonatomic) int lactation;
@property (nonatomic) int goalDirection;
@property (nonatomic) float height;
@property (nonatomic) float goalRate;
@property (nonatomic) float weight;
@property (nonatomic) int activity;
@property (nonatomic) float goalWeight;
@property (nonatomic) int BMR;
@property (nonatomic,retain) NSDate *birthDate;


-(id)initWithName:(NSString *)aFromView
	   toViewName:(NSString *)aToViewName;

@end
