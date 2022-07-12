//
//  LoginViewController.h
//  meta_capstone
//
//  Created by Nikita Singh on 7/5/22.
//

#import <UIKit/UIKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface LoginViewController : UIViewController <FBSDKLoginButtonDelegate>

@property (strong, nonatomic) IBOutlet UIView *loginButtonView;

@end

NS_ASSUME_NONNULL_END
