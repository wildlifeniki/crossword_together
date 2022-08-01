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
    self.game = game;
    PFQuery *query = [PFQuery queryWithClassName:@"AppUser"];
    [query whereKey:@"fbID" equalTo:game[@"inviteID"]];
    self.inviteFromLabel.text = [NSString stringWithFormat:@"Invitation from: %@", [query findObjects].firstObject[@"name"]];
    
    PFQuery *idQuery = [PFQuery queryWithClassName:@"AppInfo"];
    [idQuery fromLocalDatastore];
    NSArray *idObjects = [idQuery findObjects];
    NSString *currUserID;
    if ([idObjects count] != 0) {
        currUserID = idObjects.firstObject[@"fbID"];
    }
    
    [query whereKey:@"fbID" equalTo:currUserID];
    NSArray *userObjects = [query findObjects];
    self.selfUser = userObjects.firstObject;
}

- (void)deleteInvite {
    [UIView animateWithDuration:1.0 animations:^{
        self.contentView.backgroundColor = [UIColor redColor];
    } completion:NULL];
    
    [self.selfUser removeObject:self.game.objectId forKey:@"pendingInvites"];
    [self.selfUser save];
}

- (void)acceptInvite {
    [UIView animateWithDuration:1.0 animations:^{
        self.contentView.backgroundColor = [UIColor blueColor];
    } completion:NULL];
    
    [self.selfUser removeObject:self.game.objectId forKey:@"pendingInvites"];
    [self.selfUser addObject:self.game.objectId forKey:@"activeGames"];
    [self.selfUser save];
}


//accepting invite means: game gets added to active games for user, updates active games table, user gets added to active players for game
- (IBAction)didTapAccept:(id)sender {
    [self acceptInvite];
}

@end
