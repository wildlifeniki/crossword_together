//
//  LeaderboardCell.m
//  meta_capstone
//
//  Created by Nikita Singh on 7/11/22.
//

#import "LeaderboardCell.h"
#import "Parse/Parse.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

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
    self.userNameLabel.text = user[@"name"];
    self.userTimeLabel.text = [NSString stringWithFormat:@"Avg time: %@s", user[@"avgTime"]];
    self.rankLabel.text = [NSString stringWithFormat:@"#%ld", (long) rank];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?redirect=false&type=large", user[@"fbID"]]];
    NSDictionary *s = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:url] options:0 error:nil];
    NSURL *picUrl = [NSURL URLWithString:[[s objectForKey:@"data"] objectForKey:@"url"]];
    self.userImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:picUrl]];
    self.userImage.layer.cornerRadius = self.userImage.frame.size.width / 2;
}

@end
