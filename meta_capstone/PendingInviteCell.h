//
//  PendingInviteCell.h
//  meta_capstone
//
//  Created by Nikita Singh on 7/13/22.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface PendingInviteCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *inviteFromLabel;
@property (strong, nonatomic) IBOutlet UIButton *didTapDeny;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *didTapAccept;

- (void)setCellInfo:(PFObject *)game;

@end

NS_ASSUME_NONNULL_END
