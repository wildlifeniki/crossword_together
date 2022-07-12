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
#import "Parse/Parse.h"

@interface SelfProfileViewController ()

@end

@implementation SelfProfileViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    
        
    PFQuery *idQuery = [PFQuery queryWithClassName:@"ID"];
    NSArray *idObjects = [idQuery findObjects];
    if ([idObjects count] != 0) {
        self.currUserID = idObjects.firstObject[@"fbID"];
        NSLog(@"%@", self.currUserID);
    }
    PFQuery *query = [PFQuery queryWithClassName:@"AppUser"];
    [query whereKey:@"fbID" equalTo:self.currUserID];
    NSArray *userObjects = [query findObjects];
    if ([userObjects count] != 0) {
        self.selfProfileTitle.title = userObjects.firstObject[@"name"];
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
        initWithGraphPath:[NSString stringWithFormat:@"/%@?fields=picture.type(large)", self.currUserID]
            parameters:nil
            HTTPMethod:@"GET"];
        [request startWithCompletion:^(id<FBSDKGraphRequestConnecting>  _Nullable connection, id  _Nullable result, NSError * _Nullable error) {
            NSURL *url = [NSURL URLWithString:[[[(NSDictionary*) result objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"]];
            self.selfProfileImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        }];
        
    }
    
}

- (IBAction)didTapLogout:(id)sender {
    NSLog(@"tapped logout");
    
    NSLog(@"logging out, %@", FBSDKAccessToken.currentAccessToken);
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logOut];
    
    
    NSLog(@"logged out, %@", FBSDKAccessToken.currentAccessToken);
    
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
