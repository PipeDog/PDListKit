//
//  PDListSectionMap.h
//  PDListKit
//
//  Created by liang on 2021/4/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PDListSectionController;

@interface PDListSectionMap : NSObject <NSCopying>

@property (nonatomic, copy, readonly) NSArray *objects;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithMapTable:(NSMapTable * _Nullable)mapTable NS_DESIGNATED_INITIALIZER;

- (nullable PDListSectionController *)sectionControllerForSection:(NSInteger)section;
- (nullable id)objectForSection:(NSInteger)section;
- (nullable id)sectionControllerForObject:(id)object;
- (NSInteger)sectionForSectionController:(PDListSectionController *)sectionController;
- (NSInteger)sectionForObject:(id)object;

- (void)reset;

- (void)updateObject:(id)object;
- (void)updateWithObjects:(NSArray <id <NSObject>> *)objects
       sectionControllers:(NSArray<PDListSectionController *> *)sectionControllers;

- (void)enumerateUsingBlock:(void (^)(id object,
                                      PDListSectionController *sectionController,
                                      NSInteger section,
                                      BOOL *stop))block;

@end

NS_ASSUME_NONNULL_END
