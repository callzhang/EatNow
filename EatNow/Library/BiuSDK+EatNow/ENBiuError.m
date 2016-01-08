//
//  ENBiuError.m
//  EatNow
//
//  Created by Zitao Xiong on 1/8/16.
//  Copyright © 2016 modocache. All rights reserved.
//

#import "ENBiuError.h"

NSString * const ENBiuErrorDomain = @"Eatnow.BiuSDK.Error";

@implementation NSError (ENBiuError)
+ (instancetype)biuErrorWithCode:(NSInteger)errorCode userInfo:(NSDictionary *)userInfo {
    return [NSError errorWithDomain:ENBiuErrorDomain code:errorCode userInfo:userInfo];
}
@end
