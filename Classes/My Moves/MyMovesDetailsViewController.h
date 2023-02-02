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
@property (retain, nonatomic) IBOutlet UIView *moveNameView;
@property (retain, nonatomic) IBOutlet UITextView *exerciseNotesTxtView;
@property (retain, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, assign) NSDictionary * moveDetailDict;
@property (nonatomic, assign) NSDictionary * moveListDict;
@property (nonatomic, assign) NSMutableArray * moveSetListDict;
@property (retain, nonatomic) IBOutlet UILabel *exerciseNotesLbl;
@property (retain, nonatomic) IBOutlet UILabel *exerciseNameLbl;
@property (nonatomic, assign) int workoutMethodID;
@property (nonatomic, assign) int WorkoutMethodValueID;
@property (strong, retain) NSDate * currentDate;
@property (retain, nonatomic) IBOutlet UIImageView *exchangeImgView;
@property(nonatomic,assign) id<loadDataToMovesTbl> passDataDel;
@property (retain, nonatomic) IBOutlet UIButton *exchangeBtnOutlet;
@property (nonatomic, assign) NSString *parentUniqueID;
@property (nonatomic, assign) NSString *deleteSetUniqueID;
@property (nonatomic, assign) NSMutableArray *addMovesArray;
@property (retain, nonatomic) IBOutlet UILabel *noVideoMsgLbl;
@property (retain, nonatomic) IBOutlet UIButton *playVideoBtn;
@property (retain, nonatomic) IBOutlet UIImageView *playImg;
@property (retain, nonatomic) IBOutlet UIView *thumbNailView;


//@property (strong, nonatomic) NSMutableArray *moveSetListArr;

@end

@protocol exchangeDelegate <NSObject>
- (void)passDataOnExchange:(NSDictionary *)dict;
@end
