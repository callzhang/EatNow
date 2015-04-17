//
//  ENHistoryViewCell.m
//  EatNow
//
//  Created by Lee on 4/16/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENHistoryViewCell.h"
#import "UIImageView+AFNetworking.h"

@implementation ENHistoryViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setRestaurant:(ENRestaurant *)restaurant{
    [self.background setImageWithURL:self.restaurant.imageUrls.firstObject];
    self.title.text = _restaurant.name;
    self.subTitile.text = _restaurant.cuisineStr;
}

@end
