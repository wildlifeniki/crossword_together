//
//  BoardTileCell.h
//  meta_capstone
//
//  Created by Nikita Singh on 7/25/22.
//

#import <UIKit/UIKit.h>
#import "Tile.h"

NS_ASSUME_NONNULL_BEGIN

@interface BoardTileCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UITextView *inputView;

- (void)setTileInfo:(Tile *)tile;

@end

NS_ASSUME_NONNULL_END
