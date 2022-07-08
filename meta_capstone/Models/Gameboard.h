//
//  Gameboard.h
//  meta_capstone
//
//  Created by Nikita Singh on 7/6/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Gameboard : NSObject

@property (nonatomic, strong) NSString *boardId;
@property (nonatomic, strong) NSMutableArray *players;
@property (nonatomic, strong) NSMutableArray *words;
@property (nonatomic, strong) NSNumber *time;
@property (nonatomic, assign) BOOL *isCorrect;

@end

NS_ASSUME_NONNULL_END
