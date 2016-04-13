//
//  TMRowItem.m
//  TMKit
//
//  Created by Zitao Xiong on 3/25/15.
//  Copyright (c) 2015 Nanaimostudio. All rights reserved.
//

#import "TMRowItem.h"
#import "TMRowItem+Protected.h"
#import "TMTableViewBuilder.h"
#import "FBKVOController.h"
#import "UITableView+RegisterRowItem.h"
#import "objc/runtime.h"
#import "TMKit.h"
#import "TMViewControllerPresentationOption.h"
#import "TMBaseTableViewCell.h"
#import "UITableView+TMPTemplateLayoutCell.h"

const CGFloat TMTableViewBuilderDefaultSeparatorInset = -1;

@interface TMRowItem ()
//seee TMRowItem+Protected.h
@end

@implementation TMRowItem
@synthesize backgroundView = _backgroundView;
@synthesize selectedBackgroundView = _selectedBackgroundView;
@synthesize multipleSelectionBackgroundView = _multipleSelectionBackgroundView;
@synthesize nibName = _nibName;
@synthesize originalRowItem = _originalRowItem;

- (instancetype)init {
    self = [super init];
    if (self) {
        [self __setup];
    }
    return self;
}
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super init];
    if (self) {
        self.reuseIdentifier = reuseIdentifier;
        [self __setup];
    }
    return self;
}

- (void)__setup {
    self.clearsSelectionOnCellDidSelect = YES;
    self.heightForRow = UITableViewAutomaticDimension;
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    self.editingStyleForRow = UITableViewRowAnimationNone;
    self.estimatedHeightForRow = UITableViewAutomaticDimension;
    self.shouldHighlightRow = YES;
    self.topSeparatorLeftInset = TMTableViewBuilderDefaultSeparatorInset;
    self.bottomSeparatorLeftInset = TMTableViewBuilderDefaultSeparatorInset;
    self.topSeparatorRightInset = TMTableViewBuilderDefaultSeparatorInset;
    self.bottomSeparatorRightInset = TMTableViewBuilderDefaultSeparatorInset;
    self.accessoryType = TMTableViewCellAccessoryNoChange;
}

+ (instancetype)item {
    if (![[self class] reuseIdentifier]) {
        return nil;
    }
    
    TMRowItem *item = [[[self class] alloc] initWithReuseIdentifier:[[self class] reuseIdentifier]];
    return item;
}

- (NSString *)reuseIdentifier {
    if (_reuseIdentifier) {
        return [_reuseIdentifier copy];
    }
    return [[self class] reuseIdentifier];
}

- (NSString *)nibName {
    if (_nibName) {
        return _nibName;
    }
    
    return [self reuseIdentifier];
}

- (NSIndexPath *)indexPath {
    TMSectionItem *sectionItem = self.sectionItem;
    NSUInteger row = [sectionItem indexOfRowItem:self];
    if (row != NSNotFound && sectionItem.section != NSNotFound) {
        return [NSIndexPath indexPathForRow:row inSection:sectionItem.section];
    }
    
    DDLogError(@"no indexpath found");
    return nil;
}
#pragma mark - UITableViewDataSource
- (id)cellForReuseIdentifierOrRegister:(NSString *)reuseIdentifier {
    UITableView *tableView = self.tableView;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        [tableView registerRowItem:self];
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (!cell) {
            DDLogError(@"cell is nil");
        }
    }
    return cell;
}

