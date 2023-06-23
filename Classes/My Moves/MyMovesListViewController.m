//
//  MyMovesListViewController.m
//  MyMoves
//
//  Created by Sathis Kumar on 24/01/19.
//

#import "MyMovesListViewController.h"

#import "MyMovesDetailsViewController.h"
#import "MyMovesWebServices.h"
#import "DMMove.h"
#import "DMMoveCategory.h"
#import "DMMoveTag.h"

/// Cell identifier for a move's cell.
static NSString *DMMovesCellIdentifier = @"MovesCellIdentifier";
static NSString *DMMovesEmptyCellIdentifier = @"DMMovesEmptyCellIdentifier";

@interface MyMovesListViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDictionary *moveDetailDictToDelete;

/// Data source for exercises.
@property (nonatomic, strong) MyMovesWebServices *soapWebService;

/// Array that holds data that's presented in the table.
@property (nonatomic, strong) NSArray *tableData;

/// I believe this is the name of the plan's template.
@property (nonatomic, strong) IBOutlet UITextField *templateNameTxtFld;

/// Table that displays the exercises.
@property (nonatomic, strong) IBOutlet UITableView *tblView;
/// Distance measured for moving keyboard and text fields.
@property (nonatomic) CGFloat animatedDistance;

/// Filters for searching for moves.
@property (nonatomic, strong) DMMoveCategory *filterCategory;
@property (nonatomic, strong) DMMoveTag *filterTag;
/// Displays a picker to the user to select a filter.
@property (nonatomic, strong) DMPickerViewController *pickerViewController;

/// Search bar for text searches.
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
/// Buttons for filters.
@property (nonatomic, strong) IBOutlet UIButton *filterOneBtn;
@property (nonatomic, strong) IBOutlet UIButton *bodyPartBtn;
/// Hidden textfield that is under the buttons above for filters.
@property (nonatomic, strong) IBOutlet UITextField *bodypartTxtFld;
@property (nonatomic, strong) IBOutlet UITextField *filter1;

@end

@implementation MyMovesListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pickerViewController = [[DMPickerViewController alloc] init];
    self.bodypartTxtFld.text = @"Body Focus...";
    self.filter1.text = @"Filter By...";

    self.dateFormatter = [[NSDateFormatter alloc] init];
    
    self.tableData = @[];
    self.searchBar.delegate = self;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar setTranslucent:NO];
    
    [self.tblView registerClass:[UITableViewCell class] forCellReuseIdentifier:DMMovesCellIdentifier];
    [self.tblView registerClass:[UITableViewCell class] forCellReuseIdentifier:DMMovesEmptyCellIdentifier];

    [self loadTable];
}

- (void)loadTable {
    self.soapWebService = [[MyMovesWebServices alloc] init];

    if(_isExchange) {
        [DMActivityIndicator showActivityIndicator];
        NSMutableArray * tempArr = [[NSMutableArray alloc]initWithArray:[self.soapWebService getMovesFromDatabaseWithCategoryFilter:self.filterCategory tagFilter:self.filterTag textSearch:self.searchBar.text]];
        if ([tempArr count] != 0) {
            NSString *filter = @"%K == %@";
            
            NSPredicate *categoryPredicate = [[NSPredicate alloc]init];
            if ([_moveDetailDictToDelete[@"WorkoutCategoryID"] length] != 0) {
                categoryPredicate = [NSPredicate predicateWithFormat:filter,@"WorkoutCategoryID",_moveDetailDictToDelete[@"WorkoutCategoryID"]];
            }
            else
            {
                categoryPredicate = [NSPredicate predicateWithFormat:filter,@"WorkoutCategoryID",_moveDetailDictToDelete[@"CategoryID"]];
            }
            self.bodypartTxtFld.text = _moveDetailDictToDelete[@"CategoryName"];
            [self.bodypartTxtFld setUserInteractionEnabled:NO];
            [self.filter1 setUserInteractionEnabled:NO];
        }
    }
    else {
        self.tableData = [self.soapWebService getMovesFromDatabaseWithCategoryFilter:self.filterCategory
                                                                           tagFilter:self.filterTag
                                                                          textSearch:self.searchBar.text];
        [self.tblView reloadData];
    }
}

