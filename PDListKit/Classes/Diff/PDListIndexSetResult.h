//
//  PDListIndexSetResult.h
//  PDListKit
//
//  Created by liang on 2021/3/26.
//

#import <Foundation/Foundation.h>
#import "PDListMoveIndex.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDListIndexSetResult : NSObject

/**
 The indexes inserted into the new collection.
 */
@property (nonatomic, strong, readonly) NSIndexSet *inserts;

/**
 The indexes deleted from the old collection.
 */
@property (nonatomic, strong, readonly) NSIndexSet *deletes;

/**
 The indexes in the old collection that need updated.
 */
@property (nonatomic, strong, readonly) NSIndexSet *updates;

/**
 The moves from an index in the old collection to an index in the new collection.
 */
@property (nonatomic, copy, readonly) NSArray<PDListMoveIndex *> *moves;

/**
 A Read-only boolean that indicates whether the result has any changes or not.
 `YES` if the result has changes, `NO` otherwise.
 */
@property (nonatomic, assign, readonly) BOOL hasChanges;

/**
 Returns the index of the object with the specified identifier *before* the diff.

 @param identifier The diff identifier of the object.

 @return The index of the object before the diff, or `NSNotFound`.

 @see `-[IGListDiffable diffIdentifier]`.
 */
- (NSInteger)oldIndexForIdentifier:(id<NSObject>)identifier;

/**
 Returns the index of the object with the specified identifier *after* the diff.

 @param identifier The diff identifier of the object.

 @return The index path of the object after the diff, or `NSNotFound`.

 @see `-[IGListDiffable diffIdentifier]`.
 */
- (NSInteger)newIndexForIdentifier:(id<NSObject>)identifier;

/**
 Creates a new result object with operations safe for use in `UITableView` and `UICollectionView` batch updates.
 */
- (PDListIndexSetResult *)resultForBatchUpdates;

/**
 :nodoc:
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 :nodoc:
 */
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
