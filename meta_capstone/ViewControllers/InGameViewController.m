//
//  InGameViewController.m
//  meta_capstone
//
//  Created by Nikita Singh on 7/19/22.
//

#import "InGameViewController.h"
#import "Tile.h"
#import "BoardTileCell.h"

@interface InGameViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) IBOutlet UILabel *clueLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *boardCollectionView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *checkButton;
@property (nonatomic, strong) NSDictionary *wordCluePairs;
@property (nonatomic, strong) NSMutableArray *tilesArray;
@property (assign, nonatomic) int xIndex;
@property (assign, nonatomic) int yIndex;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSTimer *updateTimer;
@property (strong, nonatomic) BoardTileCell *prevSelectedCell;
@property (strong, nonatomic) PFObject *emptyTile;

@end

@implementation InGameViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.boardCollectionView.delegate = self;
    self.boardCollectionView.dataSource = self;
    
    //initialize timer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
    [self.timer fire];
        
    //if no board already in database, create empty board
    if (self.game[@"tilesArray"] == nil) {
        //initialize dictionary
        self.wordCluePairs = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"this game, cross____", @"word",
                              @"this game, _____word", @"cross",
                              @"pink fish", @"salmon",
                              @"not old", @"new",
                              nil];
        
        //initalize indexes for collectionview
        self.xIndex = 0;
        self.yIndex = 0;
        
        //initialize tilesArray with all unfillable tiles
        self.emptyTile = [[[PFQuery queryWithClassName:@"Tile"] whereKey:@"fillable" equalTo:@NO] findObjects].firstObject; //init emptyTile object
        int size = 10; //to make square grid
        
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
        [self.game save];
        
        //create word tiles and add to array
        NSArray *words = [self.wordCluePairs allKeys];
        [self createTiles:[words objectAtIndex:0] :3 :1 :NO]; //word
        [self createTiles:[words objectAtIndex:2] :1 :2 :YES]; //cross
        [self createTiles:[words objectAtIndex:1] :5 :2 :NO]; //salmon
        [self createTiles:[words objectAtIndex:3] :5 :7 :YES]; //new
    }
    
    //if user is not the host, remove check button
    if ([self.game[@"hostID"] isEqualToString:self.currUser[@"fbID"]]) {
        self.navigationItem.rightBarButtonItem = self.checkButton;
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(checkUpdate) userInfo:nil repeats:YES];
    }
}

-(void)timerFired {
    [self.game incrementKey:@"time"];
    [self.game save];
    
    int seconds = [self.game[@"time"] intValue];
    //calculate minutes and seconds
    int displayMin = seconds/60;
    int displaySec = seconds%60;
    NSString *displayTime = [NSString stringWithFormat:@"%02d:%02d", displayMin, displaySec];
    self.navigationItem.title = displayTime;
}

-(void)checkUpdate {
    self.game = [[PFQuery queryWithClassName:@"Game"] getObjectWithId:self.game.objectId];
    if ([self.game[@"updated"] boolValue]) {
        self.game[@"updated"] = @NO;
        [self.boardCollectionView reloadData];
    }
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
            tile[@"inputLetter"] = @" ";
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

- (PFObject *) getTileAtIndex : (int) xIndex : (int) yIndex {
    NSMutableArray *innerArray = [self.game[@"tilesArray"] objectAtIndex:yIndex];
    NSString *tileID = [innerArray objectAtIndex:xIndex];
    return [[PFQuery queryWithClassName:@"Tile"] getObjectWithId:tileID];
}

- (void) setTileAtIndex : (PFObject *) tile : (int) xIndex : (int) yIndex {
    NSMutableArray *tilesArray = self.game[@"tilesArray"];
    NSMutableArray *innerArray = [tilesArray objectAtIndex:yIndex];
    [innerArray replaceObjectAtIndex:xIndex withObject:tile.objectId];
    [tilesArray replaceObjectAtIndex:yIndex withObject:innerArray];
    self.game[@"tilesArray"] = tilesArray;
    [self.game save];
}

//for help with testing, can be removed once ui is able to show board
- (void)printSquareArray : (NSMutableArray *)array {
    NSString *print = @"current board: \n";
    for (NSMutableArray *row in array) {
        for (Tile *tile in row) {
            if (tile.fillable)
                print = [print stringByAppendingString:tile.inputLetter];
            else
                print = [print stringByAppendingString:@"-"];
        }
        print = [print stringByAppendingString:@"\n"];
    }
    NSLog(@"%@", print);
}

//initialize board ui
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    self.xIndex = (int)([indexPath item] % 10);
    self.yIndex = (int)([indexPath item] / 10);
    
    BoardTileCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"tile" forIndexPath:indexPath];
    PFObject *tile = [self getTileAtIndex:self.xIndex :self.yIndex];
    cell.game = self.game;
    cell.user = self.currUser;
    cell.tile = tile;
    
    if ([cell.tile[@"fillable"] boolValue]) {
        [cell.contentView.layer setBorderColor:[UIColor blackColor].CGColor];
        [cell.contentView.layer setBorderWidth:1.0f];
        cell.inputView.userInteractionEnabled = NO;
        cell.inputView.backgroundColor = [UIColor whiteColor];
        cell.inputView.text = cell.tile[@"inputLetter"];
    }
    else {
        cell.inputView.text = @"";
        cell.inputView.backgroundColor = [UIColor clearColor];
        [cell.contentView.layer setBorderWidth:0.0f];
        [cell.contentView setBackgroundColor:[UIColor clearColor]];
    }
    
    return cell;
}

