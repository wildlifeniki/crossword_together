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
    
    //get profile picture
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
    initWithGraphPath:[NSString stringWithFormat:@"/%@?fields=picture.type(large)", user[@"fbID"]]
        parameters:nil
        HTTPMethod:@"GET"];
    [request startWithCompletion:^(id<FBSDKGraphRequestConnecting>  _Nullable connection, id  _Nullable result, NSError * _Nullable error) {
        NSURL *url = [NSURL URLWithString:[[[(NSDictionary*) result objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"]];
        self.userImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        self.userImage.layer.cornerRadius = self.userImage.frame.size.width / 2;
        if (error != nil) {
            self.userImage.image = [UIImage systemImageNamed:@"person.circle"];
        }
    }];
}

@end
