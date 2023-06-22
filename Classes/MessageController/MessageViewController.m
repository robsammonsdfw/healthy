//
//  MessageViewController.m
//  DietMasterGo
//

#import "MessageViewController.h"
#import "MessageCell.h"
#import "SendView.h"
#import "Common.h"

#import "SoapWebServiceEngine.h"
#import "DietmasterEngine.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

#import "UIView+FrameControl.h"
#import "NSDate+ConvertToString.h"
#import "NSString+ConvertToDate.h"

#import "DMMessage.h"

static NSString *OpponentCellIdentifier = @"OpponentCellIdentifier";
static NSString *OwnerCellIdentifier = @"OwnerCellIdentifier";

int const ShowMessageCountStep = 10;
int const MaximumStringLength = 300;

@interface MessageViewController () <SendViewDelegate, UITableViewDataSource, UITableViewDelegate> {
    NSString *userId;
}

@property (nonatomic, strong) SendView *sendView;
/// Dictionary of messages, with the key = date, and value = array of messages.
@property (nonatomic, strong) NSMutableDictionary *messagesDict;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) int countShowedMessage;

@end

@implementation MessageViewController

#pragma mark - View Lifecycle

- (instancetype)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _messagesDict = [[NSMutableDictionary alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    self.view.backgroundColor = UIColorFromHex(0xF3F3F3);
    self.title = @"Messages";

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
    [self.view addSubview:self.tableView];
    
    self.sendView = loadNib([SendView class], @"SendView", self);
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
    [self.sendView.heightAnchor constraintEqualToConstant:50.0f].active = YES;
    UILayoutGuide *keyboardGuide = self.view.keyboardLayoutGuide;
    [self.sendView.bottomAnchor constraintEqualToAnchor:keyboardGuide.topAnchor constant:0].active = YES;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 32)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.cornerRadius = 10;
    button.layer.masksToBounds = YES;
    button.backgroundColor = UIColorFromHex(0x8e8e93);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:@"Show Previous Messages" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11.];
    [button setSize:CGSizeMake(200, 20)];
    [button addTarget:self action:@selector(addMessage) forControlEvents:UIControlEventTouchUpInside];
    button.center = CGPointMake(headerView.frame.size.width / 2, headerView.frame.size.height / 2);
    [headerView addSubview:button];
    self.tableView.tableHeaderView = headerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    self.countShowedMessage = ShowMessageCountStep;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    userId = [prefs valueForKey:@"userid_dietmastergo"];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(backAction:)];
    [self.navigationItem setLeftBarButtonItem: backButton];
    
    UIBarButtonItem *syncButton = [[UIBarButtonItem alloc] initWithTitle:@"Sync"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(syncMessages:)];
    self.navigationItem.rightBarButtonItem = syncButton;

    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        
    DietmasterEngine *engine = [DietmasterEngine sharedInstance];
    [engine startUpdatingMessages];
    
    [self reloadDataWithScroll:@(YES)];
    [self updateHeaderView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadDataWithScroll:)
                                                 name:UpdatingMessageNotification
                                               object:nil];
    [self setMessagesRead];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    DietmasterEngine *engine = [DietmasterEngine sharedInstance];
    [engine stopUpdatingMessages];
}

#pragma mark - Helpers

- (FMDatabase *)database {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
    if (![db open]) {
    }
    return db;
}

- (BOOL)isCurrentWeekDate:(NSDate *)date {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComps = [gregorian components:NSCalendarUnitWeekday fromDate:date];
    NSDateComponents *todayComps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    
    return (timeInterval < 7*24*60*60) && (todayComps.weekday >= dateComps.weekday);
}

- (BOOL)isTodayDate:(NSDate *)date {
    return [[date stringWithFormat:@"yyyyMMdd"] isEqualToString:[[NSDate date] stringWithFormat:@"yyyyMMdd"]];
}

- (NSString *)dayStringFromDate:(NSDate *)date {
    NSString *resultStr = nil;
    if ([self isTodayDate:date])
        resultStr = @"Today";
    else if ([self isCurrentWeekDate:date])
        resultStr = [date stringWithFormat:@"eeee"];
    else
        resultStr = [date stringWithFormat:@"MMMM dd"];
    
    return resultStr;
}

#pragma mark - Message Datasource

- (void)syncMessages:(id)sender {
    [DMActivityIndicator showActivityIndicatorWithMessage:@"Updating..."];
    DietmasterEngine *engine = [DietmasterEngine sharedInstance];
    [engine syncMessages];
}

