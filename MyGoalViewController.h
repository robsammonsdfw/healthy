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

@interface MyGoalViewController : BaseViewController {
	
	IBOutlet UILabel *lbl_weightGoal;
	int num_weightGoal;
		    
    // Graph
    IBOutlet CPTGraphHostingView *_graphHostingView;
    TUTSimpleScatterPlot *_scatterPlot;
    IBOutlet UISegmentedControl *segmentedControl;
    IBOutlet UILabel *noDataLabel;
}
@property (nonatomic, strong) IBOutlet UILabel *goalWeightLbl;
@property (nonatomic, strong) IBOutlet UILabel *WeightLbl;

@property (nonatomic, strong) IBOutlet UIImageView *imgbg;
@property (nonatomic, strong) IBOutlet UIImageView *imgtop;
@property (nonatomic, strong) IBOutlet UIButton *btnrecordyourweight;

@property (nonatomic, strong) UISegmentedControl *segmentedControl;
// Graph
@property (nonatomic, strong) TUTSimpleScatterPlot *scatterPlot;

-(IBAction) showRecordWeightView:(id) sender;
-(IBAction) changeGraphTime:(id) sender;
-(void)getDataForDays:(int)days;

@end
