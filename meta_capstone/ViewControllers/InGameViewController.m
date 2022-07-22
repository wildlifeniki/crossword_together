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
        [self.tilesArray insertObject:innerArray atIndex:i];
    }
    
    //create word tiles and add to array
    [self createTiles:[self.wordCluePairs allKeys].firstObject];
}

//create tile objects for each character in clue and assign them to the array of tiles
- (void) createTiles : (NSString *)word {

}

- (IBAction)didTapClose:(id)sender {

    [self dismissViewControllerAnimated:true completion:nil];
}

@end
