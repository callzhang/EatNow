//
//  TMAlertPresentationController.m
//  EatNow
//
//  Created by Zitao Xiong on 5/11/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "TMAlertPresentationController.h"

@implementation TMAlertPresentationController
- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        
    }
    
    return self;
}

- (void)presentationTransitionWillBegin {
    
}

- (void)dismissalTransitionWillBegin {
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    if (completed) {

    }
    else {
    }
}

- (void)containerViewWillLayoutSubviews {
    [[self presentedView] setFrame:[self frameOfPresentedViewInContainerView]];
}

- (CGRect)frameOfPresentedViewInContainerView {
    CGSize shrink = CGSizeMake(115, 387);
    CGRect containerRect = [super frameOfPresentedViewInContainerView];
    CGRect shrinked = CGRectMake(shrink.width / 2, shrink.height / 2, containerRect.size.width - shrink.width, containerRect.size.height - shrink.height);
    
    return shrinked;
}
@end
