//
//  BoardTileCell.h
//  meta_capstone
//
//  Created by Nikita Singh on 7/25/22.
//

#import <UIKit/UIKit.h>
#import "Tile.h"

NS_ASSUME_NONNULL_BEGIN

@interface BoardTileCell : UICollectionViewCell <UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextView *inputView;
@property (strong, nonatomic) Tile *tile;

- (void)setTileInfo:(Tile *)tile;

- (void)textViewDidEndEditing:(UITextView *)textView;


@end

NS_ASSUME_NONNULL_END
