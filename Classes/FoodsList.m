#import "FoodsList.h"
#import "DietmasterEngine.h"

@implementation FoodsList

@synthesize foodsNameList,foodsIDList, mainDelegate;

- (void)viewDidLoad {
    DietmasterEngine *dietEngine = [DietmasterEngine instance];
	dbPath	= [dietEngine databasePath];
	
	if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {	
		
		NSString *query = @"SELECT FoodKey, Name FROM Food ORDER BY Name LIMIT 250";
		sqlite3_stmt *statement;
		
		if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
			foodsIDList = [[NSMutableArray alloc] init];
			self.foodsNameList = [[NSMutableArray alloc] init];
			
			while (sqlite3_step(statement) == SQLITE_ROW) {
				
				char *foodName = (char *) sqlite3_column_text(statement, 1);
				str_foodName = [[NSString alloc] initWithUTF8String:foodName] ;
				
				int_foodKey = [NSNumber numberWithInt: sqlite3_column_int(statement, 0)];	
				
				[foodsIDList addObject:int_foodKey];
				[self.foodsNameList addObject:str_foodName];
			
			}
		sqlite3_finalize(statement);	
		}
		
		sqlite3_close(database);
	}
    
    [self.navigationController.navigationBar setTranslucent:NO];
    [super viewDidLoad];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.foodsNameList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *FoodsTable = @"FoodsTable";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             FoodsTable];
    if (cell == nil) {
		
        cell = [[[UITableViewCell alloc] 
				 initWithStyle:UITableViewCellStyleDefault
				 reuseIdentifier: FoodsTable] autorelease];
    }
	
    NSUInteger row = [indexPath row];
    cell.textLabel.text = [foodsNameList objectAtIndex:row];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
	
    return cell;
}

-(void)openUrl:(id)sender {
    NSLog(@"we did it!");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    NSString *rowValue = [foodsNameList objectAtIndex:row];
    
    NSString *message = [[NSString alloc] initWithFormat:
                         @"You selected %@", rowValue];
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle:@"Row Selected!"
                          message:message 
                          delegate:nil 
                          cancelButtonTitle:@"Yes I Did" 
                          otherButtonTitles:nil];
    [alert show];
    
    [message release];
    [alert release];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



- (void)dealloc {
    [super dealloc];
}


@end
