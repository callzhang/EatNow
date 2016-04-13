//
//  TMPickerRowItem.m
//  TMKit
//
//  Created by Zitao Xiong on 4/28/15.
//  Copyright (c) 2015 Zitao Xiong. All rights reserved.
//

#import "TMPickerRowItem.h"
#import "TMPickerViewTableViewCell.h"
#import "TMInlinePickerRowItem.h"
#import "TMSectionItem.h"
#import "TMKit.h"

@implementation TMPickerRowItem
+ (NSString *)reuseIdentifier {
    return NSStringFromClass([TMPickerViewTableViewCell class]);
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.heightForRow = 44;
    }
    return self;
}

- (UITableViewCell *)cellForRow {
    TMPickerViewTableViewCell *cell = (id) [super cellForRow];
    cell.cellTitleLabel.text = self.text;
    cell.cellDetailTextLabel.text = self.text;
    return cell;
}

- (void)didSelectRow {
    [super didSelectRow];
    
    self.expand = !self.isExpand;
}

- (BOOL)isExpand {
    if (self.sectionItem.countOfRowItems >= self.indexPath.row + 1 &&
        [self.sectionItem rowItemAtIndex:self.indexPath.row + 1] == self.inlinePickerRow) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)setExpand:(BOOL)expand {
    NSParameterAssert(self.inlinePickerRow);
//    _expand = expand;
    if (expand) {
        [self.sectionItem insertRowItem:self.inlinePickerRow intoTableViewAtIndex:self.indexPath.row + 1 withRowAnimation:UITableViewRowAnimationFade];
    }
    else {
        [self.sectionItem removeRowItemFromTableViewAtIndex:self.indexPath.row + 1 withRowAnimation:UITableViewRowAnimationFade];
    }
    
    if (self.didExpandChangeHandler) {
        self.didExpandChangeHandler(self, expand);
    }
}

- (void)setInlinePickerRow:(TMInlinePickerRowItem *)inlinePickerRow {
    _inlinePickerRow = inlinePickerRow;
    _inlinePickerRow.pickerRowItem = self;
}
@end
