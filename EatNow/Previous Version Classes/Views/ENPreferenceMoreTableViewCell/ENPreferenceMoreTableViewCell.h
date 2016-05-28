//
//  ENPreferenceMoreTableViewCell.h
//  EatNow
//
//  Created by GaoYongqing on 10/7/15.
//  Copyright © 2015 modocache. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ENProfileItem.h"

@interface ENPreferenceMoreTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *valueLabel;

@property (nonatomic, strong) ENProfileItem *item;

@end
