//
//  UIView+EasyFrame.h
//  
//
//  Created by Veracruz on 15/4/27.
//  Copyright (c) 2015年 Veracruz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (EasyFrame)

- (CGPoint)centerPoint;
- (CGFloat)insetX;
- (CGFloat)insetY;
- (CGFloat)x;
- (CGFloat)y;
- (CGFloat)centerX;
- (CGFloat)centerY;
- (CGFloat)width;
- (CGFloat)height;
- (void)setInsetX:(CGFloat)x;
- (void)setInsetY:(CGFloat)y;
- (void)setX:(CGFloat)x;
- (void)setY:(CGFloat)y;
- (void)setCenterX:(CGFloat)x;
- (void)setCenterY:(CGFloat)y;
- (void)setWidth:(CGFloat)width;
- (void)setHeight:(CGFloat)height;

@end
