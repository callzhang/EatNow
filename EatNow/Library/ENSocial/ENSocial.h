//
//  ENSocial.h
//  EatNow
//
//  Created by GaoYongqing on 10/15/15.
//  Copyright © 2015 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ENSocial : NSObject

+ (instancetype)sharedInstance;

+ (void)registerWechatApp:(NSString *)appId;

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation;

@end
