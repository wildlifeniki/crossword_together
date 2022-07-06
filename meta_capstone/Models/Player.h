//
//  Player.h
//  meta_capstone
//
//  Created by Nikita Singh on 7/6/22.
//

#import <Foundation/Foundation.h>
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface Player : NSObject

@property (nonatomic, strong) NSString *player_id;
@property (nonatomic, strong) User *user;
@property (nonatomic, assign) BOOL *isHost;
@property (nonatomic, assign) BOOL *isRequestingHost;
@property (nonatomic, strong) NSString *color;

@end

NS_ASSUME_NONNULL_END
