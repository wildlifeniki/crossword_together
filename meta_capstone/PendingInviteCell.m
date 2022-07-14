//
//  PendingInviteCell.m
//  meta_capstone
//
//  Created by Nikita Singh on 7/13/22.
//

#import "PendingInviteCell.h"
#import "FBSDKCoreKit/FBSDKCoreKit.h"
#import "Parse/Parse.h"

@implementation PendingInviteCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellInfo:(PFObject *)game {
    PFQuery *query = [PFQuery queryWithClassName:@"AppUser"];
    [query whereKey:@"fbID" equalTo:game[@"inviteID"]];
    self.inviteFromLabel.text = [NSString stringWithFormat:@"Invitation from: %@", [query findObjects].firstObject[@"name"]];
}

@end
