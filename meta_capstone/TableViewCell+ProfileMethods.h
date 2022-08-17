//
//  TableViewCell+ProfileMethods.h
//  meta_capstone
//
//  Created by Nikita Singh on 8/11/22.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface TableViewCell_ProfileMethods : UITableViewCell

- (UIImage *) getProfilePictureForUser : (NSString *) userID;

@end

NS_ASSUME_NONNULL_END
