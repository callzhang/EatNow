//
//  TMTableViewFetchedResultsRowItemDataSource.m
//  Pods
//
//  Created by Zitao Xiong on 6/1/15.
//
//

#import "TMTableViewFetchedResultsSectionItemDataSource.h"
#import "TMSectionItem.h"
#import "TMRowItem.h"
#import "TMSectionItem+Protected.h"
#import "TMLog.h"

@interface TMTableViewFetchedResultsSectionItemDataSource()
@end

@implementation TMTableViewFetchedResultsSectionItemDataSource
@synthesize delegate = _delegate;

- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.fetchedResultsController sectionForSectionIndexTitle:title
                                                              atIndex:index];
}

- (NSArray *)sectionIndexTitles {
    return [self.fetchedResultsController sectionIndexTitles];
}

#pragma mark -
- (BOOL)performFetch:(NSError **)error {
    __block BOOL success = NO;
    __block NSError *tmpError;
    [self.fetchedResultsController.managedObjectContext performBlockAndWait:^{
        success  = [self.fetchedResultsController performFetch:&tmpError];
        
        if (success) {
            [self reloadAllSectionWithNullRowItwm];
        }
    }];
    
    if (!success) {
        if (error != NULL) {
            *error = tmpError;
        }
    }
    
    DDLogWarn(@"fetch guest: [SUCCESS: %@], [ERROR: %@]", @(success), tmpError);
    return success;
}

- (void)reloadAllSectionWithNullRowItwm {
    [self removeAllSectionItems];
    [self insertSectionItemWithNullRowAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.fetchedResultsController.sections.count)]];
}

- (TMSectionItem *)insertSectionItemForFetchedResultsAtIndex:(NSUInteger)index {
    //NOTE: order matters!
    Class sectionClass = [self.delegate sectionItemClassForFetchedResultsControllerManagedType];
    NSParameterAssert([sectionClass isSubclassOfClass:[TMSectionItem class]]);
    TMSectionItem *sectionItem = [sectionClass sectionItemWithType:TMSectionItemTypeFetchedResultsController];
    sectionItem.fetchedResultsController = self.fetchedResultsController;
    sectionItem.rowItemLazyCreator = self.rowItemLazyCreator;
    [self insertObject:sectionItem inSectionItemsAtIndex:index];
    [self.delegate fetchedResultsRowItemDataSource:self didCreatedFetchedResultsSectionItem:sectionItem];
    return sectionItem;
}

- (void)insertSectionItemAtIndexes:(NSIndexSet *)indexes {
    NSUInteger currentIndex = [indexes firstIndex];
    NSUInteger count = [indexes count];
    
    for (NSUInteger i = 0; i < count; i++) {
        [self insertSectionItemForFetchedResultsAtIndex:currentIndex];
        currentIndex = [indexes indexGreaterThanIndex:currentIndex];
    }
}

- (void)insertSectionItemWithNullRowAtIndexes:(NSIndexSet *)indexes {
    NSUInteger currentIndex = [indexes firstIndex];
    NSUInteger count = [indexes count];
    
    for (NSUInteger i = 0; i < count; i++) {
        TMSectionItem *sectionItem = [self insertSectionItemForFetchedResultsAtIndex:currentIndex];
        [[sectionItem fetchedResultsRowDataSource] fillRowItemWillNullValue];
        currentIndex = [indexes indexGreaterThanIndex:currentIndex];
    }
}

- (void)removeRowAtIndexPaths:(NSArray *)indexPaths {
    NSDictionary *groupedIndexPaths = [self indexPathsToIndexSetMapping:indexPaths];
    [groupedIndexPaths enumerateKeysAndObjectsUsingBlock:^(NSNumber *section, NSIndexSet *indexSet, BOOL *stop) {
        TMSectionItem *sectionItem = [self objectInSectionItemsAtIndex:[section integerValue]];
        [sectionItem removeRowItemsAtIndexes:indexSet];
    }];
}

- (void)insertNullRowAtIndexPaths:(NSArray *)indexPaths {
    NSDictionary *groupedIndexPaths = [self indexPathsToIndexSetMapping:indexPaths];
    [groupedIndexPaths enumerateKeysAndObjectsUsingBlock:^(NSNumber *section, NSIndexSet *indexSet, BOOL *stop) {
        TMSectionItem *sectionItem = [self objectInSectionItemsAtIndex:[section integerValue]];
        NSMutableArray *nullRows = [NSMutableArray array];
        [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [nullRows addObject:[NSNull null]];
        }];
        [sectionItem insertRowItems:nullRows atIndexes:indexSet];
    }];
}

- (void)reloadRowAtIndexPaths:(NSArray *)indexPaths {
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        TMSectionItem *sectionItem = [self objectInSectionItemsAtIndex:indexPath.section];
        TMRowItem *rowItem = [sectionItem objectInRowItemsAtIndex:indexPath.row];
        rowItem.managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [rowItem reload];
    }];
}

/**
 *  group indexPaths by section
 *
 */
- (NSDictionary *)indexPathsToIndexSetMapping:(NSArray *)indexPaths {
    NSMutableDictionary *mapping = [NSMutableDictionary dictionary];
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        NSMutableIndexSet *mutableIndexSet = [mapping objectForKey:@(indexPath.section)];
        if (!mutableIndexSet) {
            mutableIndexSet = [NSMutableIndexSet indexSet];
            [mapping setObject:mutableIndexSet forKey:@(indexPath.section)];
        }
        [mutableIndexSet addIndex:indexPath.row];
    }];
    
    return mapping;
}
@end
