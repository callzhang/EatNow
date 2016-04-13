//
//  TMCircleShapeView.m
//  Pods
//
//  Created by Zitao Xiong on 6/12/15.
//
//

#import "TMCircleShapeView.h"

@implementation TMCircleShapeView
- (void)layoutSubviews {
    CAShapeLayer *layer = self.shapeLayer;
    layer.strokeColor = self.strokeColor.CGColor;
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat minBorder = MIN(width, height); //get the min edge
    
    CGFloat border = minBorder - self.lineWidth; // line is drawing on both side
    CGRect rect = CGRectMake((self.bounds.size.width - border ) / 2, (self.bounds.size.height - border) / 2, border, border);
    
    layer.path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:border / 2].CGPath;
}
@end
