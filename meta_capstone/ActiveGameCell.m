//
//  ActiveGameCell.m
//  meta_capstone
//
//  Created by Nikita Singh on 7/13/22.
//

#import "ActiveGameCell.h"
#import "FBSDKCoreKit/FBSDKCoreKit.h"
#import "Parse/Parse.h"

@implementation ActiveGameCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellInfo:(PFObject *)game {
    self.game = game;
    PFQuery *query = [PFQuery queryWithClassName:@"AppUser"];
    [query whereKey:@"fbID" equalTo:game[@"hostID"]];
    PFObject *host = [query findObjects].firstObject;
    self.hostUserLabel.text = [NSString stringWithFormat:@"Host: %@", host[@"name"]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm 'on' MM/dd";
    self.boardFillLabel.text = [NSString stringWithFormat:@"Game started at %@", [dateFormatter stringFromDate:game.createdAt]];
    
    //get profile picture
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
    initWithGraphPath:[NSString stringWithFormat:@"/%@?fields=picture.type(large)", host[@"fbID"]]
        parameters:nil
        HTTPMethod:@"GET"];
    [request startWithCompletion:^(id<FBSDKGraphRequestConnecting>  _Nullable connection, id  _Nullable result, NSError * _Nullable error) {
        NSURL *url = [NSURL URLWithString:[[[(NSDictionary*) result objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"]];
        self.hostProfileImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    }];
}

@end
