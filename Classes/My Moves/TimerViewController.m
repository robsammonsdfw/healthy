//
//  ViewController.m
//  Timer
//
//  Created by CIPL0681 on 28/02/19.
//  Copyright © 2019 Gowthami. All rights reserved.
//

#import "TimerViewController.h"

@interface TimerViewController ()<AVAudioPlayerDelegate>
{
    IBOutlet UIButton *stopWatchBtn;
    IBOutlet UIButton *timerBtn;
    IBOutlet UIPickerView *pickerCompView;
    UILabel *hourLabel;
    NSTimeInterval interval;
    NSString *selectedValue;
}

@end

@implementation TimerViewController
@synthesize pickerView;
@synthesize hoursArray;
@synthesize minsArray;
@synthesize secsArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    stopWatchBtn.layer.borderColor = [UIColor darkGrayColor].CGColor;
    stopWatchBtn.layer.borderWidth = 3.0f;
    
    timerBtn.layer.borderColor = [UIColor darkGrayColor].CGColor;
    timerBtn.layer.borderWidth = 3.0f;
    
    [stopWatchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    stopWatchBtn.backgroundColor = PrimaryColor;
    
    [timerBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    timerBtn.backgroundColor = [UIColor whiteColor];
    
    [pickerView setHidden:YES];

//    [timePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
//    timePicker.date = [NSDate date];
//    [self dateChanged:timePicker];
    [self calculateTimeFromPicker];

    [self playBuzzer];
    
    hoursArray = [[NSMutableArray alloc] init];
    minsArray = [[NSMutableArray alloc] init];
    secsArray = [[NSMutableArray alloc] init];
    
    pickerLbl.text = @"00:00:00";
    
    NSString *strVal = [[NSString alloc] init];
    
    for(int i=0; i<60; i++)
    {
        strVal = [NSString stringWithFormat:@"%d", i];
        
        //Create array with 0-24 hours
        if (i < 24)
        {
            [hoursArray addObject:strVal];
        }
        
        //create arrays with 0-60 secs/mins
        [minsArray addObject:strVal];
        [secsArray addObject:strVal];
    }
    
    hourLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, pickerCompView.frame.size.height / 3.3, 75, 30)];
    hourLabel.text = @"hour";
    [pickerCompView addSubview:hourLabel];
    
    
    UILabel *minsLabel = [[UILabel alloc] initWithFrame:CGRectMake(60 + (pickerCompView.frame.size.width / 3), pickerCompView.frame.size.height / 3.3, 75, 30)];
    minsLabel.text = @"min";
    [pickerCompView addSubview:minsLabel];
    
    UILabel *secsLabel = [[UILabel alloc] initWithFrame:CGRectMake(pickerCompView.frame.size.width - 90, pickerCompView.frame.size.height / 3.3, 75, 30)];
    secsLabel.text = @"sec";
    [pickerCompView addSubview:secsLabel];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

//Method to define how many columns/dials to show
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}


// Method to define the numberOfRows in a component using the array.
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent :(NSInteger)component
{
    if (component==0)
    {
        return [hoursArray count];
    }
    else if (component==1)
    {
        return [minsArray count];
    }
    else
    {
        return [secsArray count];
    }
    
}

