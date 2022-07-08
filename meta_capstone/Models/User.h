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
@property (nonatomic, strong) NSNumber *totalGames;
@property (nonatomic, strong) NSNumber *bestTime;
@property (nonatomic, strong) NSNumber *avgTime;
@property (nonatomic, strong) NSMutableArray *recentlyPlayedWith;

@end

NS_ASSUME_NONNULL_END
