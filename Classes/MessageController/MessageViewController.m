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
#import "MNMBottomPullToRefreshManager.h"

#import "MBProgressHUD.h"
#import "NSObject+Blocks.h"
#import "UIView+FrameControl.h"
#import "NSDate+ConvertToString.h"
#import "NSString+ConvertToDate.h"
#import "UIViewController+Keyboard.h"
#import "UIAlertView+Blocks.h"

static NSString *OpponentCellIdentifier = @"OpponentCellIdentifier";
static NSString *OwnerCellIdentifier = @"OwnerCellIdentifier";

int const ShowMessageCountStep = 10;

int const MaximumStringLength = 300;

@interface MessageViewController ()<HPGrowingTextViewDelegate,SendViewDelegate,
WSSendMessageDelegate,MNMBottomPullToRefreshManagerClient,UITableViewDataSource,UITableViewDelegate,WSSetMessageReadDelegate,TTTAttributedLabelDelegate> {
    SendView *sendView;
    IBOutlet UITableView *tableView;
    MBProgressHUD *hud;
    NSString *userId;
    FMDatabase *dataBase;
    NSDictionary *createMessage;
    NSMutableArray *sections;
    MNMBottomPullToRefreshManager *pullToRefreshManager;
    int countShowedMessage;
}

@end

@implementation MessageViewController
- (FMDatabase *)database {
    DietmasterEngine* dietmasterEngine = [DietmasterEngine instance];
    
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
        resultStr = [date stringWithFormat:@"dd MMMM"];
    
    return resultStr;
}

- (void)reloadDataWithScroll:(NSNumber *)scroll {
    int beforeMessagesCount = [self messageCount];
    
    NSString *query = [NSString stringWithFormat: @"SELECT * FROM (SELECT * FROM Messages ORDER BY Id DESC LIMIT %d) ORDER BY Id ASC",countShowedMessage];
    
    sections = [[NSMutableArray alloc] init];
    
    dataBase = [self database];
    FMResultSet *rs = [dataBase executeQuery:query];
    
    while ([rs next]) {
        
        NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [rs stringForColumn:@"Id"],    @"MessageID",
                                 [rs stringForColumn:@"Text"],   @"Text",
                                 [rs stringForColumn:@"Sender"], @"Sender",
                                 [rs dateForColumn:@"Date"],     @"DsteTime", nil];
        NSDate *date = [rs dateForColumn:@"Date"];
        NSString *dayString = [self dayStringFromDate:date];
        
        NSDictionary * section = nil;
        NSArray *filter = [sections filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"day == %@",dayString]];
        
        if (filter.count == 0) {
            section = [NSDictionary dictionaryWithObjectsAndKeys:dayString,@"day",
                       [NSMutableArray array], @"items", nil];
            [sections addObject:section];
        }
        else {
            section = filter[0];
        }
        
        NSMutableArray *items = section[@"items"];
        [items addObject:message];
    }
    
    if ([dataBase hadError]) {
        NSLog(@"Err %d: %@", [dataBase lastErrorCode], [dataBase lastErrorMessage]);
    }
    
    [rs close];
    [tableView reloadData];
    
    BOOL reloadWithScroll = ([scroll isKindOfClass:[NSNumber class]] ? scroll.boolValue : NO);
    int afterMessagesCount = [self messageCount];
    if (beforeMessagesCount != afterMessagesCount && reloadWithScroll == YES)
        [self scrollToBottom];
    
    [pullToRefreshManager tableViewReloadFinished];
}

