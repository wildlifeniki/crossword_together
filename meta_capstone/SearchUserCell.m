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

- (BOOL)arrayContainsPFObject :(NSMutableArray *)array :(PFObject *)object {
    BOOL found = NO;
    for (PFObject *element in array) {
        if ([element.objectId isEqual:object.objectId])
            found = YES;
    }
    return found;
}

- (void)setCellInfo:(PFObject *)user : (NSIndexPath *)indexPath {
    self.currUser = user;
    self.indexPath = indexPath;
    
    PFQuery *query = [PFQuery queryWithClassName:@"AppInfo"];
    [query fromLocalDatastore];
    PFObject *info = [query findObjects].firstObject;
    self.invitedArray = [NSMutableArray arrayWithArray:info[@"invitedArray"]];
        
    if ([self arrayContainsPFObject:self.invitedArray :self.currUser])
        [self.inviteButton setImage:[UIImage systemImageNamed:@"minus"] forState:UIControlStateNormal];
    else
        [self.inviteButton setImage:[UIImage systemImageNamed:@"plus"] forState:UIControlStateNormal];
    
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
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.currUser, @"cellUser", self.indexPath, @"indexPath", nil];

    if ([self arrayContainsPFObject:self.invitedArray :self.currUser]) {
        NSLog(@"removing %@", self.currUser[@"name"]); //removing from backend is also done in view controller
        [self.inviteButton setImage:[UIImage systemImageNamed:@"plus"] forState:UIControlStateNormal];
        [[NSNotificationCenter defaultCenter]
            postNotificationName:@"removeUser"
            object:self
            userInfo:userInfo];
    }
    else {
        NSLog(@"adding %@", self.currUser[@"name"]); //adding to backend is also done in view controller
        [self.inviteButton setImage:[UIImage systemImageNamed:@"minus"] forState:UIControlStateNormal];
        [[NSNotificationCenter defaultCenter]
            postNotificationName:@"addUser"
            object:self
            userInfo:userInfo];
    }
    
    [self setCellInfo:self.currUser : self.indexPath];
}

@end
