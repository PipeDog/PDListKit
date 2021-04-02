//
//  PDListMoveIndex.m
//  PDListKit
//
//  Created by liang on 2021/4/2.
//

#import "PDListMoveIndex.h"

@implementation PDListMoveIndex

- (instancetype)initWithFrom:(NSInteger)from to:(NSInteger)to {
    self = [super init];
    if (self) {
        _from = from;
        _to = to;
    }
    return self;
}

- (NSUInteger)hash {
    return _from ^ _to;
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    }
    if ([object isKindOfClass:[PDListMoveIndex class]]) {
        const NSInteger f1 = self.from, f2 = [object from];
        const NSInteger t1 = self.to, t2 = [object to];
        return f1 == f2 && t1 == t2;
    }
    return NO;
}

- (NSComparisonResult)compare:(id)object {
    const NSInteger right = [object from];
    const NSInteger left = [self from];
    if (left == right) {
        return NSOrderedSame;
    } else if (left < right) {
        return NSOrderedAscending;
    } else {
        return NSOrderedDescending;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p; from: %li; to: %li;>", NSStringFromClass(self.class), self, (long)self.from, (long)self.to];
}

@end
