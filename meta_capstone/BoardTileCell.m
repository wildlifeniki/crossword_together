//
//  BoardTileCell.m
//  meta_capstone
//
//  Created by Nikita Singh on 7/25/22.
//

#import "BoardTileCell.h"

@implementation BoardTileCell

- (void)setTileInfo :(Tile *)tile {
    if(tile.fillable) {
        self.inputView.text = tile.correctLetter;
    }
    else {
        [self.inputView removeFromSuperview];
        self.backgroundColor = [UIColor blackColor];
    }
}

@end
