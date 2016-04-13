//
//  TMRightDetailRowItem.m
//  TMKit
//
//  Created by Zitao Xiong on 3/25/15.
//  Copyright (c) 2015 Nanaimostudio. All rights reserved.
//

#import "TMRightDetailRowItem.h"
#import "TMRightDetailTableViewCell.h"
#import "TMKit.h"

@implementation TMRightDetailRowItem
- (instancetype)init {
    self = [super init];
    if (self) {
        self.heightForRow = 44;
    }
    return self;
}

+ (NSString *)reuseIdentifier {
    return @"TMRightDetailTableViewCell";
}

- (UITableViewCell *)cellForRow {
    TMRightDetailTableViewCell *cell = (id) [super cellForRow];
    cell.cellTextLabel.text = self.text;
    cell.cellDetailLabel.text = self.detailText;
    return cell;
}
@end
