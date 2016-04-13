//
//  TMExpandableSectionItem.m
//  Pods
//
//  Created by Zitao Xiong on 5/7/15.
//
//

#import "TMExpandableSectionItem.h"
#import "EXTKeyPathCoding.h"
#import "TMSectionItem+Protected.h"
#import "TMExpandableHeaderFooterView.h"

@implementation TMExpandableSectionItem
+ (NSString *)cellReuseIdentifierForHeader {
    return NSStringFromClass([TMExpandableHeaderFooterView class]);
}

- (instancetype)initWithType:(TMSectionItemType)type {
    self = [super initWithType:type];
    if (self) {
        self.heightForHeader = 44;
        self.backgroundColorForHeader = [UIColor whiteColor];
    }
    return self;
}

- (id)viewForHeader {
    TMExpandableHeaderFooterView *headerFooterView = [super viewForHeader];
    
    headerFooterView.textLabel.text = self.titleForHeader;
    headerFooterView.expand = self.expand;
    
    [headerFooterView.expandButton removeTarget:nil action:@selector(toggleExpand:) forControlEvents:UIControlEventTouchUpInside];
    [headerFooterView.expandButton addTarget:self action:@selector(toggleExpand:) forControlEvents:UIControlEventTouchUpInside];
    return headerFooterView;
}

- (void)willDisplayHeaderView:(TMExpandableHeaderFooterView *)view {
    [super willDisplayHeaderView:view];
}

- (void)didEndDisplayingHeaderView:(UIView *)view {
    [super didEndDisplayingHeaderView:view];
    
    if ([view isKindOfClass:[TMExpandableHeaderFooterView class]]) {
        TMExpandableHeaderFooterView *cell = (TMExpandableHeaderFooterView *)view;
        [cell.expandButton removeTarget:nil action:@selector(toggleExpand:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)prepareForReuse:(UITableViewHeaderFooterView *)view {
    [super prepareForReuse:view];
    if ([view isKindOfClass:[TMExpandableHeaderFooterView class]]) {
        TMExpandableHeaderFooterView *cell = (TMExpandableHeaderFooterView *)view;
        [cell.expandButton removeTarget:nil action:@selector(toggleExpand:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)expandSection {
    [self expandSectionWithRowAnimation:UITableViewRowAnimationFade];
}

- (void)unExpandSection {
    [self unExpandSectionWithRowAnimation:UITableViewRowAnimationFade];
}

- (void)expandSectionWithRowAnimation:(UITableViewRowAnimation)rowAnimation {
    self.expand = YES;
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (NSUInteger i = 0; i < self.numberOfRows; i ++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:self.section]];
    }
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:rowAnimation];
    [self.tableView endUpdates];
}

- (void)unExpandSectionWithRowAnimation:(UITableViewRowAnimation)rowAnimation {
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (NSUInteger i = 0; i < self.numberOfRows; i ++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:self.section]];
    }
    self.expand = NO;
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:rowAnimation];
    [self.tableView endUpdates];
}

- (NSInteger)numberOfRows {
    if (self.expand) {
        return [super numberOfRows];
    }
    else {
        return 0;
    }
}

- (void)toggleExpand:(id)sender {
    if (self.expand) {
        [self unExpandSection];
    }
    else {
        [self expandSection];
    }
    
    if (self.didToggleExpand) {
        self.didToggleExpand(self);
    }
}

- (BOOL)shouldResponsedToFetchedResutlsControllerDelegate {
    /**
     *  When cell is collapse, TMSectionItem should not responed to cell change callback.
     */
    if (self.expand) {
        return YES;
    }
    else {
        return NO;
    }
}

@end
