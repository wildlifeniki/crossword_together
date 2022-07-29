//
//  BoardTileCell.m
//  meta_capstone
//
//  Created by Nikita Singh on 7/25/22.
//

#import "BoardTileCell.h"
#import "InGameViewController.h"

@implementation BoardTileCell

- (void)setTileInfo :(PFObject *)tile {
    self.inputView.delegate = self;
    self.tile = tile;
    
    if ([self.tile[@"fillable"] boolValue]) {
        [self.contentView.layer setBorderColor:[UIColor blackColor].CGColor];
        [self.contentView.layer setBorderWidth:1.0f];
        if ([self.game[@"hostID"] isEqualToString:self.user[@"fbID"]])
            self.inputView.text = self.tile[@"inputLetter"];
        else
            self.inputView.text = self.tile[@"inputLetter"];
    }
    else
        [self.inputView removeFromSuperview];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //update tile on "enter" press
    if([text isEqualToString:@"\n"]) {
        [self textViewDidEndEditing:self.inputView];
        return NO;
    }
    return textView.text.length + (text.length - range.length) <= 1;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.tile[@"inputLetter"] = self.inputView.text;
    [self.tile save];
    self.game[@"updated"] = @YES;
    [self.game save];
    self.inputView.userInteractionEnabled = NO;
    self.inputView.backgroundColor = [UIColor whiteColor];
    [self.inputView resignFirstResponder];
}

@end
