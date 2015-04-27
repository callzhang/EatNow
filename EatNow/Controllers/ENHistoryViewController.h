//
//  ENHistoryViewController.h
//  EatNow
//
//  Created by Lee on 4/16/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kHistoryDetailCardDidShow;
extern NSString *const kHistoryTableViewDidShow;

@class ENRestaurantView;

@interface ENHistoryViewController : UITableViewController
@property (nonatomic, strong) ENRestaurantView *restaurantView;
@property (nonatomic, strong) UIView *mainView;
- (void)loadData;
- (void)closeRestaurantView;
@end
