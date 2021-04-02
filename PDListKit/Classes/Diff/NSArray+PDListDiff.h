//
//  NSArray+PDListDiff.h
//  PDListKit
//
//  Created by liang on 2021/4/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PDListDiffable;

@interface NSArray (PDListDiff)

FOUNDATION_EXPORT NSArray * _Nullable
PDListObjectsWithDuplicateIdentifiersRemoved(NSArray<id<PDListDiffable>> * _Nullable objects);

@end

NS_ASSUME_NONNULL_END
