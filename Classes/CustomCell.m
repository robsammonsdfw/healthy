//
//  CustomCell.m
//  TextfieldsWithKeyboard
//
//  Created by Dirk de Kok on 8/13/09.
//  Copyright 2009 D17 software services. Use at your own will.
//  http://www.d17.nl
//

#import "CustomCell.h"


@implementation CustomCell

@synthesize countryLabel, textField;

/*
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}*/


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:NO animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[countryLabel release];
	[textField release];
    [super dealloc];
}


@end
