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
    PFQuery *query = [PFQuery queryWithClassName:@"AppUser"];
    [query whereKey:@"fbID" equalTo:game[@"hostID"]];
    self.hostUserLabel.text = [NSString stringWithFormat:@"Host: %@", [query findObjects].firstObject[@"name"]];
    self.boardFillLabel.text = [NSString stringWithFormat:@"Board is %@ percent filled", game[@"percentComplete"]];
}

@end
