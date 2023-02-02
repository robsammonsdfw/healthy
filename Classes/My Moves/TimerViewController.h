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

@property (strong, nonatomic) AVAudioPlayer * audioPlayer;
@property (strong, nonatomic) NSError *error;

@property (weak, nonatomic) NSTimer *myTimer;
@property (weak, nonatomic) NSTimer *pickerTimer;
@property double currentTimeInSeconds;
@property double pickerLblInSeconds;
@property (strong, retain) NSDictionary * moveDetailDict;

@property (retain, nonatomic) IBOutlet UIButton *startBtnOutlet;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property(retain, nonatomic) NSMutableArray *hoursArray;
@property(retain, nonatomic) NSMutableArray *minsArray;
@property(retain, nonatomic) NSMutableArray *secsArray;

@end

