//
//  InGameViewController.h
//  meta_capstone
//
//  Created by Nikita Singh on 7/19/22.
//

#import <UIKit/UIKit.h>
#import "UIViewController+TileMethods.h"

NS_ASSUME_NONNULL_BEGIN

@interface InGameViewController : UIViewController_TileMethods

@property (nonatomic, strong) PFObject *currUser;

@end

NS_ASSUME_NONNULL_END
