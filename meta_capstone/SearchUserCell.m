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
}

- (IBAction)didTapAdd:(id)sender {
    //add user object to array (stored in view controller, holds all users invites) limit 4
    //if already added, symbol should change and remove from array
    NSLog(@"pressed add");
}

@end
