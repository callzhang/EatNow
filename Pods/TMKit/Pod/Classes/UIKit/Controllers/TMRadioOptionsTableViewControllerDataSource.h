//
//  TMRadioOptionsTableViewControllerDataSource.h
//  Pods
//
//  Created by Zitao Xiong on 8/7/15.
//
//
@class TMRadioOptionsTableViewController, TMRowItem;

@protocol TMRadioOptionsTableViewControllerDataSource <NSObject>
@required
- (NSInteger)numberOfOptionRowsInOptionsTableViewController:(TMRadioOptionsTableViewController *)optionsTableViewController;
- (TMRowItem *)optionsTableViewController:(TMRadioOptionsTableViewController *)optionsTableViewController optionRowAtIndex:(NSUInteger)index;
@end
