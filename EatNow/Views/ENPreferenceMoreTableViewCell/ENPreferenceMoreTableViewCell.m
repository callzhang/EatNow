//
//  ENPreferenceMoreTableViewCell.m
//  EatNow
//
//  Created by GaoYongqing on 10/7/15.
//  Copyright © 2015 modocache. All rights reserved.
//

#import "ENPreferenceMoreTableViewCell.h"

@implementation ENPreferenceMoreTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setItem:(ENProfileItem *)item
{
    _item = item;
    
    self.titleLabel.text = item.title;
    self.valueLabel.text = item.value;
}

@end
