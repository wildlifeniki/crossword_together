//
//  SelfProfileViewController.m
//  meta_capstone
//
//  Created by Nikita Singh on 7/5/22.
//

#import "SelfProfileViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKProfile.h>
#import "SceneDelegate.h"
#import "AppDelegate.h"
#import "LoginViewController.h"

@interface SelfProfileViewController ()

@end

@implementation SelfProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    dispatch_async(dispatch_get_main_queue(), ^{[FBSDKProfile loadCurrentProfileWithCompletion:^(FBSDKProfile *profile, NSError *error) {
        if (profile) {
            self.selfProfileTitle.title = [NSString stringWithFormat:@"%@ %@", profile.firstName, profile.lastName];
            NSURL *pfpURL = [profile imageURLForPictureMode:FBSDKProfilePictureModeSquare size:CGSizeMake(128, 128)];
            self.selfProfileImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:pfpURL]];
        }
    }];
        
    });
}
- (IBAction)didTapLogout:(id)sender {
    NSLog(@"tapped logout");
    
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logOut];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self presentViewController:loginViewController animated:YES completion:nil];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
