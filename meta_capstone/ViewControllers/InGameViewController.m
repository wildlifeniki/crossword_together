//
//  InGameViewController.m
//  meta_capstone
//
//  Created by Nikita Singh on 7/19/22.
//

#import "InGameViewController.h"
#import "Tile.h"
#import "BoardTileCell.h"
#import "FCAlertView/FCAlertView.h"

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
    
    self.emptyTile = [[[PFQuery queryWithClassName:@"Tile"] whereKey:@"fillable" equalTo:@NO] findObjects].firstObject; //init emptyTile object
        
    //if no board already in database, create empty board
    if (self.game[@"tilesArray"] == nil) {
        //initialize dictionary
        self.wordCluePairs = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"iPhone company", @"apple",
                              @"Bunch of produce", @"banana",
                              @"Nose on a snowman", @"carrot",
                              @"Jurassic animal", @"dinosaur",
                              @"Mystery", @"enigma",
                              @"Suspicious", @"fishy",
                              @"Silverback", @"gorilla",
                              @"They eat marbles in a classic children's game", @"hippos",
                              @"South American lizard",@"iguana",
                              @"Schoolyard activity",@"jumprope",
                              @"Queen's mate",@"king",
                              @"Uncool",@"lame",
                              @"Sahara sight",@"mirage",
                              @"Big fall",@"niagra",
                              @"Pearly stone",@"opal",
                              @"Pablo from The Backyardigans",@"penguin",
                              @"Chill", @"relax",
                              @"Spring Flower",@"tulip",
                              @"Rihanna song from 2007",@"umbrella",
                              @"Colorful",@"vivid",
                              @"Wants badly",@"yearns",
                              @"Ladybug snack",@"aphid",
                              @"High fiber ingredient",@"bran",
                              @"Waxy coloring utensil",@"crayon",
                              @"Uncertainty",@"doubt",
                              @"Mammoth cousin",@"elephant",
                              @"Collects teeth",@"fairy",
                              @"Lush",@"green",
                              @"Lift up",@"hoist",
                              @"Collapse",@"implode",
                              @"Card that may be wild",@"joker",
                              @"Chess piece that looks like a horse",@"knight",
                              @"Not dead",@"living",
                              @"Banana consumer",@"monkey",
                              @"Bright sign",@"neon",
                              @"Disneyland's county",@"orange",
                              @"Royal color",@"purple",
                              @"What bread does",@"rises",
                              @"Dunce",@"stupid",
                              @"Letter after Sierra",@"tango",
                              @"Horse's mythical relative",@"unicorn",
                              @"Starbucks cup size",@"venti",
                              @"Canary color",@"yellow",
                              nil];
        
        //initalize indexes for collectionview
        self.xIndex = 0;
        self.yIndex = 0;
        
        //initialize tilesArray with all unfillable tiles
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
        [self createBoard:words];
    }
    [self refreshTilesArray];
    
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
        [self refreshTilesArray];
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
    //check if game has been finished
    if (self.game == nil) {
        [self.timer invalidate];
        [self.updateTimer invalidate];
        [self.hostTimer invalidate];
        [self completionAlert];
    }
    else {
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

//query all tiles in game, set to tilesArray
- (void) refreshTilesArray {
    self.game = [[PFQuery queryWithClassName:@"Game"] getObjectWithId:self.game.objectId];
    NSArray *availableTilesInGame = [[[PFQuery queryWithClassName:@"Tile"] whereKey:@"gameID" equalTo:self.game.objectId] findObjects];
    NSMutableArray *tilesArray = [NSMutableArray arrayWithArray:@[]];
    
    NSArray *tileIDsArray = self.game[@"tilesArray"];
    for (NSArray *tileIDsRow in tileIDsArray) {
        NSMutableArray *tilesRow = [NSMutableArray arrayWithArray:@[]];
        for (NSString *tileID in tileIDsRow) {
            [tilesRow addObject:[self findTileInArrayWithID:availableTilesInGame :tileID]];
        }
        [tilesArray addObject:[NSArray arrayWithArray:tilesRow]];
    }
    self.tilesArray = tilesArray;
}

- (PFObject *) findTileInArrayWithID : (NSArray *)tiles : (NSString *)tileID {
    for (PFObject* tile in tiles) {
        if ([tile.objectId isEqualToString:tileID])
            return tile;
    }
    return self.emptyTile;
}

//query individual tile
- (PFObject *) getTileAtIndex : (int) xIndex : (int) yIndex {
    NSMutableArray *innerArray = [self.tilesArray objectAtIndex:yIndex];
    return [innerArray objectAtIndex:xIndex];
}

- (void) setTileAtIndex : (PFObject *) tile : (int) xIndex : (int) yIndex {
    NSMutableArray *tilesArray = self.game[@"tilesArray"];
    NSMutableArray *innerArray = [tilesArray objectAtIndex:yIndex];
    [innerArray replaceObjectAtIndex:xIndex withObject:tile.objectId];
    [tilesArray replaceObjectAtIndex:yIndex withObject:innerArray];
    self.game[@"tilesArray"] = tilesArray;
    [self.game save];
    [self refreshTilesArray];
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
    cell.inputView.backgroundColor = [UIColor colorNamed:@"CTYellow"];

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
        [self.timer invalidate];
        [self.updateTimer invalidate];
        [self.hostTimer invalidate];
        [self updatePlayerData];
        [self removeGameData];
        [self completionAlert];
    }
    
    //if not correct, make alert saying everything is not correct yet (ok just closes alert)
    else {
        FCAlertView *incorrectAlert = [[FCAlertView alloc] init];
        [incorrectAlert showAlertWithTitle:@"Not Quite..."
                              withSubtitle:@"The board is not yet correct."
                           withCustomImage:[UIImage imageNamed:@"incorrectAlert"]
                       withDoneButtonTitle:@"Back to Game"
                                andButtons:nil];
        incorrectAlert.avoidCustomImageTint = YES;
        incorrectAlert.bounceAnimations = YES;
        incorrectAlert.customImageScale = 1.5;
    }
}

