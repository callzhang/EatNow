//
//  ENProfileViewController.m
//  EatNow
//
//  Created by Veracruz on 16/4/23.
//  Copyright © 2016年 modocache. All rights reserved.
//

#import "ENProfileViewController.h"
#import "ENLoginView.h"

#define VERTICAL_LINE_TAG 1000
#define HORIZONTAL_LINE_TAG 1001

@interface ENProfileViewController ()

@property (strong, nonatomic) IBOutlet UIView *upperContainerView;

@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray <UIView*> *placeholderLineViews;
@property (strong, nonatomic) NSArray <UIView *> *lineViews;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *rateLabels;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) ENLoginView *loginView;

@end

@implementation ENProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createLines];
    
    _loginView = [ENLoginView basicLoginView];
    [_upperContainerView addSubview:_loginView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self layoutLines];
    _avatarImageView.layer.cornerRadius = _avatarImageView.height / 2.0;
    
    _loginView.frame = _upperContainerView.bounds;
    [_loginView setNeedsDisplay];
}

- (void)createLines {
    NSMutableArray *lines = [NSMutableArray array];
    for (UIView *placeholder in _placeholderLineViews) {
        UIView *line = [[UIView alloc] initWithFrame:placeholder.frame];
        line.backgroundColor = [UIColor colorWithWhite:0.733 alpha:1.000];
        [placeholder.superview addSubview:line];
        [lines addObject:line];
    }
    _lineViews = [lines copy];
}

- (void)layoutLines {
    for (NSUInteger i = 0; i < _placeholderLineViews.count; i++) {
        _lineViews[i].frame = _placeholderLineViews[i].frame;
        if (_placeholderLineViews[i].tag == VERTICAL_LINE_TAG) {
            _lineViews[i].width = SINGLE_LINE_WIDTH;
            _lineViews[i].x -= SINGLE_LINE_ADJUST_OFFSET;
        } else {
            _lineViews[i].height = SINGLE_LINE_WIDTH;
            _lineViews[i].y -= SINGLE_LINE_ADJUST_OFFSET;
        }
    }
}


- (IBAction)dismissButtonTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
