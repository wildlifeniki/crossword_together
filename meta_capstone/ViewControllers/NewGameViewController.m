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

@end

@implementation NewGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    
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
    [cell setCellInfo:self.filteredUsersArray[indexPath.row]];
    return cell;
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
    [self dismissViewControllerAnimated:true completion:nil];
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
