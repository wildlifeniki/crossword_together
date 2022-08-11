//
//  LeaderboardCell.h
//  meta_capstone
//
//  Created by Nikita Singh on 7/11/22.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import "TableViewCell+ProfileMethods.h"

NS_ASSUME_NONNULL_BEGIN

@interface LeaderboardCell : TableViewCell_ProfileMethods
@property (strong, nonatomic) IBOutlet UILabel *rankLabel;
@property (strong, nonatomic) IBOutlet UIImageView *userImage;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *userTimeLabel;

-(void)setCellInfo: (PFObject *)user : (NSInteger)rank;
@end

NS_ASSUME_NONNULL_END
