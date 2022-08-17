//
//  ActiveGameCell.h
//  meta_capstone
//
//  Created by Nikita Singh on 7/13/22.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import "TableViewCell+ProfileMethods.h"

NS_ASSUME_NONNULL_BEGIN

@interface ActiveGameCell : TableViewCell_ProfileMethods

@property (strong, nonatomic) IBOutlet UIImageView *hostProfileImage;
@property (strong, nonatomic) IBOutlet UILabel *hostUserLabel;
@property (strong, nonatomic) IBOutlet UILabel *boardFillLabel;
@property (strong, nonatomic) PFObject *game;

- (void)setCellInfo:(PFObject *)game;


@end

NS_ASSUME_NONNULL_END
