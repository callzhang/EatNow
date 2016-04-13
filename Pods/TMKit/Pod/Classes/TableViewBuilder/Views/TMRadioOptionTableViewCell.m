//
//  TMRadioOptionTableViewCell.m
//  Pods
//
//  Created by Zitao Xiong on 5/4/15.
//
//

#import "TMRadioOptionTableViewCell.h"

@implementation TMRadioOptionTableViewCell
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (self.cellDisabled) {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    else {
        if (self.selected) {
            self.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            self.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}
@end
