//
//  SearchUserCell.m
//  meta_capstone
//
//  Created by Nikita Singh on 7/15/22.
//

#import "SearchUserCell.h"
#import "FBSDKCoreKit/FBSDKCoreKit.h"

@implementation SearchUserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.invited = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellInfo:(PFObject *)user {
    self.profileUserLabel.text = user[@"name"];
    
    //get profile picture
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
    initWithGraphPath:[NSString stringWithFormat:@"/%@?fields=picture.type(large)", user[@"fbID"]]
        parameters:nil
        HTTPMethod:@"GET"];
    [request startWithCompletion:^(id<FBSDKGraphRequestConnecting>  _Nullable connection, id  _Nullable result, NSError * _Nullable error) {
        NSURL *url = [NSURL URLWithString:[[[(NSDictionary*) result objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"]];
        self.profileImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    }];
    self.currUser = user;
}

- (IBAction)didTapAdd:(id)sender {
    if (self.invited) {
        self.invited = NO;
        NSLog(@"removing %@", self.currUser[@"name"]);
        [self.inviteButton setImage:[UIImage systemImageNamed:@"plus"] forState:UIControlStateNormal];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.currUser forKey:@"cellUser"];
        [[NSNotificationCenter defaultCenter]
            postNotificationName:@"removeUser"
            object:self
            userInfo:userInfo];
        [self setCellInfo:self.currUser];
    }
    else {
        self.invited = YES;
        NSLog(@"adding %@", self.currUser[@"name"]);
        [self.inviteButton setImage:[UIImage systemImageNamed:@"minus"] forState:UIControlStateNormal];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.currUser forKey:@"cellUser"];
        [[NSNotificationCenter defaultCenter]
            postNotificationName:@"addUser"
            object:self
            userInfo:userInfo];
    }
    [self setCellInfo:self.currUser];

}



@end
