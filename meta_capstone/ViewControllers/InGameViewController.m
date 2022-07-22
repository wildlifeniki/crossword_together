//
//  InGameViewController.m
//  meta_capstone
//
//  Created by Nikita Singh on 7/19/22.
//

#import "InGameViewController.h"
#import "Tile.h"

@interface InGameViewController ()

@property (nonatomic, strong) NSDictionary *wordCluePairs;
@property (nonatomic, strong) NSMutableArray *tilesArray;

@end

@implementation InGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.wordCluePairs = [NSDictionary dictionaryWithObject:@"clue: cross____" forKey:@"word"];
    
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
                print = [print stringByAppendingString:tile.correctLetter];
            else
                print = [print stringByAppendingString:@"_"];
        }
        print = [print stringByAppendingString:@"\n"];
    }
    NSLog(print);
}

- (IBAction)didTapClose:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
