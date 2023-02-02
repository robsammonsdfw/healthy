//
//  CustomCell.h
//  TextfieldsWithKeyboard
//
//  Created by Dirk de Kok on 8/13/09.
//  Copyright 2009 D17 software services. Use at your own will.
//  http://www.d17.nl
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell {
	
	IBOutlet UILabel *countryLabel;
	IBOutlet UITextField *textField;

}

@property(nonatomic, retain) IBOutlet UILabel *countryLabel;
@property(nonatomic, retain) UITextField *textField;

@end
