//
//  TMTableViewBuilder.h
//  TMKit
//
//  Created by Zitao Xiong on 3/25/15.
//  Copyright (c) 2015 Nanaimostudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMSearchController.h"
#import "TMTableViewDelegate.h"
#import "TMTableViewDataSource.h"
#import "_TMKitClassLookup.h"

@import UIKit;
@import CoreData;

@protocol TMTableViewDataSource <NSObject>
@optional
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;              // Default is 1 if not implemented

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;    // fixed font style. use custom view (UILabel) if you want something different
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;

// Editing

// Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;

// Moving/reordering

// Allows the reorder accessory view to optionally be shown for a particular row. By default, the reorder control will be shown only if the datasource implements -tableView:moveRowAtIndexPath:toIndexPath:
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;

// Index

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView;                                                    // return list of section titles to display in section index view (e.g. "ABCD...Z#")
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;  // tell table which section corresponds to section title/index (e.g. "B",1))

// Data manipulation - insert and delete support

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
// Not called for edit actions using UITableViewRowAction - the action's handler will be invoked instead
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;

// Data manipulation - reorder / moving support

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;
@end

@class TMTableViewBuilder;
@class TMTableViewDelegate;
@class TMTableViewDataSource;
@class TMRowItem;
@class TMSectionItem;
@protocol TMTableViewBuilderViewController;

typedef void(^TableViewReloadBlock)(TMTableViewBuilder *builder);


typedef NS_ENUM(NSUInteger, TMTableViewBuilderManagedType) {
    TMTableViewBuilderManagedTypeArray = 3,
    TMTableViewBuilderManagedTypeFetchedResultsController = 4,
};

@interface TMTableViewBuilder : NSObject <NSFetchedResultsControllerDelegate, TMKitClassLookup>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, readonly) TMTableViewDataSource *tableViewDataSource;
@property (nonatomic, readonly) TMTableViewDelegate *tableViewDelegate;
@property (nonatomic, copy) NSPredicate* (^filteringPredicateForText)(NSString *text);

#pragma mark - Section Index Title
@property (nonatomic, readwrite) NSArray *sectionIndexTitles;
- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;

#pragma mark - Core Data
@property (nonatomic, readonly) TMTableViewBuilderManagedType managedType;
@property (nonatomic, readwrite) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, copy) void (^didFetchSectionItemBlock)(id item);
@property (nonatomic, copy) void (^didCreateSectionItemBlock)(id item);
- (void)setDidFetchSectionItemBlock:(void (^)(id sectionItem))didFetchSectionItem;
- (void)setDidCreateRowItemBlock:(void (^)(id rowItem, id managedObject))didCreateRowItemBlock forRowItemClass:(Class)klass;
- (BOOL)performFetch:(NSError **)error;
#pragma mark - INIT
- (BOOL)isConfigured;
- (instancetype)initWithTableView:(UITableView *)tableView;
- (instancetype)initWithTableView:(UITableView *)tableView managedType:(TMTableViewBuilderManagedType)managedType;
- (instancetype)initWithTableView:(UITableView *)tableView managedType:(TMTableViewBuilderManagedType)managedType tableViewDataSourceOverride:(id <TMTableViewDataSource> )datasource tableViewDelegateOverride:(id <UITableViewDelegate> )delegate NS_DESIGNATED_INITIALIZER;
#pragma mark - KVC
- (void)insertObject:(TMSectionItem *)object inSectionItemsAtIndex:(NSUInteger)index;
- (void)replaceObjectInSectionItemsAtIndex:(NSUInteger)index withObject:(TMSectionItem *)object;
- (void)removeObjectFromSectionItemsAtIndex:(NSUInteger)index;
- (void)removeSectionItem:(TMSectionItem *)item;
- (void)insertSectionItems:(NSArray *)sectionItemsArray atIndexes:(NSIndexSet *)indexes;
#pragma mark -
- (NSInteger)numberOfSections;
- (NSUInteger)indexOfSection:(TMSectionItem *)section;
- (TMSectionItem *)sectionItemAtIndex:(NSInteger)index;
- (TMSectionItem *)firstSectionItem;
- (TMRowItem *)rowItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)addSectionItem:(TMSectionItem *)sectionItem;

