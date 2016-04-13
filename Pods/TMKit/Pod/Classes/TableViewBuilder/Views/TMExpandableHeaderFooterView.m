//
//  TMExpandableHeaderFooterView.m
//  Pods
//
//  Created by Zitao Xiong on 5/7/15.
//
//

#import "TMExpandableHeaderFooterView.h"
@interface TMExpandableHeaderFooterView()
@property (nonatomic, assign) BOOL tm_didSetupConstraints;
@end

@implementation TMExpandableHeaderFooterView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        UIButton *expandButton = [UIButton buttonWithType:UIButtonTypeCustom];
        expandButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:expandButton];
        
        self.expandButton = expandButton;
    }
    
    return self;
}

- (void)updateConstraints {
    if (!self.tm_didSetupConstraints) {
        
        UIButton *expandButton = self.expandButton;
        
        NSArray *constrants = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[expandButton]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(expandButton)];
        [self addConstraints:constrants];
        constrants = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[expandButton]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(expandButton)];
        [self addConstraints:constrants];
        
        self.tm_didSetupConstraints = YES;
    }
    [super updateConstraints];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}
@end
