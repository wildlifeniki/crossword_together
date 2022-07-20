//
//  NewGameViewController.m
//  meta_capstone
//
//  Created by Nikita Singh on 7/15/22.
//

#import "NewGameViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKProfile.h>
#import "Parse/Parse.h"
#import "SearchUserCell.h"

@interface NewGameViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *usersArray;
@property (strong, nonatomic) NSMutableArray *filteredUsersArray;
@property (strong, nonatomic) NSMutableArray *inviteUsers;

@end

@implementation NewGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
    
    self.inviteUsers = [NSMutableArray arrayWithArray:@[]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removeUserNotification:)
                                                 name:@"removeUser"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addUserNotification:)
                                                 name:@"addUser"
                                               object:nil];
    
    [self getUsers];
}



- (void)getUsers {
    //get array of all users (except the person signed in)
    PFQuery *idQuery = [PFQuery queryWithClassName:@"ID"];
    PFQuery *query = [PFQuery queryWithClassName:@"AppUser"];
    [query whereKey:@"fbID" notEqualTo:[idQuery findObjects].firstObject[@"fbID"]];
    self.usersArray = [NSMutableArray arrayWithArray:[query findObjects]];
    self.filteredUsersArray = self.usersArray;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredUsersArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell" forIndexPath:indexPath];
    //instead of passing no, check whether user is contained in array and pass accordingly
    [cell setCellInfo:self.filteredUsersArray[indexPath.row] : indexPath];
    return cell;
}

- (void)updateParseInvites : (BOOL)clear {
    PFQuery *query = [PFQuery queryWithClassName:@"ID"];
    PFObject *info = [query findObjects].firstObject;
    if (clear)
        info[@"invitedArray"] = [NSMutableArray arrayWithArray:@[]];
    else
        info[@"invitedArray"] = self.inviteUsers;
    [info save];
}

- (void)removeUserNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    //[self.inviteUsers addObject:userInfo[@"cellUser"]];
    [self.inviteUsers removeObject:userInfo[@"cellUser"]];
    [self updateParseInvites : NO];
}

- (void)addUserNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if (self.inviteUsers.count <= 1) {
        [self.inviteUsers addObject:userInfo[@"cellUser"]];
    }
    else {
        //reset cell if unable to add
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Limit Reached"
                                       message:@"The maximum number of players alotted is 4"
                                       preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
           handler:^(UIAlertAction * action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
            
        }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        NSIndexPath *indexPath = userInfo[@"indexPath"];
        SearchUserCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell setCellInfo:userInfo[@"cellUser"] : indexPath];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:nil];
    }
    [self updateParseInvites : NO];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(nonnull NSString *)searchText {
    if (searchText.length != 0) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PFObject *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject[@"name"] containsString:searchText];
        }];
        self.filteredUsersArray = [NSMutableArray arrayWithArray:[self.usersArray filteredArrayUsingPredicate:predicate]];
    }
    else {
        self.filteredUsersArray = self.usersArray;
    }
    
    [self.tableView reloadData];
}

- (IBAction)didTapCancel:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self updateParseInvites : YES];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)didTapStartGame:(id)sender {
    PFObject *game = [PFObject objectWithClassName:@"Game"]; //this contains data for each user
    
    //find current user
    PFQuery *idQuery = [PFQuery queryWithClassName:@"ID"];
    PFQuery *query = [PFQuery queryWithClassName:@"AppUser"];
    [query whereKey:@"fbID" equalTo:[idQuery findObjects].firstObject[@"fbID"]];
    PFObject *currUser = [query findObjects].firstObject;

    //create game object with current user as active player, invite, and host
    NSString *currUserID = currUser[@"fbID"];
    game[@"activePlayerIDs"] = [NSMutableArray arrayWithArray:@[currUserID]];
    game[@"hostID"] = currUserID;
    game[@"inviteID"] = currUserID;
    game[@"percentComplete"] = @0;
    game[@"time"] = @0;
    
    [game save];
    
    //get game id
    PFQuery *gameQuery = [PFQuery queryWithClassName:@"Game"];
    [gameQuery orderByDescending:@"createdAt"];
    game = [gameQuery findObjects].firstObject;

    //add game id to active games list of current user
    [currUser addObject:game.objectId forKey:@"activeGames"];
    [currUser save];

    //add game id to pending invites list of invite users
    for (PFObject *user in self.inviteUsers) {
        [user addObject:game.objectId forKey:@"pendingInvites"];
        [user save];
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self updateParseInvites : YES];
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
