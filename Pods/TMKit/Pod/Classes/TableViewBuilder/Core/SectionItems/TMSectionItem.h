//
//  TMSectionItem.h
//  TMKit
//
//  Created by Zitao Xiong on 3/25/15.
//  Copyright (c) 2015 Nanaimostudio. All rights reserved.
//

#import "_TMTableViewBuilderRowItemLazyCreator.h"
#import "_TMKitClassLookup.h"
@import Foundation;
@import UIKit;
@import CoreData;

@protocol TMSectionItemProtocol <NSObject>
//---------------- MAP to UITableViewDelegate ---------------
@optional
- (void)willDisplayHeaderView:(UIView *)view NS_AVAILABLE_IOS(6_0);
- (void)willDisplayFooterView:(UIView *)view NS_AVAILABLE_IOS(6_0);
- (void)didEndDisplayingHeaderView:(UIView *)view NS_AVAILABLE_IOS(6_0);
- (void)didEndDisplayingFooterView:(UIView *)view NS_AVAILABLE_IOS(6_0);

- (CGFloat)heightForHeader;
- (CGFloat)heightForFooter;

- (CGFloat)estimatedHeightForHeader NS_AVAILABLE_IOS(7_0);
- (CGFloat)estimatedHeightForFooter NS_AVAILABLE_IOS(7_0);
- (UIView *)viewForHeader;   // custom view for header. will be adjusted to default or specified header height
- (UIView *)viewForFooter;   // custom view for footer. will be adjusted to default or specified footer height

//---------------- MAP to UITableViewDataSource ---------------
@required
- (NSInteger)numberOfRows;
@optional
- (NSString *)titleForHeader;    // fixed font style. use custom view (UILabel) if you want something different
- (NSString *)titleForFooter;


//----------------Expandable Section---------------

- (BOOL)shouldResponsedToFetchedResutlsControllerDelegate;
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller;
@end

@class TMTableViewBuilder, TMRowItem;

typedef NS_ENUM(NSUInteger, TMSectionItemType) {
    TMSectionItemTypeArray,
    TMSectionItemTypeFetchedResultsController,
};

@interface TMSectionItem : NSObject <TMSectionItemProtocol, TMKitClassLookup>
+ (instancetype)sectionItemWithType:(TMSectionItemType)type;
- (instancetype)initWithType:(TMSectionItemType)type NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) TMSectionItemType type;
@property (nonatomic, readonly, weak) TMTableViewBuilder *tableViewBuilder;
@property (nonatomic, readonly) NSInteger section;
- (void)removeFromTableView;
- (void)removeFromTableViewAnimated:(BOOL)animated;
#pragma mark - NSFetchedResultsController

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
//- (CGFloat)estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (id<NSFetchedResultsSectionInfo>)sectionInfo;
- (void)setDidCreateRowItemBlock:(void (^)(id rowItem, id managedObject))didCreateRowItemBlock forRowItemClass:(Class)klass;
- (BOOL)performFetch:(NSError **)error;
#pragma mark - Section Property
- (NSInteger)numberOfRows;
@property (nonatomic, strong) NSString *titleForHeader; //implement for UITableViewDelegate
@property (nonatomic, strong) NSString *titleForFooter; //implement for UITableViewDelegate
@property (nonatomic, assign) CGFloat heightForHeader;
@property (nonatomic, assign) CGFloat heightForFooter;
@property (nonatomic, readwrite) CGFloat estimatedHeightForHeader;
@property (nonatomic, readwrite) CGFloat estimatedHeightForFooter;
@property (nonatomic, readonly) id viewForHeader;
@property (nonatomic, readonly) id viewForFooter;

//convenient properties. it is different from titleForHeader.
//for example, if titleForHeader return a value, the section title will be set no matter viewForHeader also return a view.
@property (nonatomic, strong) NSString *headerTitle;
@property (nonatomic, strong) NSAttributedString *attributedHeaderTitle;
@property (nonatomic, strong) NSString *footerTitle;
@property (nonatomic, strong) NSAttributedString *attributedFooterTitle;

