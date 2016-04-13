//
//  TMRadioOptionsTableViewController.h
//  Pods
//
//  Created by Zitao Xiong on 8/3/15.
//
//

#import "TMTableViewBuilderViewController.h"
#import "TMTableViewBuilder.h"
#import "TMRadioRowItem.h"
#import "TMRadioOptionsTableViewControllerDataSource.h"
#import "TMRadioOptionsTableViewControllerDelegate.h"
#import "_TMKitClassLookup.h"

NS_ASSUME_NONNULL_BEGIN
//@protocol TMRadioOptionRow;
@class TMRadioRowItem;
@class TMRowItem;
@class TMTableViewBuilder;

typedef NS_ENUM(NSUInteger, TMRadioOptionTableViewControllerSeparatorStyle) {
    TMRadioOptionTableViewControllerSeparatorStyleNone,
    TMRadioOptionTableViewControllerSeparatorStyleFirstAndLast,
};

@interface TMRadioOptionsTableViewController : TMTableViewBuilderViewController<TMTableViewSearchController, TMRadioOptionsTableViewControllerDelegate, TMKitClassLookup>
@property (nonatomic, weak) TMRadioRowItem *radioRowItem;
//default is NO
@property (nonatomic, weak, nullable) NSObject<TMRadioOptionsTableViewControllerDataSource> *optionsTableViewControllerDataSource;
@property (nonatomic, weak, nullable) NSObject<TMRadioOptionsTableViewControllerDelegate> *optionsTableViewControllerDelegate;
//@property (nonatomic, assign) BOOL allowsMultipleSelection;
//@property (nonatomic, assign) BOOL allowsSingleSelectionDeselect;

/**
 *  TMRadioOptionsTableViewController can act as it data source. 
 *  set selectionModelList will set the datasource to self. 
 */
@property (nonatomic, strong) NSArray *rowItemsForSelection;

@property (nonatomic, assign) TMRadioOptionTableViewControllerSeparatorStyle tableViewSeparatorStyle;

//nil if not selected. it will return first index, if allowsMultipleSelection is enabled.
//@property (nonatomic, readonly, nullable) NSNumber *indexForSelectedRow;
//@property (nonatomic, readonly, nullable) NSIndexSet *indexesForSelectedRows;
//- (NSIndexSet *)selectRowAtIndex:(NSInteger)selectedIndex;
//- (NSIndexSet *)deselectRowAtIndex:(NSInteger)index;
//- (NSIndexSet *)toggleRowAtIndex:(NSInteger)index;

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, copy, nullable) void (^viewWillLoadHandler)(TMRadioOptionsTableViewController *vc);
//@property (nonatomic, copy, nullable) void (^didCreatedRadioOptionRowItem)(TMRadioOptionsTableViewController *vc, TMRowItem<TMRadioOptionRow> *rowItem);
@property (nonatomic, copy, nullable) void (^didChooseOptionHandler)(TMRowItem *optionRowItem);
@property (nonatomic, copy, nullable) void (^viewDidLoadForOptionViewController)(TMRadioOptionsTableViewController *vc);
@end
NS_ASSUME_NONNULL_END