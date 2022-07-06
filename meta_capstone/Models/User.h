//
//  User.h
//  meta_capstone
//
//  Created by Nikita Singh on 7/6/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface User : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSURL *pfpURL;
@property (nonatomic, strong) NSNumber *total_games;
@property (nonatomic, strong) NSNumber *best_time;
@property (nonatomic, strong) NSNumber *avg_time;
@property (nonatomic, strong) NSArray *recently_played_with;

@end

NS_ASSUME_NONNULL_END
