//
//  PDListAdapter.h
//  PDList
//
//  Created by liang on 2018/3/20.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDListDiffable.h"
#import "PDListUpdater.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PDListDiffable;
@class PDListAdapter;
@class PDListSectionController;

@protocol PDListAdapterDataSource <NSObject>

- (NSArray<id<PDListDiffable>> *)objectsForListAdapter:(PDListAdapter *)listAdapter;
- (PDListSectionController *)listAdapter:(PDListAdapter *)listAdapter sectionControllerForObject:(id<PDListDiffable>)object;

@optional
- (UIView * _Nullable)emptyViewForListAdapter:(PDListAdapter *)listAdapter;

@end

@interface PDListAdapter : NSObject

@property (nonatomic, weak) id<PDListAdapterDataSource> dataSource;
@property (nonatomic, weak, nullable) id<UIScrollViewDelegate> scrollDelegate;

@property (nonatomic, weak, readonly) UITableView *tableView;
@property (nonatomic, weak) UIViewController *viewController;
@property (readonly) NSArray<PDListSectionController *> *visibleSectionControllers;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithTableView:(UITableView *)tableView NS_DESIGNATED_INITIALIZER;

- (void)reloadData;
- (void)reloadData:(PDListUpdateType)reloadType;

@end

NS_ASSUME_NONNULL_END
