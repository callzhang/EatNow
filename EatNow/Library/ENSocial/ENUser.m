//
//  ENUser.m
//  EatNow
//
//  Created by GaoYongqing on 9/4/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENUser.h"

@implementation ENUser

- (NSString *)userBriefInfo
{
    NSMutableString *desc = [[NSMutableString alloc] init];
    
    [desc appendString:self.gender];
    [desc appendString:@","];
    if (self.age) {
        [desc appendString:self.age];
        [desc appendString:@","];
    }
    
    [desc appendString:self.location];
    
    return desc;
    
}

@end
