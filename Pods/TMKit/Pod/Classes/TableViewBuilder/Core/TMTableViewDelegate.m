//
//  TMTableViewDelegate.m
//
//  Created by Zitao Xiong on 4/8/15.
//  Copyright (c) 2015 Zitao Xiong. All rights reserved.
//

#import "TMTableViewDelegate.h"
#import "TMSectionItem+Protected.h"
#import "TMTableViewBuilder.h"
#import "TMRowItem.h"
#import "TMTableViewHeaderFooterView.h"
#import "TMLog.h"

@interface TMTableViewDelegate ()
@property (nonatomic, weak) TMTableViewBuilder *tableViewBuilder;

@property (nonatomic, strong) TMRowItem *rowItemForWillBeginEditingRow;
@end
@implementation TMTableViewDelegate
- (instancetype)initWithTableViewBuilder:(TMTableViewBuilder *)tableViewBuilder {
    self = [super init];
    if (self) {
        self.tableViewBuilder = tableViewBuilder;
    }
    return self;
}

// Display customization

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]) {
        [self.delegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
        return;
    }
    
    TMRowItem *rowItem = [self.tableViewBuilder rowItemAtIndexPath:indexPath];
    [rowItem willDisplayCell:cell];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:willDisplayHeaderView:forSection:)]) {
        [self.delegate tableView:tableView willDisplayHeaderView:view forSection:section];
        return;
    }
    TMSectionItem *sectionItem = [self.tableViewBuilder sectionItemAtIndex:section];
    [sectionItem willDisplayHeaderView:view];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:willDisplayFooterView:forSection:)]) {
        [self.delegate tableView:tableView willDisplayFooterView:view forSection:section];
        return;
    }
    
    TMSectionItem *sectionItem = [self.tableViewBuilder sectionItemAtIndex:section];
    [sectionItem willDisplayFooterView:view];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)]) {
        [self.delegate tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
        return;
    }
    
    /**
     *  by the time didEndDisplayCell bing called, the rowItem at indexpath might not be correct if cell deletion happens. Use associated rowItem to get the related rowItem.
     */
    TMRowItem *rowItem = [cell rowItem];
    [rowItem didEndDisplayingCell:cell];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:didEndDisplayingHeaderView:forSection:)]) {
        [self.delegate tableView:tableView didEndDisplayingHeaderView:view forSection:section];
        return;
    }
    
    if ([view isKindOfClass:[TMTableViewHeaderFooterView class]]) {
        TMTableViewHeaderFooterView *headerFooterView = (TMTableViewHeaderFooterView *)view;
        TMSectionItem *sectionItem = headerFooterView.sectionItem;
        [sectionItem didEndDisplayingFooterView:view];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:didEndDisplayingFooterView:forSection:)]) {
        [self.delegate tableView:tableView didEndDisplayingFooterView:view forSection:section];
        return;
    }
    
    if ([view isKindOfClass:[TMTableViewHeaderFooterView class]]) {
        TMTableViewHeaderFooterView *headerFooterView = (TMTableViewHeaderFooterView *)view;
        TMSectionItem *sectionItem = headerFooterView.sectionItem;
        [sectionItem didEndDisplayingFooterView:view];
    }
}

// Variable height support

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        return [self.delegate tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    
    TMRowItem *rowItem = [self.tableViewBuilder rowItemAtIndexPath:indexPath];
    return [rowItem heightForRow];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
        return [self.delegate tableView:tableView heightForHeaderInSection:section];
    }
    
    if (self.tableViewBuilder.managedType == TMTableViewBuilderManagedTypeFetchedResultsController) {
        if (section >= self.tableViewBuilder.fetchedResultsController.sections.count) {
            DDLogError(@"section index overflow: %@:%@", @(section), @(self.tableViewBuilder.numberOfSections));
            return 0;
            /**
             *  TODO: tehre is a case that section == self.tableViewBuilder.fetchedResultsController.sections.count
             *  and section == self.tableViewBuilder....count of row...
             *  It happens when controllerDidChangeContent of TMTableViewBuilder is called. I dont konw
             *  why TableView will want to access the height of already deleted section.
             */
        }
    }
    
    TMSectionItem *item = [self.tableViewBuilder sectionItemAtIndex:section];
    return item.heightForHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]) {
        return [self.delegate tableView:tableView heightForFooterInSection:section];
    }
    
    TMSectionItem *item = [self.tableViewBuilder sectionItemAtIndex:section];
    return item.heightForFooter;
}

