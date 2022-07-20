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
        NSLog(@"user accepted permissions");
        dispatch_async(dispatch_get_main_queue(), ^{[FBSDKProfile loadCurrentProfileWithCompletion:^(FBSDKProfile *profile, NSError *error) {
            if (profile) {
                NSLog(@"%@", profile.name);
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
                    user[@"totalGames"] = @0;
                    user[@"bestTime"] = @0;
                    user[@"avgTime"] = [NSNumber numberWithInt:arc4random_uniform(100)];
                    user[@"recentlyPlayedWith"] = [NSMutableArray new];
                
                    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if (succeeded) { NSLog(@"user saved"); }
                        else { NSLog(@"user did not save"); }
                    }];
                                }
                
                //create one object to track current active user id (use this id to get info about current user)
                PFQuery *idQuery = [PFQuery queryWithClassName:@"ID"];
                NSArray *idObjects = [idQuery findObjects];
                PFObject *currUserID;
                if ([idObjects count] == 0) {
                    //set current active id
                    currUserID = [PFObject objectWithClassName:@"ID"]; //this is how we know what information to show on selfProfile
                }
                else {
                    currUserID = idObjects.firstObject;
                }
                
                currUserID[@"fbID"] = [NSString stringWithFormat:@"%@", profile.userID];
                [currUserID saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded) { NSLog(@"ID saved"); }
                    else { NSLog(@"ID did not save"); }
                }];
                
            }
        }];
        });
        
        [self performSegueWithIdentifier:@"loginSegue" sender:nil];

    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    NSLog(@"User logged out");
}


@end
