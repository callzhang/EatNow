//
//  ENSocialLoginResponse.m
//  EatNow
//
//  Created by GaoYongqing on 10/18/15.
//  Copyright © 2015 modocache. All rights reserved.
//

#import "ENSocialLoginResponse.h"

@implementation ENSocialLoginResponse

-(instancetype)initWithToken:(ENToken *)token andUser:(ENUser *)user
{
    if (self = [super init]) {
        _token = token;
        _user = user;
    }
    
    return self;
}

@end
