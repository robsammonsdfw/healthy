//
//  MyGoalViewController.h
//  DietMasterGo
//
//  Created by Andrew Moffitt on 11/23/10.
//  Copyright 2010 AE Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CorePlot-CocoaTouch.h"
#import "TUTSimpleScatterPlot.h"

@interface MyGoalViewController : UIViewController {
	
	IBOutlet UILabel *lbl_weightGoal;
	int num_weightGoal;
		    
    // Graph
    IBOutlet CPTGraphHostingView *_graphHostingView;
    TUTSimpleScatterPlot *_scatterPlot;
    IBOutlet UISegmentedControl *segmentedControl;
    IBOutlet UILabel *noDataLabel;
}
@property (retain, nonatomic) IBOutlet UILabel *goalWeightLbl;
@property (retain, nonatomic) IBOutlet UILabel *WeightLbl;

@property (retain, nonatomic) IBOutlet UIImageView *imgbg;
@property (retain, nonatomic) IBOutlet UIImageView *imgtop;
@property (retain, nonatomic) IBOutlet UIButton *btnrecordyourweight;

@property (nonatomic, retain) UISegmentedControl *segmentedControl;
// Graph
@property (nonatomic, retain) TUTSimpleScatterPlot *scatterPlot;
@property (retain, nonatomic) IBOutlet UIView *popUpView;
@property (retain, nonatomic) IBOutlet UIView *showPopUpVw;

-(IBAction) showRecordWeightView:(id) sender;
-(IBAction) changeGraphTime:(id) sender;
-(void)getDataForDays:(int)days;

@end
