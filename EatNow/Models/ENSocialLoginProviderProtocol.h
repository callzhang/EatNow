//
//  ENSocialLoginProtocol.h
//  EatNow
//
//  Created by GaoYongqing on 9/4/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ENSocialLoginHandler)(id resp, NSError *error);

@protocol ENSocialLoginProviderProtocol <NSObject>

/**
 *  Provider name
 */
@property (nonatomic, readonly, strong) NSString *name;

/**
 *  Request 3rd app for login. Return the access token.
 */
- (void)loginWithHandler:(ENSocialLoginHandler)handler;

/**
 *  Logout
 */
- (void)logout;

@end