- (void)setMessagesRead {
    NSArray<DMMessage *> *messages = [[DietmasterEngine sharedInstance] unreadMessages];
    if (!messages.count) {
        return; // No messages to process.
    }
    
    DataFetcher *fetcher = [[DataFetcher alloc] init];
    [fetcher setMessagesReadWithMessages:messages completion:^(NSArray<DMMessage *> *messages, NSError *error) {
        if (error) {
            DMLog(@"Error: %@", error.localizedDescription);
            return;
        }
        for (DMMessage *message in messages) {
            [[DietmasterEngine sharedInstance] setReadedMessageId:message.messageId];
        }
    }];
}

- (int)messageCount {
    __block int count = 0;
    [self.messagesDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSMutableArray *value, BOOL * _Nonnull stop) {
        count += value.count;
    }];
    return count;
}

- (void)reloadDataWithScroll:(NSNumber *)scroll {
    [DMActivityIndicator hideActivityIndicator];
    
    int beforeMessagesCount = [self messageCount];
    
    NSString *query = [NSString stringWithFormat: @"SELECT * FROM (SELECT * FROM Messages ORDER BY Id DESC) ORDER BY Id ASC"];
    FMResultSet *rs = [[self database] executeQuery:query];
    
    [self.messagesDict removeAllObjects];
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        DMMessage *message = [[DMMessage alloc] initWithDictionary:dict];
        NSString *dayString = [self dayStringFromDate:message.dateSent];
        
        if (self.messagesDict[dayString]) {
            NSMutableArray *messages = self.messagesDict[dayString];
            [messages addObject:message];
        } else {
            NSMutableArray *messages = [NSMutableArray array];
            [messages addObject:message];
            self.messagesDict[dayString] = messages;
        }
    }
    
    if ([[self database] hadError]) {
        DMLog(@"Err %d: %@", [[self database] lastErrorCode], [[self database] lastErrorMessage]);
    }
    
    [rs close];
    [self.tableView reloadData];
    
    BOOL reloadWithScroll = ([scroll isKindOfClass:[NSNumber class]] ? scroll.boolValue : NO);
    int afterMessagesCount = [self messageCount];
    if (beforeMessagesCount != afterMessagesCount && reloadWithScroll == YES) {
        [self scrollToBottom];
    }
}

#pragma mark - Actions

- (void)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (void)addMessage {
    [DMActivityIndicator showActivityIndicatorWithMessage:@"Updating..."];
    self.countShowedMessage += ShowMessageCountStep;
    [self reloadDataWithScroll:@(NO)];
    [self updateHeaderView];
    [DMActivityIndicator hideActivityIndicator];
}

- (void)updateHeaderView {
    if ([self messageCount] < self.countShowedMessage) {
        self.tableView.tableHeaderView = nil;
    }
}

- (void)scrollToBottom {
    NSInteger lastSection = self.tableView.numberOfSections - 1;
    NSInteger numberOfRows = [self.tableView numberOfRowsInSection:lastSection];
    if (numberOfRows) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:numberOfRows-1 inSection:lastSection] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - SendViewDelegate

- (void)sendView:(SendView *)sendView_ didSendText:(NSString *)text {
    if (!text.length) {
        return;
    }
    [sendView_.messageView resignFirstResponder];
    [DMActivityIndicator showActivityIndicatorWithMessage:@"Sending..."];

    DietmasterEngine* dietmasterEngine = [DietmasterEngine sharedInstance];
    DataFetcher *fetcher = [[DataFetcher alloc] init];
    [fetcher saveMessageWithText:text completion:^(DMMessage *message, NSError *error) {
        if (error) {
            [DMGUtilities showError:error withTitle:@"Error" message:@"Please try again." inViewController:nil];
            return;
        }
        // Save message that was created.
        FMDatabase* db = [FMDatabase databaseWithPath:[dietmasterEngine databasePath]];
        if (![db open]) {
        }

        [db beginTransaction];
        NSString *sqlString = [message replaceIntoSQLString];
        [db executeUpdate:sqlString];
        if ([db hadError]) {
            DMLog(@"Error %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [db commit];

        [DMActivityIndicator hideActivityIndicator];
        [self reloadDataWithScroll:@(YES)];
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
    if ([message.senderId isEqualToString:userId])
        return DMMessageCellTypeMine;
    else
        return DMMessageCellTypeResponse;
}

#pragma mark - UITableView Delegate/Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.messagesDict.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = self.messagesDict.allKeys[section];
    NSArray *messages = [self.messagesDict[key] copy];
    return messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = self.messagesDict.allKeys[indexPath.section];
    NSArray *messages = [self.messagesDict[key] copy];
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
    
    label.text = [self tableView:tableView_ titleForHeaderInSection:section];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11.0];
    label.backgroundColor = UIColorFromHex(0xffffff);
    label.textColor = UIColorFromHex(0x8892a5);
    label.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:0.75];
    label.shadowOffset = CGSizeMake(0, 2);

    return label;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *key = self.messagesDict.allKeys[section];
    
    return [NSString stringWithFormat:@"%@", key];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0f;
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

@end
