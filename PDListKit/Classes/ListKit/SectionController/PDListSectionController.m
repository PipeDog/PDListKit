//
//  PDListSectionController.m
//  PDList
//
//  Created by liang on 2018/3/20.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "PDListSectionController.h"
#import "PDListAssert.h"
#import "PDListSectionController+Internal.h"

CGFloat const PDListSectionControllerDefaultCellHeight = 44.f;

@implementation PDListSectionController

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%@ dealloc.", self);
#endif
}

- (void)didUpdateToObject:(id)object {
    PDAssert(NO, @"This method must be override, (%s).", __FUNCTION__);
}

- (NSInteger)numberOfRows {
    PDAssert(NO, @"This method must be override, (%s).", __FUNCTION__);
    return 0;
}

- (UITableViewCell *)cellForRowAtIndex:(NSInteger)index {
    PDAssert(NO, @"This method must be override, (%s).", __FUNCTION__);
    return nil;
}

- (CGFloat)heightForRowAtIndex:(NSInteger)index {
    return PDListSectionControllerDefaultCellHeight;
}

- (CGFloat)heightForHeader {
    return 0.f;
}

- (CGFloat)heightForFooter {
    return 0.f;
}

- (UIView *)viewForHeader {
    return nil;
}

- (UIView *)viewForFooter {
    return nil;
}

- (void)didSelectRowAtIndex:(NSInteger)index {
    
}

@end
