#import "Log_Add.h"
#import "DietMasterGoAppDelegate.h"
#import "FoodsHome.h"
#import "ExercisesViewController.h"
#import "DietmasterEngine.h"

@implementation Log_Add

@synthesize date_currentDate, int_mealID;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:PLIST_NAME];
    NSDictionary *appDefaults = [[[NSDictionary alloc] initWithContentsOfFile:finalPath] autorelease];
    
    if (dietmasterEngine.isMealPlanItem) {
        self.title = @"Add To Plan";
        
        arryMeals		= [[NSArray alloc] initWithObjects:@"Breakfast",@"Snack 1",@"Lunch",@"Snack 2",@"Dinner",@"Snack 3",nil];
        
        arryExercise	= [[NSArray alloc] initWithObjects:nil];
    }
    else {
        self.title = @"Add To Log";
        arryMeals		= [[NSArray alloc] initWithObjects:@"Breakfast",@"Snack 1",@"Lunch",@"Snack 2",@"Dinner",@"Snack 3",nil];
        
        if ([[appDefaults valueForKey:@"account_code"] isEqualToString:@"mobilefit"]) {
            arryExercise	= [[NSArray alloc] initWithObjects:nil];
        }
        else {
            arryExercise	= [[NSArray alloc] initWithObjects:@"Exercise",nil];
        }
    }
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar setTranslucent:NO];

    if(self.date_currentDate == NULL) {
        NSDate* sourceDate = [NSDate date];
        NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSTimeZone* systemTimeZone = [NSTimeZone systemTimeZone];
        [dateFormat setTimeZone:systemTimeZone];
        NSString *date_string = [dateFormat stringFromDate:sourceDate];
        NSDate *destinationDate = [dateFormat dateFromString:date_string];
        
        self.date_currentDate = destinationDate;
    }
    
    if(self.int_mealID == NULL) {
        self.int_mealID = 0;
    }
        
    tblLogAdd.rowHeight = 44;
    
    if ([[appDefaults valueForKey:@"account_code"] isEqualToString:@"ezdietplanner"]) {
        tblLogAdd.backgroundView = nil;
        tblLogAdd.backgroundColor = [UIColor clearColor];
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Select_Meal_TVGray"]];
    }
    
    [super viewDidLoad];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0)
        return arryMeals.count;
    else
        return arryExercise.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if(indexPath.section == 0)
        cell.textLabel.text = [arryMeals objectAtIndex:indexPath.row];
    else
        cell.textLabel.text = [arryExercise objectAtIndex:indexPath.row];
    
    cell.textLabel.font = [UIFont systemFontOfSize:13.0];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13.0];
    cell.selectionStyle =  UITableViewCellSelectionStyleGray;
    
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStylePlain
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    [backButton release];
    
    if (indexPath.section == 1) {
        ExercisesViewController *exercisesViewController = [[ExercisesViewController alloc] init];
        [self.navigationController pushViewController:exercisesViewController animated:YES];
        [exercisesViewController release];
        
    }
    else {
        NSUInteger row		= [indexPath row];
        NSString *MealsName = [arryMeals objectAtIndex:row];
        
        if([MealsName isEqualToString:@"Breakfast"]) {
            int_mealID = [NSNumber numberWithInt:0];
        }
        else if ([MealsName isEqualToString:@"Snack 1"])
        {
            int_mealID = [NSNumber numberWithInt:1];
        }
        else if ([MealsName isEqualToString:@"Lunch"]) {
            int_mealID = [NSNumber numberWithInt:2];
        }
        else if ([MealsName isEqualToString:@"Snack 2"]) {
            int_mealID = [NSNumber numberWithInt:3];
        }
        else if ([MealsName isEqualToString:@"Dinner"]) {
            int_mealID = [NSNumber numberWithInt:4];
        }
        else if ([MealsName isEqualToString:@"Snack 3"]) {
            int_mealID = [NSNumber numberWithInt:5];
        }
        
        DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
        dietmasterEngine.selectedMealID = int_mealID;
        
        if (![dietmasterEngine.taskMode isEqualToString:@"AddMealPlanItem"]) {
            dietmasterEngine.taskMode = @"Save";
        }
        
        FoodsHome *fhController = [[FoodsHome alloc] initWithNibName:@"FoodsHome" bundle:nil];
        fhController.date_currentDate	= date_currentDate;
        fhController.title = MealsName;
        [self.navigationController pushViewController:fhController animated:YES];
        [fhController release];
    }
}

//- (void)viewDidUnload {
//    [super viewDidUnload];
//    
//    tblLogAdd = nil;
//    int_mealID = nil;
//    arryMeals = nil;
//    arryExercise = nil;
//}

- (void)dealloc {
    [super dealloc];
    [int_mealID release];
    tblLogAdd = nil;
    int_mealID = nil;
    arryMeals = nil;
    arryExercise = nil;
}

@end
