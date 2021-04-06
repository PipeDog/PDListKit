//
//  PDListAdapter+UITableView.m
//  PDList
//
//  Created by liang on 2018/3/21.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "PDListAdapter+UITableView.h"
#import "PDListAdapter+Internal.h"
#import "PDListSectionController.h"
#import "PDListSectionController+Internal.h"

@implementation PDListAdapter (UITableViewDataSource)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionMap.objects.count;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PDListSectionController *sectionController = [self sectionControllerForSection:section];
    return [sectionController numberOfRows];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PDListSectionController *sectionController = [self sectionControllerForSection:indexPath.section];
    _isDequeuingCell = YES;
    UITableViewCell *cell = [sectionController cellForRowAtIndex:indexPath.row];
    _isDequeuingCell = NO;
    return cell;
}
#pragma clang diagnostic pop

- (PDListSectionController *)sectionControllerForSection:(NSInteger)section {
    return [self.sectionMap sectionControllerForSection:section];
}

@end

@implementation PDListAdapter (UITableViewDelegate)

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PDListSectionController *sectionController = [self sectionControllerForSection:indexPath.section];
    return [sectionController heightForRowAtIndex:indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    PDListSectionController *sectionController = [self sectionControllerForSection:section];
    return [sectionController heightForHeader];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    PDListSectionController *sectionController = [self sectionControllerForSection:section];
    return [sectionController heightForFooter];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    PDListSectionController *sectionController = [self sectionControllerForSection:section];
    return [sectionController viewForHeader];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    PDListSectionController *sectionController = [self sectionControllerForSection:section];
    return [sectionController viewForFooter];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    PDListSectionController *sectionController = [self sectionControllerForSection:indexPath.section];
    [sectionController didSelectRowAtIndex:indexPath.row];
}

#pragma mark - Displaying Methods
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    PDListSectionController *sectionController = [self sectionControllerForSection:indexPath.section];
    id<PDListDisplayDelegate> displayDelegate = sectionController.displayDelegate;
    
    if ([displayDelegate respondsToSelector:@selector(listAdapter:willDisplaySectionController:cell:atIndex:)]) {
        [displayDelegate listAdapter:self willDisplaySectionController:sectionController cell:cell atIndex:indexPath.row];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!(indexPath.section < self.sectionMap.objects.count)) { return; }
    
    PDListSectionController *sectionController = [self sectionControllerForSection:indexPath.section];
    id<PDListDisplayDelegate> displayDelegate = sectionController.displayDelegate;
    
    if ([displayDelegate respondsToSelector:@selector(listAdapter:didEndDisplayingSectionController:cell:atIndex:)]) {
        [displayDelegate listAdapter:self didEndDisplayingSectionController:sectionController cell:cell atIndex:indexPath.row];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    PDListSectionController *sectionController = [self sectionControllerForSection:section];
    id<PDListDisplayDelegate> displayDelegate = sectionController.displayDelegate;
    
    if ([displayDelegate respondsToSelector:@selector(listAdapter:willDisplaySectionController:headerView:)]) {
        [displayDelegate listAdapter:self willDisplaySectionController:sectionController headerView:view];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
    if (!(section < self.sectionMap.objects.count)) { return; }
    
    PDListSectionController *sectionController = [self sectionControllerForSection:section];
    id<PDListDisplayDelegate> displayDelegate = sectionController.displayDelegate;
    
    if ([displayDelegate respondsToSelector:@selector(listAdapter:didEndDisplayingSectionController:headerView:)]) {
        [displayDelegate listAdapter:self didEndDisplayingSectionController:sectionController headerView:view];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    PDListSectionController *sectionController = [self sectionControllerForSection:section];
    id<PDListDisplayDelegate> displayDelegate = sectionController.displayDelegate;
    
    if ([displayDelegate respondsToSelector:@selector(listAdapter:willDisplaySectionController:footerView:)]) {
        [displayDelegate listAdapter:self willDisplaySectionController:sectionController footerView:view];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section {
    if (!(section < self.sectionMap.objects.count)) { return; }
    
    PDListSectionController *sectionController = [self sectionControllerForSection:section];
    id<PDListDisplayDelegate> displayDelegate = sectionController.displayDelegate;
    
    if ([displayDelegate respondsToSelector:@selector(listAdapter:didEndDisplayingSectionController:footerView:)]) {
        [displayDelegate listAdapter:self didEndDisplayingSectionController:sectionController footerView:view];
    }
}

#pragma mark - Editing Methods
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    PDListSectionController *sectionController = [self sectionControllerForSection:indexPath.section];
    id<PDListEditingDelegate> editingDelegate = sectionController.editingDelegate;
    return [editingDelegate listAdapter:self canEditSectionController:sectionController atIndex:indexPath.row];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    PDListSectionController *sectionController = [self sectionControllerForSection:indexPath.section];
    id<PDListEditingDelegate> editingDelegate = sectionController.editingDelegate;
    return [editingDelegate listAdapter:self editingStyleForSectionController:sectionController atIndex:indexPath.row];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    PDListSectionController *sectionController = [self sectionControllerForSection:indexPath.section];
    id<PDListEditingDelegate> editingDelegate = sectionController.editingDelegate;
    [editingDelegate listAdapter:self commitEditingStyle:editingStyle forSectionController:sectionController atIndex:indexPath.row];
}

@end

@implementation PDListAdapter (UIScrollViewDelegate)

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    id<UIScrollViewDelegate> scrollViewDelegate = self.scrollDelegate;
    if ([scrollViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [scrollViewDelegate scrollViewDidScroll:scrollView];
    }
    
    NSArray<PDListSectionController *> *visibleSectionControllers = [self visibleSectionControllers];
    for (PDListSectionController *sectionController in visibleSectionControllers) {
        [[sectionController scrollDelegate] listAdapter:self didScrollSectionController:sectionController];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    id<UIScrollViewDelegate> scrollViewDelegate = self.scrollDelegate;
    if ([scrollViewDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [scrollViewDelegate scrollViewWillBeginDragging:scrollView];
    }
    
    NSArray<PDListSectionController *> *visibleSectionControllers = [self visibleSectionControllers];
    for (PDListSectionController *sectionController in visibleSectionControllers) {
        [[sectionController scrollDelegate] listAdapter:self willBeginDraggingSectionController:sectionController];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    id<UIScrollViewDelegate> scrollViewDelegate = self.scrollDelegate;
    if ([scrollViewDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [scrollViewDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    
    NSArray<PDListSectionController *> *visibleSectionControllers = [self visibleSectionControllers];
    for (PDListSectionController *sectionController in visibleSectionControllers) {
        [[sectionController scrollDelegate] listAdapter:self didEndDraggingSectionController:sectionController willDecelerate:decelerate];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    id<UIScrollViewDelegate> scrollViewDelegate = self.scrollDelegate;
    if ([scrollViewDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [scrollViewDelegate scrollViewDidEndDecelerating:scrollView];
    }
    
    NSArray<PDListSectionController *> *visibleSectionControllers = [self visibleSectionControllers];
    for (PDListSectionController *sectionController in visibleSectionControllers) {
        id<PDListScrollDelegate> scrollDelegate = [sectionController scrollDelegate];
        if ([scrollDelegate respondsToSelector:@selector(listAdapter:didEndDeceleratingSectionController:)]) {
            [scrollDelegate listAdapter:self didEndDeceleratingSectionController:sectionController];
        }
    }
}

@end
