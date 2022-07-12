//
//  LeaderboardCell.m
//  meta_capstone
//
//  Created by Nikita Singh on 7/11/22.
//

#import "LeaderboardCell.h"
#import "Parse/Parse.h"

@implementation LeaderboardCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellInfo:(PFObject *)user : (NSInteger)rank{
    NSLog(@"%@", user[@"avgTime"]);
    self.userNameLabel.text = user[@"name"];
    self.userTimeLabel.text = [NSString stringWithFormat:@"%@", user[@"avgTime"]];
    self.rankLabel.text = [NSString stringWithFormat:@"#%ld", (long) rank];
//    NSURL *url = [NSURL URLWithString:user[@"pfpURLString"]];
//    self.userImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    self.userImage.image = [UIImage systemImageNamed:@"person.circle"];
}

@end
