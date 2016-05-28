//
//  ENRestaurantMainCell.m
//  EatNow
//
//  Created by Veracruz on 16/5/4.
//  Copyright © 2016年 modocache. All rights reserved.
//

#import "ENRestaurantMainCell.h"

#define VERTICAL_LINE_TAG 1000
#define HORIZONTAL_LINE_TAG 1001

@interface ENRestaurantMainCell ()

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray <UIView *> *placeholderLineViews;
@property (strong, nonatomic) NSArray <UIView *> *lineViews;

@end

@implementation ENRestaurantMainCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
//    [self createLines];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)cellHeight {
    return 170.0;
}

- (void)setNeedsLayout {
    [super setNeedsLayout];
    
//    [self layoutLines];
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

@end
