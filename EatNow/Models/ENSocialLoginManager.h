//
//  ENSocialLoginManager.h
//  EatNow
//
//  Created by GaoYongqing on 9/4/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ENUser.h"
#import "ENSocialLoginProviderProtocol.h"

@interface ENSocialLoginManager : NSObject

/**
 *  Current login user, nil if not logined.
 *
 *  @return Current login user
 */
+ (ENUser *)currentUser;

+ (void)loginWithType:(NSString *)typeName
           completion:(ENSocialLoginHandler)completion;

+ (void)logout;

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation;


@end