@property (nonatomic, weak) id displayingViewForHeader;
@property (nonatomic, weak) id displayingViewForFooter;
//@property (nonatomic, readonly) NSArray *rowItems;
#pragma mark -
+ (NSString *)cellReuseIdentifierForHeader;
+ (NSString *)cellReuseIdentifierForFooter;

//if header or footer is a UITableViewHeaderFooterView, this will be called before return view from viewForFooter or viewForHeader
- (void)prepareForReuse:(UITableViewHeaderFooterView *)view NS_REQUIRES_SUPER;

#pragma mark - UITableViewDelegate
- (void)willDisplayHeaderView:(UIView *)view NS_AVAILABLE_IOS(6_0);
- (void)willDisplayFooterView:(UIView *)view NS_AVAILABLE_IOS(6_0);
- (void)didEndDisplayingHeaderView:(UIView *)view NS_AVAILABLE_IOS(6_0) NS_REQUIRES_SUPER;
- (void)didEndDisplayingFooterView:(UIView *)view NS_AVAILABLE_IOS(6_0) NS_REQUIRES_SUPER;

#pragma mark - Convenient Methods
- (UITableView *)tableView;

#pragma mark - Accessor
- (void)addRowItem:(TMRowItem *)rowItem;
- (TMRowItem *)rowItemAtIndex:(NSUInteger)index;
- (void)removeRowItemAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfRowItem:(TMRowItem *)rowItem;
#pragma mark - TMRowItem Accessor <KVO>
/**
 *  countOfRowItems always return the count of row items
 *  however numberOfRows is used for tableview, it can be subclass to return different numbers. 
 *  the detail usage see TMExpandableItem
 *  @return the count of row items
 */
- (NSUInteger)countOfRowItems;
- (id)objectInRowItemsAtIndex:(NSUInteger)index;
- (void)insertObject:(TMRowItem *)rowItem inRowItemsAtIndex:(NSUInteger)index;
- (void)insertRowItems:(NSArray *)rowItems atIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInRowItemsAtIndex:(NSUInteger)index withObject:(TMRowItem *)rowItem;
- (void)replaceRowItemsAtIndexes:(NSIndexSet *)indexes withRowItems:(NSArray *)rowItems;
- (void)removeFromTableViewBuilder;

#pragma mark -
- (void)removeObjectFromRowItemsAtIndex:(NSUInteger)idx;
- (void)removeRowItemsAtIndexes:(NSIndexSet *)indexes;
- (void)removeAllRowItems;

#pragma mark - Notify TableView
- (void)insertRowItem:(TMRowItem *)object intoTableViewAtIndex:(NSUInteger)index withRowAnimation:(UITableViewRowAnimation)animation;
- (void)removeRowItemFromTableViewAtIndex:(NSUInteger)index withRowAnimation:(UITableViewRowAnimation)animation;
- (void)replaceRowItemFromTableViewAtIndex:(NSUInteger)index withRowItem:(TMRowItem *)object moveOutRowAnimation:(UITableViewRowAnimation)moveOutRowAnimation moveInRowAnimation:(UITableViewRowAnimation)moveInRowAnimation;

#pragma mark - Cell
@property (nonatomic, strong) UIView *backgroundViewForHeader;
@property (nonatomic, readwrite) UIColor *backgroundColorForHeader;
@property (nonatomic, strong) UIView *backgroundViewForFooter;
@property (nonatomic, readwrite) UIColor *backgroundColorForFooter;

#pragma mark - Class Lookup
- (void)registerClass:(Class)klass forType:(TMTableViewBuilderClassType)type;

- (Class)classForType:(TMTableViewBuilderClassType)type;
#pragma mark - Collection Methods

- (void)tm_each:(void (^)(id rowItem))block;

#pragma mark - Predicate
- (NSArray *)filterRowItemsUsingPredicate:(NSPredicate *)predicate;

#pragma mark - Indexed Subscript
- (id)objectAtIndexedSubscript:(NSUInteger)index;
- (void)setObject:(TMRowItem *)obj atIndexedSubscript:(NSUInteger)index;

#pragma mark - Section reload
@property (nonatomic, copy) void (^reloadBlock)(id sectionItem);
- (void)reload;
@property (nonatomic, strong) UIViewController *presentingViewController;
@end