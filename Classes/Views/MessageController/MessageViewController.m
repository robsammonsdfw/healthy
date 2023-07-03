//
//  MessageViewController.m
//  DietMasterGo
//

#import "MessageViewController.h"

#import "MessageCell.h"
#import "SendView.h"
#import "DMDataFetcher.h"
#import "DietmasterEngine.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "DMMessage.h"
#import "DMMyLogDataProvider.h"

static NSString *OpponentCellIdentifier = @"OpponentCellIdentifier";
static NSString *OwnerCellIdentifier = @"OwnerCellIdentifier";

int const ShowMessageCountStep = 10;
int const MaximumStringLength = 300;

@interface MessageViewController () <SendViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) SendView *sendView;
/// Dictionary of messages, with the key = date, and value = array of messages.
@property (nonatomic, strong) NSMutableDictionary *messagesDict;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) int countShowedMessage;
@property (nonatomic, strong) NSTimer *messageTimer;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation MessageViewController

#pragma mark - View Lifecycle

- (instancetype)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _messagesDict = [[NSMutableDictionary alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadDataWithScroll)
                                                     name:UpdatingMessageNotification
                                                   object:nil];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    self.view.backgroundColor = UIColorFromHexString(@"#F3F3F3");

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.scrollsToTop = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 25, 0);
    [self.tableView registerClass:[MessageCell class] forCellReuseIdentifier:OpponentCellIdentifier];
    [self.tableView registerClass:[MessageCell class] forCellReuseIdentifier:OwnerCellIdentifier];
    self.tableView.estimatedRowHeight = 25.0f;
    [self.view addSubview:self.tableView];
    
    self.sendView = [[SendView alloc] initWithFrame:CGRectZero];
    self.sendView.translatesAutoresizingMaskIntoConstraints = NO;
    self.sendView.delegate = self;
    [self.view addSubview:self.sendView];
    
    // Constrain.
    UILayoutGuide *layoutGuide = self.view.safeAreaLayoutGuide;
    [self.tableView.leadingAnchor constraintEqualToAnchor:layoutGuide.leadingAnchor constant:0].active = YES;
    [self.tableView.trailingAnchor constraintEqualToAnchor:layoutGuide.trailingAnchor constant:0].active = YES;
    [self.tableView.topAnchor constraintEqualToAnchor:layoutGuide.topAnchor constant:0].active = YES;

    [self.sendView.topAnchor constraintEqualToAnchor:self.tableView.bottomAnchor constant:0].active = YES;
    [self.sendView.leadingAnchor constraintEqualToAnchor:layoutGuide.leadingAnchor constant:0].active = YES;
    [self.sendView.trailingAnchor constraintEqualToAnchor:layoutGuide.trailingAnchor constant:0].active = YES;
    [self.sendView.heightAnchor constraintGreaterThanOrEqualToConstant:50.0f].active = YES;
    UILayoutGuide *keyboardGuide = self.view.keyboardLayoutGuide;
    [self.sendView.bottomAnchor constraintEqualToAnchor:keyboardGuide.topAnchor constant:0].active = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    self.countShowedMessage = ShowMessageCountStep;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(backAction:)];
    [self.navigationItem setLeftBarButtonItem: backButton];
    
    UIBarButtonItem *syncButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                 target:self
                                                                                 action:@selector(syncMessages:)];
    syncButton.style = UIBarButtonItemStylePlain;
    syncButton.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = syncButton;

    self.title = @"Messages";
    self.navigationItem.title = @"Messages";
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self syncMessages:nil];
    if (!self.messageTimer) {
        __weak typeof(self) weakSelf = self;
        self.messageTimer = [NSTimer timerWithTimeInterval:10.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [weakSelf syncMessages:nil];
        }];
    }

    [self setMessagesRead];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self scrollToBottom];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.messageTimer invalidate];
    self.messageTimer = nil;
}

#pragma mark - Helpers

- (FMDatabase *)database {
    FMDatabase* db = [DMDatabaseUtilities database];
    return db;
}

#pragma mark - Message Datasource

