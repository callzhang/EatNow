//
//  ENSocialLoginProtocol.h
//  EatNow
//
//  Created by GaoYongqing on 9/4/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#ifndef EatNow_ENSocialLoginProtocol_h
#define EatNow_ENSocialLoginProtocol_h

#import <Foundation/Foundation.h>

@protocol ENSocialLoginProviderProtocol <NSObject>

/**
 *  Request 3rd app for login.
 */
- (void)loginWithHandler:(void (^)(id resp, NSError *error))handler;

- (void)logout;

@end

#endif
