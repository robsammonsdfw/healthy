#import "TUTSimpleScatterPlot.h"
#import "DietmasterEngine.h"

@implementation TUTSimpleScatterPlot
@synthesize hostingView = _hostingView;
@synthesize graph = _graph;
@synthesize graphData = _graphData;
@synthesize graphDataValues = _graphDataValues;

-(id)initWithHostingView:(CPTGraphHostingView *)hostingView andData:(NSMutableArray *)data {
    self = [super init];
    
    if ( self != nil ) {
        self.hostingView = hostingView;
        self.graphData = data;
        self.graph = nil;
    }
    return self;
}

-(id)initWithHostingView:(CPTGraphHostingView *)hostingView {
    self = [super init];
    if ( self != nil ) {
        self.hostingView = hostingView;
        self.graph = nil;
    }
    return self;
}

-(void)initialisePlot {
    GoalWeight = [self getGoalWeightFromDB];
    if ( (self.hostingView == nil) || (self.graphData == nil) ) {
        return;
    }
    
    if ( self.graph != nil ) {
        return;
    }
    
    CGRect frame = [self.hostingView bounds];
    self.graph = [[[CPTXYGraph alloc] initWithFrame:frame] autorelease];
    
    self.graph.plotAreaFrame.paddingTop = 25.0f;
    self.graph.plotAreaFrame.paddingRight = 50.0f;
    self.graph.plotAreaFrame.paddingBottom = 45.0f;
    self.graph.plotAreaFrame.paddingLeft = 15.0f;
    
    self.hostingView.hostedGraph = self.graph;
    
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor blackColor];
    lineStyle.lineWidth = 2.0f;
    
    CPTMutableLineStyle *lineStyle2 = [CPTMutableLineStyle lineStyle];
    lineStyle2.lineColor = [CPTColor blackColor];
    lineStyle2.lineWidth = 0.6f;
    
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.fontName = @"Helvetica";
    textStyle.fontSize = 12; //13;
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:PLIST_NAME];
    NSDictionary *appDefaults = [[[NSDictionary alloc] initWithContentsOfFile:finalPath] autorelease];
    
    if ([[appDefaults valueForKey:@"account_code"] isEqualToString:@"ezdietplanner"]) {
        textStyle.color = [CPTColor blackColor];
    }
    else {
        textStyle.color = [CPTColor blackColor];
    }
    
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    if ([[appDefaults valueForKey:@"account_code"] isEqualToString:@"ezdietplanner"]) {
        // Custom
        plotSymbol.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
    }
    else {
        plotSymbol.fill = [CPTFill fillWithColor:[CPTColor redColor]];
    }
    
    plotSymbol.lineStyle = lineStyle;
    plotSymbol.size = CGSizeMake(7.0, 7.0);
    
    float  maxX = 0.0f;
    float  minX = 0.0f;
    float  maxY = 0.0f;
    float  minY = [self getGoalWeightFromDB];
    
    for (NSMutableDictionary *dict in self.graphDataValues)  {
        CGPoint point = [[dict valueForKey:@"point"] CGPointValue];
        NSNumber *x = [NSNumber numberWithFloat:point.x];
        NSNumber *y = [NSNumber numberWithFloat:point.y];
        
        minX = MIN(minX, [x floatValue]);
        minY = MIN(minY, [y floatValue]);
        
        maxX = MAX(maxX, [x floatValue]);
        maxY = MAX(maxY, [y floatValue]);
    }
    
    float xAxisMin = -0.5f;
    float xAxisMax = [self.graphDataValues count]+0.5;
    float yAxisMin = 0.0f; //0.0f;
    float yAxisMax = maxY + 10.0f;
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(xAxisMin) length:@(xAxisMax - xAxisMin)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(yAxisMin) length:@(yAxisMax - yAxisMin)];
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.graph.axisSet;
    
    axisSet.xAxis.titleTextStyle = textStyle;
    axisSet.xAxis.titleOffset = 30.0f;
    axisSet.xAxis.axisLineStyle = lineStyle2;
    axisSet.xAxis.majorTickLineStyle = lineStyle;
    axisSet.xAxis.labelTextStyle = textStyle;
    axisSet.xAxis.labelOffset = 3.0f;
    axisSet.xAxis.majorIntervalLength = @2.0f;
    axisSet.xAxis.minorTicksPerInterval = 1;
    axisSet.xAxis.minorTickLength = 5.0f;
    axisSet.xAxis.majorTickLength = 7.0f;
    
    NSMutableSet *majorTickLocations =  [NSMutableSet set];
    axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    NSMutableSet *newAxisLabels = [NSMutableSet set];
    
    for ( NSUInteger i = 0; i < [self.graphDataValues count]; i++ ) {
        NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[self.graphDataValues objectAtIndex:i]];
        
        CPTAxisLabel *newLabel = [[[CPTAxisLabel alloc] initWithText: [NSString stringWithFormat:@"%@", [dict valueForKey:@"date"]] textStyle:axisSet.xAxis.labelTextStyle] autorelease];
        newLabel.tickLocation = @(i * 1);
        newLabel.offset = axisSet.xAxis.labelOffset + axisSet.xAxis.majorTickLength / 2.0;
        newLabel.rotation = M_PI/4;
        [newAxisLabels addObject:newLabel];
        
        [majorTickLocations addObject:[NSDecimalNumber numberWithInteger:i]];
        
        [dict release];
    }
    
    axisSet.xAxis.axisLabels = newAxisLabels;
    axisSet.xAxis.majorTickLocations = majorTickLocations;
    
    axisSet.yAxis.titleTextStyle = textStyle;
    axisSet.yAxis.titleOffset = 40.0f;
    axisSet.yAxis.axisLineStyle = lineStyle2;
    axisSet.yAxis.majorTickLineStyle = lineStyle;
    axisSet.yAxis.minorTickLineStyle = nil;
    axisSet.yAxis.labelTextStyle = textStyle;
    axisSet.yAxis.labelOffset = 5.0f;
    axisSet.yAxis.majorIntervalLength = @((yAxisMax / 5));
    axisSet.yAxis.minorTicksPerInterval = 1;
    axisSet.yAxis.minorTickLength = 5.0f;
    axisSet.yAxis.majorTickLength = 7.0f;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterNoStyle];
    axisSet.yAxis.labelFormatter = numberFormatter;
    [numberFormatter release];
    
    axisSet.yAxis.orthogonalPosition = @([self.graphDataValues count]-0.5f);
    axisSet.yAxis.tickDirection = CPTSignPositive;
    
    CPTScatterPlot *plot = [[[CPTScatterPlot alloc] init] autorelease];
    plot.dataSource = self;
    plot.identifier = @"mainplot";
    plot.dataLineStyle = lineStyle;
    plot.plotSymbol = plotSymbol;
    [self.graph addPlot:plot];
    
    CPTColor *areaColor;
    CPTGradient *areaGradient;
    if ([[appDefaults valueForKey:@"account_code"] isEqualToString:@"ezdietplanner"]) {
        areaColor = [CPTColor colorWithCGColor:[UIColor colorWithRed:0.400 green:0.114 blue:0.384 alpha:1.000].CGColor];
        areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor colorWithCGColor:[UIColor colorWithRed:0.400 green:0.114 blue:0.384 alpha:1.000].CGColor]];
    }
    else {
        areaColor = AccentColor //[CPTColor colorWithComponentRed:99.0/255.0f green:196.0/255.0f blue:247.0/255.0f alpha:1.0];
        areaGradient = graphGraindentColor;

        //areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor colorWithCGColor:[UIColor colorWithRed:99.00/255.0f green:196.00/255.0f blue:247.00/255.0f alpha:1.000].CGColor]];
    }
    
    areaGradient.angle = -90.0;
    CPTFill* areaGradientFill = [CPTFill fillWithGradient:areaGradient];
    plot.areaFill = areaGradientFill;
    plot.areaBaseValue = @0.0;
    
    plot.plotSymbol = plotSymbol;
    
    plot.delegate = self;
    plot.plotSymbolMarginForHitDetection = 5.0f;
    
    [self goalWeightIndicatorLine_Initialize];
}

