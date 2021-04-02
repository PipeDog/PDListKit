//
//  PDListGenericSectionController.h
//  PDListKit
//
//  Created by liang on 2021/4/2.
//

#import "PDListSectionController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDListGenericSectionController<__covariant ObjectType> : PDListSectionController

@property (nonatomic, strong, nullable, readonly) ObjectType object;

- (void)didUpdateToObject:(id)object NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
