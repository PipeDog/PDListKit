//
//  PDListScrollDelegate.h
//  PDListKit
//
//  Created by liang on 2021/4/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PDListAdapter;
@class PDListSectionController;

@protocol PDListScrollDelegate <NSObject>

- (void)listAdapter:(PDListAdapter *)listAdapter didScrollSectionController:(PDListSectionController *)sectionController;
- (void)listAdapter:(PDListAdapter *)listAdapter willBeginDraggingSectionController:(PDListSectionController *)sectionController;
- (void)listAdapter:(PDListAdapter *)listAdapter didEndDraggingSectionController:(PDListSectionController *)sectionController willDecelerate:(BOOL)decelerate;

@optional
- (void)listAdapter:(PDListAdapter *)listAdapter didEndDeceleratingSectionController:(PDListSectionController *)sectionController;

@end

NS_ASSUME_NONNULL_END
