//
//  ENBasePreferenceRowItem.m
//  EatNow
//
//  Created by Lei Zhang on 7/12/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENBasePreferenceRowItem.h"
#import "ENBasePreferenceViewCell.h"

@implementation ENBasePreferenceRowItem
- (instancetype)init {
    self = [super init];
    if (self) {
        self.heightForRow = 60;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

+ (NSString *)reuseIdentifier {
    return @"basePreferenceCell";
}

- (UITableViewCell *)cellForRow {
    ENBasePreferenceViewCell *cell = (id) [super cellForRow];
    cell.cuisine = self.cuisine;
    cell.score = self.score;
    return cell;
}
@end
