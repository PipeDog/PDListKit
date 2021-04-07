//
//  PDListUpdater.h
//  PDListKit
//
//  Created by liang on 2021/4/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PDListUpdater <NSObject>

- (void)reloadData;
- (void)reloadSections:(NSIndexSet *)sections;

@end

NS_ASSUME_NONNULL_END
