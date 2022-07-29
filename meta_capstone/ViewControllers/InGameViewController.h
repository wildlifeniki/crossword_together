//
//  InGameViewController.h
//  meta_capstone
//
//  Created by Nikita Singh on 7/19/22.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface InGameViewController : UIViewController

@property (nonatomic, strong) PFObject *game;
@property (nonatomic, strong) PFObject *currUser;

- (void) createBoard: (NSArray *)words;

@end

NS_ASSUME_NONNULL_END
