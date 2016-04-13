//
//  TMSectionItem.m
//  TMKit
//
//  Created by Zitao Xiong on 3/25/15.
//  Copyright (c) 2015 Nanaimostudio. All rights reserved.
//

#import "TMSectionItem.h"
#import "TMRowItem+Protected.h"
#import "TMTableViewBuilder.h"
#import "TMSectionItem+Protected.h"
#import "EXTKeyPathCoding.h"
#import "TMSectionItemArrayRowItemDataSource.h"
#import "TMSectionItemFetchedResultsRowItemDataSource.h"
#import "TMHelper.h"


@interface TMSectionItem ()<TMSectionItemRowDataSourceDelegate>
//protected
//see "TMSectionItem+Protected.h"
@property (nonatomic, strong) _TMKitClassLookup *classLookup;
@end

@implementation TMSectionItem
- (instancetype)init {
    return [self initWithType:TMSectionItemTypeArray];
}

+ (instancetype)sectionItemWithType:(TMSectionItemType)type {
    id item = [(TMSectionItem *)[self alloc] initWithType:type];
    return item;
}

- (instancetype)initWithType:(TMSectionItemType)type {
    self = [super init];
    if (self) {
        self.type = type;
        if (self.type == TMSectionItemTypeArray) {
            self.rowDataSource = [[TMSectionItemArrayRowItemDataSource alloc] init];
        }
        else if (self.type == TMSectionItemTypeFetchedResultsController) {
            self.rowDataSource = [[TMSectionItemFetchedResultsRowItemDataSource alloc] init];
        }
        self.rowDataSource.delegate = self;
        self.rowDataSource.sectionItem = self;
        self.estimatedHeightForFooter = UITableViewAutomaticDimension;
        self.estimatedHeightForHeader = UITableViewAutomaticDimension;
    }
    return self;
}
#pragma mark - TMSectionItemRowDataSourceDelegate
- (void)didInsertRowItem:(TMRowItem *)object {
    if ([object isKindOfClass:[TMRowItem class]]) {
        object.sectionItem = self;
        [self.tableViewBuilder addReuseIdentifierToRegister:object.reuseIdentifier nibName:object.nibName];
    }
}

- (void)didRemoveRowItem:(TMRowItem *)object {
    
}
#pragma mark - TMRowItem Accessor <KVO>

- (void)addRowItem:(TMRowItem *)rowItem {
    [self.rowDataSource addRowItem:rowItem];
}

- (void)removeFromRowItems:(TMRowItem *)rowItem {
    [self.rowDataSource removeFromRowItems:rowItem];
}

- (void)removeRowItem:(TMRowItem *)aRowItem {
    [self.rowDataSource removeFromRowItems:aRowItem];
}

- (void)removeAllRowItems {
    [self.rowDataSource removeAllRowItems];
}

- (NSUInteger)countOfRowItems {
    return self.rowDataSource.countOfRowItems;
}

- (NSInteger)numberOfRows {
    return self.rowDataSource.countOfRowItems;
}

- (TMRowItem *)objectInRowItemsAtIndex:(NSUInteger)idx {
    return [self.rowDataSource objectInRowItemsAtIndex:idx];
}

- (void)insertObject:(TMRowItem *)rowItem inRowItemsAtIndex:(NSUInteger)idx {
    [self.rowDataSource insertObject:rowItem inRowItemsAtIndex:idx];
}

- (void)insertRowItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes {
    [self.rowDataSource insertRowItems:items atIndexes:indexes];
}

- (void)removeObjectFromRowItemsAtIndex:(NSUInteger)idx {
    [self.rowDataSource removeObjectFromRowItemsAtIndex:idx];
}

- (void)removeRowItemAtIndex:(NSUInteger)index {
    [self.rowDataSource removeObjectFromRowItemsAtIndex:index];
}

- (void)removeRowItemsAtIndexes:(NSIndexSet *)indexes {
    [self.rowDataSource removeRowItemsAtIndexes:indexes];
}