- (id)cellForRow {
    UITableViewCell *cell = [self cellForReuseIdentifierOrRegister:self.reuseIdentifier];
    
    cell.selectionStyle = self.selectionStyle;
    if (self.accessoryType != TMTableViewCellAccessoryNoChange) {
        cell.accessoryType = (UITableViewCellAccessoryType)self.accessoryType;
    }
    
    if (self.backgroundView && self.backgroundView != cell.backgroundView) {
        [self.backgroundView removeFromSuperview];
        cell.backgroundView = self.backgroundView;
    }
    
    
    if (self.selectedBackgroundView && self.selectedBackgroundView != cell.selectedBackgroundView) {
        [self.selectedBackgroundView removeFromSuperview];
        cell.selectedBackgroundView = self.selectedBackgroundView;
    }
    
    if (self.multipleSelectionBackgroundView && self.multipleSelectionBackgroundView != cell.multipleSelectionBackgroundView) {
        [self.multipleSelectionBackgroundView removeFromSuperview];
        cell.multipleSelectionBackgroundView = self.multipleSelectionBackgroundView;
    }
    
    cell.selected = self.selected;
    
    if ([cell isKindOfClass:[TMBaseTableViewCell class]]) {
        TMBaseTableViewCell *baseCell = (TMBaseTableViewCell *)cell;
        if (self.tmSeparatorColor) {
            baseCell.tmSeparatorColor = self.tmSeparatorColor;
        }
        baseCell.showTopSeparator = self.showTopSeparator;
        baseCell.showBottomSeparator = self.showBottomSeparator;
        if (self.topSeparatorLeftInset != TMTableViewBuilderDefaultSeparatorInset) {
            baseCell.topSeparatorLeftInset = self.topSeparatorLeftInset;
        }
        if (self.bottomSeparatorLeftInset != TMTableViewBuilderDefaultSeparatorInset) {
            baseCell.bottomSeparatorLeftInset = self.bottomSeparatorLeftInset;
        }
        if (self.topSeparatorRightInset != TMTableViewBuilderDefaultSeparatorInset) {
            baseCell.topSeparatorRightInset = self.topSeparatorRightInset;
        }
        if (self.bottomSeparatorRightInset != TMTableViewBuilderDefaultSeparatorInset) {
            baseCell.bottomSeparatorRightInset = self.bottomSeparatorRightInset;
        }
        
    }
    
    cell.rowItem = self;
    self.cell = cell;
    
    [self configureCell:cell];
    
    if (self.cellForRowBlock) {
        self.cellForRowBlock(self, cell);
    }
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell {
    
}

- (void)commitEditingStyle:(UITableViewCellEditingStyle)editingStyle {
    
}

- (void)moveRowToIndexPath:(NSIndexPath *)destinationIndexPath {
    
}
#pragma mark - UITableViewDelegate
- (void)willDisplayCell:(UITableViewCell *)cell TMP_REQUIRES_SUPER {
    if (self.willDisplayCellHandler) {
        self.willDisplayCellHandler(self, cell);
    }
}

- (void)didEndDisplayingCell:(UITableViewCell *)cell TMP_REQUIRES_SUPER {
    cell.rowItem = nil;
    self.cell = nil;
}

- (void)accessoryButtonTappedForRow {
    
}

- (void)didHighlightRow {
    
}

- (void)didUnhighlightRow {
    
}

- (NSIndexPath *)willSelectRow {
    return self.indexPath;
}

- (NSIndexPath *)willDeselectRow {
    return self.indexPath;
}

- (void)didSelectRow {
    self.selected = YES;
    
    if (self.clearsSelectionOnCellDidSelect) {
        [self deselectRowAnimated:YES];
    }
    
    if (self.didSelectRowHandler) {
        self.didSelectRowHandler(self);
    }
    
    if (self.presentingViewController &&
        _viewControllerPresentationOption &&
        _viewControllerPresentationOption.presentationStyle != TMViewControllerPresentationOptionStyleNone) {
        
        if (!self.presentedTableViewBuilderViewController) {
            self.presentedTableViewBuilderViewController = [[[self classForType:TMTableViewBuilderClassTypeTableViewBuilderViewController] alloc] init];
        }
        UIViewController<TMTableViewBuilderViewController> *simpleTableViewController = self.presentedTableViewBuilderViewController;
        
        [simpleTableViewController setViewDidLoadCompletionHandler:^(UIViewController<TMTableViewBuilderViewController> *vc) {
            if (self.viewControllerPresentationOption.viewDidLoadCompletionHandler) {
                self.viewControllerPresentationOption.viewDidLoadCompletionHandler(self, vc);
            }
        }];
        [simpleTableViewController setViewWillDisappearCompletionHandler:^(UIViewController<TMTableViewBuilderViewController> *vc, BOOL animated) {
            if (self.viewControllerPresentationOption.viewWillDisappearCompletionHandler) {
                self.viewControllerPresentationOption.viewWillDisappearCompletionHandler(self, vc, animated);
            }
        }];
        
        if (self.viewControllerPresentationOption.presentationStyle == TMViewControllerPresentationOptionnStyleShow) {
            [self.presentingViewController showViewController:simpleTableViewController sender:self];
        }
        else if (self.viewControllerPresentationOption.presentationStyle == TMViewControllerPresentationOptionStylePush) {
            [self.presentingViewController.navigationController pushViewController:simpleTableViewController animated:YES];
        }
        else if (self.viewControllerPresentationOption.presentationStyle == TMViewControllerPresentationOptionStylePresent) {
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:simpleTableViewController];
            [self.presentingViewController presentViewController:nav animated:YES completion:nil];
        }
    }
}

