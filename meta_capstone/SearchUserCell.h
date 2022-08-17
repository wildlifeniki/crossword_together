//
//  SearchUserCell.h
//  meta_capstone
//
//  Created by Nikita Singh on 7/15/22.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import "TableViewCell+ProfileMethods.h"

NS_ASSUME_NONNULL_BEGIN

@interface SearchUserCell : TableViewCell_ProfileMethods

@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UILabel *profileUserLabel;
@property (strong, nonatomic) IBOutlet UIButton *inviteButton;

@property (strong, nonatomic) PFObject *currUser;
@property (strong, nonatomic) NSMutableArray *invitedArray;
@property (strong, nonatomic) NSIndexPath *indexPath;


- (void)setCellInfo:(PFObject *)user : (NSIndexPath *)indexPath;


@end

NS_ASSUME_NONNULL_END
