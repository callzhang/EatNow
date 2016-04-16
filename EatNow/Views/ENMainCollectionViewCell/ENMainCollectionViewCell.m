//
//  ENMainCollectionViewCell.m
//  EatNow
//
//  Created by Veracruz on 16/4/15.
//  Copyright © 2016年 modocache. All rights reserved.
//

#import "ENMainCollectionViewCell.h"

#define VERTICAL_LINE_TAG 1000
#define HORIZONTAL_LINE_TAG 1001

@interface ENMainCollectionViewCell ()

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray <UIView *> *placeholderLineViews;
@property (strong, nonatomic) NSArray <UIView *> *lineViews;
@property (strong, nonatomic) IBOutlet UIView *containerView;


@end

@implementation ENMainCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    self.layer.cornerRadius = 15;
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [UIColor colorWithRed:0.639 green:0.643 blue:0.647 alpha:1.000].CGColor;
    
    self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.layer.shadowOpacity = 0.6;
    self.layer.shadowRadius = 5;
    self.layer.shadowOffset = CGSizeZero;
    
    _containerView.layer.cornerRadius = 15;
    
    [self createLines];

}

- (void)setNeedsLayout {
    [super setNeedsLayout];
    
    [self layoutLines];
}

- (void)createLines {
    NSMutableArray *lines = [NSMutableArray array];
    for (UIView *placeholder in _placeholderLineViews) {
        UIView *line = [[UIView alloc] initWithFrame:placeholder.frame];
        line.backgroundColor = [UIColor colorWithWhite:0.750 alpha:1.000];
        [_containerView addSubview:line];
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

@end
