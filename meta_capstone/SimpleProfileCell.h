//
//  SimpleProfileCell.h
//  meta_capstone
//
//  Created by Nikita Singh on 7/12/22.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import "TableViewCell+ProfileMethods.h"

NS_ASSUME_NONNULL_BEGIN

@interface SimpleProfileCell : TableViewCell_ProfileMethods

@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UILabel *profileUserLabel;

- (void)setCellInfo:(PFObject *)user;


@end

NS_ASSUME_NONNULL_END
