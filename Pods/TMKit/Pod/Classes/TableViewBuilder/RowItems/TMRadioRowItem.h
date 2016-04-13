//
//  TMRadioRowItem.h
//  Pods
//
//  Created by Zitao Xiong on 5/4/15.
//
//

#import "TMRowItem.h"
#import "TMTableViewBuilderTableViewController.h"
#import "TMRadioOptionsTableViewControllerDataSource.h"
#import "TMRadioOptionsTableViewControllerDelegate.h"

NS_ASSUME_NONNULL_BEGIN
@class TMTableViewBuilderTableViewController;
@class TMRadioOptionsTableViewController;
@class TMRadioRowItem;


@interface TMRadioRowItem : TMRowItem <TMRadioOptionsTableViewControllerDataSource, TMRadioOptionsTableViewControllerDelegate>
@property (nonatomic, strong, nullable) NSArray *rowItemsForSelection;

@property (nonatomic, copy) NSString *detailTextPlaceHolder;

- (instancetype)init;
- (instancetype)initWithRowItemsForSelectionWithText:(NSArray * __nullable )texts selectedIndex:(NSNumber * __nullable)index;
- (instancetype)initWithRowItemsForSelection:(NSArray * __nullable )models;


@property (nonatomic, copy, nullable) void (^viewDidLoadForOptionViewController)(TMRadioOptionsTableViewController *vc, TMRadioRowItem *radioRow);
@property (nonatomic, copy, nullable) void (^viewWillLoadForOptionViewController)(TMRadioOptionsTableViewController *vc, TMRadioRowItem *radioRow);

@property (nonatomic, strong) TMRadioOptionsTableViewController *optionTableViewController;

/**
 *  if selectedModels does not contain any object, this block will not be called
 *  if selectedModels contain 1 object, return text of the model
 *  if selectedModels contain 2 or more object, return text of model joined by ', '
 *  block is not being used if delegate method: - (NSString *)detailTextForOptionsTableViewController:(TMRadioOptionsTableViewController *)optionsTableViewController 
 *  is impletementd.
 */
@property (nonatomic, copy) NSString* (^detailTextTransformBlcok)(NSArray * selectedModels);
/**
 *  update the text for TableViewCell based on current detail text settings
 */
- (void)updateDetailTextForTableViewCell;
@end

@protocol TMRadioRowTableViewCellProtocol <NSObject>
@property (unsafe_unretained, nonatomic) UILabel *cellTitleLabel;
@property (unsafe_unretained, nonatomic) UILabel *selectionTextLabel;
@end

NS_ASSUME_NONNULL_END