#pragma mark - Register Cells
- (void)registerTableViewCellForTableView:(UITableView *)tableView;
- (void)addReuseIdentifierToRegister:(NSString *)reusedIdentifier nibName:(NSString *)nibName;
#pragma mark - Configuration
+ (void)setGlobalTableViewConfiguration:(void (^)(UITableView *tableView))configuration;
@property (nonatomic, copy)void (^tableViewConfiguration)(UITableView *tableView);
- (void)setTableViewConfiguration:(void (^)(UITableView *tableView))configuration;
#pragma mark -
- (void)removeAllSectionItems;
- (void)removeRowItemAtIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, copy) TableViewReloadBlock reloadBlock;
- (void)setReloadBlock:(TableViewReloadBlock)constructBlock;

@property (nonatomic, copy) void (^didReloadData) (TMTableViewBuilder *tableViewBuilder);
- (void)setDidReloadData:(void (^)(TMTableViewBuilder *tableViewBuilder))didReloadData;

- (void)reloadData;

- (void)configure;

#pragma mark - Collection Methods
- (NSArray *)visibleRowItems;
- (void)reloadVisibleRowsWithRowAnimation:(UITableViewRowAnimation)animation;

- (void)tm_eachRowItem:(void (^)(id rowItem))block;
- (void)tm_eachSectionItem:(void (^)(id sectionItem))block;

#pragma mark - Class registration
- (void)registerClass:(Class)kclass forType:(TMTableViewBuilderClassType)type;
+ (void)registerDefaultClass:(Class)klass forType:(TMTableViewBuilderClassType)type;
- (Class)classForType:(TMTableViewBuilderClassType)type;
+ (Class)classForType:(TMTableViewBuilderClassType)type;

#pragma mark - 

/**
 *  set estimatedHeightForRow is favored over using RowItem's estimatedHeightForRow. 
 *  default value is UITableVieAutomaticDemision(-1). when using [UITableView beginUpdates] and 
 * [UITableView endUpdates] pair. UITableVieAutomaticDemision will cause table view to scroll 
 * to the top. set this value is recommand when using self-sizing cell
 */
@property (nonatomic, assign) CGFloat estimatedHeightForRow;
/**
 *  this method *MUST* be set before setting TableView's delegate
 *  table view will ask it's delegate 'responsed' to selector during setting delegate
 *  default is YES
 */
@property (nonatomic, assign) BOOL shouldRespondToEstimatedHeightForRow;
@property (nonatomic, assign) BOOL selfSizingHeaderHeight;
@property (nonatomic, assign) BOOL selfSizingFooterHeight;
@end

@interface TMTableViewBuilder (SectionItemAddition)
- (TMSectionItem *)addedSectionItem;
@end

@protocol TMTableViewSearchResultsController <UISearchResultsUpdating>

@property (nonatomic, weak) TMTableViewBuilder *originalTableViewBuilder;
//TODO: more predicate and filtering
//TODO: core data managed section support
- (NSPredicate *)searchPredicateWithText:(NSString *)text;
- (BOOL)shouldDeepCopyRowItems;
@property (nonatomic, strong) UISearchController *searchController;
@end

/**
 *  view controller who wants to add search bar need to implement this protocol and add following method:
 *  - (void)viewDidLayoutSubviews {
 *    [super viewDidLayoutSubviews];
 *    [self.searchResultsController.searchController.searchBar sizeToFit];
 *  }
 */
@protocol TMTableViewSearchController
@property (nonatomic, strong) UIViewController<TMTableViewSearchResultsController> *searchResultsController;
@end

@interface TMTableViewBuilder (Search)

#pragma mark - UISearchController

- (void)initializeSearchControllerWithViewController:(UIViewController<TMTableViewSearchController> *)viewController;
- (NSPredicate *)searchPredicateForFilteringSearchControllerWithSearchingText:(NSString *)text;
@end