//
//  LoginViewController.m
//  meta_capstone
//
//  Created by Nikita Singh on 7/5/22.
//

#import "LoginViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "SelfProfileViewController.h"
#import "Parse/Parse.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize loginButtonView;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    loginButton.delegate = self;
    loginButton.center = loginButtonView.center;
    loginButton.permissions = @[@"public_profile", @"email"];
    [self.view addSubview:loginButton];
}

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    }
    
    if (result.isCancelled) {
        NSLog(@"User cancelled login");
    } else if (result.declinedPermissions.count > 0) {
        NSLog(@"User declined permissions");
    } else {
        
        dispatch_async(dispatch_get_main_queue(), ^{[FBSDKProfile loadCurrentProfileWithCompletion:^(FBSDKProfile *profile, NSError *error) {
            if (profile) {
                NSLog(@"profile exists");
                
                
                //check whether user exists in database
                PFQuery *query = [PFQuery queryWithClassName:@"AppUser"];
                [query whereKey:@"fbID" equalTo:profile.userID];
                NSArray *userObjects = [query findObjects];
                if ([userObjects count] == 0) {
                    //user doesnt exist, create user

                    PFObject *user = [PFObject objectWithClassName:@"AppUser"]; //this contains data for each user

                    NSLog(@"user doesn't exist yet, creating user");
                
                    user[@"fbID"] = [NSString stringWithFormat:@"%@", profile.userID];
                    user[@"name"] = [NSString stringWithFormat:@"%@ %@", profile.firstName, profile.lastName];
                    user[@"pfpURLString"] = [NSString stringWithFormat:@"%@", [profile imageURLForPictureMode:FBSDKProfilePictureModeSquare size:CGSizeMake(128, 128)]];
                    user[@"totalGames"] = @0;
                    user[@"bestTime"] = @0;
                    user[@"avgTime"] = @0;
                    user[@"recentlyPlayedWith"] = [NSMutableArray new];
                
                    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if (succeeded) { NSLog(@"user saved"); }
                        else { NSLog(@"user did not save"); }
                    }];
                
                    NSLog(@"%@", user);
                }
                
                //create one object to track current active user id (use this id to get info about current user)
                PFQuery *idQuery = [PFQuery queryWithClassName:@"ID"];
                NSArray *idObjects = [idQuery findObjects];
                if ([idObjects count] == 0) {
                    //set current active id
                    PFObject *currUserID = [PFObject objectWithClassName:@"ID"]; //this is how we know what information to show on selfProfile
                    currUserID[@"fbID"] = [NSString stringWithFormat:@"%@", profile.userID];
                    [currUserID saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if (succeeded) { NSLog(@"ID saved"); }
                        else { NSLog(@"ID did not save"); }
                    }];
                    
                }
                
            }
        }];
        });
        
        [self performSegueWithIdentifier:@"loginSegue" sender:nil];

    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    NSLog(@"User logged out");
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
