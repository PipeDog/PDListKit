//
//  PDListAdapter.m
//  PDList
//
//  Created by liang on 2018/3/20.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "PDListAdapter.h"
#import "PDListAdapter+UITableView.h"
#import "PDListAssert.h"
#import "PDListSectionController.h"
#import "PDListAdapter+Internal.h"
#import "NSArray+PDListDiff.h"
#import "PDListSectionController+Internal.h"
#import "PDListTableContext.h"

@interface PDListAdapter () <PDListTableContext>

@property (nonatomic, strong) UIView *emptyView;

@end

@implementation PDListAdapter

- (void)dealloc {
    [_sectionMap reset];
}

- (instancetype)initWithTableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        PDAssert(tableView, @"Arg `tableView` can not be nil!");

        _tableView = tableView;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _sectionMap = [[PDListSectionMap alloc] initWithMapTable:nil];
    }
    return self;
}

#pragma mark - PDListUpdater Methods
- (void)reloadData {
    [self reloadData:PDListUpdaterebindObject];
}

- (void)reloadData:(PDListReloadType)reloadType {
    PDAssertMainThread();

    BOOL useCachedSectionController = reloadType == PDListUpdaterebindObject;
    NSArray<id<PDListDiffable>> *newObjects = [self.dataSource objectsForListAdapter:self];
    newObjects = PDListObjectsWithDuplicateIdentifiersRemoved(newObjects);
    [self _updateWithObjects:newObjects useCachedSectionController:useCachedSectionController];

    [self.tableView reloadData];
    [self _addEmptyViewIfNecessary];
}

- (void)reloadObjects:(NSArray<id<PDListDiffable>> *)objects {
    PDListSectionMap *map = self.sectionMap;
    NSMutableIndexSet *sections = [NSMutableIndexSet new];

    for (id object in objects) {
        const NSInteger section = [map sectionForObject:object];
        const BOOL notFound = section == NSNotFound;
        if (notFound) {
            continue;
        }
        [sections addIndex:section];

        if (object != [map objectForSection:section]) {
            [map updateObject:object];
            [[map sectionControllerForSection:section] didUpdateToObject:object];
        }
    }

    UICollectionView *collectionView = self.collectionView;
    PDAssert(collectionView != nil, @"Tried to reload the adapter without a collection view");
    [self reloadSections:sections];
}

- (void)reloadSections:(NSIndexSet *)sections {
    [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - PDListTableContext Methods
- (UITableViewCell *)dequeueReusableCellWithStyle:(UITableViewCellStyle)style forClass:(Class)aClass {
    PDAssert(aClass, @"Arg `aClass` can not be nil!");
    
    NSString *cellIdentifier = [NSString stringWithFormat:@"%@^%@", aClass, [NSNumber numberWithInteger:style]];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[aClass alloc] initWithStyle:style reuseIdentifier:cellIdentifier];
    }
    PDAssert(cell, @"Cell can not be null!");
    return cell;
}

- (UITableViewHeaderFooterView *)dequeueReusableHeaderFooterViewForClass:(Class)aClass {
    PDAssert(aClass, @"Arg `aClass` can not be nil!");

    NSString *sectionViewIdentifier = NSStringFromClass(aClass);
    UITableViewHeaderFooterView *sectionView = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:sectionViewIdentifier];
    if (!sectionView) {
        sectionView = [[aClass alloc] initWithReuseIdentifier:sectionViewIdentifier];
    }
    PDAssert(sectionView, @"SectionView can not be null!");
    return sectionView;
}

- (__kindof UITableViewCell *)cellForRowAtIndex:(NSInteger)index sectionController:(PDListSectionController *)sectionController {
    PDAssertMainThread();
    PDParameterAssert(sectionController != nil);

    if (_isDequeuingCell) {
        return nil;
    }

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:sectionController.section];
    if (indexPath != nil && indexPath.section < [self.tableView numberOfSections]) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        return cell;
    }
    return nil;
}

- (void)performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL))completion {
    if (@available(iOS 11, *)) {
        [self.tableView performBatchUpdates:updates completion:completion];
    } else {
        [self.tableView beginUpdates];
        !updates ?: updates();
        [self.tableView endUpdates];
        
        // Callback at the next runLoop, to ensure that the update completes.
        dispatch_async(dispatch_get_main_queue(), ^{
            !completion ?: completion(YES);
        });
    }
}

#pragma mark - Private Methods
- (void)_addEmptyViewIfNecessary {
    if (![self.dataSource respondsToSelector:@selector(emptyViewForListAdapter:)]) return;
    
    if (_emptyView) {
        [_emptyView removeFromSuperview];
        _emptyView = nil;
    }
    
    if (!self.sectionMap.objects.count) {
        self.emptyView = [self.dataSource emptyViewForListAdapter:self];
        self.emptyView.frame = self.tableView.bounds;
        [self.tableView addSubview:self.emptyView];
    }
}

- (void)_updateWithObjects:(NSArray<id<PDListDiffable>> *)newObjects useCachedSectionController:(BOOL)useCachedSectionController {
    NSMutableArray<PDListSectionController *> *sectionControllers = [NSMutableArray array];
    NSInteger sectionCount = newObjects.count;
        
    for (NSInteger section = 0; section < sectionCount; section++) {
        id<PDListDiffable> object = newObjects[section];
        PDListSectionController *sectionController = nil;
        if (useCachedSectionController) {
            sectionController = [self.sectionMap sectionControllerForObject:object];
        }
        if (!sectionController) {
            sectionController = [self.dataSource listAdapter:self sectionControllerForObject:object];
        }
        
        sectionController.updater = self;
        sectionController.tableContext = self;
        sectionController.isFirstSection = (section == 0);
        sectionController.isLastSection = (section == sectionCount - 1);
        sectionController.section = section;
        
        [sectionController didUpdateToObject:object];
        [sectionControllers addObject:sectionController];
    }
    
    [self.sectionMap updateWithObjects:newObjects sectionControllers:sectionControllers];
}

#pragma mark - Getter Methods
- (NSArray<PDListSectionController *> *)visibleSectionControllers {
    PDAssertMainThread();
    
    NSMutableSet *visibleSectionControllers = [NSMutableSet new];
    NSArray<NSIndexPath *> *visibleIndexPaths = [self.tableView.indexPathsForVisibleRows copy];
    
    for (NSIndexPath *indexPath in visibleIndexPaths) {
        PDListSectionController *sectionController = [self.sectionMap sectionControllerForSection:indexPath.section];
        PDAssert(sectionController != nil, @"Section controller nil for cell in section %ld", (long)indexPath.section);
        
        if (sectionController) {
            [visibleSectionControllers addObject:sectionController];
        }
    }
    return [visibleSectionControllers allObjects];
}

@end
