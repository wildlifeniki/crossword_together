//
//  LoginViewController.m
//  meta_capstone
//
//  Created by Nikita Singh on 7/5/22.
//

#import "LoginViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "GamesViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize loginButtonView;

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!FBSDKAccessToken.currentAccessToken.isExpired) {
        //not working
        
        UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
        
        
        NSLog(@"skip login screen");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        GamesViewController *gamesViewController = [storyboard instantiateViewControllerWithIdentifier:@"GamesViewController"];
        
        
        //[top performSegueWithIdentifier:@"loginSegue" sender:nil];

        //[top presentViewController:gamesViewController animated:NO completion:nil];
    }
    
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
    }
    else if (result.declinedPermissions.count > 0) {
        NSLog(@"User declined permissions");
    }
    else {
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
