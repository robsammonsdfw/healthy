//
//  MBCircularProgressBarLayer.h
//  MBCircularProgressBar
//
//  Created by Mati Bot on 7/9/15.
//  Copyright (c) 2015 Mati Bot All rights reserved.
//

//@import QuartzCore;
#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSInteger, MBCircularProgressBarAppearanceType) {
    MBCircularProgressBarAppearanceTypeOverlaysEmptyLine = 0,
    MBCircularProgressBarAppearanceTypeAboveEmptyLine = 1,
    MBCircularProgressBarAppearanceTypeUnderEmptyLine = 2
};

/**
 * The MBCircularProgressBarLayer class is a CALayer subclass that represents the underlying layer
 * of MBCircularProgressBarView.
 */
@interface MBCircularProgressBarLayer : CALayer

/**
 * Set a partial angle for the progress bar	[0,100]
 */
@property (nonatomic) CGFloat  progressAngle;

/**
 * Progress bar rotation (Clockewise)	[0,100]
 */
@property (nonatomic) CGFloat  progressRotationAngle;

/**
 * Progress bar appearance type 
 */
@property (nonatomic) MBCircularProgressBarAppearanceType progressAppearanceType;

/**
 * The value of the progress bar
 */
@property (nonatomic) CGFloat  value;

/**
 * The maximum possible value, used to calculate the progress (value/maxValue)	[0,∞)
 */
@property (nonatomic) CGFloat  maxValue;

/**
 * Padding from borders
 */
@property (nonatomic) CGFloat borderPadding;

/**
 * Animation duration in seconds
 */
@property (nonatomic) NSTimeInterval  animationDuration;

/**
 * The font size of the value text	[0,∞)
 */
@property (nonatomic) CGFloat  valueFontSize;

/**
 * The name of the font of the unit string
 */
@property (nonatomic) CGFloat  unitFontSize;

/**
 * The string that represents the units, usually %
 */
@property (nonatomic,copy)   NSString *unitString;

/**
 * The color of the value and unit text
 */
@property (nonatomic,strong) UIColor  *fontColor;

/**
 * The width of the progress bar (user space units)	[0,∞)
 */
@property (nonatomic) CGFloat    progressLineWidth;

/**
 * The color of the progress bar
 */
@property (nonatomic,strong) UIColor    *progressColor;

/**
 * The color of the progress bar frame
 */
@property (nonatomic,strong) UIColor    *progressStrokeColor;

/**
 * The shape of the progress bar cap	{kCGLineCapButt=0, kCGLineCapRound=1, kCGLineCapSquare=2}
 */
@property (nonatomic) CGLineCap  progressCapType;

/**
 * The width of the background bar (user space units)	[0,∞)
 */
@property (nonatomic) CGFloat    emptyLineWidth;

/**
 * The shape of the background bar cap	{kCGLineCapButt=0, kCGLineCapRound=1, kCGLineCapSquare=2}
 */
@property (nonatomic) CGLineCap  emptyCapType;

/**
 * The color of the background bar
 */
@property (nonatomic,strong) UIColor    *emptyLineColor;
/**
 * The color of the background bar stroke line
 */
@property (nonatomic,strong) UIColor    *emptyLineStrokeColor;

/*
 * Number of decimal places of the value [0,∞)
 */
@property (nonatomic)  NSInteger decimalPlaces;

/**
 * The value to be displayed in the center
 */
@property (nonatomic)  CGFloat   valueDecimalFontSize;

/**
 * The font size of the unit text	[0,∞)
 */
@property (nonatomic,copy)    NSString  *unitFontName;

/**
 * The name of the font of the unit string
 */
@property (nonatomic,copy)    NSString  *valueFontName;

/**
 * Should show unit screen
 */
@property (nonatomic)  BOOL      showUnitString;

/**
 * The offset to apply to the unit / value text
 */
@property (nonatomic)  CGPoint   textOffset;

/**
 * Should show value string
 */
@property (nonatomic)  BOOL      showValueString;


/**
 * Show label value as countdown
 * Default is NO
 */
@property (nonatomic)  BOOL      countdown;

@end