// Method to show the title of row for a component.
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    switch (component)
    {
        case 0:
            return [hoursArray objectAtIndex:row];
            break;
        case 1:
            return [minsArray objectAtIndex:row];
            break;
        case 2:
            return [secsArray objectAtIndex:row];
            break;
    }
    return nil;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    
    NSString *hoursStr = [NSString stringWithFormat:@"%@",[hoursArray objectAtIndex:[pickerView selectedRowInComponent:0]]];
    
    NSString *minsStr = [NSString stringWithFormat:@"%@",[minsArray objectAtIndex:[pickerView selectedRowInComponent:1]]];
    
    NSString *secsStr = [NSString stringWithFormat:@"%@",[secsArray objectAtIndex:[pickerView selectedRowInComponent:2]]];
    
    int hoursInt = [hoursStr intValue];
    int minsInt = [minsStr intValue];
    int secsInt = [secsStr intValue];
    
    interval = secsInt + (minsInt*60) + (hoursInt*3600);
    
    
    NSString *totalTimeStr = [NSString stringWithFormat:@"%f",interval];
    selectedValue = totalTimeStr;
    DMLog(@"%@",totalTimeStr);
    
    pickerLbl.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hoursInt,minsInt,secsInt];
    
    if ([pickerLbl.text  isEqual: @"00:00:00"])// [NSString stringWithFormat:@"%02d:%02d:%02d",0,0,0])
    {
        self.startBtnOutlet.userInteractionEnabled = NO;
    }
    else
    {
       self.startBtnOutlet.userInteractionEnabled = YES;
    }
    
    
    
    [self calculateTimeFromPicker];
}

-(void)calculateTimeFromPicker
{
    
    NSString *hoursStr = [NSString stringWithFormat:@"%@",[hoursArray objectAtIndex:[pickerCompView selectedRowInComponent:0]]];
    
    NSString *minsStr = [NSString stringWithFormat:@"%@",[minsArray objectAtIndex:[pickerCompView selectedRowInComponent:1]]];
    
    NSString *secsStr = [NSString stringWithFormat:@"%@",[secsArray objectAtIndex:[pickerCompView selectedRowInComponent:2]]];
    
    int hoursInt = [hoursStr intValue];
    int minsInt = [minsStr intValue];
    int secsInt = [secsStr intValue];
    
    interval = secsInt + (minsInt*60) + (hoursInt*3600);
    
    //DMLog(@"hours: %d ... mins: %d .... sec: %d .... interval: %f", hoursInt, minsInt, secsInt, interval);
    
    NSString *totalTimeStr = [NSString stringWithFormat:@"%f",interval];
    _pickerLblInSeconds = [totalTimeStr doubleValue];
    DMLog(@"%@",totalTimeStr);
    
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error
{
    
}
- (void)dateChanged:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm"];
    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"<your date format goes here"];
