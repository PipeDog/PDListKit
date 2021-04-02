//
//  PDListBindingSectionController.m
//  PDListKit
//
//  Created by liang on 2021/3/26.
//

#import "PDListBindingSectionController.h"
#import "PDListBindable.h"
#import "NSArray+PDListDiff.h"
#import "PDListDiff.h"
#import "PDListAssert.h"
#import "PDListKitUtil.h"

typedef NS_ENUM(NSInteger, PDListDiffingSectionState) {
    PDListDiffingSectionStateIdle = 0,
    PDListDiffingSectionStateUpdateQueued,
    PDListDiffingSectionStateUpdateApplied
};

@interface PDListBindingSectionController ()

@property (nonatomic, strong, readwrite) NSArray<id<PDListDiffable>> *viewModels;
@property (nonatomic, strong) id object;
@property (nonatomic, assign) PDListDiffingSectionState state;

@end

@implementation PDListBindingSectionController

#pragma mark - Public API
- (void)updateAnimated:(BOOL)animated completion:(void (^)(BOOL))completion {
    PDAssertMainThread();

    if (self.state != PDListDiffingSectionStateIdle) {
        if (completion != nil) {
            completion(NO);
        }
        return;
    }
    self.state = PDListDiffingSectionStateUpdateQueued;

    __block PDListIndexSetResult *result = nil;
    __block NSArray<id<PDListDiffable>> *oldViewModels = nil;
    
    id<PDListTableContext> tableContext = self.tableContext;
    UITableView *tableView = tableContext.tableView;
    
    [self.tableContext performBatchUpdates:^{
        if (self.state != PDListDiffingSectionStateUpdateQueued) {
            return;
        }
        
        oldViewModels = self.viewModels;

        id<PDListDiffable> object = self.object;
        PDAssert(object != nil, @"Expected PDListBindingSectionController object to be non-nil before updating.");
        
        NSArray *newViewModels = [self.dataSource sectionController:self viewModelsForObject:object];
        self.viewModels = PDListObjectsWithDuplicateIdentifiersRemoved(newViewModels);
        
        // Diff viewModels 并获取 diff 结果
        result = PDListDiff(oldViewModels, self.viewModels, PDListDiffEquality);
        
        [result.updates enumerateIndexesUsingBlock:^(NSUInteger oldUpdatedIndex, BOOL *stop) {
            id identifier = [oldViewModels[oldUpdatedIndex] diffIdentifier];
            const NSInteger indexAfterUpdate = [result newIndexForIdentifier:identifier];
            if (indexAfterUpdate != NSNotFound) {
                UITableViewCell<PDListBindable> *cell = [tableContext cellForRowAtIndex:oldUpdatedIndex sectionController:self];
                [cell bindViewModel:self.viewModels[indexAfterUpdate]];
            }
        }];
        
        NSArray<NSIndexPath *> *deleteIndexPaths = PDListConvertIndexPaths(self.section, result.deletes);
        [tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationNone];
        
        NSArray<NSIndexPath *> *insertIndexPaths = PDListConvertIndexPaths(self.section, result.inserts);
        [tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationNone];
                
        for (PDListMoveIndex *move in result.moves) {
            NSIndexPath *fromIndexPath = [NSIndexPath indexPathForRow:move.from inSection:self.section];
            NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:move.to inSection:self.section];
            [tableView moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
        }
        
        self.state = PDListDiffingSectionStateUpdateApplied;
    } completion:^(BOOL finished) {
        self.state = PDListDiffingSectionStateIdle;
        !completion ?: completion(finished);
    }];
}

#pragma mark - PDListSectionController Overrides
- (NSInteger)numberOfItems {
    return self.viewModels.count;
}

- (CGFloat)heightForRowAtIndex:(NSInteger)index {
    return [self.dataSource sectionController:self heightForViewModel:self.viewModels[index] atIndex:index];
}

- (__kindof UITableViewCell *)cellForRowAtIndex:(NSInteger)index {
    id<PDListDiffable> viewModel = self.viewModels[index];
    UITableViewCell<PDListBindable> *cell = [self.dataSource sectionController:self cellForViewModel:viewModel atIndex:index];
    [cell bindViewModel:viewModel];
    return cell;
}

- (void)didUpdateToObject:(id)object {
    id oldObject = self.object;
    self.object = object;

    if (oldObject == nil) {
        NSArray *viewModels = [self.dataSource sectionController:self viewModelsForObject:object];
        self.viewModels = PDListObjectsWithDuplicateIdentifiersRemoved(viewModels);
    } else {
#if IGLK_LOGGING_ENABLED
        if (![oldObject isEqualToDiffableObject:object]) {
            NSLog(@"Warning: Unequal objects %@ and %@ will cause PDListBindingSectionController to reload the entire section",
                    oldObject, object);
        }
#endif
        [self updateAnimated:YES completion:nil];
    }
}

- (void)moveObjectFromIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex {
    NSMutableArray *viewModels = [self.viewModels mutableCopy];
    
    id modelAtSource = [viewModels objectAtIndex:sourceIndex];
    [viewModels removeObjectAtIndex:sourceIndex];
    [viewModels insertObject:modelAtSource atIndex:destinationIndex];
    
    self.viewModels = viewModels;
}

- (void)didSelectItemAtIndex:(NSInteger)index {
    [self.selectionDelegate sectionController:self didSelectItemAtIndex:index viewModel:self.viewModels[index]];
}

@end
