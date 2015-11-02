//
//  SUNSlideSwitchViewBorder.m
//  EatNow
//
//  Created by GaoYongqing on 10/29/15.
//  Copyright © 2015 modocache. All rights reserved.
//

#import "SUNSlideSwitchViewBorder.h"

@implementation SUNSlideSwitchViewBorder

@dynamic indicatorX;

- (instancetype)init
{
    if (self = [super init]) {
        
        self.outlineBorderWidth = 0.5;
        self.outlineBorderColor = [UIColor whiteColor];
        self.indicatorSize = CGSizeMake(16, 8);
    }
    
    return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([@"indicatorX" isEqualToString:key]) {
        return YES;
    }
    
    return [super needsDisplayForKey:key];
}

- (id<CAAction>)actionForKey:(NSString *)key
{
    if ([@"indicatorX" isEqualToString:key]) {
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:key];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.fromValue = @([[self presentationLayer] indicatorX]);
        
        return animation;
    }
    
    return [super animationForKey:key];
}

- (void)display
{
    
    //get interpolated x value
    float x = [self.presentationLayer indicatorX];
    if (x == 0) {
        x = self.indicatorX;
    }
    
    //create drawing context
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGSize triangleSize = self.indicatorSize;
    CGSize size = self.bounds.size;

    // draw outline
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path,NULL,0.0,size.height);
    CGPathAddLineToPoint(path, NULL, x - triangleSize.width / 2.0, size.height);
    CGPathAddLineToPoint(path, NULL, x, size.height - triangleSize.height);
    CGPathAddLineToPoint(path, NULL, x + triangleSize.width / 2.0, size.height);
    CGPathAddLineToPoint(path, NULL, size.width, size.height);
    CGContextAddPath(ctx, path);
    CGPathRelease(path);
    
    CGContextSetLineWidth(ctx, self.outlineBorderWidth);
    CGContextSetStrokeColorWithColor(ctx, self.outlineBorderColor.CGColor);
    CGContextSetFillColorWithColor(ctx, self.indicatorBackgroundColor.CGColor);
    
    CGContextDrawPath(ctx, kCGPathFillStroke);
    
    //set backing image
    self.contents = (id)UIGraphicsGetImageFromCurrentImageContext().CGImage;
    UIGraphicsEndImageContext();
}

@end
