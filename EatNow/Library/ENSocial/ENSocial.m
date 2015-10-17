//
//  ENSocial.m
//  EatNow
//
//  Created by GaoYongqing on 10/15/15.
//  Copyright © 2015 modocache. All rights reserved.
//

#import "ENSocial.h"
#import "ENAppSettings.h"
#import "WXApi.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@implementation ENSocial

+ (void)registerFacebookApp:(NSString *)appId
{
    [WXApi registerApp:appId];
}

+ (void)registerWechatApp:(NSString *)appId
{
    
}

+ (BOOL)handleOpenUrl:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return NO;
}

@end
