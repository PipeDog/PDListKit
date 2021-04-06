//
//  PDListUpdater.h
//  PDListKit
//
//  Created by liang on 2021/4/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PDListSectionController;

typedef NS_ENUM(NSUInteger, PDListUpdateType) {
    // 仅对 section controller 进行数据重新绑定，不会重新创建 section controller
    PDListUpdateRebindObject = 0,
    // 重新创建 section controller，并进行数据绑定
    PDListUpdateResetSections = 1,
};

@protocol PDListUpdater <NSObject>

- (void)reloadData;
- (void)reloadData:(PDListUpdateType)reloadType;

- (void)performUpdateSectionControllers:(NSArray<PDListSectionController *> *)sectionControllers withRowAnimation:(UITableViewRowAnimation)animation;

@end

NS_ASSUME_NONNULL_END
