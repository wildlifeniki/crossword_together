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
#import "SimpleProfileCell.h"

@interface SelfProfileViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *recentsArray;
//@property (strong, nonatomic) NSMutableArray *recentsIDs;

@end

@implementation SelfProfileViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    
    NSMutableArray *recentsIDs;
    
    PFQuery *idQuery = [PFQuery queryWithClassName:@"ID"];
    NSArray *idObjects = [idQuery findObjects];
    if ([idObjects count] != 0) {
        self.currUserID = idObjects.firstObject[@"fbID"];
    }
    PFQuery *query = [PFQuery queryWithClassName:@"AppUser"];
    [query whereKey:@"fbID" equalTo:self.currUserID];
    NSArray *userObjects = [query findObjects];
    if ([userObjects count] != 0) {
        recentsIDs = userObjects.firstObject[@"recentlyPlayedWith"];
        self.selfProfileTitle.title = userObjects.firstObject[@"name"];
        self.totalGamesLabel.text = [NSString stringWithFormat:@"Total Games: %@", userObjects.firstObject[@"totalGames"]];
        self.bestTimeLabel.text = [NSString stringWithFormat:@"Best Time: %@s", userObjects.firstObject[@"bestTime"]];
        self.avgTimeLabel.text = [NSString stringWithFormat:@"Average Time: %@s", userObjects.firstObject[@"avgTime"]];

        
        //get profile picture
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
        initWithGraphPath:[NSString stringWithFormat:@"/%@?fields=picture.type(large)", self.currUserID]
            parameters:nil
            HTTPMethod:@"GET"];
        [request startWithCompletion:^(id<FBSDKGraphRequestConnecting>  _Nullable connection, id  _Nullable result, NSError * _Nullable error) {
            NSURL *url = [NSURL URLWithString:[[[(NSDictionary*) result objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"]];
            self.selfProfileImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        }];
        
    }
    
    [self getRecentlyPlayedWith: recentsIDs];
    
}

- (void)getRecentlyPlayedWith : (NSMutableArray *)recentsIDs {
    PFQuery *query = [PFQuery queryWithClassName:@"AppUser"];
    [query whereKey:@"fbID" containedIn: recentsIDs];

    NSArray *users = [query findObjects];
    self.recentsArray = [NSMutableArray arrayWithArray:users];

}



- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.recentsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SimpleProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recentCell" forIndexPath:indexPath];
    [cell setCellInfo:self.recentsArray[indexPath.row]];
    return cell;
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
