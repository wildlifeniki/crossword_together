//
//  Tile.h
//  meta_capstone
//
//  Created by Nikita Singh on 7/6/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Tile : NSObject

@property (nonatomic, strong) NSNumber *xIndex;
@property (nonatomic, strong) NSNumber *yIndex;
@property (nonatomic, strong) NSString *correctLetter;
@property (nonatomic, strong) NSString *inputLetter;
@property (nonatomic, strong) NSString *acrossClue;
@property (nonatomic, strong) NSString *downClue;
@property (assign) BOOL fillable;

@end

NS_ASSUME_NONNULL_END
