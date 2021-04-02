//
//  PDListIndexSetResult.m
//  PDListKit
//
//  Created by liang on 2021/3/26.
//

#import "PDListIndexSetResult.h"
#import "PDListIndexSetResult+Internal.h"

@implementation PDListIndexSetResult {
    NSMapTable<id<NSObject>, NSNumber *> *_oldIndexMap;
    NSMapTable<id<NSObject>, NSNumber *> *_newIndexMap;
}

- (instancetype)initWithInserts:(NSIndexSet *)inserts
                        deletes:(NSIndexSet *)deletes
                        updates:(NSIndexSet *)updates
                          moves:(NSArray<PDListMoveIndex *> *)moves
                    oldIndexMap:(NSMapTable<id<NSObject>, NSNumber *> *)oldIndexMap
                    newIndexMap:(NSMapTable<id<NSObject>, NSNumber *> *)newIndexMap {
    if (self = [super init]) {
        _inserts = inserts;
        _deletes = deletes;
        _updates = updates;
        _moves = moves;
        _oldIndexMap = oldIndexMap;
        _newIndexMap = newIndexMap;
    }
    return self;
}

- (BOOL)hasChanges {
    return self.changeCount > 0;
}

- (NSInteger)changeCount {
    return self.inserts.count + self.deletes.count + self.updates.count + self.moves.count;
}

- (PDListIndexSetResult *)resultForBatchUpdates {
    NSMutableIndexSet *deletes = [self.deletes mutableCopy];
    NSMutableIndexSet *inserts = [self.inserts mutableCopy];
    NSMutableIndexSet *filteredUpdates = [self.updates mutableCopy];

    NSArray<PDListMoveIndex *> *moves = self.moves;
    NSMutableArray<PDListMoveIndex *> *filteredMoves = [moves mutableCopy];

    // convert all update+move to delete+insert
    // 将所有的 update && move 转换为 delete+insert
    const NSInteger moveCount = moves.count;
    for (NSInteger i = moveCount - 1; i >= 0; i--) {
        PDListMoveIndex *move = moves[i];
        
        // 如果是 update && move
        if ([filteredUpdates containsIndex:move.from]) {
            // 从 move 和 update 中移除
            [filteredMoves removeObjectAtIndex:i];
            [filteredUpdates removeIndex:move.from];
            
            // 填加到 delete 和 insert
            [deletes addIndex:move.from];
            [inserts addIndex:move.to];
        }
    }

    // iterate all new identifiers. if its index is updated, delete from the old index and insert the new index
    // 遍历所有的旧 identifier，如果该 identifiers 的 index 被更新，从旧索引中删除，并插入新的索引
    for (id<NSObject> key in [_oldIndexMap keyEnumerator]) {
        // 获取旧 index（在旧表中）
        const NSInteger index = [[_oldIndexMap objectForKey:key] integerValue];
        // 如果该 index 需要被 update
        if ([filteredUpdates containsIndex:index]) {
            // 转换为：先删除，再插入
            [deletes addIndex:index];
            [inserts addIndex:[[_newIndexMap objectForKey:key] integerValue]];
        }
    }

    return [[PDListIndexSetResult alloc] initWithInserts:inserts
                                                 deletes:deletes
                                                 updates:[NSIndexSet new]
                                                   moves:filteredMoves
                                             oldIndexMap:_oldIndexMap
                                             newIndexMap:_newIndexMap];
}

- (NSInteger)oldIndexForIdentifier:(id<NSObject>)identifier {
    NSNumber *index = [_oldIndexMap objectForKey:identifier];
    return index == nil ? NSNotFound : [index integerValue];
}

- (NSInteger)newIndexForIdentifier:(id<NSObject>)identifier {
    NSNumber *index = [_newIndexMap objectForKey:identifier];
    return index == nil ? NSNotFound : [index integerValue];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p; %lu inserts; %lu deletes; %lu updates; %lu moves>",
            NSStringFromClass(self.class), self, (unsigned long)self.inserts.count, (unsigned long)self.deletes.count, (unsigned long)self.updates.count, (unsigned long)self.moves.count];
}

@end
