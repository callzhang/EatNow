//
//  TMTableViewBuilderRowItemLazyCreator.m
//  Pods
//
//  Created by Zitao Xiong on 7/9/15.
//
//

#import "_TMTableViewBuilderRowItemLazyCreator.h"
#import "TMRowItem.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

@implementation _TMTableViewBuilderRowItemLazyCreator
- (id)createRowItemForManagedObject:(id)managedObject {
    TMRowItem *rowItem = [[self.rowItemClass alloc] init];
    rowItem.managedObject = managedObject;
//    if (self.didCreateRowItemBlock) {
//        self.didCreateRowItemBlock(rowItem, managedObject);
//    }
    return rowItem;
}

- (id)copyWithZone:(NSZone *)zone {
    _TMTableViewBuilderRowItemLazyCreator *copy = [self.class allocWithZone:zone];
    copy -> _didCreateRowItemBlock = self.didCreateRowItemBlock;
    copy -> _rowItemClass = self.rowItemClass;
    return copy;
}
@end
