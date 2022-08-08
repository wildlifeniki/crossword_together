//
//  BoardTileCell.m
//  meta_capstone
//
//  Created by Nikita Singh on 7/25/22.
//

#import "BoardTileCell.h"
#import "InGameViewController.h"

@implementation BoardTileCell

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //update tile on "enter" press
    if([text isEqualToString:@"\n"]) {
        [self textViewDidEndEditing:self.inputView];
        return NO;
    }
    
    //allow only letters
    if (text.length > 0 && ![[NSCharacterSet letterCharacterSet] characterIsMember:[text characterAtIndex:0]])
        return NO;
    
    //automatically capitalize letters
    NSRange lowercaseCharRange = [text rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]];
    if (lowercaseCharRange.location != NSNotFound) {
        textView.text = [textView.text stringByReplacingCharactersInRange:range withString:[text uppercaseString]];
        return NO;
    }

    //limit length to one character
    return textView.text.length + (text.length - range.length) <= 1;
}

- (void)textViewDidChange:(UITextView *)textView {
    // if a timer is already active, prevent it from firing
    if (self.sendUpdate != nil) {
        [self.sendUpdate invalidate];
        self.sendUpdate = nil;
    }

    // start timer again, so if no change in 1 second, send update
    self.sendUpdate = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                        target: self
                                                     selector: @selector(textViewDidEndEditing:)
                                                      userInfo: self.inputView
                                                       repeats: NO];
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