-(void)goalWeightIndicatorLine_Initialize {
    if ([self.graphData count] <= 1) {
        return;
        
    }
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor greenColor];
    lineStyle.lineWidth = 1.0f;
    
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol plotSymbol];
    plotSymbol.fill = [CPTFill fillWithColor:[CPTColor greenColor]];
    plotSymbol.lineStyle = lineStyle;
    plotSymbol.size = CGSizeMake(7.0, 7.0);
    
    CPTScatterPlot *plot = [[[CPTScatterPlot alloc] init] autorelease];
    plot.dataSource = self;
    plot.identifier = @"SecondryPlot";
    plot.dataLineStyle = lineStyle;
    plot.plotSymbol = plotSymbol;
    [self.graph addPlot:plot];
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    if ([plot.identifier isEqual:@"mainplot"])  {
        return [self.graphData count];
    }
    else if ([plot.identifier isEqual:@"SecondryPlot"])  {
        return [self.graphData count]+1;
    }
    return 0;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index  {
    if ([plot.identifier isEqual:@"mainplot"]) {
        NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[self.graphDataValues objectAtIndex:index]];
        CGPoint point = [[dict valueForKey:@"point"] CGPointValue];
        if ( fieldEnum == CPTScatterPlotFieldX ) {
            return [NSNumber numberWithFloat:point.x];
        }
        else {
            return [NSNumber numberWithFloat:point.y];
        }
        [dict release];
    }
    else if ([plot.identifier isEqual:@"SecondryPlot"]) {
        NSDictionary *dict;
        CGPoint point;
        if (index == [self.graphDataValues count]) {
            point = CGPointMake(-1, GoalWeight);
        }
        else {
            dict = [[NSDictionary alloc] initWithDictionary:[self.graphDataValues objectAtIndex:index]];
            point = [[dict valueForKey:@"point"] CGPointValue];
        }
        
        if (fieldEnum == CPTScatterPlotFieldX) {
            return [NSNumber numberWithFloat:point.x];
        }
        else {
            return [NSNumber numberWithFloat:GoalWeight];
        }
    }
    return [NSNumber numberWithFloat:0];
}

