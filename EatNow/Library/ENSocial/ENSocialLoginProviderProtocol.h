//
//  ENSocialLoginProtocol.h
//  EatNow
//
//  Created by GaoYongqing on 9/4/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ENSocialLoginResponse.h"

typedef void(^ENSocialLoginHandler)(ENSocialLoginResponse *resp, NSError *error);

@protocol ENSocialLoginProviderProtocol <NSObject>

/**
 *  Provider name, should be the same as sourceApplication in AppDelegate's openUrl method.
 */
@property (nonatomic, readonly, strong) NSString *name;

/**
 *  User friendly name for this provider.
 */
@property (nonatomic, readonly, strong) NSString *displayName;

/**
 *  Request 3rd app for login. Return the access token.
 */
- (void)loginWithHandler:(ENSocialLoginHandler)handler;

@end
