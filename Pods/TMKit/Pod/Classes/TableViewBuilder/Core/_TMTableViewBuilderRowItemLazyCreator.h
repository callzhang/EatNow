//
//  TMTableViewBuilderRowItemLazyCreator.h
//  Pods
//
//  Created by Zitao Xiong on 7/9/15.
//
//

#import <Foundation/Foundation.h>

@interface _TMTableViewBuilderRowItemLazyCreator : NSObject <NSCopying>
@property (nonatomic, copy) void (^didCreateRowItemBlock)(id rowItem, id managedObject);
@property (nonatomic, copy) Class rowItemClass;

- (id)createRowItemForManagedObject:(id)managedObject;
@end
