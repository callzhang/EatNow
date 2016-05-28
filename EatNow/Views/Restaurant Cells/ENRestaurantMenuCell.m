//
//  ENRestaurantMenuCell.m
//  EatNow
//
//  Created by Veracruz on 16/5/4.
//  Copyright © 2016年 modocache. All rights reserved.
//

#import "ENRestaurantMenuCell.h"

@interface ENRestaurantMenuCell ()

@property (strong, nonatomic) IBOutlet UIButton *showButton;


@end

@implementation ENRestaurantMenuCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self prepareForDisplay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)cellHeight {
    return 220.0;
}

- (void)prepareForDisplay {
    _showButton.layer.cornerRadius = _showButton.height / 2;
    _showButton.layer.borderColor = [UIColor blackColor].CGColor;
    _showButton.layer.borderWidth = 1;
}

@end
