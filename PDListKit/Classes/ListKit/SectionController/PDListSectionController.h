//
//  PDListSectionController.h
//  PDList
//
//  Created by liang on 2018/3/20.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDListScrollDelegate.h"
#import "PDListDisplayDelegate.h"
#import "PDListEditingDelegate.h"
#import "PDListTableContext.h"
#import "PDListUpdater.h"

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN CGFloat const PDListSectionControllerDefaultCellHeight;

@interface PDListSectionController : NSObject

@property (nonatomic, assign, readonly) NSInteger section;
@property (nonatomic, weak, readonly) id<PDListUpdater> updater;
@property (nonatomic, weak, readonly) id<PDListTableContext> tableContext;
@property (nonatomic, weak, nullable) id<PDListScrollDelegate> scrollDelegate;
@property (nonatomic, weak, nullable) id<PDListDisplayDelegate> displayDelegate;
@property (nonatomic, weak, nullable) id<PDListEditingDelegate> editingDelegate;

- (void)didUpdateToObject:(id)object;

- (void)reloadData;

- (NSInteger)numberOfRows;
- (__kindof UITableViewCell *)cellForRowAtIndex:(NSInteger)index;

- (CGFloat)heightForRowAtIndex:(NSInteger)index;
- (CGFloat)heightForHeader;
- (CGFloat)heightForFooter;

- (nullable UIView *)viewForHeader;
- (nullable UIView *)viewForFooter;

- (void)didSelectRowAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
