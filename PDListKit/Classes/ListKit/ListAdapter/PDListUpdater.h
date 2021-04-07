//
//  PDListUpdater.h
//  PDListKit
//
//  Created by liang on 2021/4/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PDListDiffable;
@class PDListSectionController;

typedef NS_ENUM(NSUInteger, PDListReloadType) {
    // 仅对 section controller 进行数据重新绑定，不会重新创建 section controller
    PDListUpdaterebindObject = 0,
    // 重新创建 section controller，并进行数据绑定
    PDListUpdateresetSections = 1,
};

@protocol PDListUpdater <NSObject>

- (void)reloadData;
- (void)reloadData:(PDListReloadType)reloadType;
- (void)reloadSections:(NSIndexSet *)sections;

@end

NS_ASSUME_NONNULL_END
