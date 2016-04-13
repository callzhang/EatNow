//
//  TMExpandableSectionItem.h
//  Pods
//
//  Created by Zitao Xiong on 5/7/15.
//
//

#import "TMSectionItem.h"

@interface TMExpandableSectionItem : TMSectionItem
@property (nonatomic, assign, getter=isExpand) BOOL expand;
@property (nonatomic, copy) void (^didToggleExpand)(TMExpandableSectionItem *section);

- (void)expandSection;
- (void)unExpandSection;

- (IBAction)toggleExpand:(id)sender;
@end
