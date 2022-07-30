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
@property (strong, nonatomic) IBOutlet UIBarButtonItem *requestHostButton;
@property (nonatomic, strong) NSDictionary *wordCluePairs;
@property (nonatomic, strong) NSMutableArray *tilesArray;
@property (assign, nonatomic) int xIndex;
@property (assign, nonatomic) int yIndex;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSTimer *updateTimer;
@property (strong, nonatomic) NSTimer *hostTimer;
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
                              @"apple",@"apple",
                              @"banana",@"banana",
                              @"carrot",@"carrot",
                              @"dinosaur",@"dinosaur",
                              @"enigma",@"enigma",
                              @"fishy",@"fishy",
                              @"gorilla",@"gorilla",
                              @"hippo",@"hippo",
                              @"iguana",@"iguana",
                              @"jaguar",@"jaguar",
                              @"king",@"king",
                              @"lame",@"lame",
                              @"mirage",@"mirage",
                              @"nicer",@"nicer",
                              @"opal",@"opal",
                              @"penguin",@"penguin",
                              @"red",@"red",
                              @"tyrant",@"tyrant",
                              @"umbrella",@"umbrella",
                              @"vivid",@"vivid",
                              @"yearn",@"yearn",
                              @"aphid",@"aphid",
                              @"blue",@"blue",
                              @"crayon",@"crayon",
                              @"doubt",@"doubt",
                              @"elephant",@"elephant",
                              @"fairy",@"fairy",
                              @"green",@"green",
                              @"hoist",@"hoist",
                              @"implode",@"implode",
                              @"joker",@"joker",
                              @"knight",@"knight",
                              @"living",@"living",
                              @"monkey",@"monkey",
                              @"neon",@"neon",
                              @"orange",@"orange",
                              @"purple",@"purple",
                              @"royal",@"royal",
                              @"stupid",@"stupid",
                              @"think",@"think",
                              @"unicorn",@"unicorn",
                              @"veins",@"veins",
                              @"yellow",@"yellow",
                              nil];
//
//        self.wordCluePairs = [NSDictionary dictionaryWithObjectsAndKeys:
//                              @"this game, cross____", @"word",
//                              @"this game, _____word", @"cross",
//                              @"pink fish", @"salmon",
//                              @"not old", @"new",
//                              nil];
        
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
        self.game[@"waiting"] = @NO;
        [self.game removeObjectForKey:@"requestingHost"];
        [self.game removeObjectForKey:@"requestedBy"];
        [self.game save];
        
        //create word tiles and add to array
        NSArray *words = [self.wordCluePairs allKeys];
//        [self createTiles:[words objectAtIndex:0] :3 :1 :NO]; //word
//        [self createTiles:[words objectAtIndex:2] :1 :2 :YES]; //cross
//        [self createTiles:[words objectAtIndex:1] :5 :2 :NO]; //salmon
//        [self createTiles:[words objectAtIndex:3] :5 :7 :YES]; //new
        [self createBoard:words];
    }
    
    //if user is not the host, remove check button
    if ([self.game[@"hostID"] isEqualToString:self.currUser[@"fbID"]]) {
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = self.checkButton;
        self.hostTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkHostRequest) userInfo:nil repeats:YES];
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = self.requestHostButton;
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(checkUpdate) userInfo:nil repeats:YES];
        self.hostTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkHostAccept) userInfo:nil repeats:YES];
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

-(void)checkHostRequest {
    self.game = [[PFQuery queryWithClassName:@"Game"] getObjectWithId:self.game.objectId];
    if (![self.game[@"waiting"] boolValue] && [self.currUser[@"fbID"] isEqualToString:self.game[@"hostID"]]) {
        NSString *requesting = self.game[@"requestingHost"];
        if(requesting != nil && ![requesting isEqualToString:@"Accepted"] && ![requesting isEqualToString:@"Denied"] ) {
            self.game[@"waiting"] = @YES;
            [self.game save];
            PFObject *requestingUser = [[[PFQuery queryWithClassName:@"AppUser"] whereKey:@"fbID" equalTo:requesting] getFirstObject];
            NSString *info = [NSString stringWithFormat:@"%@ is requesting host. Would you like to give them control of the board?", requestingUser[@"name"]];
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Host Request"
                                           message:info
                                           preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* accept = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
               handler:^(UIAlertAction * action) {
                self.game[@"requestingHost"] = @"Accepted";
                self.game[@"hostID"] = requesting;
                [self.game save];
                [alert dismissViewControllerAnimated:YES completion:nil];
                [self viewDidLoad];
            }];
            
            UIAlertAction* deny = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault
               handler:^(UIAlertAction * action) {
                self.game[@"requestingHost"] = @"Denied";
                [self.game save];
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            
            [alert addAction:accept];
            [alert addAction:deny];
            [self presentViewController:alert animated:YES completion:nil];
            self.game[@"waiting"] = @NO;
            [self.game save];
        }
    }
}