- (UIViewController<TMTableViewBuilderViewController> *)presentedTableViewBuilderViewController {
    if (!_presentedTableViewBuilderViewController) {
        Class SimpleTableViewControllerClass = [self.sectionItem.tableViewBuilder classForType:TMTableViewBuilderClassTypeRadioOptionsTableViewController];
        UIViewController<TMTableViewBuilderViewController> *simpleTableViewController = [[SimpleTableViewControllerClass alloc] init];
        _presentedTableViewBuilderViewController = simpleTableViewController;
    }
    return _presentedTableViewBuilderViewController;
}

- (void)didDeselectRow {
    self.selected = NO;
    
    if (self.didDeselectRowHandler) {
        self.didDeselectRowHandler(self);
    }
}

- (void)willBeginEditingRow {
    
}

- (void)didEndEditingRow {
    
}

- (NSIndexPath *)targetIndexPathForMoveFromRowToProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    return proposedDestinationIndexPath;
}

- (BOOL)shouldShowMenuForRow NS_AVAILABLE_IOS(5_0) {
    return NO;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender NS_AVAILABLE_IOS(5_0) {
    return NO;
}

- (void)performAction:(SEL)action withSender:(id)sender NS_AVAILABLE_IOS(5_0) {
    
}

- (NSArray * __nullable)editActionsForRow {
    return nil;
}

#pragma mark - UITableViewCell
- (UIView *)backgroundView {
    if (!_backgroundView && _backgroundViewColor) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = _backgroundViewColor;
        return view;
    }
    
    return _backgroundView;
}

- (UIView *)selectedBackgroundView {
    if (!_selectedBackgroundView && _selectedBackgroundViewColor) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = _selectedBackgroundViewColor;
        return view;
    }
    
    return _selectedBackgroundView;
}

- (UIView *)multipleSelectionBackgroundView {
    if (!_multipleSelectionBackgroundView && _multipleSelectionBackgroundViewColor) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = _multipleSelectionBackgroundViewColor;
        return view;
    }
    
    return _multipleSelectionBackgroundView;
}

#pragma mark Manipulating table view row
- (void)selectRowAnimated:(BOOL)animated {
    [self selectRowAnimated:animated scrollPosition:UITableViewScrollPositionNone];
}

- (void)selectRowAnimated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition {
    //didSelectRow will not be called
    self.selected = YES;
    [self.sectionItem.tableViewBuilder.tableView selectRowAtIndexPath:self.indexPath animated:animated scrollPosition:scrollPosition];
}

- (void)deselectRowAnimated:(BOOL)animated {
    //didDeselectRow will not be called
    self.selected = NO;
    [self.sectionItem.tableViewBuilder.tableView deselectRowAtIndexPath:self.indexPath animated:animated];
}

- (void)reloadRowWithAnimation:(UITableViewRowAnimation)animation {
    [self.sectionItem.tableViewBuilder.tableView reloadRowsAtIndexPaths:@[self.indexPath] withRowAnimation:animation];
}

