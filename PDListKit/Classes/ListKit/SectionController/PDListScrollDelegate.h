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

/**
 Tells the delegate that the section controller was scrolled on screen.

 @param listAdapter The list adapter whose collection view was scrolled.
 @param sectionController The visible section controller that was scrolled.
 */
- (void)listAdapter:(PDListAdapter *)listAdapter didScrollSectionController:(PDListSectionController *)sectionController;

/**
 Tells the delegate that the section controller will be dragged on screen.

 @param listAdapter The list adapter whose collection view will drag.
 @param sectionController The visible section controller that will drag.
 */
- (void)listAdapter:(PDListAdapter *)listAdapter willBeginDraggingSectionController:(PDListSectionController *)sectionController;

/**
 Tells the delegate that the section controller did end dragging on screen.

 @param listAdapter The list adapter whose collection view ended dragging.
 @param sectionController The visible section controller that ended dragging.
 @param decelerate 'Yes' if the scrolling movement will continue, but decelerate, after a touch-up gesture during a
 dragging operation. If the value is 'No', scrolling stops immediately upon touch-up.
 */
- (void)listAdapter:(PDListAdapter *)listAdapter didEndDraggingSectionController:(PDListSectionController *)sectionController willDecelerate:(BOOL)decelerate;

@optional

/**
 Tells the delegate that the section controller did end decelerating on screen.

 @param listAdapter The list adapter whose collection view ended decelerating.
 @param sectionController The visible section controller that ended decelerating.

 @note This method is `@optional` until the next breaking-change release.
 */
- (void)listAdapter:(PDListAdapter *)listAdapter didEndDeceleratingSectionController:(PDListSectionController *)sectionController;

@end

NS_ASSUME_NONNULL_END
