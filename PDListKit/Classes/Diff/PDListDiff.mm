//
//  PDListDiff.m
//  PDListKit
//
//  Created by liang on 2021/3/26.
//

#import "PDListDiff.h"
#import <stack>
#import <unordered_map>
#import <vector>
#import "PDListIndexSetResult+Internal.h"

using namespace std;

/// Used to track data stats while diffing.
struct PDListEntry {
    /// The number of times the data occurs in the old array
    NSInteger oldCounter = 0;
    /// The number of times the data occurs in the new array
    NSInteger newCounter = 0;
    /// The indexes of the data in the old array
    /// 旧数组中位置索引记录
    stack<NSInteger> oldIndexes;
    /// Flag marking if the data has been updated between arrays by checking the isEqual: method
    BOOL updated = NO;
};

/// Track both the entry and algorithm index. Default the index to NSNotFound
/// 用来记录 entry 的位置
struct PDListRecord {
    PDListEntry *entry;
    mutable NSInteger index;

    PDListRecord() {
        entry = NULL;
        index = NSNotFound;
    }
};

static id<NSObject> PDListTableKey(__unsafe_unretained id<PDListDiffable> object) {
    id<NSObject> key = [object diffIdentifier];
    NSCAssert(key != nil, @"Cannot use a nil key for the diffIdentifier of object %@", object);
    return key;
}

struct PDListEqualID {
    bool operator()(const id a, const id b) const {
        return (a == b) || [a isEqual: b];
    }
};

struct PDListHashID {
    size_t operator()(const id o) const {
        return (size_t)[o hash];
    }
};

static void addIndexToMap(BOOL useIndexPaths, NSInteger section, NSInteger index, __unsafe_unretained id<PDListDiffable> object, __unsafe_unretained NSMapTable *map) {
    id value;
    if (useIndexPaths) {
        value = [NSIndexPath indexPathForItem:index inSection:section];
    } else {
        value = @(index);
    }
    [map setObject:value forKey:[object diffIdentifier]];
}

static void addIndexToCollection(BOOL useIndexPaths, __unsafe_unretained id collection, NSInteger section, NSInteger index) {
    if (useIndexPaths) {
        NSIndexPath *path = [NSIndexPath indexPathForItem:index inSection:section];
        [collection addObject:path];
    } else {
        [collection addIndex:index];
    }
};

