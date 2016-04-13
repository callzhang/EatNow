//
//  TMTableViewBuilder.m
//  TMKit
//
//  Created by Zitao Xiong on 3/25/15.
//  Copyright (c) 2015 Nanaimostudio. All rights reserved.
//

#import "TMTableViewBuilder.h"
#import "TMTableViewArraySectionItemDataSource.h"
#import "TMSectionItem+Protected.h"
#import "TMSectionItem.h"
#import "TMLog.h"
#import "TMRowItem.h"
#import "TMTableViewFetchedResultsSectionItemDataSource.h"
#import "TMSearchController.h"
#import "TMTableViewSearchResultsController.h"
#import "TMTableViewBuilderTableViewController.h"
#import "TMTableViewBuilder+Protected.h"
#import "_TMKitClassLookup.h"

static const NSString *kTMTableViewBuilderReuseIdentifierKey = @"tableviewbuilder.key.reuseidentifier";
static const NSString *kTMTableViewBuilderNibNameKey = @"tableviewbuilder.key.nibname";

static void (^_globalTableViewConfigurationBlock)(UITableView *tableView);
//static NSMutableDictionary *registerredClassMapping = nil;
static NSMutableDictionary *defaultRegisterredClassMapping = nil;

@interface TMTableViewBuilder ()<TMTableViewSectionItemDataSourceDelegate>
@property (nonatomic, strong) NSObject<TMTableViewSectionItemDataSource> *sectionItemDataSource;
@property (nonatomic, strong) NSMutableDictionary *configurationsMapping;
@property (nonatomic, strong) NSMutableSet *reuseIdentifiersToRegister;
@property (nonatomic, strong) NSMutableDictionary *registerredClassMapping;;
@property (nonatomic, assign, getter = isConfigured) BOOL configured;

// Declare some collection properties to hold the various updates we might get from the NSFetchedResultsControllerDelegate
@property (nonatomic, strong) NSMutableIndexSet *deletedSectionIndexes;
@property (nonatomic, strong) NSMutableIndexSet *insertedSectionIndexes;
@property (nonatomic, strong) NSMutableArray *deletedRowIndexPaths;
@property (nonatomic, strong) NSMutableArray *insertedRowIndexPaths;
@property (nonatomic, strong) NSMutableArray *updatedRowIndexPaths;
@property (nonatomic, strong) _TMKitClassLookup *classLookup;
@end

@implementation TMTableViewBuilder
@synthesize tableViewDataSource = _tableViewDataSource;
@synthesize tableViewDelegate = _tableViewDelegate;

- (void)dealloc {
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

+ (void)initialize {
    //    registerredClassMapping = [NSMutableDictionary dictionary];
    defaultRegisterredClassMapping = [NSMutableDictionary dictionary];
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]) {
        [self registerDefaultClass:[TMSearchController class] forType:TMTableViewBuilderClassTypeSearchController];
    }
    [self registerDefaultClass:[TMTableViewSearchResultsController class] forType:TMTableViewBuilderClassTypeSearchResultsController];
    [self registerDefaultClass:[TMTableViewBuilderViewController class] forType:TMTableViewBuilderClassTypeTableViewBuilderViewController];
}

