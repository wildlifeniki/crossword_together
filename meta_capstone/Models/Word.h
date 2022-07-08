//
//  Word.h
//  meta_capstone
//
//  Created by Nikita Singh on 7/6/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Word : NSObject

@property (nonatomic, strong) NSString *wordId;
@property (nonatomic, strong) NSString *clue;
@property (nonatomic, strong) NSMutableArray *tiles;
@property (nonatomic, assign) BOOL *isCorrect;

@end

NS_ASSUME_NONNULL_END