static id PDListDiffing(BOOL returnIndexPaths,
                        NSInteger fromSection,
                        NSInteger toSection,
                        NSArray<id<PDListDiffable>> *oldArray,
                        NSArray<id<PDListDiffable>> *newArray,
                        PDListDiffOption option) {
    const NSInteger newCount = newArray.count;
    const NSInteger oldCount = oldArray.count;

    NSMapTable *oldMap = [NSMapTable strongToStrongObjectsMapTable];
    NSMapTable *newMap = [NSMapTable strongToStrongObjectsMapTable];

    // if no new objects, everything from the oldArray is deleted
    // take a shortcut and just build a delete-everything result
    
    /* 如果没有新的对象，旧数组中所有对象都被删除，使用快捷方式，只构建一个删除所有的结果 */
    if (newCount == 0) {
        if (returnIndexPaths) {
            NSCAssert(NO, @"Unimplemented logic!");
            return nil;
        } else {
            [oldArray enumerateObjectsUsingBlock:^(id<PDListDiffable> obj, NSUInteger idx, BOOL *stop) {
                addIndexToMap(returnIndexPaths, fromSection, idx, obj, oldMap);
            }];
            return [[PDListIndexSetResult alloc] initWithInserts:[NSIndexSet new]
                                                         deletes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, oldCount)]
                                                         updates:[NSIndexSet new]
                                                           moves:[NSArray new]
                                                     oldIndexMap:oldMap
                                                     newIndexMap:newMap];
        }
    }

    // if no old objects, everything from the newArray is inserted
    // take a shortcut and just build an insert-everything result
    
    /* 如果没有旧的对象，新数组中所有的元素都将被插入，使用快捷方式，只构建一个插入所有的结果 */
    if (oldCount == 0) {
        if (returnIndexPaths) {
            NSCAssert(NO, @"Unimplemented logic!");
            return nil;
        } else {
            [newArray enumerateObjectsUsingBlock:^(id<PDListDiffable> obj, NSUInteger idx, BOOL *stop) {
                addIndexToMap(returnIndexPaths, toSection, idx, obj, newMap);
            }];
            return [[PDListIndexSetResult alloc] initWithInserts:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newCount)]
                                                         deletes:[NSIndexSet new]
                                                         updates:[NSIndexSet new]
                                                           moves:[NSArray new]
                                                     oldIndexMap:oldMap
                                                     newIndexMap:newMap];
        }
    }

    // symbol table uses the old/new array diffIdentifier as the key and PDListEntry as the value
    // using id<NSObject> as the key provided by https://lists.gnu.org/archive/html/discuss-gnustep/2011-07/msg00019.html
    
    /* @brief 采用的数据结果说明
     * table => map，O(1) 的时间复杂度访问 entry 实例
     * newResultsArray => array，用来存储 PDListRecord，其中包括 entry 及 entry 的位置
     * oldResultsArray => array，用来存储 PDListRecord，其中包括 entry 及 entry 的位置
     */
    // 符号表使用新/旧数组 单行的 `diffIdentifier` 做为 key，`PDListEntry` 做为 value
    unordered_map<id<NSObject>, PDListEntry, PDListHashID, PDListEqualID> table;

    // pass 1
    // create an entry for every item in the new array
    // increment its new count for each occurence
    
    /* 第 1 次遍历
     * 为新数组的每个元素创建一个 entry，并对 newCounter 进行自增 */
    vector<PDListRecord> newResultsArray(newCount);
    for (NSInteger i = 0; i < newCount; i++) {
        // 即某一 cell 的 diffID
        id<NSObject> key = PDListTableKey(newArray[i]);
        PDListEntry &entry = table[key];
        entry.newCounter++;

        // add NSNotFound for each occurence of the item in the new array
        // 为每个出现在新数组中的 entry 添加NSNotFound
        entry.oldIndexes.push(NSNotFound);

        // note: the entry is just a pointer to the entry which is stack-allocated in the table
        // 注意：entry 只是一个指向表项的指针，该 entry 是由栈分配的
        newResultsArray[i].entry = &entry;
    }

    // pass 2
    // update or create an entry for every item in the old array
    // increment its old count for each occurence
    // record the original index of the item in the old array
    // MUST be done in descending order to respect the oldIndexes stack construction
    
    /* 第 2 次遍历
     * 为旧数组中的每个元素更新或创建对应的 entry，并增加得出在旧数组中出现的次数，记录该元素在
     * 旧数组中的原始索引（index），必须按降序执行，来保证 oldIndexes 数组元素在栈中的顺序 */
    vector<PDListRecord> oldResultsArray(oldCount);
    for (NSInteger i = oldCount - 1; i >= 0; i--) {
        // 即某一 cell 的 diffID
        id<NSObject> key = PDListTableKey(oldArray[i]);
        PDListEntry &entry = table[key];
        entry.oldCounter++;

        // push the original indices where the item occurred onto the index stack
        // 将该元素的原始索引压入栈中
        entry.oldIndexes.push(i);

        // note: the entry is just a pointer to the entry which is stack-allocated in the table
        // 注意：entry 只是一个指向表项的指针，该 entry 是由栈分配的
        oldResultsArray[i].entry = &entry;
    }

    // pass 3
    // handle data that occurs in both arrays
    
    /* 第 3 次遍历
     * 处理同时出现在两个数组中的数据 */
    for (NSInteger i = 0; i < newCount; i++) {
        PDListEntry *entry = newResultsArray[i].entry;

        // grab and pop the top original index. if the item was inserted this will be NSNotFound
        NSCAssert(!entry->oldIndexes.empty(), @"Old indexes is empty while iterating new item %li. Should have NSNotFound", (long)i);
        
        // 在第 2 次遍历中，因为是降序遍历，所以索引值（index）按照从大到小的顺序入栈，这里获取到的 `originalIndex` 则是从小到大出栈
        const NSInteger originalIndex = entry->oldIndexes.top();
        entry->oldIndexes.pop();

        // 更新 `updated` 标记
        if (originalIndex < oldCount) {
            const id<PDListDiffable> n = newArray[i];
            const id<PDListDiffable> o = oldArray[originalIndex];
            switch (option) {
                case PDListDiffPointerPersonality:
                    // flag the entry as updated if the pointers are not the same
                    // 指针 diff
                    if (n != o) {
                        entry->updated = YES;
                    }
                    break;
                case PDListDiffEquality:
                    // use -[PDListDiffable isEqualToDiffableObject:] between both version of data to see if anything has changed
                    // skip the equality check if both indexes point to the same object
                    // 协议方法 diff
                    if (n != o && ![n isEqualToDiffableObject:o]) {
                        entry->updated = YES;
                    }
                    break;
            }
        }
        
        // 该元素在旧数组中存在 && 新数组中存在（新数组中出现次数大于 0）&& 旧数组中存在（旧数组中出现次数大于 0）
        if (originalIndex != NSNotFound
            && entry->newCounter > 0
            && entry->oldCounter > 0) {
            // if an item occurs in the new and old array, it is unique
            // assign the index of new and old records to the opposite index (reverse lookup)
            // 如果一项出现在新旧数组中，则它是唯一的
            // 将新旧记录的索引分配给相反的索引（反向查找）
            // 交换新旧数组中的索引
            
            /*
            PDListEntry *entry = newResultsArray[i].entry;
            const NSInteger originalIndex = entry->oldIndexes.top();
             */
            newResultsArray[i].index = originalIndex;
            oldResultsArray[originalIndex].index = i;
        }
    }

    // storage for final NSIndexPaths or indexes
    // 存储最终的 NSIndexPath 或 index
    id mInserts, mMoves, mUpdates, mDeletes;
    if (returnIndexPaths) {
        NSCAssert(NO, @"Unimplemented logic!");
    } else {
        mInserts = [NSMutableIndexSet new];
        mMoves = [NSMutableArray<PDListMoveIndex *> new];
        mUpdates = [NSMutableIndexSet new];
        mDeletes = [NSMutableIndexSet new];
    }

    // track offsets from deleted items to calculate where items have moved
    // 采集已删除项目的偏移量，以计算 item 已移动的位置
    vector<NSInteger> deleteOffsets(oldCount), insertOffsets(newCount);
    NSInteger runningOffset = 0;

    // iterate old array records checking for deletes
    // incremement offset for each delete
    
    // 第 4 次遍历
    // 迭代旧数组记录检查删除
    // 每次删除增量偏移量
    for (NSInteger i = 0; i < oldCount; i++) {
        deleteOffsets[i] = runningOffset;
        const PDListRecord record = oldResultsArray[i];
        // if the record index in the new array doesn't exist, its a delete
        
        // 如果新数组中的记录索引不存在，则为 delete
        if (record.index == NSNotFound) {
            addIndexToCollection(returnIndexPaths, mDeletes, fromSection, i);
            // TODO: 偏移量计算规则 ???
            // 计算新数组与旧数组中要删除的数量
            runningOffset++;
        }

        addIndexToMap(returnIndexPaths, fromSection, i, oldArray[i], oldMap);
    }

    // reset and track offsets from inserted items to calculate where items have moved
    
    // 第 5 次遍历
    // 遍历新数组，重置和采集插入（新增）item 的偏移量，以计算 item 移动的位置
    runningOffset = 0;

    for (NSInteger i = 0; i < newCount; i++) {
        insertOffsets[i] = runningOffset;
        const PDListRecord record = newResultsArray[i];
        const NSInteger oldIndex = record.index;
        // add to inserts if the opposing index is NSNotFound
        
        // 旧数组中不存在该 item（但新数组中存在），则表示要插入该 item
        if (record.index == NSNotFound) {
            addIndexToCollection(returnIndexPaths, mInserts, toSection, i);
            runningOffset++;
        } else {
            // note that an entry can be updated /and/ moved
            // 注意：entry 可能被更新、移动
            if (record.entry->updated) {
                addIndexToCollection(returnIndexPaths, mUpdates, fromSection, oldIndex);
            }

            // calculate the offset and determine if there was a move
            // if the indexes match, ignore the index
            
            // 计算偏移量并确定是否有移动
            // 如果索引匹配，则忽略索引
            const NSInteger insertOffset = insertOffsets[i];
            const NSInteger deleteOffset = deleteOffsets[oldIndex];
            if ((oldIndex - deleteOffset + insertOffset) != i) {
                id move;
                if (returnIndexPaths) {
                    NSCAssert(NO, @"Unimplemented logic!");
                } else {
                    move = [[PDListMoveIndex alloc] initWithFrom:oldIndex to:i];
                }
                [mMoves addObject:move];
            }
        }

        addIndexToMap(returnIndexPaths, toSection, i, newArray[i], newMap);
    }

    NSCAssert((oldCount + [mInserts count] - [mDeletes count]) == newCount,
              @"Sanity check failed applying %lu inserts and %lu deletes to old count %li equaling new count %li",
              (unsigned long)[mInserts count], (unsigned long)[mDeletes count], (long)oldCount, (long)newCount);

    if (returnIndexPaths) {
        NSCAssert(NO, @"Unimplemented logic!");
        return nil;
    } else {
        return [[PDListIndexSetResult alloc] initWithInserts:mInserts
                                                     deletes:mDeletes
                                                     updates:mUpdates
                                                       moves:mMoves
                                                 oldIndexMap:oldMap
                                                 newIndexMap:newMap];
    }
}

PDListIndexSetResult *PDListDiff(NSArray<id<PDListDiffable> > *oldArray,
                                 NSArray<id<PDListDiffable>> *newArray,
                                 PDListDiffOption option) {
    return PDListDiffing(NO, 0, 0, oldArray, newArray, option);
}
