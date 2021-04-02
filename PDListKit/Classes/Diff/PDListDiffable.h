//
//  PDListDiffable.h
//  PDListKit
//
//  Created by liang on 2021/3/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PDListDiffable <NSObject>

- (id<NSObject>)diffIdentifier;

- (BOOL)isEqualToDiffableObject:(id<PDListDiffable> _Nullable)object;

@end

NS_ASSUME_NONNULL_END
