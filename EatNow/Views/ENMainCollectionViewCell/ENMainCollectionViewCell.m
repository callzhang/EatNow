//
//  ENMainCollectionViewCell.m
//  EatNow
//
//  Created by Veracruz on 16/4/15.
//  Copyright © 2016年 modocache. All rights reserved.
//

#import "ENMainCollectionViewCell.h"

@implementation ENMainCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [UIColor colorWithRed:0.639 green:0.643 blue:0.647 alpha:1.000].CGColor;
    self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.layer.shadowRadius = 5;

}

@end
