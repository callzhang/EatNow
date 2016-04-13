//
//  TMLabelCollectionItem.m
//  Pods
//
//  Created by Zitao Xiong on 5/5/15.
//
//

#import "TMLabelCollectionItem.h"
#import "TMLabelCollectionViewCell.h"
#import "EXTKeyPathCoding.h"

@implementation TMLabelCollectionItem
+ (NSString *)reuseIdentifier {
    return NSStringFromClass([TMLabelCollectionViewCell class]);
}

- (id)cellForItem {
    TMLabelCollectionViewCell *cell = [super cellForItem];
    
    cell.cellTitleLabel.text = self.text;
    
    return cell;
}
@end
