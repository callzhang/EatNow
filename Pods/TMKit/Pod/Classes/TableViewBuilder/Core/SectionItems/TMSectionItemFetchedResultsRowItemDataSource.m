//
//  TMSectionItemFetchedResultsRowDataSource.m
//  Pods
//
//  Created by Zitao Xiong on 6/2/15.
//
//

#import "TMSectionItemFetchedResultsRowItemDataSource.h"
#import "TMRowItem.h"
#import "TMSectionItem.h"
#import "TMRowItem+Protected.h"
#import "TMTableViewBuilder.h"
#import "TMSectionItem+Protected.h"
#import "TMLog.h"

@import CoreData;

@interface TMSectionItemFetchedResultsRowItemDataSource()<NSFetchedResultsControllerDelegate>
// Declare some collection properties to hold the various updates we might get from the NSFetchedResultsControllerDelegate
@property (nonatomic, strong) NSMutableIndexSet *deletedSectionIndexes;
@property (nonatomic, strong) NSMutableIndexSet *deletedRowIndexes;
@property (nonatomic, strong) NSMutableIndexSet *insertedRowIndexes;
@property (nonatomic, strong) NSMutableIndexSet *updatedRowIndexes;
@end

@implementation TMSectionItemFetchedResultsRowItemDataSource
@synthesize sectionItem = _sectionItem;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize delegate = _delegate;

- (NSUInteger)countOfRowItems {
    return [self.sectionInfo numberOfObjects];
}

- (id)objectInRowItemsAtIndex:(NSUInteger)idx {
    NSIndexPath *indexPath = nil;
    if (self.sectionItem.tableViewBuilder.managedType == TMTableViewBuilderManagedTypeArray) {
        indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
    }
    else if (self.sectionItem.tableViewBuilder.managedType == TMTableViewBuilderManagedTypeFetchedResultsController) {
        indexPath = [NSIndexPath indexPathForRow:idx inSection:self.sectionItem.section];
    }
    else {
        NSAssert(NO, @"not handle managed type for tableviewBuilder");
    }
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    TMRowItem *rowItem = [super objectInRowItemsAtIndex:idx];
    
    if ([rowItem isKindOfClass:[TMRowItem class]]) {
        rowItem.managedObject = managedObject;
    }
    else if (rowItem == (id)[NSNull null]) {
        rowItem = [[self.sectionItem rowItemLazyCreator] createRowItemForManagedObject:managedObject];
        [super replaceObjectInRowItemsAtIndex:idx withObject:rowItem];
        if (self.sectionItem.rowItemLazyCreator.didCreateRowItemBlock) {
            self.sectionItem.rowItemLazyCreator.didCreateRowItemBlock(rowItem, managedObject);
        }
    }
    
    return rowItem;
}

- (CGFloat)estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (id<NSFetchedResultsSectionInfo>)sectionInfo {
    if (self.sectionItem.tableViewBuilder.managedType == TMTableViewBuilderManagedTypeFetchedResultsController) {
        id<NSFetchedResultsSectionInfo> section = [self.fetchedResultsController.sections objectAtIndex:self.sectionItem.section];
        return section;
    }
    else if (self.sectionItem.tableViewBuilder.managedType == TMTableViewBuilderManagedTypeArray){
        NSAssert(!self.fetchedResultsController.sectionNameKeyPath, @"sectionKeyPath is not nil, don't know which section to return");
        id<NSFetchedResultsSectionInfo> section = [self.fetchedResultsController.sections objectAtIndex:0];
        return section;
    }
    else {
        NSAssert(NO, @"not handle managed type for tableviewBuilder");
        return nil;
    }
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController {
    _fetchedResultsController = fetchedResultsController;
    
    //TODO: this require sectionItem being added into tableview builder before
    //setting fetchresultscontroller. need to work even after
    if (self.sectionItem.tableViewBuilder.managedType == TMTableViewBuilderManagedTypeArray) {
        _fetchedResultsController.delegate = self;
    }
}

- (NSFetchedResultsController *)fetchedResultsController {
    return _fetchedResultsController;
}

- (void)fillRowItemWillNullValue {
    for (NSUInteger i = 0; i < [self.sectionInfo numberOfObjects]; i ++) {
        [self addRowItem:(id)[NSNull null]];
    }
}

- (BOOL)performFetch:(NSError **)error {
    __block BOOL success = NO;
    __block NSError *tmpError;
    [self.fetchedResultsController.managedObjectContext performBlockAndWait:^{
        success  = [self.fetchedResultsController performFetch:&tmpError];
        if (success) {
            [self removeAllRowItems];
            [self insertNullRowAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.fetchedResultsController.fetchedObjects.count)]];
        }
    }];
    
    if (!success) {
        if (error != NULL) {
            *error = tmpError;
        }
    }
    
    DDLogInfo(@"Section Fetch Finished: SUCCESS:(%@), Error: (%@)", success ? @"YES":@"NO", tmpError);
    NSAssert(self.fetchedResultsController.sections.count <= 1, @"not support multiple section");
    return success;
}

- (void)insertNullRowAtIndexes:(NSIndexSet *)indexSet {
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [self insertObject:(id)[NSNull null] inRowItemsAtIndex:idx];
    }];
}