- (instancetype)init {
    self = [self initWithTableView:nil managedType:TMTableViewBuilderManagedTypeArray];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithTableView:(UITableView *)tableView {
    return [self initWithTableView:tableView managedType:TMTableViewBuilderManagedTypeArray];
}

- (instancetype)initWithTableView:(UITableView *)tableView managedType:(TMTableViewBuilderManagedType)managedType {
    return [self initWithTableView:tableView managedType:managedType tableViewDataSourceOverride:nil tableViewDelegateOverride:nil];
}

- (instancetype)initWithTableView:(UITableView *)tableView managedType:(TMTableViewBuilderManagedType)managedType tableViewDataSourceOverride:(id <TMTableViewDataSource> )datasource tableViewDelegateOverride:(id <UITableViewDelegate> )delegate {
    self = [super init];
    if (self) {
        _managedType = managedType;
        if (_managedType == TMTableViewBuilderManagedTypeArray) {
            self.sectionItemDataSource = [TMTableViewArraySectionItemDataSource new];
        }
        else if (_managedType == TMTableViewBuilderManagedTypeFetchedResultsController){
            self.sectionItemDataSource = [TMTableViewFetchedResultsSectionItemDataSource new];
        }
        self.sectionItemDataSource.delegate = self;
        self.configurationsMapping = [NSMutableDictionary dictionary];
        self.registerredClassMapping = [NSMutableDictionary dictionary];
        self.estimatedHeightForRow = UITableViewAutomaticDimension;
        self.shouldRespondToEstimatedHeightForRow = YES;
        
        self.tableViewDelegate.delegate = delegate;
        self.tableViewDataSource.dataSource = datasource;
        //table view must be set at last. when setting tableview's delegate,
        //it might asks tableview builder for some setting properties. 
        self.tableView = tableView;
    }
    
    return self;
}

- (void)didFetchSectionItem:(TMSectionItem *)object {
    object.tableViewBuilder = self;
    if (self.didFetchSectionItemBlock) {
        self.didFetchSectionItemBlock(object);
    }
}

- (void)didInsertSectionItem:(TMSectionItem *)sectionItem {
    sectionItem.tableViewBuilder = self;
    if (sectionItem.type == TMSectionItemTypeArray) {
        for (NSInteger i = 0; i < sectionItem.numberOfRows; i++) {
            TMRowItem *rowItem = [sectionItem rowItemAtIndex:i];
            [self addReuseIdentifierToRegister:[rowItem reuseIdentifier] nibName:[rowItem nibName]];
        }
    }
}

- (void)didCreateSectionItem:(TMSectionItem *)sectionItem {
    sectionItem.tableViewBuilder = self;
    if (self.didCreateSectionItemBlock) {
        self.didCreateSectionItemBlock(sectionItem);
    }
}

- (void)fetchedResultsRowItemDataSource:(TMTableViewFetchedResultsSectionItemDataSource *)dataSrouce didCreatedFetchedResultsSectionItem:(TMSectionItem *)sectionItem {
    [self didCreateSectionItem:sectionItem];
}

- (Class)sectionItemClassForFetchedResultsControllerManagedType {
    return [self classForType:TMTableViewBuilderClassTypeSectionItemClassForFetchedResultsController];
}
#pragma mark -
- (NSMutableDictionary *)configurationsMapping {
    if (!_configurationsMapping) {
        _configurationsMapping = [[NSMutableDictionary alloc] init];
    }
    
    return _configurationsMapping;
}

- (NSMutableSet *)reuseIdentifiersToRegister {
    if (!_reuseIdentifiersToRegister) {
        _reuseIdentifiersToRegister = [NSMutableSet set];
    }
    
    return _reuseIdentifiersToRegister;
}
#pragma mark - KVC
- (void)insertObject:(TMSectionItem *)object inSectionItemsAtIndex:(NSUInteger)index {
    [self.sectionItemDataSource insertObject:object inSectionItemsAtIndex:index];
}

- (void)replaceObjectInSectionItemsAtIndex:(NSUInteger)index withObject:(TMSectionItem *)object {
    [self.sectionItemDataSource replaceObjectInSectionItemsAtIndex:index withObject:object];
}

- (void)removeObjectFromSectionItemsAtIndex:(NSUInteger)index {
    [self.sectionItemDataSource removeObjectFromSectionItemsAtIndex:index];
}

- (void)removeAllSectionItems {
    [self.sectionItemDataSource removeAllSectionItems];
}

- (void)removeRowItemAtIndexPath:(NSIndexPath *)indexPath {
    TMSectionItem *sectionItem = [self.sectionItemDataSource objectInSectionItemsAtIndex:indexPath.section];
    [sectionItem removeRowItemAtIndex:indexPath.row];
}

- (void)removeSectionItem:(TMSectionItem *)item {
    NSInteger index = [self.sectionItemDataSource indexOfSectionItem:item];
    if (index != NSNotFound) {
        [self removeObjectFromSectionItemsAtIndex:index];
    }
}

- (void)insertSectionItems:(NSArray *)sectionItemsArray atIndexes:(NSIndexSet *)indexes {
    [self.sectionItemDataSource insertSectionItems:sectionItemsArray atIndexes:indexes];
}
#pragma mark - kyed subscript
- (id)objectAtIndexedSubscript:(NSUInteger)index {
    return [self.sectionItemDataSource objectInSectionItemsAtIndex:index];
}

- (void)setObject:(TMSectionItem *)obj atIndexedSubscript:(NSUInteger)index {
    NSParameterAssert([obj isKindOfClass:[TMSectionItem class]]);
    [self insertObject:obj inSectionItemsAtIndex:index];
}

#pragma mark -

- (NSInteger)numberOfSections {
    return [self.sectionItemDataSource countOfSectionItems];
}

- (TMSectionItem *)sectionItemAtIndex:(NSInteger)index {
    return [self.sectionItemDataSource objectInSectionItemsAtIndex:index];
}

- (TMSectionItem *)firstSectionItem {
    if (self.sectionItemDataSource.countOfSectionItems > 0) {
        return [self.sectionItemDataSource objectInSectionItemsAtIndex:0];
    }
    else {
        return nil;
    }
}

- (TMRowItem *)rowItemAtIndexPath:(NSIndexPath *)indexPath {
    TMSectionItem *sectionItem = [self sectionItemAtIndex:indexPath.section];
    TMRowItem *rowItem = [sectionItem rowItemAtIndex:indexPath.row];
    return rowItem;
}

- (void)addSectionItem:(TMSectionItem *)sectionItem {
    NSParameterAssert([sectionItem isKindOfClass:[TMSectionItem class]]);
    [self insertObject:sectionItem inSectionItemsAtIndex:self.numberOfSections];
}

- (NSUInteger)indexOfSection:(TMSectionItem *)section {
    return [self.sectionItemDataSource indexOfSectionItem:section];
}

- (TMTableViewDataSource *)tableViewDataSource {
    if (!_tableViewDataSource) {
        _tableViewDataSource = [[TMTableViewDataSource alloc] initWithTableViewBuilder:self];
    }
    return _tableViewDataSource;
}

- (TMTableViewDelegate *)tableViewDelegate {
    if (!_tableViewDelegate) {
        _tableViewDelegate = [[TMTableViewDelegate alloc] initWithTableViewBuilder:self];
    }
    return _tableViewDelegate;
}

- (void)registerTableViewCellForTableView:(UITableView *)tableView {
    NSSet *identifiers = self.reuseIdentifiersToRegister;
    
    for (NSDictionary *dictionary in identifiers) {
        [tableView registerNib:[UINib nibWithNibName:dictionary[kTMTableViewBuilderNibNameKey] bundle:nil] forCellReuseIdentifier:dictionary[kTMTableViewBuilderReuseIdentifierKey]];
    }
}

- (void)addReuseIdentifierToRegister:(NSString *)reusedIdentifier nibName:(NSString *)nibName {
    [self.reuseIdentifiersToRegister addObject:@{kTMTableViewBuilderReuseIdentifierKey: reusedIdentifier, kTMTableViewBuilderNibNameKey: nibName}];
}

- (void)configure {
    NSParameterAssert(self.tableView);
    [self reloadData];
    
    [self registerTableViewCellForTableView:self.tableView];
    
    if (_globalTableViewConfigurationBlock) {
        _globalTableViewConfigurationBlock(self.tableView);
    }
    
    if (self.tableViewConfiguration) {
        self.tableViewConfiguration(self.tableView);
    }
    
}

- (void)reloadData {
    if (self.reloadBlock) {
        self.reloadBlock(self);
    }
    
    self.configured = YES;
    
    [self.tableView reloadData];
    if (self.didReloadData) {
        self.didReloadData(self);
    }
}

+ (void)setGlobalTableViewConfiguration:(void (^)(UITableView *))configuration {
    _globalTableViewConfigurationBlock = configuration;
}

- (void)setTableView:(UITableView *)tableView {
    _tableView = tableView;
    _tableView.delegate = self.tableViewDelegate;
    _tableView.dataSource = self.tableViewDataSource;
}
#pragma mark - Section Index Titles 
- (void)setSectionIndexTitles:(NSArray *)sectionIndexTitles {
    if ([self.sectionItemDataSource respondsToSelector:@selector(setSectionIndexTitles:)]) {
        [self.sectionItemDataSource setSectionIndexTitles:sectionIndexTitles];
    }
    else {
        NSAssert(NO, @"do not support setting index titles");
    }
}

- (NSArray *)sectionIndexTitles {
    return [self.sectionItemDataSource sectionIndexTitles];
}

- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.sectionItemDataSource sectionForSectionIndexTitle:title atIndex:index];
}
#pragma mark - Collection Methods
- (NSArray *)visibleRowItems {
    NSArray *indexPathForVisibleRows = [self.tableView indexPathsForVisibleRows];
    NSMutableArray *rows = [NSMutableArray array];
    [indexPathForVisibleRows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [rows addObject:[self rowItemAtIndexPath:obj]];
    }];
    
    return rows.copy;
}

