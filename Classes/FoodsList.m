#import "FoodsList.h"
#import "DietmasterEngine.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

static NSString *CellIdentifier = @"FoodsTableCellIdentifer";

@interface FoodsList() <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@end

@implementation FoodsList

@synthesize foodsNameList, foodsIDList, mainDelegate;

- (instancetype)init {
    self = [super initWithNibName:@"FoodsList" bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase *db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
        
    }
    
    NSString *query = @"SELECT FoodKey, Name FROM Food ORDER BY Name LIMIT 300";
    FMResultSet *rs = [db executeQuery:query];
    foodsIDList = [[NSMutableArray alloc] init];
    self.foodsNameList = [[NSMutableArray alloc] init];
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        str_foodName = dict[@"Name"];
        int_foodKey = dict[@"FoodKey"];
        [foodsIDList addObject:int_foodKey];
        [self.foodsNameList addObject:str_foodName];
    }
    if ([db hadError]) {
        DMLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    [self.navigationController.navigationBar setTranslucent:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.foodsNameList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [foodsNameList objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

@end
