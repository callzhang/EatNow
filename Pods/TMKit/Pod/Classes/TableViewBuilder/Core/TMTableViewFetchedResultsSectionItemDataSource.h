//
//  TMTableViewFetchedResultsRowItemDataSource.h
//  Pods
//
//  Created by Zitao Xiong on 6/1/15.
//
//

#import <Foundation/Foundation.h>
#import "TMTableViewArraySectionItemDataSource.h"
#import "_TMTableViewBuilderRowItemLazyCreator.h"
@import CoreData;

@interface TMTableViewFetchedResultsSectionItemDataSource : TMTableViewArraySectionItemDataSource
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, copy) _TMTableViewBuilderRowItemLazyCreator *rowItemLazyCreator;

- (TMSectionItem *)insertSectionItemForFetchedResultsAtIndex:(NSUInteger)index;
- (void)insertSectionItemAtIndexes:(NSIndexSet *)indexes;
- (void)insertSectionItemWithNullRowAtIndexes:(NSIndexSet *)indexSet;
- (void)reloadAllSectionWithNullRowItwm;
- (BOOL)performFetch:(NSError **)error;

- (void)removeRowAtIndexPaths:(NSArray *)indexPaths;
- (void)insertNullRowAtIndexPaths:(NSArray *)indexPaths;
- (void)reloadRowAtIndexPaths:(NSArray *)indexPaths;
@end
