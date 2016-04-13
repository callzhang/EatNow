//
//  TMTableViewSearchResultsController.m
//  Pods
//
//  Created by Zitao Xiong on 6/4/15.
//
//

#import "TMTableViewSearchResultsController.h"
#import "TMSectionItem.h"
#import "TMTableViewBuilder+Protected.h"
#import "TMRowItem.h"

@interface TMTableViewSearchResultsController ()<UITableViewDelegate>

@end

@implementation TMTableViewSearchResultsController
@synthesize tableViewBuilder = _tableViewBuilder;
@synthesize searchController = _searchController;
@synthesize originalTableViewBuilder = _originalTableViewBuilder;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableViewBuilder setDidReloadData:^(TMTableViewBuilder *tableViewBuilder) {
        NSMutableArray *selectedIndexes = [NSMutableArray array];
        [tableViewBuilder tm_eachRowItem:^(TMRowItem *rowItem) {
            if (rowItem.selected) {
                [selectedIndexes addObject:rowItem.indexPath];
            }
        }];
        
        [selectedIndexes enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            [tableViewBuilder.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }];
    }];
    
    self.tableViewBuilder.tableViewDelegate.delegate = self;
    self.tableViewBuilder.tableView.allowsMultipleSelection = self.originalTableViewBuilder.tableView.allowsMultipleSelection;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self.tableViewBuilder removeAllSectionItems];
    NSPredicate *searchPredicate = [self searchPredicateWithText:searchController.searchBar.text];
    
    NSMutableArray *sections = [NSMutableArray array];
    [self.originalTableViewBuilder tm_eachSectionItem:^(TMSectionItem *sectionItem) {
        NSArray *filterRowItems = [sectionItem filterRowItemsUsingPredicate:searchPredicate];
        if (filterRowItems.count > 0) {
            //Using Deep copy
            TMSectionItem *newSectionItem = sectionItem.copy;
            NSArray *copiedRowitems;
            if ([self shouldDeepCopyRowItems]) {
                copiedRowitems = [[NSArray alloc] initWithArray:filterRowItems copyItems:YES];
            }
            else {
                copiedRowitems = [[NSArray alloc] initWithArray:filterRowItems copyItems:NO];
            }
            
            [newSectionItem insertRowItems:copiedRowitems atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, copiedRowitems.count)]];
            [sections addObject:newSectionItem];
        }
    }];
    
    if (sections.count) {
        [self.tableViewBuilder insertSectionItems:sections atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, sections.count)]];
    }
    
    [self.tableViewBuilder reloadData];
}

- (NSPredicate *)searchPredicateWithText:(NSString *)text {
    return [self.originalTableViewBuilder searchPredicateForFilteringSearchControllerWithSearchingText:text];
}

- (BOOL)shouldDeepCopyRowItems {
    return YES;
}

#pragma mark - UITableViewDelegate 
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TMRowItem *rowItem = [self.tableViewBuilder rowItemAtIndexPath:indexPath];
    [rowItem didSelectRow];
    [rowItem selectRowAnimated:NO];
    if (rowItem != rowItem.originalRowItem) {
        NSIndexPath *originalItemIndexPath = rowItem.originalRowItem.indexPath;
        [self.originalTableViewBuilder.tableViewDelegate tableView:tableView didSelectRowAtIndexPath:originalItemIndexPath];
    }
    
    //if allowsMultipleSelection is NO, the didDeselectRowAtIndexPath method will not be called, if
    //this row does not appears in the search results. So we manually check all others rows.
    //this fix will not cause visual difference because setDidReloadData block will select the correct row.
    //however, the selected property of the model is incorrect. 
    if (self.originalTableViewBuilder.tableView.allowsMultipleSelection == NO) {
       [self.originalTableViewBuilder tm_eachRowItem:^(TMRowItem *originalRow) {
           if (![originalRow isEqual:rowItem.originalRowItem]) {
               if (originalRow.selected) {
                   originalRow.selected = NO;
                   [originalRow deselectRowAnimated:NO];
               }
           }
       }];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    TMRowItem *rowItem = [self.tableViewBuilder rowItemAtIndexPath:indexPath];
    [rowItem didDeselectRow];
    [rowItem deselectRowAnimated:NO];
    
    if (rowItem != rowItem.originalRowItem) {
        NSIndexPath *originalItemIndexPath = rowItem.originalRowItem.indexPath;
        [self.originalTableViewBuilder.tableViewDelegate tableView:tableView didDeselectRowAtIndexPath:originalItemIndexPath];
    }
}
@end
