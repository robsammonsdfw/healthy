//
//  MyMovesListViewController.m
//  MyMoves
//
//  Created by Sathis Kumar on 24/01/19.
//

#import "MyMovesListViewController.h"

#import "MyMovesDetailsViewController.h"
#import "MyMovesDataProvider.h"
#import "DMMove.h"
#import "DMMoveCategory.h"
#import "DMMoveTag.h"
#import "DMMoveRoutine.h"

/// Cell identifier for a move's cell.
static NSString *DMMovesCellIdentifier = @"MovesCellIdentifier";
static NSString *DMMovesEmptyCellIdentifier = @"DMMovesEmptyCellIdentifier";

@interface MyMovesListViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDictionary *moveDetailDictToDelete;

/// Data source for exercises.
@property (nonatomic, strong) MyMovesDataProvider *soapWebService;

/// Array that holds data that's presented in the table.
@property (nonatomic, strong) NSArray<DMMove *> *tableData;

/// I believe this is the name of the plan's template.
@property (nonatomic, strong) IBOutlet UITextField *templateNameTxtFld;

/// Table that displays the exercises.
@property (nonatomic, strong) IBOutlet UITableView *tblView;
/// Distance measured for moving keyboard and text fields.
@property (nonatomic) CGFloat animatedDistance;

/// Filters for searching for moves.
@property (nonatomic, strong) DMMoveCategory *filterCategory;
@property (nonatomic, strong) DMMoveTag *filterTag;

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
    self.soapWebService = [[MyMovesDataProvider alloc] init];
    self.tableData = [self.soapWebService getMovesFromDatabaseWithCategoryFilter:self.filterCategory
                                                                       tagFilter:self.filterTag
                                                                      textSearch:self.searchBar.text];
    [self.tblView reloadData];
}

/// Shows the body part filter.
- (IBAction)bodyPartAction:(id)sender {
    __weak typeof(self) weakSelf = self;
    NSArray *bodyPartArray = [self.soapWebService loadListOfBodyPart];
    DMPickerViewController *pickerViewController = [[DMPickerViewController alloc] init];
    [pickerViewController setDataSourceWithDataArray:bodyPartArray showNoneRow:YES];
    pickerViewController.didSelectOptionCallback = ^(id<DMPickerViewDataSource> object, NSInteger row) {
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
    NSInteger selectedIndex = 0;
    if (self.filterCategory) {
        selectedIndex = [bodyPartArray indexOfObject:self.filterCategory];
    }
    [pickerViewController presentPickerIn:self selectedIndex:selectedIndex];
}

/// Shows the tags to filter the list by in a picker.
- (IBAction)filterOne:(id)sender {
    __weak typeof(self) weakSelf = self;
    NSArray *dataArray = [self.soapWebService loadListOfTags];
    DMPickerViewController *pickerViewController = [[DMPickerViewController alloc] init];
    [pickerViewController setDataSourceWithDataArray:dataArray showNoneRow:YES];
    pickerViewController.didSelectOptionCallback = ^(id<DMPickerViewDataSource> object, NSInteger row) {
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
    NSInteger selectedIndex = 0;
    if (self.filterTag) {
        selectedIndex = [dataArray indexOfObject:self.filterTag];
    }
    [pickerViewController presentPickerIn:self selectedIndex:selectedIndex];
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
    __block DMMove *selectedMove = [self.tableData copy][indexPath.row];
    __block DMMoveDay *selectedDay = self.moveDay;
    __weak typeof(self) weakSelf = self;
    
    [self.dateFormatter setDateFormat:@"LLLL d, yyyy"];
    NSString *msgInfo = [NSString stringWithFormat:@"New Move will be added to %@", [self.dateFormatter stringFromDate:_selectedDate]];
   
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Add My Moves" message:msgInfo preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"Add"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
        
                                    // Create a routine with the user selected optoins.
                                    DMMoveRoutine *newRoutine = [DMMoveRoutine routineWithMove:selectedMove forDay:selectedDay];
                                    // the newRoutine ID will be nil, so need to save to database first.
                                    [weakSelf.soapWebService addMoveRoutine:newRoutine toMoveDay:selectedDay];
                                            
                                    [self.navigationController popViewControllerAnimated:YES];
                                }];
    
    UIAlertAction* noButton = [UIAlertAction actionWithTitle:@"Cancel"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    
    UIAlertAction* addEditButton = [UIAlertAction actionWithTitle:@"Add & Edit"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                        
                                        MyMovesDetailsViewController *moveDetailVc = [[MyMovesDetailsViewController alloc] init];
                                        moveDetailVc.selectedDate = self.selectedDate;

        /// Save then push controller.
        ///
                                        self.dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
                                        NSString *dateString = [self.dateFormatter stringFromDate:self.selectedDate];
                                        //[self.soapWebService updateWorkoutToDb:dateString];
                                        
                                        [self.navigationController pushViewController:moveDetailVc animated:YES];
                                    }];
    
    [alert addAction:yesButton];
    [alert addAction:addEditButton];
    [alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
