//
//  NSArray+PDListDiff.m
//  PDListKit
//
//  Created by liang on 2021/4/2.
//

#import "NSArray+PDListDiff.h"
#import "PDListDiffable.h"

@implementation NSArray (PDListDiff)

NSArray *PDListObjectsWithDuplicateIdentifiersRemoved(NSArray<id<PDListDiffable>> *objects) {
    if (!objects) { return nil; }
    
    NSMapTable *identifierMap = [NSMapTable strongToStrongObjectsMapTable];
    NSMutableArray *uniqueObjects = [NSMutableArray array];
    
    for (id<PDListDiffable> object in objects) {
        id diffIdentifier = ([object respondsToSelector:@selector(diffIdentifier)] ?
                             [object diffIdentifier] : @(object.hash));
        id previousObject = [identifierMap objectForKey:diffIdentifier];
        if (diffIdentifier != nil
            && previousObject == nil) {
            [identifierMap setObject:object forKey:diffIdentifier];
            [uniqueObjects addObject:object];
        } else {
            NSLog(@"Duplicate identifier %@ for object %@ with object %@", diffIdentifier, object, previousObject);
        }
    }
    
    return uniqueObjects;
}

@end
