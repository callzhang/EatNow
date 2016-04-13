// The MIT License (MIT)
//
// Copyright (c) 2015-2016 forkingdog ( https://github.com/forkingdog )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "UITableView+TMPTemplateLayoutCell.h"
#import <objc/runtime.h>
#import "TMRowItem.h"
#import "TMRowItem+Protected.h"
#import "UITableView+RegisterRowItem.h"

@implementation UITableView (TMPTemplateLayoutCell)

- (id)tmp_templateCellForReuseIdentifier:(NSString *)identifier {
    NSAssert(identifier.length > 0, @"Expect a valid identifier - %@", identifier);
    
    NSMutableDictionary *templateCellsByIdentifiers = objc_getAssociatedObject(self, _cmd);
    if (!templateCellsByIdentifiers) {
        templateCellsByIdentifiers = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, _cmd, templateCellsByIdentifiers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    UITableViewCell *templateCell = templateCellsByIdentifiers[identifier];
    
    if (!templateCell) {
        templateCell = [self dequeueReusableCellWithIdentifier:identifier];
        if (!templateCell) {
            return nil;
        }
//        NSAssert(templateCell != nil, @"Cell must be registered to table view for identifier - %@", identifier);
        templateCell.tmp_isTemplateLayoutCell = YES;
        templateCell.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        templateCellsByIdentifiers[identifier] = templateCell;
        [self tmp_debugLog:[NSString stringWithFormat:@"layout cell created - %@", identifier]];
    }
    
    return templateCell;
}

- (CGFloat)tmp_heightForCellWithRowItem:(TMRowItem *)rowItem configuration:(void (^)(id cell))configuration {
    UITableViewCell *cell = [self tmp_templateCellForReuseIdentifier:rowItem.reuseIdentifier];
    if (!cell) {
        [self registerRowItem:rowItem];
        cell = [self tmp_templateCellForReuseIdentifier:rowItem.reuseIdentifier];
    }
    return [self tmp_heightForCellWithCell:cell configuration:configuration];
}

- (CGFloat)tmp_heightForCellWithCell:(UITableViewCell *)cell configuration:(void (^)(id cell))configuration {
    // Manually calls to ensure consistent behavior with actual cells (that are displayed on screen).
    [cell prepareForReuse];
    
    // Customize and provide content for our template cell.
    if (configuration) {
        configuration(cell);
    }
    
    CGFloat contentViewWidth = CGRectGetWidth(self.frame);

    // If a cell has accessory view or system accessory type, its content view's width is smaller
    // than cell's by some fixed values.
    if (cell.accessoryView) {
        contentViewWidth -= 16 + CGRectGetWidth(cell.accessoryView.frame);
    } else {
        static const CGFloat systemAccessoryWidths[] = {
            [UITableViewCellAccessoryNone] = 0,
            [UITableViewCellAccessoryDisclosureIndicator] = 34,
            [UITableViewCellAccessoryDetailDisclosureButton] = 68,
            [UITableViewCellAccessoryCheckmark] = 40,
            [UITableViewCellAccessoryDetailButton] = 48
        };
        contentViewWidth -= systemAccessoryWidths[cell.accessoryType];
    }
    
    CGSize fittingSize = CGSizeZero;

    if (cell.tmp_enforceFrameLayout) {
        // If not using auto layout, you have to override "-sizeThatFits:" to provide a fitting size by yourself.
        // This is the same method used in iOS8 self-sizing cell's implementation.
        // Note: fitting height should not include separator view.
        SEL selector = @selector(sizeThatFits:);
        BOOL inherited = ![cell isMemberOfClass:UITableViewCell.class];
        BOOL overrided = [cell.class instanceMethodForSelector:selector] != [UITableViewCell instanceMethodForSelector:selector];
        if (inherited && !overrided) {
            NSAssert(NO, @"Customized cell must override '-sizeThatFits:' method if not using auto layout.");
        }
        fittingSize = [cell sizeThatFits:CGSizeMake(contentViewWidth, 0)];
    } else {
        // Add a hard width constraint to make dynamic content views (like labels) expand vertically instead
        // of growing horizontally, in a flow-layout manner.
        NSLayoutConstraint *tempWidthConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:contentViewWidth];
        [cell.contentView addConstraint:tempWidthConstraint];
        // Auto layout engine does its math
        fittingSize = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        [cell.contentView removeConstraint:tempWidthConstraint];
    }
    
    // Add 1px extra space for separator line if needed, simulating default UITableViewCell.
    if (self.separatorStyle != UITableViewCellSeparatorStyleNone) {
        fittingSize.height += 1.0 / [UIScreen mainScreen].scale;
    }
    
    if (cell.tmp_enforceFrameLayout) {
        [self tmp_debugLog:[NSString stringWithFormat:@"calculate using frame layout - %@", @(fittingSize.height)]];
    } else {
        [self tmp_debugLog:[NSString stringWithFormat:@"calculate using auto layout - %@", @(fittingSize.height)]];
    }

    return fittingSize.height;
}

