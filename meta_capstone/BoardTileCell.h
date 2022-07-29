//
//  BoardTileCell.h
//  meta_capstone
//
//  Created by Nikita Singh on 7/25/22.
//

#import <UIKit/UIKit.h>
#import "Tile.h"
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface BoardTileCell : UICollectionViewCell <UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextView *inputView;
@property (strong, nonatomic) PFObject *tile;
@property (strong, nonatomic) PFObject *game;
@property (strong, nonatomic) PFObject *user;

- (void)textViewDidEndEditing:(UITextView *)textView;


@end

NS_ASSUME_NONNULL_END