- (void)syncMessages:(id)sender {
    if (sender) {
        [DMActivityIndicator showActivityIndicatorWithMessage:@"Updating..."];
    }
    DMMessagesDataProvider *provider = [[DMMessagesDataProvider alloc] init];
    __weak typeof(self) weakSelf = self;
    [provider syncMessagesWithCompletionBlock:^(BOOL completed, NSError *error) {
        if (error && sender) {
            [DMGUtilities showAlertWithTitle:@"Error" message:error.localizedDescription inViewController:nil];
            return;
        }
        [weakSelf reloadDataWithScroll];
    }];
}

- (void)setMessagesRead {
    DMMessagesDataProvider *provider = [[DMMessagesDataProvider alloc] init];
    NSArray<DMMessage *> *messages = [provider unreadMessages];
    if (!messages.count) {
        return; // No messages to process.
    }
    
    UserDataFetcher *fetcher = [[UserDataFetcher alloc] init];
    [fetcher setMessagesReadWithMessages:messages completion:^(NSArray<NSDictionary<NSString *, NSNumber *> *> *messageIds,
                                                               NSError *error) {
        if (error) {
            DMLog(@"Error: %@", error.localizedDescription);
            return;
        }
        for (NSDictionary *dict in messageIds) {
            [provider setReadedMessageId:dict[@"MessageID"]];
        }
    }];
}

/// Counts the number of messages in the dictionary.
- (NSInteger)countMessagesInDict:(NSDictionary *)dict {
    if (!dict) {
        return 0;
    }
    __block NSInteger count = 0;
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSMutableArray *value, BOOL * _Nonnull stop) {
        count += value.count;
    }];
    return count;
}

- (void)reloadDataWithScroll {
    if ([NSThread isMainThread]) {
        [DMActivityIndicator hideActivityIndicator];
        
        NSInteger beforeMessageCount = [self countMessagesInDict:self.messagesDict];
        DMMessagesDataProvider *provider = [[DMMessagesDataProvider alloc] init];
        [self.messagesDict removeAllObjects];
        DMSortedMessageKeysArray = nil;
        [self.messagesDict addEntriesFromDictionary:[provider getMessagesByDate]];
        NSInteger afterMessageCount = [self countMessagesInDict:self.messagesDict];
        
        [self.tableView reloadData];
        if (beforeMessageCount != afterMessageCount) {
            [self scrollToBottom];
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadDataWithScroll];
        });
    }
}

#pragma mark - Actions

- (void)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (void)scrollToBottom {
    if (self.tableView.numberOfSections == 0) {
        return;
    }
    NSInteger lastSection = self.tableView.numberOfSections - 1;
    NSInteger numberOfRows = [self.tableView numberOfRowsInSection:lastSection];
    if (numberOfRows) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:numberOfRows-1 inSection:lastSection] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - SendViewDelegate

- (void)sendView:(SendView *)textView didChangeHeight:(CGFloat)height {
    // No-Op.
}