- (void)deleteRowWithAnimation:(UITableViewRowAnimation)animation {
    NSIndexPath *indexPath = [self.indexPath copy];
    [self.sectionItem removeRowItemAtIndex:indexPath.row];
    [self.sectionItem.tableViewBuilder.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
    self.sectionItem = nil;
}

- (void)removeFromSectionItem {
    if (self.indexPath) {
        [self.sectionItem removeRowItemAtIndex:self.indexPath.row];
    }
    self.sectionItem = nil;
}

#pragma mark - TableView Manipulation
- (void)removeFromTableViewWithRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexPath *indexPath = self.indexPath;
    UITableView *tableView = self.tableView;
    [self removeFromSectionItem];
    
    if (tableView && indexPath) {
        tm_runOnMainQueueWithoutDeadlocking(^{
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
            [tableView endUpdates];
        });
    }
}
#pragma mark - Subclassing
+ (NSString *)reuseIdentifier {
    return nil;
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
    
    if (self.sectionItem) {
        return [self.sectionItem classForType:type];
    }
    
    return [[_TMKitClassLookup defaultLookup] classForType:type];
}
#pragma mark - Convenient Methods
- (UITableView *)tableView {
    return self.sectionItem.tableView;
}

#pragma mark - Core Data 
- (void)setManagedObject:(NSManagedObject * __nullable)managedObject {
    _managedObject = managedObject;
    [self didManagedObjectUpdated:managedObject];
}

- (void)didManagedObjectUpdated:(NSManagedObject * __nullable)managedObject {
    if (self.didManagedObjctUpdatedBlock) {
        self.didManagedObjctUpdatedBlock(self, managedObject);
    }
}

#pragma mark - copy
- (TMRowItem * __nullable)originalRowItem {
    if ([_originalRowItem isEqual:self]) {
        return self;
    }
    
    if (!_originalRowItem) {
        return self;
    }
    
    return _originalRowItem.originalRowItem;
}

- (id)copyWithZone:(NSZone *)zone
{
    TMRowItem *theCopy = [[[self class] allocWithZone:zone] init];  // use designated initializer
    
    //    [theCopy setSectionItem:[self.sectionItem copy]];  //section should not be copied
    [theCopy setReuseIdentifier:[self.reuseIdentifier copy]];
    //    [theCopy setIndexPath:[self.indexPath copy]];
    [theCopy setClearsSelectionOnCellDidSelect:self.clearsSelectionOnCellDidSelect];
    if ([self.context conformsToProtocol:@protocol(NSCopying)]) {
        [theCopy setContext:[self.context copy]];  //context should not be copied
    }
    else {
        [theCopy setContext:self.context];
    }
    
    //copy through property
    [theCopy setDidSelectRowHandler:self.didSelectRowHandler];
    [theCopy setDidDeselectRowHandler:self.didDeselectRowHandler];
    [theCopy setWillDisplayCellHandler:self.willDisplayCellHandler];
    [theCopy setCanEditRow:self.canEditRow];
    [theCopy setCanMoveRow:self.canMoveRow];
    [theCopy setHeightForRow:self.heightForRow];
    [theCopy setEstimatedHeightForRow:self.estimatedHeightForRow];
    [theCopy setShouldHighlightRow:self.shouldHighlightRow];
    [theCopy setEditingStyleForRow:self.editingStyleForRow];
    [theCopy setTitleForDeleteConfirmationButton:[self.titleForDeleteConfirmationButton copy]];
    //    [theCopy setEditActionsForRow:[self.editActionsForRow copy]]; //to test
    [theCopy setShouldIndentWhileEditingRow:self.shouldIndentWhileEditingRow];
    [theCopy setIndentationLevelForRow:self.indentationLevelForRow];
    
    //should view be copied?
    //    [theCopy setBackgroundView:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.backgroundView]]];
    //    [theCopy setSelectedBackgroundView:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.selectedBackgroundView]]];
    //    [theCopy setMultipleSelectionBackgroundView:[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.multipleSelectionBackgroundView]]];
    
    [theCopy setBackgroundViewColor:[self.backgroundViewColor copy]];
    [theCopy setSelectedBackgroundViewColor:[self.selectedBackgroundViewColor copy]];
    [theCopy setMultipleSelectionBackgroundViewColor:[self.multipleSelectionBackgroundViewColor copy]];
    [theCopy setSelectionStyle:self.selectionStyle];
    [theCopy setSelected:self.selected];
    [theCopy setText:[self.text copy]];
    [theCopy setDetailText:[self.detailText copy]];
    //image should not be copied?
    [theCopy setImage:self.image];
    [theCopy setHighlightedImage:self.highlightedImage];
    //    [theCopy setCell:[self.cell copy]]; //cell should not be copied
    [theCopy setTmSeparatorColor:[self.tmSeparatorColor copy]];
    [theCopy setShowBottomSeparator:self.showBottomSeparator];
    [theCopy setShowTopSeparator:self.showTopSeparator];
    [theCopy setTopSeparatorLeftInset:self.topSeparatorLeftInset];
    [theCopy setBottomSeparatorLeftInset:self.bottomSeparatorLeftInset];
    [theCopy setViewControllerPresentationOption:[self.viewControllerPresentationOption copy]];
    
    //presentingViewController is not copied
    [theCopy setPresentingViewController:self.presentingViewController];
    //no need to copy managed object
    [theCopy setManagedObject:self.managedObject];
    //copied through property attribute.
    [theCopy setDidManagedObjctUpdatedBlock:self.didManagedObjctUpdatedBlock];
    [theCopy setOriginalRowItem:self];
    
    return theCopy;
}

