//
//  PDListAdapter+Internal.h
//  PDList
//
//  Created by liang on 2019/12/26.
//  Copyright © 2019 PipeDog. All rights reserved.
//

#import "PDListAdapter.h"
#import "PDListUpdater.h"
#import "PDListSectionMap.h"

NS_ASSUME_NONNULL_BEGIN

@class PDListSectionController;

@interface PDListAdapter () <PDListUpdater> {
    BOOL _isDequeuingCell;
}

@property (nonatomic, strong) PDListSectionMap *sectionMap;

@end

NS_ASSUME_NONNULL_END