- (void)completionAlert {
    FCAlertView *correctAlert = [[FCAlertView alloc] init];
    [correctAlert showAlertWithTitle:@"Complete!"
                          withSubtitle:@"Congratulations, you have finished this board."
                     withCustomImage: [UIImage imageNamed:@"correctAlert"]
                   withDoneButtonTitle:@"Finish Game"
                            andButtons:nil];
    correctAlert.avoidCustomImageTint = YES;
    correctAlert.customImageScale = 1.5;
    correctAlert.bounceAnimations = YES;
    [correctAlert doneActionBlock:^{
        [self dismissViewControllerAnimated:true completion:nil];
    }];
}

- (IBAction)didTapClose:(id)sender {
    [self.timer invalidate];
    [self.updateTimer invalidate];
    [self.hostTimer invalidate];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)updatePlayerData {
    self.game = [[PFQuery queryWithClassName:@"Game"] getObjectWithId:self.game.objectId];
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
    
    //remove tiles
    NSArray *tiles = [[[PFQuery queryWithClassName:@"Tile"] whereKey:@"gameID" equalTo:self.game.objectId] findObjects];
    for (PFObject *tile in tiles) {
        [tile deleteInBackground];
    }
    
    //remove game object
    [self.game delete]; //comment if testing without updating backend
}

- (void) createBoard: (NSArray *)words {
    //remove word once added
    NSMutableArray *usableWords = [NSMutableArray arrayWithArray:words];
    
    //pick random word to go across top
    NSUInteger randomIndex = arc4random() % usableWords.count;
    NSString *firstWord = [words objectAtIndex:randomIndex];
    [usableWords removeObject:firstWord];
    [self createTiles:firstWord :0 :0 :YES];
    
    //pick random letter in first word
    NSUInteger secondStart = arc4random() % firstWord.length; //(secondStart, 0)
    NSString *secondLetter = [firstWord substringWithRange:NSMakeRange(secondStart, 1)];
    NSArray *secondOptions = [usableWords filteredArrayUsingPredicate: [NSPredicate predicateWithFormat:@"SELF BEGINSWITH %@", secondLetter]];
    //pick random word to go down from letter
    randomIndex = arc4random() % secondOptions.count;
    NSString *secondWord = [secondOptions objectAtIndex:randomIndex];
    [usableWords removeObject:secondWord];
    [self createTiles:secondWord :(int) secondStart :0 :NO];

    //pick random letter in second word (not first or second)
    NSUInteger thirdStartY = (arc4random() % (secondWord.length - 2) + 2); //(??, thirdStartY)
    NSString *thirdLetter = [secondWord substringWithRange:NSMakeRange(thirdStartY, 1)];
    NSDictionary *thirdOptionsLocations = [self arrayOfValidStringsWithLetterAtIndex:usableWords :thirdLetter :secondStart];
    NSArray *thirdOptions = [thirdOptionsLocations allKeys];
    //pick random word to go across from letter
    randomIndex = arc4random() % thirdOptions.count;
    NSString *thirdWord = [thirdOptions objectAtIndex:randomIndex];
    NSArray *thirdStartXLocations = [thirdOptionsLocations objectForKey:thirdWord];
    [usableWords removeObject:thirdWord];
    [self createTiles:thirdWord :  [[thirdStartXLocations objectAtIndex:arc4random() % thirdStartXLocations.count] intValue]:(int) thirdStartY :YES];
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
