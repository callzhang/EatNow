//
//  CALayer+UIColor.m
//  EatNow
//
//  Created by GaoYongqing on 9/25/15.
//  Copyright © 2015 modocache. All rights reserved.
//

#import "CALayer+UIColor.h"

@implementation CALayer (UIColor)

- (void)setBorderUIColor:(UIColor*)color {
    self.borderColor = color.CGColor;
}

- (UIColor*)borderUIColor {
    return [UIColor colorWithCGColor:self.borderColor];
}

@end
