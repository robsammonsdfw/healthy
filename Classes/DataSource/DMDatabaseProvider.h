//
//  DMDatabaseProvider.h
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/25/23.
//

#import <Foundation/Foundation.h>
#import "DMConstants.h"

@class DMMessage;
@class DMUser;

NS_ASSUME_NONNULL_BEGIN

/// Manages fetching data and saving to the local database.
@interface DMDatabaseProvider : NSObject

/// Performs a complete sync of the database with completion block since the
/// last time a sync was performend.
/// Fetches all sorts of data from the server. Foods, Meals, Exercies, etc.
- (void)syncDatabaseWithCompletionBlock:(completionBlockWithError)completionBlock;

- (void)syncFavoriteFoods:(NSString *)dateString withCompletionBlock:(completionBlockWithError)completionBlock;
- (void)syncFavoriteMealsWithCompletionBlock:(completionBlockWithError)completionBlock;
- (void)syncFavoriteMealItemsWithCompletionBlock:(completionBlockWithError)completionBlock;

/// Performs a sync of the exercise log, with date of last sync, current page number,
/// and fetched items if multiple pages. Pass 1 for page number and an empty array if
/// the first time.
- (void)syncExerciseLog:(NSString *)dateString
             pageNumber:(NSInteger)pageNumber
           fetchedItems:(NSArray *)fetchedItems
    withCompletionBlock:(completionBlockWithError)completionBlock;

- (NSArray<DMMessage *> *)unreadMessages;
- (int)unreadMessageCount;
- (void)setReadedMessageId:(NSNumber *)messageId;
- (NSDictionary *)messageById:(NSString *)uid;
/// Returns the most recent message Id stored in the database.
- (NSNumber *)getLastMessageId;
/// Syncronizes messages now.
- (void)syncMessagesWithCompletionBlock:(completionBlockWithError)completionBlock;

/// Gets the max value for the column provided in the table name.
/// Used to help get ID values since most tables aren't auto incremented.
- (NSNumber *)getMaxValueForColumn:(NSString *)columnName inTable:(NSString *)tableName;

@end

NS_ASSUME_NONNULL_END
