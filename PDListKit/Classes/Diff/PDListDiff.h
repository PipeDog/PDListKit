//
//  PDListDiff.h
//  PDListKit
//
//  Created by liang on 2021/3/26.
//

#import <Foundation/Foundation.h>
#import "PDListIndexSetResult.h"
#import "PDListDiffable.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PDListDiffOption) {
    PDListDiffPointerPersonality,
    PDListDiffEquality
};

FOUNDATION_EXTERN PDListIndexSetResult * _Nullable PDListDiff(NSArray<id<PDListDiffable>> *_Nullable oldArray,
                                                              NSArray<id<PDListDiffable>> *_Nullable newArray,
                                                              PDListDiffOption option);

NS_ASSUME_NONNULL_END
