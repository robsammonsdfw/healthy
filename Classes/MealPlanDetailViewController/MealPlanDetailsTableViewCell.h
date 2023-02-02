//
//  MealPlanDetailsTableViewCell.h
//  ProDiets
//
//  Created by SOTSYS033 on 11/01/18.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface MealPlanDetailsTableViewCell : UITableViewCell

@property (retain, nonatomic) IBOutlet TTTAttributedLabel *lblMealName;
@property (retain, nonatomic) IBOutlet UILabel *lblServingSize;
@property (retain, nonatomic) IBOutlet UILabel *lblMealNote;

@end
