//
//  MealPlanDetailsTableViewCell.h
//  ProDiets
//
//  Created by SOTSYS033 on 11/01/18.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface MealPlanDetailsTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet TTTAttributedLabel *lblMealName;
@property (nonatomic, strong) IBOutlet UILabel *lblServingSize;
@property (nonatomic, strong) IBOutlet UILabel *lblMealNote;

@end
