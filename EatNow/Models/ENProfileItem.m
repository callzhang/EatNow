//
//  ENProfileItem.m
//  EatNow
//
//  Created by GaoYongqing on 10/7/15.
//  Copyright © 2015 modocache. All rights reserved.
//

#import "ENProfileItem.h"

@implementation ENProfileItem

- (instancetype)initWithTitle:(NSString *)title andValue:(NSString *)value
{
    if (self = [super init]) {
        _title = title;
        _value = value;
    }
    
    return self;
}

@end
