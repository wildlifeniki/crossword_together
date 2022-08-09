//
//  UIViewController+TileMethods.m
//  meta_capstone
//
//  Created by Nikita Singh on 8/9/22.
//

#import "UIViewController+TileMethods.h"


@interface UIViewController_TileMethods ()

@end

@implementation UIViewController_TileMethods

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

@end