- (void) checkHostAccept {
    self.game = [[PFQuery queryWithClassName:@"Game"] getObjectWithId:self.game.objectId];
    NSString *requesting = self.game[@"requestingHost"];
    if([self.game[@"requestedBy"] isEqualToString:self.currUser[@"fbID"]]) {
        UIAlertController *alert;
        if([requesting isEqualToString:@"Accepted"] || [requesting isEqualToString:@"Denied"]) {
            NSString *title = [NSString stringWithFormat:@"Host Request %@", requesting];
            alert = [UIAlertController alertControllerWithTitle:title
                                           message:@""
                                           preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
               handler:^(UIAlertAction * action) {
                [self.game removeObjectForKey:@"requestingHost"];
                [self.game save];
                [alert dismissViewControllerAnimated:YES completion:nil];
                [self viewDidLoad];
            }];
            
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        }
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
        cell.userInteractionEnabled = YES;
        cell.inputView.userInteractionEnabled = NO;
        cell.inputView.backgroundColor = [UIColor whiteColor];
        cell.inputView.text = cell.tile[@"inputLetter"];
    }
    else {
        cell.inputView.text = @"";
        cell.userInteractionEnabled = NO;
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
- (IBAction)didTapRequestHost:(id)sender {
    self.game[@"requestingHost"] = self.currUser[@"fbID"];
    self.game[@"requestedBy"] = self.currUser[@"fbID"];
    [self.game save];
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
        
        [player save]; //comment if testing without updating backend
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
        [user save]; //comment if testing without updating backend
    }
    //remove game object
    [self.game delete]; //comment if testing without updating backend
    NSArray *tiles = [[[PFQuery queryWithClassName:@"Tile"] whereKey:@"correctLetter" notEqualTo:@"empty"] findObjects];
    for (PFObject *tile in tiles) {
        [tile deleteInBackground];
    }
}









//generating boards testing

- (void)printSquareArray : (NSMutableArray *)array {
    NSString *print = @"current board: \n";
    for (NSMutableArray *row in array) {
        for (Tile *tile in row) {
            if (tile.fillable)
                print = [print stringByAppendingString:tile.correctLetter];
            else
                print = [print stringByAppendingString:@"-"];
        }
        print = [print stringByAppendingString:@"\n"];
    }
    NSLog(@"%@", print);
}

- (Tile *) getTileAtIndexTesting : (int) xIndex : (int) yIndex {
    NSMutableArray *innerArray = [self.tilesArray objectAtIndex:yIndex];
    return [innerArray objectAtIndex:xIndex];
}
- (void) setTileAtIndexTesting : (Tile *) tile : (int) xIndex : (int) yIndex {
    NSMutableArray *innerArray = [self.tilesArray objectAtIndex:yIndex];
    [innerArray replaceObjectAtIndex:xIndex withObject:tile];
}

- (void) createTilesTesting: (NSString *)word : (int) xIndex : (int) yIndex : (BOOL) across {
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
        Tile *tile = [self getTileAtIndexTesting:xIndex :yIndex];
        if (!tile.fillable) {
            tile = [[Tile alloc] init];
            tile.fillable = YES;
            tile.xIndex = xIndex;
            tile.yIndex = yIndex;
            tile.correctLetter = letter;
            tile.inputLetter = @" ";
        }
        if (across) { tile.acrossClue = word; }
        else { tile.downClue = word; }
        [self setTileAtIndexTesting:tile :tile.xIndex :tile.yIndex];
        if (across) { xIndex++; }
        else { yIndex++; }
    }
}

- (void) createBoard: (NSArray *)words {
//    //empty array, remove later
//    Tile *empty = [[Tile alloc] init];
//    empty.fillable = NO;
//    NSMutableArray *innerArray = [[NSMutableArray alloc] initWithCapacity: 10];
//    for (int j = 0; j < 10; j++) {
//        [innerArray insertObject:empty atIndex:j];
//    }
//    //add inner array to tilesArray
//    self.tilesArray = [[NSMutableArray alloc] initWithCapacity: 10];
//    for (int i = 0; i < 10; i++) {
//        [self.tilesArray insertObject:[NSMutableArray arrayWithArray:innerArray] atIndex:i];
//    }
    
    //remove word once added
    NSMutableArray *usableWords = [NSMutableArray arrayWithArray:words];
    
    //pick random word to go across top
    NSUInteger randomIndex = arc4random() % usableWords.count;
    NSString *first = [words objectAtIndex:randomIndex];
    [usableWords removeObject:first];
    [self createTiles:first :0 :0 :YES];
//    [self createTilesTesting:first :0 :0 :YES];
    
    //pick random letter in first word
    NSUInteger secondStart = arc4random() % first.length; //(secondStart, 0)
    NSString *secondLetter = [first substringWithRange:NSMakeRange(secondStart, 1)];
    NSArray *secondOptions = [usableWords filteredArrayUsingPredicate: [NSPredicate predicateWithFormat:@"SELF BEGINSWITH %@", secondLetter]];
    //pick random word to go down from letter
    randomIndex = arc4random() % secondOptions.count;
    NSString *second = [secondOptions objectAtIndex:randomIndex];
    [usableWords removeObject:second];
    [self createTiles:second :(int) secondStart :0 :NO];
//    [self createTilesTesting:second :(int) secondStart :0 :NO];

    //pick random letter in second word (not first or second)
    NSUInteger thirdStartY = (arc4random() % (second.length - 2) + 2); //(??, thirdStartY)
    NSString *thirdLetter = [second substringWithRange:NSMakeRange(thirdStartY, 1)];
    NSDictionary *thirdOptionsLocations = [self arrayOfValidStringsWithLetterAtIndex:usableWords :thirdLetter :secondStart];
    NSArray *thirdOptions = [thirdOptionsLocations allKeys];
    //pick random word to go across from letter
    randomIndex = arc4random() % thirdOptions.count;
    NSString *third = [thirdOptions objectAtIndex:randomIndex];
    NSArray *thirdStartXLocations = [thirdOptionsLocations objectForKey:third];
    [usableWords removeObject:third];
    [self createTiles:third :  [[thirdStartXLocations objectAtIndex:arc4random() % thirdStartXLocations.count] intValue]:(int) thirdStartY :YES];
//    [self createTilesTesting:third :  [[thirdStartXLocations objectAtIndex:arc4random() % thirdStartXLocations.count] intValue]:(int) thirdStartY :YES];
    
//    [self printSquareArray:self.tilesArray];
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

@end