- (void)sendView:(SendView *)sendView_ didSendText:(NSString *)text {
    if (!text.length) {
        return;
    }
    [self.sendView resignFirstResponder];
    [DMActivityIndicator showActivityIndicatorWithMessage:@"Sending..."];

    DMMessagesDataProvider *provider = [[DMMessagesDataProvider alloc] init];
    __weak typeof(self) weakSelf = self;
    [provider saveMessageText:text withCompletionBlock:^(NSObject *object, NSError *error) {
        if (error) {
            [DMGUtilities showError:error withTitle:@"Error" message:error.localizedDescription inViewController:nil];
            return;
        }
        
        if (!object) {
            [DMGUtilities showError:error withTitle:@"Error" message:@"Please try again." inViewController:nil];
            return;
        }
        
        // Save message that was created.
        FMDatabase* db = [DMDatabaseUtilities database];
        if (![db open]) {
        }

        [db beginTransaction];
        DMMessage *message = (DMMessage *)object;
        NSString *sqlString = [message replaceIntoSQLString];
        [db executeUpdate:sqlString];
        if ([db hadError]) {
            DMLog(@"Error %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];

        [DMActivityIndicator hideActivityIndicator];
        [weakSelf reloadDataWithScroll];
    }];
}

#pragma mark - Messages

- (NSString *)cellIdentifierForType:(DMMessageCellType)type {
    if (type == DMMessageCellTypeMine)
        return OwnerCellIdentifier;
    else if (type == DMMessageCellTypeResponse)
        return OpponentCellIdentifier;
    
    return nil;
}

- (DMMessageCellType)typeFromMessage:(DMMessage *)message {
    DMUser *currentUser = [[DMAuthManager sharedInstance] loggedInUser];
    if ([message.senderId isEqualToString:currentUser.userId.stringValue])
        return DMMessageCellTypeMine;
    else
        return DMMessageCellTypeResponse;
}

#pragma mark - UITableView Delegate/Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.messagesDict.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *messages = [self messagesForSection:section];
    return messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Sort the messages by date.
    NSArray *messages = [self messagesForSection:indexPath.section];
    DMMessage *message = messages[indexPath.row];

    DMMessageCellType type = [self typeFromMessage:message];
    NSString *cellIdentifier = [self cellIdentifierForType:type];
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell setMessage:message withCellType:type];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView_ viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView_.frame.size.width, 20)];
    
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor darkGrayColor];
    label.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:0.75];
    label.shadowOffset = CGSizeMake(0, 2);

    // Sort the messages by date.
    NSString *dateString = [self messageKeysSortedByDate][section];
    [self.dateFormatter setDateStyle:NSDateFormatterFullStyle];
    NSDate *date = [self.dateFormatter dateFromString:dateString];
    NSString *dayString = [self dayStringFromDate:date];
    label.text = dayString;

    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

#pragma mark - Notification Handlers

- (void)keyboardDidShow:(NSNotification *)notification {
    [self scrollToBottom];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    [self scrollToBottom];
}

#pragma mark - Helpers

/// Returns an array of messages sorted by date / section.
- (NSArray *)messagesForSection:(NSInteger)section {
    NSArray *sortedKeys = [self messageKeysSortedByDate];
    NSString *dateString = sortedKeys[section];
    NSArray *messages = [self.messagesDict[dateString] copy];
    return messages;
}

/// Returns an array of sorted messageDictionary keys by date, so we can lay out
/// the UI. The key is timeIntervalSince1970 string.
static NSArray *DMSortedMessageKeysArray = nil;
- (NSArray *)messageKeysSortedByDate {
    if (!self.messagesDict.allKeys.count) {
        return @[];
    }
    // If we have a cached result.
    if (DMSortedMessageKeysArray) {
        return DMSortedMessageKeysArray;
    }
    [self.dateFormatter setDateStyle:NSDateFormatterFullStyle];
    NSArray *sortedKeys = [self.messagesDict.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        NSDate *d1 = [self.dateFormatter dateFromString:obj1];
        NSDate *d2 = [self.dateFormatter dateFromString:obj2];
        return [d1 compare: d2];
    }];
    DMSortedMessageKeysArray = sortedKeys;
    return sortedKeys;
}

- (BOOL)isCurrentWeekDate:(NSDate *)date {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComps = [gregorian components:NSCalendarUnitWeekday fromDate:date];
    NSDateComponents *todayComps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    return todayComps.weekday >= dateComps.weekday;
}

- (BOOL)isCurrentWeekWithDate:(NSDate *)date {
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *compareDate = [calender components:NSCalendarUnitWeekOfYear fromDate:date];
    NSDateComponents *currentDate = [calender components:NSCalendarUnitWeekOfYear fromDate:[NSDate date]];
    return [compareDate weekOfYear] == [currentDate weekOfYear];
}

- (BOOL)isTodayDate:(NSDate *)date {
    BOOL today = [[NSCalendar currentCalendar] isDateInToday:date];
    return today;
}

- (NSString *)dayStringFromDate:(NSDate *)date {
    NSString *resultStr = nil;
    if ([self isTodayDate:date]) {
        resultStr = @"Today";
    } else if ([self isCurrentWeekWithDate:date]) {
        [self.dateFormatter setDateFormat:@"eeee"];
        resultStr = [self.dateFormatter stringFromDate:date];
    } else {
        [self.dateFormatter setDateFormat:@"MMMM dd"];
        resultStr = [self.dateFormatter stringFromDate:date];
    }
    
    return resultStr;
}

@end
