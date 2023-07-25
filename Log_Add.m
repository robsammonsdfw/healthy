#import "Log_Add.h"
#import "DietMasterGoAppDelegate.h"
#import "FoodsHome.h"
#import "ExercisesViewController.h"
#import "DMMealPlan.h"

@interface Log_Add() <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) IBOutlet UITableView *tblLogAdd;
/// Options the user can select from.
@property (nonatomic, strong) NSArray *mealOptionsArray;
@property (nonatomic, strong) NSArray *exerciseOptionsArray;

@property (nonatomic, strong) DMMealPlan *mealPlan;
@end

static NSString *CellIdentifier = @"CellIdentifier";

@implementation Log_Add

- (instancetype)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _selectedDate = [NSDate date]; // Default to now.
    }
    return self;
}

- (instancetype)initWithMealPlan:(DMMealPlan *)mealPlan selectedDate:(NSDate *)selectedDate {
    self = [self init];
    if (self) {
        _mealPlan = mealPlan;
        _selectedDate = selectedDate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.mealPlan) {
        self.title = @"Add To Plan";
        self.navigationItem.title = @"Add To Plan";
        self.mealOptionsArray = @[@"Breakfast", @"Snack 1", @"Lunch", @"Snack 2", @"Dinner", @"Snack 3"];
    } else {
        self.title = @"Add To Log";
        self.navigationItem.title = @"Add To Log";
        self.mealOptionsArray = @[@"Breakfast", @"Snack 1", @"Lunch", @"Snack 2", @"Dinner", @"Snack 3"];
        self.exerciseOptionsArray = @[@"Exercise"];
    }
    
    // Special case.
    if ([AppConfiguration.accountCode isEqualToString:@"mobilefit"]) {
        // No exercise.
        self.exerciseOptionsArray = @[];
    }
    if ([AppConfiguration.accountCode isEqualToString:@"ezdietplanner"]) {
        self.tblLogAdd.backgroundView = nil;
        self.tblLogAdd.backgroundColor = [UIColor clearColor];
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Select_Meal_TVGray"]];
    }
    self.tblLogAdd.estimatedRowHeight = 44;
    [self.tblLogAdd registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.mealOptionsArray.count;
    }
    
    return self.exerciseOptionsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSString *title = @"";
    if (indexPath.section == 0) {
        title = self.mealOptionsArray[indexPath.row];
    } else {
        title = self.exerciseOptionsArray[indexPath.row];
    }

    cell.textLabel.text = title;
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.selectionStyle =  UITableViewCellSelectionStyleGray;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStylePlain
                                   target: nil action: nil];
    [self.navigationItem setBackBarButtonItem: backButton];
    
    if (indexPath.section == 1) {
        ExercisesViewController *exercisesViewController = [[ExercisesViewController alloc] initWithSelectedDate:self.selectedDate];
        [self.navigationController pushViewController:exercisesViewController animated:YES];
    } else {
        NSString *mealName = [self.mealOptionsArray objectAtIndex:indexPath.row];
        DMLogMealCode mealCode = (DMLogMealCode)indexPath.row;
        FoodsHome *fhController = [[FoodsHome alloc] initWithMealTitle:mealName
                                                              mealCode:mealCode
                                                              mealPlan:self.mealPlan
                                                          selectedDate:self.selectedDate];
        fhController.taskMode = self.taskMode;
        [self.navigationController pushViewController:fhController animated:YES];
    }
}

@end