//what to do if cell is selected
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    BoardTileCell *cell = (BoardTileCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.inputView.delegate = cell;
    cell.inputView.backgroundColor = [UIColor systemGray5Color];

    if ([self.game[@"hostID"] isEqualToString:self.currUser[@"fbID"]]) {
        [cell.inputView becomeFirstResponder];
        cell.inputView.userInteractionEnabled = YES;
    }
    else {
        if (cell != self.prevSelectedCell)
            self.prevSelectedCell.inputView.backgroundColor = [UIColor whiteColor];
        self.prevSelectedCell = cell;
    }
    
    NSString *acrossClue = cell.tile[@"acrossClue"];
    NSString *downClue = cell.tile[@"downClue"];
    
    NSString *clues = @"";
    if (acrossClue != nil)
        clues = [clues stringByAppendingString:[NSString stringWithFormat:@"Across: %@", acrossClue]];
    if (acrossClue != nil && downClue != nil)
        clues = [clues stringByAppendingString:@"\n"];
    if (downClue != nil)
        clues = [clues stringByAppendingString:[NSString stringWithFormat:@"Down: %@", downClue]];
    self.clueLabel.text = clues;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    int numRows = (int) [self.game[@"tilesArray"] count];
    return numRows * numRows;
}

- (IBAction)didTapCheck:(id)sender {
    BOOL correct = YES;
    
    //check if all tiles have correct input
    for (NSMutableArray *row in self.game[@"tilesArray"]) {
        for (NSString *tileID in row) {
            PFObject *tile = [[PFQuery queryWithClassName:@"Tile"] getObjectWithId:tileID];
            if ([tile[@"fillable"] boolValue]) {
                if (![tile[@"correctLetter"] isEqualToString:tile[@"inputLetter"]]) {
                    correct = NO;
                }
            }
        }
    }
    
    //if correct, make alert saying everything is correct (ok closes alert and controller)
    if (correct) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Complete!"
                                       message:@"Congratulations, you have finished this board."
                                       preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Finish Game" style:UIAlertActionStyleDefault
           handler:^(UIAlertAction * action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
            [self dismissViewControllerAnimated:true completion:nil];
        }];
        [self.timer invalidate];
        [self.updateTimer invalidate];
        [self updatePlayerData];
        [self removeGameData];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    //if not correct, make alert saying everything is not correct yet (ok just closes alert)
    else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Not Quite..."
                                       message:@"The board is not yet correct."
                                       preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Back to Game" style:UIAlertActionStyleDefault
           handler:^(UIAlertAction * action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)didTapClose:(id)sender {
    [self.timer invalidate];
    [self.updateTimer invalidate];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)updatePlayerData {
    //get array of players in game
    NSArray *playerIDs = self.game[@"activePlayerIDs"];
    PFQuery *usersQuery = [PFQuery queryWithClassName:@"AppUser"];
    [usersQuery whereKey:@"fbID" containedIn:playerIDs];
    NSArray *players = [usersQuery findObjects];
    
    //get final time
    int seconds = [self.game[@"time"] intValue];
    
    //update all players
    for (PFObject *player in players) {
        int prevTotalGames = [player[@"totalGames"] intValue];
        if (prevTotalGames == 0) {
            //edge case for new player
            player[@"avgTime"] = [NSNumber numberWithInt:seconds];
            player[@"bestTime"] = [NSNumber numberWithInt:seconds];
        }
        else {
            //update best time
            int prevBest = [player[@"bestTime"] intValue];
            if (seconds < prevBest)
                player[@"bestTime"] = [NSNumber numberWithInt:seconds];
            
            //update avg time
            int prevAvg = [player[@"avgTime"] intValue];
            int avgTime = ((prevAvg * prevTotalGames) + seconds) / (prevTotalGames + 1);

            player[@"avgTime"] = [NSNumber numberWithInt:avgTime];
        }
        
        //update total games
        [player incrementKey:@"totalGames"];

        //update recently played with ids
        NSMutableArray *recentIDs = player[@"recentlyPlayedWith"];
        NSMutableArray *newRecentIDs = [NSMutableArray arrayWithArray:@[]];
        for (NSString *playerID in playerIDs) {
            //remove any duplicate ids that will be added
            [recentIDs removeObject:playerID];
            //don't add player to own recently played
            if (![playerID isEqualToString:player[@"fbID"]])
                [newRecentIDs addObject:playerID];
        }
        player[@"recentlyPlayedWith"] = [newRecentIDs arrayByAddingObjectsFromArray:recentIDs];
        
//        [player save]; //comment if testing without updating backend
    }
}

- (void)removeGameData {
    //remove game id from all active games and pending invites
    NSString *gameID = self.game.objectId;
    PFQuery *usersQuery = [PFQuery queryWithClassName:@"AppUser"];
    NSArray *allUsers = [usersQuery findObjects];
    for (PFObject *user in allUsers) {
        NSMutableArray *activeGames = user[@"activeGames"];
        NSMutableArray *pendingInvites = user[@"pendingInvites"];
        [activeGames removeObject:gameID];
        [pendingInvites removeObject:gameID];
        if (activeGames != nil)
            user[@"activeGames"] = activeGames;
        if (pendingInvites != nil)
            user[@"pendingInvites"] = pendingInvites;
//        [user save]; //comment if testing without updating backend
    }
    //remove game object
//    [self.game delete]; //comment if testing without updating backend
}

@end
