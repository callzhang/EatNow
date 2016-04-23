//
//  ENLoginView.m
//  EatNow
//
//  Created by Veracruz on 16/4/23.
//  Copyright © 2016年 modocache. All rights reserved.
//

#import "ENLoginView.h"

@interface ENLoginView ()

@property (strong, nonatomic) IBOutlet UIButton *dismissButton;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (strong, nonatomic) UIView *maskView;

@end

@implementation ENLoginView

+ (instancetype)loginView {
    
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil].firstObject;
}

+ (instancetype)basicLoginView {
    ENLoginView *view = [ENLoginView loginView];
    view.basicType = YES;
    return view;
}

- (void)awakeFromNib {
    
}

- (void)show {
    UIView *view = [self topViewControlller].view;
    
    _maskView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _maskView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.3];
    [view addSubview:_maskView];
    
    self.width = [UIScreen mainScreen].bounds.size.width - 40;
    self.height = 230;
    self.center = view.centerPoint;
    [view addSubview:self];
    
    self.layer.cornerRadius = 10;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [_maskView addGestureRecognizer:tap];
    
    
    // animation
    _maskView.alpha = 0;
    CGFloat y = self.y;
    self.y = -self.height;
    [UIView animateWithDuration:0.3 delay:0 options:7 >> 16 animations:^{
        _maskView.alpha = 1;
        self.y = y;
    } completion:nil];
    
}

- (void)hide {
    [UIView animateWithDuration:0.3 delay:0 options:7 >> 16 animations:^{
        _maskView.alpha = 0;
        self.y = [UIScreen mainScreen].bounds.size.height;
    } completion:^(BOOL finished) {
        [_maskView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

- (void)setBasicType:(BOOL)basicType {
    _basicType = basicType;
    
    if (basicType) {
        _dismissButton.hidden = YES;
        _descriptionLabel.hidden = YES;
    }
}

- (IBAction)facebookButtonTouched:(id)sender {
    
}

- (IBAction)wechatButtonTouched:(id)sender {
    
}

- (IBAction)signUpButtonTouched:(id)sender {
    
}

- (UIViewController *)topViewControlller {
    UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topViewController.presentedViewController) {
        topViewController = topViewController.presentedViewController;
    }
    return topViewController;
}

- (IBAction)dismissButtonTouched:(id)sender {
    [self hide];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
