//
//  TMRadioOptionsTableViewController.m
//  Pods
//
//  Created by Zitao Xiong on 8/3/15.
//
//

#import "TMRadioOptionsTableViewController.h"
#import "TMSearchController.h"
#import "TMSectionItem.h"
#import "EXTScope.h"
#import "EXTKeyPathCoding.h"
#import "TMRadioRowItem.h"
#import "CocoaLumberjack.h"

@interface TMRadioOptionsTableViewController ()<TMRadioOptionsTableViewControllerDataSource, UITableViewDelegate>
@property (nonatomic, strong) _TMKitClassLookup *classLookup;
@property (nonatomic, assign) BOOL didSetupRowHandlers;
@end

@implementation TMRadioOptionsTableViewController
@synthesize searchResultsController = _searchResultsController;

- (void)viewDidLoad {
    if (self.viewWillLoadHandler) {
        self.viewWillLoadHandler(self);
    }
    [super viewDidLoad];
    @weakify(self);
    
    self.tableViewBuilder.tableViewDelegate.delegate = self;
    
    [self.tableViewBuilder setReloadBlock:^(TMTableViewBuilder *builder) {
        @strongify(self);
        [builder removeAllSectionItems];
        TMSectionItem *sectionItem = [builder addedSectionItem];
        
        NSUInteger count = [self.optionsTableViewControllerDataSource numberOfOptionRowsInOptionsTableViewController:self];
        
        for (NSInteger i = 0; i < count; i ++) {
            TMRowItem *rowItem = [self.optionsTableViewControllerDataSource optionsTableViewController:self optionRowAtIndex:i];
            NSAssert([rowItem isKindOfClass:[TMRowItem class]], @"data source return not supported class:%@", [rowItem class]);
            [sectionItem addRowItem:rowItem];
            
            if (self.tableViewSeparatorStyle == TMRadioOptionTableViewControllerSeparatorStyleFirstAndLast) {
                if (i == 0) {
                    rowItem.showTopSeparator = YES;
                    rowItem.showBottomSeparator = YES;
                    rowItem.topSeparatorLeftInset = 0;
                }
                else if (i == count - 1) {
                    rowItem.showBottomSeparator = YES;
                    rowItem.bottomSeparatorLeftInset = 0;
                }
                else {
                    rowItem.showBottomSeparator = YES;
                }
            }
        }
        
        
        self.didSetupRowHandlers = YES;
    }];
    
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
    
    if (self.viewDidLoadForOptionViewController) {
        self.viewDidLoadForOptionViewController(self);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TMRowItem *rowItem = [self.tableViewBuilder rowItemAtIndexPath:indexPath];
    
    [rowItem didSelectRow];
    [rowItem selectRowAnimated:NO];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    TMRowItem *rowItem = [self.tableViewBuilder rowItemAtIndexPath:indexPath];
    [rowItem didDeselectRow];
    [rowItem deselectRowAnimated:NO];
}

- (void)selectRowAtIndexPath:(NSIndexPath * __nonnull)indexPath {
    //force view to load, refactor can cached the selectedRow
    if (!self.tableViewBuilder.isConfigured) {
        [self view];
    }
    TMRowItem *rowItem = [self.tableViewBuilder rowItemAtIndexPath:indexPath];
    [rowItem didSelectRow];
    [rowItem selectRowAnimated:NO];
}

#pragma mark - TMRadioOptionsTableViewControllerDataSource
- (NSInteger)numberOfOptionRowsInOptionsTableViewController:(TMRadioOptionsTableViewController *)optionsTableViewController {
    return [self.rowItemsForSelection count];
}

- (TMRowItem *)optionsTableViewController:(TMRadioOptionsTableViewController *)optionsTableViewController optionRowAtIndex:(NSUInteger)index {
    return [self.rowItemsForSelection objectAtIndex:index];
}

- (void)setRowItemsForSelection:(NSArray * __nonnull)rowItemsForSelection {
    _rowItemsForSelection = rowItemsForSelection;
    self.optionsTableViewControllerDataSource = self;
}

#pragma mark - TMRadioOptionsTableViewControllerDelegate

- (void)optionsTableViewController:(TMRadioOptionsTableViewController *)optionsTableViewController didSelectOptionAtIndex:(NSInteger)index {
    
}

- (void)optionsTableViewController:(TMRadioOptionsTableViewController *)optionsTableViewController didDeselectOptionAtIndex:(NSInteger)index {
    
}

#pragma mark - View Controller
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.searchResultsController.searchController.searchBar sizeToFit];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.radioRowItem updateDetailTextForTableViewCell];
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
    
    return [[_TMKitClassLookup defaultLookup] classForType:type];
}
@end
