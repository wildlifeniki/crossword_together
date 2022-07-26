//
//  BoardTileCell.m
//  meta_capstone
//
//  Created by Nikita Singh on 7/25/22.
//

#import "BoardTileCell.h"
#import "InGameViewController.h"

@implementation BoardTileCell

- (void)setTileInfo :(Tile *)tile {
    self.inputView.delegate = self;
    self.tile = tile;
        
    if(self.tile.fillable) {
        self.inputView.text = @"";//tile.correctLetter;
    }
    else {
        [self.inputView removeFromSuperview];
        self.backgroundColor = [UIColor blackColor];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //update tile on "enter" press
    if([text isEqualToString:@"\n"]) {
        [self textViewDidEndEditing:self.inputView];
        return NO;
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.tile.inputLetter = self.inputView.text;
}

@end
