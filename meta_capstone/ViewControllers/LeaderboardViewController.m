//
//  LeaderboardViewController.m
//  meta_capstone
//
//  Created by Nikita Singh on 7/5/22.
//

#import "LeaderboardViewController.h"
#import "LeaderboardCell.h"
#import "Parse/Parse.h"

@interface LeaderboardViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation LeaderboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.dataSource = self;
    [self getLeaderboard];
}

- (void)getLeaderboard {
    PFQuery *query = [PFQuery queryWithClassName:@"AppUser"];
    [query whereKey:@"totalGames" notEqualTo:@0];
    [query orderByAscending:@"avgTime"];
    
    NSArray *users = [query findObjects];
    self.usersArray = [NSMutableArray arrayWithArray:users];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.usersArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LeaderboardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [cell setCellInfo:self.usersArray[indexPath.row] : indexPath.row + 1];
    return cell;
}

@end