- (void)reloadVisibleRowsWithRowAnimation:(UITableViewRowAnimation)animation {
    NSArray *indexPathes = [self.tableView indexPathsForVisibleRows];
    
    [self.tableView reloadRowsAtIndexPaths:indexPathes withRowAnimation:animation];
}

- (void)tm_eachRowItem:(void (^)(id))block {
    [self tm_eachSectionItem:^(TMSectionItem *sectionItem) {
        [sectionItem tm_each:^(id rowItem) {
            block(rowItem);
        }];
    }];
}

- (void)tm_eachSectionItem:(void (^)(id))block {
    for (NSUInteger i = 0; i < [self numberOfSections]; i++) {
        TMSectionItem *sectionItem = [self sectionItemAtIndex:i];
        block(sectionItem);
    }
}

#pragma mark - Class registration
- (_TMKitClassLookup *)classLookup {
    if (!_classLookup) {
        _classLookup = [_TMKitClassLookup new];
    }
    return _classLookup;
}

+ (void)registerDefaultClass:(Class)klass forType:(TMTableViewBuilderClassType)type {
    [[_TMKitClassLookup defaultLookup] registerClass:klass forType:type];
}

- (void)registerClass:(Class)klass forType:(TMTableViewBuilderClassType)type {
    [self.classLookup registerClass:klass forType:type];
}