/// Shows the body part filter.
- (IBAction)bodyPartAction:(id)sender {
    __weak typeof(self) weakSelf = self;
    NSArray *bodyPartArray = [self.soapWebService loadListOfBodyPart];
    [self.pickerViewController setDataSourceWithDataArray:bodyPartArray showNoneRow:YES];
    self.pickerViewController.didSelectOptionCallback = ^(id<DMPickerViewDataSource> object, NSInteger row) {
        if ([(NSObject *)object isKindOfClass:[DMMoveCategory class]]) {
            weakSelf.filterCategory = (DMMoveCategory *)object;
            weakSelf.bodypartTxtFld.text = object.name;
        } else {
            weakSelf.filterCategory = nil;
            weakSelf.bodypartTxtFld.text = @"Body Focus...";
        }
        weakSelf.tableData = [weakSelf.soapWebService getMovesFromDatabaseWithCategoryFilter:weakSelf.filterCategory
                                                                                   tagFilter:weakSelf.filterTag
                                                                                  textSearch:weakSelf.searchBar.text];
        [weakSelf.tblView reloadData];
    };
    [self.pickerViewController presentPickerIn:self];
}

/// Shows the tags to filter the list by in a picker.
- (IBAction)filterOne:(id)sender {
    __weak typeof(self) weakSelf = self;
    NSArray *dataArray = [self.soapWebService loadListOfTags];
    [self.pickerViewController setDataSourceWithDataArray:dataArray showNoneRow:YES];
    self.pickerViewController.didSelectOptionCallback = ^(id<DMPickerViewDataSource> object, NSInteger row) {
        if ([(NSObject *)object isKindOfClass:[DMMoveTag class]]) {
            weakSelf.filterTag = (DMMoveTag *)object;
            weakSelf.filter1.text = object.name;
        } else {
            weakSelf.filterTag = nil;
            weakSelf.filter1.text = @"Filter By...";
        }
        weakSelf.tableData = [weakSelf.soapWebService getMovesFromDatabaseWithCategoryFilter:weakSelf.filterCategory
                                                                                   tagFilter:weakSelf.filterTag
                                                                                  textSearch:weakSelf.searchBar.text];
        [weakSelf.tblView reloadData];
    };
    [self.pickerViewController presentPickerIn:self];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.tableData = [self.soapWebService getMovesFromDatabaseWithCategoryFilter:self.filterCategory
                                                                       tagFilter:self.filterTag
                                                                      textSearch:self.searchBar.text];
    [self.tblView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - TableView Datasource/Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (self.tableData.count) {
        cell = [tableView dequeueReusableCellWithIdentifier:DMMovesCellIdentifier forIndexPath:indexPath];
        DMMove *move = self.tableData[indexPath.row];
        cell.textLabel.text = move.name;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:DMMovesEmptyCellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = @"No results...";
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MAX([self.tableData count], 1);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.tableData.count) {
        return;
    }
    
    [self.dateFormatter setDateFormat:@"LLLL d, yyyy"];
    NSString *msgInfo = [NSString stringWithFormat:@"New Move will be added to %@", [self.dateFormatter stringFromDate:_selectedDate]];
    NSString *msgInfoForExchange = [NSString stringWithFormat:@"Exchange move on %@", [self.dateFormatter stringFromDate:_selectedDate]];
   
    if (_isExchange) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Exchange My Moves" message:msgInfoForExchange preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"Exchange"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                        
                                        MyMovesDetailsViewController *moveDetailVc = [[MyMovesDetailsViewController alloc]initWithNibName:@"MyMovesDetailsViewController" bundle:nil];
                                        [self.soapWebService saveDeletedExerciseToDb:[self.moveDetailDictToDelete[@"WorkoutTemplateId"] intValue] UserId:0 WorkoutUserDateID:[self.moveDetailDictToDelete[@"WorkoutUserDateID"] intValue]];
                                        DMLog(@"%@",self.moveDetailDictToDelete);
                                        [self.soapWebService deleteWorkoutFromDb:[self.moveDetailDictToDelete[@"WorkoutUserDateID"] intValue]];
                                        [self.soapWebService addExerciseToDb:_tableData[indexPath.row] workoutDate:_selectedDate userId:0 categoryName:_bodypartTxtFld.text CategoryID:[_moveDetailDictToDelete[@"CategoryID"]integerValue] tagsName:self.filter1.text TagsId:0 templateName: _moveDetailDictToDelete[@"TemplateName"] WorkoutDateID:[_moveDetailDictToDelete[@"WorkoutUserDateID"]integerValue]];
                                        
                                        self.dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
                                        
                                        NSArray *exerciseArray = [self.soapWebService loadExerciseFromDb];
                                        NSArray *filteredExerciseArray = [exerciseArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(WorkoutDate contains[c] %@)", [self.dateFormatter stringFromDate:_selectedDate]]];
                                        NSMutableArray * tempArr = [filteredExerciseArray mutableCopy];
                                        
                                        DMLog(@"%@",tempArr[[tempArr count] - 1]);
                                        [self.exchangeDel passDataOnExchange:tempArr[[tempArr count] - 1]];
                                        
                                        moveDetailVc.workoutMethodID = [tempArr[[tempArr count] - 1][@"WorkoutUserDateID"]intValue];
                                        
                                        moveDetailVc.currentDate = self.selectedDate;
                                        NSString *dateString = [self.dateFormatter stringFromDate:self.selectedDate];
                                        [self.soapWebService updateWorkoutToDb:dateString];
                                        
                                        MyMovesViewController *mymoveVc = [[MyMovesViewController alloc]initWithNibName:@"MyMovesViewController" bundle:nil];
                                        
                                        [[self navigationController] pushViewController:mymoveVc animated:YES];
                                    }];
        
        UIAlertAction* noButton = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                        }];
        
        UIAlertAction* addEditButton = [UIAlertAction actionWithTitle:@"Exchange & Edit"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                            
                                            MyMovesDetailsViewController *moveDetailVc = [[MyMovesDetailsViewController alloc]initWithNibName:@"MyMovesDetailsViewController" bundle:nil];
                                            
                                            [self.soapWebService saveDeletedExerciseToDb:[self.moveDetailDictToDelete[@"WorkoutTemplateId"] intValue]
                                                                                  UserId:0
                                                                       WorkoutUserDateID:[self.moveDetailDictToDelete[@"WorkoutUserDateID"] intValue]];
                                            DMLog(@"%@",self.moveDetailDictToDelete);
                                            
                                            [self.soapWebService deleteWorkoutFromDb:[self.moveDetailDictToDelete[@"WorkoutUserDateID"] intValue]];
                                            
                                            [self.soapWebService addExerciseToDb:_tableData[indexPath.row]
                                                                     workoutDate:_selectedDate
                                                                          userId:0
                                                                    categoryName:_bodypartTxtFld.text
                                                                      CategoryID:[_moveDetailDictToDelete[@"CategoryID"]integerValue]
                                                                        tagsName:self.filter1.text
                                                                          TagsId:0
                                                                    templateName: _moveDetailDictToDelete[@"TemplateName"]
                                                                   WorkoutDateID:[_moveDetailDictToDelete[@"WorkoutUserDateID"]integerValue]];
                                            
                                            self.dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
                                            
                                            NSMutableArray * tempArr = [[NSMutableArray alloc]initWithArray:[[self.soapWebService loadExerciseFromDb] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(WorkoutDate contains[c] %@)", [self.dateFormatter stringFromDate:_selectedDate]]]];
                                            
                                            DMLog(@"%@",tempArr[[tempArr count] - 1]);
                                            [self.exchangeDel passDataOnExchange:tempArr[[tempArr count] - 1]];
                                          
                                            moveDetailVc.workoutMethodID = [tempArr[[tempArr count] - 1][@"WorkoutUserDateID"]intValue];
                                            
                                            moveDetailVc.currentDate = self.selectedDate;
                                            NSString *dateString = [self.dateFormatter stringFromDate:self.selectedDate];
                                            [self.soapWebService updateWorkoutToDb:dateString];

                                            [self.navigationController popViewControllerAnimated:YES];
                                        }];
        
        [alert addAction:yesButton];
        [alert addAction:addEditButton];
        [alert addAction:noButton];
        
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Add My Moves" message:msgInfo preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"Add"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                        MyMovesDetailsViewController *moveDetailVc = [[MyMovesDetailsViewController alloc]initWithNibName:@"MyMovesDetailsViewController" bundle:nil];
                                        moveDetailVc.moveDetailDict = self.tableData[indexPath.row];
                                        
                                        NSString *filter = @"%K == %@";
                                        NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:filter,@"WorkoutCategoryID",_tableData[indexPath.row][@"WorkoutCategoryID"]];
                                                                                
                                        NSString *alphaNumaricStr = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
                                        NSMutableString *planNameUniqueID = [NSMutableString stringWithCapacity: 10];
                                        NSMutableString *planDateListUniqueID = [NSMutableString stringWithCapacity: 10];
                                        NSMutableString *moveNameUniqueID = [NSMutableString stringWithCapacity: 10];

                                        for (long i=0; i<10; i++) {
                                            [planNameUniqueID appendFormat: @"%C", [alphaNumaricStr characterAtIndex: arc4random_uniform([alphaNumaricStr length])]];
                                        }
                                        
                                        for (long i=0; i<10; i++) {
                                            [planDateListUniqueID appendFormat: @"%C", [alphaNumaricStr characterAtIndex: arc4random_uniform([alphaNumaricStr length])]];
                                        }
                                        
                                        for (long i=0; i<10; i++) {
                                            [moveNameUniqueID appendFormat: @"%C", [alphaNumaricStr characterAtIndex: arc4random_uniform([alphaNumaricStr length])]];
                                        }
                                        
                                        planNameUniqueID      = [@"M-" stringByAppendingString:planNameUniqueID];
                                        planDateListUniqueID  = [@"M-" stringByAppendingString:planDateListUniqueID];
                                        moveNameUniqueID      = [@"M-" stringByAppendingString:moveNameUniqueID];

                                        
                                        moveDetailVc.parentUniqueID = moveNameUniqueID;
                                        
                                        NSString *planNameStr = @"Custom Plan";

                                            [self.soapWebService addMovesToDb:_tableData[indexPath.row]
                                                                 SelectedDate:_selectedDate
                                                                     planName:planNameStr
                                                                 categoryName:nil
                                                                   CategoryID:0
                                                                     tagsName:self.filter1.text
                                                                       TagsId:0
                                                                       status:@"New"
                                                               PlanNameUnique:planNameUniqueID
                                                               DateListUnique:planDateListUniqueID
                                                               MoveNameUnique:moveNameUniqueID];
                                        
                                        moveDetailVc.workoutMethodID = [self.tableData[indexPath.row][@"WorkoutUserDateID"]intValue];
                                        
                                        [self.navigationController popViewControllerAnimated:YES];
                                    }];
        
        UIAlertAction* noButton = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        
        UIAlertAction* addEditButton = [UIAlertAction actionWithTitle:@"Add & Edit"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                            
                                            NSString *filter = @"%K == %@";
                                            NSPredicate *categoryPredicate = [NSPredicate predicateWithFormat:filter,@"WorkoutCategoryID",_tableData[indexPath.row][@"WorkoutCategoryID"]];
                                                                                        
                                            NSString *alphaNumaricStr = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
                                            NSMutableString *planNameUniqueID = [NSMutableString stringWithCapacity: 10];
                                            NSMutableString *planDateListUniqueID = [NSMutableString stringWithCapacity: 10];
                                            NSMutableString *moveNameUniqueID = [NSMutableString stringWithCapacity: 10];
                                            
                                            for (long i=0; i<10; i++) {
                                                [planNameUniqueID appendFormat: @"%C", [alphaNumaricStr characterAtIndex: arc4random_uniform([alphaNumaricStr length])]];
                                            }
                                            
                                            for (long i=0; i<10; i++) {
                                                [planDateListUniqueID appendFormat: @"%C", [alphaNumaricStr characterAtIndex: arc4random_uniform([alphaNumaricStr length])]];
                                            }
                                            
                                            for (long i=0; i<10; i++) {
                                                [moveNameUniqueID appendFormat: @"%C", [alphaNumaricStr characterAtIndex: arc4random_uniform([alphaNumaricStr length])]];
                                            }
                                            
                                            planNameUniqueID        = [@"M-" stringByAppendingString:planNameUniqueID];
                                            planDateListUniqueID    = [@"M-" stringByAppendingString:planDateListUniqueID];
                                            moveNameUniqueID        = [@"M-" stringByAppendingString:moveNameUniqueID];
                                            
                                            NSString *planNameStr = @"Custom Plan";

                                            [self.soapWebService addMovesToDb:_tableData[indexPath.row]
                                                                 SelectedDate:_selectedDate
                                                                     planName:planNameStr
                                                                 categoryName:nil
                                                                   CategoryID:nil
                                                                     tagsName:self.filter1.text
                                                                       TagsId:0
                                                                       status:@"New"
                                                               PlanNameUnique:planNameUniqueID
                                                               DateListUnique:planDateListUniqueID
                                                               MoveNameUnique:moveNameUniqueID];
                                            
                                            MyMovesDetailsViewController *moveDetailVc = [[MyMovesDetailsViewController alloc]initWithNibName:@"MyMovesDetailsViewController" bundle:nil];
                                            
                                            moveDetailVc.moveDetailDict = _tableData[indexPath.row];
                                            moveDetailVc.parentUniqueID = moveNameUniqueID;
                
                                            NSMutableArray *addMovesArr = [[NSMutableArray alloc]init];
                                            NSMutableDictionary *dict = NSMutableDictionary.new;

                                            [dict setObject: moveNameUniqueID  forKey: @"UniqueID"];
                                            [dict setObject: planDateListUniqueID  forKey: @"ParentUniqueID"];

                                            [addMovesArr addObject:dict];
                                            moveDetailVc.addMovesArray = addMovesArr;
                                            
                                            moveDetailVc.currentDate = self.selectedDate;
                                            self.dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
                                            NSString *dateString = [self.dateFormatter stringFromDate:self.selectedDate];
                                            [self.soapWebService updateWorkoutToDb:dateString];
                                            
                                            [self.navigationController pushViewController:moveDetailVc animated:YES];
                                        }];
        
        [alert addAction:yesButton];
        [alert addAction:addEditButton];
        [alert addAction:noButton];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
