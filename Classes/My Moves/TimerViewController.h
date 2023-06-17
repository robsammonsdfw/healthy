//
//  ViewController.h
//  Timer
//
//  Created by CIPL0681 on 28/02/19.
//  Copyright © 2019 Gowthami. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyMovesWebServices.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface TimerViewController : UIViewController
{

    IBOutlet UIDatePicker *timePicker;
    IBOutlet UILabel *pickerLbl;
}
@property (weak, nonatomic) IBOutlet UILabel *timerLbl;

@property (nonatomic, strong) AVAudioPlayer * audioPlayer;

@property (weak, nonatomic) NSTimer *myTimer;
@property (weak, nonatomic) NSTimer *pickerTimer;
@property double currentTimeInSeconds;
@property double pickerLblInSeconds;
@property (nonatomic, strong) NSDictionary * moveDetailDict;

@property (nonatomic, strong) IBOutlet UIButton *startBtnOutlet;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (nonatomic, strong) NSMutableArray *hoursArray;
@property (nonatomic, strong) NSMutableArray *minsArray;
@property (nonatomic, strong) NSMutableArray *secsArray;

@end

