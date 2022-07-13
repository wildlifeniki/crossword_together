//
//  ActiveGameCell.h
//  meta_capstone
//
//  Created by Nikita Singh on 7/13/22.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface ActiveGameCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *hostProfileImage;
@property (strong, nonatomic) IBOutlet UILabel *hostUserLabel;
@property (strong, nonatomic) IBOutlet UILabel *boardFillLabel;

- (void)setCellInfo:(PFObject *)game;

@end

NS_ASSUME_NONNULL_END