// Use the estimatedHeight methods to quickly calcuate guessed values which will allow for fast load times of the table.
// If these methods are implemented, the above -tableView:heightForXXX calls will be deferred until views are ready to be displayed, so more expensive logic can be placed there.
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:estimatedHeightForRowAtIndexPath:)]) {
        return [self.delegate tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
    }
    
    TMRowItem *rowItem = [self.tableViewBuilder rowItemAtIndexPath:indexPath];
    CGFloat estimatedHeight = [rowItem estimatedHeightForRow];
    if (estimatedHeight != UITableViewAutomaticDimension) {
        return estimatedHeight;
    }
    
    return [self.tableViewBuilder estimatedHeightForRow];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:estimatedHeightForHeaderInSection:)]) {
        return [self.delegate tableView:tableView estimatedHeightForHeaderInSection:section];
    }
    TMSectionItem *sectionItem = [self.tableViewBuilder sectionItemAtIndex:section];
    return [sectionItem estimatedHeightForHeader];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:estimatedHeightForFooterInSection:)]) {
        return [self.delegate tableView:tableView estimatedHeightForFooterInSection:section];
    }
    
    TMSectionItem *sectionItem = [self.tableViewBuilder sectionItemAtIndex:section];
    return [sectionItem estimatedHeightForFooter];
}

// Section header & footer information. Views are preferred over title should you decide to provide both
// custom view for header. will be adjusted to default or specified header height
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        return [self.delegate tableView:tableView viewForHeaderInSection:section];
    }
    
    TMSectionItem *item = [self.tableViewBuilder sectionItemAtIndex:section];
    return [item viewForHeader];
}

// custom view for footer. will be adjusted to default or specified footer height
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
        return [self.delegate tableView:tableView viewForFooterInSection:section];
    }
    
    TMSectionItem *item = [self.tableViewBuilder sectionItemAtIndex:section];
    return [item viewForFooter];
}

// Accessories (disclosures).

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)]) {
        [self.delegate tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
        return;
    }
    
    TMRowItem *rowItem = [self.tableViewBuilder rowItemAtIndexPath:indexPath];
    [rowItem accessoryButtonTappedForRow];
}

// Selection

// -tableView:shouldHighlightRowAtIndexPath: is called when a touch comes down on a row.
// Returning NO to that message halts the selection process and does not cause the currently selected row to lose its selected look while the touch is down.
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:shouldHighlightRowAtIndexPath:)]) {
        return [self.delegate tableView:tableView shouldHighlightRowAtIndexPath:indexPath];
    }
    
    TMRowItem *rowItem = [self.tableViewBuilder rowItemAtIndexPath:indexPath];
    return [rowItem shouldHighlightRow];
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:didHighlightRowAtIndexPath:)]) {
        [self.delegate tableView:tableView didHighlightRowAtIndexPath:indexPath];
        return;
    }
    
    TMRowItem *rowItem = [self.tableViewBuilder rowItemAtIndexPath:indexPath];
    [rowItem didHighlightRow];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:didUnhighlightRowAtIndexPath:)]) {
        [self.delegate tableView:tableView didUnhighlightRowAtIndexPath:indexPath];
        return;
    }
    
    TMRowItem *rowItem = [self.tableViewBuilder rowItemAtIndexPath:indexPath];
    [rowItem didUnhighlightRow];
}

// Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)]) {
        return [self.delegate tableView:tableView willSelectRowAtIndexPath:indexPath];
    }
    
    TMRowItem *rowItem = [self.tableViewBuilder rowItemAtIndexPath:indexPath];
    NSIndexPath *returnIndexPath = [rowItem willSelectRow];
    if (![returnIndexPath isEqual:indexPath]) {
        DDLogError(@"DEBUG, why?");
    }
    return returnIndexPath;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:willDeselectRowAtIndexPath:)]) {
        return [self.delegate tableView:tableView willDeselectRowAtIndexPath:indexPath];
    }
    
    TMRowItem *rowItem = [self.tableViewBuilder rowItemAtIndexPath:indexPath];
    NSIndexPath *returnIndexPath = [rowItem willDeselectRow];
    if (![returnIndexPath isEqual:indexPath]) {
        DDLogError(@"DEBUG, why?");
    }
    return returnIndexPath;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
        return;
    }
    TMRowItem *rowItem = [self.tableViewBuilder rowItemAtIndexPath:indexPath];
    [rowItem didSelectRow];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)]) {
        [self.delegate tableView:tableView didDeselectRowAtIndexPath:indexPath];
        return;
    }
    TMRowItem *rowItem = [self.tableViewBuilder rowItemAtIndexPath:indexPath];
    [rowItem didDeselectRow];
}

// Editing

// Allows customization of the editingStyle for a particular cell located at 'indexPath'. If not implemented, all editable cells will have UITableViewCellEditingStyleDelete set for them when the table has editing property set to YES.
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:editingStyleForRowAtIndexPath:)]) {
        return [self.delegate tableView:tableView editingStyleForRowAtIndexPath:indexPath];
    }
    
    TMRowItem *rowItem = [self.tableViewBuilder rowItemAtIndexPath:indexPath];
    return [rowItem editingStyleForRow];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:)]) {
        return [self.delegate tableView:tableView titleForDeleteConfirmationButtonForRowAtIndexPath:indexPath];
    }
    
    TMRowItem *rowItem = [self.tableViewBuilder rowItemAtIndexPath:indexPath];
    return [rowItem titleForDeleteConfirmationButton];
}

// supercedes -tableView:titleForDeleteConfirmationButtonForRowAtIndexPath: if return value is non-nil
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:editActionsForRowAtIndexPath:)]) {
        return [self.delegate tableView:tableView editActionsForRowAtIndexPath:indexPath];
    }
    
    if(indexPath.row < 0) {
        DDLogError(@"indexPaht < 0 :[%@]", indexPath);
        return nil;
    }
    
    TMRowItem *rowItem = [self.tableViewBuilder rowItemAtIndexPath:indexPath];
    return [rowItem editActionsForRow];
}

// Controls whether the background is indented while editing.  If not implemented, the default is YES.  This is unrelated to the indentation level below.  This method only applies to grouped style table views.
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:shouldIndentWhileEditingRowAtIndexPath:)]) {
        return [self.delegate tableView:tableView shouldIndentWhileEditingRowAtIndexPath:indexPath];
    }
    
    TMRowItem *rowItem = [self.tableViewBuilder rowItemAtIndexPath:indexPath];
    return [rowItem shouldIndentWhileEditingRow];
}

// The willBegin/didEnd methods are called whenever the 'editing' property is automatically changed by the table (allowing insert/delete/move). This is done by a swipe activating a single row
- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:willBeginEditingRowAtIndexPath:)]) {
        [self.delegate tableView:tableView willBeginEditingRowAtIndexPath:indexPath];
        return;
    }
    
    TMRowItem *rowItem = [self.tableViewBuilder rowItemAtIndexPath:indexPath];
    [rowItem willBeginEditingRow];
    self.rowItemForWillBeginEditingRow = rowItem;
}

