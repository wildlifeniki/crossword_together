//
//  SimpleProfileCell.m
//  meta_capstone
//
//  Created by Nikita Singh on 7/12/22.
//

#import "SimpleProfileCell.h"
#import "FBSDKCoreKit/FBSDKCoreKit.h"

@implementation SimpleProfileCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellInfo:(PFObject *)user {
    self.profileUserLabel.text = user[@"name"];
    self.profileImage.image = [self getProfilePictureForUser:user[@"fbID"]];
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
}

@end
