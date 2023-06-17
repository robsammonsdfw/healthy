//
//  MyMovesDetailsViewController.h
//  MyMoves
//
//  Created by Samson  on 14/01/19.
//

#import <UIKit/UIKit.h>
#import "MyMovesListViewController.h"

@interface MyMovesDetailsViewController : UIViewController
{
}
@property (nonatomic, strong) IBOutlet UIView *moveNameView;
@property (nonatomic, strong) IBOutlet UITextView *exerciseNotesTxtView;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic) NSDictionary * moveDetailDict;
@property (nonatomic) NSDictionary * moveListDict;
@property (nonatomic) NSMutableArray * moveSetListDict;
@property (nonatomic, strong) IBOutlet UILabel *exerciseNotesLbl;
@property (nonatomic, strong) IBOutlet UILabel *exerciseNameLbl;
@property (nonatomic) int workoutMethodID;
@property (nonatomic) int WorkoutMethodValueID;
@property (nonatomic, strong) NSDate * currentDate;
@property (nonatomic, strong) IBOutlet UIImageView *exchangeImgView;
@property (nonatomic, weak) id<loadDataToMovesTbl> passDataDel;
@property (nonatomic, strong) IBOutlet UIButton *exchangeBtnOutlet;
@property (nonatomic) NSString *parentUniqueID;
@property (nonatomic) NSString *deleteSetUniqueID;
@property (nonatomic) NSMutableArray *addMovesArray;
@property (nonatomic, strong) IBOutlet UILabel *noVideoMsgLbl;
@property (nonatomic, strong) IBOutlet UIButton *playVideoBtn;
@property (nonatomic, strong) IBOutlet UIImageView *playImg;
@property (nonatomic, strong) IBOutlet UIView *thumbNailView;

@end

@protocol exchangeDelegate <NSObject>
- (void)passDataOnExchange:(NSDictionary *)dict;
@end
