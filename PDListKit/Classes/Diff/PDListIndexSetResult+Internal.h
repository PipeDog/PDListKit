//
//  PDListIndexSetResult+Internal.h
//  PDListKit
//
//  Created by liang on 2021/4/2.
//

#import "PDListIndexSetResult.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDListIndexSetResult ()

- (instancetype)initWithInserts:(NSIndexSet *)inserts
                        deletes:(NSIndexSet *)deletes
                        updates:(NSIndexSet *)updates
                          moves:(NSArray<PDListMoveIndex *> *)moves
                    oldIndexMap:(NSMapTable<id<NSObject>, NSNumber *> *)oldIndexMap
                    newIndexMap:(NSMapTable<id<NSObject>, NSNumber *> *)newIndexMap;

@property (nonatomic, assign, readonly) NSInteger changeCount;

@end

NS_ASSUME_NONNULL_END