#pragma mark - 
- (void)reload {
    
}

- (CGFloat)heightForRow {
    if (_heightForRow != UITableViewAutomaticDimension) {
        return _heightForRow;
    }
    
    return [self.tableView tmp_heightForCellWithRowItem:self configuration:^(id cell) {
        [self configureCell:cell];
    }];
}

- (CGFloat)estimatedHeightForRow {
    // if estimatedHeightForRow is set, return it
    if (_estimatedHeightForRow != UITableViewAutomaticDimension) {
        return _estimatedHeightForRow;
    }
    
    //    otherwise, looking for ivar _heighForRow, if set, return it
    //    do not use self.heightForRow, as it might involve height calcuation
    //    as of iOS 8, for _heightForRow == 1, return 1 in estimatedHeightForRow will causing crash.
    if (_heightForRow != UITableViewAutomaticDimension &&
        _heightForRow > 1) {
        return _heightForRow;
    }
    
    return UITableViewAutomaticDimension;
}

// note: be sure to set UILabel's preferredMaxLayoutWidth before using this method.
- (CGFloat)calculatedHeightForCell:(UITableViewCell *)cell {
    
    //    for ios 7: http://stackoverflow.com/questions/18746929/using-auto-layout-in-uitableview-for-dynamic-cell-layouts-variable-row-heights
    // Make sure the constraints have been added to this cell, since it may have just been created from scratch
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds), CGRectGetHeight(cell.bounds));
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    height += 1;
    
    return height;
}

- (TMViewControllerPresentationOption *)viewControllerPresentationOption {
    if (!_viewControllerPresentationOption) {
        _viewControllerPresentationOption = [TMViewControllerPresentationOption new];
        
    }
    return _viewControllerPresentationOption;
}

@end
@interface TMWeakObjectContainer : NSObject
@property (nonatomic, readonly, weak) id target;
@end

@implementation TMWeakObjectContainer
- (instancetype) initWithTarget:(id)object
{
    if (!(self = [super init]))
        return nil;
    
    _target = object;
    
    return self;
}
@end

@implementation UITableViewCell (TMRowItem)

- (id)rowItem {
    TMWeakObjectContainer *ref = objc_getAssociatedObject(self, @selector(rowItem));
    return ref.target;
}

- (void)setRowItem:(TMRowItem *)rowItem {
    TMWeakObjectContainer *ref = [[TMWeakObjectContainer alloc] initWithTarget: rowItem];
    objc_setAssociatedObject(self, @selector(rowItem), ref, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end