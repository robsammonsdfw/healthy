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
    self.tableData = [self.soapWebService getMovesFromDatabaseWithCategoryFilter:self.filterCategory
                                                                       tagFilter:self.filterTag
                                                                      textSearch:self.searchBar.text];
    [self.tblView reloadData];
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
    DMMove *selectedMove = [self.tableData copy][indexPath.row];
    
    [self.dateFormatter setDateFormat:@"LLLL d, yyyy"];
    NSString *msgInfo = [NSString stringWithFormat:@"New Move will be added to %@", [self.dateFormatter stringFromDate:_selectedDate]];
   
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Add My Moves" message:msgInfo preferredStyle:UIAlertControllerStyleAlert];
    __block NSString *planNameUniqueID = [NSUUID UUID].UUIDString;
    __block NSString *planDateListUniqueID  = [NSUUID UUID].UUIDString;
    __block NSString *moveNameUniqueID  = [NSUUID UUID].UUIDString;

    UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"Add"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
        
                                        NSString *planNameStr = @"Custom Plan";
                                        [self.soapWebService addMovesToDb:nil
                                                             SelectedDate:self.selectedDate
                                                                 planName:planNameStr
                                                             categoryName:nil
                                                               CategoryID:0
                                                                 tagsName:self.filter1.text
                                                                   TagsId:0
                                                                   status:@"New"
                                                           PlanNameUnique:planNameUniqueID
                                                           DateListUnique:planDateListUniqueID
                                                           MoveNameUnique:moveNameUniqueID];
                                    
                                    [self.navigationController popViewControllerAnimated:YES];
                                }];
    
    UIAlertAction* noButton = [UIAlertAction actionWithTitle:@"Cancel"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    
    UIAlertAction* addEditButton = [UIAlertAction actionWithTitle:@"Add & Edit"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                        
                                        [self.soapWebService addMovesToDb:nil
                                                             SelectedDate:self.selectedDate
                                                                 planName:nil
                                                             categoryName:nil
                                                               CategoryID:nil
                                                                 tagsName:self.filter1.text
                                                                   TagsId:0
                                                                   status:@"New"
                                                           PlanNameUnique:planNameUniqueID
                                                           DateListUnique:planDateListUniqueID
                                                           MoveNameUnique:moveNameUniqueID];
                                        
                                        MyMovesDetailsViewController *moveDetailVc = [[MyMovesDetailsViewController alloc] init];
                                        moveDetailVc.selectedDate = self.selectedDate;

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

@end