- (void)synchMessages:(id)sender {
    if (sender) {
    }
    else
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = Localized(@"Updating...");
    
    [[DietmasterEngine instance] synchMessagesWithCompletion:^(BOOL success, NSString *errorString) {
        [pullToRefreshManager tableViewReloadFinished];
        if (errorString) {
            hud.labelText = errorString;
            hud.labelFont = [hud.labelFont fontWithSize:10];
            [hud hide:YES afterDelay:1.0];
        }
        else {
            [self reloadDataWithScroll:@(YES)];
            [hud hide:YES];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    tableView.scrollsToTop = NO;
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;//11-02-2016
    
    self.title = Localized(@"Mail");
    
    countShowedMessage = ShowMessageCountStep;
    self.keyboardAutoScrolling = YES;
    [self setKeyboardAutoDismissing:YES view:tableView];
    
    sendView = loadNib([SendView class], @"SendView", self);
    sendView.messageView.delegate = self;
    sendView.delegate = self;
    [self.view addSubview:sendView];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    userId = [prefs valueForKey:@"userid_dietmastergo"];
    
    pullToRefreshManager = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:30.0f
                                                                                        tableView:tableView
                                                                                       withClient:self];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                  tableView.frame.size.width,
                                                                  32)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.cornerRadius = 10;
    button.layer.masksToBounds = YES;
    button.backgroundColor = UIColorFromHex(0x8e8e93);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:Localized(@"show previous messages") forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11.];
    [button setSize:CGSizeMake(200, 20)];
    [button addTarget:self action:@selector(addMessage) forControlEvents:UIControlEventTouchUpInside];
    button.center = CGPointMake(headerView.frame.size.width / 2, headerView.frame.size.height / 2);
    [headerView addSubview:button];
    tableView.tableHeaderView = headerView;
    
    if (IsIOS7) {
        [self.navigationController.navigationBar setBarTintColor:[UIColor blackColor]];
        [self.navigationController.navigationBar setTranslucent:YES];
    }
    else {
        [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
        [self.navigationController.navigationBar setTranslucent:NO];
    }
    
    [self.navigationController setNavigationBarHidden:NO];
}


- (int)messageCount {
    int count = 0;
    NSArray *messages = [sections valueForKey:@"items"];
    for (NSArray *items in messages) {
        count += items.count;
    }
    return count;
}

- (void)updateHeaderView {
    if ([self messageCount] < countShowedMessage) {
        tableView.tableHeaderView = nil;
    }
}

- (void)addMessage {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = Localized(@"Updating...");
    [self performAfterDelay:0.1 block:^{
        countShowedMessage += ShowMessageCountStep;
        [self reloadDataWithScroll:@(NO)];
        [self updateHeaderView];
        [hud hide:YES];
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [pullToRefreshManager relocatePullToRefreshView];
}

- (void)scrollToBottom {
    CGFloat yOffset = 0;
    
    if (tableView.contentSize.height > tableView.bounds.size.height) {
        yOffset = tableView.contentSize.height - tableView.bounds.size.height + ((IsIOS7)?65:0);
    }
    
    [tableView setContentOffset:CGPointMake(0, yOffset) animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGFloat boundsHeight = self.view.bounds.size.height;
    [sendView setOrigin:CGPointMake(0,boundsHeight - sendView.bounds.size.height)];
    [sendView setSize:CGSizeMake(SCREEN_WIDTH, sendView.bounds.size.height)];
    [tableView setSize:CGSizeMake(tableView.bounds.size.width,
                                  boundsHeight - sendView.bounds.size.height - ((IsIOS7)?65:0))];
    
    
//    sendView.frame = CGRectMake(0, boundsHeight - sendView.frame.size.height, SCREEN_WIDTH, sendView.frame.size.height);
    [self reloadDataWithScroll:@(YES)];
    [self synchMessages:nil];
    [self updateHeaderView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadDataWithScroll:)
                                                 name:UpdatingMessageNotification
                                               object:nil];
    
    [self setMessagesRead];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    pullToRefreshManager.client = nil;
    pullToRefreshManager.table = nil;
    pullToRefreshManager = nil;
    tableView.delegate = nil;
    tableView.dataSource = nil;
    [DietmasterEngine instance].messageCompletion = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    sendView = nil;
}

#pragma mark - WSSendMessageDelegate

- (void)sendMessageFinished:(NSMutableArray *)responseArray {
    if (responseArray.count && createMessage) {
        NSDictionary *result = responseArray[0];
        NSString *messageId = result[@"MessageID"];
        NSDate *dateValue = [result[@"DateTime"] dateWithFormat:@"MM/dd/yyyy hh:mm:ss a"];
        
        dataBase = [self database];
        [dataBase beginTransaction];
        
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO Messages (Id,Text,Sender,Date,Read)"
                               "VALUES ('%@','%@','%@','%f', 1)",
                               messageId,
                               createMessage[@"Text"],
                               createMessage[@"Sender"],
                               [dateValue timeIntervalSince1970]];
        createMessage = nil;
        
        [dataBase executeUpdate:insertSQL];
        
        BOOL statusMsg = YES;
        
        if ([dataBase hadError]) {
            NSLog(@"Err %d: %@", [dataBase lastErrorCode], [dataBase lastErrorMessage]);
            statusMsg = NO;
        }
        [dataBase commit];
        [self reloadDataWithScroll:@(YES)];
        [pullToRefreshManager tableViewReleased];
    }
    
    [hud hide:YES];
}

- (void)sendMessageFailed:(NSString *)failedMessage {
    [hud hide:YES];
    UIAlertViewShow(Localized(@"Error"),
                    failedMessage,
                    @[Localized(@"Cancel"),
                      Localized(@"Retry")],
                    ^(UIAlertView *alertView, NSInteger buttonIndex) {
                        if (buttonIndex == 1) {
                            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                            NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                      @"SendMessage", @"RequestType",
                                                      [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                                                      [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                                                      createMessage[@"Text"], @"MessageText",
                                                      nil];
                            
                            SoapWebServiceEngine *soapWebService = [[SoapWebServiceEngine alloc] init];
                            soapWebService.wsSendMessageDelegate = self;
                            [soapWebService callWebservice:infoDict];
                        }
                        else {
                            createMessage = nil;
                        }
                    });
}

#pragma mark - WSSetMessageReadDelegate
- (void)setMessageReadFinished:(NSMutableArray *)responseArray {
    for (NSDictionary *message in responseArray) {
        NSString *status = message[@"Status"];
        if ([status isEqualToString:@"Success"]) {
            NSString *messageId = message[@"MessageID"];
            [[DietmasterEngine instance] setReadedMessageId:messageId];
        }
    }
}

- (void)setMessageReadFailed:(NSString *)failedMessage {
    NSLog(@"%@", failedMessage);
}

#pragma mark - SendViewDelegate
- (void)setMessagesRead {
    NSArray *messages = [[DietmasterEngine instance] unreadingMessages];
    
    NSMutableArray *messageIds = [NSMutableArray arrayWithCapacity:messages.count];
    for (NSDictionary *message in messages) {
        [messageIds addObject:@{@"MessageID": message[@"MessageID"]}];
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"SetMessageRead", @"RequestType",
                              [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                              [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                              messageIds, @"MessageIds",
                              nil];
    
    SoapWebServiceEngine *soapWebService = [[SoapWebServiceEngine alloc] init];
    soapWebService.wsSetMessageReadDelegate = self;
    [soapWebService callWebservice:infoDict];
}

- (void)keyboardLayoutSubviews {
    CGFloat boundsHeight = self.view.bounds.size.height;
    
    if (self.keyboardInfo) {
        CGRect keyboardFrameInWindow = [self.keyboardInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        CGPoint tableTopOffset = tableView.contentOffset;
        CGPoint tableBottomOffset = CGPointMake(tableTopOffset.x,
                                                tableTopOffset.y+tableView.bounds.size.height);
        [sendView setOrigin:CGPointMake(0,
                                        boundsHeight-keyboardFrameInWindow.size.height -
                                        sendView.frame.size.height)];
        [tableView setSize:CGSizeMake(tableView.frame.size.width, sendView.frame.origin.y - ((IsIOS7)?65:0))];
        
        tableTopOffset = CGPointMake(tableBottomOffset.x,
                                     tableBottomOffset.y-tableView.bounds.size.height);
        tableTopOffset.y = fminf(tableTopOffset.y,
                                 tableView.contentSize.height-tableView.bounds.size.height);
        tableTopOffset.y = fmaxf(tableTopOffset.y,0);
        
        [tableView setContentOffset:tableTopOffset animated:NO];
    }
    else {
        [sendView setOrigin:CGPointMake(0, boundsHeight-sendView.frame.size.height)];
        [tableView setSize:CGSizeMake(tableView.frame.size.width, sendView.frame.origin.y - ((IsIOS7)?65:0))];
    }
}

- (void)sendView:(SendView *)sendView_ didSendText:(NSString *)text {
    [sendView_.messageView resignFirstResponder];
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = Localized(@"Sending...");
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"SendMessage", @"RequestType",
                              [prefs valueForKey:@"userid_dietmastergo"], @"UserID",
                              [prefs valueForKey:@"authkey_dietmastergo"], @"AuthKey",
                              text, @"MessageText",
                              nil];
    
    createMessage = [NSDictionary dictionaryWithObjectsAndKeys: text, @"Text",
                     [NSDate date], @"DsteTime",
                     [prefs valueForKey:@"userid_dietmastergo"], @"Sender", nil];
    
    SoapWebServiceEngine *soapWebService = [[SoapWebServiceEngine alloc] init];
    soapWebService.wsSendMessageDelegate = self;
    [soapWebService callWebservice:infoDict];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    float diff = (sendView.messageView.frame.size.height - height);
    
    CGRect r = sendView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    sendView.frame = r;
    [self keyboardLayoutSubviews];
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView {
    sendView.sendButton.enabled = growingTextView.text.length > 0;
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *result = growingTextView.text;
    result = [result stringByReplacingCharactersInRange:range withString:text];
    if (result.length > MaximumStringLength)
        return NO;
    else
        return YES;
}

#pragma mark - messges
- (NSString *)cellIdentifierForType:(MessageType)type {
    if (type == MessageOwnerType)
        return OwnerCellIdentifier;
    else if (type == MessageOpponentType)
        return OpponentCellIdentifier;
    
    return nil;
}

- (MessageType)typeFromMessage:(NSDictionary *)message {
    if ([message[@"Sender"] isEqualToString:userId])
        return MessageOwnerType;
    else
        return MessageOpponentType;
}

- (NSString *)textFromMessage:(NSDictionary *)message {
    return message[@"Text"];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *currentSection = sections[section];
    NSArray *messages = currentSection[@"items"];
    
    int additional = (section == (sections.count - 1)) ? 1 : 0;
    return messages.count + additional;
    
}

#pragma mark -

- (id)dequeueReusableCellWithMessageType:(MessageType)messageType {
    NSString *cellIdentifier = [self cellIdentifierForType:messageType];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = loadNibForCell(cellIdentifier, @"MessageCell", self);
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *section = sections[indexPath.section];
    
    NSArray *messages = section[@"items"];
    NSLog(@"%@",messages);
    
    if ((indexPath.section == (sections.count - 1)) && indexPath.row == messages.count) {
        static NSString *cellIdentifier = @"lastCellIdentifier";
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:cellIdentifier];
        cell.textLabel.text = Localized(@"Pull up the screen to update the message list");
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        if (IsIOS7)
            cell.textLabel.textColor = UIColorFromHex(0x8e8e93);
        else
            cell.textLabel.textColor = UIColorFromHex(0x8892a5);
        return cell;
    }
    else {
        //HHT Change to detect Link
        NSDictionary *message = messages[indexPath.row];
        MessageType type = [self typeFromMessage:message];
        
        MessageCell *cell = [self dequeueReusableCellWithMessageType:type];
        
        cell.timeLabel.text = @"";
        cell.messageLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        cell.messageLabel.delegate = self;
        cell.messageLabel.text = message[@"Text"];
        cell.messageType = type;
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView_ viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView_.frame.size.width, 20)];
    
    label.text = [self tableView:tableView_ titleForHeaderInSection:section];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11.0];
    label.backgroundColor = UIColorFromHex(IsIOS7?0xdbe2ed:0xffffff);
    if (IsIOS7)
        label.textColor = UIColorFromHex(0x8e8e93);
    else {
        label.textColor = UIColorFromHex(0x8892a5);
        label.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:0.75];
        label.shadowOffset = CGSizeMake(0, 2);
    }
    
    return label;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *currentSection = sections[section];
    NSArray *items = currentSection[@"items"];
    NSDictionary *message = [items firstObject];
    NSDate *date = message[@"DsteTime"];
    
    return [NSString stringWithFormat:@"%@, %@", currentSection[@"day"], [date stringWithFormat:@"hh:mm"]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *section = sections[indexPath.section];
    NSArray *messages = section[@"items"];
    
    if ((indexPath.section == (sections.count - 1)) && indexPath.row == messages.count) {
        return 20.;
    }
    else {
        NSDictionary *message = messages[indexPath.row];
        MessageType type = [self typeFromMessage:message];
        MessageCell *cell = [self dequeueReusableCellWithMessageType:type];
        NSString *text = message[@"Text"];
        
        cell.messageLabel.text = text;
        
        /*CGSize containerSize = CGSizeZero;
         CGSize area = [text sizeWithFont:cell.messageLabel.font
         constrainedToSize:CGSizeMake(cell.messageLabel.frame.size.width,
         CGFLOAT_MAX)
         lineBreakMode:cell.messageLabel.lineBreakMode];
         if (area.width != cell.messageLabel.frame.size.width)
         area.width = cell.messageLabel.frame.size.width;
         area.width = fmaxf(area.width, cell.messageLabel.frame.size.width);
         UIEdgeInsets borders = viewInsetsInSuperview(cell.messageLabel);
         containerSize = CGSizeMake(area.width+borders.left+borders.right,area.height+borders.top+borders.bottom);
         */
        //float height = [self heightForLabel:cell.messageLabel withText:text];
        
        //HHT change for height of message lable
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:cell.messageLabel.font}];
        
        CGSize size = CGSizeMake(cell.messageLabel.frame.size.width, CGFLOAT_MAX);
        
        CGSize finalSize = [TTTAttributedLabel sizeThatFitsAttributedString:attributedText withConstraints:size limitedToNumberOfLines:0];
        
        if (finalSize.height < 40) {
            return 40;
        }
        
        return roundf(finalSize.height);
    }
}

-(CGFloat)heightForLabel:(UILabel *)label withText:(NSString *)text {
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:label.font}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){label.frame.size.width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    
    return ceil(rect.size.height);
}

#pragma mark - TTTAttributedLabel Delegate
//HHT to redirct on link click
- (void)attributedLabel:(__unused TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - MNMBottomPullToRefreshManagerClient
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [pullToRefreshManager tableViewScrolled];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [pullToRefreshManager tableViewReleased];
}

- (void)bottomPullToRefreshTriggered:(MNMBottomPullToRefreshManager *)manager {
    [self synchMessages:manager];
}

@end

