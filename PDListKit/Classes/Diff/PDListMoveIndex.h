//
//  PDListMoveIndex.h
//  PDListKit
//
//  Created by liang on 2021/4/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDListMoveIndex : NSObject

@property (nonatomic, assign, readonly) NSInteger from;
@property (nonatomic, assign, readonly) NSInteger to;

- (instancetype)initWithFrom:(NSInteger)from to:(NSInteger)to NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
