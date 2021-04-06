//
//  PDListKitUtil.m
//  PDListKit
//
//  Created by liang on 2021/4/2.
//

#import "PDListKitUtil.h"

NSArray<NSIndexPath *> *PDListConvertIndexPaths(NSInteger section, NSIndexSet *indexSet) {
    if (section < 0 || !indexSet) {
        return nil;
    }
    
    NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray array];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:section]];
    }];
    return indexPaths;
}
