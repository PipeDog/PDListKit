//
//  PDListBindable.h
//  PDListKit
//
//  Created by liang on 2021/3/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PDListBindable <NSObject>

- (void)bindViewModel:(id)viewModel;

@end

NS_ASSUME_NONNULL_END
