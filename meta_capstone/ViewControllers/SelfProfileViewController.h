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
@property (strong, nonatomic) NSString *currUserID;
@property (strong, nonatomic) User *selfUser;
//@property (strong, nonatomic) LoginViewController *login;

@end

NS_ASSUME_NONNULL_END
