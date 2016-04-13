//
//  TMTableViewHeaderFooterView.h
//  Pods
//
//  Created by Zitao Xiong on 7/16/15.
//
//

#import <UIKit/UIKit.h>
#import "TMSectionItem.h"

@interface TMTableViewHeaderFooterView : UITableViewHeaderFooterView
@property (nonatomic, weak) TMSectionItem *sectionItem;
@end
