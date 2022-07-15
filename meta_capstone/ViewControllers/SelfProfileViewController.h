//
//  SelfProfileViewController.h
//  meta_capstone
//
//  Created by Nikita Singh on 7/5/22.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"


NS_ASSUME_NONNULL_BEGIN

@interface SelfProfileViewController : UIViewController 

@property (strong, nonatomic) IBOutlet UINavigationItem *selfProfileTitle;
@property (strong, nonatomic) IBOutlet UIImageView *selfProfileImage;
@property (strong, nonatomic) IBOutlet UILabel *totalGamesLabel;
@property (strong, nonatomic) IBOutlet UILabel *bestTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *avgTimeLabel;

@property (strong, nonatomic) NSString *currUserID;

@end

NS_ASSUME_NONNULL_END