- (Class)classForType:(TMTableViewBuilderClassType)type {
    Class klass = [self.classLookup classForType:type];
    if (klass) {
        return klass;
    }
    return [[_TMKitClassLookup defaultLookup] classForType:type];
}

+ (Class)classForType:(TMTableViewBuilderClassType)type {
    return [[_TMKitClassLookup defaultLookup] classForType:type];
}

#pragma mark - Core Data 
- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController {
    fetchedResultsController.delegate = self;
    [self fetchedResultsDataSource].fetchedResultsController = fetchedResultsController;
}

- (NSFetchedResultsController *)fetchedResultsController {
    return [[self fetchedResultsDataSource] fetchedResultsController];
}

- (void)setDidCreateRowItemBlock:(void (^)(id, id))didCreateRowItemBlock forRowItemClass:(Class)klass {
    self.rowItemLazyCreator = [[_TMTableViewBuilderRowItemLazyCreator alloc] init];
    self.rowItemLazyCreator.didCreateRowItemBlock = didCreateRowItemBlock;
    self.rowItemLazyCreator.rowItemClass = klass;
}

#pragma mark - NSFetchedResultControllerDelegate
- (NSUInteger)sectionForFetchedResultsController:(NSFetchedResultsController*)controller {
    NSUInteger section = NSNotFound;
    __block TMSectionItem *foundSectionItem = nil;
    [self tm_eachSectionItem:^(TMSectionItem *sectionItem) {
        if (sectionItem.type == TMSectionItemTypeFetchedResultsController && sectionItem.fetchedResultsController == controller) {
            foundSectionItem = sectionItem;
            return ;
        }
    }];
    
    section = [self indexOfSection:foundSectionItem];
    
    return section;
}

