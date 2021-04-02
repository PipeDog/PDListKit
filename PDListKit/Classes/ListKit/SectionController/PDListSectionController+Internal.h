//
//  PDListSectionController+Internal.h
//  PDList
//
//  Created by liang on 2019/12/26.
//  Copyright © 2019 PipeDog. All rights reserved.
//

#import "PDListSectionController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDListSectionController ()

@property (nonatomic, assign) NSInteger section;
@property (nonatomic, weak) id<PDListUpdater> updater;
@property (nonatomic, weak) id<PDListTableContext> tableContext;

@end

NS_ASSUME_NONNULL_END
