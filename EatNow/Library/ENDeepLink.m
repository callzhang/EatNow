//
//  ENDeepLink.m
//  EatNow
//
//  Created by ishangzuIOS on 16/3/6.
//  Copyright © 2016年 modocache. All rights reserved.
//

#import "ENDeepLink.h"
#import "ENServerManager.h"
@implementation ENDeepLink

+ (void)linktoRestaurantCard:(NSString *)urlString{
    
    NSArray* dataArray = [urlString componentsSeparatedByString:@"/"];
    NSDictionary *data = @{@"ID":dataArray[3]};

    [[NSNotificationCenter defaultCenter]postNotificationName:kOpenDeepLinkForRestaurant object:self userInfo:data];

}

@end