- (NSIndexPath *)actualIndexPathForIndexPath:(NSIndexPath *)indexPath withController:(NSFetchedResultsController *)controller {
    NSUInteger section = [self sectionForFetchedResultsController:controller];
    return [NSIndexPath indexPathForRow:indexPath.row inSection:section];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (type == NSFetchedResultsChangeInsert) {
        //        [[self fetchedResultsDataSource] insertNullRowAtIndexPaths:@[newIndexPath]];
        if ([self.insertedSectionIndexes containsIndex:newIndexPath.section]) {
            // If we've already been told that we're adding a section for this inserted row we skip it since it will handled by the section insertion.
            return;
        }
        
        [self.insertedRowIndexPaths addObject:newIndexPath];
    } else if (type == NSFetchedResultsChangeDelete) {
        if ([self.deletedSectionIndexes containsIndex:indexPath.section]) {
            // If we've already been told that we're deleting a section for this deleted row we skip it since it will handled by the section deletion.
            return;
        }
        
        [self.deletedRowIndexPaths addObject:indexPath];
        //        [[self fetchedResultsDataSource] removeRowAtIndexPaths:@[indexPath]];
    } else if (type == NSFetchedResultsChangeMove) {
        if ([self.insertedSectionIndexes containsIndex:newIndexPath.section] == NO) {
            [self.insertedRowIndexPaths addObject:newIndexPath];
            //            [[self fetchedResultsDataSource] insertNullRowAtIndexPaths:@[newIndexPath]];
        }
        
        if ([self.deletedSectionIndexes containsIndex:indexPath.section] == NO) {
            [self.deletedRowIndexPaths addObject:indexPath];
            //            [[self fetchedResultsDataSource] removeRowAtIndexPaths:@[indexPath]];
        }
    } else if (type == NSFetchedResultsChangeUpdate) {
        [self.updatedRowIndexPaths addObject:indexPath];
        //        [[self fetchedResultsDataSource] reloadRowAtIndexPaths:@[indexPath]];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    NSParameterAssert(self.managedType == TMTableViewBuilderManagedTypeFetchedResultsController);
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.insertedSectionIndexes addIndex:sectionIndex];
            //            [[self fetchedResultsDataSource] insertSectionItemForFetchedResultsAtIndex:sectionIndex];
            break;
        case NSFetchedResultsChangeDelete: {
            [self.deletedSectionIndexes addIndex:sectionIndex];
            //            [[self fetchedResultsDataSource] removeObjectFromSectionItemsAtIndex:sectionIndex];
            
            NSMutableArray *indexPathsInSection = [NSMutableArray array];
            for(NSIndexPath *indexPath in self.deletedRowIndexPaths)
            {
                if (indexPath.section == sectionIndex)
                {
                    [indexPathsInSection addObject:indexPath];
                }
            }
            [self.deletedRowIndexPaths removeObjectsInArray:indexPathsInSection];
            break;
        }
        default:
            ; // Shouldn't have a default
            break;
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

/**
 *  ref 1. https://gist.github.com/MrRooni/4988922
 *
 */
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    @synchronized (self) {
        void (^cleanupBlock)() = ^{
            self.insertedSectionIndexes = nil;
            self.deletedSectionIndexes = nil;
            self.deletedRowIndexPaths = nil;
            self.insertedRowIndexPaths = nil;
            self.updatedRowIndexPaths = nil;
        };
        
        NSInteger totalChanges = [self.deletedSectionIndexes count] +
        [self.insertedSectionIndexes count] +
        [self.deletedRowIndexPaths count] +
        [self.insertedRowIndexPaths count] +
        [self.updatedRowIndexPaths count];
        if (totalChanges > 50) {
            [self.tableView endUpdates];
            [[self fetchedResultsDataSource] reloadAllSectionWithNullRowItwm];
            [self.tableView reloadData];
            cleanupBlock();
            return;
        }
        
        
        /**
         *  order matters, ref: https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TableView_iPhone/ManageInsertDeleteRow/ManageInsertDeleteRow.html#//apple_ref/doc/uid/TP40007451-CH10-SW9
         */
        
        //        [self.tableView beginUpdates];
        
        [self.tableView deleteSections:self.deletedSectionIndexes withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView insertSections:self.insertedSectionIndexes withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView deleteRowsAtIndexPaths:self.deletedRowIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView insertRowsAtIndexPaths:self.insertedRowIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadRowsAtIndexPaths:self.updatedRowIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        
        
        [[self fetchedResultsDataSource] removeRowAtIndexPaths:self.deletedRowIndexPaths];
        [[self fetchedResultsDataSource] removeSectionItemsAtIndexes:self.deletedSectionIndexes];
        /**
         *  if a row is in insertedSectionIndexes, it will not be in insertedRowInddexPaths,
         *  therefore we created all rows in the section by current state.
         */
        [[self fetchedResultsDataSource] insertSectionItemWithNullRowAtIndexes:self.insertedSectionIndexes];
        //        [[self fetchedResultsDataSource] insertSectionItemAtIndexes:self.insertedSectionIndexes];
        [[self fetchedResultsDataSource] insertNullRowAtIndexPaths:self.insertedRowIndexPaths];
        [[self fetchedResultsDataSource] reloadRowAtIndexPaths:self.updatedRowIndexPaths];
        
        [self.tableView endUpdates];
        
        cleanupBlock();
        
        //Log out for crash analysis
        DDLogVerbose(@"[TMTableViewBuilder]: deletedSectionIndexes : [%@]", self.deletedSectionIndexes);
        DDLogVerbose(@"[TMTableViewBuilder]: insertedSectionIndexes: [%@]", self.insertedSectionIndexes);
        DDLogVerbose(@"[TMTableViewBuilder]: deletedRowIndexPaths  : [%@]", self.deletedRowIndexPaths);
        DDLogVerbose(@"[TMTableViewBuilder]: insertedRowIndexPaths : [%@]", self.insertedRowIndexPaths);
        DDLogVerbose(@"[TMTableViewBuilder]: updatedRowIndexPaths  : [%@]", self.updatedRowIndexPaths);
        // nil out the collections so their ready for their next use.
    }
}

/**
 * Lazily instantiate these collections.
 */

- (NSMutableIndexSet *)deletedSectionIndexes {
    if (_deletedSectionIndexes == nil) {
        _deletedSectionIndexes = [[NSMutableIndexSet alloc] init];
    }
    return _deletedSectionIndexes;
}

- (NSMutableIndexSet *)insertedSectionIndexes {
    if (_insertedSectionIndexes == nil) {
        _insertedSectionIndexes = [[NSMutableIndexSet alloc] init];
    }
    return _insertedSectionIndexes;
}

- (NSMutableArray *)deletedRowIndexPaths {
    if (_deletedRowIndexPaths == nil) {
        _deletedRowIndexPaths = [[NSMutableArray alloc] init];
    }
    return _deletedRowIndexPaths;
}

- (NSMutableArray *)insertedRowIndexPaths {
    if (_insertedRowIndexPaths == nil) {
        _insertedRowIndexPaths = [[NSMutableArray alloc] init];
    }
    return _insertedRowIndexPaths;
}

- (NSMutableArray *)updatedRowIndexPaths {
    if (_updatedRowIndexPaths == nil) {
        _updatedRowIndexPaths = [[NSMutableArray alloc] init];
    }
    return _updatedRowIndexPaths;
}

- (BOOL)performFetch:(NSError **)error {
    return [[self fetchedResultsDataSource] performFetch:error];
}

- (TMTableViewFetchedResultsSectionItemDataSource *)fetchedResultsDataSource {
    TMTableViewFetchedResultsSectionItemDataSource *source = (TMTableViewFetchedResultsSectionItemDataSource *)self.sectionItemDataSource;
    NSParameterAssert([source isKindOfClass:[TMTableViewFetchedResultsSectionItemDataSource class]]);
    return source;
}

- (void)setRowItemLazyCreator:(_TMTableViewBuilderRowItemLazyCreator *)rowItemLazyCreator {
    [[self fetchedResultsDataSource] setRowItemLazyCreator:rowItemLazyCreator];
}

- (_TMTableViewBuilderRowItemLazyCreator *)rowItemLazyCreator {
    return [[self fetchedResultsDataSource] rowItemLazyCreator];
}

- (void)setSelfSizingFooterHeight:(BOOL)selfSizingFooterHeight {
    [self willChangeValueForKey:@"selfSizingFooterHeight"];
    _selfSizingFooterHeight = selfSizingFooterHeight;
    self.tableView.delegate = self.tableViewDelegate;
    [self didChangeValueForKey:@"selfSizingFooterHeight"];
}

- (void)setSelfSizingHeaderHeight:(BOOL)selfSizingHeaderHeight {
    [self willChangeValueForKey:@"selfSizingHeaderHeight"];
    _selfSizingHeaderHeight = selfSizingHeaderHeight;
    self.tableView.delegate = self.tableViewDelegate;
    [self didChangeValueForKey:@"selfSizingHeaderHeight"];
}

- (void)setShouldRespondToEstimatedHeightForRow:(BOOL)shouldRespondToEstimatedHeightForRow {
    [self willChangeValueForKey:@"shouldRespondToEstimatedHeightForRow"];
    _shouldRespondToEstimatedHeightForRow = shouldRespondToEstimatedHeightForRow;
    self.tableView.delegate = self.tableViewDelegate;
    [self didChangeValueForKey:@"shouldRespondToEstimatedHeightForRow"];
}
@end

@implementation TMTableViewBuilder (SectionItemAddition)

- (TMSectionItem *)addedSectionItem {
    TMSectionItem *section = [TMSectionItem new];
    [self addSectionItem:section];
    return section;
}

@end


@implementation TMTableViewBuilder (Search)
#pragma mark - UISearchController
/**
 *  initialze and setup a search controller used for filtering current data.
 *
 *  @param viewController the view controller who holds this table view builder
 */

- (void)initializeSearchControllerWithViewController:(UIViewController<TMTableViewSearchController> *)viewController {
    Class SearchControllerClass = [self classForType:TMTableViewBuilderClassTypeSearchController];
    Class SearchResultsControllerClass = [self classForType:TMTableViewBuilderClassTypeSearchResultsController];
    NSParameterAssert([SearchControllerClass isSubclassOfClass:[UISearchController class]]);
    NSParameterAssert([SearchResultsControllerClass isSubclassOfClass:[UIViewController class]]);
    NSParameterAssert([SearchResultsControllerClass conformsToProtocol:@protocol(UISearchResultsUpdating)]);
    
    viewController.searchResultsController = [(UIViewController<TMTableViewSearchResultsController> *) [SearchResultsControllerClass alloc] init];
    viewController.searchResultsController.originalTableViewBuilder = self;
    
    UISearchController *searchController = [(UISearchController *) [SearchControllerClass alloc] initWithSearchResultsController:viewController.searchResultsController];
    searchController.searchResultsUpdater = viewController.searchResultsController;
    
    viewController.searchResultsController.searchController = searchController;
    
    UIView *tableHeaderView = [[UIView alloc] initWithFrame: CGRectMake(0.0, 0.0, 320.0, 44.0)];
    tableHeaderView.backgroundColor = [UIColor clearColor];
    [tableHeaderView addSubview:searchController.searchBar];
    searchController.searchBar.frame = tableHeaderView.bounds;
    
    
    self.tableView.tableHeaderView = tableHeaderView;
    [searchController.searchBar sizeToFit];
    
    viewController.definesPresentationContext = YES;
    viewController.edgesForExtendedLayout = UIRectEdgeNone;
    viewController.navigationController.definesPresentationContext = YES;
}

- (NSPredicate *)searchPredicateForFilteringSearchControllerWithSearchingText:(NSString *)text {
    if (self.filteringPredicateForText) {
        return self.filteringPredicateForText(text);
    }
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"(text CONTAINS[cd] %@) OR (detailText CONTAINS[cd] %@)", text, text];
    return searchPredicate;
}
@end