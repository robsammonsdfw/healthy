//
//  TUTSimpleScatterPlot.h
//  Core Plot Introduction
//
//  Created by John Wordsworth on 20/10/2011.
//

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

@interface TUTSimpleScatterPlot : NSObject <CPTScatterPlotDataSource, CPTScatterPlotDelegate> {
	CPTGraphHostingView *_hostingView;	
	CPTXYGraph *_graph;
	NSMutableArray *_graphData;
    NSMutableArray *_graphDataValues;
    
//    NSMutableArray *_graphData2;
//    NSMutableArray *_graphDataValues2;
    
    CPTLayerAnnotation   *symbolTextAnnotation;
    CPTLayerAnnotation   *symbolText_GoalWeight;
    CATextLayer *TextLayer_GoalWeight;
    float tickDistance;
    float GoalWeightNearestTick;
    float GoalWeight;
}

@property (nonatomic, retain) CPTGraphHostingView *hostingView;
@property (nonatomic, retain) CPTXYGraph *graph;
@property (nonatomic, retain) NSMutableArray *graphData;
@property (nonatomic, retain) NSMutableArray *graphDataValues;
//@property (nonatomic, retain) NSMutableArray *graphData2;
//@property (nonatomic, retain) NSMutableArray *graphDataValues2;

// Methods to create this object and attach it to it's hosting view.
//+(TUTSimpleScatterPlot *)plotWithHostingView:(CPTGraphHostingView *)hostingView andData:(NSMutableArray *)data;
-(id)initWithHostingView:(CPTGraphHostingView *)hostingView andData:(NSMutableArray *)data;
-(id)initWithHostingView:(CPTGraphHostingView *)hostingView;

// Specific code that creates the scatter plot.
-(void)initialisePlot;

-(void)reloadGraphView;

@end
