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
@property (nonatomic, strong) NSDictionary *wordCluePairs;
@property (nonatomic, strong) NSMutableArray *tilesArray;
@property (assign, nonatomic) int xIndex;
@property (assign, nonatomic) int yIndex;

@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) int seconds;

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
    int size = 10; //to make square grid
    
    //fill inner array
    Tile *black = [[Tile alloc] init];
    black.fillable = NO;
    NSMutableArray *innerArray = [[NSMutableArray alloc] initWithCapacity: size];
    for (int j = 0; j < size; j++) {
        [innerArray insertObject:black atIndex:j];
    }

    //add inner array to tilesArray
    self.tilesArray = [[NSMutableArray alloc] initWithCapacity: size];
    for (int i = 0; i < size; i++) {
        [self.tilesArray insertObject:[NSMutableArray arrayWithArray:innerArray] atIndex:i];
    }
    
    //create word tiles and add to array
    NSArray *words = [self.wordCluePairs allKeys];
    [self createTiles:[words objectAtIndex:0] :3 :1 :NO]; //word
    [self createTiles:[words objectAtIndex:2] :1 :2 :YES]; //cross
    [self createTiles:[words objectAtIndex:1] :5 :2 :NO]; //salmon
    [self createTiles:[words objectAtIndex:3] :5 :7 :YES]; //new

}

-(void)timerFired {
    self.seconds++;
    //calculate minutes and seconds
    int displayMin = self.seconds/60;
    int displaySec = self.seconds%60;
    NSString *displayTime = [NSString stringWithFormat:@"%02d:%02d", displayMin, displaySec];
    self.navigationItem.title = displayTime;
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
        Tile *tile = [self getTileAtIndex:xIndex :yIndex];
        if (!tile.fillable) {
            tile = [[Tile alloc] init];
            tile.fillable = YES;
            tile.xIndex = xIndex;
            tile.yIndex = yIndex;
            tile.correctLetter = letter;
            tile.inputLetter = @" ";
        }
        if (across) { tile.acrossClue = [self.wordCluePairs valueForKey:word]; }
        else { tile.downClue = [self.wordCluePairs valueForKey:word]; }

        [self setTileAtIndex:tile :tile.xIndex :tile.yIndex];
        if (across) { xIndex++; }
        else { yIndex++; }
    }
}

- (Tile *) getTileAtIndex : (int) xIndex : (int) yIndex {
    NSMutableArray *innerArray = [self.tilesArray objectAtIndex:yIndex];
    return [innerArray objectAtIndex:xIndex];
}

- (void) setTileAtIndex : (Tile *) tile : (int) xIndex : (int) yIndex {
    NSMutableArray *innerArray = [self.tilesArray objectAtIndex:yIndex];
    [innerArray replaceObjectAtIndex:xIndex withObject:tile];
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

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BoardTileCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"tile" forIndexPath:indexPath];
    cell.inputView.userInteractionEnabled = NO;
    cell.inputView.backgroundColor = [UIColor whiteColor];
    Tile *tile = [self getTileAtIndex:self.xIndex :self.yIndex];
    [cell setTileInfo:tile];
    
    //always increment x index
    //if x index reaches array count reset and increment y index
    self.xIndex++;
    if (self.xIndex >= self.tilesArray.count) {
        self.xIndex = 0;
        self.yIndex++;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    BoardTileCell *cell = (BoardTileCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell.inputView becomeFirstResponder];
    cell.inputView.userInteractionEnabled = YES;
    cell.inputView.backgroundColor = [UIColor systemGray5Color];
    
    NSString *clues = @"";
    if (cell.tile.acrossClue != nil)
        clues = [clues stringByAppendingString:[NSString stringWithFormat:@"Across: %@", cell.tile.acrossClue]];
    if (cell.tile.acrossClue != nil && cell.tile.downClue != nil)
        clues = [clues stringByAppendingString:@"\n"];
    if (cell.tile.downClue != nil)
        clues = [clues stringByAppendingString:[NSString stringWithFormat:@"Down: %@", cell.tile.downClue]];
    self.clueLabel.text = clues;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    int numTiles = (int)(self.tilesArray.count * self.tilesArray.count);
    return numTiles;
}

- (IBAction)didTapCheck:(id)sender {
    BOOL correct = YES;
    
    //check if all tiles have correct input
    for (NSMutableArray *row in self.tilesArray) {
        for (Tile *tile in row) {
            if (tile.fillable) {
                if (![tile.correctLetter isEqualToString:tile.inputLetter]) {
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
        
        [self updatePlayerData];
        [self.timer invalidate];
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
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)updatePlayerData {
    //get array of players in game
    NSArray *playerIDs = self.game[@"activePlayerIDs"];
    PFQuery *usersQuery = [PFQuery queryWithClassName:@"AppUser"];
    [usersQuery whereKey:@"fbID" containedIn:playerIDs];
    NSArray *players = [usersQuery findObjects];
    
    //update all players
    for (PFObject *player in players) {
        int prevTotalGames = [player[@"totalGames"] intValue];
        if (prevTotalGames == 0) {
            //edge case for new player
            player[@"avgTime"] = [NSNumber numberWithInt:self.seconds];
            player[@"bestTime"] = [NSNumber numberWithInt:self.seconds];
        }
        else {
            //update best time
            int prevBest = [player[@"bestTime"] intValue];
            if (self.seconds < prevBest)
                player[@"bestTime"] = [NSNumber numberWithInt:self.seconds];
            
            //update avg time
            int prevAvg = [player[@"avgTime"] intValue];
            int avgTime = ((prevAvg * prevTotalGames) + self.seconds) / (prevTotalGames + 1);

            player[@"avgTime"] = [NSNumber numberWithInt:avgTime];
        }
        
        //update total games
        [player incrementKey:@"totalGames"];

        //update recently played with ids
        NSMutableArray *recentIDs = player[@"recentlyPlayedWith"];
        NSMutableArray *newRecentIDs = [NSMutableArray arrayWithArray:@[]];
        for (NSString *playerID in playerIDs) {
            //remove any duplicate ids that will be added
            if ([recentIDs containsObject:playerID])
                [recentIDs removeObject:playerID];
            //don't add player to own recently played
            if (![playerID isEqualToString:player[@"fbID"]])
                [newRecentIDs addObject:playerID];
        }
        player[@"recentlyPlayedWith"] = [newRecentIDs arrayByAddingObjectsFromArray:recentIDs];
        
        [player save];
    }
}

- (void)removeGameData {
    //remove game object
    //remove game id from all active games and pending invites
    
}

@end
