//
//  ENSocialLoginManager.h
//  EatNow
//
//  Created by GaoYongqing on 9/4/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ENUser.h"

@interface ENSocialLoginManager : NSObject

+ (BOOL)isLogin;

+ (ENUser *)loginUser;

@end