-(float)getGoalWeightFromDB {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
        NSLog(@"Could not open db.");
    }
    
    float num_weightGoal;
    FMResultSet *rs = [db executeQuery:@"SELECT weight_goal FROM user"];
    while ([rs next]) {
        num_weightGoal  = [rs intForColumn:@"weight_goal"];
    }
    [rs close];
    return num_weightGoal;
}

#pragma mark ==== CPTScatterPlot delegate method ====
-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index {
    if (symbolTextAnnotation) {
        [self.graph.plotAreaFrame.plotArea removeAnnotation:symbolTextAnnotation];
        [symbolTextAnnotation release];
        symbolTextAnnotation = nil;
    }
    
    CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];
    hitAnnotationTextStyle.color = [CPTColor blackColor];
    hitAnnotationTextStyle.fontSize = 16.0f;
    hitAnnotationTextStyle.fontName = @"Helvetica-Bold";
    
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[self.graphDataValues objectAtIndex:index]];
    CGPoint point = [[dict valueForKey:@"point"] CGPointValue];
    NSNumber *y = [NSNumber numberWithFloat:point.y];
    [dict release];
    
    NSArray *anchorPoint = [NSArray arrayWithObjects:[NSNumber numberWithFloat:point.x], [NSNumber numberWithFloat:point.y], nil];
    
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
    [formatter setMaximumFractionDigits:2];
    NSString *yString = [formatter stringFromNumber:y];
    
    CPTTextLayer *textLayer = [[[CPTTextLayer alloc] initWithText:yString style:hitAnnotationTextStyle] autorelease];
    symbolTextAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:self.graph.defaultPlotSpace anchorPlotPoint:anchorPoint];
    symbolTextAnnotation.contentLayer = textLayer;
    symbolTextAnnotation.displacement = CGPointMake(0.0f, 20.0f);
    [self.graph.plotAreaFrame.plotArea addAnnotation:symbolTextAnnotation];
}

