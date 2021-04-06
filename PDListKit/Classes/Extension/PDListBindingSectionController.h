//
//  PDListBindingSectionController.h
//  PDListKit
//
//  Created by liang on 2021/3/26.
//

#import <PDListKit/PDListKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PDListBindingSectionController;

@protocol PDListDiffable;
@protocol PDListBindable;

@protocol PDListBindingSectionControllerDataSource <NSObject>

- (NSArray<id<PDListDiffable>> *)sectionController:(PDListBindingSectionController *)sectionController
                               viewModelsForObject:(id)object;

- (UITableViewCell<PDListBindable> *)sectionController:(PDListBindingSectionController *)sectionController
                                      cellForViewModel:(id<PDListDiffable>)viewModel
                                               atIndex:(NSInteger)index;

- (CGFloat)sectionController:(PDListBindingSectionController *)sectionController
          heightForViewModel:(id<PDListDiffable>)viewModel
                     atIndex:(NSInteger)index;

@end

@protocol PDListBindingSectionControllerSelectionDelegate <NSObject>

- (void)sectionController:(PDListBindingSectionController *)sectionController
     didSelectItemAtIndex:(NSInteger)index
                viewModel:(id<PDListDiffable>)viewModel;

@end

@interface PDListBindingSectionController : PDListSectionController

@property (nonatomic, weak, nullable) id<PDListBindingSectionControllerDataSource> dataSource;
@property (nonatomic, weak, nullable) id<PDListBindingSectionControllerSelectionDelegate> selectionDelegate;

@property (nonatomic, strong, readonly, nullable) id<PDListDiffable> object;
@property (nonatomic, strong, readonly) NSArray<id<PDListDiffable>> *viewModels;

- (void)updateAnimated:(BOOL)animated completion:(void (^ _Nullable)(BOOL updated))completion;
- (void)moveObjectFromIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
