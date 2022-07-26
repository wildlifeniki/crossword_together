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

@property (strong, nonatomic) IBOutlet UICollectionView *boardCollectionView;
@property (nonatomic, strong) NSDictionary *wordCluePairs;
@property (nonatomic, strong) NSMutableArray *tilesArray;
@property (assign, nonatomic) int xIndex;
@property (assign, nonatomic) int yIndex;

@end

@implementation InGameViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.boardCollectionView.delegate = self;
    self.boardCollectionView.dataSource = self;
    
    //initialize dictionary
    self.wordCluePairs = [NSDictionary dictionaryWithObject:@"clue: cross____" forKey:@"word"];
    
    //initalize indexes for collectionview
    self.xIndex = 0;
    self.yIndex = 0;
    
    //initialize tilesArray with all unfillable tiles
    int size = 4; //to make square grid
    
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
    [self createTiles:[self.wordCluePairs allKeys].firstObject];
}


//create tile objects for each character in clue and assign them to the array of tiles
- (void) createTiles : (NSString *)word {
    NSMutableArray *wordLetters = [NSMutableArray arrayWithArray:@[]];
    
    //split word string into substrings of 1 capital letter
    NSString *capitalWord = [word uppercaseString];
    for (int i = 0; i < capitalWord.length; i++) {
        NSString *letter = [capitalWord substringWithRange:(NSMakeRange(i, 1))];
        [wordLetters addObject:letter];
    }
    
    //create tiles for each letter and put them in correct spot in the array
    int xIndex = 0;
    for (NSString *letter in wordLetters) {
        Tile *tile = [[Tile alloc] init];
        tile.xIndex = xIndex;
        tile.yIndex = 1;         //assigning index hard-coded for now
        tile.correctLetter = letter;
        tile.inputLetter = @" ";
        tile.acrossClue = [self.wordCluePairs valueForKey:word];
        tile.fillable = YES;
        
        NSMutableArray *innerArray = [self.tilesArray objectAtIndex:tile.yIndex];
        [innerArray replaceObjectAtIndex:tile.xIndex withObject:tile];
        xIndex++;
    }
    [self printSquareArray:self.tilesArray];
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
    
    NSMutableArray *innerArray = [self.tilesArray objectAtIndex:self.yIndex];
    Tile *tile = [innerArray objectAtIndex:self.xIndex];
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

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    int numTiles = (int)(self.tilesArray.count * self.tilesArray.count);
    return numTiles;
}

- (IBAction)didTapClose:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