#pragma mark CUSTOM METHODS
-(void)reloadGraphView {
    if (symbolTextAnnotation) {
        [self.graph.plotAreaFrame.plotArea removeAnnotation:symbolTextAnnotation];
        [symbolTextAnnotation release];
        symbolTextAnnotation = nil;
    }
    
    [self.graph.plotAreaFrame.plotArea removeAllAnnotations];
    
    float  maxX = 0.0f;
    float  minX = 0.0f;
    float  maxY = [self getGoalWeightFromDB];
    float  minY = [self getGoalWeightFromDB];
    
    for ( NSMutableDictionary *dict in self.graphDataValues )  {
        CGPoint point = [[dict valueForKey:@"point"] CGPointValue];
        NSNumber *x = [NSNumber numberWithFloat:point.x];
        NSNumber *y = [NSNumber numberWithFloat:point.y];
        
        minX = MIN(minX, [x floatValue]);
        minY = MIN(minY, [y floatValue]); //goalw
        
        maxX = MAX(maxX, [x floatValue]);
        maxY = MAX(maxY, [y floatValue]);  //currenetW
    }
    
    float xAxisMin = -0.5f;
    float xAxisMax = [self.graphDataValues count]+0.5;
    float yAxisMin;
    if (minY>50) {
        yAxisMin = minY - 10;
    }
    else {
        yAxisMin = 0;
    }
    float yAxisMax = maxY + 10.0f;
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(xAxisMin) length:@(xAxisMax - xAxisMin)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(yAxisMin) length:@(yAxisMax - yAxisMin)];
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.graph.axisSet;
    
    NSMutableSet *majorTickLocations = [NSMutableSet set];
    axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    NSMutableSet *newAxisLabels = [NSMutableSet set];
    
    for ( NSUInteger i = 0; i < [self.graphDataValues count]; i++ ) {
        NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:[self.graphDataValues objectAtIndex:i]];
        CPTAxisLabel *newLabel = [[[CPTAxisLabel alloc] initWithText: [NSString stringWithFormat:@"%@", [dict valueForKey:@"date"]] textStyle:axisSet.xAxis.labelTextStyle] autorelease];
        newLabel.tickLocation = @(i * 1);
        newLabel.offset = axisSet.xAxis.labelOffset + axisSet.xAxis.majorTickLength / 2.0;
        newLabel.rotation = M_PI/4;
        [newAxisLabels addObject:newLabel];
        
        [majorTickLocations addObject:[NSDecimalNumber numberWithInteger:i]];
        
        [dict release];
    }
    axisSet.xAxis.axisLabels = newAxisLabels;
    axisSet.xAxis.majorTickLocations = majorTickLocations;
    
    axisSet.yAxis.majorIntervalLength = @((yAxisMax /16));
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterNoStyle];
    axisSet.yAxis.labelFormatter = numberFormatter;
    [numberFormatter release];
    
    axisSet.yAxis.orthogonalPosition = @([self.graphDataValues count]-0.5f);
    if ([self.graphData count] <=1) {
        axisSet.yAxis.orthogonalPosition = @(1.0);
    }
    axisSet.yAxis.tickDirection = CPTSignPositive;
    
    if (minY>50) {
        axisSet.xAxis.orthogonalPosition = @(minY-10);
    }
    else {
        axisSet.xAxis.orthogonalPosition = @(0);
    }
    
    if ([self.graphData count] <= 1) {
        
    }
    else {
        [self AddTextLableHere];
    }
}

-(void)AddTextLableHere {
    CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];
    hitAnnotationTextStyle.color = [CPTColor blackColor];
    hitAnnotationTextStyle.fontSize = 12.0f;
    
    NSString *strY = [NSString stringWithFormat:@"%.0f",GoalWeight];
    NSArray *anchorPoint2 = [NSArray arrayWithObjects:@"0", strY, nil];
    
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:strY style:hitAnnotationTextStyle];
    
    CPTPlotSpaceAnnotation *symbolTextAnnotation2;
    symbolTextAnnotation2 = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:self.graph.defaultPlotSpace anchorPlotPoint:anchorPoint2];
    symbolTextAnnotation2.contentLayer = textLayer;
    symbolTextAnnotation2.displacement = CGPointMake(-15.0f, 10.0f);
    [self.graph.plotAreaFrame.plotArea addAnnotation:symbolTextAnnotation2];
    
    [self AddTextLableHere2];
}

-(void)AddTextLableHere2 {
    CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];
    hitAnnotationTextStyle.color = [CPTColor blackColor];
    hitAnnotationTextStyle.fontSize = 12.0f;
    
    NSString *strX = [NSString stringWithFormat:@"%lu",[self.graphDataValues count]-1];
    NSString *strY = [NSString stringWithFormat:@"%.0f",GoalWeight];
    NSArray *anchorPoint2 = [NSArray arrayWithObjects:strX, strY, nil];
    
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:strY style:hitAnnotationTextStyle];
    
    CPTPlotSpaceAnnotation *symbolTextAnnotation2;
    symbolTextAnnotation2 = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:self.graph.defaultPlotSpace anchorPlotPoint:anchorPoint2];
    symbolTextAnnotation2.contentLayer = textLayer;
    symbolTextAnnotation2.displacement = CGPointMake(8.0f, 10.0f);
    [self.graph.plotAreaFrame.plotArea addAnnotation:symbolTextAnnotation2];
}

@end
