//
//  PendingInviteCell.h
//  meta_capstone
//
//  Created by Nikita Singh on 7/13/22.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import "GamesViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PendingInviteCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *inviteFromLabel;

@property (strong, nonatomic) PFObject *game;
@property (strong, nonatomic) PFObject *selfUser;
@property (strong, nonatomic) GamesViewController *viewController;

- (void)setCellInfo:(PFObject *)game;
- (void)deleteInvite;
- (void)acceptInvite;

@end

NS_ASSUME_NONNULL_END