//    NSDate *date = [dateFormatter dateFromString:string1];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:timePicker.date];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    
     _pickerLblInSeconds = (hour * 3600) + (minute * 60);
    
}
- (IBAction)stopWatchBtnAction:(id)sender {
    [stopWatchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    stopWatchBtn.backgroundColor = PrimaryColor;

    [timerBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    timerBtn.backgroundColor = [UIColor whiteColor];
    [pickerView setHidden:YES];
}

- (IBAction)timerBtnAction:(id)sender {
    [stopWatchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    stopWatchBtn.backgroundColor = [UIColor whiteColor];

    [timerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    timerBtn.backgroundColor = PrimaryColor;
    
    [pickerView setHidden:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.timerLbl.text = [self formattedTime:_currentTimeInSeconds];
//    [self dateChanged:pickerCompView];
    [self calculateTimeFromPicker];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [_audioPlayer stop];
}
- (NSTimer *)createTimer {
    return [NSTimer scheduledTimerWithTimeInterval:1.0
                                            target:self
                                          selector:@selector(timerTicked:)
                                          userInfo:nil
                                           repeats:YES];
}


- (NSTimer *)createTimerPicker {
    return [NSTimer scheduledTimerWithTimeInterval:1.0
                                            target:self
                                          selector:@selector(timerTickedTimer:)
                                          userInfo:nil
                                           repeats:YES];
}
- (void)timerTicked:(NSTimer *)timer {
    _currentTimeInSeconds++;
    
    self.timerLbl.text = [self formattedTime:_currentTimeInSeconds];
}


- (void)timerTickedTimer:(NSTimer *)timer {
    _pickerLblInSeconds --;
    
    if(_pickerLblInSeconds > 0)
    {
        pickerLbl.text = [self formattedTime:_pickerLblInSeconds];
    }
    else if (_pickerLblInSeconds == 0)
    {
        [_audioPlayer play];
        pickerLbl.text = @"00:00:00";
    }
}
-(void)playBuzzer
{
     _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"sound" ofType:@"mp3"]] error:&_error];

    _audioPlayer.numberOfLoops = 1;

    if (_error) {
        DMLog(@"Error : %@", [_error localizedDescription]);
    } else {
        [_audioPlayer prepareToPlay];
    }
    
}
- (NSString *)formattedTime:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;

    if([timerBtn backgroundColor] == [UIColor whiteColor])
    {
        MyMovesWebServices *soapWebService = [[MyMovesWebServices alloc] init];
        [soapWebService updateTimeForExercise:[_moveDetailDict[@"WorkoutUserDateID"]integerValue] Dict:_moveDetailDict WorkoutTimer:[NSString stringWithFormat:@"%d",totalSeconds]];
    }
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

- (IBAction)startaction:(UIButton*)sender {
    
    if ([pickerLbl.text  isEqual: @"00:00:00"])// [NSString stringWithFormat:@"%02d:%02d:%02d",0,0,0])
    {
        self.startBtnOutlet.userInteractionEnabled = NO;
    }
    else
    {
        self.startBtnOutlet.userInteractionEnabled = YES;
        if (!_currentTimeInSeconds) {
            //            _currentTimeInSeconds = 30 ;
        }
        
        if([timerBtn backgroundColor] == [UIColor whiteColor])
        {
            _timerLbl.text = [self formattedTime:_currentTimeInSeconds];
            if (!_myTimer) {
                _myTimer = [self createTimer];
            }
        }
        else
        {
            pickerLbl.text = [self formattedTime:_pickerLblInSeconds];
            if (!_pickerTimer) {
                _pickerTimer = [self createTimerPicker];
                [pickerCompView setUserInteractionEnabled:NO];
            }
        }
        [self resumeaction:sender];
    }
    
    
    
}
- (IBAction)stopaction:(UIButton*)sender {
    [_audioPlayer stop];
    if([timerBtn backgroundColor] == [UIColor whiteColor])
    {
        [_myTimer invalidate];
    }
    else
    {
        [_pickerTimer invalidate];
        [pickerCompView setUserInteractionEnabled:YES];
    }
}
- (IBAction)resumeaction:(UIButton*)sender {
    
//    _currentTimeInSeconds = 0;
    
    if([timerBtn backgroundColor] == [UIColor whiteColor])
    {
        self.timerLbl.text = [self formattedTime:_currentTimeInSeconds];
        if (_myTimer) {
            [_myTimer invalidate];
            _myTimer = [self createTimer];
        }
    }
    else
    {
        pickerLbl.text = [self formattedTime:_pickerLblInSeconds];
        if (_pickerTimer) {
            [_pickerTimer invalidate];
            _pickerTimer = [self createTimerPicker];
        }
    }
//    self.timerLbl.text = [self formattedTime:_currentTimeInSeconds];
}

- (IBAction)resetAction:(UIButton*)sender {

    if([timerBtn backgroundColor] == [UIColor whiteColor])
    {
        _currentTimeInSeconds = 0;
    }
    else
    {
        _pickerLblInSeconds = 0;
        [pickerCompView setUserInteractionEnabled:YES];
        [self calculateTimeFromPicker];
    }
    
    [self resumeaction:sender];
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self stopaction:sender];
    });
    
    if([timerBtn backgroundColor] == [UIColor whiteColor])
    {
    }
    else
    {
        pickerLbl.text = @"";
    }
}

- (void)dealloc {
    [stopWatchBtn release];
    [timerBtn release];
    [pickerLbl release];
    [timePicker release];
    [pickerView release];
    [pickerCompView release];
    [_startBtnOutlet release];
    [super dealloc];
}
@end
