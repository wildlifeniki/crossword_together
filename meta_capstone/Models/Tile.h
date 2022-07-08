//
//  Tile.h
//  meta_capstone
//
//  Created by Nikita Singh on 7/6/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Tile : NSObject

@property (nonatomic, strong) NSString *tileId;
@property (nonatomic, strong) NSString *input;
@property (nonatomic, strong) NSString *goalInput;
@property (nonatomic, assign) BOOL *isCorrect;
@property (nonatomic, assign) BOOL *acceptsInput;

@end

NS_ASSUME_NONNULL_END
