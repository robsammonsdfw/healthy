//
//  MyLogTableViewCell.h
//  ProDiets
//
//  Created by SOTSYS033 on 11/01/18.
//

#import <UIKit/UIKit.h>

//HHT change 2018 for link
#import "TTTAttributedLabel.h"

@interface MyLogTableViewCell : UITableViewCell

@property (retain, nonatomic) IBOutlet TTTAttributedLabel *lblFoodName;
@property (retain, nonatomic) IBOutlet UILabel *lblCalories;

@end