- (void)replaceObjectInRowItemsAtIndex:(NSUInteger)idx withObject:(TMRowItem *)rowItem {
    [self.rowDataSource replaceObjectInRowItemsAtIndex:idx withObject:rowItem];
}

- (void)replaceRowItemsAtIndexes:(NSIndexSet *)indexes withRowItems:(NSArray *)items {
    [self.rowDataSource replaceRowItemsAtIndexes:indexes withRowItems:items];
}

- (TMRowItem *)rowItemAtIndex:(NSUInteger)index {
    return self[index];
}

- (NSUInteger)indexOfRowItem:(TMRowItem *)rowItem {
    return [self.rowDataSource indexOfRowItem:rowItem];
}

- (void)removeFromTableViewBuilder {
    [self.tableViewBuilder removeSectionItem:self];
    self.tableViewBuilder = nil;
}

#pragma mark - Keyed Subscript
- (id)objectAtIndexedSubscript:(NSUInteger)index {
    return [self objectInRowItemsAtIndex:index];
}

- (void)setObject:(TMRowItem *)obj atIndexedSubscript:(NSUInteger)index {
    NSParameterAssert([obj isKindOfClass:[TMRowItem class]]);
    [self insertObject:obj inRowItemsAtIndex:index];
}

#pragma mark - NSFechtedResultsController
- (BOOL)performFetch:(NSError **)error {
    return [[self fetchedResultsRowDataSource] performFetch:error];
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController {
    [self.rowDataSource setFetchedResultsController:fetchedResultsController];
}

- (NSFetchedResultsController *)fetchedResultsController {
    return self.rowDataSource.fetchedResultsController;
}

- (id<NSFetchedResultsSectionInfo>)sectionInfo {
    return self.rowDataSource.sectionInfo;
}

- (TMSectionItemFetchedResultsRowItemDataSource *)fetchedResultsRowDataSource {
    TMSectionItemFetchedResultsRowItemDataSource *fetchResultsRowDataSource = (TMSectionItemFetchedResultsRowItemDataSource *)self.rowDataSource;
    NSParameterAssert([fetchResultsRowDataSource isKindOfClass:[TMSectionItemFetchedResultsRowItemDataSource class]]);
    return fetchResultsRowDataSource;
}

- (void)setDidCreateRowItemBlock:(void (^)(id, id))didCreateRowItemBlock forRowItemClass:(Class)klass {
    self.rowItemLazyCreator = [[_TMTableViewBuilderRowItemLazyCreator alloc] init];
    self.rowItemLazyCreator.rowItemClass = klass;
    self.rowItemLazyCreator.didCreateRowItemBlock = didCreateRowItemBlock;
}

#pragma mark -
- (void)removeFromTableViewAnimated:(BOOL)animated {
    [self.tableViewBuilder removeSectionItem:self];
    if (self.section != NSNotFound) {
        UITableViewRowAnimation animation = animated ? UITableViewRowAnimationFade : UITableViewRowAnimationNone;
        [self.tableViewBuilder.tableView deleteSections:[NSIndexSet indexSetWithIndex:self.section] withRowAnimation:animation];
    }
}

- (void)removeFromTableView {
    [self removeFromTableViewAnimated:NO];
}

#pragma mark -
- (UIView *)headerView {
    return nil;
}

+ (NSString *)cellReuseIdentifierForHeader {
    return nil;
}

+ (NSString *)cellReuseIdentifierForFooter {
    return nil;
}

- (UIView *)viewForHeader {
    NSString *identifier = [[self class] cellReuseIdentifierForHeader];
    UITableViewHeaderFooterView *headerView = [self.tableViewBuilder.tableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
    if (!headerView && identifier) {
        [self.tableViewBuilder.tableView registerClass:NSClassFromString(identifier) forHeaderFooterViewReuseIdentifier:identifier];
        headerView = [self.tableViewBuilder.tableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
    }
    
    if (!headerView.backgroundView && self.backgroundViewForHeader) {
        headerView.backgroundView = self.backgroundViewForHeader;
    }
    
    return headerView;
}

- (UIView *)viewForFooter {
    NSString *identifier = [[self class] cellReuseIdentifierForFooter];
    UITableViewHeaderFooterView *headerView = [self.tableViewBuilder.tableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
    if (!headerView && identifier) {
        [self.tableViewBuilder.tableView registerClass:NSClassFromString(identifier) forHeaderFooterViewReuseIdentifier:identifier];
        headerView = [self.tableViewBuilder.tableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
    }
    
    if (!headerView.backgroundView && self.backgroundViewForHeader) {
        headerView.backgroundView = self.backgroundViewForHeader;
    }
    
    return headerView;
}

- (void)prepareForReuse:(UITableViewHeaderFooterView *)view {
}

- (void)setTitleForHeader:(NSString *)titleForHeader {
    [self willChangeValueForKey:@keypath(self.titleForHeader)];
    _titleForHeader = titleForHeader;
    [self didChangeValueForKey:@keypath(self.titleForHeader)];
}

- (void)setTitleForFooter:(NSString *)titleForFooter {
    [self willChangeValueForKey:@keypath(self.titleForFooter)];
    _titleForFooter = titleForFooter;
    [self didChangeValueForKey:@keypath(self.titleForFooter)];
}
#pragma mark - UITableViewDataSource
#pragma mark - reload
- (void)reloadSectionWithAnimation:(UITableViewRowAnimation)animation {
    [self.tableViewBuilder.tableView reloadSections:[NSIndexSet indexSetWithIndex:self.section] withRowAnimation:animation];
}

#pragma mark - UITableViewDelegate
- (void)willDisplayHeaderView:(UIView *)view {
    self.displayingViewForHeader = view;
}

- (void)willDisplayFooterView:(UIView *)view {
    self.displayingViewForFooter = view;
}

- (void)didEndDisplayingHeaderView:(UIView *)view {
    self.displayingViewForHeader = nil;
}

- (void)didEndDisplayingFooterView:(UIView *)view {
    self.displayingViewForFooter = nil;
}

#pragma mark - Convenient Methods
- (UITableView *)tableView {
    return self.tableViewBuilder.tableView;
}

- (NSInteger)section {
    return [self.tableViewBuilder indexOfSection:self];
}

#pragma mark - Notify TableView
- (void)insertRowItem:(TMRowItem *)object intoTableViewAtIndex:(NSUInteger)index withRowAnimation:(UITableViewRowAnimation)animation {
    NSParameterAssert(self.tableView);
    [self insertObject:object inRowItemsAtIndex:index];
    tm_runOnMainQueueWithoutDeadlocking(^{
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[object.indexPath] withRowAnimation:animation];
        [self.tableView endUpdates];
    });
}

- (void)removeRowItemFromTableViewAtIndex:(NSUInteger)index withRowAnimation:(UITableViewRowAnimation)animation {
    NSParameterAssert(self.tableView);
    TMRowItem *rowItem = [self rowItemAtIndex:index];
    [rowItem removeFromTableViewWithRowAnimation:animation];
}

- (void)replaceRowItemFromTableViewAtIndex:(NSUInteger)index withRowItem:(TMRowItem *)object moveOutRowAnimation:(UITableViewRowAnimation)moveOutRowAnimation moveInRowAnimation:(UITableViewRowAnimation)moveInRowAnimation {
    NSParameterAssert(self.tableView);
    TMRowItem *rowItem = [self rowItemAtIndex:index];
    NSIndexPath *indexPath = rowItem.indexPath;
    [rowItem removeFromSectionItem];
    [self insertObject:object inRowItemsAtIndex:index];
    
    tm_runOnMainQueueWithoutDeadlocking(^{
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:moveOutRowAnimation];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:moveInRowAnimation];
        [self.tableView endUpdates];
    });
}

#pragma mark - Expandable
- (BOOL)shouldResponsedToFetchedResutlsControllerDelegate {
    return YES;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
}
#pragma mark - Cell
//set height will also set the height for estimatedHeight.
//because the default delegate implemented estimatedHeightForXXX, if not estimatedHeight is not set
//viewForXXX will not be called.
- (void)setHeightForFooter:(CGFloat)heightForFooter {
    _heightForFooter = heightForFooter;
    self.estimatedHeightForFooter = heightForFooter;
}

- (void)setHeightForHeader:(CGFloat)heightForHeader {
    _heightForHeader = heightForHeader;
    self.estimatedHeightForHeader = heightForHeader;
}

- (UIColor *)backgroundColorForHeader {
    return self.backgroundViewForHeader.backgroundColor;
}

- (void)setBackgroundColorForHeader:(UIColor *)backgroundColorForHeader {
    self.backgroundViewForHeader = [[UIView alloc] init];
    self.backgroundViewForHeader.backgroundColor = backgroundColorForHeader;
}

- (UIColor *)backgroundColorForFooter {
    return self.backgroundViewForFooter.backgroundColor;
}

- (void)setBackgroundColorForFooter:(UIColor *)backgroundColorForFooter {
    self.backgroundViewForFooter = [[UIView alloc] init];
    self.backgroundViewForFooter.backgroundColor = backgroundColorForFooter;
}
#pragma mark - Class registration
- (_TMKitClassLookup *)classLookup {
    if (!_classLookup) {
        _classLookup = [_TMKitClassLookup new];
    }
    return _classLookup;
}

- (void)registerClass:(Class)klass forType:(TMTableViewBuilderClassType)type {
    [self.classLookup registerClass:klass forType:type];
}

- (Class)classForType:(TMTableViewBuilderClassType)type {
    Class klass = [self.classLookup classForType:type];
    if (klass) {
        return klass;
    }
    
    if (self.tableViewBuilder) {
        return [self.tableViewBuilder classForType:type];
    }
    
    return [[_TMKitClassLookup defaultLookup] classForType:type];
}
#pragma mark - Collection Methods
- (void)tm_each:(void (^)(id rowItem))block {
    for (NSUInteger i = 0; i < [self countOfRowItems]; i++) {
        TMRowItem *rowItem = [self rowItemAtIndex:i];
        block(rowItem);
    }
}

#pragma mark - Predicate
- (NSArray *)filterRowItemsUsingPredicate:(NSPredicate *)predicate {
    return [self.rowDataSource filterRowItemsUsingPredicate:predicate];
}

#pragma mark - Copy 


- (id)copyWithZone:(NSZone *)zone
{
    id theCopy = [(TMSectionItem *)[[self class] allocWithZone:zone] initWithType:self.type];  // use designated initializer
    
    //    [theCopy setTableViewBuilder:[self.tableViewBuilder copy]];// no builder
    //    [theCopy setSection:self.section];
    //    [theCopy setFetchedResultsController:[self.fetchedResultsController copy]];
    [theCopy setTitleForHeader:[self.titleForHeader copy]];
    [theCopy setTitleForFooter:[self.titleForFooter copy]];
    [theCopy setHeightForHeader:self.heightForHeader];
    [theCopy setHeightForFooter:self.heightForFooter];
    [theCopy setEstimatedHeightForHeader:self.estimatedHeightForHeader];
    [theCopy setEstimatedHeightForFooter:self.estimatedHeightForFooter];
    
    [theCopy setBackgroundViewForHeader:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.backgroundViewForHeader]]];
    [theCopy setBackgroundViewForFooter:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.backgroundViewForFooter]]];
    
    [theCopy setBackgroundColorForHeader:[self.backgroundColorForHeader copy]];
    [theCopy setBackgroundColorForFooter:[self.backgroundColorForFooter copy]];
    
    return theCopy;
}

#pragma mark - Reload
- (void)reload {
    [self removeAllRowItems];
    if (self.reloadBlock) {
        self.reloadBlock(self);
    }
}

@end