- (CGFloat)tmp_heightForCellWithIdentifier:(NSString *)identifier configuration:(void (^)(id cell))configuration {
    if (!identifier) {
        return 0;
    }
    
    UITableViewCell *cell = [self tmp_templateCellForReuseIdentifier:identifier];
    
    return [self tmp_heightForCellWithCell:cell configuration:configuration];
}

- (CGFloat)tmp_heightForCellWithIdentifier:(NSString *)identifier cacheByIndexPath:(NSIndexPath *)indexPath configuration:(void (^)(id cell))configuration {
    if (!identifier || !indexPath) {
        return 0;
    }

    // Hit cache
    if ([self.tmp_indexPathHeightCache existsHeightAtIndexPath:indexPath]) {
        [self tmp_debugLog:[NSString stringWithFormat:@"hit cache by index path[%@:%@] - %@", @(indexPath.section), @(indexPath.row), @([self.tmp_indexPathHeightCache heightForIndexPath:indexPath])]];
        return [self.tmp_indexPathHeightCache heightForIndexPath:indexPath];
    }
    
    CGFloat height = [self tmp_heightForCellWithIdentifier:identifier configuration:configuration];
    [self.tmp_indexPathHeightCache cacheHeight:height byIndexPath:indexPath];
    [self tmp_debugLog:[NSString stringWithFormat: @"cached by index path[%@:%@] - %@", @(indexPath.section), @(indexPath.row), @(height)]];
    
    return height;
}

- (CGFloat)tmp_heightForCellWithIdentifier:(NSString *)identifier cacheByKey:(id<NSCopying>)key configuration:(void (^)(id cell))configuration {
    if (!identifier || !key) {
        return 0;
    }
    
    // Hit cache
    if ([self.tmp_keyedHeightCache existsHeightForKey:key]) {
        CGFloat cachedHeight = [self.tmp_keyedHeightCache heightForKey:key];
        [self tmp_debugLog:[NSString stringWithFormat:@"hit cache by key[%@] - %@", key, @(cachedHeight)]];
        return cachedHeight;
    }
    
    CGFloat height = [self tmp_heightForCellWithIdentifier:identifier configuration:configuration];
    [self.tmp_keyedHeightCache cacheHeight:height byKey:key];
    [self tmp_debugLog:[NSString stringWithFormat:@"cached by key[%@] - %@", key, @(height)]];

    return height;
}

@end

@implementation UITableViewCell (TMPTemplateLayoutCell)

- (BOOL)tmp_isTemplateLayoutCell {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setTmp_isTemplateLayoutCell:(BOOL)isTemplateLayoutCell {
    objc_setAssociatedObject(self, @selector(tmp_isTemplateLayoutCell), @(isTemplateLayoutCell), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)tmp_enforceFrameLayout {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setTmp_enforceFrameLayout:(BOOL)enforceFrameLayout {
    objc_setAssociatedObject(self, @selector(tmp_enforceFrameLayout), @(enforceFrameLayout), OBJC_ASSOCIATION_RETAIN);
}

@end
