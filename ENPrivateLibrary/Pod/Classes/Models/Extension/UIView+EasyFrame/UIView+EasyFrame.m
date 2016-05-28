//
//  UIView+EasyFrame.m
//
//
//  Created by Veracruz on 15/4/27.
//  Copyright (c) 2015年 Veracruz. All rights reserved.
//

#import "UIView+EasyFrame.h"

@implementation UIView (EasyFrame)

- (CGPoint)centerPoint {
    
    return CGPointMake(self.width / 2, self.height / 2);
    
}

- (CGFloat)insetX {
    return self.bounds.origin.x;
}

- (CGFloat)insetY {
    return self.bounds.origin.y;
}

- (CGFloat)x {
    return self.frame.origin.x;
}

- (CGFloat)y {
    return self.frame.origin.y;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (CGFloat)centerY {
    return self.center.y;
}

- (CGFloat)width {
    
    return self.frame.size.width;
    
}

- (CGFloat)height {
    
    return self.frame.size.height;
    
}

- (void)setInsetX:(CGFloat)x {
    
    self.bounds = CGRectMake(x, self.insetY, self.bounds.size.width, self.bounds.size.height);
}

- (void)setInsetY:(CGFloat)y {
    self.bounds = CGRectMake(self.insetX, y, self.bounds.size.width, self.bounds.size.height);
}

- (void)setX:(CGFloat)x {
    
    self.frame = CGRectMake(x, self.y, self.width, self.height);
    
}

- (void)setY:(CGFloat)y {
    
    self.frame = CGRectMake(self.x, y, self.width, self.height);
    
}

- (void)setCenterX:(CGFloat)x {
    self.center = CGPointMake(x, self.center.y);
}

- (void)setCenterY:(CGFloat)y {
    self.center = CGPointMake(self.center.x, y);
}

- (void)setWidth:(CGFloat)width {
    
    self.frame = CGRectMake(self.x, self.y, width, self.height);
    
}

- (void)setHeight:(CGFloat)height {
    
    self.frame = CGRectMake(self.x, self.y, self.width, height);
    
}

@end
