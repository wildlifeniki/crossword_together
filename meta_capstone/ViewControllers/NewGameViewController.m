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
    
    //initialize dictionary
    self.wordCluePairs = [[NSMutableDictionary alloc] init];
    NSArray *wordClueObjects = [[PFQuery queryWithClassName:@"WordClue"] findObjects];
    for (PFObject *pair in wordClueObjects) {
        [self.wordCluePairs setObject:pair[@"clue"] forKey:pair[@"word"]];
    }
}



- (void)getUsers {
    //get array of all users (except the person signed in)
    PFQuery *idQuery = [PFQuery queryWithClassName:@"AppInfo"];
    [idQuery fromLocalDatastore];
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
    PFQuery *query = [PFQuery queryWithClassName:@"AppInfo"];
    [query fromLocalDatastore];
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
    if (self.inviteUsers.count <= 3) {
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
    self.game = [PFObject objectWithClassName:@"Game"]; //this contains data for each user
    
    //find current user
    PFQuery *idQuery = [PFQuery queryWithClassName:@"AppInfo"];
    [idQuery fromLocalDatastore];
    PFQuery *query = [PFQuery queryWithClassName:@"AppUser"];
    [query whereKey:@"fbID" equalTo:[idQuery findObjects].firstObject[@"fbID"]];
    PFObject *currUser = [query findObjects].firstObject;

    //create game object with current user as active player, invite, and host
    NSString *currUserID = currUser[@"fbID"];
    self.game[@"activePlayerIDs"] = [NSMutableArray arrayWithArray:@[currUserID]];
    self.game[@"hostID"] = currUserID;
    self.game[@"inviteID"] = currUserID;
    self.game[@"percentComplete"] = @0;
    self.game[@"time"] = @0;
    
    [self.game save];
    
    [self setGameTilesArray];

    //add game id to active games list of current user
    [currUser addObject:self.game.objectId forKey:@"activeGames"];
    [currUser save];

    //add game id to pending invites list of invite users
    for (PFObject *user in self.inviteUsers) {
        [user addObject:self.game.objectId forKey:@"pendingInvites"];
        [user save];
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self updateParseInvites : YES];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void) setGameTilesArray {
    //initialize tilesArray with all unfillable tiles
    int size = 10; //to make square grid
    
    self.emptyTile = [[[PFQuery queryWithClassName:@"Tile"] whereKey:@"fillable" equalTo:@NO] findObjects].firstObject;
    
    //fill inner array
    NSMutableArray *innerArray = [[NSMutableArray alloc] initWithCapacity: size];
    for (int j = 0; j < size; j++) {
        [innerArray insertObject:self.emptyTile.objectId atIndex:j];
    }
    
    //add inner array to tilesArray
    NSMutableArray *tilesArray = [[NSMutableArray alloc] initWithCapacity: size];
    for (int i = 0; i < size; i++) {
        [tilesArray insertObject:[NSMutableArray arrayWithArray:innerArray] atIndex:i];
    }
    self.game[@"tilesArray"] = tilesArray;
    self.game[@"waiting"] = @NO;
    [self.game removeObjectForKey:@"requestingHost"];
    [self.game removeObjectForKey:@"requestedBy"];
    [self.game save];
    
    //create word tiles and add to array
    NSArray *words = [self.wordCluePairs allKeys];
    [self createBoard:words];
}

- (void) createBoard: (NSArray *)words {
    //remove word once added
    self.usableWords = [NSMutableArray arrayWithArray:words];
    
    //pick random word to go across top
    NSUInteger randomIndex = arc4random() % self.usableWords.count;
    NSString *firstWord = [words objectAtIndex:randomIndex];
    [self.usableWords removeObject:firstWord];
    [self createTiles:firstWord :0 :0 :YES];
    
    NSUInteger secondStart = arc4random() % firstWord.length; //(secondStart, 0)
    NSString *secondWord = [self setUpWord:secondStart :-1 :NO :firstWord :0 :0];

    NSUInteger thirdStart = (arc4random() % (secondWord.length - 2) + 2); //(??, thirdStartY)
    NSString *thirdWord = [self setUpWord:-1 :thirdStart :YES :secondWord :secondStart :0];
}

-(NSString *) setUpWord : (NSUInteger)xStart : (NSUInteger)yStart : (BOOL)across : (NSString *)prevWord : (NSUInteger)xPrevStart : (NSUInteger)yPrevStart {
    NSString *crossLetter;
    if (across) { crossLetter = [prevWord substringWithRange:NSMakeRange(yStart, 1)]; }
    else { crossLetter = [prevWord substringWithRange:NSMakeRange(xStart, 1)]; }
    NSUInteger crossIndex;
    if (across) { crossIndex = xPrevStart; }
    else { crossIndex = yPrevStart; }
    NSDictionary *availableWordStartPairs = [self arrayOfValidStringsWithLetterAtIndex:self.usableWords :crossLetter :crossIndex];
    NSArray *availableWords = [availableWordStartPairs allKeys];
    //pick random word to go across from letter
    NSString *newWord = [availableWords objectAtIndex:(arc4random() % availableWords.count)];
    NSArray *availableStarts = [availableWordStartPairs objectForKey:newWord];
    [self.usableWords removeObject:newWord];
    if (across) { [self createTiles:newWord :[[availableStarts objectAtIndex:arc4random() % availableStarts.count] intValue]:(int)yStart :YES]; }
    else { [self createTiles:newWord :(int)xStart :[[availableStarts objectAtIndex:arc4random() % availableStarts.count] intValue]: NO]; }
    return newWord;
}

- (NSDictionary *)arrayOfValidStringsWithLetterAtIndex : (NSArray *)words : (NSString *)letter : (NSUInteger)index {
    NSMutableDictionary *validWords = [NSMutableDictionary dictionary];
    for (NSString *word in words) {
        NSMutableArray *validStart = [NSMutableArray arrayWithArray:@[]];
        NSString *padding = [@"" stringByPaddingToLength:10 - word.length withString:@"0" startingAtIndex:0];
        for (int i = 0; i <= padding.length; i++) {
            NSString *front = [padding substringToIndex:i];
            NSString *back = [padding substringFromIndex:i];
            NSString *testWord = [NSString stringWithFormat:@"%@%@%@", front, word, back];
            if ([[testWord substringWithRange:NSMakeRange(index, 1)] isEqualToString:letter]) {
                [validStart addObject:[NSNumber numberWithInt:(int) (front.length)]];
            }
        }
        if (validStart.count != 0) {
            [validWords setObject:validStart forKey:word];
        }
    }
    return validWords;
}

- (void) createTiles: (NSString *)word : (int) xIndex : (int) yIndex : (BOOL) across {
    NSMutableArray *wordLetters = [NSMutableArray arrayWithArray:@[]];
    
    //split word string into substrings of 1 capital letter
    NSString *capitalWord = [word uppercaseString];
    for (int i = 0; i < capitalWord.length; i++) {
        NSString *letter = [capitalWord substringWithRange:(NSMakeRange(i, 1))];
        [wordLetters addObject:letter];
    }
    
    //create tiles for each letter and put them in correct spot in the array
    for (NSString *letter in wordLetters) {
        //check if fillable tile already in spot, if so, just edit that tile
        PFObject *checkTile = [self getTileAtIndex:xIndex :yIndex];
        PFObject *tile = [PFObject objectWithClassName:@"Tile"];
        if (![checkTile[@"fillable"] boolValue]) {
            tile[@"fillable"] = @YES;
            tile[@"xIndex"] = [NSNumber numberWithInt:xIndex];
            tile[@"yIndex"] = [NSNumber numberWithInt:yIndex];
            tile[@"correctLetter"] = letter;
            tile[@"inputLetter"] = @"";
            tile[@"gameID"] = self.game.objectId;
        }
        else
            tile = checkTile;
        if (across) { tile[@"acrossClue"] = [self.wordCluePairs valueForKey:word]; }
        else { tile[@"downClue"] = [self.wordCluePairs valueForKey:word]; }
        [tile save];

        [self setTileAtIndex:tile :[tile[@"xIndex"] intValue]  :[tile[@"yIndex"] intValue]];
        if (across) { xIndex++; }
        else { yIndex++; }
    }
}

@end
