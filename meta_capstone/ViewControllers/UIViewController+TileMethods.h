//
//  UIViewController+TileMethods.h
//  meta_capstone
//
//  Created by Nikita Singh on 8/9/22.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController_TileMethods : UIViewController

@property (nonatomic, strong) NSMutableArray *tilesArray;
@property (strong, nonatomic) PFObject *emptyTile;
@property (strong, nonatomic) NSMutableArray *usableWords;
@property (nonatomic, strong) NSMutableDictionary *wordCluePairs;
@property (nonatomic, strong) PFObject *game;

- (PFObject *) getTileAtIndex : (int) xIndex : (int) yIndex;
- (void) setTileAtIndex : (PFObject *) tile : (int) xIndex : (int) yIndex;
- (void) refreshTilesArray;
- (PFObject *) findTileInArrayWithID : (NSArray *)tiles : (NSString *)tileID;

@end

NS_ASSUME_NONNULL_END
