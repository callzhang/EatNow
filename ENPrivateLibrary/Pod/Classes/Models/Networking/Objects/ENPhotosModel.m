//
//  ENPhotosModel.m
//  Pods
//
//  Created by Veracruz on 16/3/30.
//
//

#import "ENPhotosModel.h"

@implementation ENPhotosModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

- (void)setItemsWithNSArray:(NSArray *)array {
    NSMutableArray *items = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        ENPhotosItemModel *item = [[ENPhotosItemModel alloc] initWithDictionary:dic error:NULL];
        [items addObject:item];
    }
    self.items = [items copy];
}

@end