/**
 * if deletion happens, the indexPath when didEndEditingRow is not correct. use rowItemForWillBeginEditingRow to cache the rowItem when will begin editign row happens. 
 */
- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:didEndEditingRowAtIndexPath:)]) {
        [self.delegate tableView:tableView didEndEditingRowAtIndexPath:indexPath];
        return;
    }
    
    [self.rowItemForWillBeginEditingRow didEndEditingRow];
    self.rowItemForWillBeginEditingRow = nil;
}

// Moving/reordering

/* pending implementation
 // Allows customization of the target row for a particular row as it is being moved/reordered
 - (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
 if ([self.delegate respondsToSelector:@selector(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:)]) {
 return [self.delegate tableView:tableView targetIndexPathForMoveFromRowAtIndexPath:sourceIndexPath toProposedIndexPath:proposedDestinationIndexPath];
 }
 
 TMRowItem *rowItem = [self.tableViewBuilder rowItemAtIndexPath:sourceIndexPath];
 return [rowItem targetIndexPathForMoveFromRowToProposedIndexPath:proposedDestinationIndexPath];
 }
 */

// Indentation
// return 'depth' of row for hierarchies
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:indentationLevelForRowAtIndexPath:)]) {
        return [self.delegate tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }
    
    TMRowItem *rowItem = [self.tableViewBuilder rowItemAtIndexPath:indexPath];
    return [rowItem indentationLevelForRow];
}

// Copy/Paste.  All three methods must be implemented by the delegate.

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:shouldShowMenuForRowAtIndexPath:)]) {
        return [self.delegate tableView:tableView shouldShowMenuForRowAtIndexPath:indexPath];
    }
    
    TMRowItem *rowItem = [self.tableViewBuilder rowItemAtIndexPath:indexPath];
    return [rowItem shouldShowMenuForRow];
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if ([self.delegate respondsToSelector:@selector(tableView:canPerformAction:forRowAtIndexPath:withSender:)]) {
        return [self.delegate tableView:tableView canPerformAction:action forRowAtIndexPath:indexPath withSender:sender];
    }
    
    TMRowItem *rowItem = [self.tableViewBuilder rowItemAtIndexPath:indexPath];
    return [rowItem canPerformAction:action withSender:sender];
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if ([self.delegate respondsToSelector:@selector(tableView:performAction:forRowAtIndexPath:withSender:)]) {
        [self.delegate tableView:tableView performAction:action forRowAtIndexPath:indexPath withSender:sender];
    }
    
    TMRowItem *rowItem = [self.tableViewBuilder rowItemAtIndexPath:indexPath];
    [rowItem performAction:action withSender:sender];
}

#pragma mark - UIScrollView Delegate
//discussion: the forwarding of this method can be cached via responsToSelector to gain better performance. 
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.delegate scrollViewDidScroll:scrollView];
    }
}

#pragma mark -
- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(tableView:estimatedHeightForRowAtIndexPath:)) {
        if ([self.tableViewBuilder shouldRespondToEstimatedHeightForRow]) {
            return YES;
        }
        else {
            return NO;
        }
    }
    else if (aSelector == @selector(tableView:heightForHeaderInSection:)) {
        if (self.tableViewBuilder.selfSizingHeaderHeight) {
            return NO;
        }
        else {
            return YES;
        }
    }
    else if (aSelector == @selector(tableView:heightForFooterInSection:)) {
        if (self.tableViewBuilder.selfSizingFooterHeight) {
            return NO;
        }
        else {
            return YES;
        }
    }
    //    
    //    if (aSelector == @selector(tableView:heightForRowAtIndexPath:)) {
    //        if ([self.tableViewBuilder shouldRespondToEstimatedHeightForRow]) {
    //            return NO;
    //        }
    //        else {
    //            return YES;
    //        }
    //    }
    
    return [super respondsToSelector:aSelector];
}

@end
