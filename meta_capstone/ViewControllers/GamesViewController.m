//
//  GamesViewController.m
//  meta_capstone
//
//  Created by Nikita Singh on 7/5/22.
//

#import "GamesViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKProfile.h>
#import "SceneDelegate.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "Parse/Parse.h"
#import "ActiveGameCell.h"
#import "PendingInviteCell.h"

@interface GamesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *gamesTableView;
//@property (strong, nonatomic) IBOutlet UITableView *invitesTableView;
@property (strong, nonatomic) NSMutableArray *gamesArray;
//@property (strong, nonatomic) NSMutableArray *invitesArray;


@end

@implementation GamesViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.gamesTableView.dataSource = self;
    [self getActiveGames];
}

- (void)getActiveGames {
    NSMutableArray *gameIDs;
    PFQuery *idQuery = [PFQuery queryWithClassName:@"ID"];
    NSArray *idObjects = [idQuery findObjects];
    if ([idObjects count] != 0) {
        PFQuery *query = [PFQuery queryWithClassName:@"AppUser"];
        [query whereKey:@"fbID" equalTo:idObjects.firstObject[@"fbID"]];
        gameIDs = [NSMutableArray arrayWithArray:[query findObjects].firstObject[@"activeGames"]];
    }
    NSLog(@"ids: %@", gameIDs);

    PFQuery *gameQuery = [PFQuery queryWithClassName:@"Game"];
    [gameQuery whereKey:@"objectId" containedIn:gameIDs];
    self.gamesArray = [NSMutableArray arrayWithArray:[gameQuery findObjects]];
    NSLog(@"game objects: %@", self.gamesArray);

}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.gamesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ActiveGameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"gameCell" forIndexPath:indexPath];
    [cell setCellInfo:self.gamesArray[indexPath.row]];
    return cell;
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
