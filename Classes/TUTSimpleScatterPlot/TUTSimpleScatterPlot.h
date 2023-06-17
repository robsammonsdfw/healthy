//
//  TUTSimpleScatterPlot.h
//  Core Plot Introduction
//
//  Created by John Wordsworth on 20/10/2011.
//

#import <Foundation/Foundation.h>
#import <CorePlot/CorePlot.h>
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

@property (nonatomic, strong) CPTGraphHostingView *hostingView;
@property (nonatomic, strong) CPTXYGraph *graph;
@property (nonatomic, strong) NSMutableArray *graphData;
@property (nonatomic, strong) NSMutableArray *graphDataValues;
//@property (nonatomic, strong) NSMutableArray *graphData2;
//@property (nonatomic, strong) NSMutableArray *graphDataValues2;

// Methods to create this object and attach it to it's hosting view.
//+(TUTSimpleScatterPlot *)plotWithHostingView:(CPTGraphHostingView *)hostingView andData:(NSMutableArray *)data;
-(id)initWithHostingView:(CPTGraphHostingView *)hostingView andData:(NSMutableArray *)data;
-(id)initWithHostingView:(CPTGraphHostingView *)hostingView;

// Specific code that creates the scatter plot.
-(void)initialisePlot;

-(void)reloadGraphView;

@end
