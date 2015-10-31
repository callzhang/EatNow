//
//  SUNSlideSwitchViewBorder.h
//  EatNow
//
//  Created by GaoYongqing on 10/29/15.
//  Copyright © 2015 modocache. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface SUNSlideSwitchViewBorder : CAShapeLayer

@property (nonatomic, assign) CGFloat indicatorX;

@property (nonatomic, assign) CGSize indicatorSize;

@property (nonatomic, strong) UIColor *indicatorBackgroundColor;

@property (nonatomic, assign) CGFloat outlineBorderWidth;

@property (nonatomic, assign) UIColor *outlineBorderColor;

@end
