//
//  PDListDisplayDelegate.h
//  PDListKit
//
//  Created by liang on 2021/4/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PDListAdapter;
@class PDListSectionController;

@protocol PDListDisplayDelegate <NSObject>

@optional
- (void)listAdapter:(PDListAdapter *)listAdapter willDisplaySectionController:(PDListSectionController *)sectionController cell:(UITableViewCell *)cell atIndex:(NSInteger)index;

- (void)listAdapter:(PDListAdapter *)listAdapter didEndDisplayingSectionController:(PDListSectionController *)sectionController cell:(UITableViewCell *)cell atIndex:(NSInteger)index;

- (void)listAdapter:(PDListAdapter *)listAdapter willDisplaySectionController:(PDListSectionController *)sectionController headerView:(UIView *)view;

- (void)listAdapter:(PDListAdapter *)listAdapter didEndDisplayingSectionController:(PDListSectionController *)sectionController headerView:(UIView *)view;

- (void)listAdapter:(PDListAdapter *)listAdapter willDisplaySectionController:(PDListSectionController *)sectionController footerView:(UIView *)view;

- (void)listAdapter:(PDListAdapter *)listAdapter didEndDisplayingSectionController:(PDListSectionController *)sectionController footerView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
