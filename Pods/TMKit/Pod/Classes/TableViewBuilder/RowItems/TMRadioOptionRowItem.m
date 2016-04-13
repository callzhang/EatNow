//
//  TMRadioOptionRowItem.m
//  Pods
//
//  Created by Zitao Xiong on 5/4/15.
//
//

#import "TMRadioOptionTableViewCell.h"
#import "TMRadioOptionRowItem.h"

@implementation TMRadioOptionRowItem
- (instancetype)init {
    self = [super init];
    if (self) {
        self.clearsSelectionOnCellDidSelect = NO;
    }
    return self;
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([TMRadioOptionTableViewCell class]);
}

- (id)cellForRow {
    TMRadioOptionTableViewCell *cell = [super cellForRow];
    if (self.attributedText) {
        cell.cellTextLabel.attributedText = self.attributedText;
    }
    else {
        cell.cellTextLabel.text = self.text;
    }

    cell.cellDisabled = self.disabled;
    return cell;
}

- (void)didSelectRow {
    if (self.isDisabled) {
        return;
    }
    [super didSelectRow];
}

- (void)setDisabled:(BOOL)disabled {
    [super setDisabled:disabled];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    TMRadioOptionTableViewCell *cell = (id)self.cell;
    cell.cellDisabled = disabled;
}

@end
