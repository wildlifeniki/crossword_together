//
//  TableViewCell+ProfileMethods.m
//  meta_capstone
//
//  Created by Nikita Singh on 8/11/22.
//

#import "TableViewCell+ProfileMethods.h"

@implementation TableViewCell_ProfileMethods

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UIImage *) getProfilePictureForUser : (NSString *) userID {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?redirect=false&type=large", userID]];
    NSDictionary *s = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:url] options:0 error:nil];
    NSURL *picUrl = [NSURL URLWithString:[[s objectForKey:@"data"] objectForKey:@"url"]];
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:picUrl]];
}

@end