- (NSArray *)filterRowItemsUsingPredicate:(NSPredicate *)predicate {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You can't call %@ when section item is backed by NSFetchedResultsController", NSStringFromSelector(_cmd)] userInfo:nil];
}

#pragma mark - NSFetchedResultControllerDelegate
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    //note, indexPath's section can not be used!!
    if (type == NSFetchedResultsChangeInsert) {
        [self.insertedRowIndexes addIndex:newIndexPath.row];
        /**
         *  if shouldResponsedToFetchedResutlsControllerDelegate is false. NSFetchedResultsController
         *  will only insert row at index 0. because numberOfRows return 0. so we need to insert rows here.
         *  the insertedRowIndexes is not valid anymore.
         */
        if (![self.sectionItem shouldResponsedToFetchedResutlsControllerDelegate]) {
            [self insertObject:(id)[NSNull null] inRowItemsAtIndex:newIndexPath.row];
        }
    }
    else if (type == NSFetchedResultsChangeDelete) {
        if ([self.deletedSectionIndexes containsIndex:self.sectionItem.section]) {
            // If we've already been told that we're deleting a section for this deleted row we skip it since it will handled by the section deletion.
            return;
        }
        
        //not tested
        if (![self.sectionItem shouldResponsedToFetchedResutlsControllerDelegate]) {
            [self removeObjectFromRowItemsAtIndex:indexPath.row];
        }
        
        [self.deletedRowIndexes addIndex:indexPath.row];
    }
    else if (type == NSFetchedResultsChangeMove) {
        [self.insertedRowIndexes addIndex:newIndexPath.row];
        [self.deletedRowIndexes addIndex:indexPath.row];
    }
    else if (type == NSFetchedResultsChangeUpdate) {
        [self.updatedRowIndexes addIndex:indexPath.row];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            NSAssert(false, @"insert is not supported");
            break;
        case NSFetchedResultsChangeDelete: {
            NSAssert(sectionIndex == self.sectionItem.section, @"section index not match, can't delete section other than self");
            [self.deletedSectionIndexes addIndex:self.sectionItem.section];
            [self.deletedRowIndexes removeAllIndexes];
            break;
        }
        default:
            ; // Shouldn't have a default
            break;
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.sectionItem.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSInteger sectionIndex = self.sectionItem.section;
    
    void (^cleanupBlock)() = ^{
        self.insertedRowIndexes = nil;
        self.deletedRowIndexes = nil;
        self.deletedSectionIndexes = nil;
        self.updatedRowIndexes = nil;
    };
    
    if (self.deletedSectionIndexes.count > 0) {
        [self.sectionItem.tableView deleteSections:self.deletedSectionIndexes withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.sectionItem removeFromTableViewBuilder];
        [self.sectionItem.tableView endUpdates];
        cleanupBlock();
        return;
    }
    
    NSMutableArray *deletedRowIndexPaths = [NSMutableArray array];
    [self.deletedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [deletedRowIndexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:sectionIndex]];
    }];
    
    NSMutableArray *insertedRowIndexPaths = [NSMutableArray array];
    NSMutableArray *insertedRowItems = [NSMutableArray array];
    [self.insertedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:sectionIndex]];
        [insertedRowItems addObject:[NSNull null]];
    }];
    
    NSMutableArray *updatedRowIndexPaths = [NSMutableArray array];
    [self.updatedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [updatedRowIndexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:sectionIndex]];
        TMRowItem *rowItem = [self objectInRowItemsAtIndex:idx];
        [rowItem reload];
    }];
    
    if ([self.sectionItem shouldResponsedToFetchedResutlsControllerDelegate]) {
        
        [self.sectionItem removeRowItemsAtIndexes:self.deletedRowIndexes];
        [self.sectionItem.tableView deleteRowsAtIndexPaths:deletedRowIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        
        [self.sectionItem insertRowItems:insertedRowItems atIndexes:self.insertedRowIndexes];
        [self.sectionItem.tableView insertRowsAtIndexPaths:insertedRowIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        
        [self.sectionItem.tableView reloadRowsAtIndexPaths:updatedRowIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self.sectionItem.tableView endUpdates];
    
    [self.sectionItem controllerDidChangeContent:controller];
    
    cleanupBlock();
}

/**
 * Lazily instantiate these collections.
 */

- (NSMutableIndexSet *)deletedSectionIndexes {
    if (!_deletedSectionIndexes) {
        _deletedSectionIndexes = [[NSMutableIndexSet alloc] init];
    }
    return _deletedSectionIndexes;
}

- (NSMutableIndexSet *)deletedRowIndexes {
    if (!_deletedRowIndexes) {
        _deletedRowIndexes = [[NSMutableIndexSet alloc] init];
    }
    return _deletedRowIndexes;
}

- (NSMutableIndexSet *)insertedRowIndexes {
    if (!_insertedRowIndexes) {
        _insertedRowIndexes = [[NSMutableIndexSet alloc] init];
    }
    return _insertedRowIndexes;
}

- (NSMutableIndexSet *)updatedRowIndexes {
    if (!_updatedRowIndexes) {
        _updatedRowIndexes = [[NSMutableIndexSet alloc] init];
    }
    return _updatedRowIndexes;
}
@end
