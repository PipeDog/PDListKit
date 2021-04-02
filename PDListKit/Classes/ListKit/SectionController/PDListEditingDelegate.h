//
//  PDListEditingDelegate.h
//  PDListKit
//
//  Created by liang on 2021/4/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PDListAdapter;
@class PDListSectionController;

@protocol PDListEditingDelegate <NSObject>

- (BOOL)listAdapter:(PDListAdapter *)listAdapter canEditSectionController:(PDListSectionController *)sectionController atIndex:(NSInteger)index;

- (UITableViewCellEditingStyle)listAdapter:(PDListAdapter *)listAdapter editingStyleForSectionController:(PDListSectionController *)sectionController atIndex:(NSInteger)index;

- (void)listAdapter:(PDListAdapter *)listAdapter commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forSectionController:(PDListSectionController *)sectionController atIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
