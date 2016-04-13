//
//  TMRadioOptionsTableViewControllerDelegate.h
//  Pods
//
//  Created by Zitao Xiong on 8/7/15.
//
//

@class TMRadioOptionsTableViewController;
@class TMRadioRowItem;

@protocol TMRadioOptionsTableViewControllerDelegate <NSObject>
@optional
/**
 *  if delegate implement detailTextForRadioRowItem. detailTextTransformBlcok will not be called
 *  detail text place holder will not be in effect neither.
 *  @param radioRowItem radioRowItem who asks for detail text
 *
 *  @return detail text to set;
 */
- (NSString *)detailTextForOptionsTableViewController:(TMRadioOptionsTableViewController *)optionsTableViewController;
@end
