//
//  ActiveGameCell.m
//  meta_capstone
//
//  Created by Nikita Singh on 7/13/22.
//

#import "ActiveGameCell.h"
#import "FBSDKCoreKit/FBSDKCoreKit.h"
#import "Parse/Parse.h"

@implementation ActiveGameCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellInfo:(PFObject *)game {
    self.game = game;
    PFQuery *query = [PFQuery queryWithClassName:@"AppUser"];
    [query whereKey:@"fbID" equalTo:game[@"hostID"]];
    PFObject *host = [query findObjects].firstObject;
    self.hostUserLabel.text = [NSString stringWithFormat:@"Host: %@", host[@"name"]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm 'on' MM/dd";
    self.boardFillLabel.text = [NSString stringWithFormat:@"Game started at %@", [dateFormatter stringFromDate:game.createdAt]];
    
    self.hostProfileImage.image = [self getProfilePictureForUser:host[@"fbID"]];
    self.hostProfileImage.layer.cornerRadius = self.hostProfileImage.frame.size.width / 2;
}

@end
