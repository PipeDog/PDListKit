//
//  PDListSectionMap.m
//  PDListKit
//
//  Created by liang on 2021/4/6.
//

#import "PDListSectionMap.h"
#import "PDListSectionController+Internal.h"

@interface PDListSectionMap ()

@property (nonatomic, strong) NSMapTable<id, PDListSectionController *> *objectToSectionControllerMap;
@property (nonatomic, strong) NSMapTable<PDListSectionController *, NSNumber *> *sectionControllerToSectionMap;
@property (nonatomic, strong) NSMutableArray *mObjects;

@end

@implementation PDListSectionMap

- (instancetype)initWithMapTable:(NSMapTable *)mapTable {
    self = [super init];
    if (self) {
        if (!mapTable) {
            NSPointerFunctions *keyFunctions = [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsObjectPersonality];
            NSPointerFunctions *valueFunctions = [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsStrongMemory];
            mapTable = [[NSMapTable alloc] initWithKeyPointerFunctions:keyFunctions valuePointerFunctions:valueFunctions capacity:0];
        }
        
        _objectToSectionControllerMap = [mapTable copy];
        
        NSPointerFunctionsOptions keyOptions = NSMapTableStrongMemory | NSMapTableObjectPointerPersonality;
        NSPointerFunctionsOptions valueOptions = NSMapTableStrongMemory;
        _sectionControllerToSectionMap = [[NSMapTable alloc] initWithKeyOptions:keyOptions
                                                                   valueOptions:valueOptions
                                                                       capacity:0];
        _mObjects = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Public Methods
- (NSArray *)objects {
    return [self.mObjects copy];
}

- (PDListSectionController *)sectionControllerForSection:(NSInteger)section {
    id object = [self objectForSection:section];
    return [self.objectToSectionControllerMap objectForKey:object];
}

- (id)objectForSection:(NSInteger)section {
    NSArray *objects = self.mObjects;
    if (section < objects.count) {
        return objects[section];
    } else {
        return nil;
    }
}

- (id)sectionControllerForObject:(id)object {
    return [self.objectToSectionControllerMap objectForKey:object];
}

- (NSInteger)sectionForSectionController:(PDListSectionController *)sectionController {
    NSNumber *index = [self.sectionControllerToSectionMap objectForKey:sectionController];
    return index != nil ? [index integerValue] : NSNotFound;
}

- (NSInteger)sectionForObject:(id)object {
    id sectionController = [self sectionControllerForObject:object];
    if (sectionController == nil) {
        return NSNotFound;
    } else {
        return [self sectionForSectionController:sectionController];
    }
}

- (void)reset {
    [self enumerateUsingBlock:^(id  _Nonnull object, PDListSectionController * _Nonnull sectionController, NSInteger section, BOOL * _Nonnull stop) {
        sectionController.section = NSNotFound;
        sectionController.isFirstSection = NO;
        sectionController.isLastSection = NO;
    }];

    [self.sectionControllerToSectionMap removeAllObjects];
    [self.objectToSectionControllerMap removeAllObjects];
}

- (void)updateObject:(id)object {
    const NSInteger section = [self sectionForObject:object];
    id sectionController = [self sectionControllerForObject:object];
    [self.sectionControllerToSectionMap setObject:@(section) forKey:sectionController];
    [self.objectToSectionControllerMap setObject:sectionController forKey:object];
    self.mObjects[section] = object;
}

- (void)updateWithObjects:(NSArray<id<NSObject>> *)objects
       sectionControllers:(NSArray<PDListSectionController *> *)sectionControllers {
    [self reset];

    self.mObjects = [objects mutableCopy];

    // id firstObject = objects.firstObject;
    // id lastObject = objects.lastObject;

    [objects enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        PDListSectionController *sectionController = sectionControllers[idx];

        // set the index of the list for easy reverse lookup
        [self.sectionControllerToSectionMap setObject:@(idx) forKey:sectionController];
        [self.objectToSectionControllerMap setObject:sectionController forKey:object];

        // sectionController.isFirstSection = (object == firstObject);
        // sectionController.isLastSection = (object == lastObject);
        // sectionController.section = (NSInteger)idx;
    }];
}

- (void)enumerateUsingBlock:(void (^)(id _Nonnull, PDListSectionController * _Nonnull, NSInteger, BOOL * _Nonnull))block {
    BOOL stop = NO;
    NSArray *objects = self.objects;
    
    for (NSInteger section = 0; section < objects.count; section++) {
        id object = objects[section];
        PDListSectionController *sectionController = [self sectionControllerForObject:object];
        block(object, sectionController, section, &stop);
        if (stop) { break; }
    }
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone {
    PDListSectionMap *copy = [[PDListSectionMap allocWithZone:zone] initWithMapTable:self.objectToSectionControllerMap];
    if (copy != nil) {
        copy->_sectionControllerToSectionMap = [self.sectionControllerToSectionMap copy];
        copy->_mObjects = [self.mObjects mutableCopy];
    }
    return copy;
}

@end
