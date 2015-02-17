//
//  ENProfileViewController.h
//  EatNow
//
//  Created by Lee on 2/14/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ENProfileViewController : UITableViewController
@property (nonatomic, strong) NSDictionary *user;
@property (nonatomic, strong) NSArray *history;
@property (nonatomic, strong) NSArray *preference;
@end
