//
//  PDListTableContext.h
//  PDListKit
//
//  Created by liang on 2021/4/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PDListTableContext <NSObject>

@property (readonly, nullable) UIViewController *viewController;
@property (readonly) UITableView *tableView;

- (__kindof UITableViewCell *)dequeueReusableCellWithStyle:(UITableViewCellStyle)style forClass:(Class)aClass;
- (__kindof UITableViewHeaderFooterView *)dequeueReusableHeaderFooterViewForClass:(Class)aClass;

- (__kindof UITableViewCell *)cellForRowAtIndex:(NSInteger)index sectionController:(PDListSectionController *)sectionController;
- (void)performBatchUpdates:(void (^)(void))updates completion:(void (^ _Nullable)(BOOL))completion;

@end

NS_ASSUME_NONNULL_END
