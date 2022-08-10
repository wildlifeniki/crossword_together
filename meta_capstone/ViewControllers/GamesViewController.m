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
#import "InGameViewController.h"
#import "SWTableViewCell/SWTableViewCell.h"

@interface GamesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *gamesTableView;
@property (strong, nonatomic) IBOutlet UITableView *invitesTableView;

@property (strong, nonatomic) NSMutableArray *gamesArray;
@property (strong, nonatomic) NSMutableArray *invitesArray;

@property (strong, nonatomic) UIRefreshControl *gameRefreshControl;
@property (strong, nonatomic) UIRefreshControl *inviteRefreshControl;

@property (strong, nonatomic) PFObject *currUser;

@end

@implementation GamesViewController

- (void)viewDidAppear:(BOOL)animated {
    [self getActiveGames];
    [self getPendingInvites];
}

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

- (void)getRespectiveTable: (NSMutableArray *)IDArray : (BOOL) isGame {
    PFQuery *query = [PFQuery queryWithClassName:@"Game"];
    [query whereKey:@"objectId" containedIn:IDArray];
    [query orderByDescending:@"updatedAt"];
    
    if (isGame)
        self.gamesArray = [NSMutableArray arrayWithArray:[query findObjects]];
    else
        self.invitesArray = [NSMutableArray arrayWithArray:[query findObjects]];
}

- (void) updateCurrentUser {
    PFQuery *idQuery = [PFQuery queryWithClassName:@"AppInfo"];
    [idQuery fromLocalDatastore];
    NSArray *idObjects = [idQuery findObjects];
    PFQuery *query = [PFQuery queryWithClassName:@"AppUser"];
    [query whereKey:@"fbID" equalTo:idObjects.firstObject[@"fbID"]];
    self.currUser = [query findObjects].firstObject;
}

- (void)getActiveGames {
    [self updateCurrentUser];
    NSMutableArray *gameIDs = [NSMutableArray arrayWithArray:self.currUser[@"activeGames"]];
    [self getRespectiveTable:gameIDs :YES];
    [self.gamesTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self.gameRefreshControl endRefreshing];
}

- (void)getPendingInvites {
    [self updateCurrentUser];
    NSMutableArray *inviteGameIDs = [NSMutableArray arrayWithArray:self.currUser[@"pendingInvites"]];
    [self getRespectiveTable:inviteGameIDs :NO];
    [self.invitesTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
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
        
        cell.viewController = self;
        cell.rightUtilityButtons = [self rightButtons];
        cell.delegate = self;
        return cell;
    }
    else {
        ActiveGameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"gameCell" forIndexPath:indexPath];
        [cell setCellInfo:self.gamesArray[indexPath.row]];
        return cell;
    }
}

- (void)swipeableTableViewCell:(PendingInviteCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    [cell deleteInvite];
}

- (NSArray *)rightButtons {
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Delete"];
    return rightUtilityButtons;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"openGame"]){
        UINavigationController *navigationController = [segue destinationViewController];
        InGameViewController *viewController = (InGameViewController*)navigationController.topViewController;
        ActiveGameCell *cell = [self.gamesTableView cellForRowAtIndexPath:self.gamesTableView.indexPathForSelectedRow];
        viewController.game = cell.game;
        viewController.currUser =  self.currUser;
    }
}

@end
