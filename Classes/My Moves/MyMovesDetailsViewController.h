//
//  MyMovesDetailsViewController.h
//  MyMoves
//
//  Created by Samson  on 14/01/19.
//

#import <UIKit/UIKit.h>
@class DMMoveRoutine;

/// Displays the details of a routine to the user and lets them
/// update the number of sets and reps, etc. that they do.
@interface MyMovesDetailsViewController : UIViewController
@property (nonatomic, strong) NSDate *selectedDate;

/// Routine that the user is viewing the details for.
@property (nonatomic, strong) DMMoveRoutine *routine;
@end
