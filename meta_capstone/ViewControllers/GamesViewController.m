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
@property (strong, nonatomic) IBOutlet UITableView *invitesTableView;

@property (strong, nonatomic) NSMutableArray *gamesArray;
@property (strong, nonatomic) NSMutableArray *invitesArray;

@property (strong, nonatomic) UIRefreshControl *gameRefreshControl;
@property (strong, nonatomic) UIRefreshControl *inviteRefreshControl;


@end

@implementation GamesViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.gamesTableView.dataSource = self;
    self.invitesTableView.dataSource = self;

    [self getActiveGames];
    [self getPendingInvites];
    
    self.gameRefreshControl = [[UIRefreshControl alloc] init];
    [self.gameRefreshControl addTarget:self action:@selector(getActiveGames) forControlEvents:UIControlEventValueChanged];
    [self.gamesTableView insertSubview:self.gameRefreshControl atIndex:0];
    [self.gamesTableView addSubview:self.gameRefreshControl];
    
    self.inviteRefreshControl = [[UIRefreshControl alloc] init];
    [self.inviteRefreshControl addTarget:self action:@selector(getPendingInvites) forControlEvents:UIControlEventValueChanged];
    [self.invitesTableView insertSubview:self.inviteRefreshControl atIndex:0];
    [self.invitesTableView addSubview:self.inviteRefreshControl];
}

- (void)viewDidAppear:(BOOL)animated{
    NSLog(@"games screen appeared");
    if ([self.presentedViewController isBeingDismissed])
        NSLog(@"new games view dismissed");
}

- (void)getRespectiveTable: (NSMutableArray *)IDArray : (BOOL) isGame {
    PFQuery *query = [PFQuery queryWithClassName:@"Game"];
    [query whereKey:@"objectId" containedIn:IDArray];
    [query orderByDescending:@"updatedAt"];
    
    if (isGame)
        self.gamesArray = [NSMutableArray arrayWithArray:[query findObjects]];
    else
        self.invitesArray = [NSMutableArray arrayWithArray:[query findObjects]];
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

    [self getRespectiveTable:gameIDs :YES];
    
    [self.gamesTableView reloadData];
    [self.gameRefreshControl endRefreshing];
}

- (void)getPendingInvites {
    NSMutableArray *inviteGameIDs;
    PFQuery *idQuery = [PFQuery queryWithClassName:@"ID"];
    NSArray *idObjects = [idQuery findObjects];
    if ([idObjects count] != 0) {
        PFQuery *query = [PFQuery queryWithClassName:@"AppUser"];
        [query whereKey:@"fbID" equalTo:idObjects.firstObject[@"fbID"]];
        inviteGameIDs = [NSMutableArray arrayWithArray:[query findObjects].firstObject[@"pendingInvites"]];
    }

    [self getRespectiveTable:inviteGameIDs :NO];
    
    [self.invitesTableView reloadData];
    [self.inviteRefreshControl endRefreshing];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView.restorationIdentifier isEqualToString:@"gameTable"]) {
        return self.gamesArray.count;
    }
    if ([tableView.restorationIdentifier isEqualToString:@"inviteTable"]) {
        return self.invitesArray.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView.restorationIdentifier isEqualToString:@"gameTable"]) {
        ActiveGameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"gameCell" forIndexPath:indexPath];
        [cell setCellInfo:self.gamesArray[indexPath.row]];
        return cell;
    }
    if ([tableView.restorationIdentifier isEqualToString:@"inviteTable"]) {
        PendingInviteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"inviteCell" forIndexPath:indexPath];
        [cell setCellInfo:self.invitesArray[indexPath.row]];
        return cell;
    }
    else {
        NSLog(@"neither cell");
        ActiveGameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"gameCell" forIndexPath:indexPath];
        [cell setCellInfo:self.gamesArray[indexPath.row]];
        return cell;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

@end
